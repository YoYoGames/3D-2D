/// @func ST_AnimationPlayerWidget(_store[, _props])
///
/// @extends GUI_Canvas
///
/// @desc
///
/// @param {Id.Instance, Store} _store
/// @param {Struct} [_props]
function ST_AnimationPlayerWidget(_store, _props={})
	: GUI_Canvas(_props) constructor
{
	/// @var {Id.Instance, Store}
	Store = _store;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? 45
	);

	BackgroundSprite = _props[$ "BackgroundSprite"] ?? ST_SprAnimationPlayerBackground;

	HBoxLeft = new GUI_HBox({
		Spacing: 7,
		X: 10,
		Y: 10,
	}, [
		new GUI_Input(Store.Asset ? Store.Asset.SamplingRate : 30, {
			Width: 50,
			Min: 1,
			Max: 60,
			WholeNumbers: true,
			Draggable: false,
			OnChange: method(self, function (_value) {
				var _asset = Store.Asset;
				if (_asset && _asset.IsAnimated)
				{
					_asset.SamplingRate = _value;
					Store.AssetImporter.Reload(Store.Asset);
					TriggerEvent(new GUI_Event("AnimationChange", {
						Animation: _asset.AnimationIndex,
						AnimationOld: _asset.AnimationIndex,
					}));
				}
			}),
		}),
		new GUI_Text("FPS"),
	]);
	Add(HBoxLeft);

	ButtonPlay = new (function (_store, _props={}) : GUI_Widget(_props) constructor {
		Store = _store;

		AnchorLeft = 0.5;

		Y = 10;

		SetSize(sprite_get_width(ST_SprPause), sprite_get_height(ST_SprPause));

		OnClick = function () {
			if (Store.Asset)
			{
				Store.Asset.AnimationPlayer.Paused = !Store.Asset.AnimationPlayer.Paused;
			}
		};

		static Draw = function () {
			// TODO: Use Glyphs
			var _sprite = (Store.Asset && Store.Asset.AnimationPlayer.Paused)
				? ST_SprPlay
				: ST_SprPause;
			draw_sprite(_sprite, 0, RealX, RealY);
			return self;
		};
	})(Store);
	Add(ButtonPlay);

	HBoxRight = new GUI_HBox({
		AnchorLeft: 1.0,
		X: -140,
		Y: 10,
		Spacing: 6,
	}, [
		new GUI_Text("Frame"),
		new GUI_Input(0, {
			Width: 50,
			Min: 0,
			WholeNumbers: true,
			OnUpdate: method(self, function (_input) {
				var _asset = Store.Asset;

				with (_input)
				{
					if (_asset && _asset.IsAnimated)
					{
						var _animationPlayer = _asset.AnimationPlayer;
						var _animation = _animationPlayer.Animation;

						Max = _animation.Duration - 1;

						if (IsDragged())
						{
							_animationPlayer.Time = Value / _animation.TicsPerSecond;
						}
						else if (!IsFocused())
						{
							Value = _animation.get_animation_time(_animationPlayer.Time);
						}
					}
					else
					{
						Max = 1;
					}
				}
			}),
			OnChange: method(self, function (_value) {
				var _asset = Store.Asset;
				if (_asset && _asset.IsAnimated)
				{
					_asset.AnimationPlayer.Time = _value / _asset.AnimationPlayer.Animation.TicsPerSecond;
				}
			}),
		}),
		new GUI_Text("/"),
		new GUI_Text("1", {
			OnUpdate: method(self, function (_text) {
				var _asset = Store.Asset;
				if (_asset && _asset.IsAnimated)
				{
					var _animationPlayer = _asset.AnimationPlayer;
					var _animation = _animationPlayer.Animation;
					_text.Text = string(_animation.Duration - 1);
				}
				else
				{
					_text.Text = "1";
				}
			}),
		}),
	]);
	Add(HBoxRight);
}
