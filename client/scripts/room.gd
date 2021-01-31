extends Spatial

const ItemTip = preload("res://scenes/item_tips.tscn")
const Magic = preload("res://scenes/magic.tscn")

var file: File = File.new()

var items = {}

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
            
            var item_id = room.get_item(x, y)
            
            if item_id == -1:
                continue
                
            var item_tip = null
            if item_id == 1:
                item_tip = Magic.instance()
            else:
                item_tip = ItemTip.instance()
                
            item_tip.translation = Vector3(x + offset_x, 0.0, y + offset_z)
            add_child(item_tip)
            
            items[room.get_index(x, y)] = item_tip

func remove_item(index):
    if items.has(index):
        items[index].hide()

func hide_tips():
    for key in items:
        items[key].hide()
