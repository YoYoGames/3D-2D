/// @func ST_Task([_callback])
///
/// @desc
///
/// @param {Function} [_callback]
function ST_Task(_callback=undefined) constructor
{
	/// @var {Function}
	Callback = _callback;

	/// @var {Bool}
	IsFinished = false;

	/// @var {Bool}
	/// @readonly
	IsBlocking = false;

	/// @func Process()
	///
	/// @desc
	///
	/// @return {Struct.ST_Task} Returns `self`.
	static Process = function () {
		IsFinished = true;
		return self;
	};

	/// @func Destroy()
	///
	/// @desc
	///
	/// @return {Undefined}
	static Destroy = function () {
		return undefined;
	};
}
