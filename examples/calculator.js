import { add, subtract, multiply, divide } from './calculator-ops.js';
import { formatResult } from './calculator-utils.js';

const num1 = 10;
const num2 = 5;

console.log('Calculator Demo:');
console.log('----------------');
console.log(`Addition: ${formatResult(add(num1, num2))}`);
console.log(`Subtraction: ${formatResult(subtract(num1, num2))}`);
console.log(`Multiplication: ${formatResult(multiply(num1, num2))}`);
console.log(`Division: ${formatResult(divide(num1, num2))}`); 