extends Sprite2D
class_name Gun

@onready var marker_2d: Marker2D = $Marker2D
@onready var shoot_sfx: AudioStreamPlayer2D = $ShootSfx

var bullet_scene = preload("res://scenes/bullet.tscn")
var target: Node2D

var is_triggering = false

var FIRE_INTERVAL = .1
var fire_interval: float = 0
const RAD_180 = deg_to_rad(180)
var SPREAD: float = 15
var spread = 1
var rng = RandomNumberGenerator.new()


signal on_recoil(direction: Vector2)

func _process(_delta: float) -> void:
    handle_aim()

func _physics_process(delta: float) -> void:
    if is_triggering:
        fire_interval -= delta
        if fire_interval <= 0:
            fire()
            fire_interval = FIRE_INTERVAL
    elif fire_interval != 0:
        fire_interval = 0
    if fire_interval == 0 and spread > 1:
        spread = move_toward(spread, 1, delta * 10)

    
    if position != Vector2.ZERO:
        position = position.move_toward(Vector2.ZERO, delta * 20)

func handle_aim():
    look_at(target.position)
    var is_looking_left = target.position.x < get_parent().position.x
    
    scale.y = -1 if is_looking_left else 1

func fire():
    var bullet: Bullet = bullet_scene.instantiate()

    # rotation
    var direction = global_position.direction_to(target.position).angle()
    var spread_multiplier = rng.randfn(0, 1)
    var spread_rad = deg_to_rad(spread) * spread_multiplier

    direction = randf_range(direction - spread_rad, direction + spread_rad)

    bullet.position = marker_2d.global_position
    bullet.direction = Vector2.RIGHT.rotated(direction)
    bullet.rotation = direction

    # recoil gun
    var recoil_direction = RAD_180 + direction
    recoil_direction = Vector2.RIGHT.rotated(recoil_direction)
    
    position = recoil_direction * 5
    on_recoil.emit(recoil_direction)

    # increase spread with each fire
    if spread < SPREAD:
        spread += 1.25

    # sfx
    shoot_sfx.pitch_scale = randf_range(0.9, 1.1)
    shoot_sfx.play()
    
    get_parent().get_parent().add_child(bullet)
