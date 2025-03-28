(function(modules) {
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
})([
    function(module, exports, require) {
        // Module: examples/main.js
        "use strict";
const { add, subtract } = require(1);

console.log('Addition: 5 + 3 =', add(5, 3));
console.log('Subtraction: 10 - 4 =', subtract(10, 4));
        return module.exports;
    },
    function(module, exports, require) {
        // Module: examples/math.js
        "use strict";
function add(a, b) {
    return a + b;
}

function subtract(a, b) {
    return a - b;
} 
module.exports.add = add;
module.exports.subtract = subtract;
        return module.exports;
    }
])