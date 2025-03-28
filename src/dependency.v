module vpack.resolver

import vpack.parser

struct ResolvedModule {
    module parser.Module
    id int
}

fn resolve_dependencies(entry_module parser.Module) ?[]ResolvedModule {
    mut modules := []ResolvedModule{}
    mut visited := map[string]bool{}
    mut module_id := 0

    fn resolve_module(module parser.Module, mut modules []ResolvedModule, mut visited map[string]bool, mut module_id int) ? {
        if visited[module.path] {
            return
        }

        visited[module.path] = true
        modules << ResolvedModule{
            module: module
            id: module_id
        }
        module_id++

        for dep in module.dependencies {
            resolved_path := parser.resolve_import_path(dep, module.path)
            if !visited[resolved_path] {
                dep_module := parser.parse_module(resolved_path) or {
                    return error('Failed to parse dependency: $resolved_path')
                }
                resolve_module(dep_module, mut modules, mut visited, mut module_id)?
            }
        }
    }

    resolve_module(entry_module, mut modules, mut visited, mut module_id)?
    return modules
} 