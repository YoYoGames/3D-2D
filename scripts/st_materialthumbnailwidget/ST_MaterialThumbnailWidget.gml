/// @var {Real}
global.__stMaterialSelected = 0;

/// @func ST_MaterialThumbnailWidget(_asset, _materialIndex[, _props])
///
/// @externs ST_ThumbnailWidget
///
/// @desc
///
/// @param {Struct.ST_Asset} _asset
/// @param {Real} _materialIndex
/// @param {Struct} [_props]
function ST_MaterialThumbnailWidget(_asset, _materialIndex, _props={})
	: ST_ThumbnailWidget(_props) constructor
{
	/// @var {Struct.ST_Asset}
	Asset = _asset;

	/// @var {Real}
	MaterialIndex = _materialIndex;

	Tooltip = "Select texture for " + Asset.Model.MaterialNames[MaterialIndex] + " material...";

	SetHeight(135);

	OnMouseEnter = function () {
		ST_HighlightAssetMaterial(Asset, MaterialIndex);
	};

	OnMouseLeave = function () {
		ST_HighlightAssetMaterial(undefined);
	};

	OnClick = function () {
		global.__stMaterialSelected = MaterialIndex;
		var _path = get_open_filename(ST_FILTER_TEXTURE, "");
		if (_path != "")
		{
			var _sprite = Asset.LoadSprite(_path);
			Asset.Materials[MaterialIndex].BaseOpacity = sprite_get_texture(_sprite, 0);
			Asset.MaterialSprites[@ MaterialIndex] = _path;
		}
	};

	OnUpdate = function () {
		Selected = (global.__stMaterialSelected == MaterialIndex);
	};

	Add(new GUI_CloseButton({
		AnchorLeft: 1.0,
		X: -4,
		Y: 24,
		Tooltip: "Remove texture",
		OnMouseEnter: OnMouseEnter,
		OnMouseLeave: OnMouseLeave,
		OnClick: method(self, function () {
			// TODO: Free the sprite maybe?
			Asset.Materials[MaterialIndex].BaseOpacity = pointer_null;
			Asset.MaterialSprites[@ MaterialIndex] = undefined;
		}),
	}));

	Add(new GUI_ColorInput(Asset.Materials[MaterialIndex].BaseOpacityMultiplier, {
		AnchorTop: 1.0,
		Width: "100%",
		Height: 24,
		OnMouseEnter: OnMouseEnter,
		OnMouseLeave: OnMouseLeave,
	}));

	static Draw = function () {
		var _backgroundHeight = sprite_get_height(BackgroundSprite);

		// Background
		var _backgroundY = RealY + 20;
		draw_sprite(BackgroundSprite, Selected, RealX, _backgroundY);

		// Material name
		var _materialName = GUI_GetTextPartLeft(Asset.Model.MaterialNames[MaterialIndex], RealWidth);
		var _textX = RealX + floor((RealWidth - string_width(_materialName)) * 0.5);
		var _textY = RealY;
		GUI_DrawText(_textX, _textY, _materialName, #C0C0C0);

		// Material preview
		if (Asset.MaterialsPreview != undefined)
		{
			var _surface = Asset.MaterialsPreview[MaterialIndex];
			if (surface_exists(_surface))
			{
				gpu_push_state();
				gpu_set_tex_filter(true);

				var _surfaceWidth = surface_get_width(_surface);
				var _surfaceHeight = surface_get_height(_surface);
				var _max = max(_surfaceWidth, _surfaceHeight);
				var _scale = min(RealWidth - 4, _backgroundHeight - 4) / _max;
				draw_surface_ext(
					_surface,
					RealX + floor((RealWidth  - (_surfaceWidth  * _scale)) * 0.5),
					_backgroundY + floor((_backgroundHeight - (_surfaceHeight * _scale)) * 0.5),
					_scale, _scale, 0.0, c_white, 1.0);

				gpu_pop_state();
			}
		}

		DrawChildren();

		return self;
	};
};
