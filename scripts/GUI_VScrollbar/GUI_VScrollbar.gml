/// @func GUI_VScrollbar([_props])
///
/// @extends GUI_Scrollbar
///
/// @desc
///
/// @param {Struct} [_props]
function GUI_VScrollbar(_props={})
	: GUI_Scrollbar(_props) constructor
{
	SetWidth(_props[$ "Width"] ?? 14);

	OnPress = function () {
		var _mouseY = window_mouse_get_y();
		var _thumbY = RealY + Scroll;
		if (_mouseY >= _thumbY
			&& _mouseY <= _thumbY + ThumbSize)
		{
			MouseOffset = _thumbY - _mouseY;
			DragStart();
		}
		else
		{
			var _scroll = _mouseY - RealY;
			_scroll = clamp(_scroll, 0, RealHeight - ThumbSize);
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
				var _scroll = window_mouse_get_y() - RealY + MouseOffset;
			}
			else
			{
				DragEnd();
			}
		}
		_scroll = max(min(_scroll, RealHeight - ThumbSize), 0);
		SetProps({
			Scroll: _scroll,
		});
		return self;
	};

	static Draw = function () {
		draw_sprite_stretched(BackgroundSprite, BackgroundSubimage,
			RealX, RealY, RealWidth, RealHeight);
		draw_sprite_stretched(Sprite, 0, RealX, RealY + Scroll, RealWidth, ThumbSize);
		return self;
	};
}
