/// @func ST_ViewportWidget(_store[, _props])
///
/// @extends GUI_AppSurface
///
/// @desc
///
/// @param {Id.Instance, Struct} _store
/// @param {Struct} [_props]
function ST_ViewportWidget(_store, _props={})
	: GUI_AppSurface(_props) constructor
{
	/// @var {Id.Instance, Struct}
	Store = _store;

	//SetSize(
	//	_props[$ "Width"] ?? "100%",
	//	_props[$ "Height"] ?? "100%"
	//);

	OptionCustom = new GUI_DropdownOption("Custom");

	CameraDropdown = new GUI_Dropdown({
		Width: 113,
		OnChange: method(Store.Camera, ApplyCameraSetting),
	}, [
		new GUI_DropdownOption("Isometric"),
		new GUI_DropdownOption("Isometric 45", { IsDefault: true }),
		new GUI_DropdownOption("Left"),
		new GUI_DropdownOption("Right"),
		new GUI_DropdownOption("Front"),
		new GUI_DropdownOption("Back"),
		new GUI_DropdownOption("Top"),
		new GUI_DropdownOption("Bottom"),
		OptionCustom,
	]);

	Add(new GUI_FloatingToolbar({
		X: 4,
		Y: 4,
		Spacing: 32,
	}, [
		new GUI_Text("Camera", { Color: #ABABAB }),
		CameraDropdown,
	]));

	ExpandExportOptionsButton = new (function (_props={}) : GUI_Widget(_props) constructor {
		BackgroundSprite = _props[$ "BackgroundSprite"] ?? ST_SprExportButton;

		BackgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;

		SetSize(
			_props[$ "Width"] ?? sprite_get_width(BackgroundSprite),
			_props[$ "Height"] ?? sprite_get_height(BackgroundSprite),
		);

		MaxChildCount = 0;

		static Draw = function () {
			draw_sprite_stretched(BackgroundSprite, BackgroundSubimage,
				RealX, RealY, RealWidth, RealHeight);
			return self;
		};
	})({
		AnchorLeft: 1.0,
		Y: 4,
		OnClick: method(self, function (_button) {
			Root.HSplitterRight.Right.SetProps({
				Visible: true,
			});
			FloatingToolbar.SetProps({
				X: FloatingToolbar.X + _button.RealWidth,
			});
			_button.SetProps({
				Visible: false,
			});
			RenderPreview.SetProps({
				Visible: false,
			});
		}),
	});
	Add(ExpandExportOptionsButton);

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
		new GUI_VBox({ Width: "100%", Padding: 8, Spacing: 4 }, [
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
		Height: 70, // TODO: "auto" sizing
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
		new GUI_VBox({ Width: "100%", Padding: 8, Spacing: 4 }, [
			new GUI_Text("Angle snap:"),
			new GUI_Input(ST_OMain.Gizmo.AngleSnap, {
				Width: "50%",
				Min: 0.0,
				Max: 360.0,
				Step: 1.0,
				OnChange: function (_value) {
					ST_OMain.Gizmo.AngleSnap = _value;
				},
			}, [
				new GUI_Checkbox(ST_OMain.Gizmo.EnableAngleSnap, {
					AnchorLeft: 1.0,
					PivotLeft: 1.0,
					X: 8,
					OnChange: function (_value) {
						ST_OMain.Gizmo.EnableAngleSnap = _value;
					},
				}, [
					new GUI_Text("Enabled", {
						AnchorLeft: 1.0,
						PivotLeft: 1.0,
						X: 8,
					}),
				])
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

	FloatingToolbar = new GUI_FloatingToolbar({
		Draggable: true,
		AnchorLeft: 1.0,
		X: -/*311*/280 - ExpandExportOptionsButton.Width,
		Y: 4,
	}, [
		new GUI_HBox({}, [
			new GUI_GlyphButton(ST_EIcon.ToolbarGridIcon, {
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
		]),
		new GUI_Separator({ Width: 2, Height: 24, BackgroundColor: #444444 }),
		new GUI_GlyphButton(ST_EIcon.ZoomOut, {
			Font: ST_FntIcons11,
			OnClick: method(Store.Camera, function () {
				Zoom += 1;
			}),
		}),
		new GUI_GlyphButton(ST_EIcon.ZoomReset, {
			Font: ST_FntIcons11,
			OnClick: method(Store, function () {
				Camera.Zoom = 10;
			}),
		}),
		new GUI_GlyphButton(ST_EIcon.ZoomIn, {
			Font: ST_FntIcons11,
			OnClick: method(Store.Camera, function () {
				Zoom = max(Zoom - 1, 1);
			}),
		}),
		new GUI_GlyphButton(ST_EIcon.ZoomCentreFit, {
			Font: ST_FntIcons11,
			OnClick: method(self, function () {
				var _cameraType = CameraDropdown.Selected.Value;
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
			}),
		}),
		new GUI_HBox({}, [
			new GUI_GlyphButton(ST_EIcon.WrenchWhite, {
				Font: ST_FntIcons11,
			}),
			new GUI_GlyphButton(ST_EIcon.ArrowDown, {
				Font: ST_FntIcons5,
				Width: 11,
				OnClick: method(self, function (_glyphButton) {
					ExtraOptions.SetProps({
						Visible: !ExtraOptions.Visible,
					});
				}),
			}, [
				ExtraOptions,
			]),
		]),
		new GUI_HBox({}, [
			new GUI_GlyphButton(ST_EIcon.Move, {
				Font: ST_FntIcons11,
				OnUpdate: function (_glyphButton) {
					switch (ST_OMain.Gizmo.EditType)
					{
					case BBMOD_EEditType.Position:
						_glyphButton.Glyph = ST_EIcon.Move;
						break;

					case BBMOD_EEditType.Rotation:
						_glyphButton.Glyph = ST_EIcon.RotateBrush;
						break;

					case BBMOD_EEditType.Scale:
						_glyphButton.Glyph = ST_EIcon.ScaleCursor;
						break;
					}
				},
			}),
			new GUI_GlyphButton(ST_EIcon.ArrowDown, {
				Font: ST_FntIcons5,
				Width: 11,
				OnClick: method(self, function (_glyphButton) {
					DropdownEditType.OnClick(DropdownEditType);
				}),
			}, [
				DropdownEditType,
			]),
		]),
		//new GUI_HBox({}, [
		//	new GUI_GlyphButton(ST_EIcon.NoSplit, {
		//		Font: ST_FntIcons11,
		//	}),
		//	new GUI_GlyphButton(ST_EIcon.ArrowDown, {
		//		Font: ST_FntIcons5,
		//		Width: 11,
		//	}),
		//]),
	]);
	Add(FloatingToolbar);

	RenderPreview = new ST_RenderPreviewWidget(Store, {
		AnchorLeft: 1.0,
		AnchorTop: 1.0,
		X: -10,
		Y: -18,
	});
	Add(RenderPreview);

	static Draw = function () {
		if (floor(RealWidth) <= 0 || floor(RealHeight) <= 0)
		{
			return self;
		}

		GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, BackgroundColor, BackgroundAlpha);
		Store.Renderer.set_rectangle(RealX, RealY, RealWidth, RealHeight);
		Store.Renderer.present();
		DrawChildren();

		return self;
	};
}
