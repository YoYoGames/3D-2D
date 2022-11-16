/// @func GUI_AccordionItem([_props[, _children])
///
/// @extends GUI_VBox
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_AccordionHeader, Struct.GUI_AccordionBody>} [_children]
function GUI_AccordionItem(_props={}, _children=[])
	: GUI_FlexLayout(_props, _children) constructor
{
	MaxChildCount = 2;

	FlexDirection = _props[$ "FlexDirection"] ?? "column";

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? "auto"
	);

	/// @var {Bool}
	/// @readonly
	IsSelected = false;

	static OnHighlight = function (_event) {
		_event.Bubble = false;
		var _siblings = Parent.Children;
		for (var i = array_length(_siblings) - 1; i >= 0; --i)
		{
			_siblings[i].SetProps({ IsSelected: false });
		}
		SetProps({ IsSelected: true });
	};

	AddEventListener("Click", OnHighlight);
	AddEventListener("Press", OnHighlight);
	AddEventListener("DragStart", OnHighlight);
	AddEventListener("Focus", OnHighlight);
}
