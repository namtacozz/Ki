# Desktop-Only Scope Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update project docs and implementation guidance so KÌ officially supports desktop browser only and no longer promises mobile-web usability.

**Architecture:** This change is documentation-first. Update source-of-truth project instructions first, then sync project structure and mentor-facing docs, then clean old plan/spec references that still promise mobile support. Do not change gameplay flow or scene behavior unless a tiny wording-only cleanup in implementation guidance is required.

**Tech Stack:** Markdown documentation, Godot 4.x project docs, existing `rtk` shell workflow.

---

## File Structure

**Modify:**
- `CLAUDE.md` — project source-of-truth instructions for target platform, core demo path, verification rules, and UX constraints.
- `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md` — architecture snapshot and changelog; must stay in sync whenever project structure or supported target changes.
- `Takanote/KÌ_PROJECT_OVERVIEW_MENTOR.md` — mentor-facing summary and demo-completion criteria.
- `docs/superpowers/plans/2026-05-04-visual-screen-scenes.md` — old implementation plan that still contains mobile-responsive tasks which should no longer be treated as required follow-up work.
- `docs/superpowers/plans/2026-05-04-md-questions-data.md` — old implementation plan with phone viewport verification.
- `docs/superpowers/specs/2026-05-04-md-questions-data-design.md` — old design spec with phone viewport acceptance criteria.

**Do not modify unless new evidence appears:**
- runtime `.gd` or `.tscn` files — mobile-safe behavior may remain in code; this plan only removes official mobile support requirements.

---

### Task 1: Update project source-of-truth instructions in `CLAUDE.md`

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Change supported target line**

Replace:

```md
- 🌐 Target: Desktop browser và phone browser.
```

With:

```md
- 🌐 Target: Desktop browser.
```

- [ ] **Step 2: Remove phone requirement from core demo path**

Replace:

```md
8. Browser desktop và viewport phone đều dùng được.
```

With:

```md
8. Browser desktop dùng được ổn định trong flow demo chính.
```

- [ ] **Step 3: Remove phone viewport verification requirement**

Replace this verification block fragment:

```md
Demo verification:
- Desktop browser chạy full flow.
- Phone viewport khoảng 390x844 không vỡ UI.
- AI proxy trả JSON hợp lệ.
- Game không crash nếu AI báo lỗi; hiển thị retry/error rõ.
- Mini games không softlock.
```

With:

```md
Demo verification:
- Desktop browser chạy full flow.
- Layout không vỡ ở cửa sổ desktop phổ biến.
- AI proxy trả JSON hợp lệ.
- Game không crash nếu AI báo lỗi; hiển thị retry/error rõ.
- Mini games không softlock.
```

- [ ] **Step 4: Remove mobile-first UX constraints**

Replace this UX block fragment:

```md
- UI phải touch-friendly.
- Text phải đọc được trên phone browser.
```

With:

```md
- UI phải dễ dùng trên desktop browser.
- Text phải đọc rõ ở layout desktop.
```

- [ ] **Step 5: Run focused grep to confirm mobile promises removed from `CLAUDE.md`**

Run:

```bash
rtk grep -nE "phone browser|viewport phone|390x844|touch-friendly" "D:/KÌ/CLAUDE.md"
```

Expected: no matches.

---

### Task 2: Sync structure document and changelog

**Files:**
- Modify: `Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md`

- [ ] **Step 1: Change target summary at top of file**

Replace:

```md
**Target:** Desktop browser + phone browser  
```

With:

```md
**Target:** Desktop browser  
```

- [ ] **Step 2: Update changelog entry that encodes phone-specific support as requirement**

Replace this line in changelog section:

```md
- Cập nhật `main_controller.gd`: panel, margin, text input, và card row co theo viewport phone 390x844.
```

With:

```md
- Cập nhật `main_controller.gd`: panel, margin, text input, và card row co theo viewport nhỏ; ghi nhận đây là xử lý cũ trước khi project chốt desktop-only.
```

- [ ] **Step 3: Update changelog line that frames phone dead-end avoidance as active requirement**

Replace:

```md
- Polish demo mentor-ready: thêm intro KÌ sau title, báo lỗi rõ khi free-text trống, button cao hơn, và bọc panel bằng ScrollContainer để tránh dead-end trên phone.
```

With:

```md
- Polish demo mentor-ready: thêm intro KÌ sau title, báo lỗi rõ khi free-text trống, button cao hơn, và bọc panel bằng ScrollContainer để tránh dead-end ở màn hình hẹp.
```

- [ ] **Step 4: Add new changelog entry for desktop-only scope decision**

Insert under `## 15. 📝 Changelog cấu trúc` as newest dated subsection above older entries:

```md
### 2026-05-11

- Chốt target hỗ trợ chính thức là desktop browser; không còn cam kết mobile browser.
- Cập nhật tài liệu dự án, tiêu chí demo, và checklist verification sang desktop-only soft cut.
- Giữ Web / HTML5 export và cho phép layout mobile cũ tồn tại nếu không ảnh hưởng trải nghiệm desktop.
```

- [ ] **Step 5: Verify structure doc no longer claims mobile as active target**

Run:

```bash
rtk grep -nE "Desktop browser \+ phone browser|mobile browser" "D:/KÌ/Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md"
```

Expected: no matches that describe current supported target.

---

### Task 3: Update mentor-facing overview doc

**Files:**
- Modify: `Takanote/KÌ_PROJECT_OVERVIEW_MENTOR.md`

- [ ] **Step 1: Change target platform summary**

Replace:

```md
**Nền tảng mục tiêu:** Desktop browser và mobile browser  
```

With:

```md
**Nền tảng mục tiêu:** Desktop browser  
```

- [ ] **Step 2: Remove phone usability from demo completion criteria**

Replace this completion block fragment:

```md
- UI đọc được trên desktop và phone,
```

With:

```md
- UI đọc được và dùng ổn định trên desktop,
```

- [ ] **Step 3: Verify mentor doc reflects desktop-only target**

Run:

```bash
rtk grep -nE "mobile browser|desktop và phone" "D:/KÌ/Takanote/KÌ_PROJECT_OVERVIEW_MENTOR.md"
```

Expected: no matches.

---

### Task 4: Clean old implementation/design docs that still promise mobile support

**Files:**
- Modify: `docs/superpowers/plans/2026-05-04-visual-screen-scenes.md`
- Modify: `docs/superpowers/plans/2026-05-04-md-questions-data.md`
- Modify: `docs/superpowers/specs/2026-05-04-md-questions-data-design.md`

- [ ] **Step 1: Remove mobile-responsive task from visual screen plan**

In `docs/superpowers/plans/2026-05-04-visual-screen-scenes.md`, replace this task heading:

```md
### Task 7: Fix responsive mobile sizing in scene scripts
```

With:

```md
### Task 7: Keep desktop-safe sizing in scene scripts
```

- [ ] **Step 2: Rewrite Task 7 file list in visual screen plan**

Replace:

```md
**Files:**
- Modify: `scripts/ui/screens/card_reveal_screen.gd`
- Modify: `scripts/ui/screens/onboarding_screen.gd`
- Modify: `scripts/ui/screens/inner_space_screen.gd`
- Modify: `scripts/ui/screens/minigame_screen.gd`
```

With:

```md
**Files:**
- Modify: `scripts/ui/screens/card_reveal_screen.gd`
- Modify: `scripts/ui/screens/onboarding_screen.gd`
- Modify: `scripts/ui/screens/inner_space_screen.gd`
```

- [ ] **Step 3: Rewrite Task 7 steps to desktop-safe wording**

Replace Task 7 body from Step 1 through Step 4 with:

```md
- [ ] **Step 1: Add `_content_width(max_width)` helper to screens with dynamic buttons/text input**

```gdscript
func _content_width(max_width: float) -> float:
	return min(max_width, get_viewport_rect().size.x - 80)
```

Use in `_create_button(...)`:

```gdscript
button.custom_minimum_size = Vector2(_content_width(300), 60)
```

Use in `inner_space_screen.gd` setup for free text:

```gdscript
free_text_input.custom_minimum_size = Vector2(_content_width(640), 120)
```

- [ ] **Step 2: Keep readable desktop card width in `card_reveal_screen.gd`**

```gdscript
var card_width := min(280.0, max(180.0, (get_viewport_rect().size.x - 120.0) / 3.0))
panel.custom_minimum_size = Vector2(card_width, 220)
```

- [ ] **Step 3: Keep desktop-safe card row spacing in `card_reveal_screen.gd`**

```gdscript
card_row.add_theme_constant_override("separation", 20)
```

- [ ] **Step 4: Run Godot syntax check**

Run: `rtk godot --headless --path "D:/KÌ" --quit`

Expected: project opens headless without parse errors.
```

- [ ] **Step 4: Remove phone viewport verification from questions-data plan**

In `docs/superpowers/plans/2026-05-04-md-questions-data.md`, replace:

```md
Open browser at local server, test: title → intro → onboarding → reveal → first inner space question. Phone viewport 390x844: confirm choices readable and no softlock.
```

With:

```md
Open browser at local server, test: title → intro → onboarding → reveal → first inner space question. Confirm desktop layout remains readable and no softlock occurs.
```

- [ ] **Step 5: Remove phone acceptance criterion from old design spec**

In `docs/superpowers/specs/2026-05-04-md-questions-data-design.md`, replace:

```md
- Phone viewport around 390x844 keeps question text and buttons usable.
```

With:

```md
- Desktop browser keeps question text and buttons readable through onboarding and inner-space flow.
```

- [ ] **Step 6: Verify stale mobile promises removed from touched old docs**

Run:

```bash
rtk grep -nE "390x844|responsive mobile|mobile sizing|Phone viewport|is_phone" "D:/KÌ/docs/superpowers/plans/2026-05-04-visual-screen-scenes.md" "D:/KÌ/docs/superpowers/plans/2026-05-04-md-questions-data.md" "D:/KÌ/docs/superpowers/specs/2026-05-04-md-questions-data-design.md"
```

Expected: no matches in edited requirement/test sections.

---

### Task 5: Run final consistency check across project docs

**Files:**
- Modify: none

- [ ] **Step 1: Search current docs for stale official mobile-support claims**

Run:

```bash
rtk grep -nE "Desktop browser và phone browser|Desktop browser \+ phone browser|mobile browser|viewport phone|390x844|touch-friendly|phone browser" "D:/KÌ/CLAUDE.md" "D:/KÌ/Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md" "D:/KÌ/Takanote/KÌ_PROJECT_OVERVIEW_MENTOR.md" "D:/KÌ/docs/superpowers/plans/2026-05-04-visual-screen-scenes.md" "D:/KÌ/docs/superpowers/plans/2026-05-04-md-questions-data.md" "D:/KÌ/docs/superpowers/specs/2026-05-04-md-questions-data-design.md"
```

Expected: no matches that describe current product requirements. Historical mentions inside changelog lines are acceptable only if explicitly marked as old pre-desktop-only behavior.

- [ ] **Step 2: Review git diff for touched docs only**

Run:

```bash
rtk git diff -- CLAUDE.md "Takanote/🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md" "Takanote/KÌ_PROJECT_OVERVIEW_MENTOR.md" docs/superpowers/plans/2026-05-04-visual-screen-scenes.md docs/superpowers/plans/2026-05-04-md-questions-data.md docs/superpowers/specs/2026-05-04-md-questions-data-design.md
```

Expected: diff shows wording/criteria cleanup only; no accidental gameplay or code changes.

- [ ] **Step 3: Check working tree status**

Run:

```bash
rtk git status --short
```

Expected: touched docs show modified; unrelated dirty files remain untouched.

---

## Self-review notes

Spec coverage:
- Supported target changed to desktop-only: Tasks 1, 2, 3.
- Core demo path no longer promises phone usability: Task 1.
- Verification checklist no longer includes phone viewport testing: Tasks 1, 3, 4, 5.
- Future UI work may ignore phone-specific constraints: Tasks 1 and 4.
- Desktop flow remains only required runtime target: Tasks 1 through 5.

No placeholders remain. Paths and replacements are explicit. Plan stays inside doc/rule cleanup boundary and does not introduce gameplay or architecture work.
