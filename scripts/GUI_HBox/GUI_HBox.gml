/// @func GUI_HBox([_props[, _children]])
///
/// @extends GUI_FlexLayout
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_HBox(_props={}, _children=[])
	: GUI_FlexLayout(_props, _children) constructor
{
	FlexDirection = "row";

	Width = "auto";
}
