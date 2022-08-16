/// @func GUI_SelectList([_props[, _items]])
///
/// @extends GUI_Container
///
/// @desc
///
/// @param {Struct] [_props]
/// @param {Array<Struct.GUI_SelectListItem>} [_items]
function GUI_SelectList(_props={}, _items=[])
	: GUI_Container(_props) constructor
{
	VBox = new GUI_VBox({
		Width: "100%",
	});
	Canvas.Add(VBox);

	var i = 0;
	repeat (array_length(_items))
	{
		Add(_items[i++]);
	}

	/// @func Add(_item)
	///
	/// @desc
	///
	/// @param {Struct.GUI_SelectListItem} _item
	///
	/// @return {Struct.GUI_SelectList}
	static Add = function (_item) {
		gml_pragma("forceinline");
		VBox.Add(_item);
		return self;
	};

	/// @func GetItems()
	///
	/// @desc
	///
	/// @return {Array<Struct.GUI_SelectList>}
	static GetItems = function () {
		gml_pragma("forceinline");
		return VBox.Children;
	};

	static ScrollPane_Update = Update;

	static Update = function () {
		var _items = VBox.Children;
		var i = 0;
		repeat (array_length(_items))
		{
			_items[i].SetProps({ "IsLight": (i & 1) });
			++i;
		}
		return self;
	};
}
