/// @func BBMOD_Camera()
///
/// @desc A camera with support for both orthographic and perspective
/// projection. While using perspective projection, you can easily switch
/// between first-person and third-person view. Comes with a mouselook
/// implementation that also works in HTML5.
///
/// @example
/// ```gml
/// // Create event
/// camera = new BBMOD_Camera();
/// camera.FollowObject = OPlayer;
/// camera.Zoom = 0.0; // Use 0.0 for FPS, > 0.0 for TPS
///
/// // End-Step event
/// camera.set_mouselook(true);
/// camera.update(delta_time);
///
/// // Draw event
/// camera.apply();
/// // Render scene here...
/// ```
function BBMOD_Camera() constructor
{
	/// @var {camera} An underlying GameMaker camera.
	/// @readonly
	Raw = camera_create();

	/// @var {Real} The camera's exposure value. Defaults to `1`.
	Exposure = 1.0;

	/// @var {Struct.BBMOD_Vec3} The camera's positon. Defaults to `(0, 0, 0)`.
	Position = new BBMOD_Vec3(0.0);

	/// @var {Struct.BBMOD_Vec3} A position where the camera is looking at.
	/// In FPS mode ({@link BBMOD_Camera.Zoom} equals to 0) this is the camera's
	/// direction. Defaults to `(1, 0, 0)`.
	Target = new BBMOD_Vec3(1.0, 0.0, 0.0);

	/// @var {Real} The camera's field of view. Defaults to `60`.
	/// @note This does not have any effect when {@link BBMOD_Camera.Orthographic}
	/// is enabled.
	Fov = 60.0;

	/// @var {Real} The camera's aspect ratio. Defaults to `16 / 9`.
	AspectRatio = 16.0 / 9.0;

	/// @var {Real} Distance to the near clipping plane. Anything closer to the
	/// camera than this will not be visible. Defaults to `0.1`.
	/// @note This can be a negative value if {@link BBMOD_Camera.Orthographic}
	/// is enabled.
	ZNear = 0.1;

	/// @var {Real} Distance to the far clipping plane. Anything farther from
	/// the camera than this will not be visible. Defaults to `32768`.
	ZFar = 32768.0;

	/// @var {Bool} Use `true` to enable orthographic projection. Defaults to
	/// `false` (perspective projection).
	Orthographic = false;

	/// @var {Real} The width of the orthographic projection. Height is computed
	/// using {@link BBMOD_Camera.AspectRatio}. Defaults to the window's width.
	/// @see BBMOD_Camera.Orthographic
	Width = window_get_width();

	/// @var {Id.Instance} An id of an instance to follow or `undefined`. The
	/// object must have a `z` variable (position on the z axis) defined!
	/// Defaults to `undefined`.
	FollowObject = undefined;

	/// @var {Bool} Used to determine change of the object to follow.
	/// @private
	FollowObjectLast = undefined;

	/// @var {Function} A function which remaps value in range `0..1` to a
	/// different `0..1` value. This is used to control the follow curve.
	/// If `undefined` then `lerp` is used. Defaults to `undefined`.
	FollowCurve = undefined;

	/// @var {Real} Controls lerp factor between the previous camera position
	/// and the object it follows. Defaults to `1`, which means the camera is
	/// immediately moved to its target position.
	/// {@link BBMOD_Camera.FollowObject} must not be `undefined` for this to
	/// have any effect.
	FollowFactor = 1.0;

	/// @var {Struct.BBMOD_Vec3} The camera's offset from its target. Defaults to
	/// `(0, 0, 0)`.
	Offset = new BBMOD_Vec3(0.0);

	/// @var {Bool} If `true` then mouselook is enabled. Defaults to `false`.
	/// @readonly
	/// @see BBMOD_Camera.set_mouselook
	MouseLook = false;

	/// @var {Real} Controls the mouselook sensitivity. Defaults to `1`.
	MouseSensitivity = 1.0;

	/// @var {Struct.BBMOD_Vec2} The position on the screen where the cursor
	/// is locked when {@link BBMOD_Camera.MouseLook} is `true`. Can be
	/// `undefined`.
	/// @private
	MouseLockAt = undefined;

	/// @var {Real} The camera's horizontal direction. Defaults to `0`.
	Direction = 0.0;

	/// @var {Real} The camera's vertical direction. Automatically clamped
	/// between {@link BBMOD_Camera.DirectionUpMin} and
	/// {@link BBMOD_Camera.DirectionUpMax}. Defaults to `0`.
	DirectionUp = 0.0;

	/// @var {Real} Minimum angle that {@link BBMOD_Camrea.DirectionUp}
	/// can be. Use `undefined` to remove the limit. Default value is `-89`.
	DirectionUpMin = -89.0;

	/// @var {Real} Maximum angle that {@link BBMOD_Camrea.DirectionUp}
	/// can be. Use `undefined` to remove the limit. Default value is `89`.
	DirectionUpMax = 89.0;

	/// @var {Real} The angle of camera's rotation from side to side. Default
	/// value is `0`.
	Roll = 0.0;

	/// @var {Real} The camera's distance from its target. Use `0` for a
	/// first-person camera. Defaults to `0`.
	Zoom = 0.0;

	/// @var {Bool} If `true` then the camera updates position and orientation
	/// of the 3D audio listener in the {@link BBMOD_Camera.update_matrices}
	/// method. Defaults to `true`.
	AudioListener = true;

	/// @var {Array<Real>} The `view * projection` matrix.
	/// @note This is updated each time {@link BBMOD_Camera.update_matrices}
	/// is called.
	/// @readonly
	ViewProjectionMatrix = matrix_build_identity();

	/// @func set_mouselook(_enable)
	///
	/// @desc Enable/disable mouselook. This locks the mouse cursor at its
	/// current position when enabled.
	///
	/// @param {Bool} _enable USe `true` to enable mouselook.
	///
	/// @return {Struct.BBMOD_Camera} Returns `self`.
	static set_mouselook = function (_enable) {
		if (_enable)
		{
			if (os_browser != browser_not_a_browser)
			{
				bbmod_html5_pointer_lock();
			}

			if (MouseLockAt == undefined)
			{
				MouseLockAt = new BBMOD_Vec2(
					window_mouse_get_x(),
					window_mouse_get_y());
			}
		}
		else
		{
			MouseLockAt = undefined;
		}
		MouseLook = _enable;
		return self;
	};

	/// @func update_matrices()
	///
	/// @desc Recomputes camera's view and projection matrices.
	///
	/// @return {Struct.BBMOD_Camera} Returns `self`.
	///
	/// @note This is called automatically in the {@link BBMOD_Camera.update}
	/// method, so you do not need to call this unless you modify
	/// {@link BBMOD_Camera.Position} or {@link BBMOD_Camera.Target} after the
	/// `update` method.
	///
	/// @example
	/// ```gml
	/// /// @desc Step event
	/// camera.set_mouselook(true);
	/// camera.update(delta_time);
	/// if (camera.Position.Z < 0.0)
	/// {
	///     camera.Position.Z = 0.0;
	/// }
	/// camera.update_matrices();
	/// ```
	static update_matrices = function () {
		gml_pragma("forceinline");

		var _forward = BBMOD_VEC3_FORWARD;
		var _right = BBMOD_VEC3_RIGHT;
		var _up = BBMOD_VEC3_UP;

		var _quatZ = new BBMOD_Quaternion().FromAxisAngle(_up, Direction);
		_forward = _quatZ.Rotate(_forward);
		_right = _quatZ.Rotate(_right);
		_up = _quatZ.Rotate(_up);

		var _quatY = new BBMOD_Quaternion().FromAxisAngle(_right, DirectionUp);
		_forward = _quatY.Rotate(_forward);
		_right = _quatY.Rotate(_right);
		_up = _quatY.Rotate(_up);

		var _quatX = new BBMOD_Quaternion().FromAxisAngle(_forward, Roll);
		_forward = _quatX.Rotate(_forward);
		_right = _quatX.Rotate(_right);
		_up = _quatX.Rotate(_up);

		var _target = Position.Add(_forward);

		var _view = matrix_build_lookat(
			Position.X, Position.Y, Position.Z,
			_target.X, _target.Y, _target.Z,
			_up.X, _up.Y, _up.Z);
		camera_set_view_mat(Raw, _view);

		var _proj = Orthographic
			? matrix_build_projection_ortho(Width, -Width / AspectRatio, ZNear, ZFar)
			: matrix_build_projection_perspective_fov(
				-Fov, -AspectRatio, ZNear, ZFar);
		camera_set_proj_mat(Raw, _proj);

		// Note: Using _view and _proj mat straight away leads into a weird result...
		ViewProjectionMatrix = matrix_multiply(
			get_view_mat(),
			get_proj_mat());

		if (AudioListener)
		{
			audio_listener_position(Position.X, Position.Y, Position.Z);
			audio_listener_orientation(
				_forward.X, _forward.Y, _forward.Z,
				_up.X, _up.Y, _up.Z);
		}

		return self;
	}

	/// @func update(_deltaTime[, _positionHandler])
	///
	/// @desc Handles mouselook, updates camera's position, matrices etc.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @param {Function} [_positionHandler] A function which takes the camera's
	/// position (@{link BBMOD_Vec3}) and returns a new position. This could be
	/// used for example for camera collisions in a third-person game. Defaults
	/// to `undefined`.
	///
	/// @return {Struct.BBMOD_Camera} Returns `self`.
	static update = function (_deltaTime, _positionHandler=undefined) {
		if (os_browser != browser_not_a_browser)
		{
			set_mouselook(bbmod_html5_pointer_is_locked());
		}

		if (MouseLook)
		{
			if (os_browser != browser_not_a_browser)
			{
				Direction -= bbmod_html5_pointer_get_movement_x() * MouseSensitivity;
				DirectionUp -= bbmod_html5_pointer_get_movement_y() * MouseSensitivity;
			}
			else
			{
				var _mouseX = window_mouse_get_x();
				var _mouseY = window_mouse_get_y();
				Direction += (MouseLockAt.X - _mouseX) * MouseSensitivity;
				DirectionUp += (MouseLockAt.Y - _mouseY) * MouseSensitivity;
				window_mouse_set(MouseLockAt.X, MouseLockAt.Y);
			}
		}

		if (DirectionUpMin != undefined)
		{
			DirectionUp = max(DirectionUp, DirectionUpMin);
		}
		if (DirectionUpMax != undefined)
		{
			DirectionUp = min(DirectionUp, DirectionUpMax);
		}

		var _offsetX = lengthdir_x(Offset.X, Direction - 90.0)
			+ lengthdir_x(Offset.Y, Direction);
		var _offsetY = lengthdir_y(Offset.X, Direction - 90.0)
			+ lengthdir_y(Offset.Y, Direction);
		var _offsetZ = Offset.Z;

		if (Zoom <= 0)
		{
			// First person camera
			if (FollowObject != undefined
				&& instance_exists(FollowObject))
			{
				Position.X = FollowObject.x + _offsetX;
				Position.Y = FollowObject.y + _offsetY;
				Position.Z = FollowObject.z + _offsetZ;
			}

			Target = Position.Add(new BBMOD_Vec3(
				+dcos(Direction),
				-dsin(Direction),
				+dtan(DirectionUp)
			));
		}
		else
		{
			// Third person camera
			if (FollowObject != undefined
				&& instance_exists(FollowObject))
			{
				var _targetNew = new BBMOD_Vec3(
					FollowObject.x + _offsetX,
					FollowObject.y + _offsetY,
					FollowObject.z + _offsetZ
				);

				if (FollowObjectLast == FollowObject
					&& FollowFactor < 1.0)
				{
					var _factor = 1.0
						- bbmod_lerp_delta_time(0.0, 1.0, FollowFactor, _deltaTime);
					if (FollowCurve != undefined)
					{
						_factor = FollowCurve(0.0, 1.0, _factor);
					}
					Target = _targetNew.Lerp(Target, _factor);
				}
				else
				{
					Target = _targetNew;
				}
			}

			var _l = dcos(DirectionUp) * Zoom;
			Position = Target.Add(new BBMOD_Vec3(
				-dcos(Direction) * _l,
				+dsin(Direction) * _l,
				-dsin(DirectionUp) * Zoom
			));
		}

		if (_positionHandler != undefined)
		{
			Position = _positionHandler(Position);
		}

		update_matrices();

		FollowObjectLast = FollowObject;

		return self;
	};

	/// @func get_view_mat()
	///
	/// @desc Retrieves camera's view matrix.
	///
	/// @return {Array<Real>} The view matrix.
	static get_view_mat = function () {
		gml_pragma("forceinline");

		if (os_browser == browser_not_a_browser)
		{
			// This returns a struct in HTML5 for some reason...
			return camera_get_view_mat(Raw);
		}

		var _view = matrix_get(matrix_view);
		var _proj = matrix_get(matrix_projection);
		camera_apply(Raw);
		var _retval = matrix_get(matrix_view);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _proj);
		return _retval;
	};

	/// @func get_proj_mat()
	///
	/// @desc Retrieves camera's projection matrix.
	///
	/// @return {Array<Real>} The projection matrix.
	static get_proj_mat = function () {
		gml_pragma("forceinline");

		if (os_browser == browser_not_a_browser)
		{
			// This returns a struct in HTML5 for some reason...
			return camera_get_proj_mat(Raw);
		}

		var _view = matrix_get(matrix_view);
		var _proj = matrix_get(matrix_projection);
		camera_apply(Raw);
		var _retval = matrix_get(matrix_projection);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _proj);
		return _retval;
	};

	/// @func get_right()
	///
	/// @desc Retrieves a vector pointing right relative to the camera's
	/// direction.
	///
	/// @return {Struct.BBMOD_Vec3} The right vector.
	static get_right = function () {
		gml_pragma("forceinline");
		var _view = get_view_mat();
		return new BBMOD_Vec3(
			_view[0],
			_view[4],
			_view[8]
		);
	};

	/// @func get_up()
	///
	/// @desc Retrieves a vector pointing up relative to the camera's
	/// direction.
	///
	/// @return {Struct.BBMOD_Vec3} The up vector.
	static get_up = function () {
		gml_pragma("forceinline");
		var _view = get_view_mat();
		return new BBMOD_Vec3(
			_view[1],
			_view[5],
			_view[9]
		);
	};

	/// @func get_forward()
	///
	/// @desc Retrieves a vector pointing forward in the camera's direction.
	///
	/// @return {Struct.BBMOD_Vec3} The forward vector.
	static get_forward = function () {
		gml_pragma("forceinline");
		var _view = get_view_mat();
		return new BBMOD_Vec3(
			_view[2],
			_view[6],
			_view[10]
		);
	};

	/// @func world_to_screen(_position[, _screenWidth[, _screenHeight]])
	///
	/// @desc Computes screen-space position of a point in world-space.
	///
	/// @param {Struct.BBMOD_Vec3} _position The world-space position.
	/// @param {Real} [_screenWidth] The width of the screen. If `undefined`, it
	/// is retrieved using `window_get_width`.
	/// @param {Real} [_screenHeight] The height of the screen. If `undefined`,
	/// it is retrieved using `window_get_height`.
	///
	/// @return {Struct.BBMOD_Vec4} The screen-space position or `undefined` if
	/// the point is outside of the screen.
	///
	/// @note This requires {@link BBMOD_Camera.ViewProjectionMatrix}, so you
	/// should use this *after* {@link BBMOD_Camera.update_matrices} (or
	/// {@link BBMOD_Camera.update}) is called!
	static world_to_screen = function (_position, _screenWidth=undefined, _screenHeight=undefined) {
		gml_pragma("forceinline");
		_screenWidth ??= window_get_width();
		_screenHeight ??= window_get_height();
		var _screenPos = new BBMOD_Vec4(_position.X, _position.Y, _position.Z, 1.0)
			.Transform(ViewProjectionMatrix);
		if (_screenPos.Z < 0.0)
		{
			return undefined;
		}
		_screenPos = _screenPos.Scale(1.0 / _screenPos.W);
		_screenPos.X = ((_screenPos.X * 0.5) + 0.5) * _screenWidth;
		_screenPos.Y = (1.0 - ((_screenPos.Y * 0.5) + 0.5)) * _screenHeight;
		return _screenPos;
	};

	/// @func screen_point_to_vec3(_vector[, _renderer])
	///
	/// @desc Unprojects a position on the screen into a direction in world-space.
	///
	/// @param {Struct.BBMOD_Vector2} _vector The position on the screen.
	/// @param {Struct.BBMOD_Renderer} [_renderer] A renderer or `undefined`.
	///
	/// @return {Struct.BBMOD_Vec3} The world-space direction.
	static screen_point_to_vec3 = function (_vector, _renderer=undefined) {
		var _forward = get_forward();
		var _up = get_up();
		var _right = get_right();
		var _tFov = dtan(Fov * 0.5);
		_up = _up.Scale(_tFov);
		_right = _right.Scale(_tFov * AspectRatio);
		var _screenWidth = _renderer ? _renderer.get_width() : window_get_width();
		var _screenHeight = _renderer ? _renderer.get_height() : window_get_height();
		var _screenX = _vector.X - (_renderer ? _renderer.X : 0);
		var _screenY = _vector.Y - (_renderer ? _renderer.Y : 0);
		var _ray = _forward.Add(_up.Scale(1.0 - 2.0 * (_screenY / _screenHeight))
			.Add(_right.Scale(2.0 * (_screenX / _screenWidth) - 1.0)));
		return _ray.Normalize();
	};

	/// @func apply()
	///
	/// @desc Applies the camera.
	///
	/// @return {Struct.BBMOD_Camera} Returns `self`.
	///
	/// @example
	/// Following code renders a model from the camera's view.
	/// ```gml
	/// camera.apply();
	/// bbmod_material_reset();
	/// model.submit();
	/// bbmod_material_reset();
	/// ```
	///
	/// @note This also overrides the camera position and exposure passed to
	/// shaders using {@link bbmod_camera_set_position} and
	/// {@link bbmod_camera_set_exposure} respectively!
	static apply = function () {
		gml_pragma("forceinline");
		global.__bbmodCameraCurrent = self;
		camera_apply(Raw);
		bbmod_camera_set_position(Position.Clone());
		bbmod_camera_set_zfar(ZFar);
		bbmod_camera_set_exposure(Exposure);
		return self;
	};
}
