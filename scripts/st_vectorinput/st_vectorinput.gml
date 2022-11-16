/// @func ST_VectorInput(_vector[, _props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} _vector
/// @param {Struct} [_props]
function ST_VectorInput(_vector, _props={})
	: GUI_FlexLayout(_props) constructor
{
	Vector = _vector;

	Labels = _props[$ "Labels"] ?? ["X", "Y", "Z"];

	var _labelCount = array_length(Labels);

	Colors = _props[$ "Colors"] ?? [ #FF767B, #7DAF37, #0395CD ];

	SetWidth(_props[$ "Width"] ?? "100%");

	Gap = _props[$ "Gap"] ?? 4;

	WholeNumbers = _props[$ "WholeNumbers"] ?? false;

	Min = GUI_StructGet(_props, "Min");

	Max = GUI_StructGet(_props, "Max");

	Step = _props[$ "Step"] ?? 1.0;

	VectorSize = _labelCount;

	MaxChildCount = VectorSize * 2;

	InputWidgets = [];

	var _self = self;
	for (var i = 0; i < VectorSize; ++i)
	{
		Add(new GUI_Text(Labels[i], { Color: Colors[i] }));

		var _context = {
			VectorInput: _self,
			Vector: Vector,
			Index: i,
		};

		var _input = new GUI_Input(Vector.Get(i), {
			FlexGrow: 1,
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
}
