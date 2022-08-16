/// @func GUI_Splitter([_props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
function GUI_Splitter(_props={})
	: GUI_Widget(_props) constructor
{
	/// @var {Real}
	Split = _props[$ "Split"] ?? 0.5;

	/// @var {Real}
	Size = _props[$ "Size"] ?? 4; //floor(GUI_LINE_HEIGHT) / 2;

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? #171717;

	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? #101010;

	/// @var {Real}
	BackgroundAlpha = _props[$ "BackgroundAlpha"] ?? 1.0;

	MaxChildCount = 2;

	/// @var {Real}
	/// @ignore
	MouseOffset = 0;
}
