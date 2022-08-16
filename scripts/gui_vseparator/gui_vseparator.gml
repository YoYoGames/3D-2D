/// @func GUI_VSeparator([_props[, _children]])
///
/// @extends GUI_Separator
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_VSeparator(_props={}, _children=[])
	: GUI_Separator(_props, _children) constructor
{
	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? 2
	);
}
