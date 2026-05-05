# KÌ: Ba Lá Của Bản Ngã — Project Overview for Mentor

## 1. Thông tin tổng quan

**Tên dự án:** KÌ: Ba Lá Của Bản Ngã  
**Thể loại:** Web game narrative / giải đố nhẹ / tự khám phá bản thân  
**Chủ đề:** Tarot, nội tâm, lựa chọn cá nhân, phản tư bằng AI  
**Engine:** Godot 4.x  
**Ngôn ngữ:** GDScript  
**Nền tảng mục tiêu:** Desktop browser và mobile browser  
**Thời gian thực hiện:** 2026-05-04 đến trước 2026-05-15  
**Mục tiêu demo:** Người chơi hoàn thành được một lượt chơi đầy đủ từ màn hình mở đầu đến bản tổng kết cuối.

## 2. Tóm tắt dự án

**KÌ: Ba Lá Của Bản Ngã** là một web game ngắn, nơi người chơi gặp thầy bói tên **KÌ** và bước vào một hành trình tự soi chiếu bản thân qua ba lá bài tarot.

Sau phần câu hỏi nhập môn, hệ thống chọn ra ba lá Major Arcana đại diện cho:

1. **Quá khứ** — điều người chơi đang mang theo.
2. **Hiện tại** — mâu thuẫn hoặc lựa chọn đang đối mặt.
3. **Tương lai** — khả năng hoặc lời mời đang mở ra.

Mỗi lá bài dẫn người chơi vào một không gian nội tâm riêng. Tại đó, người chơi đọc một đoạn narrative ngắn, trả lời câu hỏi lựa chọn, nhập một câu trả lời tự do, chơi một mini card game nhẹ, rồi nhận diễn giải từ AI. Cuối hành trình, KÌ tổng hợp dữ liệu thành một bản đọc cuối cùng theo phong cách tarot và self-reflection.

## 3. Lý do chọn đề tài

Dự án được thiết kế để phù hợp với phạm vi kiến tập ngắn nhưng vẫn có điểm nổi bật rõ ràng:

- **Có gameplay hoàn chỉnh:** người chơi có mục tiêu, lựa chọn, mini game và kết thúc.
- **Có tính cá nhân hóa:** câu trả lời của người chơi ảnh hưởng đến lá bài, chỉ số ẩn và nội dung diễn giải.
- **Có yếu tố sáng tạo:** kết hợp tarot, narrative design, puzzle nhẹ và AI.
- **Có giá trị trình bày kỹ thuật:** dữ liệu tách riêng bằng JSON, luồng game có cấu trúc, AI gọi qua proxy an toàn.
- **Có scope kiểm soát được:** chỉ dùng 22 lá Major Arcana, không làm hệ thống tarot đầy đủ 78 lá, không làm multiplayer, không làm chatbot phức tạp.

## 4. Đối tượng người chơi

Game hướng tới người chơi thích:

- Trải nghiệm narrative ngắn.
- Tarot, biểu tượng và không khí huyền bí nhẹ.
- Game tự khám phá bản thân.
- Câu hỏi phản tư, lựa chọn mang màu sắc cá nhân.
- Puzzle / mini game đơn giản, không yêu cầu phản xạ cao.

Game không tập trung vào cạnh tranh, tốc độ, chiến đấu hoặc kỹ năng thao tác phức tạp.

## 5. Core gameplay loop

Luồng chơi chính của demo:

1. Người chơi mở game.
2. Màn hình title giới thiệu tên game và bầu không khí.
3. Người chơi gặp thầy bói KÌ.
4. KÌ đặt các câu hỏi nhập môn.
5. Hệ thống tính điểm chủ đề từ câu trả lời.
6. Game chọn ba lá Major Arcana cho Quá khứ / Hiện tại / Tương lai.
7. Người chơi xem nghi thức lật bài.
8. Người chơi lần lượt bước vào ba không gian nội tâm.
9. Trong mỗi không gian, người chơi:
   - đọc narrative ngắn theo lá bài,
   - trả lời câu hỏi lựa chọn,
   - nhập một câu trả lời tự do,
   - nhận AI interpretation,
   - chơi một mini card game,
   - nhận Self Fragment.
10. Người chơi quay lại phòng bói.
11. KÌ tạo final report từ toàn bộ dữ liệu hành trình.
12. Game hiển thị bản tổng kết cuối.

## 6. Các hệ thống chính

### 6.1. Title / Intro System

**Chức năng:**

- Hiển thị tên game.
- Thiết lập tone dark cozy tarot.
- Dẫn người chơi vào phòng bói của KÌ.

**Vai trò trong demo:** tạo ấn tượng ban đầu và giúp người chơi hiểu đây là hành trình tự soi chiếu, không phải game tarot ngẫu nhiên thuần túy.

### 6.2. KÌ Tarot Room

**Chức năng:**

- Đóng vai trò hub chính.
- KÌ nói chuyện với người chơi.
- KÌ đặt onboarding questions.
- KÌ thực hiện nghi thức chọn và lật bài.
- KÌ xuất hiện lại ở cuối game để trao final report.

**Vai trò trong demo:** kết nối toàn bộ flow thành một trải nghiệm có nhân vật dẫn chuyện rõ ràng.

### 6.3. Onboarding Question System

**Chức năng:**

- Hiển thị câu hỏi nhập môn.
- Ghi nhận lựa chọn của người chơi.
- Mỗi lựa chọn cộng điểm vào một số nhóm chủ đề tarot.

**Ví dụ nhóm chủ đề:**

- Ký ức / quá khứ.
- Lựa chọn / hiện tại.
- Hy vọng / tương lai.
- Sợ thay đổi.
- Trực giác.
- Ý chí.
- Cân bằng.

**Vai trò trong demo:** giúp việc chọn lá bài có cơ sở từ câu trả lời của người chơi, thay vì hoàn toàn ngẫu nhiên.

### 6.4. Tarot Card Selection System

**Chức năng:**

- Load dữ liệu 22 lá Major Arcana.
- Tính điểm phù hợp giữa câu trả lời và từng lá bài.
- Chọn ba lá cho Past / Present / Future.
- Đảm bảo một lượt chơi không trùng lá.

**Vai trò trong demo:** biến tarot thành một hệ thống gameplay có logic và có tính cá nhân hóa.

### 6.5. Card Reveal System

**Chức năng:**

- Hiển thị ba lá bài đã chọn.
- Gắn mỗi lá với một thời kỳ: Past, Present, Future.
- Tạo khoảnh khắc nghi thức lật bài.

**Vai trò trong demo:** đây là điểm chuyển quan trọng từ phần nhập môn sang hành trình ba không gian nội tâm.

### 6.6. Inner Space System

Mỗi lá bài mở ra một không gian nội tâm riêng.

Mỗi không gian gồm:

- Một đoạn narrative ngắn dựa trên ý nghĩa lá bài.
- Một nhân vật hoặc hình ảnh đại diện cho lá bài.
- Các câu hỏi lựa chọn.
- Một câu hỏi tự do.
- Một AI interpretation.
- Một mini card game.
- Một Self Fragment reward.

Ba không gian chính:

1. **Past Space** — nhìn lại điều đã qua.
2. **Present Space** — nhận diện mâu thuẫn hiện tại.
3. **Future Space** — hình dung khả năng phía trước.

**Vai trò trong demo:** tạo cấu trúc ba hồi rõ ràng, giúp game có nhịp tiến triển thay vì chỉ là một bài quiz.

### 6.7. Question & Personality Scoring System

**Chức năng:**

- Quản lý câu hỏi trong từng giai đoạn.
- Ghi nhận câu trả lời lựa chọn.
- Cập nhật các chỉ số ẩn dùng cho final report.

**Ví dụ chỉ số ẩn:**

- Attachment to Past — mức độ gắn với quá khứ.
- Self Trust — mức độ tin vào bản thân.
- Fear of Change — mức độ sợ thay đổi.
- Action vs Reflection — thiên về hành động hay suy ngẫm.
- Control vs Acceptance — thiên về kiểm soát hay chấp nhận.
- Connection vs Solitude — thiên về kết nối hay một mình.

**Vai trò trong demo:** tạo dữ liệu nền để final report có cảm giác phản ánh lựa chọn của người chơi.

### 6.8. Free-text Reflection System

**Chức năng:**

- Mỗi không gian có một câu hỏi tự do.
- Người chơi nhập câu trả lời bằng văn bản.
- Câu trả lời được gửi đến AI proxy để diễn giải.

**Vai trò trong demo:** tăng cảm giác cá nhân hóa vì người chơi không chỉ chọn đáp án có sẵn, mà còn có thể viết suy nghĩ riêng.

### 6.9. AI Integration System

**Chức năng:**

- Godot gửi dữ liệu đến local AI proxy.
- Proxy giữ API key ở môi trường local.
- AI nhận context gồm: lá bài, giai đoạn, câu hỏi, câu trả lời, trạng thái hành trình.
- AI trả về JSON có cấu trúc.

AI dùng cho:

1. Diễn giải câu trả lời tự do trong từng không gian.
2. Tạo final report cuối game.

**Giới hạn scope:** AI không điều khiển logic thắng thua của mini game, không đóng vai chatbot xuyên suốt và không quyết định flow chính.

**Vai trò trong demo:** tạo điểm nhấn kỹ thuật và giúp nội dung phản tư linh hoạt hơn nội dung hardcode.

### 6.10. Mini Card Game System

Mỗi không gian có một mini card game nhỏ. Người chơi hoàn thành hoặc chiến thắng để nhận **Self Fragment**.

Ba biến thể dự kiến:

1. **Past — Blackjack-lite**
   - Chủ đề: chuộc lại ký ức.
   - Mục tiêu: đạt điểm gần 21 hơn đối thủ hoặc ngưỡng mục tiêu.

2. **Present — Poker-lite**
   - Chủ đề: dùng những lá bài đang có.
   - Mục tiêu: tạo cặp, bộ hoặc pattern đơn giản.

3. **Future — Symbol Match-lite**
   - Chủ đề: mở đường tương lai.
   - Mục tiêu: đánh lá theo biểu tượng hoặc màu phù hợp.

**Vai trò trong demo:** thêm tương tác gameplay ngoài đọc thoại và trả lời câu hỏi, đồng thời giữ chủ đề “bài” xuyên suốt dự án.

### 6.11. Final Report System

**Chức năng:**

- Tổng hợp toàn bộ dữ liệu hành trình:
  - ba lá tarot,
  - onboarding answers,
  - multiple-choice answers,
  - free-text reflections,
  - AI interpretations,
  - mini game results,
  - Self Fragments,
  - hidden personality scores.
- Gửi context tổng hợp đến AI.
- Hiển thị bản đọc cuối cùng cho người chơi.

**Nội dung final report:**

- Tiêu đề bản đọc.
- Core self — hình ảnh bản thân cốt lõi.
- Past pattern — mô thức từ quá khứ.
- Present tension — mâu thuẫn hiện tại.
- Future invitation — lời mời từ tương lai.
- Advice — lời khuyên ngắn.
- Three keywords — ba từ khóa đại diện.

**Vai trò trong demo:** tạo kết thúc rõ ràng và thể hiện được toàn bộ pipeline: gameplay → dữ liệu → AI → kết quả cá nhân hóa.

## 7. Kiến trúc kỹ thuật dự kiến

```text
D:/KÌ/
  project.godot
  CLAUDE.md
  README.md

  data/
    tarot_major_arcana.json
    questions.json
    prompts.json
    local_config.example.json

  scripts/
    core/
      game_state.gd
      json_loader.gd
    tarot/
      tarot_manager.gd
    questions/
      question_manager.gd
    ai/
      ai_client.gd
    report/
      report_builder.gd
    minigames/
      card_model.gd
      minigame_manager.gd
    ui/
      main_controller.gd

  scenes/
    main.tscn
    title/
    tarot_room/
    questions/
    cards/
    inner_space/
    minigames/
    report/

  tools/
    ai_proxy/
      server.mjs
      package.json
      .env.example
```

## 8. Vai trò các module chính

### GameState

Lưu trạng thái một lượt chơi:

- câu trả lời nhập môn,
- ba lá bài đã chọn,
- câu trả lời trong từng không gian,
- điểm tính cách ẩn,
- AI interpretations,
- mini game results,
- Self Fragments,
- final report.

### TarotManager

- Load dữ liệu tarot.
- Tính điểm chủ đề.
- Chọn ba lá bài phù hợp.
- Đảm bảo không trùng lá trong một lượt chơi.

### QuestionManager

- Load dữ liệu câu hỏi.
- Trả về câu hỏi theo giai đoạn.
- Ghi nhận lựa chọn và câu trả lời tự do.
- Cập nhật score liên quan.

### AIClient

- Gọi local AI proxy.
- Gửi context và prompt.
- Parse JSON response.
- Báo lỗi rõ nếu proxy hoặc AI fail.

### MiniGameManager

- Chạy mini game tương ứng với từng không gian.
- Tính kết quả thắng / thua / hoàn thành.
- Ghi Self Fragment reward.

### ReportBuilder

- Tổng hợp dữ liệu cuối game.
- Tạo payload gửi AI.
- Chuẩn hóa dữ liệu report để UI hiển thị.

### MainController

- Điều phối flow chính.
- Chuyển giữa title, tarot room, onboarding, card reveal, inner spaces, mini games và report.
- Giữ luồng demo chạy tuyến tính và dễ kiểm thử.

## 9. Điểm nổi bật kỹ thuật

- Project độc lập bằng Godot 4.x.
- Có mục tiêu export Web / HTML5.
- UI dùng Control nodes để phù hợp desktop và mobile browser.
- Dữ liệu tarot, câu hỏi và prompt tách khỏi code bằng JSON.
- Có hệ thống chọn bài dựa trên điểm từ câu trả lời.
- Có hidden scoring dùng cho final report.
- AI tích hợp qua local proxy, không hardcode API key trong Godot.
- AI response dùng JSON schema để dễ parse và hiển thị.
- Mini game logic nằm trong game, không phụ thuộc AI.
- Core flow có thể kiểm thử từ đầu đến cuối.

## 10. Kiểm soát rủi ro và phạm vi

### Rủi ro 1: Scope quá rộng

**Cách kiểm soát:**

- Chỉ dùng 22 lá Major Arcana.
- Chỉ làm ba không gian chính: Past / Present / Future.
- Mỗi không gian chỉ có một mini game nhỏ.
- Không làm đủ 78 lá tarot.
- Không làm multiplayer.
- Không làm chatbot xuyên suốt.
- Ưu tiên playable demo trước polish.

### Rủi ro 2: AI trả sai format

**Cách kiểm soát:**

- Prompt yêu cầu JSON rõ ràng.
- AIClient parse response theo schema.
- UI hiển thị lỗi và cho retry nếu proxy hoặc AI fail.
- AI không quyết định logic thắng thua nên không làm hỏng mini game.

### Rủi ro 3: Web export lỗi trên mobile

**Cách kiểm soát:**

- Dùng Control nodes và layout responsive.
- Dùng ScrollContainer cho nội dung dài.
- Button đủ lớn cho thao tác touch.
- Test viewport phone sớm, khoảng 390x844.

### Rủi ro 4: Mini game tốn thời gian hơn dự kiến

**Cách kiểm soát:**

- Luật chơi giữ đơn giản.
- Ưu tiên một mini game chạy ổn trước, sau đó mở rộng thành ba biến thể.
- Nếu cần demo gấp, có thể giảm độ sâu chiến thuật nhưng vẫn giữ tương tác và reward.

## 11. Kế hoạch demo trước mentor

Flow trình bày đề xuất:

1. Giới thiệu mục tiêu: làm một web game ngắn trong thời gian kiến tập, có gameplay và điểm nhấn AI.
2. Giới thiệu concept: tarot + tự khám phá bản thân + mini card game + AI reflection.
3. Mở game trên browser.
4. Cho mentor xem title và phòng bói của KÌ.
5. Trả lời onboarding questions.
6. Cho thấy hệ thống chọn ba lá Past / Present / Future.
7. Vào một inner space.
8. Trả lời câu hỏi lựa chọn.
9. Nhập câu trả lời tự do.
10. Cho AI trả interpretation.
11. Chơi mini card game ngắn.
12. Nhảy đến final report hoặc chạy hết flow nếu đủ thời gian.
13. Giải thích kiến trúc: Godot scene flow, JSON data, managers, AI proxy, bảo mật API key.

## 12. Tiêu chí hoàn thành demo

Dự án đạt mức demo kiến tập khi:

- Game chạy được từ đầu đến cuối.
- Có title screen và phòng bói của KÌ.
- Có onboarding questions.
- Game chọn được ba lá Major Arcana không trùng nhau.
- Card reveal hiển thị Past / Present / Future rõ ràng.
- Có ba inner spaces hoặc ít nhất một inner space hoàn chỉnh để chứng minh pattern.
- Có câu hỏi lựa chọn và câu hỏi tự do.
- AI interpretation hoạt động trong intended demo path.
- Có ít nhất một mini card game chạy được; mục tiêu tốt hơn là đủ ba biến thể nhẹ.
- Self Fragment reward được ghi nhận.
- Final report hiển thị rõ.
- Game mở được trên browser.
- UI không vỡ trên phone viewport.
- API key không nằm trong Godot project hoặc GitHub.

## 13. Giá trị học được từ dự án

Thông qua dự án này, em tập trung rèn các nhóm kỹ năng:

- Thiết kế gameplay loop có mở đầu, tương tác, tiến triển và kết thúc.
- Tổ chức project Godot 4 theo scene và script rõ ràng.
- Làm UI web game phù hợp cả desktop và mobile browser.
- Thiết kế data-driven content bằng JSON.
- Tích hợp AI vào game qua proxy thay vì hardcode API key.
- Kiểm soát scope để hoàn thành demo trong thời gian ngắn.
- Trình bày sản phẩm theo cả góc nhìn trải nghiệm người chơi và góc nhìn kỹ thuật.

## 14. Tóm tắt một câu

**KÌ: Ba Lá Của Bản Ngã** là một web game Godot ngắn dùng tarot, lựa chọn phản tư, mini card game và AI để dẫn người chơi qua hành trình nhìn lại quá khứ, nhận diện hiện tại và đối thoại với tương lai của chính mình.
