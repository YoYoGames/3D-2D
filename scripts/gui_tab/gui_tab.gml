/// @func GUI_Tab(_text[, _props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {String} _text
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Tab(_text, _props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {String}
	Text = _text;

	/// @var {Bool}
	/// @readonly
	IsSelected = _props[$ "IsSelected"] ?? false;

	/// @var {Struct.GUI_Widget}
	/// @readonly
	Target = GUI_StructGet(_props, "Target");

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	if (Target)
	{
		Target.SetProps({
			"Visible": IsSelected,
		});
	}

	OnClick = function () {
		Select();
	};

	/// @func Select()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Tab} Returns `self`.
	static Select = function () {
		if (Parent && variable_struct_exists(Parent, "Selected"))
		{
			if (Parent.Selected)
			{
				Parent.Selected.Unselect();
			}
			var _self = self;
			Parent.SetProps({
				"Selected": _self,
			});
		}
		SetProps({ "IsSelected": true });
		if (Target)
		{
			Target.SetProps({
				"Visible": true,
			});
		}
		return self;
	};

	/// @func Unselect()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Tab} Returns `self`.
	static Unselect = function () {
		if (Parent && variable_struct_exists(Parent, "Selected") && Parent.Selected == self)
		{
			Parent.Selected.SetProps({ "IsSelected": false });
			Parent.SetProps({ "Selected": undefined });
		}
		SetProps({ "IsSelected": false });
		if (Target)
		{
			Target.SetProps({
				"Visible": false,
			});
		}
		return self;
	};

	static Draw = function () {
		// TODO: Make tab font and color configurable
		var _font = draw_get_font();
		if (IsSelected)
		{
			GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, #1C8395);
			draw_set_font(ST_FntOpenSans12Bold);
		}
		else
		{
			draw_set_font(ST_FntOpenSans12);
		}
		var _text = GUI_GetTextPartLeft(Text, RealWidth);
		var _textX = RealX + floor((RealWidth - string_width(_text)) * 0.5);
		var _textY = RealY + floor((RealHeight - string_height(_text)) * 0.5);
		draw_text_color(_textX, _textY, _text, c_white, c_white, c_white, c_white, 1.0);
		draw_set_font(_font);
		DrawChildren();
		return self;
	};
}
