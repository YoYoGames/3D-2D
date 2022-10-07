/// @func GUI_AlphaSlider([_props[, _children]])
///
/// @extends GUI_HSlider
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_AlphaSlider(_props={}, _children=[])
	: GUI_HSlider(0.0, 1.0, _props, _children) constructor
{
	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? c_white;

	SetSize(
		sprite_get_width(GUI_SprAlphaSlider),
		sprite_get_height(GUI_SprAlphaSlider)
	);

	OnChange = function (_value) {
		Parent.SetProps({
			Alpha: _value,
		});
		Arrow.SetProps({
			X: RealWidth * _value,
		});
	};

	Arrow = new GUI_AlphaSliderArrow();
	Add(Arrow);

	static Draw = function () {
		draw_sprite(GUI_SprAlphaSlider, 0, RealX, RealY);
		draw_sprite_ext(GUI_SprAlphaSlider, 1, RealX, RealY, 1.0, 1.0, 0, Color, 1.0);
		DrawChildren();
		return self;
	};
}
