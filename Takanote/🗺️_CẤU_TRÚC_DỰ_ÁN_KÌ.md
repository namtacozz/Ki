# 🗺️ CẤU TRÚC DỰ ÁN KÌ

**Dự án:** KÌ: Ba Lá Của Bản Ngã  
**Engine:** Godot 4.x  
**Target:** Desktop browser  
**Repo:** https://github.com/namtacozz/Ki  
**Cập nhật:** 2026-05-11

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
│   ├── questions.json
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
│       ├── hud_menu_button.tscn
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
│   └── ai_proxy/
│       ├── package.json
│       ├── package-lock.json
│       ├── server.mjs
│       └── .env.example
│
├── assets/
│   ├── backgrounds/
│   │   ├── bg_ai_state_booth.png
│   │   ├── bg_final_booth_ki_smile.png
│   │   ├── bg_minigame_table_clean.png
│   │   ├── bg_space_future.png
│   │   ├── bg_space_past.png
│   │   ├── bg_space_present.png
│   │   └── bg_title_fortune_booth_ki.png
│   ├── characters/
│   │   └── KI.png
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

**Path:**
- `scripts/core/game_state.gd` (Autoload) - Lưu trữ state toàn cục của game.
- `scripts/core/settings_manager.gd` (Autoload) - Quản lý cài đặt (âm lượng, trợ năng, text speed).
- `scripts/core/json_loader.gd` (Autoload) - Hỗ trợ load JSON an toàn.

Vai trò:

- Lưu trạng thái một lượt chơi.
- Lưu onboarding answers.
- Lưu spread 3 lá Past / Present / Future.
- Lưu câu trả lời từng không gian.
- Lưu score ẩn.
- Lưu AI reflections.
- Lưu mini game results.
- Cộng Mảnh Hồn từ mini game rewards.
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
- `soul_fragments`
- `final_report`

### `AudioManager`

**Path:** `scripts/core/audio_manager.gd` (Autoload)

Vai trò:

- Quản lý và phát âm thanh SFX (hover, click, typewriter, v.v) thông qua hệ thống pool để tránh ngắt quãng.
- Quản lý và phát nhạc nền BGM (TarotVeil và 22 track riêng cho Major Arcana) với cơ chế crossfade mượt mà dùng Tween.
- Tải nhạc theo yêu cầu (on-demand) thay vì preload toàn bộ để tiết kiệm bộ nhớ RAM cho nền tảng Web.

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

- Load `data/questions.json` fixed runtime question data.
- Trả về onboarding questions.
- Trả về questions theo từng space.
- Ghi multiple-choice answers.
- Ghi free-text answers.
- Cập nhật hidden profile score qua `GameState`.

### `AIClient`

**Path:** `scripts/ai/ai_client.gd`

Vai trò:

- Gọi proxy local tại endpoint cấu hình trong `data/local_config.json`.
- Gửi payload cho AI interpretation hoặc final report.
- Validate JSON response schema mức cơ bản.
- Trả lỗi rõ nếu timeout / malformed JSON / missing field.

### `ReportBuilder`

**Path:** `scripts/report/report_builder.gd`

Vai trò:

- Gom onboarding summary.
- Gom 3 lá và inner space answers.
- Chuẩn hóa payload cho final report prompt.
- Merge AI output vào format final report dùng cho UI với schema rút gọn: `title`, `overall_reflection`, `guidance`, `keywords`.
- Tổng hợp chung cả 3 không gian và Mảnh Hồn vào một mục soi chiếu ngắn gọn.

### `MinigameManager`

**Path:** `scripts/minigames/minigame_manager.gd`

Vai trò:

- Tạo/trả state mini game cho từng card space.
- Tính thắng/thua hoặc reward condition.
- Trả reward data về `GameState`.

### `SettingsManager`

**Path:** `scripts/core/settings_manager.gd` (Autoload)

Vai trò:

- Lưu và tải cài đặt game từ `user://settings.cfg`.
- Quản lý âm lượng tổng (`master_volume_db`, `music_volume_db`, `sfx_volume_db`).
- Quản lý tùy chọn trợ năng (`high_contrast_mode`, `reduce_motion`).
- Quản lý tốc độ hiển thị chữ (`text_speed_multiplier`).
- Phát tín hiệu `settings_changed` để UI cập nhật ngay lập tức.

Dữ liệu chính:

- `master_volume_db`
- `music_volume_db`
- `sfx_volume_db`
- `high_contrast_mode`
- `reduce_motion`
- `text_speed_multiplier`

### `JSONLoader`

**Path:** `scripts/core/json_loader.gd` (Autoload)

Vai trò:

- Đọc file JSON từ `res://` hoặc `user://`.
- Trả về Dictionary/Array an toàn.
- Báo lỗi parse rõ ràng để `AIClient`, `TarotManager`, `QuestionManager` dùng chung.

---

## 4. 🖼️ Scenes & UI Flow

### `scenes/main.tscn`

Vai trò:

- Root scene của game.
- Mount `MainController`.
- Chứa layer/container để swap các màn hình con.

### `scenes/title/title_screen.tscn`

Mục đích:

- Màn hình mở đầu.
- Giới thiệu KÌ và hành trình 3 lá.
- Có nút bắt đầu onboarding.
- Có thể có nút settings, quit, credits nếu còn scope.
- Thanh settings góc trên phải chứa icon slider cho cài đặt, icon trợ năng để bật/tắt high contrast và reduce motion, cùng icon âm nhạc để bật/tắt soundtrack riêng biệt.

### `scenes/cards/card_reveal_screen.tscn`

Mục đích:

- Hiển thị 3 lá Past / Present / Future.
- Animate reveal từng lá.
- Cho người chơi chọn đi vào không gian đầu tiên.
- Có thể hiện intro text ngắn cho mỗi lá.

### `scenes/minigames/minigame_screen.tscn`

Mục đích:

- Host mini game cho từng inner space.
- Nhận config từ card hiện tại.
- Phát kết quả reward / fragment.
- Có HUD menu button overlay để mở menu tạm dừng hoặc quay về title.

### `scenes/report/final_report_screen.tscn`

Mục đích:

- Hiển thị tổng kết cuối.
- Gồm 1 mục soi chiếu tổng hợp chung cho Quá khứ / Hiện tại / Tương lai và Mảnh Hồn, cùng 1 mục lời khuyên cuối.
- Có thêm `keywords` ngắn để người chơi nhớ trục chính.
- Nếu AI/proxy fail, `MainController` swap `ai_error_screen.tscn` hoặc truyền fallback summary vào final report scene.
- Screen script nhận report data qua `setup(...)` và emit replay/retry/copy signals về `MainController`.
- Replay reset run về title.
- Có thể có nút copy report / share screenshot nếu scope cho phép.

### `scenes/ui/`

Scene:

- `loading_screen.tscn`: màn hình chờ AI/proxy hoặc bước xử lý dài.
- `narrative_screen.tscn`: màn hình dẫn chuyện/dialogue cho onboarding intro và card story.
- `ai_error_screen.tscn`: màn hình lỗi AI/proxy có retry rõ ràng.
- `hud_menu_button.tscn`: component nút menu HUD kèm menu overlay sau khi bấm `MenuButton`, để chỉnh vị trí và layout trực quan trong editor.

Mục đích:

- Tách trạng thái loading/error/narrative thành visual screen scene riêng.
- Tách nút menu HUD thành component scene để chỉnh anchor/offset trực tiếp trong editor thay vì hardcode bằng script.
- Screen script nhận message/context qua `setup(...)` và emit signal về `MainController`.
- `narrative_screen` hiển thị speaker name, body text, continue button để dẫn vào onboarding questions hoặc inner space questions.

---

## 5. 📦 Data Files

### `data/tarot_major_arcana.json`

Chứa 22 lá Major Arcana.

Mỗi object nên có:

- `id`
- `name`
- `arcana_number`
- `keywords`
- `themes`
- `intro_text`
- `space_prompt`
- `portrait_asset`
- `card_asset`
- `bg_asset`
- `minigame_id`

### `data/questions.json`

Chứa:

1. `onboarding_intro` cho mở đầu câu hỏi nhập môn.
2. `onboarding` questions.
3. `cards.<slug>.<past|present|future>` cho từng inner space theo lá và vị trí.
4. `story_title` + `story_beats` + `questions` cho từng card-position section.

Runtime schema hiện hành:

```json
{
  "onboarding_intro": "...",
  "onboarding": [],
  "cards": {
    "the_fool": {
      "past": {
        "story_title": "Rời Khỏi Vùng An Toàn",
        "story_beats": ["...", "...", "...", "...", "..."],
        "questions": []
      },
      "present": {
        "story_title": "Sống Dưới Đáy Vực",
        "story_beats": ["...", "...", "...", "...", "..."],
        "questions": []
      },
      "future": {
        "story_title": "Vùng Đất Không Tên",
        "story_beats": ["...", "...", "...", "...", "..."],
        "questions": []
      }
    }
  }
}
```

- Mỗi inner space chạy theo nhịp: story beat 1 → question 1 → ... → story beat 5 → question 5.
- `Takanote/BienNienSu.md` là nguồn prose tham chiếu để đồng bộ `story_beats` trong `data/questions.json`.
- Hiện tại prose được đồng bộ thủ công từ `BienNienSu.md` sang `data/questions.json`; chưa có converter tự động trong runtime path hiện hành.

### `data/prompts.json`

Chứa prompt template cho:

- AI interpretation từng inner space.
- AI final report.
- Có thể tách voice/style của KÌ.

### `data/local_config.example.json`

Chứa ví dụ config local:

```json
{
  "ai_proxy_url": "http://127.0.0.1:3000",
  "timeout_ms": 20000
}
```

`data/local_config.json` là file thật dùng local, phải nằm trong `.gitignore`.

### `data/audio_config.json`

Chứa cấu hình cho toàn bộ hệ thống audio của game, bao gồm đường dẫn file BGM và SFX.

Schema chính:

```json
{
  "bgm_tracks": {
    "tarot_veil": {
      "path": "res://assets/audio/bgm/TarotVeil.mp3",
      "volume_db": -5.0
    },
    "major_arcana": {
      "the_fool": {
        "path": "res://assets/audio/bgm/22 Major Arcana/TheFool.mp3"
      }
    }
  },
  "sfx_pools": {
    "button_hover": {
      "path": "res://assets/audio/sfx/ui/button-hover.wav",
      "pool_size": 4
    }
  }
}
```

---

## 6. 🔁 Core Demo Flow

Luồng chơi bắt buộc giữ chạy:

1. `title_screen.tscn`
2. `narrative_screen.tscn` intro của KÌ
3. onboarding questions
4. chọn 3 lá bằng `TarotManager`
5. `card_reveal_screen.tscn`
6. với mỗi lá:
   - intro narrative
   - câu hỏi lựa chọn
   - câu hỏi tự do
   - AI interpretation
   - mini game
   - reward fragment
7. `final_report_screen.tscn`

`MainController` chịu trách nhiệm điều phối flow này.

---

## 7. 🧠 Trách nhiệm từng module

### `scripts/ui/main_controller.gd`

Điều phối flow chính:

- start game
- show intro narrative
- show onboarding
- call tarot selection
- show card reveal
- enter inner spaces theo thứ tự
- show AI loading state
- show error state nếu proxy fail
- show final report
- reset run

### `scripts/core/game_state.gd`

Quản lý dữ liệu runtime xuyên suốt session.

### `scripts/tarot/tarot_manager.gd`

Từ onboarding answers → tính theme score → chọn spread.

### `scripts/questions/question_manager.gd`

Cung cấp câu hỏi và ghi nhận câu trả lời.

### `scripts/ai/ai_client.gd`

Giao tiếp local proxy, parse JSON response, phát signal thành công/thất bại.

### `scripts/report/report_builder.gd`

Tạo payload tổng hợp cho final report.

### `scripts/minigames/minigame_manager.gd`

Xử lý logic mini game độc lập với UI scene.

### `scripts/core/audio_manager.gd`

Điều phối toàn bộ hệ thống audio của game.

- Phát nhạc nền title (`TarotVeil`) khi vào title screen.
- Crossfade mượt mà sang nhạc riêng của từng lá bài khi vào inner space.
- Phát SFX cho mọi tương tác UI chính (hover, click) và hiệu ứng typewriter của chữ.

---

## 8. 🔌 AI Proxy Structure

### `tools/ai_proxy/`

Thành phần:

- `server.mjs`: local server nhận request từ Godot.
- `.env.example`: danh sách biến môi trường cần tạo trong `.env`.
- `package.json`: dependencies + scripts.

Kỳ vọng API:

#### `POST /interpret-space`

Input:

```json
{
  "card": "The Fool",
  "position": "past",
  "answers": {
    "mc": ["a", "c"],
    "free_text": "..."
  }
}
```

Output:

```json
{
  "title": "...",
  "summary": "...",
  "insight": "...",
  "suggestion": "..."
}
```

#### `POST /final-report`

Input:

```json
{
  "spread": [],
  "answers": {},
  "fragments": 3
}
```

Output:

```json
{
  "headline": "...",
  "overview": "...",
  "past": "...",
  "present": "...",
  "future": "...",
  "closing": "..."
}
```

Lưu ý:

- Không hardcode API key trong Godot.
- `.env` không được commit.
- Response phải JSON ổn định, không trả prose tự do.
- `AIClient` phải handle timeout, non-200, malformed JSON.

---

## 9. 🚫 File không được commit

- `tools/ai_proxy/.env`
- `data/local_config.json`
- mọi API key/token thật
- export build nặng nếu không cần
- file temp/editor cache không thuộc source chính

---

## 10. ✅ Verification Commands

Dùng từ root `D:/KÌ`.

```bash
rtk git status --short
rtk godot --path "D:/KÌ" --headless --quit
rtk npm --prefix "D:/KÌ/tools/ai_proxy" run dev
rtk python -m http.server 8090 --directory "D:/KÌ/exports/web"
```

Checklist:

- Title mở được.
- Intro narrative chạy.
- Onboarding questions trả lời được.
- 3 lá reveal đúng.
- Mỗi inner space không softlock.
- AI loading/error screen hiện đúng.
- Final report render được.
- Browser desktop không vỡ layout.

---

## 11. 📝 Changelog cấu trúc

### 2026-05-04

- Tạo file cấu trúc dự án ban đầu.
- Khai báo các thư mục scenes/, scripts/, data/, tools/ai_proxy/.
- Mô tả core demo path đầu tiên.

### 2026-05-10

- Đồng bộ cấu trúc với repo `Ki`.
- Bổ sung `loading_screen.tscn`, `narrative_screen.tscn`, `ai_error_screen.tscn` vào `scenes/ui/`.
- Bổ sung `main_controller.gd`, screen scripts, ai/report/question/tarot manager.
- Thêm mục AI proxy structure và verification commands.

### 2026-05-11

- Thêm `hud_menu_button.tscn` vào `scenes/ui/` để đặt nút menu trực tiếp trong editor, và gộp menu overlay sau `MenuButton` vào cùng component HUD.
- Cập nhật mô tả `scenes/ui/` và `scenes/minigames/minigame_screen.tscn` theo HUD menu button component.
- Đồng bộ thêm `choice_button.tscn`, `tarot_card_display.tscn`, `report_field.tscn`, `minigame_card_visual.tscn`, `game_button.tscn`.
- Bổ sung `SettingsManager`, `settings_panel.tscn`, `settings_row.tscn`, `settings_tab_button.tscn`, `high_contrast_theme.tres`, `audio_config.json`, `audio_manager.gd`, và `assets/audio/` vào sơ đồ cấu trúc.
- Cập nhật mô tả title screen với thanh settings và quản lý cài đặt trong autoload/data/modules.
