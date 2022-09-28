/// @func GUI_Scrollbar([_props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
function GUI_Scrollbar(_props={})
	: GUI_Widget(_props) constructor
{
	MaxChildCount = 0;

	/// @var {Real}
	/// @ignore
	Scroll = 0;

	/// @var {Real}
	/// @ignore
	ScrollJump = 1;

	/// @var {Real}
	/// @ignore
	MouseOffset = 0;

	/// @var {Real}
	MinThumbSize = _props[$ "MinThumbSize"] ?? GUI_LINE_HEIGHT;

	/// @var {Real}
	/// @ignore
	ThumbSize = MinThumbSize;

	/// @var {Constant.Color}
	Color = _props[$ "Color"] ?? #555555;

	/// @var {Asset.GMSprite}
	Sprite = _props[$ "Sprite"] ?? GUI_SprScrollbar;

	/// @var {Asset.GMSprite}
	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprScrollbarBackground;

	/// @var {Real}
	BackgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;

	/// @func CalcJumpAndThumbSize()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Scrollbar} Returns `self`.
	static CalcJumpAndThumbSize = function (_size, _contentSize) {
		var _viewableRatio = _size / _contentSize;
		var _scrollBarArea = _size;
		var _thumbSize = max(MinThumbSize, _scrollBarArea * _viewableRatio);
		ThumbSize = _thumbSize;

		var _scrollTrackSpace = _contentSize - _size;
		var _scrollThumbSpace = _size - _thumbSize;
		ScrollJump = _scrollTrackSpace / _scrollThumbSpace;

		return self;
	};

	/// @func GetScroll()
	///
	/// @desc
	///
	/// @return {Real}
	static GetScroll = function () {
		gml_pragma("forceinline");
		return round(Scroll * ScrollJump);
	};

	/// @func SetScroll()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static SetScroll = function (_scroll) {
		gml_pragma("forceinline");
		SetProps({
			Scroll: _scroll / ScrollJump,
		});
		return self;
	};
}
