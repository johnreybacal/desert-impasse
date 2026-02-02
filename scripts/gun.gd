extends Sprite2D
class_name Gun

@onready var marker_2d: Marker2D = $Marker2D

var bullet_scene = preload("res://scenes/bullet.tscn")
var target: Node2D

var is_triggering = false

func _process(_delta: float) -> void:
    handle_aim()

func _physics_process(_delta: float) -> void:
    if is_triggering:
        fire()

func handle_aim():
    look_at(target.position)
    var is_looking_left = target.position.x < get_parent().position.x
    
    scale.y = -1 if is_looking_left else 1

func fire():
    var bullet: Bullet = bullet_scene.instantiate()

    var direction = global_position.direction_to(target.position)
    bullet.position = marker_2d.global_position
    bullet.direction = direction
    bullet.rotation = rotation
    
    get_parent().get_parent().add_child(bullet)
