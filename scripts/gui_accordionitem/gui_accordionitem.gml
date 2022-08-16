/// @func GUI_AccordionItem([_props[, _children])
///
/// @extends GUI_VBox
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_AccordionHeader, Struct.GUI_AccordionBody>} [_children]
function GUI_AccordionItem(_props={}, _children=[])
	: GUI_VBox(_props, _children) constructor
{
	MaxChildCount = 2;

	SetWidth(_props[$ "Width"] ?? "100%");

	/// @var {Bool}
	/// @readonly
	IsSelected = false;
}
