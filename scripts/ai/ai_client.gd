extends Node

signal reflection_ready(space_id: String, data: Dictionary)
signal report_ready(data: Dictionary)
signal ai_failed(message: String)

const DEFAULT_PROXY_URL := "http://127.0.0.1:8787/generate"
const LOCAL_CONFIG_PATH := "res://data/local_config.json"
const EXAMPLE_CONFIG_PATH := "res://data/local_config.example.json"
const PROMPTS_PATH := "res://data/prompts.json"

var proxy_url := DEFAULT_PROXY_URL
var prompts: Dictionary = {}
var _http_request: HTTPRequest
var _pending_type := ""
var _pending_space_id := ""

func _ready() -> void:
	_load_config()
	_load_prompts()
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

func request_reflection(space_id: String, context: Dictionary) -> void:
	var prompt := _build_prompt("card_interpretation")
	_send_request("reflection", prompt, context, space_id)

func request_final_report(context: Dictionary) -> void:
	var prompt := _build_prompt("final_report")
	_send_request("final_report", prompt, context, "")

func _load_config() -> void:
	var config: Dictionary = JsonLoader.load_json(LOCAL_CONFIG_PATH, {})
	if config.is_empty():
		config = JsonLoader.load_json(EXAMPLE_CONFIG_PATH, {})
	proxy_url = String(config.get("ai_proxy_url", DEFAULT_PROXY_URL))
	if not proxy_url.ends_with("/generate"):
		proxy_url = proxy_url.rstrip("/") + "/generate"

func _load_prompts() -> void:
	var loaded: Variant = JsonLoader.load_json(PROMPTS_PATH, {})
	prompts = loaded if loaded is Dictionary else {}



func _build_prompt(prompt_key: String) -> String:
	var prompt_data: Variant = prompts.get(prompt_key, {})
	if prompt_data is Dictionary:
		return "%s\n\n%s" % [String(prompt_data.get("system", "")), String(prompt_data.get("user", ""))]
	return "Trả lời bằng JSON hợp lệ."

func _send_request(request_type: String, prompt: String, context: Dictionary, space_id: String) -> void:
	if _http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		emit_signal("ai_failed", "AI proxy đang xử lý yêu cầu trước.")
		return
	_pending_type = request_type
	_pending_space_id = space_id
	var payload := {
		"type": request_type,
		"prompt": prompt,
		"context": context,
	}
	var body := JSON.stringify(payload)
	var error := _http_request.request(proxy_url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	if error != OK:
		emit_signal("ai_failed", "Không gửi được request tới AI proxy: %s" % error_string(error))

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("ai_failed", "AI proxy không phản hồi: %s" % _request_result_label(result))
		return
	var text := body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		emit_signal("ai_failed", "AI proxy trả response không phải JSON.")
		return
	var wrapper := parsed as Dictionary
	if response_code < 200 or response_code >= 300 or not bool(wrapper.get("ok", false)):
		emit_signal("ai_failed", String(wrapper.get("error", "AI proxy báo lỗi.")))
		return
	var ai_text := String(wrapper.get("text", ""))
	var ai_data: Variant = JSON.parse_string(ai_text)
	if not ai_data is Dictionary:
		emit_signal("ai_failed", "AI trả nội dung không phải JSON hợp lệ.")
		return
	if _pending_type == "reflection":
		emit_signal("reflection_ready", _pending_space_id, ai_data as Dictionary)
	elif _pending_type == "final_report":
		emit_signal("report_ready", ai_data as Dictionary)

func _request_result_label(result: int) -> String:
	match result:
		HTTPRequest.RESULT_CANT_RESOLVE:
			return "không resolve được host"
		HTTPRequest.RESULT_CANT_CONNECT:
			return "không kết nối được"
		HTTPRequest.RESULT_CONNECTION_ERROR:
			return "lỗi kết nối"
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "lỗi TLS"
		HTTPRequest.RESULT_TIMEOUT:
			return "timeout"
		_:
			return "mã lỗi %d" % result
