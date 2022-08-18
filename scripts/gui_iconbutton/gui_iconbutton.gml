/// @func GUI_IconButton(_sprite[, _subimage[, _props]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Asset.GMSprite} _sprite
/// @param {Real} [_subimage]
/// @param {Struct} [_props]
function GUI_IconButton(_sprite, _subimage=0, _props={})
	: GUI_Widget(_props) constructor
{
	MaxChildCount = 0;

	/// @var {Asset.GMSprite}
	Sprite = _sprite;

	/// @var {Real}
	Subimage = _subimage;

	/// @var {Bool}
	Active = _props[$ "Active"] ?? false;

	/// @var {Bool} If `true` then the background sprite is not visible when the
	/// button is not pressed or the mouse is not over. Default value is `false`.
	Minimal = _props[$ "Minimal"] ?? false;

	/// @var {Asset.GMSprite}
	BackgroundSprite = GUI_StructGet(_props, "BackgroundSprite", GUI_SprButton);

	/// @var {Real}
	BackgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;

	SetSize(
		_props[$ "Width"] ?? GUI_LINE_HEIGHT,
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	static Widget_Update = Update;

	static Update = function () {
		Widget_Update();
		BackgroundSubimage = ((Active || Root.WidgetPressed == self) ? 2
			: (IsMouseOver() ? 1 : 0));
		return self;
	};

	static Draw = function () {
		if (BackgroundSprite != undefined
			&& (!Minimal || BackgroundSubimage > 0))
		{
			draw_sprite_stretched(BackgroundSprite, BackgroundSubimage,
				RealX, RealY, RealWidth, RealHeight);
		}
		var _spriteWidth = sprite_get_width(Sprite);
		var _spriteHeight = sprite_get_height(Sprite);
		draw_sprite_ext(
			Sprite, Subimage,
			RealX + floor((RealWidth - _spriteWidth) * 0.5),
			RealY + floor((RealHeight - _spriteHeight) * 0.5),
			1.0, 1.0, 0,
			IsDisabled() ? c_dkgray : c_white, 1.0);
		return self;
	};
}
