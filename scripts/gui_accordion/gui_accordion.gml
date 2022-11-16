/// @func GUI_Accordion([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_AccordionItem>} [_children]
function GUI_Accordion(_props={}, _children=[])
	: GUI_FlexLayout(_props, _children) constructor
{
	FlexDirection = _props[$ "FlexDirection"] ?? "column";

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? "auto"
	);
}
