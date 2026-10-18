extends Node

func play(audio_stream: AudioStream, volume_db: float = 0, pitch_range: float = 0):
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sfx_player.stream = audio_stream
	sfx_player.volume_db = volume_db
	sfx_player.pitch_scale = randf_range(1.0 - pitch_range, 1.0 + pitch_range)
	add_child(sfx_player)
	
	sfx_player.play()
	sfx_player.finished.connect(func():
		sfx_player.queue_free()
	)
