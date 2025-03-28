module vpack.parser

import os
import regex

struct Module {
    path string
    content string
    dependencies []string
    exports []string
}

fn parse_module(path string) ?Module {
    // Read file content
    content := os.read_file(path) or {
        return error('Failed to read file: $path')
    }

    // Extract dependencies using regex
    mut dependencies := []string{}
    import_pattern := regex.regex_opt(r'import\s+.*?from\s+[\'"]([^\'"]+)[\'"]') or {
        return error('Invalid regex pattern')
    }

    matches := import_pattern.find_all_str(content)
    for match in matches {
        if match.len > 0 {
            dependencies << match
        }
    }

    // Extract exports
    mut exports := []string{}
    export_pattern := regex.regex_opt(r'export\s+(?:default\s+)?(?:const|let|var|function|class)\s+(\w+)') or {
        return error('Invalid regex pattern')
    }

    export_matches := export_pattern.find_all_str(content)
    for match in export_matches {
        if match.len > 0 {
            exports << match
        }
    }

    return Module{
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