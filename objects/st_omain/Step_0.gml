if (keyboard_check_pressed(vk_f1))
{
	Debug = !Debug;
}
show_debug_overlay(Debug);

var _viewport = GUI.Viewport;

GUI.Update();

////////////////////////////////////////////////////////////////////////////////
// Camera
Camera.AspectRatio = max(_viewport.RealWidth, 1) / max(_viewport.RealHeight, 1);
Camera.Width = Camera.Zoom * Camera.AspectRatio;

if (!mouse_check_button(mb_right))
{
	Camera.set_mouselook(false);
}

if (_viewport.IsMouseOver()
	&& GUI.WidgetFocused == undefined)
{
	Camera.Zoom = max(Camera.Zoom + (mouse_wheel_down() - mouse_wheel_up()) * 1, 1);

	if (mouse_check_button_pressed(mb_right))
	{
		if (!keyboard_check(vk_shift))
		{
			Camera.set_mouselook(true);
		}
		else
		{
			CameraPosition = Camera.Position.Clone();
			PanningCamera = true;
		}
	}

	if (!PanningCamera)
	{
		var _speed = 0.5 * (keyboard_check(vk_shift) ? 2.0 : 1.0);

		if (keyboard_check(ord("W")))
		{
			x += lengthdir_x(_speed, Camera.Direction);
			y += lengthdir_y(_speed, Camera.Direction);
		}
		if (!keyboard_check(vk_control) && keyboard_check(ord("S")))
		{
			x -= lengthdir_x(_speed, Camera.Direction);
			y -= lengthdir_y(_speed, Camera.Direction);
		}
		if (keyboard_check(ord("A")))
		{
			x += lengthdir_x(_speed, Camera.Direction + 90);
			y += lengthdir_y(_speed, Camera.Direction + 90);
		}
		if (keyboard_check(ord("D")))
		{
			x += lengthdir_x(_speed, Camera.Direction - 90);
			y += lengthdir_y(_speed, Camera.Direction - 90);
		}
		z += (keyboard_check(ord("E")) - keyboard_check(ord("Q"))) * _speed;
	}

	if (PanningCamera)
	{
		var _point = new BBMOD_Vec2(window_mouse_get_x(), window_mouse_get_y());
		var _dir = Camera.screen_point_to_vec3(_point, Renderer);
		// TODO: Move intersect_ray_plane out of Gizmo
		var _mouseWorld = Gizmo.intersect_ray_plane(
			CameraPosition, _dir, new BBMOD_Vec3(), Camera.get_forward());

		if (MouseOffset)
		{
			var _position = _mouseWorld.Sub(MouseOffset);
			x -= _position.X;
			y -= _position.Y;
			z -= _position.Z;
		}

		MouseOffset = _mouseWorld;

		if (!mouse_check_button(mb_right)
			|| !keyboard_check(vk_shift))
		{
			MouseOffset = undefined;
			CameraPosition = undefined;
			PanningCamera = false;
		}
	}
}

var _cameraDireciton = Camera.Direction;
var _cameraDirecitonUp = Camera.DirectionUp;

Camera.update(delta_time);

if (Camera.MouseLook)
{
	window_set_cursor(cr_none);
	if (Camera.Direction != _cameraDireciton
		|| Camera.DirectionUp != _cameraDirecitonUp)
	{
		global.stCameraDirection.X = Camera.Direction;
		global.stCameraDirection.Y = Camera.DirectionUp;
		GUI.Viewport.CameraDropdown.Selected = GUI.Viewport.OptionCustom;
	}
}

// Apply custom Camera in export options
var _exportOptionsWidget = GUI.ExportOptionsPane.ExportOptions;
if (_exportOptionsWidget.DropdownCamera.Selected == _exportOptionsWidget.OptionCustom)
{
	with (AssetRenderer.Camera)
	{
		ApplyCameraSetting("Custom");
	}
}

////////////////////////////////////////////////////////////////////////////////
// Renderer
Renderer.EnableMousepick = _viewport.IsMouseOver();
Renderer.update(delta_time);

////////////////////////////////////////////////////////////////////////////////
// Tasks
TaskQueue.Process();

////////////////////////////////////////////////////////////////////////////////
// Test saving and loading
if (keyboard_check(vk_control))
{
	if (keyboard_check_pressed(ord("N")))
	{
		GUI_ShowQuestionAsync(
			"Are you sure you want to create a new empty project? Any unsaved progress will be lost!",
			method(self, NewProject));
	}
	else if (keyboard_check_pressed(ord("S")))
	{
		var _path = (global.stSavePath == undefined || keyboard_check(vk_shift))
			? get_save_filename(ST_FILTER_SAVE, "")
			: global.stSavePath;
		if (_path != "")
		{
			SaveProject(_path);
		}
	}
	else if (keyboard_check_pressed(ord("O")))
	{
		var _callback = method(self, function () {
			var _path = get_open_filename(ST_FILTER_SAVE, "");
			if (_path != "")
			{
				LoadProject(_path);
			}
		});

		if (!Asset)
		{
			_callback();
		}
		else
		{
			GUI_ShowQuestionAsync(
				"Are you sure you want to open a different project? Any unsaved progress will be lost!",
				_callback);
		}
	}
}
