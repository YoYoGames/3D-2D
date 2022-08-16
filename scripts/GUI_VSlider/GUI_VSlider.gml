/// @func GUI_VSlider(_min, _max[, _props[, _children]])
///
/// @extends GUI_Slider
///
/// @desc
///
/// @param {Real} _min
/// @param {Real} _max
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_VSlider(_min, _max, _props={}, _children=[])
	: GUI_Slider(_min, _max, _props, _children) constructor
{
	SetSize(
		_props[$ "Width"] ?? GUI_LINE_HEIGHT,
		_props[$ "Height"] ?? 200
	);

	static Slider_Update = Update;

	static Update = function () {
		Slider_Update();
		if (IsDragged())
		{
			var _valueOld = Value;
			var _value = lerp(Max, Min, clamp((window_mouse_get_y() - RealY) / RealHeight, 0.0, 1.0));
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
		var _height = RealHeight - ((Value - Min) / (Max - Min)) * RealHeight;
		if (_height < RealHeight)
		{
			GUI_DrawRectangle(RealX, RealY + _height, RealWidth, RealHeight - _height, Color);
		}
		Slider_Draw();
		return self;
	};
}
