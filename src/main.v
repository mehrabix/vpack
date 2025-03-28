module vpack

import os
import flag
import regex
import strings

pub struct JsModule {
pub:
    path string
    content string
    dependencies []string
    exports []string
}

pub struct ResolvedModule {
pub:
    mod JsModule
    id int
}

struct ResolverState {
mut:
    modules []ResolvedModule
    visited map[string]bool
    module_id int
}

struct Config {
    entry_path string
    output_path string
}

pub fn parse_module(path string) !JsModule {
    // Read file content
    content := os.read_file(path) or { return error('Failed to read file: $path') }

    // Extract dependencies using regex
    mut dependencies := []string{}
    mut import_pattern := regex.regex_opt('from\\s+["\']([^"\']+)["\']') or { return error('Invalid regex pattern') }

    mut matches := import_pattern.find_all_str(content)
    for m in matches {
        if m.len > 0 {
            // Extract the path from the match using another regex
            mut path_pattern := regex.regex_opt('["\']([^"\']+)["\']') or { return error('Invalid regex pattern') }
            path_matches := path_pattern.find_all_str(m)
            if path_matches.len > 0 {
                clean_path := path_matches[0].trim('"\'')
                dependencies << clean_path
            }
        }
    }

    // Extract exports
    mut exports := []string{}
    mut export_pattern := regex.regex_opt('export\\s+function\\s+(\\w+)') or { return error('Invalid regex pattern') }

    mut export_matches := export_pattern.find_all_str(content)
    for m in export_matches {
        if m.len > 0 {
            // Extract the function name using another regex
            mut name_pattern := regex.regex_opt('function\\s+(\\w+)') or { return error('Invalid regex pattern') }
            name_matches := name_pattern.find_all_str(m)
            if name_matches.len > 0 {
                clean_name := name_matches[0].trim_string_left('function ').trim(' ')
                exports << clean_name
            }
        }
    }

    return JsModule{
        path: path
        content: content
        dependencies: dependencies
        exports: exports
    }
}

pub fn resolve_import_path(import_path string, current_file_path string) string {
    // Handle relative paths
    if import_path.starts_with('.') {
        dir := os.dir(current_file_path)
        return os.join_path(dir, import_path)
    }
    // Handle absolute paths
    return import_path
}

fn resolve_single_module(mod JsModule, mut state ResolverState) ! {
    if state.visited[mod.path] {
        return
    }

    state.visited[mod.path] = true
    state.modules << ResolvedModule{
        mod: mod
        id: state.module_id
    }
    state.module_id++

    for dep in mod.dependencies {
        resolved_path := resolve_import_path(dep, mod.path)
        if !state.visited[resolved_path] {
            dep_module := parse_module(resolved_path)!
            resolve_single_module(dep_module, mut state)!
        }
    }
}

pub fn resolve_dependencies(entry_module JsModule) ![]ResolvedModule {
    mut state := ResolverState{
        modules: []ResolvedModule{}
        visited: map[string]bool{}
        module_id: 0
    }

    resolve_single_module(entry_module, mut state)!
    return state.modules
}

pub fn generate_bundle(modules []ResolvedModule) !string {
    mut bundle := strings.new_builder(1024)
    
    // Add module loader
    bundle.write_string('(function(modules) {\n')
    bundle.write_string('    function require(id) {\n')
    bundle.write_string('        const module = { exports: {} };\n')
    bundle.write_string('        modules[id](module, module.exports, require);\n')
    bundle.write_string('        return module.exports;\n')
    bundle.write_string('    }\n')
    bundle.write_string('    return require(0);\n')
    bundle.write_string('})([\n')

    // Add each module
    for i, resolved_module in modules {
        mod := resolved_module.mod
        bundle.write_string('    function(module, exports, require) {\n')
        bundle.write_string('        // Module: $mod.path\n')
        bundle.write_string(mod.content)
        bundle.write_string('\n    }')
        if i < modules.len - 1 {
            bundle.write_string(',\n')
        } else {
            bundle.write_string('\n')
        }
    }

    // Close the bundle
    bundle.write_string(']);\n')

    return bundle.str()
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
    entry_module := parse_module(config.entry_path) or {
        println('Error parsing entry module: $err')
        exit(1)
    }

    println('Found ${entry_module.dependencies.len} dependencies')
    println('Resolving dependencies...')
    // Resolve dependencies
    modules := resolve_dependencies(entry_module) or {
        println('Error resolving dependencies: $err')
        exit(1)
    }

    println('Found ${modules.len} total modules')
    println('Generating bundle...')
    // Generate bundle
    bundle_content := generate_bundle(modules) or {
        println('Error generating bundle: $err')
        exit(1)
    }

    println('Writing bundle to file...')
    // Write bundle to file
    os.write_file(config.output_path, bundle_content) or {
        println('Error writing bundle file: $err')
        exit(1)
    }

    println('Bundle generated successfully at: $config.output_path')
} 