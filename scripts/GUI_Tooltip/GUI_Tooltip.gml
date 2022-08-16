/// @func GUI_Tooltip()
///
/// @desc
///
/// @param {Struct} [_props]
function GUI_Tooltip(_props={}) constructor
{
	/// @var {String}
	Text = "";

	/// @var {Real}
	X = 0;

	/// @var {Real}
	Y = 0;

	/// @var {Real}
	OffsetX = _props[$ "OffsetX"] ?? 16;

	/// @var {Real}
	OffsetY = _props[$ "OffsetY"] ?? 16;

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? c_black;

	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? #EADBB2;

	/// @var {Real}
	BackgroundAlpha = _props[$ "BackgroundAlpha"] ?? 1.0;

	/// @func Draw()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Tooltip} Returns `self`.
	static Draw = function () {
		if (Text != "")
		{
			var _paddingX = 8;
			var _paddingY = 4;
			var _width = string_width(Text) + _paddingX * 2;
			var _height = string_height(Text) + _paddingY * 2;
			var _x = clamp(X + OffsetX, 0, window_get_width() - _width);
			var _y = clamp(Y + OffsetY, 0, window_get_height() - _height);
			GUI_DrawRectangle(_x, _y, _width, _height, BackgroundColor, BackgroundAlpha);
			draw_text_color(_x + _paddingX, _y + _paddingY, Text,
				Color, Color, Color, Color, 1.0);
		}
		return self;
	};
}
