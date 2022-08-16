#macro CHECK_LAYOUT_CHANGED \
	if (!_force && !Changed) \
	{ \
		return self; \
	} \
	_force = true; \
	Changed = false

/// @func GUI_Widget([_props[, _children]])
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Widget(_props={}, _children=[]) constructor
{
	/// @var {Bool}
	/// @private
	Changed = true;

	/// @var {Struct}
	/// @private
	PropsChanged = {};

	/// @var {Struct.GUI_Root}
	/// @readonly
	Root = undefined;

	/// @var {Struct.GUI_Widget}
	/// @readonly
	Parent = undefined;

	/// @var {Real}
	/// @readonly
	MaxChildCount = infinity;

	/// @var {Array<Struct.GUI_Widget>}
	/// @readonly
	Children = [];

	var i = 0
	repeat (array_length(_children))
	{
		Add(_children[i++]);
	}

	static IdNext = 0;

	/// @var {String}
	Id = _props[$ "Id"] ?? ("Widget" + string(IdNext++));

	/// @var {Real}
	X = _props[$ "X"] ?? 0;

	/// @var {Real}
	/// @readonly
	RealX = X;

	/// @var {Real}
	Y = _props[$ "Y"] ?? 0;

	/// @var {Real}
	/// @readonly
	RealY = Y;

	/// @var {Real}
	/// @readonly
	Width = 1;

	/// @var {String}
	/// @readonly
	WidthUnit = "px";

	if (variable_struct_exists(_props, "Width"))
	{
		SetWidth(_props[$ "Width"]);
	}

	/// @var {Real}
	MinWidth = GUI_StructGet(_props, "MinWidth");

	/// @var {Real}
	/// @readonly
	RealWidth = 0;

	/// @var {Real}
	/// @readonly
	Height = 1;

	/// @var {String}
	/// @readonly
	HeightUnit = "px";

	if (variable_struct_exists(_props, "Height"))
	{
		SetHeight(_props[$ "Height"]);
	}

	/// @var {Real}
	MinHeight = GUI_StructGet(_props, "MinHeight");

	/// @var {Real}
	/// @readonly
	RealHeight = 0;

	/// @var {Real}
	Padding = _props[$ "Padding"] ?? 0;

	/// @var {Real}
	PaddingLeft = GUI_StructGet(_props, "PaddingLeft");

	/// @var {Real}
	PaddingRight = GUI_StructGet(_props, "PaddingRight");

	/// @var {Real}
	PaddingTop = GUI_StructGet(_props, "PaddingTop");

	/// @var {Real}
	PaddingBottom = GUI_StructGet(_props, "PaddingBottom");

	/// @var {Real}
	AnchorLeft = _props[$ "AnchorLeft"] ?? 0;

	/// @var {Real}
	AnchorTop = _props[$ "AnchorTop"] ?? 0;

	/// @var {Real}
	PivotLeft = _props[$ "PivotLeft"] ?? 0;

	/// @var {Real}
	PivotTop = _props[$ "PivotTop"] ?? 0;

	/// @var {Real}
	FlexGrow = _props[$ "FlexGrow"] ?? 0;

	/// @var {String}
	Tooltip = _props[$ "Tooltip"] ?? "";

	/// @var {Bool}
	Disabled = _props[$ "Disabled"] ?? false;

	/// @var {Bool}
	Visible = _props[$ "Visible"] ?? true;

	/// @var {Bool}
	Draggable = _props[$ "Draggable"] ?? false;

	/// @var {Function}
	OnMouseEnter = GUI_StructGet(_props, "OnMouseEnter");

	/// @var {Function}
	OnMouseLeave = GUI_StructGet(_props, "OnMouseLeave");

	/// @var {Function}
	OnPress = GUI_StructGet(_props, "OnPress");

	/// @var {Function}
	OnClick = GUI_StructGet(_props, "OnClick");

	/// @var {Function}
	OnDoubleClick = GUI_StructGet(_props, "OnDoubleClick");

	/// @var {Function}
	OnRelease = GUI_StructGet(_props, "OnRelease");

	/// @var {Function}
	OnChange = GUI_StructGet(_props, "OnChange");

	/// @var {Function}
	OnFocus = GUI_StructGet(_props, "OnFocus");

	/// @var {Function}
	OnBlur = GUI_StructGet(_props, "OnBlur");

	/// @var {Function}
	OnDragStart = GUI_StructGet(_props, "OnDragStart");

	/// @var {Function}
	OnDrag = GUI_StructGet(_props, "OnDrag");

	/// @var {Function}
	OnDragEnd = GUI_StructGet(_props, "OnDragEnd");

	/// @var {Function}
	OnUpdate = GUI_StructGet(_props, "OnUpdate");

	/// @var {Id.DsMap<String, Id.DsList<Function>>}
	/// @readonly
	EventListeners = undefined;

	/// @func MarkChanged()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static MarkChanged = function () {
		var _current = self;
		while (_current != undefined)
		{
			if (_current.Changed)
			{
				break;
			}
			_current.Changed = true;
			_current = _current.Parent;
		}
		return self;
	};

	/// @func SetProps(_props)
	///
	/// @desc
	///
	/// @param {Struct} _props
	///
	/// @return {Struct.GUI_Widge} Returns `self`.
	static SetProps = function (_props) {
		gml_pragma("forceinline");
		var _names = variable_struct_get_names(_props);
		var i = 0;
		repeat (array_length(_names))
		{
			var _name = _names[i++];
			var _valueOld = self[$ _name];
			var _valueNew = _props[$ _name];
			if (_valueOld != _valueNew)
			{
				self[$ _name] = _valueNew;
				if (!variable_struct_exists(PropsChanged, _name))
				{
					PropsChanged[$ _name] = _valueOld;
				}
			}
		}
		return self;
	};

	/// @func CheckPropChanges()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	///
	/// @private
	static CheckPropChanges = function () {
		var _props = PropsChanged;
		var _names = variable_struct_get_names(_props);
		var i = 0;
		repeat (array_length(_names))
		{
			var _name = _names[i++];
			var _valueOld = _props[$ _name];
			var _valueNew = self[$ _name];
			if (_valueNew != _valueOld)
			{
				MarkChanged();
				break;
			}
		}
		PropsChanged = {};
		return self;
	};

	/// @func AddEventListener(_event, _callback)
	///
	/// @desc
	///
	/// @param {String} _event
	/// @param {Function} _callback
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static AddEventListener = function (_event, _callback) {
		EventListeners ??= ds_map_create();
		var _list;
		if (!ds_map_exists(EventListeners,  _event))
		{
			_list = ds_list_create();
			ds_map_add_list(EventListeners, _event, _list);
		}
		else
		{
			_list = EventListeners[? _event];
		}
		ds_list_add(_list, _callback);
		return self;
	};

	/// @func RemoveEventListener(_event[, _callback])
	///
	/// @desc
	///
	/// @param {String} _event
	/// @param {Function} [_callback]
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static RemoveEventListener = function (_event, _callback=undefined) {
		if (EventListeners != undefined)
		{
			if (ds_map_exists(EventListeners, _event))
			{
				if (!_callback)
				{
					ds_map_delete(EventListeners, _event);
				}
				else
				{
					var _list = EventListeners[? _event];
					var _index = ds_list_find_index(_list, _callback);
					if (_index >= 0)
					{
						ds_list_delete(_list, _index);
						if (ds_list_empty(_list))
						{
							ds_map_delete(EventListeners, _event);
						}
						if (ds_map_empty(EventListeners))
						{
							ds_map_destroy(EventListeners);
							EventListeners = undefined;
						}
					}
				}
			}
		}
		return self;
	};

	/// @func TriggerEvent(_event)
	///
	/// @desc
	///
	/// @param {Struct.GUI_Event} _event
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static TriggerEvent = function (_event) {
		_event.Target ??= self;
		_event.TargetCurrent = self;
		if (EventListeners != undefined
			&& ds_map_exists(EventListeners, _event.Type))
		{
			var _list = EventListeners[? _event.Type];
			var i = 0;
			repeat (ds_list_size(_list))
			{
				_list[| i++](self, _event);
			}
		}
		if (_event.Bubble && Parent)
		{
			Parent.TriggerEvent(_event);
		}
		return self;
	};

	/// @func SetWidth(_value)
	///
	/// @desc
	///
	/// @param {String/Real} _value
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	///
	/// @throws {String}
	static SetWidth = function (_value) {
		gml_pragma("forceinline");
		static _dest = [];
		GUI_ParseSize(_value, _dest);
		SetProps({
			"Width": _dest[0],
			"WidthUnit": _dest[1],
		});
		return self;
	};

	/// @func SetHeight(_value)
	///
	/// @desc
	///
	/// @param {String/Real} _value
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	///
	/// @throws {String}
	static SetHeight = function (_value) {
		gml_pragma("forceinline");
		static _dest = [];
		GUI_ParseSize(_value, _dest);
		SetProps({
			"Height": _dest[0],
			"HeightUnit": _dest[1],
		});
		return self;
	};

	/// @func SetSize(_width, _height)
	///
	/// @desc
	///
	/// @param {String/Real} _width
	/// @param {String/Real} _height
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	///
	/// @throws {String}
	static SetSize = function (_width, _height) {
		gml_pragma("forceinline");
		SetWidth(_width);
		SetHeight(_height);
		return self;
	};

	/// @func ComputeRealWidth(_parentWidth)
	///
	/// @desc
	///
	/// @param {Real} _parentWidth
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static ComputeRealWidth = function (_parentWidth) {
		gml_pragma("forceinline");
		var _realWidth = (WidthUnit == "px") ? Width : (_parentWidth * (Width / 100.0));
		if (MinWidth != undefined)
		{
			_realWidth = max(_realWidth, MinWidth);
		}
		SetProps({
			"RealWidth": _realWidth,
		});
		return self;
	};

	/// @func ComputeRealHeight(_parentHeight)
	///
	/// @desc
	///
	/// @param {Real} _parentHeight
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static ComputeRealHeight = function (_parentHeight) {
		gml_pragma("forceinline");
		var _realHeight = (HeightUnit == "px") ? Height : (_parentHeight * (Height / 100.0));
		if (MinHeight != undefined)
		{
			_realHeight = max(_realHeight, MinHeight);
		}
		SetProps({
			"RealHeight": _realHeight,
		});
		return self;
	};

	/// @func ComputeRealSize(_parentWidth, _parentHeight)
	///
	/// @desc
	///
	/// @param {Real} _parentWidth
	/// @param {Real} _parentHeight
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static ComputeRealSize = function (_parentWidth, _parentHeight) {
		gml_pragma("forceinline");
		ComputeRealWidth(_parentWidth);
		ComputeRealHeight(_parentHeight);
		return self;
	};

	/// @func IsDisabled()
	///
	/// @desc
	///
	/// @return {Bool}
	static IsDisabled = function () {
		gml_pragma("forceinline");
		if (is_bool(Disabled))
		{
			return Disabled;
		}
		return Disabled();
	};

	/// @func IsDisabled(_widget)
	///
	/// @desc
	///
	/// @param {Struct.GUI_Widget} _widget
	///
	/// @return {Bool}
	static IsAncestorOf = function (_widget) {
		while (_widget)
		{
			_widget = _widget.Parent;
			if (_widget == self)
			{
				return true;
			}
		}
		return false;
	};

	/// @func GetBoundingBox([_dest])
	///
	/// @desc
	///
	/// @param {Array<Real>} [_dest]
	///
	/// @return {Array<Real>} Returns `_dest`.
	static GetBoundingBox = function (_dest=[RealX, RealY, RealX + RealWidth, RealY + RealHeight]) {
		gml_pragma("forceinline");
		if (Visible)
		{
			_dest[@ 0] = min(_dest[0], RealX);
			_dest[@ 1] = min(_dest[1], RealY);
			_dest[@ 2] = max(_dest[2], RealX + RealWidth);
			_dest[@ 3] = max(_dest[3], RealY + RealHeight);
			var i = 0;
			repeat (array_length(Children))
			{
				Children[i++].GetBoundingBox(_dest);
			}
		}
		return _dest;
	};

	/// @func GetInnerBoundingBox()
	///
	/// @desc
	///
	/// @return {Array<Real>}
	static GetInnerBoundingBox = function () {
		var _childCount = array_length(Children);
		if (_childCount > 0)
		{
			var _dest = [infinity, infinity, 0, 0];
			var i = 0;
			repeat (_childCount)
			{
				Children[i++].GetBoundingBox(_dest);
			}
			return _dest;
		}
		return undefined;
	};

	/// @func Layout([_force])
	///
	/// @desc
	///
	/// @param {Bool} [_force]
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static Layout = function (_force=false) {
		CHECK_LAYOUT_CHANGED;

		var _parentX = RealX;
		var _parentY = RealY;
		var _parentWidth = RealWidth;
		var _parentHeight = RealHeight;
		var _paddingLeft = PaddingLeft ?? Padding;
		var _paddingTop = PaddingTop ?? Padding;

		var i = 0;
		repeat (array_length(Children))
		{
			with (Children[i++])
			{
				if (Visible)
				{
					ComputeRealSize(_parentWidth, _parentHeight);
					RealX = round(_parentX + _paddingLeft + ((_parentWidth - RealWidth) * AnchorLeft) + (RealWidth * PivotLeft) + X);
					RealY = round(_parentY + _paddingTop + ((_parentHeight - RealHeight) * AnchorTop) + (RealHeight * PivotTop) + Y);
					Layout(_force);
				}
			}
		}

		return self;
	};

	/// @func IsMouseOver()
	///
	/// @desc
	///
	/// @return {Bool}
	static IsMouseOver = function () {
		gml_pragma("forceinline");
		return (Root ? (Root.WidgetHovered == self) : false);
	};

	/// @func Focus()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static Focus = function () {
		gml_pragma("forceinline");
		if (IsDisabled()
			|| Root == undefined
			|| Root.WidgetFocused == self)
		{
			return self;
		}
		var _widgetFocused = Root.WidgetFocused;
		Root.WidgetFocused = self;
		if (OnFocus)
		{
			OnFocus();
		}
		if (_widgetFocused && _widgetFocused.OnBlur)
		{
			_widgetFocused.OnBlur();
		}
		return self;
	};

	/// @func IsFocused()
	///
	/// @desc
	///
	/// @return {Bool}
	static IsFocused = function () {
		gml_pragma("forceinline");
		return (Root ? (Root.WidgetFocused == self) : false);
	};

	/// @func Blur()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static Blur = function () {
		gml_pragma("forceinline");
		if (Root == undefined
			|| Root.WidgetFocused != self)
		{
			return self;
		}
		Root.WidgetFocused = undefined;
		if (OnBlur)
		{
			OnBlur();
		}
		return self;
	};

	/// @func DragStart()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static DragStart = function () {
		gml_pragma("forceinline");
		if (IsDisabled()
			|| Root == undefined
			|| Root.WidgetDragged == self)
		{
			return self;
		}
		var _widgetDragging = Root.WidgetDragged;
		Root.WidgetDragged = self;
		if (_widgetDragging && _widgetDragging.OnDragEnd)
		{
			_widgetDragging.OnDragEnd();
		}
		if (OnDragStart)
		{
			OnDragStart();
		}
		return self;
	};

	/// @func IsDragged()
	///
	/// @desc
	///
	/// @return {Bool}
	static IsDragged = function () {
		gml_pragma("forceinline");
		return (Root ? (Root.WidgetDragged == self) : false);
	};

	/// @func DragEnd()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static DragEnd = function () {
		gml_pragma("forceinline");
		if (Root == undefined
			|| Root.WidgetDragged != self)
		{
			return self;
		}
		Root.WidgetDragged = undefined;
		if (OnDragEnd)
		{
			OnDragEnd();
		}
		return self;
	};

	/// @func PassRoot(_widget, _root)
	///
	/// @desc
	///
	/// @param {Struct.GUI_Widget} _widget
	/// @param {Struct.GUI_Root} _root
	///
	/// @ignore
	static PassRoot = function (_widget, _root) {
		_widget.Root = _root;
		for (var i = array_length(_widget.Children) - 1; i >= 0; --i)
		{
			_widget.PassRoot(_widget.Children[i], _root);
		}
	};

	/// @func Add(_widget)
	///
	/// @desc
	///
	/// @param {Struct.GUI_Widget} _widget
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	///
	/// @throws {String}
	static Add = function (_widget) {
		gml_pragma("forceinline");
		if (_widget == self)
		{
			throw "Cannot add self as a child!";
		}
		if (_widget.Parent)
		{
			throw "Already a child of a widget!";
		}
		if (array_length(Children) >= MaxChildCount)
		{
			throw "Cannot add more child widgets!";
		}
		array_push(Children, _widget);
		_widget.Parent = self;
		PassRoot(_widget, Root);
		MarkChanged();
		return self;
	};

	/// @func RemoveSelf()
	///
	/// @desc Removes itself from the parent widget.
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static RemoveSelf = function () {
		MarkChanged();
		if (Parent)
		{
			for (var i = array_length(Parent.Children) - 1; i >= 0; --i)
			{
				if (Parent.Children[i] == self)
				{
					array_delete(Parent.Children, i, 1);
					break;
				}
			}
		}
		Parent = undefined;
		Root = undefined;
		return self;
	};

	/// @func RemoveChildWidgets()
	///
	/// @desc Removes and **destroys** all child widgets.
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static RemoveChildWidgets = function () {
		MarkChanged();
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			Children[i].Destroy();
		}
		Children = [];
		return self;
	};

	/// @func FindWidget(_id)
	///
	/// @desc Finds a widget from its ID.
	///
	/// @param {String} _id The id of the widget.
	///
	/// @return {Struct.GUI_Widget} The found widget or `undefined`.
	static FindWidget = function (_id) {
		if (Id == _id)
		{
			return self;
		}
		var i = 0;
		repeat (array_length(Children))
		{
			var _found = Children[i++].FindWidget(_id);
			if (_found)
			{
				return _found;
			}
		}
		return undefined;
	};

	/// @func FindWidgetAt(_x, _y[, _allowDisabled])
	///
	/// @desc
	///
	/// @param {Real} _x
	/// @param {Real} _y
	/// @param {Bool} [_allowDisabled]
	///
	/// @return {Struct.GUI_Widget}
	static FindWidgetAt = function (_x, _y, _allowDisabled=true) {
		if (!Visible)
		{
			return undefined;
		}
		for (var i = array_length(Children) - 1; i >= 0; --i)
		{
			var _found = Children[i].FindWidgetAt(_x, _y, _allowDisabled);
			if (_found)
			{
				return _found;
			}
		}
		if ((!IsDisabled() || _allowDisabled)
			&& _x >= RealX && _x <= RealX + RealWidth
			&& _y >= RealY && _y <= RealY + RealHeight)
		{
			return self;
		}
		return undefined;
	};

	/// @func Update()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static Update = function () {
		if (OnUpdate)
		{
			OnUpdate(self);
		}
		return self;
	};

	/// @func DrawChildren()
	///
	/// @desc Draws all *visible* child widgets.
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static DrawChildren = function () {
		var i = 0;
		repeat (array_length(Children))
		{
			with (Children[i++])
			{
				if (Visible)
				{
					Draw();
				}
			}
		}
		return self;
	};

	/// @func Draw()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static Draw = function () {
		DrawChildren();
		return self;
	};

	/// @func DrawDebug()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static DrawDebug = function () {
		if (Visible)
		{
			draw_rectangle_color(
				RealX, RealY,
				RealX + RealWidth - 1,
				RealY + RealHeight - 1,
				c_red, c_red, c_red, c_red, true);

			var i = 0;
			repeat (array_length(Children))
			{
				Children[i++].DrawDebug();
			}
		}
		return self;
	};

	/// @func Destroy()
	///
	/// @desc Destroys the widget and its child widgets and frees all used
	/// resources from memory.
	///
	/// @return {Undefined} Always returns `udefined`.
	static Destroy = function () {
		RemoveSelf();
		RemoveChildWidgets();
		if (EventListeners != undefined)
		{
			ds_map_destroy(EventListeners);
			EventListeners = undefined;
		}
		return undefined;
	};
}
