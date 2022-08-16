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

		SetSize(
			_props[$ "Width"] ?? sprite_get_width(BackgroundSprite),
			_props[$ "Height"] ?? sprite_get_height(BackgroundSprite),
		);

		MaxChildCount = 0;

		static Draw = function () {
			draw_sprite_stretched(BackgroundSprite, 0, RealX, RealY, RealWidth, RealHeight);
			return self;
		};
	})({
		AnchorLeft: 1.0,
		Y: 4,
		OnClick: method(self, function (_button) {
			Root.HSplitterRight.Right.SetProps({
				"Visible": true,
			});
			FloatingToolbar.SetProps({
				"X": FloatingToolbar.X + _button.RealWidth,
			});
			_button.SetProps({
				"Visible": false,
			});
			RenderPreview.SetProps({
				"Visible": false,
			});
		}),
	});
	Add(ExpandExportOptionsButton);

	FloatingToolbar = new GUI_FloatingToolbar({
		Draggable: true,
		AnchorLeft: 1.0,
		X: -/*311*/240 - ExpandExportOptionsButton.Width,
		Y: 4,
	}, [
		new GUI_HBox({}, [
			new GUI_IconButton(GUI_SprGridIcon), // TODO: Grid glyph
			new GUI_IconButton(GUI_SprCaretDownIcon, 0, { Width: 11 }),
		]),
		new GUI_Separator({ Width: 2, Height: 24, BackgroundColor: #444444 }),
		new GUI_GlyphButton(ST_EIcon.ZoomOut, {
			Font: ST_FntIcons,
			OnClick: method(Store.Camera, function () {
				Zoom += 1;
			}),
		}),
		new GUI_GlyphButton(ST_EIcon.ZoomReset, {
			Font: ST_FntIcons,
			OnClick: method(Store, function () {
				Camera.Zoom = 10;
			}),
		}),
		new GUI_GlyphButton(ST_EIcon.ZoomIn, {
			Font: ST_FntIcons,
			OnClick: method(Store.Camera, function () {
				Zoom = max(Zoom - 1, 1);
			}),
		}),
		new GUI_GlyphButton(ST_EIcon.ZoomCentreFit, {
			Font: ST_FntIcons,
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
		//new GUI_HBox({}, [
		//	new GUI_IconButton(GUI_SprWrenchIcon),
		//	new GUI_IconButton(GUI_SprCaretDownIcon, 0, { Width: 11 }),
		//]),
		new GUI_HBox({}, [
			new GUI_GlyphButton(ST_EIcon.Move, {
				Font: ST_FntIcons,
			}),
			new GUI_IconButton(GUI_SprCaretDownIcon, 0, { Width: 11 }),
		]),
		//new GUI_HBox({}, [
		//	new GUI_IconButton(GUI_SprSquareOutlineIcon),
		//	new GUI_IconButton(GUI_SprCaretDownIcon, 0, { Width: 11 }),
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
