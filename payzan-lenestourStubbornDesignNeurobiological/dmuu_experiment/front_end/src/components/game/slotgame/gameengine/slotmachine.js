import Phaser from 'phaser';
import { FruitReel } from './fruit_reel';

// Where to position the fruit reels
const reelOneOffset = {
    x: 91,
    y: 213
};

const reelTwoOffset = {
    x: 169,
    y: 213
};

const INITIAL_SPIN_SPEED = 1500;
const SLOW_SPIN_SPEED = 300;

const MIN_SPIN_DURATION_MS = 200;

// Max time it takes to slow down to complete stop
const SLOW_REEL_MAX_TIME_MS = 600;

class SlotMachine
{
    constructor(args)
    {
        this.x = args.x;
        this.y = args.y;

        // Parameters
        this.cheeky = args.cheeky;
        this.reward = args.reward;
        this.spin_duration = Math.max(args.spin_duration - SLOW_REEL_MAX_TIME_MS, MIN_SPIN_DURATION_MS);
        this.result_duration = args.result_duration;
        this.soundEnabled = args.sound;
        this.high = args.high;

        // Create a random data generator
        this.rand = new Phaser.Math.RandomDataGenerator();

        // Image of the slotmachine
        let sTmp = new Phaser.GameObjects.Image(args.scene, args.x, args.y, args.slotImage);
        this.slotImage = args.scene.add.existing(sTmp);

        const slot_top_left = this.slotImage.getTopLeft();

        // Add the fruit reels
        this.fruit_images = args.fruit_images;
        this.reelOnePos = {
            x: slot_top_left.x + reelOneOffset.x,
            y: slot_top_left.y + reelOneOffset.y 
        }

        this.reelTwoPos = {
            x: slot_top_left.x + reelTwoOffset.x,
            y: slot_top_left.y + reelTwoOffset.y
        }

        this.fruitReels = {
            fruitReelOne: new FruitReel({scene: args.scene, x: this.reelOnePos.x, y: this.reelOnePos.y, fruit_images: this.fruit_images, rand: this.rand}),
            fruitReelTwo: new FruitReel({scene: args.scene, x: this.reelTwoPos.x, y: this.reelTwoPos.y, fruit_images: this.fruit_images, rand: this.rand}),
        }

        // Increase depth of slotImage to bring to the front
        this.slotImage.depth += 1;

        // Sound
        this.jackpot_sound = args.scene.sound.add(args.jackpot_sound);
        this.jackpot_sound.setVolume(0.5);
        this.lose_sound = args.scene.sound.add(args.lose_sound);
        this.lose_sound.setVolume(0.5);

        // Variables for winning
        this.win = false;
        this.spinning = false;

        // Aaron revealing the result
        const aaron_pos = this.slotImage.getBottomCenter();

        this.aaron_win = args.scene.add.image(aaron_pos.x, aaron_pos.y, 'win');
        this.aaron_win.setOrigin(0.5, 0);
        this.aaron_win.visible = false;

        this.aaron_lose = args.scene.add.image(aaron_pos.x, aaron_pos.y, 'lose');
        this.aaron_lose.setOrigin(0.5, 0);
        this.aaron_lose.visible = false;

        this.aaron_cheeky_win = args.scene.add.image(aaron_pos.x, aaron_pos.y, 'cheeky_win');
        this.aaron_cheeky_win.setOrigin(0.5, 0);
        this.aaron_cheeky_win.visible = false;

        this.aaron_cheeky_lose = args.scene.add.image(aaron_pos.x, aaron_pos.y, 'cheeky_lose');
        this.aaron_cheeky_lose.setOrigin(0.5, 0);
        this.aaron_cheeky_lose.visible = false;
        
        const message_pos = this.slotImage.getTopRight();
        this.reveal_text = args.scene.add.text(message_pos.x, message_pos.y + 20, 'You win!', { fontSize: '32px', fill: '#000' });
        this.reveal_text.setOrigin(0, 0);
        this.reveal_text.visible = false;

        // Create the spinning coin
        this.coin_1 = args.scene.add.sprite(message_pos.x + 50, message_pos.y + 80, 'coin').setOrigin(0, 0);
        this.coin_2 = args.scene.add.sprite(message_pos.x + 100, message_pos.y + 80, 'coin').setOrigin(0, 0);
        args.scene.anims.create({
            key: 'spin',
            frames: args.scene.anims.generateFrameNumbers('coin'),
            frameRate: 10,
            repeat: -1
        });
        // this.coins = args.scene.add.image(message_pos.x + 30, message_pos.y + 80, 'coins').setOrigin(0, 0);
        this.coin_1.visible = false;
        this.coin_2.visible = false;
        
    }

    // Display the image of Aaron as well as text
    reveal_result()
    {
        if (this.cheeky)
        {
            if (this.win)
            {
                this.aaron_cheeky_win.visible = true;
            }
            else
            {
                this.aaron_cheeky_lose.visible = true;
            }
        }
        else
        {
            if (this.win)
            {
                this.aaron_win.visible = true;
            }
            else
            {
                this.aaron_lose.visible = true;
            }
        }

        this.reveal_text.setText(this.win ? `You won ${this.reward}!` : 'No luck this\n time!');
        this.reveal_text.visible = true;
        this.reveal_coins();
    }

    reveal_coins()
    {
        this.coin_1.visible = this.win;
        this.coin_1.anims.play('spin', true);
        if (this.high)
        {
            this.coin_2.visible = this.win;
            this.coin_2.anims.play('spin', true);
        }
    }

    // Spin the slot machine with a given probablity 0 - 100
    spin(probablity, time)
    {
        // Only spin if it isn't currently spinning
        if (!this.spinning)
        {
            let random_draw = this.rand.between(1, 100);
            let fruitOne = this.rand.pick(this.fruit_images);
            let fruitTwo = fruitOne;
            this.win = true;
            if (random_draw > probablity)
            {
                this.win = false;
                let leftover_fruits = this.fruit_images.filter(item => item !== fruitOne);
                fruitTwo = this.rand.pick(leftover_fruits);
            }

            const reelTwo_duration = this.spin_duration;
            const reelOne_duration = Math.round(this.spin_duration/3);

            this.fruitReels.fruitReelOne.spin(INITIAL_SPIN_SPEED, time, reelOne_duration, SLOW_SPIN_SPEED, fruitOne);
            this.fruitReels.fruitReelTwo.spin(INITIAL_SPIN_SPEED, time, reelTwo_duration, SLOW_SPIN_SPEED, fruitTwo);

            this.fruitOne = fruitOne;
            this.fruitTwo = fruitTwo;

            this.spinning = true;
        }
    }

    update(time)
    {
        if (this.spinning)
        {
            let fruitReelOneFinished = this.fruitReels.fruitReelOne.update(time);
            let fruitReelTwoFinished = this.fruitReels.fruitReelTwo.update(time);

            // If both have finished spinning
            if (fruitReelOneFinished && fruitReelTwoFinished)
            {
                this.spinning = false;
                if (this.soundEnabled)
                {
                    if (this.win)
                    {
                        this.jackpot_sound.play();
                    }
                    else
                    {
                        this.lose_sound.play();
                    }
                }
            }
        }
    }

}

export default SlotMachine;