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

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? "100%"
	);

	static Layout = function (_force=false) {
		CHECK_LAYOUT_CHANGED;

		var _parentWidth = RealWidth;
		var _parentHeight = RealHeight;
		var _childCount = array_length(Children);

		var _direction = FlexDirection;
		var _sizeTotal = (FlexDirection == "row") ? RealWidth : RealHeight;
		var _growTotal = 0;

		for (var i = 0; i < _childCount; ++i)
		{
			with (Children[i])
			{
				if (!Visible)
				{
					continue;
				}

				if (_direction == "row")
				{
					SetProps({
						"RealWidth": Width,
						"RealHeight": _parentHeight,
					});
					if (FlexGrow <= 0)
					{
						_sizeTotal -= RealWidth;
					}
					else if (WidthUnit != "px")
					{
						show_error("GUI_FlexLayout cannot containt widgets with relative size!", true);
					}
				}
				else
				{
					SetProps({
						"RealWidth": _parentWidth,
						"RealHeight": Height,
					});
					if (FlexGrow <= 0)
					{
						_sizeTotal -= RealHeight;
					}
					else if (HeightUnit != "px")
					{
						show_error("GUI_FlexLayout cannot containt widgets with relative size!", true);
					}
				}

				_growTotal += FlexGrow;
			}
		}

		var _x = RealX;
		var _y = RealY;

		for (var i = 0; i < _childCount; ++i)
		{
			with (Children[i])
			{
				if (!Visible)
				{
					continue;
				}

				SetProps({
					"RealX": _x,
					"RealY": _y,
				});

				if (_direction == "row")
				{
					if (FlexGrow > 0)
					{
						SetProps({
							"RealWidth": _sizeTotal * (FlexGrow / _growTotal),
						});
					}
					_x += RealWidth;
				}
				else
				{
					if (FlexGrow > 0)
					{
						SetProps({
							"RealHeight": _sizeTotal * (FlexGrow / _growTotal),
						});
					}
					_y += RealHeight;
				}

				Layout(_force);
			}
		}

		return self;
	};
}
