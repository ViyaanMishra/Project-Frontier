extends Node

## In-scene test runner that loads autoloads and runs all suites.

func _ready() -> void:
	var runner: TestRunner = TestRunner.new()
	add_child(runner)

