extends Node

func play(audio_stream: AudioStream):
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sfx_player.stream = audio_stream
	add_child(sfx_player)
	
	sfx_player.play()
	sfx_player.finished.connect(func():
		sfx_player.queue_free()
	)
