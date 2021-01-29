const fs = require('fs');
const Map = require('./map');
const Game = require('./game');


class Lobby {
    constructor(setting) {
        let map = new Map();
        setting.rooms.forEach(room_filename => {
            map.addRoom(fs.readFileSync(`data/${ room_filename }`, 'utf8'));
        });

        this.map = map;
        this.games = [];
        this.free_games = [];
    }

    onConnect(websocket) {

    }

    update() {
        this.games.forEach(game => game.update());
    }
}

module.exports = Lobby;