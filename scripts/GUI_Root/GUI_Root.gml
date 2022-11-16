/// @func GUI_Root([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Root(_props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	Root = self;

	/// @var {Struct.GUI_Widget}
	/// @readonly
	WidgetHovered = undefined;

	/// @var {Struct.GUI_Widget}
	/// @readonly
	WidgetFocused = undefined;

	/// @var {Struct.GUI_Widget}
	/// @readonly
	WidgetDragged = undefined;

	/// @var {Struct.GUI_Widget}
	/// @readonly
	WidgetPressed = undefined;

	/// @var {Real}
	/// @readonly
	MouseLastX = 0;

	/// @var {Real}
	/// @readonly
	MouseLastY = 0;

	/// @var {Real}
	/// @readonly
	MousePressX = 0;

	/// @var {Real}
	/// @readonly
	MousePressY = 0;

	/// @var {Real}
	/// @readonly
	MouseLocked = false;

	/// @var {Real}
	/// @readonly
	MouseLockX = 0;

	/// @var {Real}
	/// @readonly
	MouseLockY = 0;

	/// @var {Real}
	DragThreshold = 3;

	/// @var {Real, Undefined}
	DoubleClickTime = undefined;

	/// @var {Real}
	DoubleClickDelay = 500;

	/// @var {Real}
	DoubleClickCount = 0;

	/// @var {Real}
	DoubleClickX = undefined;

	/// @var {Real}
	DoubleClickY = undefined;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? "100%"
	);

	/// @var {Struct.GUI_Tooltip}
	Tooltip = _props[$ "Tooltip"] ?? new GUI_Tooltip();

	/// @var {Constant.Cursor}
	Cursor = cr_default;

	/// @func LockCursor()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Root} Returns `self`.
	static LockCursor = function () {
		if (!MouseLocked)
		{
			MouseLockX = window_mouse_get_x();
			MouseLockY = window_mouse_get_y();
			MouseLocked = true;
		}
		return self;
	};

	/// @func UnlockCursor()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Root} Returns `self`.
	static UnlockCursor = function () {
		if (MouseLocked)
		{
			MouseLocked = false;
		}
		return self;
	};

	static Widget_Layout = Layout;

	static Layout = function (_force=false) {
		SetProps({
			RealX: X,
			RealY: Y,
			RealWidth: (WidthUnit == "px") ? Width : (window_get_width() * (Width / 100.0)),
			RealHeight: (HeightUnit == "px") ? Height : (window_get_height() * (Height / 100.0)),
		});
		Widget_Layout(_force);
		return self;
	};

	static Update = function () {
		Cursor = MouseLocked ? cr_none : cr_default;

		var _mouseX = window_mouse_get_x();
		var _mouseY = window_mouse_get_y();
		var _mouseLastX = MouseLastX;
		var _mouseLastY = MouseLastY;

		static _updateStack = ds_stack_create();
		ds_stack_push(_updateStack, self);

		while (!ds_stack_empty(_updateStack))
		{
			with (ds_stack_pop(_updateStack))
			{
				var _children = Children;
				var i = 0;
				repeat (array_length(_children))
				{
					with (_children[i++])
					{
						Update();
						ds_stack_push(_updateStack, self);
					}
				}
			}
		}

		if (WidgetDragged != undefined)
		{
			with (WidgetDragged)
			{
				if (mouse_check_button(mb_left))
				{
					if (OnDrag)
					{
						OnDrag(self, _mouseX - _mouseLastX, _mouseY - _mouseLastY);
					}
				}
				else
				{
					DragEnd();
				}
			}
		}

		var _widgetHovered = FindWidgetAt(_mouseX, _mouseY, false);
		if (_widgetHovered == self
			|| (WidgetDragged && _widgetHovered != WidgetDragged))
		{
			_widgetHovered = undefined;
		}

		if (WidgetHovered != _widgetHovered)
		{
			var _widgetHoveredPrev = WidgetHovered;
			WidgetHovered = _widgetHovered;

			if (_widgetHoveredPrev
				&& _widgetHoveredPrev.OnMouseLeave)
			{
				_widgetHoveredPrev.OnMouseLeave(WidgetHovered);
			}

			if (WidgetHovered
				&& WidgetHovered.OnMouseEnter)
			{
				WidgetHovered.OnMouseEnter(WidgetHovered);
			}
		}

		if (mouse_check_button_pressed(mb_left))
		{
			if (WidgetHovered)
			{
				if (WidgetHovered.OnPress)
				{
					WidgetHovered.OnPress(WidgetHovered);
				}
				WidgetHovered.TriggerEvent(new GUI_Event("Press"));
				WidgetPressed = WidgetHovered;
				MousePressX = _mouseX;
				MousePressY = _mouseY;
			}

			if (DoubleClickTime == undefined
				|| current_time > DoubleClickTime + DoubleClickDelay)
			{
				DoubleClickTime = current_time;
				DoubleClickCount = 1;
				DoubleClickX = _mouseX;
				DoubleClickY = _mouseY;
			}
			else if (point_distance(_mouseX, _mouseY, DoubleClickX, DoubleClickY) < DragThreshold)
			{
				++DoubleClickCount;
			}
		}

		if (WidgetPressed)
		{
			if (mouse_check_button(mb_left))
			{
				if (!WidgetFocused
					&& WidgetPressed.Draggable
					&& !WidgetDragged
					&& point_distance(_mouseX, _mouseY, MousePressX, MousePressY) >= DragThreshold)
				{
					WidgetPressed.DragStart(WidgetPressed);
					WidgetPressed.TriggerEvent(new GUI_Event("DragStart"));
				}
			}
			else
			{
				if (point_distance(_mouseX, _mouseY, MousePressX, MousePressY) < DragThreshold)
				{
					var _doubleClicked = false;

					if (DoubleClickCount == 2)
					{
						if (WidgetPressed.OnDoubleClick)
						{
							WidgetPressed.OnDoubleClick(WidgetPressed);
							_doubleClicked = true;
						}
						DoubleClickTime = undefined;
					}

					if (!_doubleClicked)
					{
						if (WidgetPressed.OnClick)
						{
							WidgetPressed.OnClick(WidgetPressed);
						}
						WidgetPressed.TriggerEvent(new GUI_Event("Click"));
					}
				}

				if (WidgetPressed.OnRelease)
				{
					WidgetPressed.OnRelease(WidgetPressed);
				}

				WidgetPressed = undefined;
			}
		}

		if (MouseLocked)
		{
			window_mouse_set(MouseLockX, MouseLockY);
			MouseLastX = MouseLockX;
			MouseLastY = MouseLockY;
		}
		else
		{
			MouseLastX = _mouseX;
			MouseLastY = _mouseY;
		}

		CheckPropChanges();
		Layout();

		if (window_get_cursor() != Cursor)
		{
			window_set_cursor(Cursor);
		}

		return self;
	};

	static Draw = function () {
		if (Visible)
		{
			DrawBackground();
			DrawChildren();
			//DrawDebug();
			if (WidgetHovered && !WidgetDragged)
			{
				Tooltip.Text = WidgetHovered.Tooltip;
				Tooltip.X = window_mouse_get_x();
				Tooltip.Y = window_mouse_get_y();
				Tooltip.Draw();
			}
		}
		return self;
	};
}
