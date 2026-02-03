extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var move_sfx: AudioStreamPlayer2D = $MoveSfx
@onready var move_speed = 125
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var navigation_marker: Sprite2D = $NavigationMarker

var bullet_scene = preload("res://scenes/bullet.tscn")
var gun_scene = preload("res://scenes/gun.tscn")
var gun: Gun
var aim_cursor: Node2D


func _ready() -> void:
    aim_cursor = get_tree().get_first_node_in_group("cursor")
    gun = gun_scene.instantiate()
    add_child(gun)
    gun.target = aim_cursor
    gun.on_recoil.connect(on_recoil)

    navigation_marker.top_level = true

    # https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_introduction_2d.html

    # These values need to be adjusted for the actor's speed
    # and the navigation layout.
    navigation_agent.path_desired_distance = 4.0
    navigation_agent.target_desired_distance = 4.0

    # Make sure to not await during _ready.
    actor_setup.call_deferred()

func actor_setup():
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame

    # Now that the navigation map is no longer empty, set the movement target.
    set_movement_target(Vector2.ZERO)

func set_movement_target(movement_target: Vector2):
    navigation_agent.target_position = movement_target
    navigation_marker.global_position = navigation_agent.get_final_position()
    navigation_marker.visible = true


func _process(_delta: float) -> void:
    handle_animation()

func _physics_process(_delta: float) -> void:
    handle_input()

    if navigation_agent.is_navigation_finished():
        navigation_marker.visible = false
        return

    var current_agent_position: Vector2 = global_position
    var next_path_position: Vector2 = navigation_agent.get_next_path_position()

    velocity = current_agent_position.direction_to(next_path_position) * move_speed
    
    move_and_slide()

func handle_input():
    gun.is_triggering = Input.is_action_pressed("trigger")

func handle_animation():
    var is_looking_left = aim_cursor.position.x < position.x

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
        if navigation_agent.is_navigation_finished():
            velocity = Vector2.ZERO
