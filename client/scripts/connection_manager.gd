extends Node


var client = null

func _ready():
    set_process(false)

func start():
    
    client = WebSocketClient.new()
    
    client.connect("connection_closed", self, "on_closed")
    client.connect("connection_error", self, "on_closed")
    client.connect("connection_established", self, "on_connected")
    client.connect("data_received", self, "on_data")
    
    client.connect_to_url("ws://localhost:3000")
    
    set_process(true)

func stop():
    client.disconnect_from_host()
    client = null
    set_process(false)
    

func _process(delta):
    if client == null:
        return
    
    client.poll()

func on_closed(was_clean = false):
    Router.route("connection_closed")
    set_process(false)

func on_connected(proto = ""):
    Router.route("connected")

func on_data():
    var packet = client.get_peer(1).get_packet().get_string_from_utf8()
    Router.route({
        name = "packet_arrived",
        packet = packet
    }, false)

func send(packet: String):
    client.get_peer(1).put_packet(packet.to_utf8())
