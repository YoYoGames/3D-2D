/// @func GUI_MenuBar([_props[, _items]])
///
/// @extends GUI_Canvas
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_MenuBarItem>} [_items]
function GUI_MenuBar(_props={}, _items=[])
	: GUI_Canvas(_props) constructor
{
	MaxChildCount = 1;

	/// @var {Struct.GUI_MenuBarItem}
	/// @ignore
	Selected = undefined;

	/// @var {Asset.GMSprite}
	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprMenuBar;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? GUI_LINE_HEIGHT + 4
	);

	Container = new GUI_HBox({ X: 4, Y: 2 });
	Canvas_Add(Container);

	var i = 0;
	repeat (array_length(_items))
	{
		Add(_items[i++]);
	}

	static Canvas_Add = Add;

	/// @func Add(_item)
	///
	/// @desc
	///
	/// @param {Struct.GUI_MenuBarItem} _item
	///
	/// @return {Struct.GUI_MenuBar} Returns `self`.
	static Add = function (_item) {
		gml_pragma("forceinline");
		Container.Add(_item);
		_item.MenuBar = self;
		return self;
	};
}
