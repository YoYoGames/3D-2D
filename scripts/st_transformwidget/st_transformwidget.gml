/// @func ST_TransformWidget(_asset[, _props])
///
/// @extends GUI_VBox
///
/// @desc
///
/// @param {Struct.ST_Asset} _asset
/// @param {Struct} [_props]
function ST_TransformWidget(_asset, _props={})
	: GUI_VBox(_props) constructor
{
	/// @var {Struct.ST_Asset}
	Asset = _asset;

	Spacing = _props[$ "Spacing"] ?? 12;

	SetWidth(_props[$ "Width"] ?? "100%");

	var _columnRightX = 109;

	var _textPosition = new GUI_Text("Position");
	Add(_textPosition);

	PositionInput = new ST_VectorInput(Asset.Position, { X: _columnRightX, Step: 0.1 });
	_textPosition.Add(PositionInput);

	var _textRotation = new GUI_Text("Rotation");
	Add(_textRotation);

	RotationInput = new ST_VectorInput(Asset.Rotation, { X: _columnRightX });
	_textRotation.Add(RotationInput);

	var _textScale = new GUI_Text("Scale");
	Add(_textScale);

	ScaleInput = new ST_VectorInput(Asset.Scale, { X: _columnRightX, Step: 0.01 });
	_textScale.Add(ScaleInput);

	var _textFlipUV = new GUI_Text("Flip UV");
	Add(_textFlipUV);

	var _hboxFlipUV = new GUI_HBox({ X: _columnRightX, Spacing: 4 });
	_textFlipUV.Add(_hboxFlipUV);

	// TODO: Implement reloading assets with new settings
	ButtonMirrorUV = new GUI_GlyphButton(ST_EIcon.FlipBrushHorizontal, {
		Font: ST_FntIcons,
		BackgroundSprite: undefined,
		OnClick: method(self, function () {
			Asset.FlipUVHorizontally = !Asset.FlipUVHorizontally;
			ST_OMain.AssetImporter.Reload(Asset);
		}),
	});
	_hboxFlipUV.Add(ButtonMirrorUV);

	ButtonFlipUV = new GUI_GlyphButton(ST_EIcon.FlipBrushVertical, {
		Font: ST_FntIcons,
		BackgroundSprite: undefined,
		OnClick: method(self, function () {
			Asset.FlipUVVertically = !Asset.FlipUVVertically;
			ST_OMain.AssetImporter.Reload(Asset);
		}),
	});
	_hboxFlipUV.Add(ButtonFlipUV);
}
