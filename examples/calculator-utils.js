export function formatResult(value) {
    return value.toFixed(2);
}

export function validateInput(value) {
    if (typeof value !== 'number') {
        throw new Error('Input must be a number');
    }
    return true;
} 