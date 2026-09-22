# AUDIO BACKLOG & RESERVED ASSETS

Tài liệu này ghi nhận danh sách các sound cues và âm thanh còn thiếu cần sản xuất/bổ sung trong các giai đoạn phát triển tiếp theo, cùng các assets đang ở trạng thái Reserved.

---

## 1. Asset Hiện tại ở trạng thái Reserved (Chưa kích hoạt)
Các asset đã có file `.ogg` trong runtime nhưng chưa được kích hoạt vì domain gameplay chưa có event/metadata tương ứng:
- `title_intro.ogg`: Nhạc intro mở màn/logo (hiện app mở thẳng vào `HomePage` / `GameShellPage`).
- `arrow_shot.ogg`: Âm thanh bắn cung (hiện `CombatEnemyDamaged` chưa có metadata `weaponType` hay `sourceHeroId`).
- `spear_hit.ogg`: Âm thanh đâm thương (hiện chưa có metadata vũ khí).
- `shield.ogg`: Âm thanh tạo khiên (chưa có kỹ năng/hiệu ứng shield application thật trong combat domain).

---

## 2. Danh sách Cues cần sản xuất thêm (Backlog)
Để tránh tái sử dụng sai ngữ nghĩa, các âm thanh sau được đưa vào backlog thiết kế:

### Match-3 Board:
- `swap_rejected`: Âm thanh khi nước đi không hợp lệ / không tạo ra match (hiện tạm dùng `tile_swap`).
- `tile_drop`: Tiếng rơi va chạm của ngọc khi rơi xuống theo trọng lực.
- `tile_spawn`: Tiếng ngọc mới xuất hiện trên đỉnh bàn cờ.
- `board_shuffle`: Tiếng xào lại bàn cờ khi không còn nước đi hợp lệ.
- `special_created`: Tiếng tạo ngọc đặc biệt (Bomb, Line horizontal, Line vertical, Rainbow).
- `special_triggered`: Tiếng nổ/kích hoạt ngọc đặc biệt theo từng loại.

### Combat & Skills:
- `water_cast`: Tiếng xuất chiêu hệ Thủy (hiện kỹ năng Thủy Trận Thủ dùng `heal.ogg`).
- `hero_hit`: Tiếng khi anh hùng bị quái tấn công (`CombatHeroDamaged`).
- `enemy_attack_variants`: Biến thể đòn đánh của quái (thể chất, phép thuật, độc tố).
- `boss_phase_change`: Tiếng biến hình / nộ khí khi Boss chuyển phase (`CombatBossPhaseChanged`).
- `wave_start`: Tiếng kèn lệnh hoặc hiệu ứng báo hiệu wave mới (`CombatWaveStarted`).

### Kinh tế & Phần thưởng:
- `reward_claim`: Tiếng nhận phần thưởng sau trận.
- `chest_open`: Tiếng mở rương báu.
- `currency_collect`: Tiếng nhặt vàng / ngọc / nguyên liệu.

### Giao diện người dùng (UI):
- `ui_back`: Tiếng quay lại / đóng popup.
- `ui_confirm`: Tiếng xác nhận mua hàng / nâng cấp.
- `ui_error`: Tiếng báo lỗi khi không đủ tài nguyên.

### Lồng tiếng (Voice):
- Voice cues cho 4 danh tướng (câu thoại ra trận, xuất chiêu đặc biệt, chiến thắng, tử trận).
