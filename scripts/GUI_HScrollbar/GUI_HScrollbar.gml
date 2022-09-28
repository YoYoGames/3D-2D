/// @func GUI_HScrollbar([_props])
///
/// @extends GUI_Scrollbar
///
/// @desc
///
/// @param {Struct} [_props]
function GUI_HScrollbar(_props={})
	: GUI_Scrollbar(_props) constructor
{
	SetHeight(_props[$ "Height"] ?? 14);

	OnPress = function () {
		var _mouseX = window_mouse_get_x();
		var _thumbX = RealX + Scroll;
		if (_mouseX >= _thumbX
			&& _mouseX <= _thumbX + ThumbSize)
		{
			MouseOffset = _thumbX - _mouseX;
			DragStart();
		}
		else
		{
			var _scroll = _mouseX - RealX;
			_scroll = clamp(_scroll, 0, RealWidth - ThumbSize);
			SetProps({
				Scroll: _scroll,
			});
		}
	};

	static Scrollbar_Update = Update;

	static Update = function () {
		Scrollbar_Update();
		var _scroll = Scroll;
		if (IsDragged())
		{
			if (mouse_check_button(mb_left))
			{
				_scroll = window_mouse_get_x() - RealX + MouseOffset;
			}
			else
			{
				DragEnd();
			}
		}
		_scroll = max(min(_scroll, RealWidth - ThumbSize), 0);
		SetProps({
			Scroll: _scroll,
		});
		return self;
	};

	static Draw = function () {
		draw_sprite_stretched(BackgroundSprite, BackgroundSubimage,
			RealX, RealY, RealWidth, RealHeight);
		draw_sprite_stretched(Sprite, 0, RealX + Scroll, RealY, ThumbSize, RealHeight);
		return self;
	};
}
