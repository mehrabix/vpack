module bundle

import strings
import resolver { ResolvedModule }

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