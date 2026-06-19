
export default function update(time, delta) {

    // Auto spin
    if (this.auto === true)
    {
        this.startTime += delta;
        if (this.startTime > 200)
        {
            this.slotMachine.spin(this.game.config.parent.probability, time);
            this.auto = false;
        }
    }

    if (this.cursors.space.isDown)
    {
        this.slotMachine.spin(this.game.config.parent.probability, time);
    }

    // If finished spinning
    if (this.slotMachine.spinning === false && this.auto === false && this.end === false)
    {
        // Allow some time for the winning sound to play
        this.end = true;
        this.startTime = 0;
        this.slotMachine.reveal_result();
    }

    if (this.end)
    {
        this.startTime += delta;
        if (this.startTime > this.game.config.parent.result_duration)
        {
            if (!this.ended)
            {
                this.game.config.parent.result(this.slotMachine.win);
                this.ended = true;
            }
        }
    }
    this.slotMachine.update(time);

}