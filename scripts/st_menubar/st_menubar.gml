/// @func ST_MenuBar([_props])
///
/// @extends GUI_MenuBar
///
/// @desc
///
/// @param {Struct} [_props]
function ST_MenuBar(_props)
	: GUI_MenuBar(_props) constructor
{
	// TODO: Deduplicate code with keyboard shortcuts
	Add(new GUI_MenuBarItem("File", {
		// TODO: Automatic sizing of context menus with keyboard shortcuts
		Menu: new GUI_ContextMenu({ MinWidth: 148 }, [
			new GUI_ContextMenuOption("New", {
				ShortcutText: "CTRL+N",
				Action: function () {
					GUI_ShowQuestionAsync(
						"Are you sure you want to create a new empty project?\nAny unsaved progress will be lost!",
						method(ST_OMain, ST_OMain.NewProject));
				},
			}),
			new GUI_ContextMenuOption("Open", {
				ShortcutText: "CTRL+O",
				Action: function () {
					with (ST_OMain)
					{
						var _callback = method(self, function () {
							var _path = get_open_filename(ST_FILTER_SAVE, "");
							if (_path != "")
							{
								LoadProject(_path);
							}
						});

						if (!Asset)
						{
							_callback();
						}
						else
						{
							GUI_ShowQuestionAsync(
								"Are you sure you want to open a different project?\nAny unsaved progress will be lost!",
								_callback);
						}
					}
				},
			}),
			// TODO: Add submenus to context menus
			//new GUI_ContextMenuOption("Recent"),
			new GUI_ContextMenuSeparator(),
			new GUI_ContextMenuOption("Save", {
				ShortcutText: "CTRL+S",
				Action: function () {
					with (ST_OMain)
					{
						var _path = (global.stSavePath == undefined)
							? get_save_filename(ST_FILTER_SAVE, "")
							: global.stSavePath;
						if (_path != "")
						{
							SaveProject(_path);
						}
					}
				},
			}),
			new GUI_ContextMenuOption("Save As", {
				ShortcutText: "CTRL+SHIFT+S",
				Action: function () {
					with (ST_OMain)
					{
						var _path = get_save_filename(ST_FILTER_SAVE, "");
						if (_path != "")
						{
							SaveProject(_path);
						}
					}
				},
			}),
			new GUI_ContextMenuSeparator(),
			new GUI_ContextMenuOption("Preferences"),
			new GUI_ContextMenuSeparator(),
			new GUI_ContextMenuOption("Exit", {
				ShortcutText: "ALT+F4",
				Action: game_end,
			}),
		]),
	}));

	//Add(new GUI_MenuBarItem("Edit", {
	//	Menu: new GUI_ContextMenu({}, [
	//		new GUI_ContextMenuOption("Undo"),
	//		new GUI_ContextMenuOption("Redo"),
	//	]),
	//}));

	//Add(new GUI_MenuBarItem("Build"));
	//Add(new GUI_MenuBarItem("Windows"));
	//Add(new GUI_MenuBarItem("Tools"));
}
