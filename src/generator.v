module vpack.bundle

import vpack.resolver
import strings

fn generate_bundle(modules []resolver.ResolvedModule) ?string {
    mut bundle := strings.Builder{}
    
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
        module := resolved_module.module
        bundle.write_string('    function(module, exports, require) {\n')
        bundle.write_string('        // Module: $module.path\n')
        bundle.write_string(module.content)
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