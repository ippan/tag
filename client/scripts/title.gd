extends TextureRect

func _ready():
    Router.reset()

func _input(event):
    if event.is_action("ui_accept"):
        get_tree().change_scene("res://scenes/waiting.tscn")
