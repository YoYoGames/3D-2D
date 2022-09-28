/// @func GUI_FlexLayout([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_FlexLayout(_props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {String}
	/// Possible options are "row" (default) and "column".
	FlexDirection = _props[$ "FlexDirection"] ?? "row";

	/// @var {Real}
	Gap = _props[$ "Gap"] ?? 0;

	//SetSize(
	//	_props[$ "Width"] ?? "100%",
	//	_props[$ "Height"] ?? "100%"
	//);

	static Layout = function (_force=false) {
		CHECK_LAYOUT_CHANGED;

		var _paddingLeft = PaddingLeft ?? Padding;
		var _paddingRight = PaddingRight ?? Padding;
		var _paddingTop = PaddingTop ?? Padding;
		var _paddingBottom = PaddingBottom ?? Padding;
		var _availableWidth = floor(RealWidth - _paddingLeft - _paddingRight);
		var _availableHeight = floor(RealHeight - _paddingTop - _paddingBottom);
		var _childCount = array_length(Children);
		var _gap = Gap;
		var _direction = FlexDirection;
		var _growTotal = 0;
		var _maxItemWidth = 0;
		var _maxItemHeight = 0;

		var _sizeTotal;
		if (FlexDirection == "row")
		{
			_availableWidth -= max(_childCount - 1, 0) * _gap;
			_sizeTotal = _availableWidth;
		}
		else // column
		{
			_availableHeight -= max(_childCount - 1, 0) * _gap;
			_sizeTotal = _availableHeight;
		}

		for (var i = 0; i < _childCount; ++i)
		{
			with (Children[i])
			{
				if (!Visible)
				{
					continue;
				}

				ComputeRealSize(_availableWidth, _availableHeight);

				if (_direction == "row")
				{
					if (FlexGrow <= 0)
					{
						_sizeTotal -= RealWidth;
					}
				}
				else // column
				{
					if (FlexGrow <= 0)
					{
						_sizeTotal -= RealHeight;
					}
				}

				_growTotal += FlexGrow;
			}
		}

		var _x = RealX + _paddingLeft;
		var _y = RealY + _paddingTop;

		for (var i = 0; i < _childCount; ++i)
		{
			with (Children[i])
			{
				if (!Visible)
				{
					continue;
				}

				SetProps({
					RealX: _x,
					RealY: _y,
				});

				if (_direction == "row")
				{
					if (FlexGrow > 0)
					{
						SetProps({
							RealWidth: _sizeTotal * (FlexGrow / _growTotal),
						});
					}
					_x += RealWidth + _gap;
				}
				else
				{
					if (FlexGrow > 0)
					{
						SetProps({
							RealHeight: _sizeTotal * (FlexGrow / _growTotal),
						});
					}
					_y += RealHeight + _gap;
				}

				_maxItemWidth = max(RealWidth, _maxItemWidth);
				_maxItemHeight = max(RealHeight, _maxItemHeight);

				Layout(_force);
			}
		}

		// Note: This should also affect the child widgets, but then the layout
		// would have to be done in multiple passes, which could get very slow!
		if (Width == "auto" && (FlexGrow == 0 || Parent[$ "FlexDirection"] != "row"))
		{
			_maxItemWidth = GetClampedRealWidth(_maxItemWidth, Parent.RealWidth);
			SetProps({ RealWidth: _maxItemWidth });
		}

		if (Height == "auto" && (FlexGrow == 0 || Parent[$ "FlexDirection"] != "column"))
		{
			_maxItemHeight = GetClampedRealHeight(_maxItemHeight, Parent.RealHeight);
			SetProps({ RealHeight: _maxItemHeight });
		}

		return self;
	};
}
