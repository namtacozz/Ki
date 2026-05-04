# Final Report Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build final report flow after Future inner space, with AI report, structured fallback, retry, and replay.

**Architecture:** `ReportBuilder` owns final-report context assembly, AI report normalization, and local fallback. `MainController` owns UI flow: request report after three spaces, render loading/error/report screens, retry AI, and replay by resetting `GameState`. `AIClient` stays transport-only; prompt schema lives in `data/prompts.json`.

**Tech Stack:** Godot 4.x, GDScript, JSON data, local AI proxy via existing `AIClient`, RTK shell wrapper.

---

## File map

- Modify: `scripts/report/report_builder.gd` — build final report context, normalize AI output, build local fallback summary.
- Modify: `scripts/ui/main_controller.gd` — call `ReportBuilder`, render schema fields, handle final-report retry/fallback/replay.
- Modify: `data/prompts.json` — require exact final report JSON schema.
- Modify: `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md` — document final report flow and changed module roles.

---

### Task 1: Expand ReportBuilder data contract

**Files:**
- Modify: `scripts/report/report_builder.gd`

- [ ] **Step 1: Replace `scripts/report/report_builder.gd` with focused helpers**

```gdscript
extends Node

const REPORT_KEYS := [
	"title",
	"core_self",
	"past_pattern",
	"present_tension",
	"future_invitation",
	"advice",
	"keywords",
]

func build_context() -> Dictionary:
	return {
		"onboarding_answers": GameState.onboarding_answers.duplicate(true),
		"selected_cards": GameState.selected_cards.duplicate(true),
		"spread": _build_spread(),
		"inner_space_results": GameState.inner_space_results.duplicate(true),
		"ai_reflections": GameState.ai_reflections.duplicate(true),
		"minigame_results": GameState.minigame_results.duplicate(true),
		"self_fragments": GameState.self_fragments,
		"final_report": GameState.final_report.duplicate(true),
	}

func normalize_report(data: Dictionary) -> Dictionary:
	var report := {}
	for key in REPORT_KEYS:
		if key == "keywords":
			report[key] = _normalize_keywords(data.get(key, []))
		else:
			report[key] = String(data.get(key, "")).strip_edges()
	return report

func build_local_summary(error_message: String) -> Dictionary:
	var spread := _build_spread()
	var past := spread.get("past", {})
	var present := spread.get("present", {})
	var future := spread.get("future", {})
	return {
		"title": "Bản soi chiếu tạm thời",
		"core_self": "AI chưa khả dụng: %s" % error_message,
		"past_pattern": _card_sentence(past, "Quá khứ đang nhắc lại một mô thức quanh"),
		"present_tension": _card_sentence(present, "Hiện tại đang giữ một lực căng quanh"),
		"future_invitation": _card_sentence(future, "Tương lai đang mời Ngài bước tới"),
		"advice": "Giữ lại điều đã học từ ba không gian, rồi thử lại AI khi proxy sẵn sàng.",
		"keywords": _fallback_keywords(),
	}

func _build_spread() -> Dictionary:
	var spread := {}
	for card in GameState.selected_cards:
		var position := String(card.get("position", "")).to_lower()
		if not position.is_empty():
			spread[position] = card.duplicate(true)
	return spread

func _normalize_keywords(value: Variant) -> Array[String]:
	var keywords: Array[String] = []
	if value is Array:
		for item in value:
			var keyword := String(item).strip_edges()
			if not keyword.is_empty():
				keywords.append(keyword)
	elif value is String:
		for item in String(value).split(",", false):
			var keyword := item.strip_edges()
			if not keyword.is_empty():
				keywords.append(keyword)
	while keywords.size() > 3:
		keywords.pop_back()
	while keywords.size() < 3:
		keywords.append("Soi chiếu")
	return keywords

func _fallback_keywords() -> Array[String]:
	var keywords: Array[String] = []
	for card in GameState.selected_cards:
		var card_keywords: Variant = card.get("keywords", [])
		if card_keywords is Array:
			for keyword in card_keywords:
				var text := String(keyword).strip_edges()
				if not text.is_empty() and not keywords.has(text):
					keywords.append(text)
				if keywords.size() == 3:
					return keywords
	while keywords.size() < 3:
		keywords.append("Soi chiếu")
	return keywords

func _card_sentence(card: Dictionary, prefix: String) -> String:
	if card.is_empty():
		return "%s hành trình chưa hoàn tất." % prefix
	return "%s %s." % [prefix, String(card.get("name", "lá bài chưa rõ"))]
```

- [ ] **Step 2: Run Godot parse check**

Run:

```bash
rtk godot --headless --path "D:/KÌ" --quit
```

Expected: no GDScript parse error from `scripts/report/report_builder.gd`. If existing unrelated errors appear, record exact output before continuing.

---

### Task 2: Wire MainController final report request and UI

**Files:**
- Modify: `scripts/ui/main_controller.gd`

- [ ] **Step 1: Add final report state variable near existing pending state**

In `scripts/ui/main_controller.gd`, after:

```gdscript
var pending_ai_card: Dictionary = {}
```

add:

```gdscript
var final_report_error := ""
```

- [ ] **Step 2: Replace `_on_report_ready` with normalization + report screen**

Replace current `_on_report_ready`:

```gdscript
func _on_report_ready(data: Dictionary) -> void:
	GameState.set_final_report(data)
	_show_label_screen("Bản Soi Chiếu Cuối", _format_ai_dictionary(data), func(): pass)
```

with:

```gdscript
func _on_report_ready(data: Dictionary) -> void:
	final_report_error = ""
	var report := ReportBuilder.normalize_report(data)
	GameState.set_final_report(report)
	_show_final_report_screen(report, false)
```

- [ ] **Step 3: Replace `_on_ai_failed` so final report gets fallback but reflections keep existing behavior**

Replace current `_on_ai_failed`:

```gdscript
func _on_ai_failed(message: String) -> void:
	_show_ai_error_screen(message)
```

with:

```gdscript
func _on_ai_failed(message: String) -> void:
	if pending_ai_card.is_empty():
		final_report_error = message
		var report := ReportBuilder.build_local_summary(message)
		GameState.set_final_report(report)
		_show_final_report_screen(report, true)
		return
	_show_ai_error_screen(message)
```

- [ ] **Step 4: Replace `_request_final_report` context assembly with ReportBuilder**

Replace current `_request_final_report`:

```gdscript
func _request_final_report() -> void:
	pending_ai_card = {}
	_show_loading_screen("Bản Soi Chiếu Cuối", "KÌ đang tổng hợp hành trình của Ngài...")
	AIClient.request_final_report({
		"onboarding_answers": GameState.onboarding_answers.duplicate(true),
		"selected_cards": GameState.selected_cards.duplicate(true),
		"inner_space_results": GameState.inner_space_results.duplicate(true),
		"ai_reflections": GameState.ai_reflections.duplicate(true),
		"minigame_results": GameState.minigame_results.duplicate(true),
		"self_fragments": GameState.self_fragments,
	})
```

with:

```gdscript
func _request_final_report() -> void:
	pending_ai_card = {}
	final_report_error = ""
	_show_loading_screen("Bản Soi Chiếu Cuối", "KÌ đang tổng hợp hành trình của Ngài...")
	AIClient.request_final_report(ReportBuilder.build_context())
```

- [ ] **Step 5: Add final report screen + replay helpers after `_request_final_report`**

Add this block after `_request_final_report`:

```gdscript
func _show_final_report_screen(report: Dictionary, is_local_summary: bool) -> void:
	_clear_screen()
	var panel := _create_center_panel(Vector2(980, 680))
	var box := _create_panel_box(panel)
	box.add_child(_create_label(String(report.get("title", "Bản Soi Chiếu Cuối")), 34))
	if is_local_summary:
		box.add_child(_create_label("Bản tạm thời. AI proxy chưa trả report hoàn chỉnh.", 18))
		if not final_report_error.is_empty():
			box.add_child(_create_label(final_report_error, 16))
	box.add_child(_create_report_field("Core self", String(report.get("core_self", ""))))
	box.add_child(_create_report_field("Past pattern", String(report.get("past_pattern", ""))))
	box.add_child(_create_report_field("Present tension", String(report.get("present_tension", ""))))
	box.add_child(_create_report_field("Future invitation", String(report.get("future_invitation", ""))))
	box.add_child(_create_report_field("Advice", String(report.get("advice", ""))))
	box.add_child(_create_report_field("Keywords", ", ".join(report.get("keywords", []))))
	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 16)
	if is_local_summary:
		var retry_button := _create_button("Thử lại AI")
		retry_button.pressed.connect(_request_final_report)
		button_row.add_child(retry_button)
	var replay_button := _create_button("Chơi lại")
	replay_button.pressed.connect(_replay_from_title)
	button_row.add_child(replay_button)
	box.add_child(button_row)
	screen_root.add_child(panel)
	current_screen = panel

func _create_report_field(title: String, body: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.add_child(_create_label(title, 18))
	box.add_child(_create_label(body, 20))
	return box

func _replay_from_title() -> void:
	GameState.reset_run()
	pending_ai_card = {}
	final_report_error = ""
	show_title()
```

- [ ] **Step 6: Run Godot parse check**

Run:

```bash
rtk godot --headless --path "D:/KÌ" --quit
```

Expected: no parse errors in `scripts/ui/main_controller.gd`.

---

### Task 3: Tighten final report prompt schema

**Files:**
- Modify: `data/prompts.json`

- [ ] **Step 1: Replace `final_report.user` text**

Change:

```json
"user": "Tạo bản soi chiếu cuối từ 3 lá bài, lựa chọn, câu trả lời tự do, mini game, và Self Fragment."
```

To:

```json
"user": "Tạo bản soi chiếu cuối từ onboarding_answers, selected_cards/spread, inner_space_results, ai_reflections, minigame_results, và self_fragments. Chỉ trả JSON object hợp lệ với đúng keys: title, core_self, past_pattern, present_tension, future_invitation, advice, keywords. keywords là array đúng 3 string. Không thêm markdown, không thêm text ngoài JSON."
```

- [ ] **Step 2: Validate JSON with Python**

Run:

```bash
rtk python -m json.tool "D:/KÌ/data/prompts.json"
```

Expected: formatted JSON printed, exit code 0.

---

### Task 4: Update structure docs

**Files:**
- Modify: `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md`

- [ ] **Step 1: Update `ReportBuilder` role section**

In `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md`, update `ReportBuilder` bullets to include:

```markdown
- Gom dữ liệu cuối từ `GameState` thành context gửi AI.
- Chuẩn hóa AI final report về schema hiển thị.
- Tạo local fallback đủ field khi AI/proxy fail.
```

- [ ] **Step 2: Update scene flow final report section**

Ensure scene flow includes:

```markdown
- Sau Future space + mini game + AI reflection, `MainController` gọi `ReportBuilder.build_context()` rồi `AIClient.request_final_report()`.
- UI hiển thị loading trong lúc chờ AI.
- Final report hiển thị các field: `title`, `core_self`, `past_pattern`, `present_tension`, `future_invitation`, `advice`, `keywords`.
- Nếu AI/proxy fail, UI hiển thị local summary có cùng schema và nút thử lại.
- Nút chơi lại gọi reset run và quay về title.
```

- [ ] **Step 3: Add changelog entry dated 2026-05-04**

Add under structure changelog:

```markdown
- 2026-05-04: Hoàn thiện final report flow: ReportBuilder gom context/normalize/fallback, MainController hiển thị final report + retry + replay, `data/prompts.json` khai báo schema JSON report.
```

---

### Task 5: Final verification

**Files:**
- Verify working tree only; no code edits unless parse errors found.

- [ ] **Step 1: Run Godot headless check**

Run:

```bash
rtk godot --headless --path "D:/KÌ" --quit
```

Expected: Godot exits without script parse errors.

- [ ] **Step 2: Check git status**

Run:

```bash
rtk git status --short
```

Expected changed files include only relevant implementation/docs files plus pre-existing unrelated files. Do not stage or commit unless Ngài explicitly requests commit.

---

## Self-review

- Spec coverage: final data context, AI request, loading, schema rendering, AI fail fallback + retry, replay reset, prompt schema, docs update, and Godot verification are covered.
- Placeholder scan: no `TBD`, `TODO`, `implement later`, or vague test steps remain.
- Type consistency: `ReportBuilder.build_context()`, `ReportBuilder.normalize_report(data)`, `ReportBuilder.build_local_summary(error_message)`, `_show_final_report_screen(report, is_local_summary)`, and `_replay_from_title()` names match across tasks.
