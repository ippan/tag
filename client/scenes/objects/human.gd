extends Spatial

var elapsed = 0.0

onready var left_hand = $L_hand
onready var right_hand = $R_hand
onready var left_foot = $L_foot
onready var right_foot = $R_foot

onready var body = $Player1

func _process(delta):
    elapsed += delta
    
    var scaled_elapsed = elapsed * 3.0
    
    body.translation.y = (sin(scaled_elapsed) + 1.0) * 0.02
    
    left_hand.translation.z = sin(scaled_elapsed) * 0.05
    right_hand.translation.z = cos(scaled_elapsed) * 0.05
    left_foot.translation.z = cos(scaled_elapsed) * 0.1
    right_foot.translation.z = sin(scaled_elapsed) * 0.1
