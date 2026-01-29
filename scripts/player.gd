extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gun_sprite: Sprite2D = $GunSprite
@onready var bullet_spawn_marker: Marker2D = $GunSprite/Marker2D
@export var move_speed = 100

var bullet_scene = preload("res://scenes/bullet.tscn")

var move_vector: Vector2

func _process(_delta: float) -> void:
    handle_animation()

func _physics_process(_delta: float) -> void:
    handle_input()
    move_and_slide()

func handle_input():
    move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    velocity = move_vector.normalized() * move_speed

    if Input.is_action_just_pressed("trigger"):
        var direction = bullet_spawn_marker.global_position.direction_to(get_global_mouse_position())

        var bullet: Bullet = bullet_scene.instantiate()
        bullet.position = bullet_spawn_marker.global_position
        bullet.direction = direction
        bullet.rotation = gun_sprite.rotation
        
        get_parent().add_child(bullet)

func handle_animation():
    var mouse_position = get_global_mouse_position()
    var is_looking_left = mouse_position.x < position.x

    animated_sprite_2d.flip_h = is_looking_left
    gun_sprite.look_at(mouse_position)
    
    gun_sprite.scale.y = -1 if is_looking_left else 1


    if move_vector == Vector2.ZERO:
        animated_sprite_2d.play("idle")
    else:
        animated_sprite_2d.play("walk")
