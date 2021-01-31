extends Spatial

var data = null

var mesh_node = null

var last_direction = Vector3.ZERO

var last_x = "0"
var last_y = "0"

func update_player_data(player_data):
    data = player_data    
    translation = Vector3(data.room * 100.0 + data.x, 0.0, data.y)

func set_player_data(player_data):
    update_player_data(player_data)
    
    if player_data.is_ghost == 1:
        mesh_node = load("res://scenes/objects/ghost.tscn").instance()
    else:
        mesh_node = load("res://scenes/objects/human.tscn").instance()
        
    add_child(mesh_node)

func update_position(x, y):
    if x == last_x and y == last_y:
        last_direction = Vector3.ZERO
        return
        
    last_x = x
    last_y = y
    
    var new_position = Vector3(data.room * 100.0 + float(x), 0.0, float(y))
    
    last_direction = (new_position - translation).normalized()
    
    mesh_node.look_at(translation - last_direction, Vector3.UP)
    
    translation = new_position
    

func _process(delta):
    if data == null:
        return
    
    # translation += last_direction * data.speed * delta
