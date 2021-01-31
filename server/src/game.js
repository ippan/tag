const { StateMachine, State } = require('./state_machine');
const Player = require('./player');
const Tool = require('./tool');

class GameState extends State {
    onConnect(id) {}
    onDisconnect(id) {}

    send(id, message) {
        if (this.parent.players[id]) {
            this.parent.players[id].send(message);
        }
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

class ClosedState extends GameState {
    getName() { return 'closed' }

    onEnter() {
        super.onEnter();
        this.parent.is_active = false;
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
                this.broadcast(`BTT`);
                this.changeState("closed");
            }
        }
    }

}

class InGameState extends  GameState {
    getName() { return 'in_game' }

    onEnter() {
        super.onEnter();

        this.players = [];

        this.player_id_to_index = {}

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

            this.player_id_to_index[i] = this.players.length;

            this.players.push(player);
        }

        this.log(`start with ${ this.players.length } players`);

        this.broadcast(`STG ${ this.parent.map_state.serialize_items() }`);
    }

    onDisconnect(id) {
        super.onDisconnect(id);

        this.broadcast(`CBG ${ id }`);
    }

    onUpdate() {
        super.onUpdate();

        if (this.parent.getPlayerCount() === 0) {
            this.changeState("closed");
            return;
        }



    }

    getPlayerById(id) {
        return this.players[this.player_id_to_index[id]];
    }

    get_players(id, parameters) {
        let players = this.players.map(player => player.serialize()).join('|');

        this.send(id, `PLS ${ id } ${ players }`)
    }

    sendToOthers(id, message) {
        for (let i = 0; i < this.players.length; ++i) {
            let player = this.players[i];

            if (player.id !== id) {
                this.send(i, message)
            }
        }
    }

    player_win(id, message) {
        this.broadcast('PYW');
        this.changeState('closed');
    }

    update_position(id, parameters) {
        let player = this.getPlayerById(id);
        player.x = parseFloat(parameters[0])
        player.y = parseFloat(parameters[1])
        this.sendToOthers(id, `UPP ${ id } ${ parameters[0] } ${ parameters[1] }`)
    }

    change_room(id, parameters) {
        let player = this.getPlayerById(id);
        player.room = parseInt(parameters[0])
        player.x = parseFloat(parameters[1])
        player.y = parseFloat(parameters[2])

        this.sendToOthers(id, `CHR ${ id } ${ parameters.join(' ') }`)
    }

    get_item(id, parameters) {
        this.broadcast(`ITM ${ id } ${ parameters.join(' ') }`)
    }

    catch_by_ghost(id, parameters) {
        this.broadcast(`CBG ${ id }`);
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
        this.map_state.putItems(setting.items);

        this.addState(new WaitingState());
        this.addState(new InGameState());
        this.addState(new ClosedState());

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
            this.players[index] = null;
            this.current_state.onDisconnect(index);
        });
    }
}

module.exports = Game;