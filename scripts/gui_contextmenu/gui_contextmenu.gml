/// @func GUI_ContextMenu([_props[, _items]])
///
/// @extends GUI_Canvas
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_ContextMenuItem>} [_items]
function GUI_ContextMenu(_props={}, _items=[])
	: GUI_Canvas(_props) constructor
{
	/// @var {Struct.GUI_Widget}
	/// @readonly
	Toggler = GUI_StructGet(_props, "Toggler");

	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprContextMenu;

	//MinWidth = _props[$ "MinWidth"] ?? 120;

	Container = new GUI_VBox({ Width: "100%" });
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
	/// @param {Struct.GUI_ContextMenuItem} _item
	///
	/// @return {Struct.GUI_ContextMenu} Returns `self`.
	static Add = function (_item) {
		gml_pragma("forceinline");
		Container.Add(_item);
		_item.ContextMenu = self;
		return self;
	};

	static Canvas_Update = Update;

	static Update = function () {
		if (Visible)
		{
			Canvas_Update();
			if (mouse_check_button_pressed(mb_left)
				&& !IsMouseOver()
				&& !(Toggler && Toggler.IsMouseOver())
				&& !(Root && IsAncestorOf(Root.WidgetHovered)))
			{
				RemoveSelf();
			}
		}
		return self;
	};

	static Canvas_Layout = Layout;

	static Layout = function (_force=false) {
		CHECK_LAYOUT_CHANGED;
		var _bbox = GetInnerBoundingBox();
		var _realWidthNew = _bbox[2] - RealX;
		if (MinWidth != undefined)
		{
			_realWidthNew = max(_realWidthNew, MinWidth);
		}
		SetProps({
			RealWidth: _realWidthNew,
			RealHeight: _bbox[3] - RealY,
		});
		Canvas_Layout(_force);
		return self;
	};

	static Canvas_Draw = Draw;

	static Draw = function () {
		GUI_DrawShadow(RealX, RealY, RealWidth, RealHeight);
		Canvas_Draw();
		return self;
	};
}
