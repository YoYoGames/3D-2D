/// @func ST_TaskQueue([_timeBudget])
///
/// @desc
///
/// @param {Real} [_timeBudget]
function ST_TaskQueue(_timeBudget=8000) constructor
{
	/// @var {Real}
	TimeBudget = _timeBudget;

	/// @var {Id.DsList<ST_Task>}
	Tasks = ds_list_create();

	/// @var {Real}
	/// @readonly
	Progress = 0;

	/// @var {Real}
	/// @readonly
	ProgressMax = 0;

	/// @var {Real}
	/// @readonly
	BlockingTaskCount = 0;

	/// @func Add(_task)
	///
	/// @desc
	///
	/// @param {Struct.ST_Task} _task
	///
	/// @return {Struct.ST_TaskQueue} Returns `self`.
	static Add = function (_task) {
		gml_pragma("forceinline");
		ds_list_add(Tasks, _task);
		++ProgressMax;
		if (_task.IsBlocking)
		{
			++BlockingTaskCount;
		}
		return self;
	};

	/// @func GetTaskCount()
	///
	/// @desc
	///
	/// @return {Real}
	static GetTaskCount = function () {
		gml_pragma("forceinline");
		return ds_list_size(Tasks);
	};

	/// @func Process()
	///
	/// @desc
	///
	/// @return {Struct.ST_TaskQueue} Returns `self`.
	static Process = function () {
		var _timer = get_timer();
		while (!ds_list_empty(Tasks)
			&& (get_timer() - _timer) < TimeBudget)
		{
			var _task = Tasks[| 0];
			_task.Process();
			if (_task.IsFinished)
			{
				if (_task.Callback)
				{
					_task.Callback(_task);
				}
				_task.Destroy();
				ds_list_delete(Tasks, 0);
				++Progress;
				if (ds_list_empty(Tasks))
				{
					Progress = 0;
					ProgressMax = 0;
				}
				if (_task.IsBlocking)
				{
					--BlockingTaskCount;
				}
			}
		}
		return self;
	};

	/// @func Destroy()
	///
	/// @desc
	///
	/// @return {Undefined}
	static Destroy = function () {
		var i = 0;
		repeat (ds_list_size(Tasks))
		{
			Tasks[| i++].Destroy();
		}
		ds_list_destroy(Tasks);
		return undefined;
	};
}
