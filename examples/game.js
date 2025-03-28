import { Game } from './game-core.js';
import { Player } from './game-player.js';
import { Enemy } from './game-enemy.js';
import { ScoreManager } from './game-score.js';

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