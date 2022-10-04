/// @func GUI_ScrollPane([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children] These are added to
/// {@link GUI_ScrollPane.Canvas}!
function GUI_ScrollPane(_props={}, _children=[])
	: GUI_Widget(_props) constructor
{
	/// @var {Bool}
	EnableScrollbarH = _props[$ "EnableScrollbarH"] ?? true;

	/// @var {Bool}
	EnableScrollbarV = _props[$ "EnableScrollbarV"] ?? true;

	/// @var {Struct.GUI_Canvas}
	/// @readonly
	Canvas = new GUI_Canvas({
		BackgroundColor: #272727,
	});
	Add(Canvas);

	var i = 0;
	repeat (array_length(_children))
	{
		Canvas.Add(_children[i++]);
	}

	/// @var {Struct.GUI_HScrollbar}
	/// @readonly
	ScrollbarH = new GUI_HScrollbar({ Visible: false, Target: Canvas });
	Add(ScrollbarH);

	/// @var {Struct.GUI_VScrollbar}
	/// @readonly
	ScrollbarV = new GUI_VScrollbar({ Visible: false, Target: Canvas });
	Add(ScrollbarV);

	MaxChildCount = 3;

	static Widget_Update = Update;

	static Update = function () {
		Widget_Update();

		var _contentWidth = Canvas.ContentWidth;
		var _contentHeight = Canvas.ContentHeight;
		var _wheel = (mouse_wheel_down() - mouse_wheel_up()) * GUI_LINE_HEIGHT * 2;

		if (_wheel != 0)
		{
			if (ScrollbarV.Visible
				&& (!ScrollbarH.Visible || !keyboard_check(vk_control))
				&& (IsMouseOver() || (Root && IsAncestorOf(Root.WidgetHovered))))
			{
				ScrollbarV.SetScroll(clamp(ScrollbarV.GetScroll() + _wheel, 0, _contentHeight - Canvas.RealHeight));
			}

			if (ScrollbarH.Visible
				&& (!ScrollbarV.Visible || keyboard_check(vk_control))
				&& (IsMouseOver() || (Root && IsAncestorOf(Root.WidgetHovered))))
			{
				ScrollbarH.SetScroll(clamp(ScrollbarH.GetScroll() + _wheel, 0, _contentWidth - Canvas.RealWidth));
			}
		}

		return self;
	};

	static Layout = function (_force=false) {
		GUI_CHECK_LAYOUT_CHANGED;

		var _parentX = RealX;
		var _parentY = RealY;
		var _parentWidth = RealWidth;
		var _parentHeight = RealHeight;

		with (Canvas)
		{
			SetProps({
				RealWidth: _parentWidth,
				RealHeight: _parentHeight,
				RealX: _parentX,
				RealY: _parentY,
			});
		}

		with (ScrollbarH)
		{
			ComputeRealHeight(_parentHeight);
			SetProps({
				RealWidth: _parentWidth,
				RealX: _parentX,
				RealY: _parentY + _parentHeight - RealHeight,
			});
		}

		with (ScrollbarV)
		{
			ComputeRealWidth(_parentWidth);
			SetProps({
				RealHeight: _parentHeight,
				RealX: _parentX + _parentWidth - RealWidth,
				RealY: _parentY,
			});
		}

		if (ScrollbarH.Visible)
		{
			Canvas.RealHeight -= ScrollbarH.RealHeight;
			ScrollbarV.RealHeight -= ScrollbarH.RealHeight;
		}

		if (ScrollbarV.Visible)
		{
			Canvas.RealWidth -= ScrollbarV.RealWidth;
			ScrollbarH.RealWidth -= ScrollbarV.RealWidth;
		}

		Canvas.Layout(_force);
		ScrollbarH.Layout(_force);
		ScrollbarV.Layout(_force);

		ScrollbarH.SetProps({
			Visible: (EnableScrollbarH && Canvas.ContentWidth > Canvas.RealWidth),
		})
		ScrollbarV.SetProps({
			Visible: (EnableScrollbarV && Canvas.ContentHeight > Canvas.RealHeight),
		});

		return self;
	};

	static Draw = function () {
		DrawChildren();
		if (ScrollbarH.Visible && ScrollbarV.Visible)
		{
			GUI_DrawRectangle(
				RealX + RealWidth - ScrollbarV.RealWidth,
				RealY + RealHeight - ScrollbarH.RealHeight,
				ScrollbarV.RealWidth,
				ScrollbarH.RealHeight,
				c_black);
		}
		return self;
	};
}
