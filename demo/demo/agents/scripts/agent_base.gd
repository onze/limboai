#*
#* agent_base.gd
#* =============================================================================
#* Copyright 2021-2024 Serhii Snitsaruk
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*
extends CharacterBody2D

## Base agent script.

const NinjaStar := preload("res://demo/agents/ninja_star/ninja_star.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health: Health = $Health
@onready var root: Node2D = $Root
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var _frames_since_facing_update: int = 0
var _is_dead: bool = false

func _ready() -> void:
	health.damaged.connect(_damaged)
	health.death.connect(_die)


func update_facing() -> void:
	_frames_since_facing_update += 1
	if _frames_since_facing_update > 3:
		face_dir(velocity.x)


func face_dir(dir: float) -> void:
	if dir > 0.0 and root.scale.x < 0.0:
		root.scale.x = 1.0;
		_frames_since_facing_update = 0
	if dir < 0.0 and root.scale.x > 0.0:
		root.scale.x = -1.0;
		_frames_since_facing_update = 0


func get_facing() -> float:
	return signf(root.scale.x)


func throw_ninja_star() -> void:
	var ninja_star := NinjaStar.instantiate()
	ninja_star.dir = get_facing()
	get_parent().add_child(ninja_star)
	ninja_star.global_position = global_position + Vector2.RIGHT * 100.0 * get_facing()


func _damaged(_amount: float, knockback: Vector2) -> void:
	apply_knockback(knockback)
	animation_player.play(&"hurt")
	var btplayer := get_node_or_null(^"BTPlayer") as BTPlayer
	if btplayer:
		btplayer.set_active(false)
	var hsm := get_node_or_null(^"LimboHSM")
	if hsm:
		hsm.set_active(false)
	await animation_player.animation_finished
	if btplayer and not _is_dead:
		btplayer.restart()
	if hsm and not _is_dead:
		hsm.set_active(true)


func apply_knockback(knockback: Vector2, frames: int = 10) -> void:
	if knockback.is_zero_approx():
		return
	for i in range(frames):
		velocity = lerp(velocity, knockback, 0.2)
		move_and_slide()
		await get_tree().physics_frame


func _die() -> void:
	_is_dead = true
	root.process_mode = Node.PROCESS_MODE_DISABLED
	animation_player.play(&"death")
	collision_shape_2d.set_deferred(&"disabled", true)

	for child in get_children():
		if child is BTPlayer or child is LimboHSM:
			child.set_active(false)

	await get_tree().create_timer(10.0).timeout
	queue_free()
