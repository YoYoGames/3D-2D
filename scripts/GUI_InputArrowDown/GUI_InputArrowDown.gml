/// @func GUI_InputArrowDown([_props[, _children]])
///
/// @extends GUI_InputArrow
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_InputArrowDown(_props={}, _children=[])
	: GUI_InputArrow(_props, _children) constructor
{
	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprInputArrowDown;

	SetSize(
		_props[$ "Width"] ?? sprite_get_width(BackgroundSprite),
		_props[$ "Height"] ?? sprite_get_height(BackgroundSprite)
	);
}
