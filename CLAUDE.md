# Folkify Flutter

App học nhạc cụ dân tộc Việt Nam — Flutter mobile app, deploy CH Play + App Store.

## Nguồn gốc

Port từ web app React tại `~/Desktop/Desktop - Nhật's MacBook Pro/Mobile app for learning instruments`.
Hội thoại thiết kế ban đầu nằm trong project đó (working dir của web app).

## Stack

- Flutter 3.44 / Dart 3.12
- State: **flutter_riverpod** (`lib/core/providers/`)
- Navigation: **go_router** (`lib/core/router/app_router.dart`) — có auth redirect guard
- Theme: Material 3 dark, màu chủ đạo amber `#D97706`, font Be Vietnam Pro
- HTTP: **dio** — chưa dùng, chuẩn bị cho Spring Boot API
- Auth: mock bằng `SharedPreferences` (chưa có backend)

## Cấu trúc nhanh

```
lib/core/           → constants, providers, router, theme, widgets
lib/features/
  auth/             → login, register, forgot_password
  home/             → home_screen
  learn/            → instruments_data, instrument_detail (3 tabs), lesson_detail
  practice/         → metronome + tuner placeholder
  sheets/           → bản nhạc + search/filter
  premium/          → plans (Basic 49k, Pro 99k VND)
  profile/          → stats, badges, menu, logout
```

## Việc tiếp theo

- [ ] Cài Android Studio → build Android
- [ ] Tạo Spring Boot backend + PostgreSQL
- [ ] Thay mock auth (`auth_provider.dart`) bằng Dio API call thực
- [ ] App icon + splash screen (`flutter_launcher_icons`, `flutter_native_splash`)
- [ ] Signing cho store (Apple Developer + Google Play Console)
