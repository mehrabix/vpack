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
        // Module: examples/counter.js
        "use strict";
const { increment, decrement, getValue } = require(1);

console.log('Initial value:', getValue());
console.log('After increment:', increment());
console.log('After increment:', increment());
console.log('After decrement:', decrement());
console.log('Final value:', getValue());
        return module.exports;
    },
    function(module, exports, require) {
        // Module: examples/counter-state.js
        "use strict";
let count = 0;

export function increment() {
    count++;
    return count;
}

export function decrement() {
    count--;
    return count;
}

export function getValue() {
    return count;
}
        return module.exports;
    }
])