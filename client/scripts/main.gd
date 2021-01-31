extends GameBase

const Room = preload("res://scenes/room.tscn")
const Player = preload("res://scenes/player.tscn")
const PlayerShadow = preload("res://scenes/player_shadow.tscn")
const Item = preload("res://scenes/item.tscn")

class PlayerData:
    var id = -1
    var room = 0
    var x = 0.0
    var y = 0.0
    var is_ghost = 0
    var speed = 1.0
    var sight = 3.0
    
    var items = []
    
    func has_item(item_id):
        for item in items:
            if item == item_id:
                return true
                
        return false
                
    func add_item(item_id):
        items.append(item_id)

var inited_map = false

var id = -1
var ghost_id = -1

var player_datas = {}

var players = {}

var rooms = []

var show_message_count_down = -1.0

func _ready():
    Router.reset()
    Router.add_observer(self)
    ConnectionManager.send("get_players")

# messages

func get_supported_messages():
    return [ "packet_arrived", "show_message", "remove_item" ]

func show_message(message):
    $message.text = message
    show_message_count_down = 5.0

func _process(delta):
    
    if show_message_count_down > 0.0:
        show_message_count_down -= delta
        
        if show_message_count_down < 0.0:
            $message.text = ""
    
    if not inited_map and GlobalData.map != null:
        inited_map = true
        for i in GlobalData.map.rooms.size():
            var room_data = GlobalData.map.rooms[i]
            
            var room = Room.instance()
            
            room.set_data(room_data)
            
            room.translation.x = 100 * i
            
            $rooms.add_child(room)
            
            rooms.append(room)
            
        if id == ghost_id and id != -1:
            for room in rooms:
                room.hide_tips()            
            
    if ghost_id == id:
        return
        
    if (players[ghost_id].translation - players[id].translation).length() < 0.5:
        ConnectionManager.send("catch_by_ghost")
        Router.reset()
        get_tree().change_scene("res://scenes/ghost_win.tscn")
        
func on_show_message(message):
    show_message(message.text)

func on_remove_item(message):
    GlobalData.map.rooms[message.room].remove_item(message.index)
    rooms[message.room].remove_item(message.index)
        
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
        
        var player = null
        
        if id == player_data.id:
            player = Player.instance()
        else:
            player = PlayerShadow.instance()
            
        add_child(player)
        player.set_player_data(player_data)
    
        players[player_data.id] = player

    players[id].ghost_data = player_datas[ghost_id]
    
    if id == ghost_id:
        for room in rooms:
            room.hide_tips()

func process_upp(text_id, text_x, text_y):
    var player_id = int(text_id)
    
    players[player_id].update_position(text_x, text_y)
    
func process_chr(text_id, text_room, text_x, text_y):
    var player_id = int(text_id)
    player_datas[player_id].room = int(text_room)
    process_upp(text_id, text_x, text_y)

func process_cbg(text_id):
    var player_id = int(text_id)
    
    players[player_id].hide()
    
    if player_id == ghost_id:
        Router.reset()
        get_tree().change_scene("res://scenes/human_win.tscn")
        return
    
    if ghost_id != id:
        return
        
    for alive_player_id in players:
        var player = players[alive_player_id]
        
        if player.data.is_ghost == 0 and player.visible:
            return
        
        Router.reset()
        get_tree().change_scene("res://scenes/ghost_win.tscn")
    
func process_itm(text_id, text_room, text_index):
    var player_id = int(text_id)
    var room = int(text_room)
    var index = int(text_index)
    
    if player_id == id:
        var item_id = GlobalData.map.rooms[room].get_item_by_index(index)
        
        if item_id == -1:
            return
        
        player_datas[id].add_item(item_id)
        var item = Item.instance()
        item.texture = load("res://data/images/item_%s.png" % [ item_id ])
        $items.add_child(item)
        
        if item_id == 5:
            player_datas[id].speed += 0.5
        elif item_id == 6:
            player_datas[id].sight += 0.5
            
        print(item_id)
            
        players[id].update_player_data(player_datas[id])
        
        
    on_remove_item({
        name = "remove_item",
        room = room,
        index = index
    })

func process_pyw():
    Router.reset()
    get_tree().change_scene("res://scenes/player_win.tscn")
    
