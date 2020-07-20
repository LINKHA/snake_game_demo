const PLAYER_SPEED = {
    SPEED: 3
};

export class Player {
    constructor(sprite) {
        this.sprite = sprite;
    }

    update(game, cursors, shootButton, channel) {
        this._checkCursors(cursors, channel);
        this._updateAlpha();
        this._movePlayer(channel);
    }

    _movePlayer(channel) {
        //channel.push('player_rotate', {rotation: this.direction});
    }

    _checkCursors(cursors, channel) {

        if (cursors.up.isDown) {
            channel.push('player_rotate', { x: this.sprite.x, y: this.sprite.y, deltaX: 0, deltaY: -PLAYER_SPEED.SPEED});
        }
        else if(cursors.right.isDown){
            channel.push('player_rotate', { x: this.sprite.x, y: this.sprite.y, deltaX: PLAYER_SPEED.SPEED, deltaY: 0});
        }
        else if(cursors.down.isDown){
            channel.push('player_rotate', { x: this.sprite.x, y: this.sprite.y, deltaX: 0, deltaY: PLAYER_SPEED.SPEED});
        }
        else if(cursors.left.isDown){
            channel.push('player_rotate', { x: this.sprite.x, y: this.sprite.y, deltaX: -PLAYER_SPEED.SPEED, deltaY: 0});
        }
    }

    _updateAlpha() {
        if(this.sprite.alpha < 1){
            this.sprite.alpha += (1 - this.sprite.alpha) * 0.2;
        } else {
            this.sprite.alpha = 1;
        }
    }
}
