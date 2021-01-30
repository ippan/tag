extends GameBase

func _ready():
    Router.reset()
    Router.add_observer(self)
    ConnectionManager.start()


func get_supported_messages():
    return [ "connected", "packet_arrived" ]

func on_connected(message):
    var have_map = 0
    
    if GlobalData.map != null:
        have_map = 1
    
    ConnectionManager.send("login " + str(have_map))

# packets

func process_map(map_data):
    GlobalData.map = Map.new(map_data)

func process_wcd(text_countdown, text_player_count):
    var countdown = float(text_countdown)
    
    $countdown.text = str(int(countdown))
    
    $join.text = "%s player(s) joined." % [ text_player_count ]
    

func process_btt():
    get_tree().change_scene("res://scenes/title.tscn")

func process_stg(text_items):
    get_tree().change_scene("res://scenes/main.tscn")
