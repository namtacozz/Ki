# 🗺️ CẤU TRÚC DỰ ÁN KÌ

**Dự án:** KÌ: Ba Lá Của Bản Ngã  
**Engine:** Godot 4.x  
**Target:** Desktop browser + phone browser  
**Repo:** https://github.com/namtacozz/Ki  
**Cập nhật:** 2026-05-04

---

## 1. 🎯 Tổng quan kiến trúc

KÌ là web game Godot độc lập, tập trung vào trải nghiệm tarot narrative và tự soi chiếu bản thân. Kiến trúc được chia thành các lớp chính:

1. **UI Flow Layer** — điều phối màn hình, câu hỏi, card reveal, mini game, final report.
2. **Game State Layer** — lưu trạng thái một lượt chơi.
3. **Data Layer** — tarot cards, questions, prompts, config.
4. **Tarot & Question Logic Layer** — chọn bài, ghi câu trả lời, tính score ẩn.
5. **AI Layer** — gọi local proxy, nhận JSON interpretation/report.
6. **Mini Game Layer** — xử lý các mini game bài nhẹ.
7. **Docs & Planning Layer** — tài liệu thiết kế, overview, roadmap/cấu trúc.

---

## 2. 🌳 Sơ đồ thư mục

```text
D:/KÌ/
├── CLAUDE.md
├── README.md
├── project.godot
├── export_presets.cfg
├── icon.svg
├── icon.svg.import
├── KÌ_PROJECT_OVERVIEW_MENTOR.md
│
├── Takanote/
│   └── 🗺️_CẤU_TRÚC_DỰ_ÁN_KÌ.md
│
├── docs/
│   └── design/
│       └── 2026-05-04-ki-tarot-game-design.md
│
├── data/
│   ├── tarot_major_arcana.json
│   ├── questions.json
│   ├── prompts.json
│   └── local_config.example.json
│
├── scenes/
│   ├── main.tscn
│   ├── title/
│   ├── tarot_room/
│   ├── questions/
│   ├── cards/
│   ├── inner_space/
│   ├── minigames/
│   └── report/
│
├── scripts/
│   ├── core/
│   │   ├── game_state.gd
│   │   └── json_loader.gd
│   ├── tarot/
│   │   └── tarot_manager.gd
│   ├── questions/
│   │   └── question_manager.gd
│   ├── ai/
│   │   └── ai_client.gd
│   ├── report/
│   │   └── report_builder.gd
│   ├── minigames/
│   │   ├── card_model.gd
│   │   └── minigame_manager.gd
│   └── ui/
│       └── main_controller.gd
│
├── tools/
│   └── ai_proxy/
│       ├── package.json
│       ├── package-lock.json
│       ├── server.mjs
│       └── .env.example
│
├── assets/
│   ├── art/
│   ├── audio/
│   └── fonts/
│
└── exports/
    └── web/
```

> Ghi chú: Một số file/thư mục có thể chưa tồn tại nếu task tương ứng chưa hoàn thành. File này phải được cập nhật sau mỗi task làm thay đổi cấu trúc.

---

## 3. ⚙️ Autoload Singletons

Godot autoloads được khai báo trong `project.godot`.

### `GameState`

**Path:** `scripts/core/game_state.gd`

Vai trò:

- Lưu trạng thái một lượt chơi.
- Lưu onboarding answers.
- Lưu spread 3 lá Past / Present / Future.
- Lưu câu trả lời từng không gian.
- Lưu score ẩn.
- Lưu AI reflections.
- Lưu mini game results.
- Cộng Self Fragments từ mini game rewards.
- Lưu final report.

Dữ liệu chính:

- `onboarding_answers`
- `spread`
- `current_space_index`
- `space_answers`
- `inner_space_results`
- `profile_scores`
- `ai_reflections`
- `minigame_results`
- `self_fragments`
- `final_report`

### `TarotManager`

**Path:** `scripts/tarot/tarot_manager.gd`

Vai trò:

- Load `data/tarot_major_arcana.json`.
- Tính điểm theme từ onboarding answers.
- Chọn 3 lá không trùng cho Past / Present / Future.
- Ghi spread vào `GameState`.

### `QuestionManager`

**Path:** `scripts/questions/question_manager.gd`

Vai trò:

- Load `data/questions.json`.
- Trả về onboarding questions.
- Trả về questions theo từng space.
- Ghi multiple-choice answers.
- Ghi free-text answers.
- Cập nhật hidden profile score qua `GameState`.

### `AIClient`

**Path:** `scripts/ai/ai_client.gd`

Vai trò:

- Load prompt templates từ `data/prompts.json`.
- Đọc local config nếu có.
- Gửi request tới local AI proxy.
- Parse JSON response.
- Emit signal khi có reflection/report.
- Emit lỗi nếu proxy/AI fail.

Signals dự kiến:

- `reflection_ready(space_id, data)`
- `report_ready(data)`
- `ai_failed(message)`

### `MiniGameManager`

**Path:** `scripts/minigames/minigame_manager.gd`

Vai trò:

- Chạy mini game theo mode:
  - `blackjack` cho Past.
  - `poker` cho Present.
  - `symbol_match` cho Future.
- Tính kết quả thắng/thua không dùng AI.
- Tính Self Fragments.
- Ghi kết quả vào `GameState`.

### `ReportBuilder`

**Path:** `scripts/report/report_builder.gd`

Vai trò:

- Gom dữ liệu cuối từ `GameState` vào AI context.
- Chuẩn hóa schema AI final report trước khi hiển thị.
- Tạo local fallback đủ field khi AI/proxy fail.

---

## 4. 🎬 Scene Flow

### `scenes/main.tscn`

Scene chính của game. Được set làm `run/main_scene` trong `project.godot`.

Node chính:

```text
Main (Control)
├── Background (ColorRect)
└── ScreenRoot (Control)
```

Script:

- `scripts/ui/main_controller.gd`

Vai trò:

- Điều phối toàn bộ playable flow.
- Clear/replace screen trong `ScreenRoot`.
- Chuyển giữa title, onboarding, spread, inner spaces, mini games, final report.

### `scenes/title/`

Mục đích:

- Dành cho title screen tách riêng nếu cần polish.
- Hiện tại có thể được dựng runtime trong `main_controller.gd`.

### `scenes/tarot_room/`

Mục đích:

- Phòng bói của KÌ.
- Hub narrative đầu/cuối game.
- Có thể chứa portrait KÌ, bàn bài, nến, card deck.

### `scenes/questions/`

Mục đích:

- Chứa scene/question panel reusable nếu tách khỏi main controller.
- Dùng cho onboarding và inner space questions.

### `scenes/cards/`

Mục đích:

- Card reveal animation/screen.
- Hiển thị 3 lá Past / Present / Future.

### `scenes/inner_space/`

Mục đích:

- Hiển thị không gian nội tâm theo từng card.
- Có thể dùng một scene reusable với data khác nhau.

### `scenes/minigames/`

Mục đích:

- Hiển thị mini game bài.
- Dùng chung UI card hand, opponent, Self Fragment reward.

### `scenes/report/`

Mục đích:

- Hiển thị final report.
- Sau Future space + mini game + AI reflection, `MainController` gọi `ReportBuilder.build_context()` rồi `AIClient.request_final_report()`.
- UI hiển thị trạng thái loading trong lúc chờ final report.
- Final report hiển thị các field: `title`, `core_self`, `past_pattern`, `present_tension`, `future_invitation`, `advice`, `keywords`.
- Nếu AI/proxy fail, UI hiển thị local summary cùng schema và nút retry.
- Replay reset run về title.
- Có thể có nút copy report / share screenshot nếu scope cho phép.

---

## 5. 📦 Data Files

### `data/tarot_major_arcana.json`

Chứa 22 lá Major Arcana.

Mỗi card nên có:

```json
{
  "id": "fool",
  "name": "The Fool",
  "vi": "Kẻ Khờ",
  "themes": ["beginning", "risk", "freedom"],
  "past": "...",
  "present": "...",
  "future": "...",
  "symbols": ["star", "road", "bag"]
}
```

Dùng cho:

- card selection,
- card reveal,
- inner space intro,
- AI context,
- mini game symbols.

### `data/questions.json`

Chứa:

- `onboarding` questions,
- `past` questions,
- `present` questions,
- `future` questions.

Mỗi inner space set hiện có 2 multiple-choice questions và 1 free-text question.

Dùng cho:

- chọn bài ban đầu,
- inner space runtime flow,
- score ẩn,
- final report.

### `data/prompts.json`

Chứa prompt templates:

- reflection prompt,
- final report prompt,
- JSON repair prompt nếu cần.
- Schema JSON final report gồm: `title`, `core_self`, `past_pattern`, `present_tension`, `future_invitation`, `advice`, `keywords`.

Dùng bởi:

- `AIClient`.

### `data/local_config.example.json`

Template config không chứa secret.

Ví dụ:

```json
{
  "ai_proxy_url": "http://localhost:8787/generate"
}
```

### `data/local_config.json`

File local không commit.

Dùng để override proxy URL khi demo.

---

## 6. 🤖 AI Proxy

### `tools/ai_proxy/server.mjs`

Local server giữ API key và gọi model AI.

Game gửi request đến:

```text
http://localhost:8787/generate
```

Proxy nhận request:

```json
{
  "type": "reflection",
  "prompt": "...",
  "context": {}
}
```

Proxy trả wrapper JSON:

```json
{
  "ok": true,
  "text": "{...AI JSON...}"
}
```

Hoặc lỗi:

```json
{
  "ok": false,
  "error": "..."
}
```

### `tools/ai_proxy/.env.example`

Template:

```env
PORT=8787
ANTHROPIC_BASE_URL=http://localhost:20128/v1
ANTHROPIC_API_KEY=your_local_gateway_token
ANTHROPIC_MODEL=High
ANTHROPIC_TIMEOUT_MS=30000
```

### `tools/ai_proxy/.env`

File local chứa key thật. Không commit.

---

## 7. 🃏 Mini Game Layer

### `scripts/minigames/card_model.gd`

Vai trò:

- Định nghĩa suit/value cơ bản.
- Gắn symbol theo suit để dùng cho symbol match.
- Tạo deck.
- Shuffle deck.
- Draw cards.
- Format card labels cho UI.

### `scripts/minigames/minigame_manager.gd`

Mode hiện có:

1. `blackjack` cho Past: rút/dừng để gần 21 hơn KÌ.
2. `poker` cho Present: đoán chất bài xuất hiện nhiều nhất trong tay 5 lá.
3. `symbol_match` cho Future: chọn biểu tượng cộng hưởng với lá tương lai.

Kết quả mỗi mini game:

```gdscript
{
  "mode": "blackjack",
  "won": true,
  "fragments": 3,
  "detail": "..."
}
```

---

## 8. 🧠 Hidden Profile Dimensions

Các dimension dự kiến:

- `attachment_to_past`
- `self_trust`
- `fear_of_change`
- `action_vs_reflection`
- `control_vs_acceptance`
- `connection_vs_solitude`

Dùng cho:

- final report,
- AI context,
- personality-style summary.

---

## 9. 🎮 Core Demo Path

Core demo path không được phá khi thêm tính năng:

```text
Title
→ KÌ intro
→ Onboarding questions
→ Select 3 tarot cards
→ Reveal Past / Present / Future
→ Past space questions + free text + AI + mini game
→ Present space questions + free text + AI + mini game
→ Future space questions + free text + AI + mini game
→ Final AI report
→ Replay/end
```

Nếu task mới làm hỏng flow này, phải fix trước khi nhận task hoàn thành.

---

## 10. 🔐 Files không được commit

Không commit:

```text
data/local_config.json
tools/ai_proxy/.env
exports/
.godot/
*.log
*.tmp
```

Trước mỗi commit, chạy:

```bash
rtk git status --short
```

Chỉ stage file thuộc task.

---

## 11. ✅ Verification Commands

Parse/headless check:

```bash
rtk godot --headless --path "D:/KÌ" --quit
```

AI proxy:

```bash
rtk npm --prefix "D:/KÌ/tools/ai_proxy" install
rtk npm --prefix "D:/KÌ/tools/ai_proxy" start
```

Web export:

```bash
rtk godot --headless --path "D:/KÌ" --export-release Web "D:/KÌ/exports/web/index.html"
```

Local web serve:

```bash
rtk python -m http.server 8090 --directory "D:/KÌ/exports/web"
```

---

## 12. 📌 Quy tắc cập nhật file này

Mỗi khi hoàn thành task có thay đổi cấu trúc, phải cập nhật file này.

Cập nhật khi:

- Thêm scene mới.
- Thêm script mới.
- Thêm autoload mới.
- Thêm data file mới.
- Đổi đường dẫn file.
- Xóa file/system.
- Đổi flow chính.
- Đổi AI proxy/API structure.
- Đổi mini game structure.
- Đổi export/deployment structure.

Nội dung cần cập nhật:

- Sơ đồ thư mục.
- Mô tả module.
- Core demo path nếu thay đổi.
- Verification commands nếu thay đổi.
- Files không được commit nếu có secret/temp mới.

---

## 13. 🚧 TODO cấu trúc gần nhất

- [ ] Tách UI screens thành scene riêng thay vì dựng runtime trong `main_controller.gd` nếu cần polish.
- [x] Bổ sung `tools/ai_proxy/` đầy đủ nếu chưa có.
- [x] Bổ sung `export_presets.cfg` khi setup Web export.
- [ ] Bổ sung report scene riêng nếu tách khỏi main controller.
- [ ] Bổ sung assets thật cho KÌ, tarot cards, background.

---

## 14. 📝 Changelog cấu trúc

### 2026-05-04

- Khởi tạo tài liệu cấu trúc dự án KÌ.
- Ghi nhận kiến trúc Godot web game độc lập.
- Ghi nhận autoload managers dự kiến.
- Ghi nhận data-driven tarot/question/prompt structure.
- Ghi nhận AI proxy structure.
- Thêm `tools/ai_proxy/package.json`, `server.mjs`, `.env.example`, và `package-lock.json` cho local Anthropic-compatible proxy.
- Cập nhật runtime flow: sau card reveal, người chơi đi lần lượt qua Past / Present / Future inner spaces.
- Cập nhật `data/questions.json`: tách question sets `past`, `present`, `future`, mỗi set có 2 choice questions và 1 free-text question.
- Cập nhật `GameState`: lưu `current_space_index`, `space_answers`, `inner_space_results` cho inner space flow.
- Thêm `scripts/minigames/card_model.gd`: deck 4 suit, value 1-13, symbol theo suit, draw/shuffle/label helpers.
- Cập nhật `MiniGameManager`: Past blackjack-lite, Present poker-lite, Future symbol_match-lite, không dùng AI trong logic.
- Cập nhật `main_controller.gd`: sau questions/free-text của mỗi space hiện mini game, nhận action, lưu result, cộng Self Fragments.
- Hoàn thiện final report flow: `ReportBuilder` gom context/normalize/fallback, `MainController` hiển thị final report + retry + replay, `data/prompts.json` khai báo schema JSON report.
- Thêm `export_presets.cfg` cho Web export; tắt mobile VRAM compression để Godot 4.6 export release hợp lệ khi ETC2/ASTC chưa bật.
- Cập nhật `main_controller.gd`: panel, margin, text input, và card row co theo viewport phone 390x844.
