/// @func GUI_GlyphButton(_glyph[, _props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {String, Real} _glyph
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_GlyphButton(_glyph, _props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {String, Real}
	Glyph = _glyph;

	/// @var {Asset.GMFont}
	Font = _props[$ "Font"];

	/// @var {Asset.GMSprite}
	BackgroundSprite = GUI_StructGet(_props, "BackgroundSprite", GUI_SprButton);

	SetSize(
		_props[$ "Width"] ?? GUI_LINE_HEIGHT,
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	static Draw = function () {
		if (BackgroundSprite != undefined)
		{
			draw_sprite_stretched(BackgroundSprite, 0, RealX, RealY, RealWidth, RealHeight);
		}
		var _string = is_string(Glyph) ? Glyph : chr(Glyph);
		var _color = IsDisabled() ? c_dkgray : c_white;
		var _font = undefined;
		if (Font != undefined)
		{
			_font = draw_get_font();
			draw_set_font(Font);
		}
		draw_text_color(
			RealX + floor((RealWidth - string_width(_string)) * 0.5),
			RealY + floor((RealHeight - string_height(_string)) * 0.5),
			_string, _color, _color, _color, _color, 1.0);
		if (_font != undefined)
		{
			draw_set_font(_font);
		}
		DrawChildren();
		return self;
	};
}
