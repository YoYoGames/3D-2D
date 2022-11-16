/// @func GUI_VBox([_props[, _children]])
///
/// @extends GUI_FlexLayout
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_VBox(_props={}, _children=[])
	: GUI_FlexLayout(_props, _children) constructor
{
	FlexDirection = "column";

	Height = "auto";
}
