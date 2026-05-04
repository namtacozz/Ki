extends Node

const DEFAULT_PROXY_URL := "http://127.0.0.1:8787"

var proxy_url := DEFAULT_PROXY_URL

func request_interpretation(payload: Dictionary) -> Dictionary:
	return {
		"ok": false,
		"error": "AI proxy chưa được kết nối.",
		"payload": payload,
	}
