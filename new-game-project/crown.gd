extends Area2D

# ── Constants ────────────────────────────────────────────────
const BOB_HEIGHT   = 8.0
const BOB_SPEED    = 2.0
const SPIN_SPEED   = 0.4
const PICKUP_DIST  = 60.0
const COLLECT_DUR  = 12.0

# ── State ────────────────────────────────────────────────────
var start_y       = 0.0
var time          = 0.0
var won           = false
var collecting    = false
var collect_time  = 0.0
var collect_pos   = Vector2.ZERO
var shake_amount  = 0.0
var vp_size       = Vector2.ZERO
var bg_hue        = 0.0

# ── Node refs ────────────────────────────────────────────────
var win_label     = null
var black_rect    = null
var flash_rect    = null
var color_rect    = null
var player        = null

# ── Particle pools ───────────────────────────────────────────
var sparks        = []
var rings         = []
var bolts         = []
var shockwaves    = []
var beams         = []
var triangles     = []
var spirals       = []
var debris        = []
var orbs          = []
var screen_sparks = []
var stars         = []
var columns       = []
var ribbons       = []
var glyphs        = []
var meteors       = []
var vortex_parts  = []
var hexagons      = []
var pulses        = []
var comets        = []
var tendrils      = []
var portals       = []
var fractals      = []
var snowflakes    = []
var laserbeams    = []
var eyeballs      = []
var tornadoes     = []
var novas         = []
var sigils        = []
var crowns_fx     = []
var bubble_rings  = []
var doom_circles  = []
var aurora_bands  = []


func _ready():
	start_y = position.y
	vp_size = get_viewport().get_visible_rect().size
	win_label            = get_node_or_null("../WinLabel")
	win_label.modulate.a = 0.0
	var canvas   = CanvasLayer.new()
	black_rect   = ColorRect.new()
	flash_rect   = ColorRect.new()
	color_rect   = ColorRect.new()
	black_rect.color = Color(0, 0, 0, 0)
	flash_rect.color = Color(1, 1, 1, 0)
	color_rect.color = Color(0, 0, 0, 0)
	for rect in [black_rect, flash_rect, color_rect]:
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		rect.size = vp_size
		canvas.add_child(rect)
	get_tree().root.call_deferred("add_child", canvas)
	player = get_node_or_null("../player")
	_spawn_ambient()


# ════════════════════════════════════════════════════════════
#  PALETTE
# ════════════════════════════════════════════════════════════
func _rand_color() -> Color:
	var palette = [
		Color(1.0,0.1,0.0), Color(1.0,0.4,0.0), Color(1.0,0.8,0.0),
		Color(1.0,1.0,0.0), Color(0.5,1.0,0.0), Color(0.0,1.0,0.2),
		Color(0.0,1.0,0.8), Color(0.0,0.7,1.0), Color(0.2,0.2,1.0),
		Color(0.6,0.0,1.0), Color(0.9,0.0,1.0), Color(1.0,0.0,0.7),
		Color(1.0,0.0,0.3), Color(1.0,1.0,1.0), Color(0.0,1.0,1.0),
		Color(1.0,0.5,0.5), Color(0.5,1.0,1.0), Color(1.0,0.8,0.5),
		Color(0.8,1.0,0.0), Color(0.0,0.5,1.0), Color(1.0,0.3,0.8),
		Color(0.3,1.0,0.5), Color(1.0,0.6,0.0), Color(0.7,0.0,0.5),
	]
	return palette[randi() % palette.size()]

func _hot_color() -> Color:
	var hot = [Color(1,0.1,0),Color(1,0.4,0),Color(1,0.8,0),Color(1,1,0),Color(1,1,1),Color(1,0.3,0.1)]
	return hot[randi() % hot.size()]

func _cool_color() -> Color:
	var cool = [Color(0,0.7,1),Color(0.2,0.2,1),Color(0.6,0,1),Color(0,1,1),Color(0.5,0.5,1),Color(0.3,0,1)]
	return cool[randi() % cool.size()]

func _rainbow(t: float) -> Color:
	return Color(abs(sin(t*PI)), abs(sin(t*PI+2.1)), abs(sin(t*PI+4.2)), 1.0)


# ════════════════════════════════════════════════════════════
#  SPAWN HELPERS
# ════════════════════════════════════════════════════════════
func _spawn_ambient():
	for i in range(20): _add_spark(true, global_position, _rand_color())

func _add_spark(ambient: bool, origin: Vector2, col: Color):
	var angle  = randf() * TAU
	var radius = randf_range(10.0,60.0)  if ambient else randf_range(0.0,60.0)
	var spd    = randf_range(20.0,80.0)  if ambient else randf_range(80.0,700.0)
	var life   = randf_range(0.5,1.5)    if ambient else randf_range(0.2,3.0)
	var sz     = randf_range(2.0,5.0)    if ambient else randf_range(3.0,20.0)
	sparks.append({"pos":origin+Vector2(cos(angle),sin(angle))*radius,
		"vel":Vector2(cos(angle),sin(angle))*spd,"size":sz,"color":col,
		"trail":Color(col.r*0.5,col.g*0.5,col.b*0.5,1.0),
		"life":life,"max":life,"ambient":ambient,"gravity":randf_range(-10.0,140.0)})

func _add_ring(offset:Vector2, radius:float, col:Color, expand:float, life:float, width:float):
	rings.append({"offset":offset,"radius":radius,"color":col,"expand":expand,
		"life":life,"max":life,"width":width,"dash":randf()>0.5,"spin":randf_range(-2.0,2.0)})

func _add_bolt(origin:Vector2, length:float, col:Color):
	var angle=randf()*TAU; var segments=[]; var start=origin
	var dir=Vector2(cos(angle),sin(angle)); var segs=randi_range(8,20)
	for i in range(segs):
		var perp=Vector2(-dir.y,dir.x)
		var nxt=start+dir*(length/segs)+perp*randf_range(-35.0,35.0)
		segments.append({"from":start,"to":nxt}); start=nxt
	bolts.append({"segs":segments,"life":randf_range(0.04,0.22),"max":0.22,
		"color":col,"width":randf_range(1.0,6.0)})

func _add_shockwave(radius:float, max_r:float, col:Color, width:float):
	shockwaves.append({"radius":radius,"max_r":max_r,"life":1.2,"max":1.2,"color":col,"width":width})

func _add_beam(col:Color, length:float, width:float):
	var angle=randf()*TAU
	beams.append({"angle":angle,"length":length,"width":width,
		"life":randf_range(0.08,0.6),"max":0.6,"color":col,"cross":randf()>0.5,
		"double":randf()>0.6})

func _add_triangle(origin:Vector2, col:Color):
	var angle=randf()*TAU; var dist=randf_range(10.0,250.0)
	triangles.append({"pos":origin+Vector2(cos(angle),sin(angle))*dist,
		"vel":Vector2(cos(angle),sin(angle))*randf_range(40.0,400.0),
		"rot":randf()*TAU,"rot_spd":randf_range(-14.0,14.0),
		"size":randf_range(8.0,70.0),"color":col,
		"life":randf_range(0.3,2.0),"max":2.0,"filled":randf()>0.5})

func _add_hexagon(origin:Vector2, col:Color):
	var angle=randf()*TAU; var dist=randf_range(20.0,200.0)
	hexagons.append({"pos":origin+Vector2(cos(angle),sin(angle))*dist,
		"vel":Vector2(cos(angle),sin(angle))*randf_range(30.0,250.0),
		"rot":randf()*TAU,"rot_spd":randf_range(-8.0,8.0),
		"size":randf_range(10.0,60.0),"color":col,"life":randf_range(0.4,2.0),"max":2.0})

func _add_spiral(col:Color):
	spirals.append({"angle":randf()*TAU,"radius":randf_range(5.0,25.0),
		"expand":randf_range(60.0,500.0),
		"rot_spd":randf_range(4.0,30.0)*(1.0 if randf()>0.5 else -1.0),
		"life":randf_range(0.3,1.5),"max":1.5,"color":col,"size":randf_range(3.0,16.0)})

func _add_orb(origin:Vector2, col:Color):
	var angle=randf()*TAU; var spd=randf_range(20.0,200.0)
	orbs.append({"pos":origin,"vel":Vector2(cos(angle),sin(angle))*spd,
		"size":randf_range(5.0,30.0),"color":col,
		"life":randf_range(0.4,3.0),"max":3.0,"pulse":randf()*TAU,"glow_layers":randi_range(2,6)})

func _add_debris(origin:Vector2, col:Color):
	var angle=randf()*TAU
	debris.append({"pos":origin,"vel":Vector2(cos(angle),sin(angle))*randf_range(60.0,500.0),
		"size":Vector2(randf_range(3.0,30.0),randf_range(2.0,12.0)),
		"rot":randf()*TAU,"rot_spd":randf_range(-20.0,20.0),"color":col,
		"life":randf_range(0.3,2.5),"max":2.5,"gravity":randf_range(30.0,300.0)})

func _add_meteor(col:Color):
	var angle=randf()*TAU
	var origin=collect_pos+Vector2(cos(angle),sin(angle))*randf_range(400.0,900.0)
	var target=collect_pos+Vector2(randf_range(-150.0,150.0),randf_range(-150.0,150.0))
	var dir=(target-origin).normalized()
	meteors.append({"pos":origin,"vel":dir*randf_range(500.0,1100.0),
		"size":randf_range(4.0,18.0),"color":col,"life":randf_range(0.3,1.0),"max":1.0})

func _add_column(col:Color):
	var x=randf_range(-vp_size.x*0.6,vp_size.x*0.6)
	columns.append({"x":x,"width":randf_range(5.0,50.0),"color":col,
		"life":randf_range(0.05,0.35),"max":0.35})

func _add_ribbon(col:Color):
	var angle=randf()*TAU; var pts=[]
	var pos=collect_pos
	for i in range(16):
		pos+=Vector2(cos(angle+randf_range(-0.6,0.6)),sin(angle+randf_range(-0.6,0.6)))*randf_range(20.0,80.0)
		pts.append(pos)
	ribbons.append({"points":pts,"color":col,"life":randf_range(0.2,1.2),"max":1.2,
		"width":randf_range(2.0,14.0)})

func _add_vortex_part(col:Color):
	vortex_parts.append({"angle":randf()*TAU,"radius":randf_range(20.0,400.0),
		"rot_spd":randf_range(3.0,20.0)*(1.0 if randf()>0.5 else -1.0),
		"shrink":randf_range(30.0,150.0),"size":randf_range(3.0,12.0),
		"color":col,"life":randf_range(0.3,2.0),"max":2.0})

func _add_comet(col:Color):
	var angle=randf()*TAU
	var spd=randf_range(300.0,900.0)
	comets.append({"pos":collect_pos.lerp(collect_pos+Vector2(cos(angle),sin(angle))*300.0,randf()),
		"vel":Vector2(cos(angle),sin(angle))*spd,
		"size":randf_range(4.0,14.0),"color":col,
		"life":randf_range(0.2,0.8),"max":0.8,"tail_len":randi_range(10,25)})

func _add_pulse(col:Color):
	pulses.append({"radius":0.0,"max_r":randf_range(150.0,700.0),
		"color":col,"life":randf_range(0.3,1.0),"max":1.0,"rings":randi_range(1,5)})

func _add_glyph(col:Color):
	var angle=randf()*TAU; var dist=randf_range(20.0,300.0)
	glyphs.append({"pos":collect_pos+Vector2(cos(angle),sin(angle))*dist,
		"rot":randf()*TAU,"rot_spd":randf_range(-8.0,8.0),
		"size":randf_range(15.0,60.0),"color":col,"sides":randi_range(3,10),
		"life":randf_range(0.3,1.5),"max":1.5,
		"vel":Vector2(cos(angle),sin(angle))*randf_range(20.0,120.0)})

func _add_screen_spark():
	screen_sparks.append({"pos":Vector2(randf_range(-vp_size.x*0.5,vp_size.x*0.5),
		randf_range(-vp_size.y*0.5,vp_size.y*0.5)),
		"size":randf_range(2.0,18.0),"color":_rand_color(),
		"life":randf_range(0.05,0.4),"max":0.4})

func _add_star(col:Color):
	var angle=randf()*TAU; var dist=randf_range(50.0,500.0)
	stars.append({"pos":collect_pos+Vector2(cos(angle),sin(angle))*dist,
		"vel":Vector2(cos(angle),sin(angle))*randf_range(20.0,200.0),
		"size":randf_range(8.0,40.0),"color":col,"points":randi_range(4,9),
		"rot":randf()*TAU,"rot_spd":randf_range(-6.0,6.0),
		"life":randf_range(0.4,2.0),"max":2.0})

func _add_tendril(col:Color):
	var angle=randf()*TAU; var pts=[]
	var pos=collect_pos; var cur_angle=angle
	for i in range(20):
		cur_angle+=randf_range(-0.4,0.4)
		pos+=Vector2(cos(cur_angle),sin(cur_angle))*randf_range(15.0,50.0)
		pts.append(pos)
	tendrils.append({"points":pts,"color":col,"life":randf_range(0.5,2.0),"max":2.0,
		"width":randf_range(2.0,8.0),"grow":0.0,"grow_spd":randf_range(8.0,20.0)})

func _add_portal(col:Color):
	var angle=randf()*TAU; var dist=randf_range(100.0,350.0)
	portals.append({"pos":collect_pos+Vector2(cos(angle),sin(angle))*dist,
		"radius":0.0,"max_r":randf_range(40.0,120.0),"color":col,
		"spin":randf_range(2.0,8.0)*(1.0 if randf()>0.5 else -1.0),
		"life":randf_range(0.5,2.5),"max":2.5,"angle":randf()*TAU})

func _add_nova(col:Color):
	novas.append({"radius":0.0,"max_r":randf_range(200.0,600.0),"color":col,
		"life":0.9,"max":0.9,"rays":randi_range(6,16),"spin":randf_range(0.5,3.0),"angle":randf()*TAU})

func _add_sigil(col:Color):
	var pts=[]; var n=randi_range(5,12)
	for i in range(n):
		var a=float(i)/float(n)*TAU+randf_range(-0.3,0.3)
		var r=randf_range(30.0,100.0)
		pts.append(Vector2(cos(a),sin(a))*r)
	sigils.append({"points":pts,"color":col,"rot":randf()*TAU,"rot_spd":randf_range(-4.0,4.0),
		"life":randf_range(0.5,2.0),"max":2.0,"width":randf_range(1.5,4.0)})

func _add_crown_fx(col:Color):
	var angle=randf()*TAU; var dist=randf_range(80.0,300.0)
	crowns_fx.append({"pos":collect_pos+Vector2(cos(angle),sin(angle))*dist,
		"vel":Vector2(cos(angle),sin(angle))*randf_range(50.0,200.0),
		"size":randf_range(15.0,45.0),"color":col,
		"rot":randf()*TAU,"rot_spd":randf_range(-8.0,8.0),
		"life":randf_range(0.5,2.0),"max":2.0})

func _add_bubble_ring(col:Color):
	var n=randi_range(8,20); var radius=randf_range(50.0,200.0)
	var bubbles=[]
	for i in range(n):
		var a=float(i)/float(n)*TAU
		bubbles.append({"angle":a,"r":radius,"size":randf_range(4.0,12.0)})
	bubble_rings.append({"bubbles":bubbles,"spin":randf_range(1.0,5.0)*(1.0 if randf()>0.5 else -1.0),
		"expand":randf_range(50.0,200.0),"color":col,"life":randf_range(0.5,2.0),"max":2.0})

func _add_doom_circle(col:Color):
	doom_circles.append({"radius":randf_range(20.0,100.0),"max_r":randf_range(400.0,1000.0),
		"color":col,"life":1.5,"max":1.5,"width":randf_range(15.0,60.0),
		"segments":randi_range(3,8)})

func _add_aurora(col:Color):
	var pts=[]
	for i in range(20):
		var x=lerp(-vp_size.x*0.5, vp_size.x*0.5, float(i)/19.0)
		pts.append(Vector2(x, randf_range(-vp_size.y*0.3, vp_size.y*0.3)))
	aurora_bands.append({"points":pts,"color":col,"life":randf_range(0.5,2.0),"max":2.0,
		"width":randf_range(10.0,60.0),"wave_spd":randf_range(1.0,4.0),"wave_amp":randf_range(20.0,100.0),
		"phase":randf()*TAU})


# ════════════════════════════════════════════════════════════
#  GIANT EXPLOSION
# ════════════════════════════════════════════════════════════
func _giant_explosion():
	for i in range(16): _add_shockwave(5.0, randf_range(700.0,2000.0), _rand_color(), randf_range(10.0,70.0))
	for i in range(30): _add_beam(_rand_color(), randf_range(500.0,1200.0), randf_range(6.0,40.0))
	for i in range(400): _add_spark(false, collect_pos, _rand_color())
	for i in range(30): _add_bolt(collect_pos, randf_range(400.0,1000.0), _rand_color())
	for i in range(50): _add_triangle(collect_pos, _rand_color())
	for i in range(40): _add_hexagon(collect_pos, _rand_color())
	for i in range(40): _add_debris(collect_pos, _rand_color())
	for i in range(30): _add_orb(collect_pos, _rand_color())
	for i in range(20): _add_ring(Vector2.ZERO,5.0,_rand_color(),randf_range(400.0,1200.0),1.0,randf_range(8.0,30.0))
	for i in range(30): _add_spiral(_rand_color())
	for i in range(20): _add_comet(_rand_color())
	for i in range(15): _add_ribbon(_rand_color())
	for i in range(15): _add_vortex_part(_rand_color())
	for i in range(12): _add_pulse(_rand_color())
	for i in range(25): _add_glyph(_rand_color())
	for i in range(25): _add_star(_rand_color())
	for i in range(15): _add_meteor(_rand_color())
	for i in range(30): _add_column(_rand_color())
	for i in range(60): _add_screen_spark()
	for i in range(10): _add_nova(_rand_color())
	for i in range(8):  _add_doom_circle(_rand_color())
	for i in range(10): _add_tendril(_rand_color())
	for i in range(8):  _add_portal(_rand_color())
	for i in range(6):  _add_sigil(_rand_color())
	for i in range(10): _add_crown_fx(_rand_color())
	for i in range(8):  _add_bubble_ring(_rand_color())
	for i in range(5):  _add_aurora(_rand_color())


func _medium_burst():
	for i in range(6): _add_shockwave(5.0,randf_range(200.0,600.0),_rand_color(),randf_range(5.0,15.0))
	for i in range(10): _add_beam(_rand_color(),randf_range(200.0,500.0),randf_range(4.0,15.0))
	for i in range(80): _add_spark(false,collect_pos,_rand_color())
	for i in range(10): _add_bolt(collect_pos,randf_range(200.0,500.0),_rand_color())
	for i in range(15): _add_triangle(collect_pos,_rand_color())
	for i in range(10): _add_orb(collect_pos,_rand_color())
	for i in range(8):  _add_ring(Vector2.ZERO,5.0,_rand_color(),randf_range(150.0,400.0),0.8,randf_range(4.0,12.0))
	for i in range(5):  _add_nova(_rand_color())
	for i in range(3):  _add_doom_circle(_rand_color())
	for i in range(5):  _add_tendril(_rand_color())
	for i in range(20): _add_screen_spark()


# ════════════════════════════════════════════════════════════
#  MAIN PROCESS
# ════════════════════════════════════════════════════════════
func _process(delta):
	time += delta

	if not collecting and not won:
		position.y = start_y + sin(time*BOB_SPEED)*BOB_HEIGHT
		rotation  += SPIN_SPEED * delta
		while sparks.size() < 20: _add_spark(true,global_position,_rand_color())
		if player and global_position.distance_to(player.global_position) < PICKUP_DIST:
			_collect()

	if collecting:
		global_position = collect_pos
		collect_time   += delta
		var t = collect_time / COLLECT_DUR
		bg_hue += delta * 0.5

		# ── Phase 1 (0–0.1): first tremor ─────────────────────
		if t < 0.1:
			shake_amount = t * 60.0
			if randi()%2==0: _add_spark(false,collect_pos,_hot_color())
			if randi()%4==0: _add_bolt(collect_pos,randf_range(60.0,150.0),_hot_color())
			if randi()%8==0: _add_ring(Vector2.ZERO,5.0,_rand_color(),60.0,0.4,2.0)
			if randi()%6==0: _add_screen_spark()

		# ── Phase 2 (0.1–0.22): awakening ─────────────────────
		elif t < 0.22:
			var pt=(t-0.1)/0.12; shake_amount=30.0
			rotation+=18.0*delta; scale=Vector2.ONE*(1.0+pt*1.5)
			for i in range(3): _add_spark(false,collect_pos,_rand_color())
			if randi()%2==0: _add_bolt(collect_pos,randf_range(100.0,300.0),_rand_color())
			if randi()%3==0: _add_ring(Vector2.ZERO,5.0,_rand_color(),randf_range(80.0,200.0),0.5,randf_range(2.0,5.0))
			if randi()%3==0: _add_beam(_rand_color(),randf_range(100.0,300.0),randf_range(3.0,10.0))
			if randi()%4==0: _add_triangle(collect_pos,_rand_color())
			if randi()%5==0: _add_orb(collect_pos,_rand_color())
			if randi()%5==0: _add_tendril(_rand_color())
			for i in range(3): _add_screen_spark()
			if pt<0.02: _add_shockwave(5.0,200.0,_rand_color(),5.0)
			flash_rect.color=Color(randf_range(0.6,1),randf_range(0.3,0.8),0.0,abs(sin(pt*PI*6.0))*0.2)

		# ── Phase 3 (0.22–0.38): DOMAIN EXPANSION ─────────────
		elif t < 0.38:
			var pt=(t-0.22)/0.16; shake_amount=50.0
			rotation+=40.0*delta; scale=Vector2.ONE*(2.5+sin(pt*PI*3.0)*2.0)
			for i in range(6): _add_spark(false,collect_pos,_rand_color())
			for i in range(2): _add_bolt(collect_pos,randf_range(150.0,450.0),_rand_color())
			if randi()%2==0: _add_ring(Vector2.ZERO,10.0,_rand_color(),randf_range(150.0,400.0),0.6,randf_range(3.0,10.0))
			if randi()%2==0: _add_beam(_rand_color(),randf_range(200.0,600.0),randf_range(5.0,20.0))
			if randi()%2==0: _add_triangle(collect_pos,_rand_color())
			if randi()%2==0: _add_hexagon(collect_pos,_rand_color())
			if randi()%2==0: _add_debris(collect_pos,_rand_color())
			if randi()%3==0: _add_spiral(_rand_color())
			if randi()%3==0: _add_orb(collect_pos,_rand_color())
			if randi()%3==0: _add_ribbon(_rand_color())
			if randi()%3==0: _add_meteor(_rand_color())
			if randi()%3==0: _add_glyph(_rand_color())
			if randi()%3==0: _add_star(_rand_color())
			if randi()%4==0: _add_comet(_rand_color())
			if randi()%4==0: _add_vortex_part(_rand_color())
			if randi()%4==0: _add_column(_rand_color())
			if randi()%4==0: _add_nova(_rand_color())
			if randi()%5==0: _add_tendril(_rand_color())
			if randi()%5==0: _add_portal(_rand_color())
			if randi()%6==0: _add_sigil(_rand_color())
			if randi()%6==0: _add_bubble_ring(_rand_color())
			if pt<0.02:
				for i in range(4): _add_shockwave(10.0,randf_range(300.0,700.0),_rand_color(),randf_range(5.0,15.0))
			for i in range(8): _add_screen_spark()
			flash_rect.color=Color(abs(sin(pt*PI*10.0)),abs(sin(pt*PI*10.0+2.1)),abs(sin(pt*PI*10.0+4.2)),0.35)
			color_rect.color=Color.from_hsv(fmod(bg_hue,1.0),0.8,0.3,0.15)

		# ── Phase 4 (0.38–0.52): FIRST CRESCENDO ──────────────
		elif t < 0.52:
			var pt=(t-0.38)/0.14; shake_amount=70.0
			rotation+=60.0*delta; scale=Vector2.ONE*(4.0+sin(pt*PI*5.0)*3.0)
			for i in range(10): _add_spark(false,collect_pos,_rand_color())
			for i in range(4):  _add_bolt(collect_pos,randf_range(200.0,600.0),_rand_color())
			_add_ring(Vector2.ZERO,5.0,_rand_color(),randf_range(200.0,600.0),0.7,randf_range(4.0,15.0))
			if randi()%2==0: _add_beam(_rand_color(),randf_range(300.0,800.0),randf_range(8.0,25.0))
			if randi()%2==0: _add_triangle(collect_pos,_rand_color())
			if randi()%2==0: _add_hexagon(collect_pos,_rand_color())
			if randi()%2==0: _add_debris(collect_pos,_rand_color())
			if randi()%2==0: _add_orb(collect_pos,_rand_color())
			if randi()%2==0: _add_glyph(_rand_color())
			if randi()%2==0: _add_star(_rand_color())
			if randi()%2==0: _add_comet(_rand_color())
			if randi()%2==0: _add_meteor(_rand_color())
			if randi()%2==0: _add_nova(_rand_color())
			if randi()%2==0: _add_doom_circle(_rand_color())
			if randi()%3==0: _add_pulse(_rand_color())
			if randi()%3==0: _add_ribbon(_rand_color())
			if randi()%3==0: _add_vortex_part(_rand_color())
			if randi()%3==0: _add_tendril(_rand_color())
			if randi()%3==0: _add_portal(_rand_color())
			if randi()%3==0: _add_crown_fx(_rand_color())
			if randi()%4==0: _add_aurora(_rand_color())
			for i in range(12): _add_screen_spark()
			flash_rect.color=Color(abs(sin(pt*PI*15.0)),abs(sin(pt*PI*15.0+2.1)),abs(sin(pt*PI*15.0+4.2)),0.5)
			color_rect.color=Color.from_hsv(fmod(bg_hue,1.0),1.0,0.4,0.2)
			if pt<0.02:
				for i in range(6): _add_shockwave(5.0,randf_range(400.0,900.0),_rand_color(),randf_range(8.0,25.0))

		# ── Phase 5 (0.52–0.62): BRIEF CALM ───────────────────
		elif t < 0.62:
			var pt=(t-0.52)/0.10; shake_amount=lerp(70.0,10.0,pt)
			rotation+=lerp(60.0,5.0,pt)*delta
			scale=Vector2.ONE*lerp(4.0,1.0,pt)
			modulate=Color.from_hsv(fmod(bg_hue*2.0,1.0),0.5,1.0,1.0)
			for i in range(3): _add_spark(false,collect_pos,_cool_color())
			if randi()%4==0: _add_ring(Vector2.ZERO,5.0,_cool_color(),80.0,0.6,2.0)
			if randi()%3==0: _add_spiral(_cool_color())
			if randi()%4==0: _add_orb(collect_pos,_cool_color())
			for i in range(4): _add_screen_spark()
			flash_rect.color=Color(0,0,0,0)
			color_rect.color=Color(0,0,0,0)

		# ── Phase 6 (0.62–0.78): SECOND WAVE ──────────────────
		elif t < 0.78:
			var pt=(t-0.62)/0.16; shake_amount=80.0
			rotation+=50.0*delta; scale=Vector2.ONE*(1.0+pt*5.0)
			modulate=Color(1,1,1,1)
			for i in range(12): _add_spark(false,collect_pos,_rand_color())
			for i in range(5):  _add_bolt(collect_pos,randf_range(250.0,700.0),_rand_color())
			for i in range(2):  _add_ring(Vector2.ZERO,5.0,_rand_color(),randf_range(250.0,700.0),0.8,randf_range(5.0,18.0))
			if randi()%1==0: _add_beam(_rand_color(),randf_range(400.0,900.0),randf_range(10.0,35.0))
			if randi()%2==0: _add_nova(_rand_color())
			if randi()%2==0: _add_doom_circle(_rand_color())
			if randi()%2==0: _add_triangle(collect_pos,_rand_color())
			if randi()%2==0: _add_hexagon(collect_pos,_rand_color())
			if randi()%2==0: _add_crown_fx(_rand_color())
			if randi()%2==0: _add_bubble_ring(_rand_color())
			if randi()%2==0: _add_portal(_rand_color())
			if randi()%2==0: _add_sigil(_rand_color())
			if randi()%3==0: _add_aurora(_rand_color())
			if randi()%3==0: _add_tendril(_rand_color())
			if randi()%3==0: _add_meteor(_rand_color())
			for i in range(15): _add_screen_spark()
			flash_rect.color=Color(abs(sin(pt*PI*12.0)),abs(sin(pt*PI*12.0+2.1)),abs(sin(pt*PI*12.0+4.2)),0.55)
			color_rect.color=Color.from_hsv(fmod(bg_hue+0.5,1.0),1.0,0.5,0.25)
			if pt<0.02: _medium_burst()

		# ── Phase 7 (0.78–0.87): GIANT EXPLOSION ──────────────
		elif t < 0.87:
			var pt=(t-0.78)/0.09; shake_amount=120.0
			if pt<0.02: _giant_explosion()
			scale=Vector2.ONE*max(0.0,1.0-pt*pt*14.0)
			modulate.a=max(0.0,1.0-pt*7.0)
			flash_rect.color=Color(1,1,1,clamp(pt*6.0,0.0,1.0))
			color_rect.color=Color(0,0,0,0)
			for i in range(20): _add_screen_spark()

		# ── Phase 8 (0.87–0.92): white out ────────────────────
		elif t < 0.92:
			visible=false; shake_amount=40.0
			var pt=(t-0.87)/0.05
			flash_rect.color=Color(1,1,1,1.0-pt)
			black_rect.color=Color(0,0,0,pt)

		# ── Phase 9 (0.92+): YOU WIN ───────────────────────────
		else:
			visible=false; shake_amount=0.0
			flash_rect.color=Color(0,0,0,0)
			black_rect.color=Color(0,0,0,1)
			var lt=clamp((t-0.92)/0.6,0.0,1.0)
			win_label.modulate.a=lt
			win_label.scale=Vector2.ONE*(0.3+0.7*lt)

		if collect_time >= COLLECT_DUR:
			won=true; get_tree().paused=true

	if shake_amount>0.0 and player:
		player.position+=Vector2(randf_range(-1,1),randf_range(-1,1))*shake_amount*0.04

	_tick_particles(delta)
	queue_redraw()


func _collect():
	var enemy = get_node_or_null("../enemy")
	if enemy:
		enemy.on_crown_collected()
	collecting=true; collect_pos=global_position
	for i in range(60): _add_spark(false,collect_pos,_rand_color())
	for i in range(10): _add_bolt(collect_pos,200.0,_rand_color())
	for i in range(6):  _add_ring(Vector2.ZERO,5.0,_rand_color(),150.0,0.7,4.0)
	for i in range(6):  _add_orb(collect_pos,_rand_color())
	for i in range(6):  _add_triangle(collect_pos,_rand_color())
	for i in range(3):  _add_nova(_rand_color())
	for i in range(3):  _add_tendril(_rand_color())
	_add_shockwave(5.0,300.0,_rand_color(),8.0)
	_add_shockwave(5.0,500.0,_rand_color(),12.0)
	_add_doom_circle(_rand_color())


# ════════════════════════════════════════════════════════════
#  TICK ALL PARTICLES
# ════════════════════════════════════════════════════════════
func _tick_particles(delta):
	var dead=[]
	for s in sparks:
		s["life"]-=delta; s["vel"].y+=s["gravity"]*delta
		s["pos"]+=s["vel"]*delta; s["vel"]*=0.93
		if s["life"]<=0: dead.append(s)
	for d in dead: sparks.erase(d); dead.clear()
	for r in rings:
		r["life"]-=delta; r["radius"]+=r["expand"]*delta
		if r["life"]<=0: dead.append(r)
	for d in dead: rings.erase(d); dead.clear()
	for b in bolts:
		b["life"]-=delta
		if b["life"]<=0: dead.append(b)
	for d in dead: bolts.erase(d); dead.clear()
	for sw in shockwaves:
		sw["life"]-=delta; sw["radius"]+=(sw["max_r"]-sw["radius"])*5.0*delta
		if sw["life"]<=0: dead.append(sw)
	for d in dead: shockwaves.erase(d); dead.clear()
	for bm in beams:
		bm["life"]-=delta
		if bm["life"]<=0: dead.append(bm)
	for d in dead: beams.erase(d); dead.clear()
	for tr in triangles:
		tr["life"]-=delta; tr["pos"]+=tr["vel"]*delta
		tr["rot"]+=tr["rot_spd"]*delta; tr["vel"]*=0.96
		if tr["life"]<=0: dead.append(tr)
	for d in dead: triangles.erase(d); dead.clear()
	for hx in hexagons:
		hx["life"]-=delta; hx["pos"]+=hx["vel"]*delta
		hx["rot"]+=hx["rot_spd"]*delta; hx["vel"]*=0.96
		if hx["life"]<=0: dead.append(hx)
	for d in dead: hexagons.erase(d); dead.clear()
	for sp in spirals:
		sp["life"]-=delta; sp["angle"]+=sp["rot_spd"]*delta; sp["radius"]+=sp["expand"]*delta
		if sp["life"]<=0: dead.append(sp)
	for d in dead: spirals.erase(d); dead.clear()
	for db in debris:
		db["life"]-=delta; db["vel"].y+=db["gravity"]*delta
		db["pos"]+=db["vel"]*delta; db["rot"]+=db["rot_spd"]*delta; db["vel"]*=0.97
		if db["life"]<=0: dead.append(db)
	for d in dead: debris.erase(d); dead.clear()
	for o in orbs:
		o["life"]-=delta; o["pos"]+=o["vel"]*delta; o["vel"]*=0.98; o["pulse"]+=delta*8.0
		if o["life"]<=0: dead.append(o)
	for d in dead: orbs.erase(d); dead.clear()
	for ss in screen_sparks:
		ss["life"]-=delta
		if ss["life"]<=0: dead.append(ss)
	for d in dead: screen_sparks.erase(d); dead.clear()
	for st in stars:
		st["life"]-=delta; st["pos"]+=st["vel"]*delta; st["rot"]+=st["rot_spd"]*delta; st["vel"]*=0.97
		if st["life"]<=0: dead.append(st)
	for d in dead: stars.erase(d); dead.clear()
	for col_data in columns:
		col_data["life"]-=delta
		if col_data["life"]<=0: dead.append(col_data)
	for d in dead: columns.erase(d); dead.clear()
	for rb in ribbons:
		rb["life"]-=delta
		if rb["life"]<=0: dead.append(rb)
	for d in dead: ribbons.erase(d); dead.clear()
	for vp in vortex_parts:
		vp["life"]-=delta; vp["angle"]+=vp["rot_spd"]*delta
		vp["radius"]=max(0.0,vp["radius"]-vp["shrink"]*delta)
		if vp["life"]<=0: dead.append(vp)
	for d in dead: vortex_parts.erase(d); dead.clear()
	for cm in comets:
		cm["life"]-=delta; cm["pos"]+=cm["vel"]*delta; cm["vel"]*=0.97
		if cm["life"]<=0: dead.append(cm)
	for d in dead: comets.erase(d); dead.clear()
	for p in pulses:
		p["life"]-=delta; p["radius"]+=(p["max_r"]-p["radius"])*6.0*delta
		if p["life"]<=0: dead.append(p)
	for d in dead: pulses.erase(d); dead.clear()
	for g in glyphs:
		g["life"]-=delta; g["pos"]+=g["vel"]*delta; g["rot"]+=g["rot_spd"]*delta; g["vel"]*=0.97
		if g["life"]<=0: dead.append(g)
	for d in dead: glyphs.erase(d); dead.clear()
	for m in meteors:
		m["life"]-=delta; m["pos"]+=m["vel"]*delta; m["vel"]*=0.99
		if m["life"]<=0: dead.append(m)
	for d in dead: meteors.erase(d); dead.clear()
	for td in tendrils:
		td["life"]-=delta; td["grow"]=min(1.0,td["grow"]+td["grow_spd"]*delta)
		if td["life"]<=0: dead.append(td)
	for d in dead: tendrils.erase(d); dead.clear()
	for pt in portals:
		pt["life"]-=delta; pt["angle"]+=pt["spin"]*delta
		pt["radius"]=min(pt["max_r"],pt["radius"]+pt["max_r"]*2.0*delta)
		if pt["life"]<=0: dead.append(pt)
	for d in dead: portals.erase(d); dead.clear()
	for n in novas:
		n["life"]-=delta; n["radius"]+=(n["max_r"]-n["radius"])*5.0*delta; n["angle"]+=n["spin"]*delta
		if n["life"]<=0: dead.append(n)
	for d in dead: novas.erase(d); dead.clear()
	for s in sigils:
		s["life"]-=delta; s["rot"]+=s["rot_spd"]*delta
		if s["life"]<=0: dead.append(s)
	for d in dead: sigils.erase(d); dead.clear()
	for c in crowns_fx:
		c["life"]-=delta; c["pos"]+=c["vel"]*delta; c["rot"]+=c["rot_spd"]*delta; c["vel"]*=0.97
		if c["life"]<=0: dead.append(c)
	for d in dead: crowns_fx.erase(d); dead.clear()
	for br in bubble_rings:
		br["life"]-=delta
		for bub in br["bubbles"]:
			bub["angle"]+=br["spin"]*delta; bub["r"]+=br["expand"]*delta
		if br["life"]<=0: dead.append(br)
	for d in dead: bubble_rings.erase(d); dead.clear()
	for dc in doom_circles:
		dc["life"]-=delta; dc["radius"]+=(dc["max_r"]-dc["radius"])*4.0*delta
		if dc["life"]<=0: dead.append(dc)
	for d in dead: doom_circles.erase(d); dead.clear()
	for ab in aurora_bands:
		ab["life"]-=delta; ab["phase"]+=ab["wave_spd"]*delta
		if ab["life"]<=0: dead.append(ab)
	for d in dead: aurora_bands.erase(d); dead.clear()


# ════════════════════════════════════════════════════════════
#  DRAW
# ════════════════════════════════════════════════════════════
func _draw():
	# Aurora bands (behind everything)
	for ab in aurora_bands:
		var t=ab["life"]/ab["max"]; var col=ab["color"]; col.a=t*0.4
		for i in range(ab["points"].size()-1):
			var a=to_local(ab["points"][i]+Vector2(0,sin(ab["phase"]+float(i)*0.5)*ab["wave_amp"]))
			var b=to_local(ab["points"][i+1]+Vector2(0,sin(ab["phase"]+float(i+1)*0.5)*ab["wave_amp"]))
			draw_line(a,b,col,ab["width"]*t)
			var glow=Color(col.r,col.g,col.b,t*0.15)
			draw_line(a,b,glow,ab["width"]*t*2.5)

	# Doom circles
	for dc in doom_circles:
		var t=dc["life"]/dc["max"]; var col=dc["color"]; col.a=t*t
		var segs=dc["segments"]
		for i in range(segs):
			var a1=float(i)/float(segs)*TAU; var a2=float(i+1)/float(segs)*TAU-0.1
			draw_arc(Vector2.ZERO,dc["radius"],a1,a2,16,col,dc["width"]*t)
		draw_arc(Vector2.ZERO,dc["radius"]*0.8,0,TAU,32,Color(col.r,col.g,col.b,t*0.3),dc["width"]*t*0.4)

	# Shockwaves
	for sw in shockwaves:
		var t=sw["life"]/sw["max"]; var col=sw["color"]; col.a=t*t
		draw_arc(Vector2.ZERO,sw["radius"],0,TAU,64,col,sw["width"]*t)
		draw_arc(Vector2.ZERO,sw["radius"]*0.9,0,TAU,64,Color(col.r,col.g,col.b,t*0.2),sw["width"]*t*2.0)
		draw_arc(Vector2.ZERO,sw["radius"]*1.1,0,TAU,64,Color(col.r,col.g,col.b,t*0.15),sw["width"]*t*1.5)

	# Novas
	for n in novas:
		var t=n["life"]/n["max"]; var col=n["color"]; col.a=t
		draw_arc(Vector2.ZERO,n["radius"],0,TAU,48,col,3.0*t)
		for i in range(n["rays"]):
			var a=n["angle"]+float(i)/float(n["rays"])*TAU
			var tip=Vector2(cos(a),sin(a))*n["radius"]*1.4*t
			draw_line(Vector2.ZERO,tip,Color(col.r,col.g,col.b,t*0.7),4.0*t)
			draw_line(Vector2.ZERO,tip,Color(1,1,1,t*0.3),1.5*t)

	# Pulses
	for p in pulses:
		var t=p["life"]/p["max"]; var col=p["color"]
		for i in range(p["rings"]):
			var r=p["radius"]*(1.0-float(i)*0.15); col.a=t*t*(1.0-float(i)*0.3)
			draw_arc(Vector2.ZERO,r,0,TAU,48,col,3.0*t)

	# Rings
	for r in rings:
		var t=r["life"]/r["max"]; var col=r["color"]; col.a=t
		draw_arc(Vector2.ZERO,r["radius"],0,TAU,48,col,r["width"]*t)
		draw_arc(Vector2.ZERO,r["radius"],0,TAU,48,Color(col.r,col.g,col.b,t*0.2),r["width"]*t*2.5)

	# Portals
	for pt in portals:
		var t=pt["life"]/pt["max"]; var col=pt["color"]; col.a=t
		var lpos=to_local(pt["pos"])
		for i in range(5):
			var r=pt["radius"]*(1.0-float(i)*0.18)
			var ic=Color(col.r,col.g,col.b,t*(0.8-float(i)*0.15))
			draw_arc(lpos,r,pt["angle"]+float(i)*0.3,pt["angle"]+TAU*0.85+float(i)*0.3,32,ic,3.0*t)
		draw_circle(lpos,pt["radius"]*0.3,Color(col.r,col.g,col.b,t*0.4))

	# Beams
	for bm in beams:
		var t=bm["life"]/bm["max"]; var col=bm["color"]; col.a=t
		var tip=Vector2(cos(bm["angle"]),sin(bm["angle"]))*bm["length"]*t
		draw_line(Vector2.ZERO,tip,col,bm["width"]*t)
		draw_line(Vector2.ZERO,tip,Color(1,1,1,t*0.5),bm["width"]*t*0.3)
		draw_line(Vector2.ZERO,-tip*0.7,col,bm["width"]*t*0.6)
		if bm["double"]:
			var tip2=tip.rotated(0.15)
			draw_line(Vector2.ZERO,tip2,Color(col.r,col.g,col.b,t*0.5),bm["width"]*t*0.5)

	# Columns
	for col_data in columns:
		var t=col_data["life"]/col_data["max"]
		var col=col_data["color"]; col.a=t
		var lx=to_local(collect_pos+Vector2(col_data["x"],0)).x
		draw_line(Vector2(lx,-vp_size.y),Vector2(lx,vp_size.y),col,col_data["width"]*t)
		draw_line(Vector2(lx,-vp_size.y),Vector2(lx,vp_size.y),Color(1,1,1,t*0.2),col_data["width"]*t*0.3)

	# Ribbons
	for rb in ribbons:
		var t=rb["life"]/rb["max"]; var col=rb["color"]; col.a=t
		for i in range(rb["points"].size()-1):
			draw_line(to_local(rb["points"][i]),to_local(rb["points"][i+1]),col,rb["width"]*t)
			draw_line(to_local(rb["points"][i]),to_local(rb["points"][i+1]),Color(1,1,1,t*0.25),rb["width"]*t*0.3)

	# Tendrils
	for td in tendrils:
		var t=td["life"]/td["max"]; var col=td["color"]; col.a=t
		var show=int(td["grow"]*float(td["points"].size()-1))
		for i in range(min(show,td["points"].size()-1)):
			draw_line(to_local(td["points"][i]),to_local(td["points"][i+1]),col,td["width"]*t)
			draw_line(to_local(td["points"][i]),to_local(td["points"][i+1]),Color(1,1,1,t*0.3),td["width"]*t*0.3)

	# Sigils
	for s in sigils:
		var t=s["life"]/s["max"]; var col=s["color"]; col.a=t
		var n=s["points"].size()
		for i in range(n):
			var a=_rotate_point(s["points"][i],s["rot"])
			var b=_rotate_point(s["points"][(i+2)%n],s["rot"])
			draw_line(a,b,col,s["width"]*t)
		for i in range(n):
			var a=_rotate_point(s["points"][i],s["rot"])
			var b=_rotate_point(s["points"][(i+1)%n],s["rot"])
			draw_line(a,b,Color(col.r,col.g,col.b,t*0.4),s["width"]*t*0.5)

	# Bubble rings
	for br in bubble_rings:
		var t=br["life"]/br["max"]; var col=br["color"]; col.a=t
		for bub in br["bubbles"]:
			var lpos=Vector2(cos(bub["angle"]),sin(bub["angle"]))*bub["r"]
			draw_circle(lpos,bub["size"]*t,col)
			draw_circle(lpos,bub["size"]*t,Color(1,1,1,t*0.3))
			draw_arc(lpos,bub["size"]*t*1.5,0,TAU,8,Color(col.r,col.g,col.b,t*0.2),1.5)

	# Sparks
	for s in sparks:
		var t=s["life"]/s["max"]; var col=s["color"]; col.a=t*t
		var lpos=to_local(s["pos"]); var trail=to_local(s["pos"]-s["vel"]*0.07)
		draw_line(trail,lpos,Color(s["trail"].r,s["trail"].g,s["trail"].b,t*0.5),s["size"]*0.5)
		draw_circle(lpos,s["size"]*t,col)
		draw_circle(lpos,s["size"]*t*0.35,Color(1,1,1,t*0.7))

	# Bolts
	for b in bolts:
		var t=b["life"]/b["max"]; var col=b["color"]; col.a=t
		for seg in b["segs"]:
			var lf=to_local(seg["from"]); var lt=to_local(seg["to"])
			draw_line(lf,lt,col,b["width"])
			draw_line(lf,lt,Color(1,1,1,t*0.8),b["width"]*0.35)
			if randf()<0.4:
				var mid=(lf+lt)*0.5
				var perp=(lt-lf).rotated(PI*0.5).normalized()*randf_range(8.0,30.0)
				draw_line(mid,mid+perp,Color(col.r,col.g,col.b,t*0.6),b["width"]*0.5)

	# Triangles
	for tr in triangles:
		var t=tr["life"]/tr["max"]; var col=tr["color"]; col.a=t
		var lpos=to_local(tr["pos"]); var sz=tr["size"]*t; var r=tr["rot"]
		var p1=lpos+Vector2(cos(r),sin(r))*sz
		var p2=lpos+Vector2(cos(r+TAU/3.0),sin(r+TAU/3.0))*sz
		var p3=lpos+Vector2(cos(r+2.0*TAU/3.0),sin(r+2.0*TAU/3.0))*sz
		if tr["filled"]: draw_colored_polygon(PackedVector2Array([p1,p2,p3]),col)
		draw_line(p1,p2,col,2.5); draw_line(p2,p3,col,2.5); draw_line(p3,p1,col,2.5)

	# Hexagons
	for hx in hexagons:
		var t=hx["life"]/hx["max"]; var col=hx["color"]; col.a=t
		var lpos=to_local(hx["pos"]); var sz=hx["size"]*t; var r=hx["rot"]
		var pts=PackedVector2Array()
		for i in range(6): pts.append(lpos+Vector2(cos(r+i*TAU/6.0),sin(r+i*TAU/6.0))*sz)
		for i in range(6): draw_line(pts[i],pts[(i+1)%6],col,2.5)

	# Glyphs
	for g in glyphs:
		var t=g["life"]/g["max"]; var col=g["color"]; col.a=t
		var lpos=to_local(g["pos"]); var sz=g["size"]*t; var r=g["rot"]; var n=g["sides"]
		for i in range(n):
			var a1=lpos+Vector2(cos(r+i*TAU/n),sin(r+i*TAU/n))*sz
			var a2=lpos+Vector2(cos(r+(i+1)*TAU/n),sin(r+(i+1)*TAU/n))*sz
			draw_line(a1,a2,col,2.0)
			draw_line(lpos,a1,Color(col.r,col.g,col.b,t*0.3),1.0)

	# Stars
	for st in stars:
		var t=st["life"]/st["max"]; var col=st["color"]; col.a=t
		var lpos=to_local(st["pos"]); var sz=st["size"]*t; var r=st["rot"]; var n=st["points"]
		for i in range(n):
			var outer=lpos+Vector2(cos(r+i*TAU/n),sin(r+i*TAU/n))*sz
			var inner=lpos+Vector2(cos(r+(i+0.5)*TAU/n),sin(r+(i+0.5)*TAU/n))*sz*0.4
			var outer2=lpos+Vector2(cos(r+(i+1)*TAU/n),sin(r+(i+1)*TAU/n))*sz
			draw_line(inner,outer,col,2.0); draw_line(inner,outer2,col,2.0)
			draw_circle(outer,sz*0.1,Color(1,1,1,t*0.6))

	# Spirals
	for sp in spirals:
		var t=sp["life"]/sp["max"]; var col=sp["color"]; col.a=t
		var lpos=Vector2(cos(sp["angle"]),sin(sp["angle"]))*sp["radius"]
		draw_circle(lpos,sp["size"]*t,col)
		draw_circle(lpos,sp["size"]*t*0.4,Color(1,1,1,t*0.6))
		draw_circle(lpos,sp["size"]*t*2.0,Color(col.r,col.g,col.b,t*0.2))

	# Vortex
	for vp in vortex_parts:
		var t=vp["life"]/vp["max"]; var col=vp["color"]; col.a=t
		var lpos=Vector2(cos(vp["angle"]),sin(vp["angle"]))*vp["radius"]
		draw_circle(lpos,vp["size"]*t,col)
		draw_circle(lpos,vp["size"]*t*0.5,Color(1,1,1,t*0.5))

	# Debris
	for db in debris:
		var t=db["life"]/db["max"]; var col=db["color"]; col.a=t
		var lpos=to_local(db["pos"]); var sz=db["size"]; var r=db["rot"]
		var corners=[lpos+Vector2(cos(r),sin(r))*sz.x+Vector2(-sin(r),cos(r))*sz.y,
			lpos+Vector2(cos(r),sin(r))*sz.x-Vector2(-sin(r),cos(r))*sz.y,
			lpos-Vector2(cos(r),sin(r))*sz.x-Vector2(-sin(r),cos(r))*sz.y,
			lpos-Vector2(cos(r),sin(r))*sz.x+Vector2(-sin(r),cos(r))*sz.y]
		draw_colored_polygon(PackedVector2Array(corners),col)

	# Crown FX
	for c in crowns_fx:
		var t=c["life"]/c["max"]; var col=c["color"]; col.a=t
		var lpos=to_local(c["pos"]); var sz=c["size"]*t; var r=c["rot"]
		for i in range(5):
			var a=r+float(i)/5.0*TAU
			var tip=lpos+Vector2(cos(a),sin(a))*sz
			draw_line(lpos,tip,col,3.0*t)
			draw_circle(tip,sz*0.15,Color(1,1,1,t*0.8))
		draw_circle(lpos,sz*0.3,col)

	# Orbs
	for o in orbs:
		var t=o["life"]/o["max"]; var col=o["color"]; col.a=t
		var lpos=to_local(o["pos"]); var sz=o["size"]*(1.0+sin(o["pulse"])*0.3)*t
		for i in range(o["glow_layers"]):
			draw_circle(lpos,sz*(3.0-float(i)*0.5),Color(col.r,col.g,col.b,t*0.1*(o["glow_layers"]-i)))
		draw_circle(lpos,sz,col); draw_circle(lpos,sz*0.35,Color(1,1,1,t*0.9))

	# Comets
	for cm in comets:
		var t=cm["life"]/cm["max"]; var col=cm["color"]; col.a=t
		var lpos=to_local(cm["pos"])
		var tail=to_local(cm["pos"]+(-cm["vel"].normalized())*cm["size"]*cm["tail_len"]*t)
		draw_line(lpos,tail,Color(col.r,col.g,col.b,t*0.4),cm["size"]*t*0.5)
		draw_circle(lpos,cm["size"]*t,col); draw_circle(lpos,cm["size"]*t*0.4,Color(1,1,1,t*0.8))

	# Meteors
	for m in meteors:
		var t=m["life"]/m["max"]; var col=m["color"]; col.a=t
		var lpos=to_local(m["pos"]); var tail=to_local(m["pos"]-m["vel"]*0.08)
		draw_line(tail,lpos,Color(col.r,col.g,col.b,t*0.4),m["size"]*t)
		draw_circle(lpos,m["size"]*t,col); draw_circle(lpos,m["size"]*t*0.3,Color(1,1,1,t))

	# Screen sparks
	var cam_off=player.global_position if player else collect_pos
	for ss in screen_sparks:
		var t=ss["life"]/ss["max"]; var col=ss["color"]; col.a=t*t
		var lpos=to_local(cam_off+ss["pos"])
		draw_circle(lpos,ss["size"]*t,col); draw_circle(lpos,ss["size"]*t*0.4,Color(1,1,1,t*0.7))


func _rotate_point(p:Vector2, angle:float)->Vector2:
	return Vector2(p.x*cos(angle)-p.y*sin(angle), p.x*sin(angle)+p.y*cos(angle))
