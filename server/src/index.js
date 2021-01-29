const fs = require('fs');
const Lobby = require('./lobby');
const WebSocket = require('ws');

let setting = JSON.parse(fs.readFileSync('data/setting.json', 'utf8'));

let lobby = new Lobby(setting);

const websocket_server = new WebSocket.Server({ port: setting.port });

websocket_server.on('connection', websocket => {
    lobby.onConnect(websocket);
});

setInterval(() => lobby.update(), setting.tick * 1000.0);