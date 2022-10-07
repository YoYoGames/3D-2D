/// @func ST_FramesPane(_store[, _props])
///
/// @extends GUI_ScrollPane
///
/// @desc
///
/// @param {Id.Instance, Struct} _store
/// @param {Struct} [_props]
function ST_FramesPane(_store, _props={})
	: GUI_ScrollPane(_props) constructor
{
	/// @var {Id.Instance, Struct}
	Store = _store;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? 113
	);

	EnableScrollbarV = false;

	framesHBox = new GUI_HBox({
		Y: 9,
		Gap: 2,
	});
	Canvas.Add(framesHBox);

	if (Store.Asset)
	{
		AddFrames();
	}

	ScrollbarH.OnUpdate = method(self, function (_scrollbar) {
		// Automatically scroll to the current frame when the animation player
		// isn't paused
		if (Store.Asset
			&& Store.Asset.AnimationPlayer
			&& Store.Asset.AnimationPlayer.Paused)
		{
			return;
		}

		var _baseX = RealX + Canvas.ScrollX;
		var _frames = framesHBox.Children;
		var _frameCount = array_length(_frames);

		for (var i = 0; i < _frameCount; ++i)
		{
			with (_frames[i])
			{
				if (IsCurrentFrame())
				{
					_scrollbar.SetScroll(RealX - _baseX);
				}
			}
		}
	});

	/// @func AddFrames()
	///
	/// @desc
	///
	/// @return {Struct.ST_FramesPane} Returns `self`.
	static AddFrames = function () {
		framesHBox.RemoveChildWidgets();
		var _animationIndex = Store.Asset.AnimationIndex;
		if (_animationIndex != undefined)
		{
			var _animationDuration = Store.Asset.Animations[_animationIndex].Duration;
			for (var i = 0; i < _animationDuration; ++i)
			{
				framesHBox.Add(new ST_FrameThumbnailWidget(Store, _animationIndex, i));
			}
		}
		return self;
	};
}
