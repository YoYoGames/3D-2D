/// @func ST_ViewportFloatingToolbar(_store[, _props])
///
/// @extends GUI_FloatingToolbar
///
/// @desc
///
/// @param {Id.Instance, Struct} _store
/// @param {Struct} [_props]
function ST_ViewportFloatingToolbar(_store, _props={})
	: GUI_FloatingToolbar(_props) constructor
{
	Store = _store;

	GridOptions = new GUI_Canvas({
		Width: 200,
		Height: 90, // TODO: "auto" sizing
		AnchorLeft: 1.0,
		PivotTop: 1.0,
		AnchorTop: 1.0,
		BackgroundColor: #212121,
		BackgroundSprite: GUI_SprContainerBorder,
		Visible: false,
		OnUpdate: function (_canvas) {
			with (_canvas)
			{
				if (Visible
					&& mouse_check_button_pressed(mb_left)
					&& !IsMouseOver()
					&& !Parent.IsMouseOver()
					&& !(Root && IsAncestorOf(Root.WidgetHovered)))
				{
					SetProps({ Visible: false });
				}
			}
		},
	}, [
		new GUI_VBox({ Width: "100%", Padding: 8, Gap: 4 }, [
			new GUI_Text("Grid:"),
			new ST_VectorInput(ST_OMain.Gizmo.GridSize, {
				Width: "100%",
				Min: 0.0,
				Step: 0.1,
			}),
			new GUI_Checkbox(ST_OMain.Gizmo.EnableGridSnap, {
				OnChange: function (_value) {
					ST_OMain.Gizmo.EnableGridSnap = _value;
				},
			}, [
				new GUI_Text("Snap", {
					AnchorLeft: 1.0,
					PivotLeft: 1.0,
					X: 8,
				}),
			]),
		]),
	]);

	ExtraOptions = new GUI_Canvas({
		Width: 200,
		Height: 124, // TODO: "auto" sizing
		AnchorLeft: 1.0,
		PivotTop: 1.0,
		AnchorTop: 1.0,
		BackgroundColor: #212121,
		BackgroundSprite: GUI_SprContainerBorder,
		Visible: false,
		OnUpdate: function (_canvas) {
			with (_canvas)
			{
				if (Visible
					&& mouse_check_button_pressed(mb_left)
					&& !IsMouseOver()
					&& !Parent.IsMouseOver()
					&& !(Root && IsAncestorOf(Root.WidgetHovered)))
				{
					SetProps({ Visible: false });
				}
			}
		},
	}, [
		new GUI_VBox({ Width: "100%", Padding: 8, Gap: 4 }, [
			new GUI_Text("Angle snap:"),
			new GUI_FlexLayout({
				Width: "100%",
				Height: "auto",
				Gap: 8,
			}, [
				new GUI_Input(ST_OMain.Gizmo.AngleSnap, {
					Width: "50%",
					Min: 0.0,
					Max: 360.0,
					Step: 1.0,
					OnChange: function (_value) {
						ST_OMain.Gizmo.AngleSnap = _value;
					},
				}),
				new GUI_Checkbox(ST_OMain.Gizmo.EnableAngleSnap, {
					OnChange: function (_value) {
						ST_OMain.Gizmo.EnableAngleSnap = _value;
					},
				}),
				new GUI_Text("Enabled"),
			]),
			new GUI_Text("Edit space:"),
			// FIXME: Selecting value here closes the extra options widget!
			new GUI_Dropdown({
				Width: "100%",
				OnChange: function (_value) {
					ST_OMain.Gizmo.EditSpace = _value;
				},
			}, [
				new GUI_DropdownOption("Global", { Value: BBMOD_EEditSpace.Global, IsDefault: true }),
				new GUI_DropdownOption("Local", { Value: BBMOD_EEditSpace.Local }),
			]),
		]),
	]);

	// FIXME: DIRTY HACK!!!
	DropdownEditType = new GUI_Dropdown({
		DrawSelf: false,
		Width: 60,
		AnchorLeft: 1.0,
		AnchorTop: 1.0,
		OnChange: function (_value) {
			ST_OMain.Gizmo.EditType = _value;
		},
	}, [
		new GUI_DropdownOption("Move", { Value: BBMOD_EEditType.Position, IsDefault: true }),
		new GUI_DropdownOption("Rotate", { Value: BBMOD_EEditType.Rotation }),
		new GUI_DropdownOption("Scale", { Value: BBMOD_EEditType.Scale }),
	]);

	static CentreCamera = function () {
		var _cameraType = Root.Viewport.CameraDropdown.Selected.Value;
		with (Store)
		{
			x = 0;
			y = 0;
			z = 0;
			with (Camera)
			{
				Zoom = 10;
				ApplyCameraSetting(_cameraType);
			}
		}
	};

	Add(new GUI_HBox({}, [
		new GUI_GlyphButton(ST_EIcon.ToolbarGridIcon, {
			Tooltip: "Toggle Grid",
			Font: ST_FntIcons11,
			OnClick: function () {
				ST_OMain.GridVisible = !ST_OMain.GridVisible;
			},
			OnUpdate: function (_iconButton) {
				_iconButton.SetProps({
					Active: ST_OMain.GridVisible,
				});
			},
		}),
		new GUI_GlyphButton(ST_EIcon.ArrowDown, {
			Tooltip: "Grid Options",
			Font: ST_FntIcons5,
			Width: 11,
			OnUpdate: method(self, function (_glyphButton) {
				_glyphButton.SetProps({
					Active: GridOptions.Visible,
				});
			}),
			OnClick: method(self, function (_glyphButton) {
				GridOptions.SetProps({
					Visible: !GridOptions.Visible,
				});
			}),
		}, [
			GridOptions,
		]),
	]));

	Add(new GUI_Separator({ Width: 2, Height: 24, BackgroundColor: #444444 }));

	Add(new GUI_GlyphButton(ST_EIcon.ZoomOut, {
		Tooltip: "Zoom Out",
		Font: ST_FntIcons11,
		OnClick: method(Store.Camera, function () {
			Zoom += 1;
		}),
	}));

	Add(new GUI_GlyphButton(ST_EIcon.ZoomReset, {
		Tooltip: "Reset Zoom",
		Font: ST_FntIcons11,
		OnClick: method(Store, function () {
			Camera.Zoom = 10;
		}),
	}));

	Add(new GUI_GlyphButton(ST_EIcon.ZoomIn, {
		Tooltip: "Zoom In",
		Font: ST_FntIcons11,
		OnClick: method(Store.Camera, function () {
			Zoom = max(Zoom - 1, 1);
		}),
	}));

	Add(new GUI_GlyphButton(ST_EIcon.ZoomCentreFit, {
		Tooltip: "Centre (F)",
		Font: ST_FntIcons11,
		OnClick: method(self, CentreCamera),
		OnUpdate: method(self, function () {
			if (Store.GUI.Viewport.IsMouseOver()
				&& Store.GUI.WidgetFocused == undefined
				&& keyboard_check_pressed(ord("F")))
			{
				CentreCamera();
			}
		}),
	}));

	Add(new GUI_GlyphButton(ST_EIcon.WrenchWhite, {
		Font: ST_FntIcons11,
		OnClick: method(self, function (_glyphButton) {
			ExtraOptions.SetProps({
				Visible: !ExtraOptions.Visible,
			});
		}),
	}, [
		ExtraOptions,
	]));

	Add(new GUI_HBox({}, [
		new GUI_GlyphButton(ST_EIcon.Move, {
			Font: ST_FntIcons11,
			OnUpdate: function (_glyphButton) {
				switch (ST_OMain.Gizmo.EditType)
				{
				case BBMOD_EEditType.Position:
					_glyphButton.Tooltip = "Move Tool (TAB)";
					_glyphButton.Glyph = ST_EIcon.Move;
					break;

				case BBMOD_EEditType.Rotation:
					_glyphButton.Tooltip = "Rotate Tool (TAB)";
					_glyphButton.Glyph = ST_EIcon.RotateBrush;
					break;

				case BBMOD_EEditType.Scale:
					_glyphButton.Tooltip = "Scale Tool (TAB)";
					_glyphButton.Glyph = ST_EIcon.ScaleCursor;
					break;
				}
			},
			OnPress: method(self, function () {
				DropdownEditType.SelectNext();
			}),
		}),
		new GUI_GlyphButton(ST_EIcon.ArrowDown, {
			Tooltip: "Select Tool",
			Font: ST_FntIcons5,
			Width: 11,
			OnClick: method(self, function (_glyphButton) {
				DropdownEditType.OnClick(DropdownEditType);
			}),
		}, [
			DropdownEditType,
		]),
	]));

	//Add(new GUI_HBox({}, [
	//	new GUI_GlyphButton(ST_EIcon.NoSplit, {
	//		Font: ST_FntIcons11,
	//	}),
	//	new GUI_GlyphButton(ST_EIcon.ArrowDown, {
	//		Font: ST_FntIcons5,
	//		Width: 11,
	//	}),
	//]));
}
