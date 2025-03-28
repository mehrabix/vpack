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
        // Module: examples/todo.js
        "use strict";
const { TodoList } = require(2);
const { TodoItem } = require(1);

const list = new TodoList();
const item1 = new TodoItem('Learn V programming');
const item2 = new TodoItem('Build a module bundler');
const item3 = new TodoItem('Write tests');

list.add(item1);
list.add(item2);
list.add(item3);

console.log('Todo List:');
list.print();
console.log('\nMarking first item as complete...');
item1.complete();
list.print();
        return module.exports;
    },
    function(module, exports, require) {
        // Module: examples/todo-item.js
        "use strict";
class TodoItem {
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
module.exports.TodoItem = TodoItem;
        return module.exports;
    },
    function(module, exports, require) {
        // Module: examples/todo-list.js
        "use strict";

        return module.exports;
    }
])