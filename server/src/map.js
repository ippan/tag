class Room {
    constructor(text) {

        let map_data = text.split("\n");

        this.width = map_data[0].split(',').length;
        this.height = map_data.length;

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
}

class MapState {
    constructor(map) {
        this.map = map;
    }
}

class Map {
    constructor() {
        this.rooms = [];
    }

    addRoom(text) {
        this.rooms.push(new Room(text));
    }

    serialize() {
        return this.rooms.map(room => room.serialize()).join('|');
    }
}

module.exports = Map;