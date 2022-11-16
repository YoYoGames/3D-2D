/// @func GUI_Checkbox(_value[, _props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Bool} _value
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Checkbox(_value, _props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {Bool}
	Value = _value;

	/// @var {Asset.GMSprite}
	Sprite = _props[$ "Sprite"] ?? GUI_SprCheckbox;

	SetSize(
		sprite_get_width(Sprite),
		sprite_get_height(Sprite)
	);

	OnClick = function () {
		SetProps({
			Value: !Value,
		});
		if (OnChange)
		{
			OnChange(Value, !Value);
		}
	};

	static Draw = function () {
		draw_sprite(Sprite, (Value * 2) + (IsMouseOver() ? 1 : 0), RealX, RealY);
		if (IsDisabled())
		{
			GUI_DrawRectangle(RealX + 1, RealY + 1, sprite_get_width(Sprite) - 4, sprite_get_height(Sprite) - 4, c_black, 0.5);
		}
		DrawChildren();
		return self;
	};
}
