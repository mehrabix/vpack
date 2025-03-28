export class Game {
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