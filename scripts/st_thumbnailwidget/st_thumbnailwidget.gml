/// @func ST_ThumbnailWidget([_props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
function ST_ThumbnailWidget(_props={})
	: GUI_Widget(_props) constructor
{
	/// @var {Bool}
	Selected = _props[$ "Selected"] ?? false;

	/// @var {Asset.GMSprite}
	BackgroundSprite = _props[$ "BackgroundSprite"] ?? ST_SprThumbnail;

	SetSize(
		sprite_get_width(BackgroundSprite),
		sprite_get_height(BackgroundSprite)
	);

	static Draw = function () {
		draw_sprite(BackgroundSprite, Selected, RealX, RealY);
		DrawChildren();
		return self;
	};
};
