extends CharacterBody2D
class_name Enemy

@export var alert_color: Color

@onready var vision_renderer: Polygon2D = $VisionCone2D/VisionConeRenderer
@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var move_speed = 50
@onready var alerted_animation: AnimationPlayer = $AlertedSprite/AnimationPlayer
var target: Node2D

func _ready() -> void:
    navigation_agent.path_desired_distance = 4.0
    navigation_agent.target_desired_distance = 4.0

    actor_setup.call_deferred()

func actor_setup():
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame

func set_movement_target(movement_target: Vector2):
    navigation_agent.target_position = movement_target
    

func _on_vision_cone_area_body_entered(body: Node2D) -> void:
    if body is Player:
        print("%s is seeing %s" % [ self , body])
        vision_renderer.color = alert_color
        target = body
        alerted_animation.play("alerted")

func _on_vision_cone_area_body_exited(body: Node2D) -> void:
    if body is Player:
        target = null
        print("%s stopped seeing %s" % [ self , body])
        vision_renderer.color = original_color


func _physics_process(_delta: float) -> void:
    if target:
        set_movement_target(target.global_position)
    if navigation_agent.is_navigation_finished():
        return

    var current_agent_position: Vector2 = global_position
    var next_path_position: Vector2 = navigation_agent.get_next_path_position()

    velocity = current_agent_position.direction_to(next_path_position) * move_speed
    handle_animation()

    move_and_slide()

func handle_animation():
    animated_sprite_2d.play("worm")
    if target:
        animated_sprite_2d.flip_h = position.x > target.position.x
