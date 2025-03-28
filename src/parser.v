module parser

import os
import regex

pub struct JsModule {
pub:
    path string
    content string
    dependencies []string
    exports []string
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