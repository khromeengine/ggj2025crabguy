@tool
extends Camera2D
class_name BoundedCamera

@export var rectangle_bound: Vector2
@export var max_camera_size: Vector2
@export var no_scroll: bool = false

var lookat_target: Node2D

## Stores the length of the viewport with respect to zoom.
var _viewport_length: float = 0.0
## Stores the length of half the viewport with respect to zoom.
var _half_vp_length: float = 0.0

## Stores the height of the viewport with respect to zoom.
var _viewport_height: float = 0.0
## Stores the height of half the viewport with respect to zoom.
var _half_vp_height: float = 0.0

var _scroll_vert: bool = false
var _half_rect_x: float
var _half_rect_y: float
var _anchor: Vector2

var _zoomed = false




func _ready() -> void:
	if Engine.is_editor_hint():
		$Polygon2D.visible = true
		$CameraSize.visible = true
	else:
		$Polygon2D.visible = false
		$CameraSize.visible = false
		lookat_target = GameStateManager.player
		
	_anchor = global_position
	var max_x_zoom: float = get_viewport_rect().size.x / min(rectangle_bound.x, max_camera_size.x)
	var max_y_zoom: float = get_viewport_rect().size.y / min(rectangle_bound.y, max_camera_size.y)
	var max_zoom: float = max(max_x_zoom, max_y_zoom)
	if max_x_zoom > max_y_zoom:
		_scroll_vert = true
	zoom = Vector2(max_zoom, max_zoom)
	
	
	_viewport_length = get_viewport_rect().size.x / zoom.x
	_half_vp_length = 0.5 * _viewport_length
	_viewport_height = get_viewport_rect().size.y / zoom.y
	_half_vp_height = 0.5 * _viewport_height
	
	_half_rect_x = rectangle_bound.x / 2
	_half_rect_y = rectangle_bound.y / 2

	
func _physics_process(delta):
	if Engine.is_editor_hint():
		_half_rect_x = rectangle_bound.x / 2
		_half_rect_y = rectangle_bound.y / 2
		var half_cam_x = max_camera_size.x / 2
		var half_cam_y = max_camera_size.y / 2
		$Polygon2D.polygon[0] = Vector2(_half_rect_x, _half_rect_y)
		$Polygon2D.polygon[1] = Vector2(-_half_rect_x, _half_rect_y)
		$Polygon2D.polygon[2] = Vector2(-_half_rect_x, -_half_rect_y)
		$Polygon2D.polygon[3] = Vector2(_half_rect_x, -_half_rect_y)
		$CameraSize.polygon[0] = Vector2(half_cam_x, half_cam_y)
		$CameraSize.polygon[1] = Vector2(-half_cam_x, half_cam_y)
		$CameraSize.polygon[2] = Vector2(-half_cam_x, -half_cam_y)
		$CameraSize.polygon[3] = Vector2(half_cam_x, -half_cam_y)
	else:
		if not no_scroll:
			follow_tgt()


func follow_tgt():
	var tgtpos = lookat_target.global_position
	
	if _anchor.y - _half_rect_y + _half_vp_height < _anchor.y + _half_rect_y - _half_vp_height:
		global_position.y = clampf(tgtpos.y, _anchor.y - _half_rect_y + _half_vp_height, _anchor.y + _half_rect_y - _half_vp_height)
	if _anchor.x - _half_rect_x + _half_vp_length < _anchor.x + _half_rect_x - _half_vp_length:
		global_position.x = clampf(tgtpos.x, _anchor.x - _half_rect_x + _half_vp_length, _anchor.x + _half_rect_x - _half_vp_length)
