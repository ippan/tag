const fs = require('fs');
const Map = require('./map');
const Game = require('./game');


class Lobby {
    constructor(setting) {
        let map = new Map();
        this.setting = setting;

        setting.rooms.forEach(room_filename => {
            map.addRoom(fs.readFileSync(`data/${ room_filename }`, 'utf8'));
        });

        this.map = map;
        this.games = [];

        this.current_game = null;

        this.current_id = 0
    }

    getCurrentGame() {
        if (this.current_game === null || this.current_game.isStarted()) {
            let game = new Game(this.current_id++, this.map, this.setting);
            this.games.push(game);
            this.current_game = game;
        }

        return this.current_game;
    }

    onConnect(websocket) {
        let current_game = this.getCurrentGame();

        current_game.onConnect(websocket);
    }

    update() {
        let games = this.games;

        let new_games = [];

        for (let i = 0; i < games.length; ++i) {
            let game = games[i];

            try {
                game.update();
            } catch (error) {
                console.log(`lobby update error ${ error }`);
            }

            if (game.is_active) {
                new_games.push(game);
            }
        }

        this.games = new_games;
    }
}

module.exports = Lobby;