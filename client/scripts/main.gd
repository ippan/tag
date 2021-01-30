extends GameBase

const Room = preload("res://scenes/room.tscn")
const Player = preload("res://scenes/player.tscn")

class PlayerData:
    var id = -1
    var room = 0
    var x = 0.0
    var y = 0.0
    var is_ghost = 0
    var speed = 1.0
    var sight = 3.0
    

var inited_map = false

var id = -1
var ghost_id = -1

var player_datas = {}

var players = {}

func _ready():
    Router.reset()
    Router.add_observer(self)
    ConnectionManager.send("get_players")

# messages

func get_supported_messages():
    return [ "packet_arrived" ]


func _process(delta):
    
    if not inited_map and GlobalData.map != null:
        inited_map = true
        for i in GlobalData.map.rooms.size():
            var room_data = GlobalData.map.rooms[i]
            
            var room = Room.instance()
            
            room.set_data(room_data)
            
            room.translation.x = 100 * i
            
            $rooms.add_child(room)

        
# packets

func process_pls(text_id, text_players):
    id = int(text_id)
    
    for text_player in text_players.split("|"):
        var data = text_player.split(":")
        var player_data = PlayerData.new()
        
        player_data.id = int(data[0])
        player_data.is_ghost = int(data[1])
        player_data.room = int(data[2])
        player_data.x = float(data[3])
        player_data.y = float(data[4])
        player_data.speed = float(data[5])
        player_data.sight = float(data[6])

        player_datas[player_data.id] = player_data
        
        if player_data.is_ghost == 1:
            ghost_id = player_data.id
        
    
    var player = Player.instance()
    add_child(player)
    player.set_player_data(player_datas[id])

    players[id] = player
