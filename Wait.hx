package;

using api.IdeckiaApi;

typedef Props = {
	@:editable("prop_time", '1m')
	var time:String;
	@:editable("prop_ask", false)
	var ask:Bool;
}

@:name("wait")
@:description("action_description")
@:localize
class Wait extends IdeckiaAction {
	var timeEreg = ~/([0-9]+)[\s]*(ms|s|m)?/;
	var previousState:ItemState;

	public function execute(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		return new js.lib.Promise((resolve, reject) -> {
			calculateDelay().then(timeString -> {
				var timeValue = Std.parseInt(timeEreg.matched(1));
				var timeUnit:TimeUnit = timeEreg.matched(2);
				var totalMilliseconds = timeUnit.toMilliseconds(timeValue);
				var timer;
				if (totalMilliseconds > 1000) {
					// if it's more than a second, show a countdown
					previousState = {
						text: currentState.text,
						textSize: currentState.textSize,
						textColor: currentState.textColor,
						icon: currentState.icon,
						bgColor: currentState.bgColor
					}
					var delay = 100;
					var totalCalls = totalMilliseconds / delay;
					var callCounter = 0;
					var dt = new datetime.DateTime(0).add(Second(Std.int(totalMilliseconds / 1000)));
					core.updateClientState({
						text: formatTime(dt)
					});
					timer = new haxe.Timer(delay);
					timer.run = () -> {
						callCounter++;
						if (callCounter % 10 == 0) {
							dt = dt.add(Second(-1));

							core.updateClientState({
								text: formatTime(dt)
							});
						}
						if (callCounter >= totalCalls) {
							resolve(new ActionOutcome({state: previousState}));
							timer.stop();
						}
					};
				} else {
					timer = new haxe.Timer(totalMilliseconds);
					timer.run = () -> {
						timer.stop();
						resolve(new ActionOutcome({state: currentState}));
					};
				}
			}).catchError(msg -> core.dialog.error('Wait error', msg));
		});
	}

	inline function formatTime(dt:datetime.DateTime) {
		return (dt.getHour() > 0) ? dt.format('%H:%M:%S') : dt.format('%M:%S');
	}

	function calculateDelay():js.lib.Promise<String> {
		return new js.lib.Promise((resolve, reject) -> {
			function checkTimeString(timeString) {
				if (timeString == null || Std.parseInt(timeString) == null || !timeEreg.match(timeString))
					reject(Loc.not_valid_value.tr());
				else
					resolve(timeString);
			}
			if (props.ask) {
				core.dialog.entry(Loc.dialog_title.tr(), Loc.dialog_body.tr()).then(response -> {
					switch response {
						case Some(time): checkTimeString(time);
						case None: checkTimeString(null);
					}
				});
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
