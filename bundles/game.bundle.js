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
        // Module: examples/game.js
        "use strict";
const { Game } = require(4);
const { Player } = require(3);
const { Enemy } = require(2);
const { ScoreManager } = require(1);

const game = new Game();
const player = new Player('Hero');
const enemy = new Enemy('Dragon');
const scoreManager = new ScoreManager();

console.log('Game Demo:');
console.log('----------');
console.log(`Player: ${player.name}`);
console.log(`Enemy: ${enemy.name}`);

// Simulate some game actions
player.attack(enemy);
scoreManager.addPoints(10);
enemy.attack(player);
scoreManager.addPoints(5);

console.log('\nGame State:');
console.log(`Player Health: ${player.health}`);
console.log(`Enemy Health: ${enemy.health}`);
console.log(`Score: ${scoreManager.getScore()}`);
        return module.exports;
    },
    function(module, exports, require) {
        // Module: examples/game-score.js
        "use strict";
class ScoreManager {
    constructor() {
        this.score = 0;
        this.highScore = 0;
    }

    addPoints(points) {
        this.score += points;
        if (this.score > this.highScore) {
            this.highScore = this.score;
        }
        console.log(`Score increased by ${points}!`);
    }

    getScore() {
        return this.score;
    }

    getHighScore() {
        return this.highScore;
    }

    reset() {
        this.score = 0;
    }
} 
module.exports.ScoreManager = ScoreManager;
        return module.exports;
    },
    function(module, exports, require) {
        // Module: examples/game-enemy.js
        "use strict";
class Enemy {
    constructor(name) {
        this.name = name;
        this.health = 150;
        this.strength = 15;
    }

    attack(target) {
        const damage = this.strength;
        target.takeDamage(damage);
        console.log(`${this.name} attacks for ${damage} damage!`);
    }

    takeDamage(amount) {
        this.health -= amount;
        console.log(`${this.name} takes ${amount} damage!`);
    }

    isDefeated() {
        return this.health <= 0;
    }
} 
module.exports.Enemy = Enemy;
        return module.exports;
    },
    function(module, exports, require) {
        // Module: examples/game-player.js
        "use strict";
class Player {
    constructor(name) {
        this.name = name;
        this.health = 100;
        this.strength = 10;
    }

    attack(target) {
        const damage = this.strength;
        target.takeDamage(damage);
        console.log(`${this.name} attacks for ${damage} damage!`);
    }

    takeDamage(amount) {
        this.health -= amount;
        console.log(`${this.name} takes ${amount} damage!`);
    }

    heal(amount) {
        this.health = Math.min(100, this.health + amount);
        console.log(`${this.name} heals for ${amount}!`);
    }
} 
module.exports.Player = Player;
        return module.exports;
    },
    function(module, exports, require) {
        // Module: examples/game-core.js
        "use strict";
class Game {
    constructor() {
        this.isRunning = false;
        this.level = 1;
    }

    start() {
        this.isRunning = true;
        console.log(`Game started at level ${this.level}`);
    }

    end() {
        this.isRunning = false;
        console.log('Game ended');
    }

    nextLevel() {
        this.level++;
        console.log(`Level up! Now at level ${this.level}`);
    }
} 
module.exports.Game = Game;
        return module.exports;
    }
])