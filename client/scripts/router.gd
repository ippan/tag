extends Node

var observers: Dictionary = {}

class MessageInvoker:
    var target
    
    func _init(message_target):
        target = message_target
        
    func on_message(message):
        var function_name = "on_" + message.name
    
        if target.has_method(function_name):
            target.call(function_name, message)
    
    func get_supported_messages() -> Array:
        return target.get_supported_messages()    
    
func reset():
    observers = {}

func add_observer(observer):
    if not observer.has_method("on_message"):
        observer = MessageInvoker.new(observer)
    
    for message in observer.get_supported_messages():
        if not observers.has(message):
            observers[message] = []
            
        observers[message].append(observer)

func route(message):
    if typeof(message) == TYPE_STRING:
        message = { name = message }    
    
    Logger.info("(message)" +  to_json(message))
    
    if observers.has(message.name):
        for observer in observers[message.name]:
            observer.on_message(message)
    
    if observers.has("all"):
        for observer in observers["all"]:
            observer.on_message(message)
