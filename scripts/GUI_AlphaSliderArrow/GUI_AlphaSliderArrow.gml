/// @func GUI_AlphaSliderArrow([_props[, _children]])
///
/// @extends GUI_SliderArrow
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_AlphaSliderArrow(_props={}, _children=[])
	: GUI_SliderArrow(_props, _children) constructor
{
	PivotLeft = _props[$ "PivotLeft"] ?? -0.5;

	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprAlphaSliderArrow;

	Y = _props[$ "Y"] ?? -sprite_get_yoffset(BackgroundSprite);

	SetSize(
		_props[$ "Width"] ?? sprite_get_width(BackgroundSprite),
		_props[$ "Height"] ?? sprite_get_height(BackgroundSprite)
	);

	OnPress = function () {
		MouseOffset = window_mouse_get_x() - (RealX - (RealWidth * PivotLeft) - Parent.RealX);
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
					X: clamp(window_mouse_get_x() - MouseOffset, 0, Parent.RealWidth),
				});
				Parent.OnChange(X / Parent.RealWidth, Parent.Value);
			}
			else
			{
				DragEnd();
			}
		}
		return self;
	};
}
