class Player {
    constructor(id, is_ghost, player_setting) {
        this.player_setting = player_setting;

        this.id = id;

        this.is_ghost = is_ghost

        this.room = 0

        this.x = 0.0;
        this.y = 0.0;

        this.speed = player_setting.speed;
        this.sight = player_setting.sight;
    }

    serialize() {
        return `${ this.id }:${ this.is_ghost }:${ this.room }:${ this.x.toFixed(2) }:${ this.y.toFixed(2) }:${ this.speed.toFixed(2) }:${ this.sight.toFixed(2) }`;
    }
}

module.exports = Player;