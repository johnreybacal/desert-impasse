extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var move_speed = 100

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

func _process(_delta: float) -> void:
    handle_animation()

func _physics_process(_delta: float) -> void:
    handle_input()
    move_and_slide()

func handle_input():
    move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = move_vector.normalized() * move_speed

    gun.is_triggering = Input.is_action_pressed("trigger")

func handle_animation():
    var is_looking_left = cursor.position.x < position.x

    animated_sprite_2d.flip_h = is_looking_left

    if move_vector == Vector2.ZERO:
        animated_sprite_2d.play("idle")
    else:
        animated_sprite_2d.play("walk")
