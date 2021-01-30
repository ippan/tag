extends Spatial

var file: File = File.new()

func get_object(id):
    var path = "res://scenes/objects/%s.tscn" % [ id ]
    
    if file.file_exists(path):
        return load(path).instance()
    
    return load("res://scenes/objects/1.tscn").instance()

func set_data(room):
    var offset_x = room.width * -0.5 - 0.5
    var offset_z = room.height * -0.5 - 0.5
    
    $floor.scale = Vector3(room.width, 1.0, room.height)
    
    for y in room.height:
        for x in room.width:
            var block_id = room.get_data(x, y)
            
            if block_id == 0:
                continue
            
            var block = get_object(block_id)
            block.translation = Vector3(x + offset_x, 0.0, y + offset_z)
            add_child(block)
