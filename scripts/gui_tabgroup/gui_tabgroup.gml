/// @func GUI_TabGroup([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Tab>} [_children]
function GUI_TabGroup(_props={}, _children=[])
	: GUI_Widget(_props) constructor
{
	/// @var {Sruct.GUI_Tab}
	/// @readonly
	Selected = undefined;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? GUI_LINE_HEIGHT
	);

	var i = 0
	repeat (array_length(_children))
	{
		Add(_children[i++]);
	}

	static Widget_Add = Add;

	/// @func Add(_tab)
	///
	/// @desc
	///
	/// @param {Struct.GUI_Tab} _tab
	///
	/// @return {Struct.GUI_TabGroup} Returns `self`.
	static Add = function (_tab) {
		gml_pragma("forceinline");
		Widget_Add(_tab);
		if (_tab.IsSelected)
		{
			_tab.Select();
		}
		return self;
	};

	static Layout = function (_force=false) {
		GUI_CHECK_LAYOUT_CHANGED;
		var _tabCount = array_length(Children);
		if (_tabCount > 0)
		{
			var _parentHeight = RealHeight;
			var _x = RealX;
			var _y = RealY;
			var _tabWidth = RealWidth / _tabCount;
			for (var i = 0; i < _tabCount; ++i)
			{
				with (Children[i])
				{
					SetProps({
						RealWidth: _tabWidth,
						RealHeight: _parentHeight - 1,
						RealX: _x,
						RealY: _y,
					});
					_x += _tabWidth;
				}
			}
		}
		return self;
	};

	static Draw = function () {
		DrawChildren();
		GUI_DrawRectangle(RealX, RealY + RealHeight - 1, RealWidth, 1, #1C8395);
		return self;
	};
}