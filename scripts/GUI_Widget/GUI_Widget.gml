#macro GUI_CHECK_LAYOUT_CHANGED \
	if (Changed) \
	{ \
		_force = true; \ // The widget has changed, we have to recompute layout for all child widgets!
		Changed = false; \
	} \
	if (!BranchChanged && !_force) \
	{ \
		return self; \
	} \
	BranchChanged = false

/// @var {Id.DsStack}
/// @private
global.__guiClipStack = ds_stack_create();

/// @var {Array<Real>, Undefined}
/// @private
global.__guiClipArea = undefined;

/// @func GUI_ClipAreaPush(_x, _y, _width, _height)
///
/// @desc
///
/// @param {Real} _x
/// @param {Real} _y
/// @param {Real} _width
/// @param {Real} _height
function GUI_ClipAreaPush(_x, _y, _width, _height)
{
	ds_stack_push(global.__guiClipStack, global.__guiClipArea);
	if (global.__guiClipArea == undefined)
	{
		global.__guiClipArea = [_x, _y, _x + _width, _y + _height];
	}
	else
	{
		global.__guiClipArea = [
			max(global.__guiClipArea[0], _x),
			max(global.__guiClipArea[1], _y),
			min(global.__guiClipArea[2], _x + _width),
			min(global.__guiClipArea[3], _y + _height)
		];
	}
}

/// @func GUI_ClipAreaPop()
///
/// @desc
function GUI_ClipAreaPop()
{
	global.__guiClipArea = ds_stack_top(global.__guiClipStack);
	ds_stack_pop(global.__guiClipStack);
}

/// @func GUI_ClipAreaGet()
///
/// @desc
///
/// @return {Array<Real>, Undefined}
function GUI_ClipAreaGet()
{
	gml_pragma("forceinline");
	return global.__guiClipArea;
}

/// @func GUI_Widget([_props[, _children]])
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_Widget>} [_children]
function GUI_Widget(_props={}, _children=[]) constructor
{
	/// @var {Bool} If `true` then widget's properties have changed.
	/// @private
	Changed = true;

	/// @var {Bool} If `true` then properties in the widget's subtree
	/// have changed.
	/// @private
	BranchChanged = true;

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

	/// @var {Constant.Color}
	BackgroundColor = GUI_StructGet(_props, "BackgroundColor");

	/// @var {Real}
	BackgroundAlpha = _props[$ "BackgroundAlpha"] ?? 1.0;

	/// @var {Asset.GMSprite}
	BackgroundSprite = GUI_StructGet(_props, "BackgroundSprite");

	/// @var {Real}
	BackgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;

	/// @var {Constant.Color}
	BackgroundSpriteColor = _props[$ "BackgroundSpriteColor"] ?? c_white;

	/// @var {Real}
	BackgroundSpriteAlpha = _props[$ "BackgroundSpriteAlpha"] ?? 1.0;

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

	/// @var {Real, String}
	MinWidth = GUI_StructGet(_props, "MinWidth");

	/// @var {Real, String}
	MaxWidth = GUI_StructGet(_props, "MaxWidth");

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

	/// @var {Real, String}
	MinHeight = GUI_StructGet(_props, "MinHeight");

	/// @var {Real, String}
	MaxHeight = GUI_StructGet(_props, "MaxHeight");

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

	/// @func FindFromId(_id)
	///
	/// @desc
	///
	/// @param {String} _id
	///
	/// @return {Struct.GUI_Widget} The found widget or `undefined`.
	static FindFromId = function (_id) {
		if (Id == _id)
		{
			return self;
		}
		var i = 0;
		repeat (array_length(Children))
		{
			with (Children[i++])
			{
				var _widget = FindFromId(_id);
				if (_widget != undefined)
				{
					return _widget;
				}
			}
		}
		return undefined;
	};

	/// @func MarkChangedUp()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static MarkChangedUp = function () {
		Changed = true;
		var _current = Parent;
		while (_current != undefined)
		{
			if (_current.BranchChanged)
			{
				break;
			}
			_current.BranchChanged = true;
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
	/// @return {Bool}
	///
	/// @private
	static CheckPropChanges = function () {
		var _changed = false;

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
				//show_debug_message([current_time, _name, _valueNew, _valueOld]);
				Changed = true;
				_changed = true;
				break;
			}
		}
		PropsChanged = {};

		if (!BranchChanged)
		{
			var i = 0;
			repeat (array_length(Children))
			{
				if (Children[i++].CheckPropChanges())
				{
					BranchChanged = true;
					_changed = true;
				}
			}
		}

		return _changed;
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
			Width: _dest[0],
			WidthUnit: _dest[1],
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
			Height: _dest[0],
			HeightUnit: _dest[1],
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

	/// @func GetClampedRealWidth(_realWidth, _parentWidth)
	///
	/// @desc
	///
	/// @param {Real} _realWidth
	/// @param {Real} _parentWidth
	///
	/// @return {Real}
	static GetClampedRealWidth = function (_realWidth, _parentWidth) {
		static _dest = array_create(2);
		if (MinWidth != undefined)
		{
			GUI_ParseSize(MinWidth, _dest);
			var _realMinWidth = (_dest[1] == "px") ? _dest[0] : (_parentWidth * (_dest[0] / 100.0));
			_realWidth = max(_realWidth, _realMinWidth);
		}
		if (MaxWidth != undefined)
		{
			GUI_ParseSize(MaxWidth, _dest);
			var _realMaxWidth = (_dest[1] == "px") ? _dest[0] : (_parentWidth * (_dest[0] / 100.0));
			_realWidth = min(_realWidth, _realMaxWidth);
		}
		return _realWidth;
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
		if (Width != "auto")
		{
			var _realWidth = (WidthUnit == "px") ? Width : (_parentWidth * (Width / 100.0));
			_realWidth = GetClampedRealWidth(_realWidth, _parentWidth);
			SetProps({ RealWidth: round(_realWidth) });
		}
		return self;
	};

	/// @func GetClampedRealHeight(_realHeight, _parentHeight)
	///
	/// @desc
	///
	/// @param {Real} _realHeight
	/// @param {Real} _parentHeight
	///
	/// @return {Real}
	static GetClampedRealHeight = function (_realHeight, _parentHeight) {
		static _dest = array_create(2);
		if (MinHeight != undefined)
		{
			GUI_ParseSize(MinHeight, _dest);
			var _realMinHeight = (_dest[1] == "px") ? _dest[0] : (_parentHeight * (_dest[0] / 100.0));
			_realHeight = max(_realHeight, _realMinHeight);
		}
		if (MaxHeight != undefined)
		{
			GUI_ParseSize(MaxHeight, _dest);
			var _realMaxHeight = (_dest[1] == "px") ? _dest[0] : (_parentHeight * (_dest[0] / 100.0));
			_realHeight = min(_realHeight, _realMaxHeight);
		}
		return _realHeight;
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
		if (Height != "auto")
		{
			var _realHeight = (HeightUnit == "px") ? Height : (_parentHeight * (Height / 100.0));
			_realHeight = GetClampedRealHeight(_realHeight, _parentHeight);
			SetProps({ RealHeight: round(_realHeight) });
		}
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

	/// @func ApplyAutoSize(_width, _height)
	///
	/// @desc
	///
	/// @param {Real} _width
	/// @param {Real} _height
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static ApplyAutoSize = function (_width, _height) {
		// Note: This should also affect the child widgets, but then the layout
		// would have to be done in multiple passes, which could get very slow!

		if (Width == "auto" && (FlexGrow == 0 || Parent[$ "FlexDirection"] != "row"))
		{
			_width = GetClampedRealWidth(_width, Parent.RealWidth);
			SetProps({ RealWidth: round(_width) });
		}

		if (Height == "auto" && (FlexGrow == 0 || Parent[$ "FlexDirection"] != "column"))
		{
			_height = GetClampedRealHeight(_height, Parent.RealHeight);
			SetProps({ RealHeight: round(_height) });
		}

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
		GUI_CHECK_LAYOUT_CHANGED;

		var _parentX = RealX;
		var _parentY = RealY;
		var _parentWidth = RealWidth;
		var _parentHeight = RealHeight;
		var _paddingLeft = PaddingLeft ?? Padding;
		var _paddingRight = PaddingRight ?? Padding;
		var _paddingTop = PaddingTop ?? Padding;
		var _paddingBottom = PaddingBottom ?? Padding;

		var i = 0;
		repeat (array_length(Children))
		{
			with (Children[i++])
			{
				if (Visible)
				{
					ComputeRealSize(
						_parentWidth - _paddingLeft - _paddingRight,
						_parentHeight - _paddingTop - _paddingBottom
					);
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
		MarkChangedUp();
		return self;
	};

	/// @func RemoveSelf()
	///
	/// @desc Removes itself from the parent widget.
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static RemoveSelf = function () {
		MarkChangedUp();
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
		MarkChangedUp();
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

	/// @func DrawBackground()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static DrawBackground = function () {
		gml_pragma("forceinline");
		if (BackgroundColor != undefined)
		{
			GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, BackgroundColor, BackgroundAlpha);
		}
		if (BackgroundSprite != undefined)
		{
			draw_sprite_stretched_ext(BackgroundSprite, BackgroundSubimage, RealX, RealY, RealWidth, RealHeight,
				BackgroundSpriteColor, BackgroundSpriteAlpha);
		}
		return self;
	};

	/// @func DrawChildren()
	///
	/// @desc Draws all *visible* child widgets.
	///
	/// @return {Struct.GUI_Widget} Returns `self`.
	static DrawChildren = function () {
		var _xMin, _yMin, _xMax, _yMax;

		var _clipArea = GUI_ClipAreaGet();
		if (_clipArea != undefined)
		{
			_xMin = _clipArea[0];
			_yMin = _clipArea[1];
			_xMax = _clipArea[2];
			_yMax = _clipArea[3];
		}
		else
		{
			_xMin = Root.RealX;
			_yMin = Root.RealY;
			_xMax = Root.RealX + Root.RealWidth;
			_yMax = Root.RealY + Root.RealHeight;
		}

		var i = 0;
		repeat (array_length(Children))
		{
			with (Children[i++])
			{
				if (Visible
					&& !(RealX + RealWidth < _xMin
					|| RealY + RealHeight < _yMin
					|| RealX > _xMax
					|| RealY > _yMax))
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
		DrawBackground();
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
