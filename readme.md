# Action for ideckia: wait

## Definition

Waits given milliseconds until the next action

## Properties

| Name | Type | Description | Shared | Default | Possible values |
| ----- |----- | ----- | ----- | ----- | ----- |
| ms | UInt | Milliseconds to wait until next action | false | 500 | null |

## On single click

Starts the timer

## Example in layout file

```json
{
    "state": {
        "text": "wait action example",
        "actions": [
            {
                "name": "wait",
                "props": {
                    "ms": 500
                }
            }
        ]
    }
}
```