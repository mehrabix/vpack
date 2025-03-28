export class Enemy {
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