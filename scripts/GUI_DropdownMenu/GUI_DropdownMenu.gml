/// @func GUI_DropdownMenu([_props])
///
/// @extends GUI_ScrollPane
///
/// @desc
///
/// @param {Struct} [_props]
function GUI_DropdownMenu(_props={})
	: GUI_ScrollPane(_props) constructor
{
	/// @var {Struct.GUI_Dropdown}
	/// @readonly
	Dropdown = undefined;

	OptionsContainer = new GUI_VBox({
		Width: "100%",
	});
	Canvas.BackgroundColor = #181818;
	Canvas.Add(OptionsContainer);
	Canvas.MaxChildCount = 1;

	static ScrollPane_Layout = Layout;

	static Layout = function (_force=false) {
		CHECK_LAYOUT_CHANGED;
		SetProps({
			RealHeight: min(OptionsContainer.GetBoundingBox()[3] - RealY, window_get_height() - RealY),
		});
		ScrollPane_Layout(_force);
		return self;
	};

	static ScrollPane_Update = Update;

	static Update = function () {
		ScrollPane_Update();
		if (Visible)
		{
			if (mouse_check_button_pressed(mb_left)
				&& !IsMouseOver()
				&& !(Dropdown && Dropdown.IsMouseOver())
				&& !(Root && IsAncestorOf(Root.WidgetHovered)))
			{
				RemoveSelf();
			}
		}
		return self;
	};
}
