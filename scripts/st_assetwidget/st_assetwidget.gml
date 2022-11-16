/// @func ST_AssetWidget(_asset[, _props])
///
/// @extends GUI_VBox
///
/// @desc
///
/// @param {Struct.ST_Asset} _asset
/// @param {Struct} [_props]
function ST_AssetWidget(_asset, _props={})
	: GUI_VBox(_props) constructor
{
	Asset = _asset;

	SetWidth(_props[$ "Width"] ?? "100%");

	////////////////////////////////////////////////////////////////////////////
	// Transform
	SectionTransform = new GUI_VBox({
		Width: "100%",
		PaddingLeft: 19,
		PaddingRight: 19,
		PaddingTop: 12,
		PaddingBottom: 12,
	}, [
		new ST_TransformWidget(Asset),
	]);

	TextTransform = new GUI_SectionHeader("Transform", { Target: SectionTransform });

	Add(TextTransform);
	Add(SectionTransform);

	////////////////////////////////////////////////////////////////////////////
	// Animations
	if (array_length(Asset.Animations) > 0)
	{
		SectionAnimations = new GUI_VBox({
			Width: "100%",
			PaddingLeft: 19,
			PaddingRight: 19,
			PaddingTop: 12,
			PaddingBottom: 12,
		});

		TextAnimations = new GUI_SectionHeader("Animations", { Target: SectionAnimations });

		TextAnimations.Add(new GUI_GlyphButton(ST_EIcon.Grid, {
			Font: ST_FntIcons11,
			Minimal: true,
			AnchorLeft: 1.0,
			OnClick: method(self, function (_iconButton) {
				_iconButton.SetProps({
					Glyph: (_iconButton.Glyph == ST_EIcon.Grid)
						? ST_EIcon.ListView : ST_EIcon.Grid,
				});
				AnimationsGridContainer.SetProps({
					Visible: !AnimationsGridContainer.Visible,
				});
				AnimationsList.SetProps({
					Visible: !AnimationsList.Visible,
				});
			}),
		}));

		var _animationsRowHeight = 128;

		AnimationsGridContainer = new GUI_Container({
			Width: "100%",
			MinWidth: 401,
			Height: _animationsRowHeight * ((array_length(Asset.Animations) > 4) ? 2 : 1),
		});
		AnimationsGridContainer.Canvas.Padding = 4;
		SectionAnimations.Add(AnimationsGridContainer);

		AnimationsGrid = new GUI_Grid(4, undefined, {
			Width: "100%",
		});
		AnimationsGridContainer.Add(AnimationsGrid);

		AnimationsList = new GUI_SelectList({
			Width: "100%",
			Height: _animationsRowHeight,
			Visible: false,
		});
		SectionAnimations.Add(AnimationsList);

		for (var i = 0; i < array_length(Asset.Animations); ++i)
		{
			AnimationsGrid.Add(new ST_AnimationThumbnailWidget(Asset, i));

			var _selectListItem = new GUI_SelectListItem(Asset.AnimationNames[i], {
				OnClick: method(self, function (_selectListItem) {
					var _animationOld = Asset.AnimationIndex;
					Asset.PlayAnimation(_selectListItem.AnimationIndex);
					TriggerEvent(new GUI_Event("AnimationChange", {
						Animation: _selectListItem.AnimationIndex,
						AnimationOld: _animationOld,
					}));
				}),
				OnUpdate: method(self, function (_selectListItem) {
					_selectListItem.IsSelected =
						(Asset.AnimationIndex == _selectListItem.AnimationIndex);
				}),
			});
			_selectListItem.AnimationIndex = i;
			AnimationsList.Add(_selectListItem);
		}

		Add(TextAnimations);
		Add(SectionAnimations);
	}

	////////////////////////////////////////////////////////////////////////////
	// Materials
	if (array_length(Asset.Materials) > 0)
	{
		SectionMaterials = new GUI_VBox({
			Width: "100%",
			PaddingLeft: 19,
			PaddingRight: 19,
			PaddingTop: 12,
			PaddingBottom: 12,
		});

		TextMaterials = new GUI_SectionHeader("Materials", { Target: SectionMaterials });

		//TextMaterials.Add(new GUI_GlyphButton(ST_EIcon.Grid, {
		//	BackgroundSprite: undefined,
		//	AnchorLeft: 1.0,
		//	OnClick: method(self, function (_iconButton) {
		//		_iconButton.SetProps({
		//			Glyph: (_iconButton.Glyph == ST_EIcon.Grid)
		//				? ST_EIcon.List : ST_EIcon.Grid,
		//		});
		//		MaterialsGridContainer.SetProps({
		//			Visible: !MaterialsGridContainer.Visible,
		//		});
		//		MaterialsList.SetProps({
		//			Visible: !MaterialsList.Visible,
		//		});
		//	}),
		//}));

		var _materialsRowHeight = 148;

		MaterialsGridContainer = new GUI_Container({
			Width: "100%",
			MinWidth: 401,
			Height: _materialsRowHeight * ((array_length(Asset.Materials) > 4) ? 2 : 1),
		});
		MaterialsGridContainer.Canvas.Padding = 4;
		SectionMaterials.Add(MaterialsGridContainer);

		MaterialsGrid = new GUI_Grid(4, undefined, {
			Width: "100%",
		});
		MaterialsGridContainer.Add(MaterialsGrid);

		//MaterialsList = new GUI_SelectList({
		//	Width: "100%",
		//	Height: _materialsRowHeight,
		//	Visible: false,
		//});
		//SectionMaterials.Add(MaterialsList);

		for (var i = 0; i < array_length(Asset.Materials); ++i)
		{
			MaterialsGrid.Add(new ST_MaterialThumbnailWidget(Asset, i));

			//var _selectListItem = new GUI_SelectListItem(Asset.Model.MaterialNames[i], {
			//	OnMouseEnter: method(self, function (_selectListItem) {
			//		ST_HighlightAssetMaterial(Asset, _selectListItem.MaterialIndex);
			//	}),
			//	OnMouseLeave: method(self, function (_selectListItem) {
			//		ST_HighlightAssetMaterial(undefined);
			//	}),
			//	OnClick: method(self, function (_selectListItem) {
			//		global.__stMaterialSelected = _selectListItem.MaterialIndex;
			//	}),
			//	OnUpdate: method(self, function (_selectListItem) {
			//		_selectListItem.IsSelected =
			//			(global.__stMaterialSelected == _selectListItem.MaterialIndex);
			//	}),
			//});
			//_selectListItem.MaterialIndex = i;
			//MaterialsList.Add(_selectListItem);
		}

		Add(TextMaterials);
		Add(SectionMaterials);
	}

	MaxChildCount = array_length(Children);
}
