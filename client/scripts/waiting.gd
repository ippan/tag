extends GameBase

var back_to_title_countdown = 3.0

func _ready():
    set_process(false)
    Router.reset()
    Router.add_observer(self)
    ConnectionManager.start()

func get_supported_messages():
    return [ "connected", "packet_arrived", "connection_closed" ]

func on_connected(message):
    var have_map = 0
    
    if GlobalData.map != null:
        have_map = 1
    
    ConnectionManager.send("login " + str(have_map))

func on_connection_closed(message):
    $countdown.text = "Server closed"
    set_process(true)


func _process(delta):
    back_to_title_countdown -= delta
    if back_to_title_countdown < 0.0:
        get_tree().change_scene("res://scenes/title.tscn")

# packets

func process_map(map_data):
    GlobalData.map = Map.new(map_data)

func process_wcd(text_countdown, text_player_count):
    var countdown = float(text_countdown)
    
    $countdown.text = str(int(countdown))
    
    if text_player_count == "1":
        $join.text = "Waiting for other players..."
    else:
        $join.text = "Current player: %s" % [ text_player_count ]
    

func process_btt():
    $countdown.text = "Not enough players."
    set_process(true)
    
func process_stg(text_items):
    GlobalData.map.add_items(text_items)
    
    get_tree().change_scene("res://scenes/main.tscn")
