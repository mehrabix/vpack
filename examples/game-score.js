export class ScoreManager {
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