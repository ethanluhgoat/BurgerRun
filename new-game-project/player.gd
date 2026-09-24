extends CharacterBody2D

const SPEED       = 1000.0
const JUMP_FORCE  = -650.0
const ACCEL       = 3500.0
const FRICTION    = 3000.0
const SPIN_SPEED  = 5.0
const SWING_ACCEL = 2000.0
const PULL_SPEED  = 1000.0

const HOOK_SPEED  = 1400.0
const HOOK_GRAV   = 400.0

const ROPE_SEGS   = 16
const SEG_DAMPING = 0.97

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum State { IDLE, FLYING, ATTACHED }
var state    = State.IDLE
var anchor   = Vector2.ZERO
var rope_len = 0.0

var hook_tip = Vector2.ZERO
var hook_vel = Vector2.ZERO
var prev_tip = Vector2.ZERO

var seg_pos = []
var seg_old = []

@onready var rope = $"../Rope"


func _ready():
	rope.visible       = false
	rope.default_color = Color.BLACK
	rope.width         = 3.0
	for i in range(ROPE_SEGS + 1):
		seg_pos.append(Vector2.ZERO)
		seg_old.append(Vector2.ZERO)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_shoot(get_global_mouse_position())
	if event is InputEventKey:
		if event.keycode == KEY_E and event.pressed:
			_release()


func _shoot(target: Vector2):
	var dir  = (target - global_position).normalized()
	state    = State.FLYING
	hook_tip = global_position
	prev_tip = global_position
	hook_vel = dir * HOOK_SPEED
	rope.visible = true
	for i in range(ROPE_SEGS + 1):
		seg_pos[i] = global_position
		seg_old[i] = global_position


func _release():
	state        = State.IDLE
	rope.visible = false


func _physics_process(delta):
	match state:
		State.FLYING:
			_fly_hook(delta)
		State.ATTACHED:
			_swing(delta)

	if not is_on_floor():
		velocity.y += gravity * delta

	if state != State.ATTACHED:
		var dir = Input.get_axis("left", "right")
		if dir != 0:
			velocity.x = move_toward(velocity.x, dir * SPEED, ACCEL * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_FORCE

	move_and_slide()

	if state == State.ATTACHED:
		var to_anchor = anchor - global_position
		var dist      = to_anchor.length()
		if dist > rope_len and dist > 0.001:
			var n            = to_anchor / dist
			global_position += n * (dist - rope_len)
			var dot = velocity.dot(n)
			if dot < 0.0:
				velocity -= n * dot * 0.85

	_update_rope(delta)
	rotation += velocity.x * delta * SPIN_SPEED * 0.01


func _fly_hook(delta):
	prev_tip   = hook_tip
	hook_vel.y += HOOK_GRAV * delta
	hook_tip   += hook_vel * delta

	var space  = get_world_2d().direct_space_state
	var params = PhysicsRayQueryParameters2D.create(prev_tip, hook_tip)
	params.exclude       = [get_rid()]
	params.collision_mask = 1
	var hit = space.intersect_ray(params)

	if hit:
		anchor   = hit.position
		hook_tip = anchor
		rope_len = global_position.distance_to(anchor)
		state    = State.ATTACHED
		for i in range(ROPE_SEGS + 1):
			var t      = float(i) / float(ROPE_SEGS)
			seg_pos[i] = global_position.lerp(anchor, t)
			seg_old[i] = seg_pos[i]
		return

	if global_position.distance_to(hook_tip) > 2000.0:
		_release()


func _swing(delta):
	if Input.is_action_pressed("up"):
		var pull_dir = (anchor - global_position).normalized()
		velocity    += pull_dir * PULL_SPEED * delta
		rope_len     = max(40.0, rope_len - PULL_SPEED * 0.5 * delta)

	var dir = Input.get_axis("left", "right")
	velocity.x += dir * SWING_ACCEL * delta
	velocity.x *= 0.985


func _update_rope(delta):
	if state == State.IDLE:
		rope.visible = false
		return

	rope.visible = true

	var player_end = global_position
	var tip_end    = hook_tip if state == State.FLYING else anchor
	var seg_len    = player_end.distance_to(tip_end) / float(ROPE_SEGS)

	if state == State.FLYING:
		rope.clear_points()
		rope.add_point(player_end)
		rope.add_point(tip_end)
		return

	seg_pos[0]         = anchor
	seg_pos[ROPE_SEGS] = player_end

	for i in range(1, ROPE_SEGS):
		var p      = seg_pos[i]
		var o      = seg_old[i]
		var new_p  = p + (p - o) * SEG_DAMPING + Vector2(0, gravity * delta * delta * 0.5)
		seg_old[i] = p
		seg_pos[i] = new_p

	for _pass in range(6):
		seg_pos[0]         = anchor
		seg_pos[ROPE_SEGS] = player_end
		for i in range(ROPE_SEGS):
			var a    = seg_pos[i]
			var b    = seg_pos[i + 1]
			var diff = b - a
			var d    = diff.length()
			if d < 0.001:
				continue
			var corr = diff * ((d - seg_len) / d) * 0.5
			if i == 0:
				seg_pos[i + 1] -= corr * 2.0
			elif i == ROPE_SEGS - 1:
				seg_pos[i]     += corr * 2.0
			else:
				seg_pos[i]     += corr
				seg_pos[i + 1] -= corr
		seg_pos[0]         = anchor
		seg_pos[ROPE_SEGS] = player_end

	rope.clear_points()
	for i in range(ROPE_SEGS + 1):
		rope.add_point(seg_pos[i])
