class_name TestSuite
extends RefCounted

## Test harness used by TestRunner.

class TestCase:
	var name: String
	var target: Object
	var method: Callable

var _cases: Array[TestCase] = []
var _results: Array[Dictionary] = []
var _failed: int = 0

func register(name: String, target: Object, method: Callable) -> void:
	var tc: TestCase = TestCase.new()
	tc.name = name
	tc.target = target
	tc.method = method
	_cases.append(tc)

func run_all(runner: TestRunner) -> void:
	_results.clear()
	_failed = 0
	for tc in _cases:
		var result: Dictionary = {"name": tc.name, "passed": true, "message": ""}
		var before_failed: int = _failed
		var callable: Callable = Callable(tc.target, tc.method.get_method())
		callable.call(self)
		if _failed > before_failed:
			result.passed = false
			result.message = _results.back().message
		_results.append(result)
	if runner.has_method("_on_suite_complete"):
		runner._on_suite_complete("all", _results, _failed)

func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		_record_fail(message if message != "" else "expected true")

func assert_false(condition: bool, message: String = "") -> void:
	if condition:
		_record_fail(message if message != "" else "expected false")

func assert_eq(a: Variant, b: Variant, message: String = "") -> void:
	if a != b:
		_record_fail(message if message != "" else "expected %s == %s" % [a, b])

func assert_ne(a: Variant, b: Variant, message: String = "") -> void:
	if a == b:
		_record_fail(message if message != "" else "expected %s != %s" % [a, b])

func _record_fail(message: String) -> void:
	_failed += 1
	_results.append({"name": "", "passed": false, "message": message})
