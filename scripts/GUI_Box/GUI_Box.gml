/// @func GUI_Box([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Box(_props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {Real}
	Gap = _props[$ "Gap"] ?? 0;
}
