/// @func GUI_Text(_text[, _props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {String} _text
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Text(_text, _props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {String}
	Text = _text;

	SetSize(
		_props[$ "Width"] ?? string_width(Text),
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? #BEBEBE;

	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? c_black;

	/// @var {Real}
	BackgroundAlpha = _props[$ "BackgroundAlpha"] ?? 0.0;

	static Draw = function () {
		GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, BackgroundColor, BackgroundAlpha);
		draw_text_color(
			RealX,
			RealY + floor((RealHeight - GUI_FONT_HEIGHT) * 0.5),
			Text, Color, Color, Color, Color, 1.0);
		DrawChildren();
		return self;
	};
}
