import Phaser from 'phaser';

// Stop spinning if the reel gets within so many pixels
// Makes the reel stopping look smoother
const PIXEL_REEL_STOP_THRESHOLD = 20;

// A fruit reel is made up of fruits
export class Fruit extends Phaser.Physics.Arcade.Image {
    constructor(args) {
        super(args.scene, args.x, args.y, args.img);
        args.scene.add.existing(this).setOrigin(0, 0);
        args.scene.physics.add.existing(this).setOrigin(0, 0);
    }
}

// The fruit reel uses 3 fruit sprites
export class FruitReel {
    constructor(args)
    {
        this.x = args.x;
        this.y = args.y;
        this.fruit_images = args.fruit_images;
        this.rand = args.rand;

        // Initialize the fruit reel
        this.fruits = [];
        for (let i = 0; i < 3; ++i)
        {
            let rand_img = this.rand.pick(this.fruit_images);
            this.fruits.push(new Fruit({scene: args.scene, x: args.x, y: args.y + i*64, img: rand_img}));
        }

        // The co-ordinates for the top of the reel
        this.top = this.y - 64;

        // Keep track of the ordering of the fruits on the reel
        this.top_index = 0;
        this.mid_index = 1;
        this.bottom_index = 2;

        // For spinning slow down
        this.slowDownTime = 0; // Time to spin the reel
        this.startSpinTime = 0;
        this.slowDownSlope = 0; // The speed slows down linearly
        this.spinning = false;

        // Which fruit to rig and stop on
        this.closeToStop = false;
        this.stopIndex = 0;
        this.rigged = false;
        this.stopped = false;

        this.reelVelocity = 0;

    }

    // If the top goes offscreen, move it to the bottom
    // Update indexes appropriately
    check_offscreen() 
    {
        if (this.spinning)
        {
            let top_fruit = this.fruits[this.top_index];
            const top_pos = top_fruit.getTopLeft().y;
            if (top_pos <= this.top)
            {
                // Choose a fruit
                let rand_img = this.rand.pick(this.fruit_images);
                // Rigging the game
                if (this.closeToStop === true && this.top_index === this.stopIndex)
                {
                    rand_img = this.endFruit;
                    this.rigged = true;
                }

                // Place the top after the bottom
                let bot_y = this.fruits[this.bottom_index];
                const bot_left = bot_y.getBottomRight();

                top_fruit.y = bot_left.y;
                top_fruit.setTexture(rand_img);

                // Update indexes
                let tmp = this.top_index;
                this.top_index = this.mid_index;
                this.mid_index = this.bottom_index;
                this.bottom_index = tmp;
            }
        }
        
    }

    calcSlowDownVelocity(time)
    {
        let time_since_spin = time - this.startSpinTime;
        if (!this.closeToStop)
        {
            this.reelVelocity = - (this.initialVelocity + this.slowToStopSpeed - this.slowDownSlope*(time_since_spin));

            if (time_since_spin > this.slowDownTime)
            {
                this.closeToStop = true;

                // Set the top as the index to stop on
                this.stopIndex = this.top_index;
                this.reelVelocity = -this.slowToStopSpeed;
            }
        }
        else
        {
            const fruitToStopOn = this.fruits[this.stopIndex];
            const stopFruitPos = fruitToStopOn.getTopLeft().y - PIXEL_REEL_STOP_THRESHOLD;

            if (stopFruitPos < this.y && this.rigged)
                this.reelVelocity = 0;
        }
    }

    slowDown(time)
    {
        if (this.spinning)
        {
            this.calcSlowDownVelocity(time);
            this.setReelVelocity();
            if (this.reelVelocity === 0)
            {
                this.spinning = false;
                this.closeToStop = false;
                
            }
        }
    }

    // Returns whether the reel has stopped
    update(time)
    {
        if (this.reelVelocity === 0) {
            if (!this.stopped) {
                const fruitToStopOn = this.fruits[this.stopIndex];
                const stopFruitPos = fruitToStopOn.getTopLeft().y;
                const offset = this.y - stopFruitPos;

                this.setReelLocation(offset);
                this.stopped = true;
            }
            return true;
        } else {
            this.slowDown(time);
            this.check_offscreen();
        }
        return false;
    }

    setReelLocation(offset) {
        for (let i = 0; i < 3; ++i) {
            const curFruitPos = this.fruits[i].getTopLeft().y;
            const newPos = curFruitPos + offset;

            this.fruits[i].setY(newPos);
        }
    }

    setReelVelocity()
    {
        for (let i = 0; i < 3; ++i)
        {
            this.fruits[i].setVelocityY(this.reelVelocity);
        }
    }
   
    // InitialVelocity: Speed to start the spin
    // slowdownTime: Time in milliseconds before coming to a complete halt
    spin(initialVelocity, time, slowDownTime, slowToStopSpeed, endFruit)
    {
        if (!this.spinning)
        {
            this.slowDownTime = slowDownTime;
            this.startSpinTime = time;
            this.spinning = true;
            this.slowDownSlope = initialVelocity/slowDownTime;
            this.initialVelocity = initialVelocity;
            this.slowToStopSpeed = slowToStopSpeed;
            this.endFruit = endFruit;
            this.rigged = false;

            this.reelVelocity = -initialVelocity;
            this.setReelVelocity();
        }
    }
}