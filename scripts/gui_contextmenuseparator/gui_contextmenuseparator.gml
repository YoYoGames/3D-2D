/// @func GUI_ContextMenuSeparator([_props])
///
/// @extends GUI_ContextMenuItem
///
/// @desc
///
/// @param {Struct} [_props]
function GUI_ContextMenuSeparator(_props={})
	: GUI_ContextMenuItem(_props) constructor
{
	MaxChildCount = 0;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? 3,
	);

	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? #3E3E3E;

	static Draw = function () {
		GUI_DrawRectangle(RealX, RealY + RealHeight - 1, RealWidth, 1, BackgroundColor);
		return self;
	};
}
