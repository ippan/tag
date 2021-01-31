extends Node

var cache = {}

func play(sfx_name: String, bus = "Master"):
    
    if not cache.has(sfx_name):
        cache[sfx_name] = load("res://data/audios/%s.wav" % [ sfx_name ])

    var audio_player = $audio
    audio_player.bus = bus
    audio_player.set_stream(cache[sfx_name])
    audio_player.play()
