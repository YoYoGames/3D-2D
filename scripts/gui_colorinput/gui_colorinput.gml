/// @func GUI_ColorInput(_color[, _props])
///
/// @extends GUI_ColorButton
///
/// @desc
///
/// @param {Struct} _color
/// @param {Struct} [_props]
function GUI_ColorInput(_color, _props={})
	: GUI_ColorButton(_color, _props) constructor
{
	MaxChildCount = 0;

	OnClick = function () {
		if (Root)
		{
			var _colorPicker = new GUI_ColorPicker(Color, {
				X: window_mouse_get_x() + 24,
				Y: window_mouse_get_y() - 24,
			});
			_colorPicker.X = clamp(_colorPicker.X, 0, window_get_width() - _colorPicker.Width);
			_colorPicker.Y = clamp(_colorPicker.Y, 0, window_get_height() - _colorPicker.Height);
			Root.Add(_colorPicker);
		}
	};
}
