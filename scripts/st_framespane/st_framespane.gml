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
		Spacing: 2,
	});
	Canvas.Add(framesHBox);

	if (Store.Asset)
	{
		AddFrames();
	}

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
