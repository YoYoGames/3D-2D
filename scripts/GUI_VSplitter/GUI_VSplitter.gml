/// @func GUI_VSplitter([_props[, _children]])
///
/// @extends GUI_Splitter
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children] Takes two at most. The first
/// one is added to {@link GUI_VSplitter.Top} and the second one to
/// {@link GUI_VSplitter.Bottom}.
function GUI_VSplitter(_props={}, _children=[])
	: GUI_Splitter(_props) constructor
{
	/// @var {Struct.GUI_Canvas}
	/// @readonly
	Top = new GUI_Canvas({ BackgroundColor: c_black });
	Add(Top);

	if (array_length(_children) > 0)
	{
		Top.Add(_children[0]);
	}

	/// @var {Struct.GUI_Canvas}
	/// @readonly
	Bottom = new GUI_Canvas({ BackgroundColor: c_black });
	Add(Bottom);

	if (array_length(_children) > 1)
	{
		Bottom.Add(_children[1]);
	}

	OnPress = function () {
		var _mouseY = window_mouse_get_y();
		var _splitterY = GetSplitterY();
		if (_mouseY >= _splitterY
			&& _mouseY <= _splitterY + Size)
		{
			MouseOffset = (RealY + RealHeight * Split) - _mouseY;
			DragStart();
		}
	};

	/// @func GetSplitterY()
	///
	/// @desc
	///
	/// @return {Real}
	static GetSplitterY = function () {
		gml_pragma("forceinline");
		return clamp(
			floor(RealY + (RealHeight * Split) - (Size / 2)),
			RealY,
			RealY + RealHeight - Size);
	};

	static Layout = function (_force=false) {
		GUI_CHECK_LAYOUT_CHANGED;

		var _splitterY = GetSplitterY();

		Top.SetProps({
			RealX: RealX,
			RealY: RealY,
			RealWidth: RealWidth,
			RealHeight: Bottom.Visible ? max(_splitterY - RealY, 0) : RealHeight,
		});
		Top.Layout(_force);

		var _bottomRealY = Top.Visible ? (_splitterY + Size) : RealY;
		Bottom.SetProps({
			RealX: RealX,
			RealY: _bottomRealY,
			RealWidth: RealWidth,
			RealHeight: Top.Visible ? max(RealY + RealHeight - _bottomRealY, 0) : RealHeight,
		});
		Bottom.Layout(_force);

		return self;
	};

	static Splitter_Update = Update;

	static Update = function () {
		Splitter_Update();

		var _mouseY = window_mouse_get_y();

		if (IsDragged())
		{
			if (mouse_check_button(mb_left))
			{
				var _split = (_mouseY - RealY + MouseOffset) / RealHeight;
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
			var _splitterY = GetSplitterY();
			if (IsDragged()
				|| (IsMouseOver()
				&& (_mouseY >= _splitterY && _mouseY <= _splitterY + Size)))
			{
				Root.Cursor = cr_size_ns;
			}
		}

		return self;
	};

	static Splitter_Draw = Draw;

	static Draw = function () {
		if (!Visible)
		{
			return self;
		}
		GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, BackgroundColor, BackgroundAlpha);
		GUI_DrawRectangle(RealX, GetSplitterY(), RealWidth, Size, Color);
		Splitter_Draw();
		return self;
	};
}
