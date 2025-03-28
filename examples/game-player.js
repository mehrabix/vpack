export class Player {
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