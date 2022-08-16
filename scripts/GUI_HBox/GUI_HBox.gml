/// @func GUI_HBox([_props[, _children]])
///
/// @extends GUI_Box
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_HBox(_props={}, _children=[])
	: GUI_Box(_props, _children) constructor
{
	static Layout = function (_force=false) {
		CHECK_LAYOUT_CHANGED;

		var _x = RealX;
		var _y = RealY;
		var _ymax = _y;
		var _parentWidth = RealWidth;
		var _parentHeight = RealHeight;
		var _spacing = Spacing;
		var _childCount = array_length(Children);

		var i = 0;
		repeat (_childCount)
		{
			with (Children[i++])
			{
				if (Visible)
				{
					ComputeRealSize(_parentWidth, _parentHeight);
					SetProps({
						"RealX": _x,
						"RealY": _y,
					})
					Layout(_force);
					var _bbox = GetBoundingBox();
					_ymax = max(_ymax, _bbox[3]);
					var _width = _bbox[2] - _bbox[0]
					_x += _width + (_spacing * (_width > 0 && i < _childCount));
				}
			}
		}

		SetProps({
			"RealWidth": _x - RealX,
			"RealHeight": _ymax - RealY,
		});

		return self;
	};
}
