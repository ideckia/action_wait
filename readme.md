# Action for ideckia: wait

## Definition

Waits given time until the next action. The time can be fixed (defined by the [time] property) or can be asked to the user every time the action is fired (if property [ask = true]).

## Properties

| Name | Type | Description | Shared | Default | Possible values |
| ----- |----- | ----- | ----- | ----- | ----- |
| time | String | Time to wait until next action. The unit is definde with the value (ms, s or m). If no unit is provided, default is milliseconds. Examples: 500ms, 3s, 15m. | false | '1m' | null |
| ask | Bool | Ask to the user the time to wait every execution. The given time will override any value of [time] property. | false | false | null |

## On single click

* if `ask = false`, starts the timer to wait the defined `time`.
* if `ask = true`, shows a dialog asking the user the time to wait (ignoring the `time` property if defined).

## Example in layout file

```json
{
    "state": {
        "text": "wait action example",
        "actions": [
            {
                "name": "wait",
                "props": {
                    "time": "10s"
                }
            }
        ]
    }
}
```