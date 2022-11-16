/// @func GUI_HueSlider([_props])
///
/// @extends GUI_VSlider
///
/// @desc
///
/// @param {Struct} [_props]
function GUI_HueSlider(_props={})
	: GUI_VSlider(0, 255, _props) constructor
{
	SetSize(
		sprite_get_width(GUI_SprHueSlider),
		sprite_get_height(GUI_SprHueSlider)
	);

	OnChange = function (_value) {
		Parent.SetProps({
			Hue: _value,
		});
		Arrow.SetProps({
			Y: RealHeight * (1.0 - (_value / 255.0)),
		});
	};

	Arrow = new GUI_HueSliderArrow();
	Add(Arrow);

	static Draw = function () {
		draw_sprite(GUI_SprHueSlider, 0, RealX, RealY);
		DrawChildren();
		return self;
	};
}
