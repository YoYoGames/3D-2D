/// @func ST_Gizmo([_size])
///
/// @extends BBMOD_Gizmo
///
/// @desc
///
/// @param {Real} [_size]
function ST_Gizmo(_size=15)
	: BBMOD_Gizmo(_size) constructor
{
	/// @var {Struct.BBMOD_Renderer}
	Renderer = undefined;

	/// @var {Struct.BBMOD_Camera}
	Camera = undefined;

	/// @var {Bool}
	EnableGridSnap = true;

	/// @var {Struct.BBMOD_Vec3}
	GridSize = new BBMOD_Vec3(1.0);

	/// @var {Bool}
	EnableAngleSnap = true;

	/// @var {Real}
	AngleSnap = 5.0;

	/// @var {Constant.VirtualKey}
	KeyCancel = vk_escape;

	/// @var {Constant.VirtualKey}
	KeyIgnoreSnap = vk_alt;

	GetInstanceGlobalMatrix = function (_instance)         { return _instance.Asset.Matrix ?? new BBMOD_Matrix(); };
	GetInstancePositionX    = function (_instance)         { return _instance.Asset.GetPositionX(); };
	GetInstancePositionY    = function (_instance)         { return _instance.Asset.GetPositionY(); };
	GetInstancePositionZ    = function (_instance)         { return _instance.Asset.GetPositionZ(); };
	GetInstanceRotationX    = function (_instance)         { return _instance.Asset.GetRotationX(); };
	GetInstanceRotationY    = function (_instance)         { return _instance.Asset.GetRotationY(); };
	GetInstanceRotationZ    = function (_instance)         { return _instance.Asset.GetRotationZ(); };
	GetInstanceScaleX       = function (_instance)         { return _instance.Asset.GetScaleX(); };
	GetInstanceScaleY       = function (_instance)         { return _instance.Asset.GetScaleY(); };
	GetInstanceScaleZ       = function (_instance)         { return _instance.Asset.GetScaleZ(); };
	SetInstancePositionX    = function (_instance, _value) { _instance.Asset.SetPositionX(_value); };
	SetInstancePositionY    = function (_instance, _value) { _instance.Asset.SetPositionY(_value); };
	SetInstancePositionZ    = function (_instance, _value) { _instance.Asset.SetPositionZ(_value); };
	SetInstanceRotationX    = function (_instance, _value) { _instance.Asset.SetRotationX(_value); };
	SetInstanceRotationY    = function (_instance, _value) { _instance.Asset.SetRotationY(_value); };
	SetInstanceRotationZ    = function (_instance, _value) { _instance.Asset.SetRotationZ(_value); };
	SetInstanceScaleX       = function (_instance, _value) { _instance.Asset.SetScaleX(_value); };
	SetInstanceScaleY       = function (_instance, _value) { _instance.Asset.SetScaleY(_value); };
	SetInstanceScaleZ       = function (_instance, _value) { _instance.Asset.SetScaleZ(_value); };

	static update = function (_deltaTime) {
		if (!Camera)
		{
			return self;
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Not editing or finished editing
		//
		if (!IsEditing || !mouse_check_button(ButtonDrag))
		{
			if (keyboard_check_pressed(KeyNextEditType))
			{
				if (++EditType >= BBMOD_EEditType.SIZE)
				{
					EditType = 0;
				}
			}

			if (keyboard_check_pressed(KeyNextEditSpace))
			{
				if (++EditSpace >= BBMOD_EEditSpace.SIZE)
				{
					EditSpace = 0;
				}
			}

			// Compute Gizmo's new position
			var _size = ds_list_size(Selected);
			var _posX = 0.0;
			var _posY = 0.0;
			var _posZ = 0.0;

			for (var i = _size - 1; i >= 0; --i)
			{
				var _instance = Selected[| i];

				if (!InstanceExists(_instance))
				{
					ds_list_delete(Selected, i);
					ds_list_delete(InstanceData, i);
					--_size;
					continue;
				}

				_posX += GetInstancePositionX(_instance);
				_posY += GetInstancePositionY(_instance);
				_posZ += GetInstancePositionZ(_instance);
			}

			if (_size > 0)
			{
				_posX /= _size;
				_posY /= _size;
				_posZ /= _size;

				Position.Set(_posX, _posY, _posZ);

				if (EditSpace == BBMOD_EEditSpace.Local)
				{
					var _lastSelected = Selected[| _size - 1];
					var _mat = GetInstanceGlobalMatrix(_lastSelected);
					var _mat2 = new BBMOD_Matrix().RotateEuler(get_instance_rotation_vec3(_lastSelected));
					var _mat3 = _mat2.Mul(_mat);
					var _euler = _mat3.ToEuler();
					Rotation.FromArray(_euler);
				}
				else
				{
					Rotation.Set(0.0, 0.0, 0.0);
				}
			}

			// Store instance data
			for (var i = _size - 1; i >= 0; --i)
			{
				var _instance = Selected[| i];
				var _data = InstanceData[| i];
				_data.Offset = get_instance_position_vec3(_instance).Sub(Position);
				_data.Rotation = get_instance_rotation_vec3(_instance);
				_data.Scale = get_instance_scale_vec3(_instance);
			}

			// Clear properties used when editing
			IsEditing = false;
			MouseOffset = undefined;
			MouseLockAt = undefined;
			PositionBackup = undefined;
			if (CursorBackup != undefined)
			{
				window_set_cursor(CursorBackup);
				CursorBackup = undefined;
			}
			ScaleBy = new BBMOD_Vec3(0.0);
			RotateBy = new BBMOD_Vec3(0.0);

			return self;
		}

		////////////////////////////////////////////////////////////////////////
		//
		// Editing
		//
		var _mouseX = window_mouse_get_x();
		var _mouseY = window_mouse_get_y();

		if (!MouseLockAt)
		{
			MouseLockAt = new BBMOD_Vec2(_mouseX, _mouseY);
			CursorBackup = window_get_cursor();
		}

		var _quaternionGizmo = new BBMOD_Quaternion().FromEuler(Rotation.X, Rotation.Y, Rotation.Z);
		var _forwardGizmo    = _quaternionGizmo.Rotate(BBMOD_VEC3_FORWARD);
		var _rightGizmo      = _quaternionGizmo.Rotate(BBMOD_VEC3_RIGHT);
		var _upGizmo         = _quaternionGizmo.Rotate(BBMOD_VEC3_UP);

		var _matRot = [
			_forwardGizmo.X, _forwardGizmo.Y, _forwardGizmo.Z, 0.0,
			_rightGizmo.X,   _rightGizmo.Y,   _rightGizmo.Z,   0.0,
			_upGizmo.X,      _upGizmo.Y,      _upGizmo.Z,      0.0,
			0.0,             0.0,             0.0,             1.0,
		];

		var _matRotInverse = [
			_forwardGizmo.X, _rightGizmo.X, _upGizmo.X, 0.0,
			_forwardGizmo.Y, _rightGizmo.Y, _upGizmo.Y, 0.0,
			_forwardGizmo.Z, _rightGizmo.Z, _upGizmo.Z, 0.0,
			0.0,             0.0,           0.0,        1.0,
		];

		////////////////////////////////////////////////////////////////////////
		// Handle editing
		switch (EditType)
		{
		case BBMOD_EEditType.Position:
			if (!PositionBackup)
			{
				PositionBackup = Position.Clone();
			}

			var _planeNormal = ((EditAxis == BBMOD_EEditAxis.Z) ? _forwardGizmo
				: ((EditAxis == BBMOD_EEditAxis.All) ? BBMOD_VEC3_UP
				: _upGizmo));
			var _mouseWorld = intersect_ray_plane(
				Camera.Position,
				Camera.screen_point_to_vec3(new BBMOD_Vec2(_mouseX, _mouseY), Renderer),
				PositionBackup,
				_planeNormal);

			if (!MouseOffset)
			{
				MouseOffset = Position.Sub(_mouseWorld);
			}

			var _diff = _mouseWorld.Add(MouseOffset).Sub(Position);

			if (EditAxis & BBMOD_EEditAxis.X)
			{
				Position = Position.Add(_forwardGizmo.Scale(_diff.Dot(_forwardGizmo)));
			}

			if (EditAxis & BBMOD_EEditAxis.Y)
			{
				Position = Position.Add(_rightGizmo.Scale(_diff.Dot(_rightGizmo)));
			}

			if (EditAxis & BBMOD_EEditAxis.Z)
			{
				Position = Position.Add(_upGizmo.Scale(_diff.Dot(_upGizmo)));
			}

			if (EnableGridSnap
				&& !keyboard_check(KeyIgnoreSnap))
			{
				if ((EditAxis & BBMOD_EEditAxis.X)
					&& GridSize.X != 0.0)
				{
					Position.X = floor(Position.X / GridSize.X) * GridSize.X;
				}

				if ((EditAxis & BBMOD_EEditAxis.Y)
					&& GridSize.Y != 0.0)
				{
					Position.Y = floor(Position.Y / GridSize.Y) * GridSize.Y;
				}

				if ((EditAxis & BBMOD_EEditAxis.Z && EditAxis != BBMOD_EEditAxis.All)
					&& GridSize.Z != 0.0)
				{
					Position.Z = floor(Position.Z / GridSize.Z) * GridSize.Z;
				}
			}
			break;

		case BBMOD_EEditType.Rotation:
			var _planeNormal = ((EditAxis == BBMOD_EEditAxis.X) ? _forwardGizmo
				: ((EditAxis == BBMOD_EEditAxis.Y) ? _rightGizmo
				: _upGizmo));
			var _mouseWorld = intersect_ray_plane(
				Camera.Position,
				Camera.screen_point_to_vec3(new BBMOD_Vec2(_mouseX, _mouseY), Renderer),
				Position,
				_planeNormal);

			if (!MouseOffset)
			{
				MouseOffset = _mouseWorld;
			}

			var _mul = (keyboard_check(KeyEditFaster) ? 2.0
				: (keyboard_check(KeyEditSlower) ? 0.1
				: 1.0));
			var _v1 = MouseOffset.Sub(Position);
			var _v2 = _mouseWorld.Sub(Position);
			var _angle = darctan2(_v2.Cross(_v1).Dot(_planeNormal), _v1.Dot(_v2)) * _mul;

			switch (EditAxis)
			{
			case BBMOD_EEditAxis.X:
				RotateBy.X += _angle;
				break;

			case BBMOD_EEditAxis.Y:
				RotateBy.Y += _angle;
				break;

			case BBMOD_EEditAxis.Z:
				RotateBy.Z += _angle;
				break;
			}

			window_mouse_set(MouseLockAt.X, MouseLockAt.Y);
			window_set_cursor(cr_none);
			break;

		case BBMOD_EEditType.Scale:
			var _planeNormal = (EditAxis == BBMOD_EEditAxis.Z) ? _forwardGizmo : _upGizmo;
			var _mouseWorld = intersect_ray_plane(
				Camera.Position,
				Camera.screen_point_to_vec3(new BBMOD_Vec2(_mouseX, _mouseY), Renderer),
				Position,
				_planeNormal);

			if (!MouseOffset)
			{
				MouseOffset = _mouseWorld;
			}

			var _mul = (keyboard_check(KeyEditFaster) ? 5.0
				: (keyboard_check(KeyEditSlower) ? 0.1
				: 1.0));

			var _diff = _mouseWorld.Sub(MouseOffset).Scale(_mul);

			if (EditAxis == BBMOD_EEditAxis.All)
			{
				var _diffX = _diff.Mul(_forwardGizmo.Abs()).Dot(_forwardGizmo);
				var _diffY = _diff.Mul(_rightGizmo.Abs()).Dot(_rightGizmo);
				var _scaleBy = (abs(_diffX) > abs(_diffY)) ? _diffX : _diffY;
				ScaleBy.X += _scaleBy;
				ScaleBy.Y += _scaleBy;
				ScaleBy.Z += _scaleBy;
			}
			else
			{
				if (EditAxis & BBMOD_EEditAxis.X)
				{
					ScaleBy.X += _diff.Mul(_forwardGizmo.Abs()).Dot(_forwardGizmo);
				}

				if (EditAxis & BBMOD_EEditAxis.Y)
				{
					ScaleBy.Y += _diff.Mul(_rightGizmo.Abs()).Dot(_rightGizmo);
				}

				if (EditAxis & BBMOD_EEditAxis.Z)
				{
					ScaleBy.Z += _diff.Mul(_upGizmo.Abs()).Dot(_upGizmo);
				}
			}

			window_mouse_set(MouseLockAt.X, MouseLockAt.Y);
			window_set_cursor(cr_none);
			break;
		}

		////////////////////////////////////////////////////////////////////////
		// Cancel editing?
		if (keyboard_check_pressed(KeyCancel))
		{
			if (PositionBackup)
			{
				PositionBackup.Copy(Position);
			}
			RotateBy.Set(0.0, 0.0, 0.0);
			ScaleBy.Set(0.0, 0.0, 0.0);
			IsEditing = false;
		}

		////////////////////////////////////////////////////////////////////////
		// Apply to selected instances
		var _size = ds_list_size(Selected);

		for (var i = _size - 1; i >= 0; --i)
		{
			var _instance = Selected[| i];

			if (!InstanceExists(_instance))
			{
				ds_list_delete(Selected, i);
				ds_list_delete(InstanceData, i);
				--_size;
				continue;
			}

			var _data = InstanceData[| i];
			var _positionOffset = _data.Offset;
			var _rotationStored = _data.Rotation;
			var _scaleStored = _data.Scale;

			// Get local basis
			var _quaternionInstance = new BBMOD_Quaternion().FromEuler(
				GetInstanceRotationX(_instance),
				GetInstanceRotationY(_instance),
				GetInstanceRotationZ(_instance));
			var _forwardInstance    = _quaternionInstance.Rotate(BBMOD_VEC3_FORWARD);
			var _rightInstance      = _quaternionInstance.Rotate(BBMOD_VEC3_RIGHT);
			var _upInstance         = _quaternionInstance.Rotate(BBMOD_VEC3_UP);

			// Apply rotation
			// TODO: Add configurable angle increments
			var _matGlobal    = GetInstanceGlobalMatrix(_instance);
			var _matGlobalInv = _matGlobal.Inverse();
			var _rotateByX    = RotateBy.X;
			var _rotateByY    = RotateBy.Y;
			var _rotateByZ    = RotateBy.Z;

			if (EnableAngleSnap
				&& AngleSnap != 0.0
				&& !keyboard_check(KeyIgnoreSnap))
			{
				_rotateByX = floor(RotateBy.X / AngleSnap) * AngleSnap;
				_rotateByY = floor(RotateBy.Y / AngleSnap) * AngleSnap;
				_rotateByZ = floor(RotateBy.Z / AngleSnap) * AngleSnap;
			}

			var _temp          = new BBMOD_Vec4(_forwardGizmo.X, _forwardGizmo.Y, _forwardGizmo.Z, 0.0).Transform(_matGlobalInv.Raw);
			var _forwardGlobal = new BBMOD_Vec3(_temp.X, _temp.Y, _temp.Z);
			var _temp          = new BBMOD_Vec4(_rightGizmo.X, _rightGizmo.Y, _rightGizmo.Z, 0.0).Transform(_matGlobalInv.Raw);
			var _rightGlobal   = new BBMOD_Vec3(_temp.X, _temp.Y, _temp.Z);
			var _temp          = new BBMOD_Vec4(_upGizmo.X, _upGizmo.Y, _upGizmo.Z, 0.0).Transform(_matGlobalInv.Raw);
			var _upGlobal      = new BBMOD_Vec3(_temp.X, _temp.Y, _temp.Z);

			var _rotMatrix = new BBMOD_Matrix().RotateEuler(_rotationStored);
			if (_rotateByX != 0.0)
			{
				var _quaternionX = new BBMOD_Quaternion().FromAxisAngle(_forwardGlobal, _rotateByX);
				_positionOffset = _quaternionX.Rotate(_positionOffset);
				_rotMatrix = _rotMatrix.RotateQuat(_quaternionX);
			}
			if (_rotateByY != 0.0)
			{
				var _quaternionY = new BBMOD_Quaternion().FromAxisAngle(_rightGlobal, _rotateByY);
				_positionOffset = _quaternionY.Rotate(_positionOffset);
				_rotMatrix = _rotMatrix.RotateQuat(_quaternionY);
			}
			if (_rotateByZ != 0.0)
			{
				var _quaternionZ = new BBMOD_Quaternion().FromAxisAngle(_upGlobal, _rotateByZ);
				_positionOffset = _quaternionZ.Rotate(_positionOffset);
				_rotMatrix = _rotMatrix.RotateQuat(_quaternionZ);
			}
			var _rotArray = _rotMatrix.ToEuler();
			SetInstanceRotationX(_instance, _rotArray[0]);
			SetInstanceRotationY(_instance, _rotArray[1]);
			SetInstanceRotationZ(_instance, _rotArray[2]);

			// Apply scale
			var _scaleNew = _scaleStored.Clone();
			var _scaleOld = _scaleNew.Clone();

			// Scale on X
			_scaleNew.X += ScaleBy.X * abs(_forwardGlobal.Dot(_forwardInstance));
			_scaleNew.Y += ScaleBy.X * abs(_forwardGlobal.Dot(_rightInstance));
			_scaleNew.Z += ScaleBy.X * abs(_forwardGlobal.Dot(_upInstance));

			// Scale on Y
			_scaleNew.X += ScaleBy.Y * abs(_rightGlobal.Dot(_forwardInstance));
			_scaleNew.Y += ScaleBy.Y * abs(_rightGlobal.Dot(_rightInstance));
			_scaleNew.Z += ScaleBy.Y * abs(_rightGlobal.Dot(_upInstance));

			// Scale on Z
			_scaleNew.X += ScaleBy.Z * abs(_upGlobal.Dot(_forwardInstance));
			_scaleNew.Y += ScaleBy.Z * abs(_upGlobal.Dot(_rightInstance));
			_scaleNew.Z += ScaleBy.Z * abs(_upGlobal.Dot(_upInstance));

			// Scale offset
			var _vI = matrix_transform_vertex(_matRotInverse, _positionOffset.X, _positionOffset.Y, _positionOffset.Z);
			var _vIRot = matrix_transform_vertex(
				matrix_build(
					0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
					(1.0 / max(_scaleOld.X, 0.0001)) * (_scaleOld.X + ScaleBy.X),
					(1.0 / max(_scaleOld.Y, 0.0001)) * (_scaleOld.Y + ScaleBy.Y),
					(1.0 / max(_scaleOld.Z, 0.0001)) * (_scaleOld.Z + ScaleBy.Z)),
				_vI[0], _vI[1], _vI[2]);
			var _v = matrix_transform_vertex(_matRot, _vIRot[0], _vIRot[1], _vIRot[2]);

			// Apply scale and position
			set_instance_scale_vec3(_instance, _scaleNew);
			SetInstancePositionX(_instance, Position.X + _v[0]);
			SetInstancePositionY(_instance, Position.Y + _v[1]);
			SetInstancePositionZ(_instance, Position.Z + _v[2]);
		}

		return self;
	};
}
