/// @func GUI_Container([_props[, _children]])
///
/// @extends GUI_ScrollPane
///
/// @desc
///
/// @param {Struct] [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Container(_props={}, _children=[])
	: GUI_ScrollPane(_props) constructor
{
	/// @var {Asset.GMSprite}
	BorderSprite = _props[$ "BorderSprite"] ?? GUI_SprContainerBorder;

	Canvas.BackgroundColor = #212121;

	var i = 0;
	repeat (array_length(_children))
	{
		Add(_children[i++]);
	}

	static Add = function (_child) {
		gml_pragma("forceinline");
		Canvas.Add(_child);
		return self;
	};

	static ScrollPane_Draw = Draw;

	static Draw = function () {
		ScrollPane_Draw();
		draw_sprite_stretched(BorderSprite, 0, RealX, RealY, RealWidth, RealHeight);
		return self;
	};
}
