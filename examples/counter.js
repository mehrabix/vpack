import { increment, decrement, getValue } from './counter-state.js';

console.log('Initial value:', getValue());
console.log('After increment:', increment());
console.log('After increment:', increment());
console.log('After decrement:', decrement());
console.log('Final value:', getValue()); 