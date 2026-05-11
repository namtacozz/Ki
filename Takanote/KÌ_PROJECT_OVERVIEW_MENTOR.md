# KÌ: Ba Lá Của Bản Ngã — Project Overview for Mentor

## 1. Thông tin tổng quan

**Tên dự án:** KÌ: Ba Lá Của Bản Ngã  
**Thể loại:** Web game narrative / tự khám phá bản thân / mini card game  
**Chủ đề:** Tarot, nội tâm, lựa chọn cá nhân, Mảnh Hồn, phản tư bằng AI  
**Engine:** Godot 4.x  
**Nền tảng mục tiêu:** Desktop browser  
**Mục tiêu demo:** Người chơi hoàn thành được một lượt chơi đầy đủ từ màn hình mở đầu đến bản soi chiếu cuối.

---

## 2. Tóm tắt dự án

**KÌ: Ba Lá Của Bản Ngã** là một web game ngắn, nơi người chơi gặp thầy bói tên **KÌ** và đi qua một hành trình tự soi chiếu bản thân bằng tarot.

Game bắt đầu bằng một vài câu hỏi nhập môn. Từ câu trả lời của người chơi, hệ thống chọn ra ba lá **Major Arcana** đại diện cho:

1. **Quá khứ** — điều người chơi đang mang theo.
2. **Hiện tại** — điều người chơi đang đối diện.
3. **Tương lai** — khả năng hoặc lời mời phía trước.

Sau đó, người chơi bước vào từng không gian nội tâm của mỗi lá bài, trả lời câu hỏi, chơi mini game bằng bài Tây để nhận **Mảnh Hồn**, rồi nhận diễn giải từ AI. Cuối hành trình, KÌ tổng hợp toàn bộ lựa chọn, câu trả lời và kết quả mini game thành một bản soi chiếu cuối.

---

## 3. Lý do chọn đề tài

Em chọn đề tài này vì nó vừa đủ nhỏ để hoàn thành trong thời gian kiến tập, vừa có điểm nổi bật để trình bày:

- Có một vòng chơi hoàn chỉnh: mở đầu, lựa chọn, tiến triển, mini game, kết thúc.
- Có yếu tố cá nhân hóa: câu trả lời ảnh hưởng đến lá bài và bản soi chiếu cuối.
- Có phong cách riêng: tarot, thầy bói KÌ, không khí huyền bí nhẹ.
- Có gameplay thật: ba mini game bài Tây gắn với Quá khứ / Hiện tại / Tương lai.
- Có tích hợp AI: AI không điều khiển game, chỉ giúp diễn giải hành trình của người chơi.

Scope được giữ gọn: chỉ dùng 22 lá Major Arcana, không làm đủ 78 lá tarot, không multiplayer, không chatbot dài, ưu tiên demo chơi được từ đầu đến cuối.

---

## 4. Trải nghiệm người chơi

Người chơi phù hợp là người thích:

- narrative game ngắn,
- tarot và biểu tượng,
- trải nghiệm tự khám phá bản thân,
- câu hỏi phản tư,
- mini game nhẹ, không cần phản xạ nhanh.

Game không tập trung vào thắng thua căng thẳng. Trọng tâm là cảm giác người chơi đang đối thoại với chính mình thông qua lựa chọn, lá bài và Mảnh Hồn.

---

## 5. Core gameplay loop

Luồng chơi chính:

1. Người chơi mở game tại màn hình title.
2. Gặp KÌ và nghe giới thiệu hành trình.
3. Trả lời câu hỏi nhập môn.
4. Game chọn ba lá tarot cho Quá khứ / Hiện tại / Tương lai.
5. Người chơi xem nghi thức lật bài.
6. Với từng lá bài, người chơi:
   - đọc đoạn dẫn chuyện,
   - trả lời các câu hỏi lựa chọn,
   - nhập một câu trả lời tự do,
   - chơi mini game bài Tây,
   - nhận Mảnh Hồn,
   - nhận diễn giải AI.
7. Sau ba không gian, KÌ tạo bản soi chiếu cuối.
8. Người chơi đọc final report và có thể chơi lại.

---

## 6. Ba lá bài và ý nghĩa

### Quá khứ

Lá Quá khứ đại diện cho điều người chơi đã trải qua hoặc vẫn đang mang theo. Nội dung phần này thường liên quan đến ký ức, vết cũ, sự tiếc nuối hoặc điều cần buông bỏ.

### Hiện tại

Lá Hiện tại đại diện cho trạng thái người chơi đang đối diện. Phần này tập trung vào lựa chọn, mâu thuẫn, sự thích nghi và cách người chơi đọc tình huống trước mắt.

### Tương lai

Lá Tương lai không nói trước kết quả chắc chắn, mà gợi ra một khả năng. Phần này liên quan đến trực giác, dự đoán, hy vọng và cách người chơi bước tiếp khi chưa biết mọi thứ.

---

## 7. Hệ thống câu hỏi

Game có hai loại câu hỏi:

1. **Câu hỏi lựa chọn**  
   Người chơi chọn một đáp án. Mỗi lựa chọn có nhãn ý nghĩa để game hiểu khuynh hướng của người chơi.

2. **Câu hỏi tự do**  
   Người chơi tự viết suy nghĩ của mình. Đây là dữ liệu quan trọng để AI diễn giải cá nhân hơn.

Câu hỏi được thiết kế riêng theo từng lá bài và từng vị trí Quá khứ / Hiện tại / Tương lai, để cùng một lá tarot nhưng khi rơi vào vị trí khác nhau sẽ tạo cảm giác khác nhau.

---

## 8. Mini game và Mảnh Hồn

Mỗi không gian có một mini game dùng bộ bài Tây 52 lá. Mini game không chỉ để thắng thua, mà còn tạo thêm dữ liệu về cách người chơi ra quyết định.

### 8.1. Quá khứ — Hai Mươi Mốt Lời Thú Nhận

Đây là biến thể blackjack. Người chơi rút bài để tiến gần 21 điểm, nhưng nếu vượt quá thì bị “quá tải” bởi ký ức.

Người chơi có thể:

- rút thêm,
- dừng lại,
- đốt một lá bài để tượng trưng cho việc buông bỏ một phần ký ức.

Ý nghĩa: người chơi chọn đào sâu thêm hay dừng lại đúng lúc trước quá khứ.

### 8.2. Hiện tại — Poker của Hiện Tại

Người chơi có 2 lá bài riêng. Các lá chung được lật dần theo kiểu Flop / Turn / River. Trước mỗi lần lật thêm, người chơi có thể đổi một trong hai lá của mình hoặc giữ nguyên.

Kết quả được tính theo thứ hạng poker chuẩn như Pair, Straight, Flush, Full House, Royal Flush.

Ý nghĩa: hiện tại là thứ đang mở dần ra, và người chơi phải quyết định giữ vững hay thay đổi bản thân theo thông tin mới.

### 8.3. Tương lai — Cao Hơn / Thấp Hơn

Game lật một lá bài đầu tiên. Người chơi đoán lá kế tiếp sẽ cao hơn hay thấp hơn. Mỗi lần đoán đúng sẽ tiếp tục và cộng dồn Mảnh Hồn. Người chơi có thể dừng lại để giữ phần đã đạt được.

Ý nghĩa: tương lai là vùng bất định. Người chơi dùng trực giác để đọc dấu hiệu, nhưng không thể biết chắc hoàn toàn.

---

## 9. Mảnh Hồn

**Mảnh Hồn** là phần thưởng người chơi nhận được từ mini game. Nó không phải tiền hay điểm số arcade, mà là dấu vết của hành trình nội tâm.

Mỗi mini game tạo ra:

- số Mảnh Hồn nhận được,
- lý do nhận Mảnh Hồn,
- hồ sơ hành vi ngắn của người chơi,
- các nhãn ý nghĩa để AI dùng trong bản soi chiếu cuối.

Ví dụ:

- Quá khứ: người chơi thận trọng, mạo hiểm, hay biết buông bỏ.
- Hiện tại: người chơi ổn định, thích nghi, hay thay đổi liên tục.
- Tương lai: người chơi tin trực giác, dừng đúng lúc, hay cố đi quá xa.

---

## 10. Vai trò của AI

AI trong game có vai trò diễn giải, không điều khiển gameplay.

AI nhận dữ liệu như:

- lá tarot đã chọn,
- vị trí Quá khứ / Hiện tại / Tương lai,
- câu trả lời của người chơi,
- kết quả mini game,
- Mảnh Hồn,
- diễn biến hành trình.

AI dùng dữ liệu đó để tạo:

1. diễn giải sau từng không gian,
2. bản soi chiếu cuối.

API key không nằm trong Godot project. Game gọi qua một local proxy để giữ phần nhạy cảm ở ngoài game.

---

## 11. Các hệ thống chính

### Title / Intro

Màn hình mở đầu tạo không khí tarot và dẫn người chơi vào cuộc gặp với KÌ.

### Tarot Selection

Hệ thống chọn ba lá Major Arcana dựa trên câu trả lời nhập môn, kết hợp một phần ngẫu nhiên để mỗi lượt chơi không quá giống nhau.

### Narrative Screen

Đây là màn hình dẫn chuyện chính. Nó hiển thị nhân vật, nền, câu thoại, câu hỏi và lựa chọn của người chơi.

### Mini Game System

Quản lý ba mini game bài Tây, tính kết quả và Mảnh Hồn.

### Report System

Gom toàn bộ dữ liệu hành trình và hiển thị bản soi chiếu cuối.

### Settings / Trợ năng

Game có các tuỳ chọn cơ bản để người chơi dễ tiếp cận hơn, như cỡ chữ, tốc độ chữ chạy, giảm chuyển động, tương phản cao và hướng dẫn chơi.

---


## 12. Điểm nổi bật kỹ thuật

- Game chạy bằng Godot 4.x và hướng đến web browser.
- Dữ liệu tarot, câu hỏi và prompt được tách khỏi logic xử lý.
- Ba mini game dùng cùng bộ bài Tây nhưng có luật và ý nghĩa khác nhau.
- AI được gọi qua proxy để tránh hardcode API key trong game.
- AI trả JSON để game dễ đọc và hiển thị.
- Game có flow đầy đủ từ title đến final report.

---

## 13. Kiểm soát rủi ro

### Scope

Dự án giữ phạm vi nhỏ:

- chỉ dùng 22 lá Major Arcana,
- chỉ có ba không gian Quá khứ / Hiện tại / Tương lai,
- mỗi không gian có một mini game,
- ưu tiên playable demo.

---

## 14. Tiêu chí hoàn thành demo

Dự án đạt mức demo khi:

- game chạy được từ đầu đến cuối,
- title screen hoạt động,
- onboarding questions hoạt động,
- chọn được ba lá tarot không trùng,
- có ba không gian nội tâm,
- có câu hỏi lựa chọn và câu hỏi tự do,
- ba mini game chạy được,
- Mảnh Hồn được ghi nhận,
- AI interpretation và final report hoạt động,
- UI đọc được và dùng ổn định trên desktop,
- API key không nằm trong Godot project.

