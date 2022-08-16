/// @func GUI_ColorButtton(_color[, _props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} _color
/// @param {Struct} [_props]
function GUI_ColorButton(_color, _props={})
	: GUI_Widget(_props) constructor
{
	MaxChildCount = 0;

	/// @var {Struct}
	Color = _color;

	SetSize(
		_props[$ "Width"] ?? GUI_LINE_HEIGHT,
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	static Draw = function () {
		if (Color)
		{
			draw_sprite_stretched(GUI_SprCheckerboard, 0, RealX, RealY, RealWidth, RealHeight);
			var _color = make_color_rgb(Color.Red, Color.Green, Color.Blue);
			GUI_DrawRectangle(RealX + 1, RealY + 1, RealWidth - 2, RealHeight - 2, _color, Color.Alpha);
		}
		draw_sprite_stretched(GUI_SprColorButton, 0, RealX, RealY, RealWidth, RealHeight);
		DrawChildren();
		return self;
	};
}
