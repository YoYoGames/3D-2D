/// @func ST_FrameThumbnailWidget(_store, _animationIndex, _frame[, _props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Id.Instance, Struct} _store
/// @param {Real} _animationIndex
/// @param {Real} _frame
/// @param {Struct} [_props]
function ST_FrameThumbnailWidget(_store, _animationIndex, _frame, _props={})
	: GUI_Widget(_props) constructor
{
	/// @var {Id.Instance, Struct}
	Store = _store;

	/// @var {Real}
	AnimationIndex = _animationIndex;

	/// @var {Real}
	Frame = _frame;

	SetSize(
		_props[$ "Width"] ?? 88,
		_props[$ "Height"] ?? 81
	);

	OnClick = function () {
		var _asset = Store.Asset;
		var _enabled = _asset.FrameFilters[AnimationIndex][Frame];
		if (_enabled)
		{
			_asset.AnimationPlayer.Time = Frame / _asset.AnimationPlayer.Animation.TicsPerSecond;
		}
	};

	Checkbox = new GUI_Checkbox(Store.Asset.FrameFilters[AnimationIndex][Frame], {
		AnchorLeft: 1.0,
		X: -4,
		Y: 4,
		OnChange: method(self, function (_value) {
			Store.Asset.FrameFilters[AnimationIndex][@ Frame] = _value;
		}),
	});
	Add(Checkbox);

	static Draw = function () {
		var _enabled = Store.Asset.FrameFilters[AnimationIndex][Frame];

		draw_sprite_stretched_ext(ST_SprFrameBackground, 0, RealX, RealY, RealWidth, RealHeight,
			_enabled ? c_white : c_silver, 1.0);

		if (Store.Asset.AnimationsPreview != undefined)
		{
			var _surface = Store.Asset.AnimationsPreview[AnimationIndex][Frame];
			if (surface_exists(_surface))
			{
				//gpu_push_state();
				//gpu_set_tex_filter(true);

				var _surfaceWidth = surface_get_width(_surface);
				var _surfaceHeight = surface_get_height(_surface);
				var _max = max(_surfaceWidth, _surfaceHeight);
				var _scale = min(RealWidth - 2, RealHeight - 2) / _max;
				draw_surface_ext(
					_surface,
					RealX + floor((RealWidth  - (_surfaceWidth  * _scale)) * 0.5),
					RealY + floor((RealHeight - (_surfaceHeight * _scale)) * 0.5),
					_scale, _scale, 0.0, _enabled ? c_white : c_gray, 1.0);

				var _asset = Store.Asset;

				if (_asset
					&& _asset.IsAnimated
					&& _asset.AnimationPlayer.Animation.get_animation_time(_asset.AnimationPlayer.Time) == Frame)
				{
					GUI_DrawRectangle(RealX + 1, RealY + RealHeight, RealWidth - 2, 5, #1C899A);
				}

				//gpu_pop_state();
			}
		}

		DrawChildren();

		return self;
	};
}
