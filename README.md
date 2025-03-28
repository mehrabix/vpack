# VPack - A Simple Module Bundler in V

VPack is a lightweight JavaScript module bundler written in V. It supports ES6 module syntax and bundles multiple JavaScript files into a single file.

## Features

- ES6 module support (import/export)
- Dependency resolution
- CommonJS-style module wrapping
- Fast and efficient bundling
- Support for relative and absolute paths

## Installation

1. Make sure you have V installed on your system
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/vpack.git
   cd vpack
   ```

## Usage

Basic usage:
```bash
v run src/main.v -e examples/main.js -o bundle.js
```

Options:
- `-e, --entry`: Entry file path (required)
- `-o, --output`: Output bundle file path (default: bundle.js)

## Examples

### Basic Math Operations
```javascript
// examples/main.js
import { add, subtract } from './math.js';

console.log('Addition: 5 + 3 =', add(5, 3));
console.log('Subtraction: 10 - 4 =', subtract(10, 4));
```

### Counter with State Management
```javascript
// examples/counter.js
import { increment, decrement, getValue } from './counter-state.js';

console.log('Initial value:', getValue());
console.log('After increment:', increment());
console.log('After increment:', increment());
console.log('After decrement:', decrement());
console.log('Final value:', getValue());
```

### Todo List Application
```javascript
// examples/todo.js
import { TodoList } from './todo-list.js';
import { TodoItem } from './todo-item.js';

const list = new TodoList();
const item1 = new TodoItem('Learn V programming');
const item2 = new TodoItem('Build a module bundler');
const item3 = new TodoItem('Write tests');

list.add(item1);
list.add(item2);
list.add(item3);
list.print();
```

## Performance Tests

Run the performance tests:
```bash
v run tests/performance.v
```

The tests measure bundling time for different scenarios:

### Test Results
1. Small Bundle (2 modules)
   - Bundle size: 635 bytes
   - Processing time: < 1ms
   - Example: Basic math operations (main.js + math.js)

2. Medium Bundle (3 modules)
   - Bundle size: 897 bytes
   - Processing time: ~1s
   - Example: Counter application (counter.js + counter-state.js)

3. Large Bundle (4 modules)
   - Bundle size: 1202 bytes
   - Processing time: < 1ms
   - Example: Todo list application (todo.js + todo-list.js + todo-item.js)

### Performance Analysis
- The bundler shows excellent performance for small and large bundles
- Medium bundle processing time is currently higher than expected and is being optimized
- Bundle sizes are optimized and reasonable for the included code
- Memory usage remains constant across different bundle sizes

## Development

### Project Structure
```
vpack/
├── src/
│   └── main.v         # Main bundler implementation
├── examples/
│   ├── main.js        # Basic math example
│   ├── math.js        # Math operations module
│   ├── counter.js     # Counter example
│   ├── counter-state.js # Counter state module
│   ├── todo.js        # Todo list example
│   ├── todo-list.js   # Todo list class
│   └── todo-item.js   # Todo item class
├── tests/
│   └── performance.v  # Performance tests
└── v.mod             # V module file
```

### Building
```bash
v build src/main.v -o vpack.exe
```

## License

MIT License - see LICENSE file for details
