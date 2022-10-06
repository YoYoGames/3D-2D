/// @func ST_ExportOptionsPane(_store[, _props])
///
/// @extends GUI_ScrollPane
///
/// @desc
///
/// @param {Id.Instance, Struct} _store
/// @param {Struct} [_props]
function ST_ExportOptionsPane(_store, _props={})
	: GUI_ScrollPane(_props) constructor
{
	/// @var {Id.Instance, Struct}
	Store = _store;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? "100%"
	);

	EnableScrollbarH = false;

	ExportOptions = new ST_ExportOptionsWidget(Store);

	Canvas.Add(new GUI_VBox({
		Width: "100%",
		Gap: 2,
	}, [
		new GUI_Tab("Export Options", {
			Height: 46,
			IsSelected: true,
		}, [
			new GUI_GlyphButton(ST_EIcon.CloseSemibold, {
				Font: ST_FntIcons11,
				BackgroundSprite: undefined,
				AnchorLeft: 1.0,
				AnchorTop: 0.5,
				X: -19,
				OnClick: function (_iconButton) {
					_iconButton.Root.HSplitterRight.Right.SetProps({
						Visible: false,
					});
					var _expandExportOptionsButton = _iconButton.Root.Viewport.ExpandExportOptionsButton;
					_expandExportOptionsButton.SetProps({
						Visible: true,
					});
					var _floatingToolbar = _iconButton.Root.Viewport.FloatingToolbar;
					_floatingToolbar.SetProps({
						X: _floatingToolbar.X - _expandExportOptionsButton.Width,
					})
					_iconButton.Root.Viewport.RenderPreview.SetProps({
						Visible: true,
					});
				},
			}),
		]),
		ExportOptions,
	]));
}
