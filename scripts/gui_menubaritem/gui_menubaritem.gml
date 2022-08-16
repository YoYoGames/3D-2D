/// @func GUI_MenuBarItem(_text[, _props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {String} _text
/// @param {Struct} [_props]
function GUI_MenuBarItem(_text, _props={})
	: GUI_Widget(_props) constructor
{
	MaxChildCount = 0;

	/// @var {String}
	Text = _text;

	SetSize(
		_props[$ "Width"] ?? (string_width(Text) + 20),
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	/// @var {Struct.GUI_MenuBar/Undfined}
	/// @readonly
	MenuBar = undefined;

	/// @var {Struct.GUI_ContextMenu}
	/// @readonly
	Menu = GUI_StructGet(_props, "Menu");

	if (Menu)
	{
		Menu.Toggler = self;
	}

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? c_white;

	/// @var {Constant.Color}
	ColorDisabled = _props[$ "Color"] ?? c_gray;

	/// @var {Asset.GMSprite}
	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprMenuItem;

	Disabled = function () {
		return (Menu == undefined);
	};

	OnClick = function () {
		if (MenuBar)
		{
			if (MenuBar.Selected == self && Menu.Root)
			{
				MenuBar.SetProps({
					"Selected": undefined,
				});
				Menu.RemoveSelf();
			}
			else
			{
				var _self = self;
				MenuBar.SetProps({
					"Selected": _self,
				});
				Menu.X = RealX;
				Menu.Y = RealY + RealHeight;
				Root.Add(Menu);
			}
		}
	};

	OnMouseEnter = function () {
		if (MenuBar
			&& MenuBar.Selected
			&& MenuBar.Selected != self
			&& MenuBar.Selected.Menu.Root)
		{
			if (MenuBar.Selected)
			{
				MenuBar.Selected.Menu.RemoveSelf();
			}
			var _self = self;
			MenuBar.SetProps({
				"Selected": _self,
			});
			Menu.X = RealX;
			Menu.Y = RealY + RealHeight;
			Root.Add(Menu);
		}
	};

	static Draw = function () {
		if ((Menu && Menu.Root) || IsMouseOver())
		{
			draw_sprite_stretched(BackgroundSprite, 0, RealX, RealY, RealWidth, RealHeight);
		}
		var _color = IsDisabled() ? ColorDisabled : Color;
		draw_text_color(
			RealX + floor((RealWidth - string_width(Text)) * 0.5),
			RealY + floor((RealHeight - string_height(Text)) * 0.5),
			Text,
			_color, _color, _color, _color, 1.0);
		return self;
	};
}
