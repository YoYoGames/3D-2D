/// @func ST_TransformWidget(_asset[, _props])
///
/// @extends GUI_VBox
///
/// @desc
///
/// @param {Struct.ST_Asset} _asset
/// @param {Struct} [_props]
function ST_TransformWidget(_asset, _props={})
	: GUI_FlexLayout(_props) constructor
{
	/// @var {Struct.ST_Asset}
	Asset = _asset;

	FlexDirection = _props[$ "FlexDirection"] ?? "column";

	Gap = _props[$ "Gap"] ?? 12;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? "auto"
	);

	var _columnWidth = 109;
	var _styleLabel = {
		Width: _columnWidth,
		MaxWidth: "25%",
	};

	PositionInput = new ST_VectorInput(Asset.Position, {
		Step: 0.1,
		FlexGrow: 1,
	});

	RotationInput = new ST_VectorInput(Asset.Rotation, {
		FlexGrow: 1,
	});

	ScaleInput = new ST_VectorInput(Asset.Scale, {
		Step: 0.01,
		FlexGrow: 1,
	});

	// TODO: Implement reloading assets with new settings
	ButtonMirrorUV = new GUI_GlyphButton(ST_EIcon.FlipBrushHorizontal, {
		Tooltip: "Flip UVs Horizontally",
		Font: ST_FntIcons11,
		Minimal: true,
		OnClick: method(self, function () {
			Asset.FlipUVHorizontally = !Asset.FlipUVHorizontally;
			ST_OMain.AssetImporter.Reload(Asset);
		}),
	});

	ButtonFlipUV = new GUI_GlyphButton(ST_EIcon.FlipBrushVertical, {
		Tooltip: "Flip UVs Vertically",
		Font: ST_FntIcons11,
		Minimal: true,
		OnClick: method(self, function () {
			Asset.FlipUVVertically = !Asset.FlipUVVertically;
			ST_OMain.AssetImporter.Reload(Asset);
		}),
	});

	Add(
		new GUI_FlexLayout({
			Width: "100%",
			Height: "auto",
		}, [
			new GUI_Text("Position", _styleLabel),
			PositionInput,
		])
	);

	Add(
		new GUI_FlexLayout({
			Width: "100%",
			Height: "auto",
		}, [
			new GUI_Text("Rotation", _styleLabel),
			RotationInput,
		])
	);

	Add(
		new GUI_FlexLayout({
			Width: "100%",
			Height: "auto",
		}, [
			new GUI_Text("Scale", _styleLabel),
			ScaleInput,
		])
	);

	Add(
		new GUI_FlexLayout({
			Width: "100%",
			Height: "auto",
		}, [
			new GUI_Text("Flip UV", _styleLabel),
			ButtonMirrorUV,
			ButtonFlipUV,
		])
	);
}
