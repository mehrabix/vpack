import { TodoList } from './todo-list.js';
import { TodoItem } from './todo-item.js';

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