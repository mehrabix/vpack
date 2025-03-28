module main

import os
import flag
import regex

struct JsModule {
    path string
    content string
    dependencies []string
}

struct ResolvedModule {
    path string
    content string
}

struct Config {
    entry_path string
    output_path string
}

fn parse_args() Config {
    mut fp := flag.new_flag_parser(os.args)
    fp.application('vpack')
    fp.description('A simple module bundler written in V')
    fp.skip_executable()

    entry_path := fp.string('entry', `e`, '', 'Entry file path')
    output_path := fp.string('output', `o`, 'bundle.js', 'Output bundle file path')

    if entry_path == '' {
        println('Error: Entry file path is required')
        println(fp.usage())
        exit(1)
    }

    println('Entry path: $entry_path')
    println('Output path: $output_path')

    return Config{
        entry_path: entry_path
        output_path: output_path
    }
}

fn main() {
    config := parse_args()

    println('Parsing entry module...')
    // Parse the entry module
    entry_module := parse_module(config.entry_path)!

    println('Found ${entry_module.dependencies.len} dependencies')
    println('Resolving dependencies...')
    // Resolve dependencies
    modules := resolve_dependencies(entry_module)!

    println('Found ${modules.len} total modules')
    println('Generating bundle...')
    // Generate bundle
    bundle_content := generate_bundle(modules)

    println('Writing bundle to file...')
    // Write bundle to file
    os.write_file(config.output_path, bundle_content)!

    println('Bundle generated successfully at: $config.output_path')
}

fn parse_module(path string) !JsModule {
    content := os.read_file(path)!
    
    mut dependencies := []string{}
    
    // Find ES6 imports
    mut import_pattern := regex.regex_opt('import\\s*\\{([^}]+)\\}\\s*from\\s*["\']([^"\']+)["\']')!
    if import_pattern.matches_string(content) {
        for m in import_pattern.find_all_str(content) {
            mut path_pattern := regex.regex_opt('["\']([^"\']+)["\']')!
            path_match := path_pattern.find_all_str(m)
            if path_match.len > 0 {
                import_path := path_match[0].trim('"\'')
                dependencies << import_path
            }
        }
    }

    // Find direct imports
    mut direct_import_pattern := regex.regex_opt('import\\s+(\\w+)\\s+from\\s*["\']([^"\']+)["\']')!
    if direct_import_pattern.matches_string(content) {
        for m in direct_import_pattern.find_all_str(content) {
            mut path_pattern := regex.regex_opt('["\']([^"\']+)["\']')!
            path_match := path_pattern.find_all_str(m)
            if path_match.len > 0 {
                import_path := path_match[0].trim('"\'')
                dependencies << import_path
            }
        }
    }

    return JsModule{
        path: path
        content: content
        dependencies: dependencies
    }
}

fn resolve_import_path(import_path string, current_path string) string {
    if import_path.starts_with('./') {
        dir := os.dir(current_path)
        return os.join_path(dir, import_path.trim_string_left('./')).replace('\\', '/')
    }
    return import_path.replace('\\', '/')
}

fn resolve_dependencies(entry_module JsModule) ![]ResolvedModule {
    mut modules := []ResolvedModule{}
    mut visited := map[string]bool{}
    mut to_visit := [entry_module]
    mut module_order := []string{}
    mut module_ids := map[string]int{}
    mut next_id := 0

    // First pass: collect all modules and their order
    for to_visit.len > 0 {
        current_module := to_visit.pop()
        if visited[current_module.path] {
            continue
        }
        visited[current_module.path] = true
        module_order << current_module.path
        module_ids[current_module.path] = next_id
        next_id++

        for dep in current_module.dependencies {
            resolved_path := resolve_import_path(dep, current_module.path)
            if !visited[resolved_path] {
                dep_module := parse_module(resolved_path)!
                to_visit << dep_module
            }
        }
    }

    // Second pass: resolve modules in the correct order
    visited = map[string]bool{}
    for path in module_order {
        if visited[path] {
            continue
        }
        visited[path] = true

        current_module := parse_module(path)!
        resolved_module := ResolvedModule{
            path: current_module.path
            content: transform_content(current_module.content, current_module.path, module_ids)
        }
        modules << resolved_module
    }

    return modules
}

fn transform_content(content string, module_path string, module_ids map[string]int) string {
    mut transformed := content

    // Transform function exports first
    mut function_export_pattern := regex.regex_opt('export\\s+function\\s+(\\w+)\\s*\\([^)]*\\)\\s*\\{[^}]*\\}') or { return transformed }
    if function_export_pattern.matches_string(transformed) {
        for m in function_export_pattern.find_all_str(transformed) {
            mut name_pattern := regex.regex_opt('function\\s+(\\w+)') or { continue }
            name_match := name_pattern.find_all_str(m)
            
            if name_match.len > 0 {
                name := name_match[0].trim_string_left('function ').trim(' ')
                function_body := m.trim_string_left('export ')
                transformed = transformed.replace(m, function_body)
                transformed = transformed + '\r\nmodule.exports.${name} = ${name};'
            }
        }
    }

    // Transform ES6 imports to CommonJS requires
    mut import_pattern := regex.regex_opt('import\\s*\\{([^}]+)\\}\\s*from\\s*["\']([^"\']+)["\']') or { return transformed }
    if import_pattern.matches_string(transformed) {
        for m in import_pattern.find_all_str(transformed) {
            mut vars_pattern := regex.regex_opt('\\{([^}]+)\\}') or { continue }
            mut path_pattern := regex.regex_opt('["\']([^"\']+)["\']') or { continue }
            
            vars_match := vars_pattern.find_all_str(m)
            path_match := path_pattern.find_all_str(m)
            
            if vars_match.len > 0 && path_match.len > 0 {
                vars := vars_match[0].trim('{}').trim(' ')
                path := path_match[0].trim('"\'')
                resolved_path := resolve_import_path(path, module_path)
                module_id := module_ids[resolved_path]
                transformed = transformed.replace(m, 'const { ${vars} } = require(${module_id})')
            }
        }
    }

    // Transform direct imports
    mut direct_import_pattern := regex.regex_opt('import\\s+(\\w+)\\s+from\\s*["\']([^"\']+)["\']') or { return transformed }
    if direct_import_pattern.matches_string(transformed) {
        for m in direct_import_pattern.find_all_str(transformed) {
            mut name_pattern := regex.regex_opt('import\\s+(\\w+)') or { continue }
            mut path_pattern := regex.regex_opt('["\']([^"\']+)["\']') or { continue }
            
            name_match := name_pattern.find_all_str(m)
            path_match := path_pattern.find_all_str(m)
            
            if name_match.len > 0 && path_match.len > 0 {
                name := name_match[0].trim_string_left('import ').trim(' ')
                path := path_match[0].trim('"\'')
                resolved_path := resolve_import_path(path, module_path)
                module_id := module_ids[resolved_path]
                transformed = transformed.replace(m, 'const ${name} = require(${module_id})')
            }
        }
    }

    // Transform class exports
    mut class_export_pattern := regex.regex_opt('export\\s+class\\s+(\\w+)\\s*\\{') or { return transformed }
    if class_export_pattern.matches_string(transformed) {
        for m in class_export_pattern.find_all_str(transformed) {
            mut name_pattern := regex.regex_opt('class\\s+(\\w+)') or { continue }
            name_match := name_pattern.find_all_str(m)
            
            if name_match.len > 0 {
                name := name_match[0].trim_string_left('class ').trim(' ')
                transformed = transformed.replace(m, 'class ${name} {')
                transformed = transformed + '\r\nmodule.exports.${name} = ${name};'
            }
        }
    }

    // Transform variable exports
    mut var_export_pattern := regex.regex_opt('export\\s+(const|let|var)\\s+(\\w+)\\s*=') or { return transformed }
    if var_export_pattern.matches_string(transformed) {
        for m in var_export_pattern.find_all_str(transformed) {
            mut name_pattern := regex.regex_opt('(const|let|var)\\s+(\\w+)') or { continue }
            name_match := name_pattern.find_all_str(m)
            
            if name_match.len > 0 {
                type_and_name := name_match[0]
                name := type_and_name.trim_string_left('const ').trim_string_left('let ').trim_string_left('var ').trim(' ')
                transformed = transformed.replace(m, '${type_and_name} =')
                transformed = transformed + '\r\nmodule.exports.${name} = ${name};'
            }
        }
    }

    // Transform default exports
    mut default_export_pattern := regex.regex_opt('export\\s+default\\s+(\\w+)') or { return transformed }
    if default_export_pattern.matches_string(transformed) {
        for m in default_export_pattern.find_all_str(transformed) {
            mut name_pattern := regex.regex_opt('default\\s+(\\w+)') or { continue }
            name_match := name_pattern.find_all_str(m)
            
            if name_match.len > 0 {
                name := name_match[0].trim_string_left('default ').trim(' ')
                transformed = transformed.replace(m, 'module.exports = ${name}')
            }
        }
    }

    // Transform named exports
    mut named_export_pattern := regex.regex_opt('export\\s+\\{([^}]+)\\}') or { return transformed }
    if named_export_pattern.matches_string(transformed) {
        for m in named_export_pattern.find_all_str(transformed) {
            mut vars_pattern := regex.regex_opt('\\{([^}]+)\\}') or { continue }
            vars_match := vars_pattern.find_all_str(m)
            
            if vars_match.len > 0 {
                vars := vars_match[0].trim('{}').trim(' ')
                transformed = transformed.replace(m, '')
                for mut var in vars.split(',') {
                    var = var.trim(' ')
                    transformed = transformed + '\r\nmodule.exports.${var} = ${var};'
                }
            }
        }
    }

    return transformed
}

fn generate_bundle(modules []ResolvedModule) string {
    mut bundle := '(function(modules) {
    function require(id) {
        const cached = require.cache[id];
        if (cached) return cached.exports;

        const module = { exports: {} };
        require.cache[id] = module;
        modules[id](module, module.exports, require);
        return module.exports;
    }
    require.cache = {};
    return require(0);
})(['

    for i, resolved_module in modules {
        if i > 0 {
            bundle += ','
        }
        bundle += '\n    function(module, exports, require) {'
        bundle += '\n        // Module: ' + resolved_module.path
        bundle += '\n        "use strict";'
        bundle += '\n' + resolved_module.content.trim_space()
        bundle += '\n        return module.exports;'
        bundle += '\n    }'
    }

    bundle += '\n])'
    return bundle
} 