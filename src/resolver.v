module resolver

import parser { JsModule, parse_module, resolve_import_path }

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