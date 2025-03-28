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