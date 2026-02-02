extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var move_sfx: AudioStreamPlayer2D = $MoveSfx
@onready var move_speed = 125

var bullet_scene = preload("res://scenes/bullet.tscn")
var gun_scene = preload("res://scenes/gun.tscn")
var gun: Gun
var move_vector: Vector2
var cursor: Node2D


func _ready() -> void:
    cursor = get_tree().get_first_node_in_group("cursor")
    gun = gun_scene.instantiate()
    add_child(gun)
    gun.target = cursor
    gun.on_recoil.connect(on_recoil)

func _process(_delta: float) -> void:
    handle_animation()

func _physics_process(_delta: float) -> void:
    handle_input()
    move_and_slide()

func handle_input():
    move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    if move_vector != Vector2.ZERO:
        velocity = move_vector.normalized() * move_speed
    else:
        velocity = lerp(velocity, Vector2.ZERO, 0.2)
    # Movement stops after animation. refer to  _on_animated_sprite_2d_animation_finished

    gun.is_triggering = Input.is_action_pressed("trigger")

func handle_animation():
    var is_looking_left = cursor.position.x < position.x

    animated_sprite_2d.flip_h = is_looking_left

    if velocity == Vector2.ZERO:
        animated_sprite_2d.play("idle")
    else:
        animated_sprite_2d.play("walk")


func on_recoil(direction: Vector2):
    move_and_collide(direction * 2)


func _on_animated_sprite_2d_animation_finished() -> void:
    if animated_sprite_2d.animation == "walk":
        move_sfx.pitch_scale = randf_range(0.9, 1.1)
        move_sfx.play()
        if move_vector == Vector2.ZERO:
            velocity = Vector2.ZERO
