export class TodoItem {
    constructor(text) {
        this.text = text;
        this.completed = false;
    }

    complete() {
        this.completed = true;
    }

    toString() {
        return `${this.text}${this.completed ? ' ✓' : ''}`;
    }
} 