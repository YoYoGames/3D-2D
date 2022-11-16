/// @func GUI_HueSliderArrow([_props[, _children]])
///
/// @extends GUI_SliderArrow
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_HueSliderArrow(_props={}, _children=[])
	: GUI_SliderArrow(_props, _children) constructor
{
	PivotTop = _props[$ "PivotTop"] ?? -0.5;

	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprHueSliderArrow;

	X = _props[$ "X"] ?? -sprite_get_xoffset(BackgroundSprite);

	SetSize(
		_props[$ "Width"] ?? sprite_get_width(BackgroundSprite),
		_props[$ "Height"] ?? sprite_get_height(BackgroundSprite)
	);

	OnPress = function () {
		MouseOffset = window_mouse_get_y() - (RealY - (RealHeight * PivotTop) - Parent.RealY);
		DragStart();
	};

	static SliderArrow_Update = Update;

	static Update = function () {
		SliderArrow_Update();
		if (IsDragged())
		{
			if (mouse_check_button(mb_left))
			{
				SetProps({
					Y: clamp(window_mouse_get_y() - MouseOffset, 0, Parent.RealHeight),
				});
				Parent.OnChange((1.0 - (Y / Parent.RealHeight)) * 255.0, Parent.Value);
			}
			else
			{
				DragEnd();
			}
		}
		return self;
	};
}
