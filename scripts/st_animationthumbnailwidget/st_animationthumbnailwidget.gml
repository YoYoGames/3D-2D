/// @func ST_AnimationThumbnailWidget(_asset, _animationIndex[, _props])
///
/// @externs ST_ThumbnailWidget
///
/// @desc
///
/// @param {Struct.ST_Asset} _asset
/// @param {Real} _animationIndex
/// @param {Struct} [_props]
function ST_AnimationThumbnailWidget(_asset, _animationIndex, _props={})
	: ST_ThumbnailWidget(_props) constructor
{
	/// @var {Struct.ST_Asset}
	Asset = _asset;

	/// @var {Real}
	AnimationIndex = _animationIndex;

	SetHeight(120);

	OnClick = function () {
		var _animationOld = Asset.AnimationIndex;
		Asset.PlayAnimation(AnimationIndex);
		TriggerEvent(new GUI_Event("AnimationChange", {
			Animation: AnimationIndex,
			AnimationOld: _animationOld,
		}));
	};

	OnUpdate = function () {
		Selected = (Asset.AnimationIndex == AnimationIndex);
	};

	static ThumbnailWidget_Draw = Draw;

	static Draw = function () {
		ThumbnailWidget_Draw();

		var _backgroundHeight = sprite_get_height(BackgroundSprite);

		// Animation preview
		if (Asset.AnimationsPreview != undefined)
		{
			var _frame = floor(Asset.Animations[AnimationIndex].Duration / 2);
			var _surface = Asset.AnimationsPreview[AnimationIndex][_frame];
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
					RealY + floor((_backgroundHeight - (_surfaceHeight * _scale)) * 0.5),
					_scale, _scale, 0.0, c_white, 1.0);

				gpu_pop_state();
			}
		}

		// Animation name
		var _animationName = GUI_GetTextPartLeft(Asset.AnimationNames[AnimationIndex], RealWidth);
		var _textX = RealX + floor((RealWidth - string_width(_animationName)) * 0.5);
		var _textAreaHeight = RealHeight - _backgroundHeight;
		var _textY = RealY + _backgroundHeight + floor((_textAreaHeight - GUI_LINE_HEIGHT) * 0.5);
		GUI_DrawText(_textX, _textY, _animationName, #C0C0C0);

		return self;
	};
};
