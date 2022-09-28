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
	MaxChildCount = 0;

	SetSize(
		sprite_get_width(GUI_SprHueSlider),
		sprite_get_height(GUI_SprHueSlider)
	);

	OnChange = function (_value) {
		Parent.SetProps({
			Hue: _value,
		});
	};

	static Draw = function () {
		draw_sprite(GUI_SprHueSlider, 0, RealX, RealY);
		draw_sprite(GUI_SprHueSliderArrow, 0, RealX, RealY + (1.0 - (Parent.Hue / 255.0)) * RealHeight);
		return self;
	};
}
