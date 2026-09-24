extends Control

var time          = 0.0
var particles     = []
var sprite_start  = Vector2.ZERO
var title_start   = Vector2.ZERO

@onready var title  = $Label1
@onready var play   = $Label2
@onready var bg     = $ColorRect
@onready var sprite = $Sprite2D


func _ready():
	get_tree().paused = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	play.mouse_filter   = Control.MOUSE_FILTER_STOP
	title.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	title.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	sprite_start = sprite.position
	title_start  = title.position
	for i in range(30):
		_add_title_particle(true)


func _rand_color() -> Color:
	var cols = [
		Color(1,0.2,0.2), Color(1,0.6,0), Color(1,1,0),
		Color(0.2,1,0.2), Color(0,0.8,1), Color(0.6,0,1),
		Color(1,0,0.8),   Color(1,1,1),   Color(0,1,1)
	]
	return cols[randi() % cols.size()]


func _add_title_particle(random_pos: bool):
	var types = ["circle", "triangle", "square", "star", "diamond"]
	var title_rect = title.get_global_rect()
	var origin = Vector2(
		randf_range(title_rect.position.x, title_rect.position.x + title_rect.size.x),
		randf_range(title_rect.position.y, title_rect.position.y + title_rect.size.y)
	) if random_pos else Vector2(
		randf_range(title_rect.position.x - 20, title_rect.position.x + title_rect.size.x + 20),
		title_rect.position.y + title_rect.size.y * 0.5
	)
	var angle = randf_range(-PI, PI)
	var spd   = randf_range(5.0, 30.0)
	particles.append({
		"pos":     origin,
		"vel":     Vector2(cos(angle), sin(angle)) * spd,
		"rot":     randf() * TAU,
		"rot_spd": randf_range(-2.0, 2.0),
		"size":    randf_range(3.0, 10.0),
		"color":   _rand_color(),
		"type":    types[randi() % types.size()],
		"life":    randf_range(1.5, 4.0),
		"max":     4.0
	})


func _is_mouse_over(label: Label) -> bool:
	return label.get_global_rect().has_point(get_global_mouse_position())


func _process(delta):
	time += delta

	# ── Sprite subtle shake ───────────────────────────────────
	var shake_x = sin(time * 1.3) * 3.0 + sin(time * 2.7) * 1.5
	var shake_y = sin(time * 1.1) * 2.0 + sin(time * 3.1) * 1.0
	sprite.position = sprite_start + Vector2(shake_x, shake_y)
	# Tiny rotation wobble
	sprite.rotation = sin(time * 0.9) * 0.03

	# ── Title subtle float ────────────────────────────────────
	title.position.y = title_start.y + sin(time * 1.1) * 4.0
	title.position.x = title_start.x + sin(time * 0.6) * 2.0

	# ── Play button hover ─────────────────────────────────────
	if _is_mouse_over(play):
		var r = abs(sin(time * 5.0))
		var g = abs(sin(time * 5.0 + 2.1))
		var b = abs(sin(time * 5.0 + 4.2))
		play.add_theme_color_override("font_color", Color(r, g, b, 1.0))
		play.scale = Vector2(1.08, 1.08)
	else:
		play.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		play.scale = Vector2(1.0, 1.0)

	# ── Spawn title particles ─────────────────────────────────
	if randi() % 6 == 0:
		_add_title_particle(false)

	# ── Tick particles ────────────────────────────────────────
	var dead = []
	for p in particles:
		p["life"] -= delta
		p["pos"]  += p["vel"] * delta
		p["rot"]  += p["rot_spd"] * delta
		p["vel"]  *= 0.98
		if p["life"] <= 0:
			dead.append(p)
	for d in dead: particles.erase(d)

	queue_redraw()


func _draw():
	for p in particles:
		var t   = p["life"] / p["max"]
		var col = p["color"]
		col.a   = clamp(t * 1.5, 0.0, 0.6)
		var sz  = p["size"] * clamp(t * 2.0, 0.0, 1.0)
		var pos = p["pos"]
		var r   = p["rot"]

		match p["type"]:
			"circle":
				draw_circle(pos, sz, col)

			"square":
				var c = [
					pos + Vector2(cos(r), sin(r)) * sz + Vector2(-sin(r), cos(r)) * sz,
					pos + Vector2(cos(r), sin(r)) * sz - Vector2(-sin(r), cos(r)) * sz,
					pos - Vector2(cos(r), sin(r)) * sz - Vector2(-sin(r), cos(r)) * sz,
					pos - Vector2(cos(r), sin(r)) * sz + Vector2(-sin(r), cos(r)) * sz,
				]
				draw_colored_polygon(PackedVector2Array(c), col)

			"triangle":
				var p1 = pos + Vector2(cos(r),           sin(r))           * sz
				var p2 = pos + Vector2(cos(r + TAU/3.0), sin(r + TAU/3.0)) * sz
				var p3 = pos + Vector2(cos(r + 2*TAU/3), sin(r + 2*TAU/3)) * sz
				draw_colored_polygon(PackedVector2Array([p1, p2, p3]), col)

			"diamond":
				var p1 = pos + Vector2(0, -sz)
				var p2 = pos + Vector2(sz * 0.6, 0)
				var p3 = pos + Vector2(0, sz)
				var p4 = pos + Vector2(-sz * 0.6, 0)
				draw_colored_polygon(PackedVector2Array([p1, p2, p3, p4]), col)

			"star":
				for i in range(5):
					var a1    = r + float(i) / 5.0 * TAU
					var a2    = r + (float(i) + 0.5) / 5.0 * TAU
					var outer = pos + Vector2(cos(a1), sin(a1)) * sz
					var inner = pos + Vector2(cos(a2), sin(a2)) * sz * 0.4
					var nxt   = pos + Vector2(cos(r + float(i+1)/5.0*TAU), sin(r + float(i+1)/5.0*TAU)) * sz
					draw_colored_polygon(PackedVector2Array([pos, outer, inner]), col)
					draw_colored_polygon(PackedVector2Array([pos, inner, nxt]), col)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _is_mouse_over(play):
				get_tree().change_scene_to_file("res://game.tscn")
