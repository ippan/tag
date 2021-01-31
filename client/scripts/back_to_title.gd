extends Control


var countdown = 5.0

func _process(delta):
    countdown -= delta
    
    if countdown < 0.0:
        get_tree().change_scene("res://scenes/title.tscn")
