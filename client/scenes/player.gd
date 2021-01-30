extends KinematicBody

var last_direction = Vector3(0.0, 0.0, -1.0)

var data = null

var move_cd = 0.0

var sync_countdown = 0.1

func set_player_data(player_data):
    data = player_data
    
    $light.translation.y = data.sight
    
    translation = Vector3(data.room * 100.0 + data.x, 0.0, data.y)

func _physics_process(delta):
    
    if data == null:
        return
    
    var move_vector = Vector3(0.0, 0.0, 0.0)
    
    if Input.is_action_pressed("ui_up"):
        move_vector.z = -1.0

    if Input.is_action_pressed("ui_down"):
        move_vector.z = 1.0
        
    if Input.is_action_pressed("ui_left"):
        move_vector.x = -1.0
        
    if Input.is_action_pressed("ui_right"):
        move_vector.x = 1.0
        
    move_vector = move_vector.normalized()
    
    last_direction = move_vector
    
    move_and_slide(move_vector * data.speed)
    
    data.x = translation.x
    data.y = translation.z

func fade():
    $animation.play("fade")

func _process(delta):
    sync_countdown -= delta
    
    if sync_countdown < 0.0:
        sync_countdown = 0.1
        ConnectionManager.send("update_position %s %s" % [ data.x, data.y ])
    
    
    if move_cd > 0.0:
        move_cd -= delta

func _input(event):
    if move_cd > 0.0:
        return
    
    if event.is_action("next_room"):
        fade()
        move_cd += 10.0
            
        var next_room = GlobalData.map.get_room(data.room + 1)
        var position = next_room.get_random_path_position()
        data.room = next_room.id
        data.x = position.x
        data.y = position.y
        set_player_data(data)
