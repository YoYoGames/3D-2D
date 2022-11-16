/// @func GUI_SelectListItem(_text[, _props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {String} _text
/// @param {Struct} [_props]
function GUI_SelectListItem(_text, _props={})
	: GUI_Widget(_props) constructor
{
	/// @var {String}
	Text = _text;

	/// @var {Real}
	TextX = _props[$ "TextX"] ?? 10;

	/// @var {Struct.GUI_Widget}
	Target = GUI_StructGet(_props, "Target");

	/// @var {Bool}
	IsLight = _props[$ "Light"] ?? false;

	/// @var {Bool}
	IsSelected = _props[$ "IsSelected"] ?? false;

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? #BFBFBF;

	/// @var {Constant.Color}
	BackgroundColorLight = _props[$ "BackgroundColorLight"] ?? #222222;

	/// @var {Constant.Color}
	BackgroundColorDark = _props[$ "BackgroundColorDark"] ?? #1E1E1E;

	/// @var {Constant.Color}
	BackgroundColorSelected = _props[$ "BackgroundColorSelected"] ?? #4B525C;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? 22
	);

	MinWidth = _props[$ "MinWidth"] ?? 10 + string_width(Text);

	static Draw = function () {
		GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight,
			IsSelected ? BackgroundColorSelected
				: (IsLight ? BackgroundColorLight : BackgroundColorDark));
		draw_text_color(RealX + TextX, RealY + floor((RealHeight - GUI_FONT_HEIGHT) * 0.5),
			Text, Color, Color, Color, Color, 1.0);
		return self;
	};
}
