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
	: GUI_FlexLayout(_props, _children) constructor
{
	/// @var {Struct.GUI_IconButton}
	Caret = new GUI_IconButton(GUI_SprSectionHeaderCaret, 0, {
		BackgroundSprite: undefined,
		OnPress: method(self, function (_caret) {
			SetProps({ Collapsed: !Collapsed });
			_caret.SetProps({ Subimage: Collapsed ? 1 : 0 });

			if (Target)
			{
				Target.SetProps({
					Visible: !Collapsed,
				});
			}
		}),
	});
	Add(Caret);

	/// @var {Struct.GUI_Text}
	Text = new GUI_Text(_text, {
		FlexGrow: 1,
	});
	Add(Text);

	/// @var {Bool}
	/// @readonly
	Collapsed = _props[$ "Collapsed"] ?? false;

	Caret.Subimage = Collapsed ? 1 : 0;

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
	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprAccordionHeader;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? sprite_get_height(BackgroundSprite)
	);

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

		draw_sprite_stretched(BackgroundSprite, _backgroundIndex + (Parent.IsSelected * 3),
			RealX, RealY, RealWidth, RealHeight);

		DrawChildren();

		return self;
	};
}
