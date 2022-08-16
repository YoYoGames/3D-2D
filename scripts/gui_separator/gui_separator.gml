/// @func GUI_Separator([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Separator(_props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? #1F1F1F;

	/// @var {Real}
	BackgroundAlpha = _props[$ "BackgroundAlpha"] ?? 1.0;

	static Draw = function () {
		GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, BackgroundColor, BackgroundAlpha);
		DrawChildren();
		return self;
	};
}
