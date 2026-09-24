extends CharacterBody2D

const SPEED       = 400.0
const SHADOW_SEGS = 12
const KILL_DIST   = 220.0
const FADE_DUR    = 1.5

var player    = null
var time      = 0.0
var dead      = false
var won       = false
var fade_time = 0.0
var win_fade  = 0.0

var black_rect = null
var dead_label = null


func _ready():
	player = get_node_or_null("../player")
	call_deferred("_build_ui")
	collision_layer = 2
	collision_mask  = 1


func _build_ui():
	var canvas           = CanvasLayer.new()
	canvas.layer         = 128
	canvas.process_mode  = Node.PROCESS_MODE_ALWAYS

	black_rect              = ColorRect.new()
	black_rect.color        = Color(0, 0, 0, 0)
	black_rect.position     = Vector2(-5000, -5000)
	black_rect.size         = Vector2(10000, 10000)
	black_rect.process_mode = Node.PROCESS_MODE_ALWAYS
	canvas.add_child(black_rect)

	dead_label              = Label.new()
	dead_label.text         = "YOU DIED"
	dead_label.modulate.a   = 0.0
	dead_label.position     = Vector2(350, 150)
	dead_label.process_mode = Node.PROCESS_MODE_ALWAYS
	dead_label.add_theme_font_size_override("font_size", 80)
	dead_label.add_theme_color_override("font_color", Color(0.8, 0.0, 0.0))
	canvas.add_child(dead_label)

	get_tree().root.call_deferred("add_child", canvas)


# Call this from the crown script when player wins
func on_crown_collected():
	won = true


func _process(delta):
	time += delta

	# Won — freeze then fade out
	if won:
		win_fade   += delta
		modulate.a  = clamp(1.0 - win_fade / 1.5, 0.0, 1.0)
		if win_fade >= 1.5:
			queue_free()
		queue_redraw()
		return

	# Dead — screen goes black
	if dead:
		fade_time += delta
		var t = fade_time / FADE_DUR
		if black_rect:
			black_rect.color.a = clamp(t, 0.0, 1.0)
		if dead_label and t > 0.5:
			dead_label.modulate.a = clamp((t - 0.5) / 0.5, 0.0, 1.0)
		if fade_time >= FADE_DUR:
			get_tree().paused = true
		queue_redraw()
		return

	if player:
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * SPEED * delta
		if $Sprite2D:
			$Sprite2D.flip_h = player.global_position.x < global_position.x
		if global_position.distance_to(player.global_position) < KILL_DIST:
			dead = true

	queue_redraw()


func _draw():
	if dead or won:
		return
	if not $Sprite2D or not $Sprite2D.texture:
		return

	var tex      = $Sprite2D.texture
	var tex_size = tex.get_size()

	for i in range(SHADOW_SEGS):
		var t        = float(i) / float(SHADOW_SEGS)
		var radius   = 4.0 + t * 28.0 + sin(time * 2.0 + t * TAU) * 3.0
		var darkness = Color(0.0, 0.0, 0.05, (1.0 - t) * 0.45)
		for j in range(8):
			var angle  = float(j) / 8.0 * TAU + time * 0.3
			var offset = Vector2(cos(angle), sin(angle)) * radius
			draw_texture(tex, offset - tex_size * 0.5, darkness)

	var pulse  = 0.5 + 0.5 * sin(time * 3.0)
	var halo_r = 26.0 + pulse * 10.0
	draw_arc(Vector2.ZERO, halo_r, 0, TAU, 48, Color(0.0, 0.0, 0.1, 0.5 * (1.0 - pulse * 0.3)), 4.0)
	draw_arc(Vector2.ZERO, halo_r * 0.75, 0, TAU, 48, Color(0.05, 0.0, 0.15, 0.3), 2.0)

	for i in range(6):
		var wt = float(i) / 6.0
		var wy = -10.0 - sin(time * 1.5 + wt * TAU) * 15.0
		var wx = cos(wt * TAU + time * 0.8) * 8.0
		draw_circle(Vector2(wx, wy), 6.0 + wt * 4.0, Color(0.0, 0.0, 0.05, 0.3 - wt * 0.25))
