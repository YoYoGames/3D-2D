/// @func GUI_Button(_text[, _props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {String} _text
/// @param {Struct} [_props]
function GUI_Button(_text, _props={})
	: GUI_Widget(_props) constructor
{
	MaxChildCount = 0;

	/// @var {String}
	Text = _text;

	SetSize(
		_props[$ "Width"] ?? (string_width(Text) + 16),
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? #BEBEBE;

	/// @var {Constant.Color}
	ColorDisabled = _props[$ "ColorDisabled"] ?? c_gray;

	/// @var {Asset.GMSprite}
	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprButton;

	/// @var {Real}
	BackgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;

	static Draw = function () {
		// Background
		draw_sprite_stretched(BackgroundSprite, BackgroundSubimage,
			RealX, RealY, RealWidth, RealHeight);

		// Text
		var _color = IsDisabled() ? ColorDisabled : Color;
		draw_text_color(
			round(RealX + (RealWidth - string_width(Text)) * 0.5),
			round(RealY + (RealHeight - string_height(Text)) * 0.5),
			Text,
			_color, _color, _color, _color, 1.0);

		DrawChildren();
		return self;
	};
}
