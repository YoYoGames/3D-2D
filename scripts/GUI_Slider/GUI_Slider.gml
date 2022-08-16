/// @func GUI_Slider(_min, _max[, _props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Real} _min
/// @param {Real} _max
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Slider(_min, _max, _props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {Real}
	/// @readonly
	Min = _min;

	/// @var {Real}
	/// @readonly
	Max = _max;

	/// @var {Real}
	/// @readonly
	Value = clamp(_props[$ "Value"] ?? _min, _min, _max);

	/// @var {Bool}
	/// @readonly
	WholeNumbers = _props[$ "WholeNumbers"] ?? false;

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? c_white;

	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? c_dkgray;

	/// @var {Real}
	BackgroundAlpha = _props[$ "BackgroundAlpha"] ?? 1.0;

	OnPress = function () {
		DragStart();
	};
}
