package;

using api.IdeckiaApi;

typedef Props = {
	@:editable("Time to wait until next action. The unit is definde with the value (ms, s or m). If no unit is provided, default is milliseconds. Examples: 500ms, 3s, 15m.",
		'1m')
	var time:String;
	@:editable("Ask to the user the time to wait every execution. The given time will override any value of [time] property.", false)
	var ask:Bool;
}

@:name("wait")
@:description("Waits given time until the next action. The time can be fixed (defined by the [time] property) or can be asked to the user every time the action is fired (if property [ask = true]).")
class Wait extends IdeckiaAction {
	var timeEreg = ~/([0-9]+)[\s]*(ms|s|m)?/;

	public function execute(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			calculateDelay().then(timeString -> {
				var timeValue = Std.parseInt(timeEreg.matched(1));
				var timeUnit:TimeUnit = timeEreg.matched(2);
				haxe.Timer.delay(() -> resolve(currentState), timeUnit.toMilliseconds(timeValue));
			}).catchError(msg -> server.dialog.error('Wait error', msg));
		});
	}

	function calculateDelay():js.lib.Promise<String> {
		return new js.lib.Promise((resolve, reject) -> {
			function checkTimeString(timeString) {
				if (timeString == null || Std.parseInt(timeString) == null || !timeEreg.match(timeString))
					reject('The given time value is not a valid value.');
				else
					resolve(timeString);
			}
			if (props.ask) {
				server.dialog.entry('Wait time', 'How many time do you want to wait?').then(checkTimeString);
			} else {
				checkTimeString(props.time);
			}
		});
	}
}

enum TimeUnitEnum {
	ms;
	s;
	m;
}

abstract TimeUnit(TimeUnitEnum) from TimeUnitEnum {
	inline function new(tu:TimeUnitEnum)
		this = tu;

	public function toMilliseconds(timeValue:UInt)
		return switch this {
			case TimeUnitEnum.ms: timeValue;
			case TimeUnitEnum.s: timeValue * 1000;
			case TimeUnitEnum.m: timeValue * 60 * 1000;
		}

	@:from
	static public inline function fromString(s:String) {
		return new TimeUnit(switch s {
			case 'ms':
				TimeUnitEnum.ms;
			case 's':
				TimeUnitEnum.s;
			case 'm':
				TimeUnitEnum.m;
			case x:
				trace('Unknown time unit [$x]. Using milliseconds by default.');
				TimeUnitEnum.ms;
		});
	}
}
