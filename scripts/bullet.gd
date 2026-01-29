extends Area2D
class_name Bullet

var bullet_speed = 750
var direction: Vector2

func _process(delta: float) -> void:
    position += direction * bullet_speed * delta
    
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
    queue_free()
