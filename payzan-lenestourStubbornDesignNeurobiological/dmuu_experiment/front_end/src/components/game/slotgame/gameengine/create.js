import SlotMachine from './slotmachine';

export default function create() {

    // Keyboard input
    this.cursors = this.input.keyboard.createCursorKeys();
    
    // Create the slot machine

    const { cheeky, reward, spin_duration, result_duration, sound, high } = this.game.config.parent; 

    this.slotArgs = {
        scene: this,
        x: this.cameras.main.centerX,
        y: 272,
        slotImage: 'slotMachine',
        fruit_images: ['apple', 'banana', 'cherry', 'lemon', 'orange', 'pineapple', 'strawberry'],
        jackpot_sound: 'jackpot',
        lose_sound: 'lose_snd',
        cheeky,
        reward,
        spin_duration,
        result_duration,
        sound,
        high
    }

    this.slotMachine = new SlotMachine(this.slotArgs);

    this.auto = true;
    this.startTime = 0;

    this.end = false;
    this.ended = false; // Fix bug where it calls result function too many times
}