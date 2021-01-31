const Tool = require('./tool');

class Room {
    constructor(id, text) {

        let map_data = text.split("\n");

        this.id = id;

        this.width = map_data[0].split(',').length;
        this.height = map_data.length;

        this.offset_x = this.width * -0.5 - 0.5
        this.offset_y = this.height * -0.5 - 0.5

        let data = []
        let path_indices = [];
        let object_indices = [];

        map_data.forEach(row => {
            let values = row.split("\r")[0].split(',');
            values.forEach(value => {
                if (value === '') {
                    path_indices.push(data.length);
                    data.push(0);
                } else {
                    let object_value = parseInt(value, 16);

                    if (object_value > 1) {
                        object_indices.push(data.length);
                    }

                    data.push(object_value);
                }
            })
        });

        this.data = data;
        this.path_indices = path_indices;
        this.object_indices = object_indices;
    }

    serialize() {
        return `${ this.width }:${ this.height }:${ this.data.map(value => value.toString(16)).join('') }`;
    }

    getRandomPathIndex() {
        return this.path_indices[Tool.randomInt(this.path_indices.length)];
    }

    getRandomPathPosition() {
        let index = this.getRandomPathIndex();

        return {
            "x": (index % this.width) + this.offset_x,
            "y": Math.floor(index / this.width) + this.offset_y
        }
    }
}

class RoomState {

    constructor(room) {
        this.room = room;
        this.object_indices = Array.from(room.object_indices);
        this.items = {};
    }

    putItem(id) {
        if (this.object_indices.length === 0) {
            return false;
        }

        let index = Tool.randomInt(this.object_indices.length);


        this.items[this.object_indices[index]] = id;

        this.object_indices.splice(index, 1);

        return true;
    }

    serialize_items() {
        return Object.keys(this.items).map(index => `${ index }:${ this.items[index] }`).join(',')
    }
}

class MapState {
    constructor(map) {
        this.map = map;
        this.room_states = map.rooms.map(room => new RoomState(room));
    }

    putItems(items) {
        items.forEach(id => {
            while (!this.randomRoom().putItem(id)) {}
        });
    }

    getRoomCount() {
        return this.map.rooms.length;
    }

    randomRoom() {
        return this.room_states[Tool.randomInt(this.room_states.length)];
    }

    getRoom(id) {
        return this.map.rooms[id];
    }

    serialize_items() {
        return this.room_states.map(room_state => room_state.serialize_items()).join('|');
    }

    getItem(room, index) {
        return this.room_states[room].items[index];
    }

    removeItem(room, index) {
        delete this.room_states[room].items[index];
    }

}

class Map {
    constructor() {
        this.rooms = [];
    }

    addRoom(text) {
        this.rooms.push(new Room(this.rooms.length, text));
    }

    serialize() {
        return this.rooms.map(room => room.serialize()).join('|');
    }

    createMapState() {
        return new MapState(this);
    }
}

module.exports = Map;