/// @func GUI_AccordionHeader(_text[, _props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {String} _text
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_AccordionHeader(_text, _props={}, _children=[])
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

	/// @var {Constant.Color}
	ColorSelected = _props[$ "Color"] ?? c_white;

	/// @var {Asset.GMSprite}
	SpriteCaret = _props[$ "SpriteCaret"] ?? GUI_SprSectionHeaderCaret;

	/// @var {Asset.GMSprite}
	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprAccordionHeader;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? sprite_get_height(BackgroundSprite)
	);

	OnClick = function () {
		var _caretWidth = sprite_get_width(SpriteCaret);
		if (window_mouse_get_x() < RealX + 5 + _caretWidth + 7)
		{
			SetProps({
				Collapsed: !Collapsed,
			});
			if (Target)
			{
				Target.SetProps({
					Visible: !Collapsed,
				});
			}
		}

		// TODO: Better way to do this?
		var _items = Parent.Parent.Children;
		var i = 0;
		repeat (array_length(_items))
		{
			with (_items[i++])
			{
				IsSelected = false;
			}
		}

		Parent.SetProps({
			IsSelected: true,
		});
	};

	static Draw = function () {
		var _items = Parent.Parent.Children;
		var _itemCount = array_length(_items);
		var _backgroundIndex = 1;
		if (_itemCount > 1)
		{
			if (_items[0] == Parent)
			{
				_backgroundIndex = 0;
			}
			else if (Collapsed && _items[_itemCount - 1] == Parent)
			{
				_backgroundIndex = 2;
			}
		}

		var _isSelected = Parent.IsSelected;

		draw_sprite_stretched(BackgroundSprite, _backgroundIndex + (_isSelected * 3), RealX, RealY, RealWidth, RealHeight);

		var _caretWidth = sprite_get_width(SpriteCaret);
		var _caretHeight = sprite_get_height(SpriteCaret);
		draw_sprite(SpriteCaret, Collapsed, RealX + 5, RealY + floor((RealHeight - _caretHeight) * 0.5));

		var _font;
		if (_isSelected)
		{
			_font = draw_get_font();
			// TODO: Make font configurable
			draw_set_font(ST_FntOpenSans10Bold);
		}

		var _color = _isSelected ? ColorSelected : Color;

		draw_text_color(
			RealX + 5 + _caretWidth + 7,
			RealY + floor((RealHeight - GUI_FONT_HEIGHT) * 0.5),
			Text,
			_color, _color, _color, _color, 1.0);

		if (_isSelected)
		{
			draw_set_font(_font);
		}

		DrawChildren();

		return self;
	};
}
