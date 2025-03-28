(function(modules) {
    function require(id) {
        const module = { exports: {} };
        modules[id](module, module.exports, require);
        return module.exports;
    }
    return require(0);
})([
    function(module, exports, require) {
        // Module: examples/main.js
import { add, subtract } from './math.js';

console.log('Addition: 5 + 3 =', add(5, 3));
console.log('Subtraction: 10 - 4 =', subtract(10, 4)); 
    },
    function(module, exports, require) {
        // Module: examples\math.js
export function add(a, b) {
    return a + b;
}

export function subtract(a, b) {
    return a - b;
} 
    }
]);
