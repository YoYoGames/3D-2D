/// @func GUI_Dropdown([_props[, _options])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
/// @param {Array<Struct.GUI_DropdownOption>} [_options]
function GUI_Dropdown(_props={}, _options=[])
	: GUI_Widget(_props) constructor
{
	/// @var {Array<Struct.GUI_DropdownOption>}
	/// @readonly
	Options = [];

	/// @var {Struct.GUI_DropdownOption}
	/// @readonly
	Selected = undefined;

	/// @var {Struct.GUI_DropdownMenu}
	/// @readonly
	DropdownMenu = new GUI_DropdownMenu();
	DropdownMenu.Dropdown = self;

	SetHeight(_props[$ "Height"] ?? GUI_LINE_HEIGHT);

	Color = _props[$ "Color"] ?? #BEBEBE;

	/// @var {Asset.GMSprite}
	BackgroundSprite = _props[$ "BackgroundSprite"] ?? GUI_SprDropdown;

	/// @var {Real}
	BackgroundSubimage = _props[$ "BackgroundSubimage"] ?? 0;

	/// @var {Asset.GMSprite}
	SpriteCaret = _props[$ "SpriteCaret"] ?? GUI_SprDropdownCaret;

	/// @var {Bool} FIXME: DIRTY HACK!!!
	DrawSelf = _props[$ "DrawSelf"] ?? true;

	OnClick = function () {
		if (DropdownMenu.Parent)
		{
			DropdownMenu.RemoveSelf();
		}
		else if (Root)
		{
			Root.Add(DropdownMenu);
		}
	};

	var i = 0;
	repeat (array_length(_options))
	{
		AddOption(_options[i++]);
	}

	static Widget_FindWidgetAt = FindWidgetAt;

	static FindWidgetAt = function (_x, _y, _allowDisabled=true) {
		if (DrawSelf)
		{
			return Widget_FindWidgetAt(_x, _y, _allowDisabled);
		}
		return undefined;
	};

	/// @func AddOption(_option)
	///
	/// @desc
	///
	/// @param {Struct.GUI_DropdownOption} _option
	///
	/// @return {Struct.GUI_Dropdown} Returns `self`.
	static AddOption = function (_option) {
		gml_pragma("forceinline");
		array_push(Options, _option);
		DropdownMenu.OptionsContainer.Add(_option);
		_option.Dropdown = self;
		if (!Selected && _option.IsDefault)
		{
			SetProps({
				Selected: _option,
			});
		}
		return self;
	};

	/// @func SelectPrev()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Dropdown} Returns `self`.
	static SelectPrev = function () {
		var _optionCount = array_length(Options);
		var i = 0;
		repeat (_optionCount)
		{
			if (Selected == Options[i])
			{
				break;
			}
			++i;
		}
		if (--i < 0)
		{
			i = _optionCount - 1;
		}
		Select(Options[i]);
		return self;
	};

	/// @func SelectNext()
	///
	/// @desc
	///
	/// @return {Struct.GUI_Dropdown} Returns `self`.
	static SelectNext = function () {
		var _optionCount = array_length(Options);
		var i = 0;
		repeat (_optionCount)
		{
			if (Selected == Options[i])
			{
				break;
			}
			++i;
		}
		if (++i >= _optionCount)
		{
			i = 0;
		}
		Select(Options[i]);
		return self;
	};

	/// @func Select(_option)
	///
	/// @desc
	///
	/// @param {Struct.GUI_DropdownOption} _option
	///
	/// @return {Struct.GUI_Dropdown} Returns `self`.
	static Select = function (_option) {
		if (Selected != _option)
		{
			var _options = Options;
			var i = 0;
			repeat (array_length(_options))
			{
				if (_options[i++] == _option)
				{
					var _selectedOld = Selected;
					Selected = _option;
					if (OnChange)
					{
						OnChange(_option.Value, _selectedOld ? _selectedOld.Value : undefined);
					}
				}
			}
		}
		if (DropdownMenu)
		{
			DropdownMenu.RemoveSelf();
		}
		return self;
	};

	static Widget_Layout = Layout;

	static Layout = function (_force=false) {
		CHECK_LAYOUT_CHANGED;
		DropdownMenu.X = RealX;
		DropdownMenu.Y = RealY + RealHeight;
		DropdownMenu.SetWidth(RealWidth);
		Widget_Layout(_force);
		return self;
	};

	static Draw = function () {
		if (DrawSelf)
		{
			// Background
			draw_sprite_stretched(BackgroundSprite, BackgroundSubimage,
				RealX, RealY, RealWidth, RealHeight);
			draw_sprite_stretched(BackgroundSprite, BackgroundSubimage,
				RealX + RealWidth - RealHeight, RealY, RealHeight, RealHeight);
			// Caret
			var _caretWidth = sprite_get_width(SpriteCaret);
			var _caretHeight = sprite_get_height(SpriteCaret);
			draw_sprite(
				SpriteCaret, 0,
				RealX + RealWidth - _caretWidth - 8,
				RealY + floor((RealHeight - _caretHeight) * 0.5));
			// Text
			GUI_DrawTextPartLeft(
				RealX + 7,
				RealY + floor((RealHeight - GUI_FONT_HEIGHT) * 0.5),
				Selected ? Selected.Text : "", RealWidth - 14 - _caretWidth - 9, Color);
		}
		DrawChildren();
		return self;
	};
}
