# KÌ: Ba Lá Của Bản Ngã — Project Overview

## 1. Thông tin tổng quan

**Tên dự án:** KÌ: Ba Lá Của Bản Ngã  
**Thể loại:** Web game giải đố - tự khám phá bản thân - tarot narrative  
**Engine:** Godot 4.x  
**Ngôn ngữ:** GDScript  
**Nền tảng mục tiêu:** Desktop browser và mobile browser  
**Thời gian thực hiện:** 2026-05-04 đến trước 2026-05-15  
**Mục tiêu demo:** Người chơi có thể hoàn thành một lượt chơi đầy đủ từ màn hình bắt đầu đến bản tổng kết cuối.

## 2. Ý tưởng cốt lõi

KÌ là một game web ngắn xoay quanh trải nghiệm bói tarot và tự tìm hiểu bản thân. Người chơi gặp nhân vật thầy bói tên **KÌ**, trả lời một số câu hỏi nhập môn, sau đó game chọn ra 3 lá bài Major Arcana đại diện cho:

1. **Quá khứ**
2. **Hiện tại**
3. **Tương lai**

Mỗi lá bài mở ra một không gian nội tâm riêng. Trong đó, người chơi đối thoại với nhân vật tượng trưng cho lá bài, trả lời các câu hỏi lựa chọn, nhập một câu trả lời tự do, chơi một mini game bài nhỏ, rồi nhận diễn giải từ AI.

Cuối game, KÌ tổng hợp toàn bộ hành trình thành một bản đánh giá nhẹ nhàng theo phong cách ứng dụng khám phá tính cách / tự phản tư.

## 3. Mục tiêu dự án

### Mục tiêu sản phẩm

- Tạo một game nhỏ có thể hoàn thành trong thời gian kiến tập 2 tuần.
- Có gameplay rõ ràng, không chỉ là demo giao diện.
- Có điểm nhấn sáng tạo: kết hợp tarot, giải đố, câu hỏi tự phản tư, và AI.
- Chạy được trên trình duyệt desktop và điện thoại.
- Có thể trình bày được với mentor như một dự án có cấu trúc, mục tiêu và phạm vi rõ ràng.

### Mục tiêu kỹ thuật

- Xây dựng project Godot 4 độc lập.
- Tổ chức code theo các module nhỏ, dễ hiểu, dễ mở rộng.
- Dữ liệu tarot, câu hỏi, prompt AI được tách ra thành file JSON.
- Tích hợp AI qua local proxy để tránh hardcode API key trong game.
- Có khả năng export Web/HTML5.
- Giữ luồng chơi chính luôn hoạt động ổn định.

## 4. Đối tượng người chơi

Game hướng tới người chơi thích:

- Trải nghiệm narrative ngắn.
- Tarot, biểu tượng, tâm linh nhẹ.
- Game tự khám phá bản thân.
- Puzzle nhỏ, không quá khó.
- Trải nghiệm có tính cảm xúc và suy ngẫm.

Game không tập trung vào cạnh tranh, tốc độ, hành động hoặc kỹ năng phản xạ.

## 5. Core loop gameplay

Luồng chơi chính gồm các bước:

1. Người chơi mở game.
2. Gặp thầy bói KÌ.
3. Trả lời câu hỏi nhập môn.
4. Game chọn 3 lá tarot dựa trên câu trả lời.
5. Người chơi xem nghi thức lật bài.
6. Vào không gian Quá khứ.
7. Trả lời câu hỏi, nhập câu trả lời tự do, chơi mini game bài.
8. AI diễn giải câu trả lời.
9. Lặp lại với không gian Hiện tại.
10. Lặp lại với không gian Tương lai.
11. Quay lại phòng bói của KÌ.
12. Nhận bản tổng kết cuối.

## 6. Cấu trúc chức năng

### 6.1. Title / Intro System

Chức năng:

- Hiển thị tên game.
- Giới thiệu bối cảnh ngắn.
- Đưa người chơi vào phòng bói của KÌ.

Mục đích:

- Tạo ấn tượng ban đầu.
- Đặt tone dark cozy tarot.
- Giúp người chơi hiểu đây là hành trình tự soi chiếu bản thân.

### 6.2. KÌ Tarot Room

Chức năng:

- KÌ nói chuyện với người chơi.
- KÌ đặt các câu hỏi nhập môn.
- KÌ thực hiện nghi thức xào bài / lật bài.

Mục đích:

- Là hub narrative chính.
- Liên kết các phần gameplay thành một trải nghiệm có chủ đề.
- Là nơi bắt đầu và kết thúc hành trình.

### 6.3. Onboarding Question System

Chức năng:

- Đưa ra một số câu hỏi ban đầu.
- Người chơi chọn đáp án.
- Mỗi đáp án cộng điểm vào một số nhóm chủ đề tarot.

Ví dụ nhóm chủ đề:

- Quá khứ / ký ức
- Hiện tại / lựa chọn
- Tương lai / hy vọng
- Sợ thay đổi
- Trực giác
- Ý chí
- Cân bằng

Mục đích:

- Cá nhân hóa trải nghiệm.
- Chọn 3 lá bài không hoàn toàn random.
- Làm người chơi cảm thấy game đang phản hồi theo chính câu trả lời của họ.

### 6.4. Tarot Card Selection System

Chức năng:

- Load dữ liệu 22 lá Major Arcana.
- Tính điểm chủ đề từ onboarding answers.
- Chọn 3 lá cho Quá khứ / Hiện tại / Tương lai.
- Đảm bảo một lượt chơi không trùng lá.

Mục đích:

- Biến tarot thành hệ thống gameplay.
- Tạo tính cá nhân hóa.
- Giữ scope nhỏ bằng cách chỉ dùng Major Arcana thay vì đủ 78 lá.

### 6.5. Card Reveal System

Chức năng:

- Hiển thị 3 lá bài đã chọn.
- Gắn từng lá với một thời kỳ: Past, Present, Future.
- Tạo cảm giác nghi thức bói bài.

Mục đích:

- Tạo khoảnh khắc trọng tâm của trải nghiệm.
- Cho người chơi biết hành trình sắp đi qua những chủ đề nào.

### 6.6. Inner Space System

Mỗi lá bài mở ra một không gian nội tâm riêng.

Mỗi không gian gồm:

- Một câu chuyện ngắn dựa trên lá bài.
- Một nhân vật đại diện cho lá bài.
- Nhiều câu hỏi lựa chọn.
- Một câu hỏi tự do.
- Một mini game bài.
- Một đoạn AI interpretation.

Ba không gian chính:

1. **Past Space** — nhìn lại điều đã qua.
2. **Present Space** — nhận diện mâu thuẫn hiện tại.
3. **Future Space** — hình dung khả năng phía trước.

Mục đích:

- Tạo cấu trúc 3 hồi rõ ràng.
- Biến ý nghĩa tarot thành trải nghiệm tương tác.
- Giúp người chơi phản tư từng lớp thay vì chỉ đọc kết quả bói.

### 6.7. Question & Personality Scoring System

Chức năng:

- Quản lý câu hỏi trong từng không gian.
- Ghi lại lựa chọn của người chơi.
- Cập nhật các chỉ số ẩn.

Ví dụ chỉ số ẩn:

- Attachment to Past — mức độ gắn với quá khứ.
- Self Trust — mức độ tin bản thân.
- Fear of Change — mức độ sợ thay đổi.
- Action vs Reflection — thiên về hành động hay suy ngẫm.
- Control vs Acceptance — thiên về kiểm soát hay chấp nhận.
- Connection vs Solitude — thiên về kết nối hay một mình.

Mục đích:

- Tạo nền dữ liệu cho bản tổng kết cuối.
- Giúp game giống một công cụ khám phá bản thân hơn là quiz đơn giản.

### 6.8. Free-text Reflection System

Chức năng:

- Mỗi không gian có một câu hỏi tự do.
- Người chơi nhập câu trả lời bằng văn bản.
- Câu trả lời được gửi tới AI để diễn giải.

Mục đích:

- Tăng cảm giác cá nhân hóa.
- Cho người chơi thể hiện suy nghĩ thật thay vì chỉ chọn đáp án có sẵn.
- Tạo điểm nhấn kỹ thuật AI cho dự án.

### 6.9. AI Integration System

Chức năng:

- Game gửi dữ liệu tới local AI proxy.
- AI nhận: lá bài, thời kỳ, câu hỏi, câu trả lời, trạng thái hành trình.
- AI trả về JSON có cấu trúc.

AI dùng cho:

1. Diễn giải câu trả lời tự do trong từng không gian.
2. Tạo câu thoại chuyển tiếp của nhân vật lá bài.
3. Viết bản tổng kết cuối.

Mục đích:

- Tạo phản hồi linh hoạt.
- Làm demo có điểm nổi bật về ứng dụng AI.
- Tránh hardcode mọi kết quả phản tư.

Lưu ý kỹ thuật:

- API key không được hardcode trong Godot.
- Game gọi local proxy.
- Proxy giữ API key ở file `.env` local, không commit lên GitHub.

### 6.10. Mini Card Game System

Mỗi không gian có một mini game bài nhỏ. Người chơi thắng để nhận **Self Fragments** — mảnh bản ngã.

Ba mini game dự kiến:

1. **Past — Blackjack-lite**
   - Chủ đề: chuộc lại ký ức.
   - Mục tiêu: đạt điểm gần 21 hơn đối thủ.

2. **Present — Poker-lite**
   - Chủ đề: dùng những lá bài mình đang có.
   - Mục tiêu: tạo cặp, bộ hoặc pattern đơn giản.

3. **Future — Symbol Match-lite**
   - Chủ đề: mở đường tương lai.
   - Mục tiêu: đánh lá theo biểu tượng hoặc màu phù hợp.

Mục đích:

- Tạo gameplay ngoài đọc thoại.
- Giữ chủ đề “bài” xuyên suốt.
- Thêm yếu tố vui nhẹ, không làm game thành quiz thuần.

### 6.11. Final Report System

Chức năng:

- Tổng hợp toàn bộ dữ liệu:
  - 3 lá tarot.
  - onboarding answers.
  - multiple-choice answers.
  - free-text reflections.
  - AI interpretations.
  - mini game results.
  - hidden personality scores.
- Gửi dữ liệu tới AI.
- Hiển thị bản soi chiếu cuối.

Nội dung report gồm:

- Tiêu đề bản đọc.
- Core self — hình ảnh bản thân cốt lõi.
- Past pattern — mô thức từ quá khứ.
- Present tension — mâu thuẫn hiện tại.
- Future invitation — lời mời từ tương lai.
- Advice — lời khuyên ngắn.
- Three keywords — 3 từ khóa đại diện.

Mục đích:

- Tạo kết thúc có ý nghĩa.
- Cho người chơi cảm giác hành trình của họ được tổng hợp lại.
- Là phần dễ trình bày với mentor nhất vì thể hiện gameplay + data + AI.

## 7. Cấu trúc code dự kiến

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
- 3 lá bài đã chọn,
- câu trả lời trong từng không gian,
- điểm tính cách ẩn,
- kết quả AI,
- kết quả mini game,
- final report.

### TarotManager

- Load dữ liệu tarot.
- Tính điểm chủ đề.
- Chọn 3 lá bài phù hợp.

### QuestionManager

- Load câu hỏi.
- Trả về câu hỏi theo giai đoạn.
- Ghi nhận lựa chọn và câu trả lời tự do.

### AIClient

- Gọi local AI proxy.
- Gửi prompt và dữ liệu context.
- Parse JSON response.
- Báo lỗi nếu AI/proxy fail.

### MiniGameManager

- Chạy mini game tương ứng từng không gian.
- Tính thắng/thua.
- Ghi Self Fragments.

### ReportBuilder

- Tổng hợp dữ liệu cuối.
- Gọi AI tạo final report.
- Chuẩn hóa dữ liệu hiển thị.

### MainController

- Điều phối toàn bộ flow game.
- Chuyển giữa title, onboarding, card reveal, spaces, mini game, report.

## 9. Điểm nổi bật kỹ thuật

- Project độc lập bằng Godot 4.
- Chạy được trên web browser.
- Thiết kế mobile-first/touch-friendly.
- Data-driven bằng JSON cho tarot, câu hỏi, prompts.
- Tích hợp AI qua local proxy.
- Tách API key khỏi game client.
- Cấu trúc module rõ ràng.
- Có mini game bài thay vì chỉ đọc text.
- Có personalization dựa trên lựa chọn và free-text input.

## 10. Rủi ro và cách kiểm soát scope

### Rủi ro: AI trả sai format JSON

Cách xử lý:

- Prompt yêu cầu JSON rõ.
- UI có màn báo lỗi / retry nếu parse fail.
- AI không quyết định logic thắng thua nên không làm hỏng mini game.

### Rủi ro: Web export lỗi trên mobile

Cách xử lý:

- UI dùng Control nodes, layout responsive.
- Button lớn, text lớn.
- Test viewport phone sớm.

### Rủi ro: Scope quá rộng

Cách xử lý:

- Chỉ dùng 22 Major Arcana.
- Mỗi không gian chỉ có một mini game nhỏ.
- Không làm đủ 78 lá.
- Không làm chatbot xuyên suốt.
- Không làm multiplayer.
- Ưu tiên playable flow trước polish.

### Rủi ro: Mini game mất nhiều thời gian

Cách xử lý:

- Dùng rule đơn giản.
- Có thể mô phỏng kết quả nhanh nếu cần demo.
- Tập trung vào cảm giác tương tác hơn độ sâu chiến thuật.

## 11. Kế hoạch demo trước mentor

Khi trình bày, có thể đi theo flow:

1. Giới thiệu vấn đề: muốn làm game nhỏ trong 2 tuần nhưng có cá tính riêng.
2. Giới thiệu ý tưởng: tarot + tự hiểu bản thân + AI.
3. Mở game trên browser.
4. Cho thấy KÌ hỏi onboarding questions.
5. Lật 3 lá Past / Present / Future.
6. Vào một inner space.
7. Trả lời câu hỏi lựa chọn.
8. Nhập câu trả lời tự do.
9. Cho AI trả interpretation.
10. Chơi mini game bài ngắn.
11. Nhảy tới final report hoặc trình bày report đã chuẩn bị.
12. Giải thích cấu trúc kỹ thuật: Godot, JSON data, managers, AI proxy.

## 12. Tiêu chí hoàn thành

Dự án được xem là hoàn thành ở mức demo kiến tập nếu:

- Game chạy được từ đầu đến cuối.
- Có đủ 3 lá bài và 3 không gian.
- Có câu hỏi lựa chọn và câu hỏi tự do.
- AI hoạt động trong demo.
- Có ít nhất một mini game bài chạy được; tốt nhất là đủ 3 biến thể nhẹ.
- Final report hiển thị rõ.
- Có thể mở trên browser.
- UI không vỡ trên phone viewport.
- Code và dữ liệu được tổ chức rõ.
- Không lộ API key trên GitHub.

## 13. Tóm tắt một câu

**KÌ: Ba Lá Của Bản Ngã** là một web game Godot ngắn dùng tarot, câu hỏi tự phản tư, mini game bài và AI để dẫn người chơi qua hành trình nhìn lại quá khứ, nhận diện hiện tại và đối thoại với tương lai của chính mình.
