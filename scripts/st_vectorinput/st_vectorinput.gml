/// @func ST_VectorInput(_vector[, _props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} _vector
/// @param {Struct} [_props]
function ST_VectorInput(_vector, _props={})
	: GUI_Widget(_props) constructor
{
	Vector = _vector;

	Labels = _props[$ "Labels"] ?? ["X", "Y", "Z"];

	var _labelCount = array_length(Labels);

	Colors = _props[$ "Colors"] ?? [ #FF767B, #7DAF37, #0395CD ];

	Spacing = _props[$ "Spacing"] ?? 4;

	if (_props[$ "Width"] == undefined)
	{
		var _width = (80 * _labelCount) + (Spacing * ((_labelCount * 2) - 1));
		for (var i = 0; i < _labelCount; ++i)
		{
			_width += string_width(Labels[i]);
		}
		SetWidth(_width);
	}

	WholeNumbers = _props[$ "WholeNumbers"] ?? false;

	Min = GUI_StructGet(_props, "Min");

	Max = GUI_StructGet(_props, "Max");

	Step = _props[$ "Step"] ?? 1.0;

	VectorSize = _labelCount;

	MaxChildCount = VectorSize * 2;

	LabelWidgets = [];

	InputWidgets = [];

	var _self = self;
	for (var i = 0; i < VectorSize; ++i)
	{
		var _text = new GUI_Text(Labels[i], { Color: Colors[i] });
		Add(_text);
		array_push(LabelWidgets, _text);

		var _context = {
			VectorInput: _self,
			Vector: Vector,
			Index: i,
		};

		var _input = new GUI_Input(Vector.Get(i), {
			OnChange: method(_context, function (_value, _valueOld) {
				var _vecOld = Vector.Clone();
				Vector.SetIndex(Index, Vector.Get(Index) + _value - _valueOld);
				if (VectorInput.OnChange)
				{
					VectorInput.OnChange(Vector, _vecOld);
				}
			}),
		});
		Add(_input);
		array_push(InputWidgets, _input);
	}

	static Super_Update = Update;

	static Update = function () {
		Super_Update();

		for (var i = 0; i < VectorSize; ++i)
		{
			var _input = InputWidgets[i];
			_input.Disabled = Disabled;
			_input.WholeNumbers = WholeNumbers;
			_input.Min = Min;
			_input.Max = Max;
			_input.Step = Step;
			if (!_input.IsFocused())
			{
				_input.Value = Vector.Get(i);
			}
		}

		return self;
	};

	static Layout = function (_force=false) {
		CHECK_LAYOUT_CHANGED;

		var _x = RealX;
		var _y = RealY;
		var _parentWidth = RealWidth;
		var _parentHeight = RealHeight;
		var _spacing = Spacing;

		var _inputWidth = RealWidth;
		for (var i = 0; i < VectorSize; ++i)
		{
			var _text = LabelWidgets[i];
			_inputWidth -= _text.RealWidth;
		}
		_inputWidth = floor((_inputWidth - (_spacing * (MaxChildCount - 1))) / VectorSize);

		for (var i = 0; i < VectorSize; ++i)
		{
			InputWidgets[i].SetWidth(_inputWidth);
		}

		for (var i = 0; i < array_length(Children); ++i)
		{
			with (Children[i])
			{
				SetProps({
					RealWidth: (WidthUnit == "px") ? Width : (_parentWidth * (Width / 100.0)),
					RealHeight: (HeightUnit == "px") ? Height : (_parentHeight * (Height / 100.0)),
					RealX: _x,
					RealY: _y,
				});
				_x += RealWidth + _spacing;
			}
		}

		return self;
	};
}
