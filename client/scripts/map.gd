class_name Map

var rooms = []

class Room:
    var id = 0
    
    var width = 0
    var height = 0
    
    var data = []
    var path_indices = []
    
    var items = {}
    
    func _init(room_id, text):
        id = room_id
        var room_data = text.split(":")
        width = int(room_data[0])
        height = int(room_data[1])
        
        for i in room_data[2].length():
            var value = ("0x" + room_data[2].substr(i, 1)).hex_to_int()            
            data.append(value)
            if value == 0:
                path_indices.append(i)
    
    func position_to_index(x, y):
        return int(y + height * 0.5 + 0.75) * width + int(x + width * 0.5 + 0.75)
    
    func get_data(x, y):
        return data[get_index(x, y)]
    
    func get_item(x, y):
        var index = get_index(x, y)
        return get_item_by_index(index)
        
    func remove_item(index):
        if items.has(index):
            items.erase(index)
        
    func get_item_by_index(index):
        if items.has(index):
            return items[index]
            
        return -1
        
    func get_index(x, y):
        return y * width + x
    
    func get_random_path_index():
        return path_indices[randi() % path_indices.size()];

    func get_random_path_position():
        var index = get_random_path_index()

        return {
            x = (index % width) + width * -0.5 - 0.5,
            y = (index / width) + height * -0.5 - 0.5
        }
        
    func add_items(items_text):
        items = {}
        for item_text in items_text.split(","):
            var data = item_text.split(":")
            items[int(data[0])] = int(data[1])
        
func _init(text):
    var room_datas = text.split("|")
    var index = 0

    for room_data in room_datas:
        rooms.append(Room.new(index, room_data))
        index += 1

func get_room(index):
    return rooms[index % rooms.size()]

func add_items(items_text):
    var i = 0
    for item_text in items_text.split("|"):        
        rooms[i].add_items(item_text)
        i += 1
