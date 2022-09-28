/// @func GUI_AccordionBody([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_AccordionBody(_props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	SetWidth(_props[$ "Width"] ?? "100%");

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
		var _bbox = GetBoundingBox();
		var _width = _bbox[2] - RealX;
		var _height = _bbox[3] - RealY;
		if (Parent.IsSelected)
		{
			GUI_DrawRectangle(RealX, RealY, _width, _height, BorderColorSelected);
			GUI_DrawRectangle(RealX + 2, RealY + 2, _width - 4, _height - 4, BackgroundColorSelected);
		}
		else
		{
			GUI_DrawRectangle(RealX, RealY, _width, _height, BackgroundColor);
		}
		DrawChildren();
		return self;
	};
}
