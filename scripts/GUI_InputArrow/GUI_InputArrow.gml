/// @func GUI_InputArrow([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_InputArrow(_props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	static Widget_Update = Update;

	static Update = function () {
		Widget_Update();
		SetProps({
			BackgroundSubimage: IsDisabled() ? 0 : (IsPressed() ? 3 : (IsMouseOver() ? 2 : 1)),
		});
		return self;
	};
}
