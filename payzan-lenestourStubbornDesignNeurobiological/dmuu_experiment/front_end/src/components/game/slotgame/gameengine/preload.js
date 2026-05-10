// Preload images

export default function preload() {
    let pub = process.env.PUBLIC_URL;
    this.load.image('slotMachine', pub + '/assets/slot-machine.png');
    this.load.image('apple', pub + '/assets/apple.jpg');
    this.load.image('banana', pub + '/assets/banana.jpg');
    this.load.image('cherry', pub + '/assets/cherry.jpg');
    this.load.image('lemon', pub + '/assets/lemon.jpg');
    this.load.image('orange', pub + '/assets/orange.jpg');
    this.load.image('pineapple', pub + '/assets/pineapple.jpg');
    this.load.image('strawberry', pub + '/assets/strawberry.jpg');

    this.load.audio('jackpot', pub + '/assets/jackpot.mp3');
    this.load.audio('lose_snd', pub + '/assets/lose.mp3');

    // Aaron reveal images
    this.load.image('win', pub + '/assets/aaron_reveal_win.png');
    this.load.image('lose', pub + '/assets/aaron_reveal_lose.png');
    this.load.image('cheeky_win', pub + '/assets/aaron_cheeky_reveal_win.png');
    this.load.image('cheeky_lose', pub + '/assets/aaron_cheeky_reveal_lose.png');
    this.load.image('coins', pub + '/assets/coins.png');


    this.load.spritesheet('coin', pub + '/assets/coin_spin.png', {frameWidth: 82, frameHeight: 84});

}