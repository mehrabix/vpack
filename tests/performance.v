module main

import os
import time
import regex
import strings

struct JsModule {
pub:
    path string
    content string
    dependencies []string
    exports []string
}

struct ResolvedModule {
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

struct PerformanceResult {
pub:
    bundle_size int
    processing_time f64
    module_count int
    dependency_count int
}

fn parse_module(path string) !JsModule {
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

fn resolve_import_path(import_path string, current_file_path string) string {
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

fn resolve_dependencies(entry_module JsModule) ![]ResolvedModule {
    mut state := ResolverState{
        modules: []ResolvedModule{}
        visited: map[string]bool{}
        module_id: 0
    }

    resolve_single_module(entry_module, mut state)!
    return state.modules
}

fn generate_bundle(modules []ResolvedModule) !string {
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

fn measure_performance(entry_path string) !PerformanceResult {
    start_time := time.now()
    
    // Parse entry module
    entry_module := parse_module(entry_path)!
    
    // Resolve dependencies
    modules := resolve_dependencies(entry_module)!
    
    // Generate bundle
    bundle_content := generate_bundle(modules)!
    
    end_time := time.now()
    
    // Calculate total dependencies
    mut total_deps := 0
    for mod in modules {
        total_deps += mod.mod.dependencies.len
    }
    
    return PerformanceResult{
        bundle_size: bundle_content.len
        processing_time: end_time - start_time
        module_count: modules.len
        dependency_count: total_deps
    }
}

fn print_performance_result(name string, result PerformanceResult) {
    println('\n$name:')
    println('----------------')
    println('Bundle size: ${result.bundle_size} bytes')
    println('Processing time: ${result.processing_time:.3f}ms')
    println('Module count: $result.module_count')
    println('Total dependencies: $result.dependency_count')
    println('Average dependencies per module: ${f64(result.dependency_count) / f64(result.module_count):.1f}')
}

fn main() {
    println('Running performance tests...')
    
    // Test small bundle (calculator)
    small_result := measure_performance('examples/calculator.js') or { return }
    print_performance_result('Small Bundle (Calculator)', small_result)
    
    // Test medium bundle (counter)
    medium_result := measure_performance('examples/counter.js') or { return }
    print_performance_result('Medium Bundle (Counter)', medium_result)
    
    // Test large bundle (game)
    large_result := measure_performance('examples/game.js') or { return }
    print_performance_result('Large Bundle (Game)', large_result)
    
    // Test extra large bundle (todo)
    xlarge_result := measure_performance('examples/todo.js') or { return }
    print_performance_result('Extra Large Bundle (Todo)', xlarge_result)
} 