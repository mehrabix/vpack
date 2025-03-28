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
        // Module: examples/calculator.js
        "use strict";
const { add, subtract, multiply, divide } = require(2);
const { formatResult } = require(1);

const num1 = 10;
const num2 = 5;

console.log('Calculator Demo:');
console.log('----------------');
console.log(`Addition: ${formatResult(add(num1, num2))}`);
console.log(`Subtraction: ${formatResult(subtract(num1, num2))}`);
console.log(`Multiplication: ${formatResult(multiply(num1, num2))}`);
console.log(`Division: ${formatResult(divide(num1, num2))}`);
        return module.exports;
    },
    function(module, exports, require) {
        // Module: examples/calculator-utils.js
        "use strict";
function formatResult(value) {
    return value.toFixed(2);
}

function validateInput(value) {
    if (typeof value !== 'number') {
        throw new Error('Input must be a number');
    }
    return true;
} 
module.exports.formatResult = formatResult;
module.exports.validateInput = validateInput;
        return module.exports;
    },
    function(module, exports, require) {
        // Module: examples/calculator-ops.js
        "use strict";
function add(a, b) {
    return a + b;
}

function subtract(a, b) {
    return a - b;
}

function multiply(a, b) {
    return a * b;
}

function divide(a, b) {
    if (b === 0) {
        throw new Error('Division by zero');
    }
    return a / b;
} 
module.exports.add = add;
module.exports.subtract = subtract;
module.exports.multiply = multiply;
module.exports.divide = divide;
        return module.exports;
    }
])