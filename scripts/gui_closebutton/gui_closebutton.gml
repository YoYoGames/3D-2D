/// @func GUI_CloseButton([_props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
function GUI_CloseButton(_props={})
	: GUI_Widget(_props) constructor
{
	MaxChildCount = 0;

	/// @var {Asset.GMSprite}
	Sprite = _props[$ "Sprite"] ?? GUI_SprCloseButton;

	/// @var {Real}
	Subimage = _props[$ "Subimage"] ?? 0;

	SetSize(
		_props[$ "Width"] ?? sprite_get_width(Sprite),
		_props[$ "Height"] ?? sprite_get_height(Sprite)
	);

	static Draw = function () {
		var _spriteWidth = sprite_get_width(Sprite);
		var _spriteHeight = sprite_get_height(Sprite);
		draw_sprite_ext(
			Sprite, Subimage + (IsMouseOver() ? 1 : 0),
			RealX + floor((RealWidth - _spriteWidth) * 0.5),
			RealY + floor((RealHeight - _spriteHeight) * 0.5),
			1.0, 1.0, 0,
			IsDisabled() ? c_dkgray : c_white, 1.0);
		return self;
	};
}
