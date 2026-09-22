# AUDIO LICENSE & ATTRIBUTION

> [!WARNING]
> **TRẠNG THÁI: CHƯA XÁC MINH (UNVERIFIED) - BLOCKER ĐỐI VỚI RELEASE PRODUCTION**
> Gói âm thanh này hiện không có tài liệu bản quyền hợp lệ, giấy phép thương mại hoặc thông tin attribution chính thức từ tác giả.
> - **Chỉ sử dụng để tích hợp môi trường nội bộ / local testing.**
> - **Tuyệt đối không đánh dấu là Production-Ready về mặt pháp lý.**
> - **Không merge các asset âm thanh này vào release branch** cho đến khi có văn bản ủy quyền / bản quyền rõ ràng.

---

## 1. Thông tin Gói Âm thanh (Audio Pack Information)
- **Tên pack:** Hào Kiệt Đại Việt Audio Pack (`hao_kiet_dai_viet_audio_pack`)
- **Nguồn cung cấp:** Tải về cục bộ từ môi trường phát triển (`D:\UserData\Applications\Downloads\hao_kiet_dai_viet_audio_pack\hao_kiet_dai_viet_audio_pack`)
- **Người sở hữu:** Chưa xác định (Không có metadata tác giả hoặc chứng nhận bản quyền trong source)
- **Quyền sử dụng thương mại:** **CHƯA XÁC MINH (UNVERIFIED)**
- **Quyền chỉnh sửa / phân phối:** **CHƯA XÁC MINH (UNVERIFIED)**
- **Ngày xác minh:** 2026-09-22

---

## 2. Quy định Quản lý Tài sản (Asset Handling Rules)
1. **Runtime Bundle:** Chỉ đóng gói các tệp định dạng nén `.ogg` đã tối ưu cho web/mobile vào thư mục `assets/audio/`.
2. **Master Storage:** Các tệp `.wav` chất lượng cao (PCM 44.1kHz 16-bit) được lưu trữ riêng ngoài bundle Flutter tại `audio_source/master/` để tránh phình dung lượng app. Không commit `.wav` vào git khi chưa sử dụng Git LFS.
3. **Tránh ô nhiễm cấu trúc:** Không lưu trữ manifest thô hoặc thư mục wrapper lặp trong `assets/`.
4. **Hành động cần thực hiện:** Liên hệ nhà cung cấp / tác giả để xin giấy phép bản quyền (hoặc thay thế bằng bộ asset có license Creative Commons / commercial license hợp lệ trước khi phát hành phiên bản công khai).
