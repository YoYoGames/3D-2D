/// @func GUI_AccordionBody([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_AccordionBody(_props={}, _children=[])
	: GUI_FlexLayout(_props, _children) constructor
{
	FlexDirection = _props[$ "FlexDirection"] ?? "column";

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? "auto"
	);

	/// @var {Constant.Color}
	BorderColorSelected = _props[$ "BorderColorSelected"] ?? #1c8395;

	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? #383B40;

	/// @var {Constant.Color}
	BackgroundColorSelected = _props[$ "BackgroundColor"] ?? #43474D;

	OnClick = function () {
		Parent.SetProps({
			IsSelected: true,
		});
	};

	static Draw = function () {
		if (Parent.IsSelected)
		{
			GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, BorderColorSelected);
			GUI_DrawRectangle(RealX + 2, RealY + 2, RealWidth - 4, RealHeight - 4, BackgroundColorSelected);
		}
		else
		{
			GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, BackgroundColor);
		}
		DrawChildren();
		return self;
	};
}
