const { StateMachine, State } = require('./state_machine');
const Player = require('./player');
const Tool = require('./tool');

class GameState extends State {
    onConnect(id) {}
    onDisconnect(id) {}

    send(id, message) {
        this.parent.players[id].send(message);
    }

    changeState(state_name) {
        this.parent.changeState(state_name)
    }

    broadcast(message) {
        this.parent.broadcast(message)
    }

    log(message) {
        this.parent.log(`[${ this.getName() }] ${ message }`)
    }
}

class WaitingState extends GameState {

    getName() { return "waiting"; }

    onEnter() {
        super.onEnter();
        this.start = this.parent.elapsed;

        this.count_down = this.parent.setting.game.waiting_count_down;
    }

    login(id, parameters) {
        if (parameters[0] === '0') {
            this.send(id, `MAP ${ this.parent.map_state.map.serialize() }`);
        }
    }

    onUpdate() {
        super.onUpdate();

        let count_down = this.count_down - this.parent.elapsed + this.start;

        this.broadcast(`WCD ${ count_down.toFixed(2) } ${ this.parent.getPlayerCount() }`)

        if (count_down <= 0) {
            if (this.parent.getPlayerCount() > 1) {
                this.changeState("in_game");
            } else {
                this.changeState("in_game");
            }
        }
    }

}

class InGameState extends  GameState {
    getName() { return 'in_game' }

    onEnter() {
        super.onEnter();

        this.players = [];

        this.ghost_id = Tool.randomInt(this.parent.getPlayerCount());

        let room_count = this.parent.map_state.getRoomCount();

        let room_offset = Tool.randomInt(room_count);

        for (let i = 0; i < this.parent.players.length; ++i) {
            let websocket = this.parent.players[i];

            if (websocket === null) {
                continue;
            }

            let is_ghost = 0;
            let player_setting = this.parent.setting.human;

            if (this.ghost_id === i) {
                is_ghost = 1
                player_setting = this.parent.setting.ghost;
            }

            let player = new Player(i, is_ghost, player_setting);
            player.room = (i + room_offset) % room_count;

            let start_position = this.parent.map_state.getRoom(player.room).getRandomPathPosition();

            player.x = start_position.x;
            player.y = start_position.y;

            this.players.push(player);
        }

        this.log(`start with ${ this.players.length } players`);

        this.broadcast('STG XXX');
    }

    get_players(id, parameters) {
        let players = this.players.map(player => player.serialize()).join('|');

        this.send(id, `PLS ${ id } ${ players }`)
    }

    update_position(id, parameters) {
        for (let i = 0; i < this.players.length; ++i) {
            let player = this.players[i];

            if (player.id === id) {
                player.x = parseFloat(parameters[0])
                player.y = parseFloat(parameters[1])
                continue;
            }

            this.send(i, `UPP ${ id } ${ parameters[0] } ${ parameters[1] }`)
        }
    }

}

class Game extends StateMachine {
    constructor(id, map, setting) {
        super();

        this.id = id;

        this.setting = setting;

        this.elapsed = 0.0;

        this.is_active = true;

        this.tick = setting.tick;

        this.map_state = map.createMapState();

        this.addState(new WaitingState());
        this.addState(new InGameState());

        this.players = [ null, null, null, null ]

        this.changeState("waiting");

        this.log('created');
    }

    log(message) {
        console.log(`game [${ this.id }] ${ message }`);
    }

    changeState(state_name) {
        this.log(`change state to ${ state_name }`)
        super.changeState(state_name);
    }

    getFreePlayerIndex() {
        for (let i = 0; i < this.players.length; ++i) {
            if (this.players[i] === null) {
                return i;
            }
        }

        return -1;
    }

    getPlayerCount() {
        let count = 0;
        for (let i = 0; i < this.players.length; ++i) {
            if (this.players[i] !== null) {
                count++;
            }
        }
        return count;
    }

    isStarted() {
        return this.current_state.getName() !== "waiting";
    }

    update() {
        this.elapsed += this.tick;

        super.update();
    }

    broadcast(message) {
        this.players.forEach(player => {
            if (player) {
                player.send(message);
            }
        })
    }

    onConnect(websocket) {
        let index = this.getFreePlayerIndex();
        this.players[index] = websocket;

        this.current_state.onConnect(index);

        websocket.on('message', (message) => {

            let parameters = message.toString().split(' ')

            let command = parameters.shift()

            let method = this.current_state[command];

            if (!method) {
                console.log("unknown command: " + command)
                return;
            }

            method.bind(this.current_state)(index, parameters)
        });

        websocket.on('close', () => {
            console.log('disconnected');
        });
    }
}

module.exports = Game;