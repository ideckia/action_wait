package;

using api.IdeckiaApi;

typedef Props = {
	@:editable("Milliseconds to wait until next action", 500)
	var ms:UInt;
}

@:name("wait")
@:description("Waits given milliseconds until the next action")
class Wait extends IdeckiaAction {
	public function execute(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			haxe.Timer.delay(() -> resolve(currentState), props.ms);
		});
	}
}
