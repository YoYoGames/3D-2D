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

	/// @var {Bool}
	Active = _props[$ "Active"] ?? false;

	/// @var {Bool} If `true` then the background sprite is not visible when the
	/// button is not pressed or the mouse is not over. Default value is `false`.
	Minimal = _props[$ "Minimal"] ?? false;

	/// @var {Asset.GMSprite}
	BackgroundSprite = GUI_StructGet(_props, "BackgroundSprite", GUI_SprButton);

	/// @var {Real}
	BackgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;

	SetSize(
		_props[$ "Width"] ?? GUI_LINE_HEIGHT,
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	static Widget_Update = Update;

	static Update = function () {
		Widget_Update();
		BackgroundSubimage = ((Active || Root.WidgetPressed == self) ? 2
			: (IsMouseOver() ? 1 : 0));
		return self;
	};

	static Draw = function () {
		if (BackgroundSprite != undefined
			&& (!Minimal || BackgroundSubimage > 0))
		{
			draw_sprite_stretched(BackgroundSprite, BackgroundSubimage,
				RealX, RealY, RealWidth, RealHeight);
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
