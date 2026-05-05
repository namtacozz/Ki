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
├── .gitignore
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
│   ├── questions.md
│   ├── questions.json
│   ├── questions.generated.json
│   ├── prompts.json
│   └── local_config.example.json
│
├── scenes/
│   ├── main.tscn
│   ├── title/
│   │   └── title_screen.tscn
│   ├── tarot_room/
│   ├── cards/
│   │   └── card_reveal_screen.tscn
│   ├── minigames/
│   │   └── minigame_screen.tscn
│   ├── report/
│   │   └── final_report_screen.tscn
│   └── ui/
│       ├── loading_screen.tscn
│       ├── narrative_screen.tscn
│       ├── ai_error_screen.tscn
│       ├── choice_button.tscn
│       ├── tarot_card_display.tscn
│       ├── report_field.tscn
│       ├── minigame_card_visual.tscn
│       └── game_button.tscn
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
│       ├── main_controller.gd
│       └── screens/
│           ├── title_screen.gd
│           ├── narrative_screen.gd
│           ├── card_reveal_screen.gd
│           ├── minigame_screen.gd
│           ├── final_report_screen.gd
│           ├── loading_screen.gd
│           └── ai_error_screen.gd
│
├── tools/
│   ├── content/
│   │   └── convert_questions_md.py
│   └── ai_proxy/
│       ├── package.json
│       ├── package-lock.json
│       ├── server.mjs
│       └── .env.example
│
├── assets/
│   ├── backgrounds/
│   │   └── opening.jpg
│   ├── characters/
│   │   ├── ki_mystical.jpg
│   │   └── ki_thinking.jpg
│   ├── art/
│   │   ├── Tarot/
│   │   └── Playing-cards/
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
- Chuyển giữa title, KÌ intro, onboarding narrative, onboarding questions, spread, card story, inner spaces, mini games, final report.
- Swap các visual screen scene vào `ScreenRoot` thay vì dựng toàn bộ panel bằng code.
- Truyền data cho từng screen qua `setup(...)`.
- Nhận signal từ screen để chuyển bước flow tiếp theo.

### `scenes/title/`

Scene:

- `title_screen.tscn`: màn hình title, bắt đầu hành trình.
- `intro_screen.tscn`: màn hình KÌ giới thiệu hành trình tự hiểu bản thân.

Mục đích:

- Tách title và intro thành visual screen scene riêng.
- Mỗi screen script nhận data qua `setup(...)` nếu cần và emit signal về `MainController`.

### `scenes/tarot_room/`

Mục đích:

- Phòng bói của KÌ.
- Hub narrative đầu/cuối game.
- Có thể chứa portrait KÌ, bàn bài, nến, card deck.

### `scenes/questions/`

Scene:

- `onboarding_screen.tscn`: màn hình câu hỏi nhập môn.

Mục đích:

- Hiển thị onboarding questions bằng visual screen scene.
- Screen script nhận danh sách câu hỏi qua `setup(...)` và emit answers về `MainController`.

### `scenes/cards/`

Scene:

- `card_reveal_screen.tscn`: màn hình reveal 3 lá Past / Present / Future.

Mục đích:

- Card reveal animation/screen.
- Hiển thị 3 lá Past / Present / Future bằng tarot art nếu `art_path` tồn tại.
- Giữ text fallback: position, name, theme, keywords.
- Screen script nhận spread qua `setup(...)` và emit signal khi người chơi tiếp tục.

### `scenes/inner_space/`

Scene:

- `inner_space_screen.tscn`: màn hình không gian nội tâm theo từng card.

Mục đích:

- Hiển thị không gian nội tâm theo từng card.
- Dùng một scene reusable với data khác nhau cho Past / Present / Future.
- Screen script nhận card, questions, reflection state qua `setup(...)` và emit answers/action về `MainController`.

### `scenes/minigames/`

Scene:

- `minigame_screen.tscn`: màn hình mini game bài.

Mục đích:

- Hiển thị mini game bài.
- Dùng chung UI card hand bằng `TextureRect` nếu `image_path` tồn tại, text fallback, opponent, Self Fragment reward.
- Screen script nhận mode/result state qua `setup(...)` và emit action về `MainController`.

### `scenes/report/`

Scene:

- `final_report_screen.tscn`: màn hình bản soi chiếu cuối.

Mục đích:

- Hiển thị final report.
- Sau Future space + mini game + AI reflection, `MainController` gọi `ReportBuilder.build_context()` rồi `AIClient.request_final_report()`.
- `MainController` swap `loading_screen.tscn` trong lúc chờ final report.
- Final report hiển thị các field: `title`, `core_self`, `past_pattern`, `present_tension`, `future_invitation`, `advice`, `keywords`.
- Nếu AI/proxy fail, `MainController` swap `ai_error_screen.tscn` hoặc truyền fallback summary vào final report scene.
- Screen script nhận report data qua `setup(...)` và emit replay/retry/copy signals về `MainController`.
- Replay reset run về title.
- Có thể có nút copy report / share screenshot nếu scope cho phép.

### `scenes/ui/`

Scene:

- `loading_screen.tscn`: màn hình chờ AI/proxy hoặc bước xử lý dài.
- `narrative_screen.tscn`: màn hình dẫn chuyện/dialogue cho onboarding intro và card story.
- `ai_error_screen.tscn`: màn hình lỗi AI/proxy có retry rõ ràng.

Mục đích:

- Tách trạng thái loading/error/narrative thành visual screen scene riêng.
- Screen script nhận message/context qua `setup(...)` và emit signal về `MainController`.
- `narrative_screen` hiển thị speaker name, body text, continue button để dẫn vào onboarding questions hoặc inner space questions.

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

Hiện mỗi Major Arcana có `art_path` trỏ tới `res://assets/art/Tarot/Name.jpg` nếu asset tồn tại.

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

### `data/questions.md`

Markdown source file chứa câu hỏi theo định dạng structured.

Dùng bởi:

- `tools/content/convert_questions_md.py` để generate `data/questions.generated.json`.

### `data/questions.generated.json`

Generated JSON từ `data/questions.md` bằng converter script.

Dùng cho:

- runtime game nếu cần load từ generated version.

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

## 6. 🛠️ Content Pipeline

### `tools/content/convert_questions_md.py`

Script Python để convert `data/questions.md` thành `data/questions.generated.json`.

Vai trò:

- Parse markdown source file.
- Parse onboarding `Intro:` và card-position `Story:`.
- Validate structure và schema.
- Generate JSON output với onboarding intro, onboarding questions, và card questions theo past/present/future.
- Hardening validation để tránh malformed data.

---

## 7. 🤖 AI Proxy

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

## 8. 🃏 Mini Game Layer

### `scripts/minigames/card_model.gd`

Vai trò:

- Định nghĩa 52-card deck theo `clubs`, `diamonds`, `hearts`, `spades` và value A/2-10/J/Q/K.
- Gắn `image_path`/`art_path` tới `res://assets/art/Playing-cards/{suit}_{rank}.png`.
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

## 9. 🧠 Hidden Profile Dimensions

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

## 10. 🎮 Core Demo Path

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

## 11. 🔐 Files không được commit

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

## 12. ✅ Verification Commands

Parse/headless check:

```bash
rtk godot --headless --path "D:/KÌ" --quit
```

Questions converter:

```bash
rtk python tools/content/convert_questions_md.py
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

## 13. 📌 Quy tắc cập nhật file này

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

## 14. 🚧 TODO cấu trúc gần nhất

- [x] Tách UI screens thành scene riêng thay vì dựng runtime trong `main_controller.gd` nếu cần polish.
- [x] Bổ sung `tools/ai_proxy/` đầy đủ nếu chưa có.
- [x] Bổ sung `export_presets.cfg` khi setup Web export.
- [x] Bổ sung report scene riêng nếu tách khỏi main controller.
- [x] Bổ sung assets thật cho tarot cards và playing cards.
- [x] Bổ sung assets thật cho KÌ và background.

---

## 15. 📝 Changelog cấu trúc

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
- Polish demo mentor-ready: thêm intro KÌ sau title, báo lỗi rõ khi free-text trống, button cao hơn, và bọc panel bằng ScrollContainer để tránh dead-end trên phone.
- Tách UI flow thành scene trực quan theo màn hình trong scenes/title, scenes/questions, scenes/cards, scenes/inner_space, scenes/minigames, scenes/report, scenes/ui.
- MainController chuyển sang vai trò điều phối flow và swap scene vào ScreenRoot.
- Mỗi screen script nhận data qua setup(...) và emit signal về controller.
- Tích hợp assets bài: `assets/art/Tarot/` cho 22 Major Arcana bằng `art_path`; `assets/art/Playing-cards/` cho 52 lá bài tây bằng `image_path`/`art_path`.
- Cập nhật card reveal và mini game screen để hiển thị card art bằng `TextureRect` kèm text fallback, giữ core flow playable.
- Thêm pipeline câu hỏi `data/questions.md` → `data/questions.generated.json` bằng `tools/content/convert_questions_md.py`.
- Câu hỏi inner space chuyển sang theo từng lá tarot và vị trí Quá khứ / Hiện tại / Tương lai.
- Chọn 3 lá đầu dùng hybrid 64% affinity tags và 36% random noise.
- Cập nhật inner space hiển thị story của lá bài và AI reflection context nhận cả danh sách câu hỏi.
- Cập nhật màn hình lỗi: thiếu dữ liệu câu hỏi chỉ cho retry, không cho đi tiếp để tránh core flow chạy sai dữ liệu.

### 2026-05-04 (tiếp)

- Thay thế tarot card assets từ `assets/art/Tarot-cards/` (PNG với prefix số) sang `assets/art/Tarot/` (JPG).
- Cập nhật `data/tarot_major_arcana.json`: tất cả 22 lá Major Arcana trỏ `art_path` từ `res://assets/art/Tarot-cards/NN-Name.png` sang `res://assets/art/Tarot/Name.jpg`.

### 2026-05-04 (narrative & story support)

- Thêm `scenes/ui/narrative_screen.tscn` và `scripts/ui/screens/narrative_screen.gd` để hiển thị dẫn chuyện/dialogue.
- Cập nhật `tools/content/convert_questions_md.py`:
  - Parse `Intro:` từ onboarding block thành `onboarding_intro` trong JSON.
  - Hỗ trợ multiline intro (tiếp tục đến khi gặp question line).
  - Giữ nguyên `Story:` parsing cho card-position sections.
- Cập nhật `scripts/questions/question_manager.gd`: thêm `get_onboarding_intro() -> String`.
- Cập nhật `scripts/ui/main_controller.gd`:
  - Sau title continue, hiển thị onboarding intro narrative screen trước questions.
  - Sau load card story, hiển thị card story narrative screen trước questions.
  - Narrative screen emit `continued` signal để chuyển sang questions.
- Rebuild `data/questions.generated.json` với onboarding intro và card stories.
- Verify Godot headless load thành công.
- 
+### 2026-05-05 (Dialogue & Visual Overhaul)
+
+- Nâng cấp hệ thống dẫn chuyện: Chuyển đổi từ giao diện Panel tĩnh sang hệ thống đối thoại (Dialogue Chat) chuẩn Genshin/Stardew Valley.
+- Cập nhật `scripts/ui/screens/narrative_screen.gd`: hỗ trợ hiệu ứng chữ chạy (typewriter), hiển thị lựa chọn (choices), và avatar/background động.
+- Cập nhật `scenes/ui/narrative_screen.tscn`: Thiết kế lại bố cục với bối cảnh phủ kín, nhân vật ở góc màn hình và hộp thoại mờ ảo phía dưới.
+- Bổ sung tài nguyên nghệ thuật mới: `assets/backgrounds/opening.jpg` và `assets/characters/ki_avatar.jpg`.
+- Cập nhật `scripts/ui/main_controller.gd`: Hợp nhất luồng game, sử dụng NarrativeScreen cho toàn bộ đối thoại.

### 2026-05-05 (Clean Code Refactoring)

- **Refactor MainController.gd**: Tách biệt logic lấy asset (art/background), xử lý lỗi và quản lý trạng thái không gian nội tâm thành các hàm helper để giảm độ phức tạp (SRP).
- **Centralize Blackjack Logic**: Di chuyển logic tính điểm blackjack từ `MinigameManager` và `MinigameScreen` vào `CardModel.gd` dưới dạng static method để tránh lặp code.
- **Dọn dẹp QuestionManager**: Loại bỏ các hàm helper không còn sử dụng (dead code) và tối ưu hóa luồng load dữ liệu.
- **Chuẩn hóa JSON Loading**: Chuyển đổi toàn bộ logic đọc file JSON sang sử dụng autoload `JsonLoader`.
- **Bảo mật**: Thiết lập `.gitignore` chuẩn cho Godot và loại bỏ các file nhạy cảm (`.env`, `local_config.json`) khỏi version control.
- **Cải thiện CardRevealScreen**: Tách biệt logic xử lý layout mobile và loại bỏ comment dư thừa.
- **Đồng bộ hóa Assets**: Đảm bảo toàn bộ asset hình ảnh sử dụng định dạng `.jpg` để tối ưu dung lượng và sửa lỗi import.
+
