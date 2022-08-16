/// @func GUI_DropdownOption(_text[, _props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {String} _text
/// @param {Struct} [_props]
function GUI_DropdownOption(_text, _props={})
	: GUI_Widget(_props) constructor
{
	MaxChildCount = 0;

	/// @var {Struct.GUI_Dropdown}
	/// @readonly
	Dropdown = undefined;

	/// @var {String}
	/// @readonly
	Text = _text;

	/// @var {Mixed}
	/// @readonly
	Value = _props[$ "Value"] ?? Text;

	/// @var {Bool}
	/// @readonly
	IsDefault = _props[$ "IsDefault"] ?? false;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? (GUI_FONT_HEIGHT + 8)
	);

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? c_white;

	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? c_black;

	/// @var {Constant.Color}
	BackgroundAlpha = _props[$ "BackgroundAlpha"] ?? 0.0;

	OnClick = function () {
		Select();
	};

	/// @func IsSelected()
	///
	/// @desc
	///
	/// @return {Bool}
	static IsSelected = function () {
		gml_pragma("forceinline");
		return (Dropdown.Selected == self);
	};

	/// @func Select()
	///
	/// @desc
	///
	/// @return {Struct.GUI_DropdownOption} Returns `self`.
	static Select = function () {
		Dropdown.Select(self);
		return self;
	};

	static Draw = function () {
		var _isMouseOver = IsMouseOver();
		if (IsSelected() || _isMouseOver)
		{
			GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, _isMouseOver ? #8993A0 : #616B78, 1.0);
		}
		draw_text_color(RealX + 7, RealY + round((RealHeight - GUI_FONT_HEIGHT) * 0.5),
			Text, Color, Color, Color, Color, 1.0);
		return self;
	};
}
