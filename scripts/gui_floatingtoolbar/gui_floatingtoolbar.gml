/// @func GUI_FloatingToolbar([_props[, _children]])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_FloatingToolbar(_props={}, _children=[])
	: GUI_Widget(_props) constructor
{
	/// @var {Asset.GMSprite}
	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprFloatingToolbar;

	/// @var {Real}
	BackgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;

	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? c_black;

	/// @var {Real}
	BackgroundAlpha = _props[$ "BackgroundAlpha"] ?? 0.75;

	MinWidth = _props[$ "MinWidth"] ?? Draggable ? 17 : 32;

	Height = _props[$ "Height"] ?? 37;

	OnDrag = function (_self, _diffX, _diffY) {
		SetProps({
			"X": X + _diffX,
		});
	};

	Container = new GUI_HBox({
		X: Draggable ? 17 : 5,
		Y: 7,
		Spacing: _props[$ "Spacing"] ?? 8,
	});
	Widget_Add(Container);

	var i = 0;
	repeat (array_length(_children))
	{
		Add(_children[i++]);
	}

	static Widget_Layout = Layout;

	static Layout = function (_force=false) {
		CHECK_LAYOUT_CHANGED;
		Widget_Layout(_force);
		SetProps({
			"RealWidth": GetInnerBoundingBox()[2] - RealX + 5,
		});
		return self;
	};

	static Widget_Add = Add;

	static Add = function (_widget) {
		gml_pragma("forceinline");
		Container.Add(_widget);
		return self;
	};

	static Draw = function () {
		draw_sprite_stretched_ext(BackgroundSprite, BackgroundSubimage,
			RealX, RealY, RealWidth, RealHeight,
			BackgroundColor, BackgroundAlpha);
		if (Draggable)
		{
			draw_sprite(GUI_SprFloatingToolbarDrag, 0, RealX + 4,
				RealY + floor((RealHeight - sprite_get_height(GUI_SprFloatingToolbarDrag)) * 0.5));
		}
		DrawChildren();
		return self;
	};
}
