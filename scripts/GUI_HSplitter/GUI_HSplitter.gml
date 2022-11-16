/// @func GUI_HSplitter([_props[, _children]])
///
/// @extends GUI_Splitter
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children] Takes two at most. The first
/// one is added to {@link GUI_HSplitter.Left} and the second one to
/// {@link GUI_HSplitter.Right}.
function GUI_HSplitter(_props={}, _children=[])
	: GUI_Splitter(_props) constructor
{
	/// @var {Struct.GUI_Canvas}
	/// @readonly
	Left = new GUI_Canvas({ BackgroundColor: c_black });
	Add(Left);

	if (array_length(_children) > 0)
	{
		Left.Add(_children[0]);
	}

	/// @var {Struct.GUI_Canvas}
	/// @readonly
	Right = new GUI_Canvas({ BackgroundColor: c_black });
	Add(Right);

	if (array_length(_children) > 1)
	{
		Right.Add(_children[1]);
	}

	OnPress = function () {
		var _mouseX = window_mouse_get_x();
		var _splitterX = GetSplitterX();
		if (_mouseX >= _splitterX
			&& _mouseX <= _splitterX + Size)
		{
			MouseOffset = (RealX + RealWidth * Split) - _mouseX;
			DragStart();
		}
	};

	/// @func GetSplitterX()
	///
	/// @desc
	///
	/// @return {Real}
	static GetSplitterX = function () {
		gml_pragma("forceinline");
		return clamp(
			floor(RealX + (RealWidth * Split) - (Size / 2)),
			RealX,
			RealX + RealWidth - Size);
	};

	static Layout = function (_force=false) {
		GUI_CHECK_LAYOUT_CHANGED;

		var _splitterX = GetSplitterX();

		Left.SetProps({
			RealX: RealX,
			RealY: RealY,
			RealHeight: RealHeight,
			RealWidth: Right.Visible ? max(_splitterX - RealX, 0) : RealWidth,
		});
		Left.Layout(_force);

		var _rightRealX = Left.Visible ? (_splitterX + Size) : RealX;
		Right.SetProps({
			RealX: _rightRealX,
			RealY: RealY,
			RealWidth: Left.Visible ? max(RealX + RealWidth - _rightRealX, 0) : RealWidth,
			RealHeight: RealHeight,
		});
		Right.Layout(_force);

		return self;
	};

	static Splitter_Update = Update;

	static Update = function () {
		Splitter_Update();

		var _mouseX = window_mouse_get_x();

		if (IsDragged())
		{
			if (mouse_check_button(mb_left))
			{
				var _split = (_mouseX - RealX + MouseOffset) / RealWidth;
				_split = clamp(_split, 0.1, 0.9);
				SetProps({
					Split: _split,
				});
			}
			else
			{
				DragEnd();
			}
		}

		if (Root)
		{
			var _splitterX = GetSplitterX();
			if (IsDragged()
				|| (IsMouseOver()
				&& (_mouseX >= _splitterX && _mouseX <= _splitterX + Size)))
			{
				Root.Cursor = cr_size_we;
			}
		}

		return self;
	};

	static Draw = function () {
		GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, BackgroundColor, BackgroundAlpha);
		GUI_DrawRectangle(GetSplitterX(), RealY, Size, RealHeight, Color);
		DrawChildren();
		return self;
	};
}
