extends Sprite2D
class_name Gun

class GunData:
    var name: String
    var fire_interval: float
    var spread: float
    var frame_coords: Vector2

    static func instantiate(p_name: String, p_fire_interval: float, p_spread: float, p_frame_coords: Vector2) -> GunData:
        var data := GunData.new()
        data.name = p_name
        data.fire_interval = p_fire_interval
        data.spread = p_spread
        data.frame_coords = p_frame_coords
        return data

@onready var marker_2d: Marker2D = $Marker2D
@onready var shoot_sfx: AudioStreamPlayer2D = $ShootSfx

var bullet_scene = preload("res://scenes/bullet.tscn")
var target: Node2D

var is_triggering = false

var FIRE_INTERVAL: float = .1
var fire_interval: float = 0
const RAD_180 = deg_to_rad(180)
var SPREAD: float = 15
var spread: float = 1
var apply_spread_penalty := false

signal on_recoil(direction: Vector2)

func _process(_delta: float) -> void:
    handle_aim()

func _physics_process(delta: float) -> void:
    if is_triggering:
        fire_interval -= delta
        if fire_interval <= 0:
            fire()
            fire_interval = FIRE_INTERVAL
    elif fire_interval > 0:
        fire_interval -= delta
    if spread > 1:
        spread = move_toward(spread, 1, delta * (2.5 if is_triggering else 10.0))

    if position != Vector2.ZERO:
        position = position.move_toward(Vector2.ZERO, delta * 20)

func handle_aim():
    look_at(target.position)
    var is_looking_left = target.position.x < get_parent().position.x
    
    scale.y = -1 if is_looking_left else 1

func fire():
    var bullet: Bullet = bullet_scene.instantiate()

    # rotation
    var direction := marker_2d.global_position.direction_to(target.position).angle()
    var distance := marker_2d.global_position.distance_to(target.position)
    # var spread_multiplier = randfn(.5, 1.5)
    print("spread: ", spread)
    var spread_rad := deg_to_rad(spread * (2 if apply_spread_penalty else 1))

    direction = randfn(direction, spread_rad)
    distance = randfn(distance - SPREAD, SPREAD)

    bullet.max_distance = distance
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
        spread += SPREAD * .1

    # sfx
    shoot_sfx.pitch_scale = randf_range(0.9, 1.1)
    shoot_sfx.play()
    
    get_parent().get_parent().add_child(bullet)

func set_gun(data: GunData):
    FIRE_INTERVAL = data.fire_interval
    SPREAD = data.spread
    spread = 1
    frame_coords = data.frame_coords