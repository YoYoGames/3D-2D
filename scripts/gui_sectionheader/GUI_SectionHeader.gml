/// @func GUI_SectionHeader(_text[, _props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {String} _text
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_SectionHeader(_text, _props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {String}
	Text = _text;

	/// @var {Bool}
	/// @readonly
	Collapsed = _props[$ "Collapsed"] ?? false;

	/// @var {Struct.GUI_Widget}
	/// @readonly
	Target = GUI_StructGet(_props, "Target");

	if (Target)
	{
		Target.SetProps({
			Visible: !Collapsed,
		});
	}

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? #BEBEBE;

	/// @var {Asset.GMSprite}
	SpriteCaret = _props[$ "SpriteCaret"] ?? GUI_SprSectionHeaderCaret;

	/// @var {Asset.GMSprite}
	BackgroundSprite = GUI_StructGet(_props, "BackgroundSprite", GUI_SprSectionHeader);

	/// @var {Real}
	BackgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? (BackgroundSprite != undefined
			? sprite_get_height(BackgroundSprite)
			: GUI_LINE_HEIGHT),
	);

	OnClick = function () {
		SetProps({
			Collapsed: !Collapsed,
		});
		if (Target)
		{
			Target.SetProps({
				Visible: !Collapsed,
			});
		}
	};

	static Draw = function () {
		if (BackgroundSprite != undefined)
		{
			draw_sprite_stretched(BackgroundSprite, BackgroundSubimage,
				RealX, RealY, RealWidth, RealHeight);
		}

		var _caretWidth = sprite_get_width(SpriteCaret);
		var _caretHeight = sprite_get_height(SpriteCaret);
		draw_sprite(SpriteCaret, Collapsed, RealX + 5, RealY + floor((RealHeight - _caretHeight) * 0.5));

		draw_text_color(
			RealX + 5 + _caretWidth + 7,
			RealY + floor((RealHeight - GUI_FONT_HEIGHT) * 0.5),
			Text,
			Color, Color, Color, Color, 1.0);

		DrawChildren();

		return self;
	};
}
