extends Node


func _ready():
	$Label.text = "i"
	$Label.modulate = Color.PURPLE

func _input(event):
	if event.is_action_pressed("my_action"):
		$Label.modulate = Color.GREEN
		
	if event.is_action_released("my_action"):
		$Label.modulate = Color.PURPLE
