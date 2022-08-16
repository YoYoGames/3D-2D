/// @func GUI_HSlider(_min, _max[, _props[, _children]])
///
/// @extends GUI_Slider
///
/// @desc
///
/// @param {Real} _min
/// @param {Real} _max
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_HSlider(_min, _max, _props={}, _children=[])
	: GUI_Slider(_min, _max, _props, _children) constructor
{
	SetSize(
		_props[$ "Width"] ?? 200,
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	static Slider_Update = Update;

	static Update = function () {
		Slider_Update();
		if (IsDragged())
		{
			var _valueOld = Value;
			var _value = lerp(Min, Max, clamp((window_mouse_get_x() - RealX) / RealWidth, 0.0, 1.0));
			if (WholeNumbers)
			{
				_value = floor(_value);
			}
			if (_value != _valueOld)
			{
				SetProps({
					"Value": _value,
				});
				if (OnChange)
				{
					OnChange(_value, _valueOld);
				}
			}
			if (!device_mouse_check_button(0, mb_left))
			{
				Blur();
			}
		}
		return self;
	};

	static Slider_Draw = Draw;

	static Draw = function () {
		if (!Visible)
		{
			return self;
		}
		GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, BackgroundColor, BackgroundAlpha);
		var _width = ((Value - Min) / (Max - Min)) * RealWidth;
		if (_width > 0)
		{
			GUI_DrawRectangle(RealX, RealY, _width, RealHeight, Color);
		}
		Slider_Draw();
		return self;
	};
}
