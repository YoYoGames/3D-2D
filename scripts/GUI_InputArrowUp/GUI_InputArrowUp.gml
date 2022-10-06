/// @func GUI_InputArrowUp([_props[, _children]])
///
/// @extends GUI_InputArrow
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_InputArrowUp(_props={}, _children=[])
	: GUI_InputArrow(_props, _children) constructor
{
	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprInputArrowUp;

	SetSize(
		_props[$ "Width"] ?? sprite_get_width(BackgroundSprite),
		_props[$ "Height"] ?? sprite_get_height(BackgroundSprite)
	);
}
