extends Node

var current_time: float = 0
var interaction_count: int = 0

func reset():
	current_time = 0
	interaction_count = 0

const seconds_in_minute: int = 60
const minutes_in_hour: int = 60

func get_time_as_str() -> String:
	var seconds_in_hour: int = seconds_in_minute * minutes_in_hour
	var hours_count: int = floori(current_time / seconds_in_hour)
	var hour_remainder_sec: int = int(current_time) % seconds_in_hour
	var minutes_count: int = floori(hour_remainder_sec / minutes_in_hour)
	var seconds_count: int = hour_remainder_sec % seconds_in_minute
	
	var time_as_str: String = ""
	if hours_count > 0: time_as_str += str(hours_count) + ':'
	var minute_as_str: String = str(minutes_count)
	if hours_count > 0 and minutes_count < 10: minute_as_str = "0" + minute_as_str
	time_as_str += minute_as_str + ':'
	
	var second_as_str: String = str(seconds_count)
	if minutes_count > 0 and seconds_count < 10: second_as_str = "0" + second_as_str
	time_as_str += second_as_str
	
	return time_as_str

func _process(delta: float):
	current_time += delta
