// TODO: Save colors between sessions
global.__guiSavedColors = array_create(10, undefined);

/// @func GUI_ColorPicker(_color[, _props])
///
/// @extends GUI_Canvas
///
/// @desc
///
/// @param {Struct} _color
/// @param {Struct} [_props]
function GUI_ColorPicker(_color, _props={})
	: GUI_Canvas(_props) constructor
{
	/// @var {Struct}
	/// @readonly
	Color = _color;

	var _colorRGB = make_color_rgb(Color.Red, Color.Green, Color.Blue);

	/// @var {Real}
	Hue = color_get_hue(_colorRGB);

	/// @var {Real}
	Sat = color_get_saturation(_colorRGB);

	/// @var {Real}
	Val = color_get_value(_colorRGB);

	/// @var {Real}
	Alpha = _color.Alpha;

	SetSize(348, 482);

	/// @var {Constant.Color}
	BackgroundColor = _props[$ "BackgroundColor"] ?? #272727;

	Draggable = true;

	OnDrag = function (_self, _diffX, _diffY) {
		SetProps({
			X:  + _diffX,
			Y:  + _diffY,
		});
	};

	Add(new GUI_HueBox({
		X: 15,
		Y: 11,
		Width: 266,
		Height: 320,
	}));

	Add(new GUI_HueSlider({
		Value: Hue,
		X: 297,
		Y: 11,
	}));

	SliderAlpha = new GUI_AlphaSlider({
		Value: Alpha,
		X: 15,
		Y: 345,
		Color: _colorRGB,
	});
	Add(SliderAlpha);

	InputAlpha = new GUI_Input(Alpha * 100, {
		Min: 0,
		Max: 100,
		WholeNumbers: true,
		OnChange: method(self, function (_value) {
			Alpha = _value / 100.0;
		}),
		X: 248,
		Y: 345,
		Width: 70,
		After: "%",
	});
	Add(InputAlpha);

	DropdownType = new GUI_Dropdown({
		X: 14,
		Y: 381,
		Width: 70,
		OnChange: method(self, function (_value) {
			InputHex.SetProps({
				Visible: (_value == "Hex"),
			});
			ContainerInputsHSV.SetProps({
				Visible: (_value == "HSV"),
			});
			ContainerInputsRGB.SetProps({
				Visible: (_value == "RGB"),
			});
		}),
	}).AddOption(new GUI_DropdownOption("Hex", { IsDefault: true, }))
		.AddOption(new GUI_DropdownOption("HSV"))
		.AddOption(new GUI_DropdownOption("RGB"));
	Add(DropdownType);

	var _styleInputContainer = {
		X: 96,
		Y: 382,
		Visible: false,
		Spacing: 5,
	};

	InputHex = new GUI_Input(GUI_ByteArrayToHex([Color.Red, Color.Green, Color.Blue]), GUI_StructExtend({}, _styleInputContainer, {
		Before: "#",
		Width: 188,
		OnChange: method(self, function (_value) {
			var _colorNew = GUI_HexToReal(_value);
			if (!is_nan(_colorNew))
			{
				_colorNew = make_color_rgb(
					color_get_blue(_colorNew),
					color_get_green(_colorNew),
					color_get_red(_colorNew));
				Hue = color_get_hue(_colorNew);
				Sat = color_get_saturation(_colorNew);
				Val = color_get_value(_colorNew);
			}
		}),
		Visible: true,
	}));
	Add(InputHex);

	ContainerInputsHSV = new GUI_HBox(_styleInputContainer);
	Add(ContainerInputsHSV);

	var _styleInput = {
		Width: 46,
		Min: 0,
		Max: 255,
		WholeNumbers: true,
	};

	ContainerInputsHSV.Add(new GUI_Text("H"));

	InputHue = new GUI_Input(Hue, GUI_StructExtend({}, _styleInput, {
		OnChange: method(self, function (_value) {
			Hue = _value;
		}),
	}));
	ContainerInputsHSV.Add(InputHue);

	ContainerInputsHSV.Add(new GUI_Text("S"));

	InputSat = new GUI_Input(Sat, GUI_StructExtend({}, _styleInput, {
		OnChange: method(self, function (_value) {
			Sat = _value;
		}),
	}));
	ContainerInputsHSV.Add(InputSat);

	ContainerInputsHSV.Add(new GUI_Text("V"));

	InputVal = new GUI_Input(Val, GUI_StructExtend({}, _styleInput, {
		OnChange: method(self, function (_value) {
			Val = _value;
		}),
	}));
	ContainerInputsHSV.Add(InputVal);

	ContainerInputsRGB = new GUI_HBox(_styleInputContainer);
	Add(ContainerInputsRGB);

	ContainerInputsRGB.Add(new GUI_Text("R"));

	InputRed = new GUI_Input(Color.Red, GUI_StructExtend({}, _styleInput, {
		OnChange: method(self, function (_value) {
			var _colorHSV = make_color_hsv(Hue, Sat, Val);
			var _colorNewRGB = make_color_rgb(_value, color_get_green(_colorHSV), color_get_blue(_colorHSV));
			SetProps({
				Hue:color_get_hue(_colorNewRGB),
				Sat:color_get_saturation(_colorNewRGB),
				Val:color_get_value(_colorNewRGB),
			});
		}),
	}));
	ContainerInputsRGB.Add(InputRed);

	ContainerInputsRGB.Add(new GUI_Text("G"));

	InputGreen = new GUI_Input(Color.Green, GUI_StructExtend({}, _styleInput, {
		OnChange: method(self, function (_value) {
			var _colorHSV = make_color_hsv(Hue, Sat, Val);
			var _colorNewRGB = make_color_rgb(color_get_red(_colorHSV), _value, color_get_blue(_colorHSV));
			SetProps({
				Hue:color_get_hue(_colorNewRGB),
				Sat:color_get_saturation(_colorNewRGB),
				Val:color_get_value(_colorNewRGB),
			});
		}),
	}));
	ContainerInputsRGB.Add(InputGreen);

	ContainerInputsRGB.Add(new GUI_Text("B"));

	InputBlue = new GUI_Input(Color.Blue, GUI_StructExtend({}, _styleInput, {
		OnChange: method(self, function (_value) {
			var _colorHSV = make_color_hsv(Hue, Sat, Val);
			var _colorNewRGB = make_color_rgb(color_get_red(_colorHSV), color_get_green(_colorHSV), _value);
			SetProps({
				Hue:color_get_hue(_colorNewRGB),
				Sat:color_get_saturation(_colorNewRGB),
				Val:color_get_value(_colorNewRGB),
			});
		}),
	}));
	ContainerInputsRGB.Add(InputBlue);

	ButtonEyeDropper = new GUI_GlyphButton(ST_EIcon.ColorPicker, {
		Font: ST_FntIcons11,
		X: 294,
		Y: 382,
		// TODO: Implement eye dropper
		OnClick: method(self, function () {
		}),
		Disabled: true,
	});
	Add(ButtonEyeDropper);

	Add(new GUI_VSeparator({
		X: 15,
		Y: 425,
		Width: 303,
	}));

	ButtonPlus = new GUI_GlyphButton(ST_EIcon.TrackpanelAddTrack, {
		Font: ST_FntIcons11,
		X: 15,
		Y: 438,
		OnClick: method(self, function () {
			// Shift saved colors right
			var _colorButtons = ContainerColors.Children;
			for (var i = array_length(global.__guiSavedColors) - 1; i >= 1; --i)
			{
				global.__guiSavedColors[i] = global.__guiSavedColors[i - 1];
				_colorButtons[i].Color = global.__guiSavedColors[i];
			}

			// Save a new color
			global.__guiSavedColors[0] = {
				Red: Color.Red,
				Green: Color.Green,
				Blue: Color.Blue,
				Alpha: Color.Alpha,
			};
			_colorButtons[0].Color = global.__guiSavedColors[0];
		}),
	});
	Add(ButtonPlus);

	ContainerColors = new GUI_HBox({
		X: 45,
		Y: 438,
		Spacing: 4,
	});
	Add(ContainerColors);

	var _self = self;
	for (var i = 0; i < array_length(global.__guiSavedColors); ++i)
	{
		var _colorButton = new GUI_ColorButton(global.__guiSavedColors[i]);
		_colorButton.OnClick = method({ ColorPicker: _self, Button: _colorButton }, function () {
			var _savedColor = Button.Color;
			if (_savedColor)
			{
				var _colorStored = make_color_rgb(_savedColor.Red, _savedColor.Green, _savedColor.Blue);
				ColorPicker.SetProps({
					Hue:color_get_hue(_colorStored),
					Sat:color_get_saturation(_colorStored),
					Val:color_get_value(_colorStored),
					Alpha:_savedColor.Alpha,
				});
			}
		});
		ContainerColors.Add(_colorButton);
	}

	static Canvas_Update = Update;

	static Update = function () {
		Canvas_Update();

		if (IsDragged())
		{
			Root.Cursor = cr_size_all;
		}

		var _colorNew = make_color_hsv(Hue, Sat, Val);
		Color.Red = color_get_red(_colorNew);
		Color.Green = color_get_green(_colorNew);
		Color.Blue = color_get_blue(_colorNew);
		Color.Alpha = Alpha;

		SliderAlpha.SetProps({
			Color:_colorNew,
		});

		// FIXME: I really have that I have to do this. This GUI system needs
		// to automatically update input values when they are edited from outside!
		if (!InputAlpha.IsFocused())  { InputAlpha.SetProps({  Value:floor(Alpha * 100) }); }
		if (!SliderAlpha.IsFocused()) { SliderAlpha.SetProps({ Value:Alpha }); }
		if (!InputHex.IsFocused())    { InputHex.SetProps({    Value:GUI_ByteArrayToHex([Color.Red, Color.Green, Color.Blue]) }); }
		if (!InputHue.IsFocused())    { InputHue.SetProps({    Value:floor(Hue) }); }
		if (!InputSat.IsFocused())    { InputSat.SetProps({    Value:floor(Sat) }); }
		if (!InputVal.IsFocused())    { InputVal.SetProps({    Value:floor(Val) }); }
		if (!InputRed.IsFocused())    { InputRed.SetProps({    Value:floor(Color.Red) }); }
		if (!InputGreen.IsFocused())  { InputGreen.SetProps({  Value:floor(Color.Green) }); }
		if (!InputBlue.IsFocused())   { InputBlue.SetProps({   Value:floor(Color.Blue) }); }

		if (keyboard_check_pressed(vk_escape)
			|| (mouse_check_button_pressed(mb_left)
			&& !IsMouseOver()
			&& !(Parent && Parent.IsMouseOver())
			&& !(Root && (DropdownType.DropdownMenu.IsAncestorOf(Root.WidgetHovered) || IsAncestorOf(Root.WidgetHovered)))))
		{
			Destroy();
		}

		return self;
	};

	static Canvas_Draw = Draw;

	static Draw = function () {
		GUI_DrawShadow(RealX, RealY, RealWidth, RealHeight);
		Canvas_Draw();
		return self;
	};
}
