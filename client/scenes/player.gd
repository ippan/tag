extends KinematicBody

var last_direction = Vector3(0.0, 0.0, -1.0)

var data = null

var ghost_data = null

var move_cd = 0.0

var sync_countdown = 0.2

var mesh_node = null

var ghost_move_countdown = 30.0

func update_player_data(player_data):
    data = player_data
    
    $light.translation.y = data.sight
    
    translation = Vector3(data.room * 100.0 + data.x, 0.0, data.y)

func set_player_data(player_data):
    update_player_data(player_data)
    
    if player_data.is_ghost == 1:
        mesh_node = load("res://scenes/objects/ghost.tscn").instance()
    else:
        mesh_node = load("res://scenes/objects/human.tscn").instance()
        
    add_child(mesh_node)

func _physics_process(delta):
    
    if data == null:
        return
    
    var have_move = false
    
    var move_vector = Vector3(0.0, 0.0, 0.0)
    
    if Input.is_action_pressed("ui_up"):
        move_vector.z = -1.0
        have_move = true

    if Input.is_action_pressed("ui_down"):
        move_vector.z = 1.0
        have_move = true
        
    if Input.is_action_pressed("ui_left"):
        move_vector.x = -1.0
        have_move = true
        
    if Input.is_action_pressed("ui_right"):
        move_vector.x = 1.0
        have_move = true
        
    if not have_move:
        return
        
    move_vector = move_vector.normalized()
    
    last_direction = move_vector
    
    move_and_slide(move_vector * data.speed)
    
    data.x = translation.x - data.room * 100.0
    data.y = translation.z
    
    mesh_node.look_at(translation - last_direction, Vector3.UP)
    
    

func fade():
    $animation.play("fade")

func _process(delta):
    sync_countdown -= delta
    
    if sync_countdown < 0.0:
        sync_countdown = 0.1
        ConnectionManager.send("update_position %s %s" % [ data.x, data.y ])
    
    if move_cd > 0.0:
        move_cd -= delta
        
    if data.is_ghost == 1:
        ghost_move_countdown -= delta
        
        if ghost_move_countdown < 0.0:
            move_room(data.room + 1)
            
            Router.route({ 
                name = "show_message",
                text = "Auto teleport"
            })
        
        
func move_room(new_room):
    fade()
    var next_room = GlobalData.map.get_room(new_room)
    var position = next_room.get_random_path_position()
    data.room = next_room.id
    data.x = position.x
    data.y = position.y
        
    ConnectionManager.send("change_room %s %s %s" % [ data.room, data.x, data.y ])
        
    update_player_data(data)
    Sfx.play("teleport_success")
    
    ghost_move_countdown = 30.0
    move_cd = 10.0
    
    if data.is_ghost == 1:
        move_cd += 5.0

func _input(event):    
    
    if event.is_action_pressed("next_room") or event.is_action_pressed("previous_room"):
        if move_cd > 0.0:
            return
        
        
        var room_delta = 1
        
        if event.is_action_pressed("previous_room"):
            room_delta = -1 + GlobalData.map.rooms.size()
        
            if data.is_ghost == 0:
                return
        
        if data.is_ghost == 0 and data.room == ghost_data.room:
            Sfx.play("teleport_fail")
            return
            
        move_room(data.room + room_delta)   
    
    if data.is_ghost == 1:
        return
    
    if event.is_action_pressed("ui_accept"):
        var front = translation + mesh_node.transform.basis.z
        var index = GlobalData.map.rooms[data.room].position_to_index(front.x - data.room * 100.0, front.z)
        
        var item_id = GlobalData.map.rooms[data.room].get_item_by_index(index)
        
        if item_id == 1:
            if data.has_item(2):
                ConnectionManager.send("player_win")
        elif item_id == 0:
            Router.route({ 
                name = "show_message",
                text = "There is nothing..."
            })
            
            Router.route({
                name = "remove_item",
                room = data.room,
                index = index   
            })
        else:
            ConnectionManager.send("get_item %s %s" % [ data.room, index ])
        
func update_position(x, y):
    pass
