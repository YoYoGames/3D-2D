/// @func ST_RenderPreviewWidget(_store[, _props])
///
/// @extends GUI_Canvas
///
/// @desc
///
/// @param {Id.Instance, Struct} _store
/// @param {Struct} [_props]
function ST_RenderPreviewWidget(_store, _props={})
	: GUI_Widget(_props) constructor
{
	/// @var {Id.Instance, Struct}
	Store = _store;

	SetWidth(_props[$ "Width"] ?? 437);

	Header = new GUI_SectionHeader("Render Preview", {
		BackgroundSprite: undefined,
		Collapsed: true,
	});
	Add(Header);

	Toolbar = new GUI_HBox({
		Spacing: 4,
		X: 280,
	}, [
		new GUI_GlyphButton(ST_EIcon.ArrowLeft, {
			Font: ST_FntIcons11,
			BackgroundSprite: undefined,
			OnClick: method(self, function () {
				Root.ExportOptionsPane.ExportOptions.DropdownCamera.SelectPrev();
			}),
		}),
		new GUI_Text("", {
			Width: 72,
			OnUpdate: method(self, function (_text) {
				_text.Text = Root.ExportOptionsPane.ExportOptions.DropdownCamera.Selected.Text;
			}),
		}),
		new GUI_GlyphButton(ST_EIcon.ExpandClosed, {
			Font: ST_FntIcons11,
			BackgroundSprite: undefined,
			OnClick: method(self, function () {
				Root.ExportOptionsPane.ExportOptions.DropdownCamera.SelectNext();
			}),
		}),
		new GUI_GlyphButton(ST_EIcon.Settings, {
			Font: ST_FntIcons11,
			BackgroundSprite: undefined,
			OnClick: method(self, function () {
				var _expandExportOptionsButton = Root.Viewport.ExpandExportOptionsButton;
				_expandExportOptionsButton.OnClick(_expandExportOptionsButton);
			}),
		}),
	]);
	Add(Toolbar);

	static Widget_Update = Update;

	static Update = function () {
		Widget_Update();
		SetHeight(Header.Collapsed ? Header.Height : 244);
		Toolbar.SetProps({
			Visible: !Header.Collapsed,
		});
		return self;
	};

	static Draw = function () {
		if (!Header.Collapsed)
		{
			GUI_DrawShadow(RealX, RealY, RealWidth, RealHeight);
		}
		GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, Header.Collapsed ? #3F3F3F : c_black);
		if (!Header.Collapsed && Store.Asset)
		{
			Store.AssetRenderer.DrawPreview(Store.Asset, RealX, RealY, RealWidth, RealHeight);
		}
		DrawChildren();
		draw_sprite_stretched(GUI_SprContainerBorder, 0, RealX, RealY, RealWidth, RealHeight);
		return self;
	};
}
