/// @func GUI_ContextMenuOption(_text[, _props])
///
/// @extends GUI_ContextMenuItem
///
/// @desc
///
/// @param {String} _text
/// @param {Struct} [_props]
function GUI_ContextMenuOption(_text, _props={})
	: GUI_ContextMenuItem(_props) constructor
{
	MaxChildCount = 0;

	/// @var {String}
	Text = _text;

	// TODO: Keyboard shortcut system

	/// @var {String}
	ShortcutText = GUI_StructGet(_props, "ShortcutText", "");

	/// @var {Function}
	Action = GUI_StructGet(_props, "Action");

	var _textWidth = string_width(Text);
	var _textHeight = string_height(Text);

	MinWidth = 4 + (_props[$ "MinWidth"] ?? _textWidth) + 16 + 4;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? (_textHeight + 2)
	);

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? c_white;

	/// @var {Constant.Color}
	ColorDisabled = _props[$ "ColorDisabled"] ?? #3E3E3E;

	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? #474D58;

	Disabled = function () {
		return (Action == undefined);
	};

	OnClick = function () {
		if (ContextMenu)
		{
			ContextMenu.RemoveSelf();
		}
		if (Action)
		{
			Action();
		}
	};

	static Draw = function () {
		if (IsMouseOver())
		{
			GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, BackgroundColor);
		}
		var _color = IsDisabled() ? ColorDisabled : Color;
		var _textY = RealY + floor((RealHeight - string_height(Text)) * 0.5);
		GUI_DrawText(RealX + 4, _textY, Text, _color);
		if (ShortcutText != "")
		{
			GUI_DrawText(RealX + RealWidth - string_width(ShortcutText) - 4, _textY, ShortcutText, _color);
		}
		return self;
	};
}
