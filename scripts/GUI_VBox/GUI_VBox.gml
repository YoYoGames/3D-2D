/// @func GUI_VBox([_props[, _children]])
///
/// @extends GUI_Box
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_VBox(_props={}, _children=[])
	: GUI_Box(_props, _children) constructor
{
	static Layout = function (_force=false) {
		GUI_CHECK_LAYOUT_CHANGED;

		var _paddingLeft = PaddingLeft ?? Padding;
		var _paddingTop = PaddingTop ?? Padding;
		var _x = RealX + _paddingLeft;
		var _xmax = _x;
		var _y = RealY + _paddingTop;
		var _parentWidth = RealWidth - _paddingLeft - (PaddingRight ?? Padding);
		var _parentHeight = RealHeight - _paddingTop - (PaddingBottom ?? Padding);
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
						RealX: _x,
						RealY: _y,
					});
					Layout(_force);
					var _bbox = GetBoundingBox();
					_xmax = max(_xmax, _bbox[2]);
					var _height = _bbox[3] - RealY;//_bbox[1];
					_y += _height + (_spacing * (_height > 0 && i < _childCount));
				}
			}
		}

		SetProps({
			RealWidth: _xmax - RealX + (PaddingRight ?? Padding),
			RealHeight: _y - RealY + (PaddingBottom ?? Padding),
		});

		return self;
	};
}
