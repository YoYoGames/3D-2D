/// @func GUI_Grid(_clumns[, _rows[, _props[, _children]]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Real} _columns
/// @param {Real} [_rows]
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Grid(_columns, _rows=undefined, _props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {Real}
	/// @readonly
	Columns = _columns;

	/// @var {Real}
	/// @readonly
	Rows = _rows;

	if (Rows != undefined)
	{
		MaxChildCount = Columns * Rows;
	}

	AlignLeft = _props[$ "AlignLeft"] ?? 0.5;

	AlignTop = _props[$ "AlignTop"] ?? 0.5;

	static Layout = function (_force=false) {
		GUI_CHECK_LAYOUT_CHANGED;

		var _x = RealX;
		var _y = RealY;
		var _parentWidth = RealWidth;
		var _parentHeight = RealHeight;
		var _cellWidth = _parentWidth / Columns;
		var _rows = Rows;
		if (_rows != undefined)
		{
			var _cellHeight = _parentHeight / Rows;
		}
		var _xStart = _x;
		var _xEnd = _xStart + RealWidth;
		var _alignLeft = AlignLeft;
		var _alignTop = AlignTop;

		var i = 0;
		repeat (array_length(Children))
		{
			with (Children[i++])
			{
				if (Visible)
				{
					ComputeRealSize(_parentWidth, _parentHeight);
					SetProps({
						RealX: round(_x + ((_cellWidth - RealWidth) * _alignLeft) + (RealWidth * PivotLeft)),
						RealY: (_rows != undefined)
							? round(_y + ((_cellHeight - RealHeight) * _alignTop) + (RealHeight * PivotTop))
							: round(_y + (RealHeight * PivotTop)),
					});
					Layout(_force);
					_x += _cellWidth;
					if (_x >= _xEnd)
					{
						_y += (_rows != undefined) ? _cellHeight : RealHeight;
						_x = _xStart;
					}
				}
			}
		}
		return self;
	};
}
