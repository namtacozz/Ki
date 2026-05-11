# Final Report Two Sections Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rút gọn final report thành 2 mục ngắn: một mục soi chiếu tổng hợp xuyên suốt 3 không gian cộng Mảnh Hồn, và một mục lời khuyên cuối.

**Architecture:** Giữ nguyên flow AI request và màn final report hiện tại, nhưng đổi schema final report từ nhiều field phân mảnh sang 2 field ngắn gọn. Sửa prompt AI, lớp normalize/fallback trong `ReportBuilder`, và renderer `FinalReportScreen` để chỉ hiển thị 2 mục. Không thêm scene mới, không đổi flow gameplay.

**Tech Stack:** Godot 4.x, GDScript, JSON prompt config, local AI proxy

---

## File Structure

- Modify: `data/prompts.json`
  - Đổi yêu cầu prompt `final_report` để model chỉ trả `title`, `overall_reflection`, `guidance`, `keywords`.
- Modify: `scripts/report/report_builder.gd`
  - Đổi danh sách key chuẩn hóa, fallback local summary, và keyword normalization theo schema mới.
- Modify: `scripts/ui/screens/final_report_screen.gd`
  - Chỉ render 2 field nội dung chính, và cập nhật copy-to-clipboard theo schema mới.
- Modify: `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md`
  - Đồng bộ mô tả final report schema/UI nếu cấu trúc logic hiển thị đổi.
- Verify: `scripts/ui/main_controller.gd`
  - Xác nhận không cần đổi flow gọi `ReportBuilder.normalize_report()` và `screen.setup(...)`.

---

### Task 1: Change final report AI schema

**Files:**
- Modify: `data/prompts.json:5-8`
- Verify: `scripts/ai/ai_client.gd:82-90`

- [ ] **Step 1: Update final report prompt to request only 2 sections**

```json
"final_report": {
  "system": "Bạn là KÌ, tổng hợp hành trình nội tâm. Hãy soi chiếu ngắn gọn nhưng sắc bén, dễ đọc cho người chơi. Trả lời bằng JSON hợp lệ.",
  "user": "Tạo bản soi chiếu cuối từ onboarding_answers, selected_cards/spread, inner_space_results, ai_reflections, minigame_results, soul_fragments_total, soul_fragments_by_position, và soul_fragment_events. Gộp toàn bộ Quá khứ / Hiện tại / Tương lai thành một mục duy nhất tên overall_reflection, trong đó phải nhắc được mẫu lặp hoặc tiến trình xuyên suốt cả 3 không gian và ảnh hưởng của Mảnh Hồn. Tạo thêm đúng một mục guidance là lời khuyên cuối cùng, ngắn gọn và thực tế. Chỉ trả JSON object hợp lệ với đúng keys: title, overall_reflection, guidance, keywords. keywords là array đúng 3 string. Không thêm markdown, không thêm text ngoài JSON."
}
```

- [ ] **Step 2: Verify no AI client schema-specific parsing blocks this change**

Run inspection on:
- `scripts/ai/ai_client.gd:82-90`

Expected: AI client only unwraps JSON and does not hardcode old report keys.

- [ ] **Step 3: Commit prompt schema update**

```bash
rtk git add data/prompts.json
rtk git commit -m "refactor: simplify final report ai schema"
```

### Task 2: Normalize and fallback report data to 2 sections

**Files:**
- Modify: `scripts/report/report_builder.gd:2-48`
- Verify: `scripts/ui/main_controller.gd:337-341`

- [ ] **Step 1: Write failing expectation as executable checklist**

Expected normalized dictionary shape:

```gdscript
{
	"title": "...",
	"overall_reflection": "...",
	"guidance": "...",
	"keywords": ["...", "...", "..."]
}
```

Expected failure before code change:
- `normalize_report()` returns empty strings for `overall_reflection` and `guidance`
- `build_local_summary()` still returns `core_self`, `past_pattern`, `present_tension`, `future_invitation`, `advice`

- [ ] **Step 2: Replace old report key list with new schema**

```gdscript
const REPORT_KEYS := [
	"title",
	"overall_reflection",
	"guidance",
	"keywords",
]
```

- [ ] **Step 3: Update normalize_report() to fill new fields**

```gdscript
func normalize_report(data: Dictionary) -> Dictionary:
	var report := {}
	for key in REPORT_KEYS:
		if key == "keywords":
			report[key] = _normalize_keywords(data.get(key, []))
		else:
			report[key] = String(data.get(key, "")).strip_edges()
	return report
```

- [ ] **Step 4: Rewrite local fallback summary to match 2-section output**

```gdscript
func build_local_summary(error_message: String) -> Dictionary:
	var spread := _build_spread()
	var past: Dictionary = spread.get("past", {})
	var present: Dictionary = spread.get("present", {})
	var future: Dictionary = spread.get("future", {})
	return {
		"title": "Bản soi chiếu tạm thời",
		"overall_reflection": "AI chưa khả dụng: %s\n\nQuá khứ: %s\nHiện tại: %s\nTương lai: %s\nTổng Mảnh Hồn: %d." % [
			error_message,
			_card_sentence(past, "Mô thức nổi bật quanh"),
			_card_sentence(present, "Lực căng hiện tại quanh"),
			_card_sentence(future, "Lời mời phía trước quanh"),
			GameState.soul_fragments,
		],
		"guidance": "Giữ lại trục chung lặp đi lặp lại giữa ba không gian, rồi chọn một hành động nhỏ nhưng thật để thay đổi nó trong hôm nay.",
		"keywords": _fallback_keywords(),
	}
```

- [ ] **Step 5: Verify main controller still works unchanged**

Check:
- `scripts/ui/main_controller.gd:337-341`

Expected: `ReportBuilder.normalize_report(data)` still returns `Dictionary`, no caller changes needed.

- [ ] **Step 6: Commit report normalization update**

```bash
rtk git add scripts/report/report_builder.gd
rtk git commit -m "refactor: collapse final report into two sections"
```

### Task 3: Simplify final report screen rendering

**Files:**
- Modify: `scripts/ui/screens/final_report_screen.gd:31-79`
- Verify: `scenes/ui/report_field.tscn`

- [ ] **Step 1: Replace 5 field render calls with 2 field render calls**

```gdscript
func setup(report: Dictionary, is_local_summary: bool, final_report_error: String) -> void:
	_current_report = report
	title_label.text = String(report.get("title", "Bản Soi Chiếu Cuối"))
	temporary_label.visible = is_local_summary
	error_label.visible = is_local_summary and not final_report_error.is_empty()
	error_label.text = final_report_error
	retry_button.visible = is_local_summary
	_clear_fields()

	_add_field("Tổng soi chiếu", String(report.get("overall_reflection", "")))
	_add_field("Lời khuyên", String(report.get("guidance", "")))
	_add_field("Từ khóa", ", ".join(report.get("keywords", [])))
```

- [ ] **Step 2: Simplify clipboard export to match 2-section schema**

```gdscript
var fields = [
	["Tổng soi chiếu", "overall_reflection"],
	["Lời khuyên", "guidance"]
]
```

Expected clipboard body:

```text
--- KÌ: Bản Soi Chiếu Cuối ---

Tước Hiệu: ...

✨ Tổng soi chiếu:
...

✨ Lời khuyên:
...

🔑 Keywords: ...
```

- [ ] **Step 3: Verify no empty legacy sections remain on screen**

Run manual checklist:
- Final report shows title
- Final report shows only 2 main text cards + keywords
- Retry/local-summary mode still shows warning correctly

- [ ] **Step 4: Commit screen simplification**

```bash
rtk git add scripts/ui/screens/final_report_screen.gd
rtk git commit -m "refactor: shorten final report presentation"
```

### Task 4: Update project structure note and run manual verification

**Files:**
- Modify: `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md`
- Verify: running game flow

- [ ] **Step 1: Update structure note for final report behavior**

Add/update wording so final report describes:
- one unified reflection across all 3 spaces
- one final advice section
- soul fragments included in overall synthesis

- [ ] **Step 2: Run desktop flow to verify report brevity**

Run game and check:
1. Complete onboarding
2. Finish all 3 spaces
3. Reach final report
4. Confirm report shows concise `overall_reflection`
5. Confirm report shows concise `guidance`
6. Confirm no legacy fields (`core_self`, `past_pattern`, `present_tension`, `future_invitation`) remain

- [ ] **Step 3: Commit docs update after verification**

```bash
rtk git add "Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md"
rtk git commit -m "docs: update final report structure"
```

---

## Self-Review

- Spec coverage: covers AI schema, normalization, local fallback, UI rendering, clipboard export, structure doc, manual verification.
- Placeholder scan: no TODO/TBD placeholders left.
- Type consistency: final report schema consistently uses `title`, `overall_reflection`, `guidance`, `keywords` across prompt, builder, and screen.
