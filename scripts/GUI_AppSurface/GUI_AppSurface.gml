/// @func GUI_AppSurface([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_AppSurface(_props={}, _children=[])
	: GUI_Widget(_props, _children) constructor
{
	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? c_black;

	/// @var {Constant.Color}
	BackgroundAlpha = _props[$ "BackgroundAlpha"] ?? 1.0;

	static Draw = function () {
		if (floor(RealWidth) <= 0 || floor(RealHeight) <= 0)
		{
			return self;
		}

		if (surface_get_width(application_surface) != RealWidth
			|| surface_get_height(application_surface) != RealHeight)
		{
			surface_resize(application_surface, RealWidth, RealHeight);
		}

		GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, BackgroundColor, BackgroundAlpha);
		draw_surface_stretched(application_surface, RealX, RealY, RealWidth, RealHeight);

		DrawChildren();

		return self;
	};
}
