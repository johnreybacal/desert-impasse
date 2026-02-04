extends Area2D
class_name Bullet

var bullet_speed = 500
var direction: Vector2
var distance_travelled: float
var max_distance: float
var initial_position: Vector2

var impact_particle_scene := preload("res://scenes/bullet_impact_particle.tscn")
var bullet_impact_scene := preload("res://scenes/bullet_impact.tscn")

func _ready() -> void:
    initial_position = position

func _process(delta: float) -> void:
    position += direction * bullet_speed * delta
    distance_travelled = position.distance_to(initial_position)
    if distance_travelled >= max_distance:
        var particle: GPUParticles2D = impact_particle_scene.instantiate()
        var bullet_impact = bullet_impact_scene.instantiate()

        get_parent().add_child(particle)
        get_parent().add_child(bullet_impact)
        particle.position = position
        particle.one_shot = true
        particle.emitting = true
        
        bullet_impact.position = position
        
        queue_free()
    
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    queue_free()
