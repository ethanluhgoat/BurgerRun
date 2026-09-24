extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.name == "player":
		# Reset player position to spawn
		body.global_position = Vector2(4, -53)  # change this to your spawn point
		body.velocity = Vector2.ZERO
