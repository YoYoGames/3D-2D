/// @func ST_AssetRenderer()
///
/// @desc
function ST_AssetRenderer() constructor
{
	/// @var {Struct.BBMOD_Camera}
	Camera = new BBMOD_Camera();
	Camera.Orthographic = true;
	Camera.Zoom = 5.0;
	Camera.Direction = 90.0;
	Camera.DirectionUp = -45.0;
	Camera.ZFar *= 0.5;
	Camera.ZNear = -Camera.ZFar;

	/// @var {Struct.BBMOD_Vec3}
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3}
	Rotation = new BBMOD_Vec3();

	/// @var {Real}
	Scale = 1.0;

	/// @var {Real}
	Width = 256;

	/// @var {Real}
	Height = 256;

	/// @var {Bool}
	SmoothEdges = false;

	/// @var {Constant.Color}
	BackgroundColor = c_black;

	/// @var {Real}
	BackgroundAlpha = 0.0;

	/// @var {Id.Surface}
	/// @private
	Surface = noone;

	/// @func UpdateCamera()
	///
	/// @desc
	static UpdateCamera = function () {
		gml_pragma("forceinline");
		Camera.AspectRatio = Width / Height;
		Camera.Width = Camera.Zoom * Camera.AspectRatio;
		Camera.update_matrices();
	};

	/// @func DrawPreview(_asset, _x, _y, _width, _height)
	///
	/// @desc
	///
	/// @param {Struct.ST_Asset} _asset
	/// @param {Real} _x
	/// @param {Real} _y
	/// @param {Real} _width
	/// @param {Real} _height
	static DrawPreview = function (_asset, _x, _y, _width, _height) {
		UpdateCamera();
		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		var _world = matrix_get(matrix_world);
		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);
		Surface = bbmod_surface_check(Surface, _width, _height);
		surface_set_target(Surface);
		draw_clear_alpha(BackgroundColor, BackgroundAlpha);

		var _cameraAspectRatio = Camera.AspectRatio;
		var _cameraWidth = Camera.Width;
		Camera.AspectRatio = _width / _height;
		Camera.Width = Camera.Zoom * Camera.AspectRatio;
		Camera.update_matrices();
		Camera.apply();

		var _matrix = new BBMOD_Matrix()
			.Scale(Scale, Scale, Scale)
			.RotateEuler(Rotation)
			.Translate(Position);
		_asset.Draw(_matrix);

		Camera.AspectRatio = _cameraAspectRatio;
		Camera.Width = _cameraWidth;
		Camera.update_matrices();

		surface_reset_target();
		matrix_set(matrix_world, _world);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);
		gpu_pop_state();
		draw_surface(Surface, _x, _y);
	};

	/// @func CreateStaticSprite(_asset[, _direction])
	///
	/// @desc
	///
	/// @param {Struct.ST_Asset} _asset
	/// @param {Real} [_direction]
	static CreateStaticSprite = function (_asset, _direction=0) {
		UpdateCamera();
		Surface = bbmod_surface_check(Surface, Width, Height);
		surface_set_target(Surface);
		draw_clear_alpha(BackgroundColor, BackgroundAlpha);
		Camera.apply();
		var _matrix = new BBMOD_Matrix()
			.Scale(Scale, Scale, Scale)
			.RotateEuler(Rotation)
			.Translate(Position)
			.RotateZ(_direction);
		_asset.Draw(_matrix, _asset.GetTransform(true));
		surface_reset_target();
		return sprite_create_from_surface(Surface, 0, 0, Width, Height, false, SmoothEdges, 0, 0);
	};

	/// @func CreateAnimatedSprite(_asset, _animationIndex[, _direction])
	///
	/// @desc
	///
	/// @param {Struct.ST_Asset} _asset
	/// @param {Real} _animationIndex
	/// @param {Real} [_direction]
	///
	/// @return {Asset.GMSprite} Returns `undefined` if no sprite was created.
	static CreateAnimatedSprite = function (_asset, _animationIndex, _direction=0) {
		UpdateCamera();
		Surface = bbmod_surface_check(Surface, Width, Height);
		var _animation = _asset.Animations[_animationIndex];
		var _animationDuration = _animation.Duration;
		var _frameFilter = _asset.FrameFilters[_animationIndex];
		var _sprite = undefined;
		var _matrix = new BBMOD_Matrix()
			.Scale(Scale, Scale, Scale)
			.RotateEuler(Rotation)
			.Translate(Position)
			.RotateZ(_direction);
		for (var _frame = 0; _frame < _animationDuration; ++_frame)
		{
			if (!_frameFilter[_frame])
			{
				continue;
			}
			surface_set_target(Surface);
			draw_clear_alpha(BackgroundColor, BackgroundAlpha);
			Camera.apply();
			_asset.DrawAnimationFrame(_animationIndex, _frame, _matrix);
			surface_reset_target();
			if (!_sprite)
			{
				_sprite = sprite_create_from_surface(Surface, 0, 0, Width, Height, false, SmoothEdges, 0, 0);
			}
			else
			{
				sprite_add_from_surface(_sprite, Surface, 0, 0, Width, Height, false, SmoothEdges);
			}
		}
		return _sprite;
	};

	/// @func Destroy()
	///
	/// @desc
	///
	/// @return {Undefined}
	static Destroy = function () {
		if (surface_exists(Surface))
		{
			surface_free(Surface);
			Surface = noone;
		}
		return undefined;
	};
}
