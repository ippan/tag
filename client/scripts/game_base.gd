extends Node
class_name GameBase


func on_packet_arrived(message):
    var data = message.packet.split(" ")
    
    var packet_name = data[0].to_lower()
    data.remove(0)
    
    var method_name = "process_" + packet_name
    
    if not self.has_method(method_name):
        Logger.warn("unknown packet: " + message.packet)
        return
        
    self.callv(method_name, data)
