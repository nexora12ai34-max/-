# همراز | Hamraz Messenger 1.0.0

یک monorepo عملی برای پیام‌رسان اجتماعی با هسته‌ی چت، گروه، کانال، استوری، جستجو، فایل، واکنش، اعلان، AI، Wallet/Premium، Mini App و پنل مدیریت.

## سریع‌ترین اجرا در ویندوز

1. پوشه پروژه را در VS Code باز کن.
2. روی `RUN_HAMRAZ.bat` دوبار کلیک کن، یا در PowerShell این را اجرا کن:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\HAMRAZ_ONE_CLICK_BUILD.ps1 -Target Menu
```

از منو اول `1 Doctor` و بعد `2 Install / prepare tools` را اجرا کن. برای ساخت Web از `4`، برای Windows از `5` و برای Android از `6` استفاده کن. برای Android release باید `-ApiUrl https://...` بدهی.

## اجرای کامل سرور/وب با Docker

```bash
docker compose up --build
```

Web: http://localhost:5173

Installable PWA: the web client includes a manifest and offline shell.  
API: http://localhost:8000  
Docs: http://localhost:8000/docs

## حالت بدون Docker

Backend:

```bash
cd backend
python -m venv .venv
# ویندوز: .venv\\Scripts\\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

Frontend:

```bash
cd frontend
npm install
npm run dev
```

## اجزای فعلی

- JWT Authentication (short-lived access + revocable refresh sessions)
- OTP-ready account recovery, session management and security audit log
- پروفایل کاربر و جستجو
- چت خصوصی و گروهی
- WebSocket real-time
- Reply / Edit / Delete / Reaction / Read
- آپلود فایل تا 50MB در حالت local
- Channels + posts + subscribe
- Stories + views
- Global search روی user/chat/message
- Notifications + device management
- AI provider-neutral endpoint با fallback محلی
- Wallet / Premium / Mini Apps data model
- Admin stats / reports
- PostgreSQL برای deployment و SQLite برای توسعه سریع

## وضعیت release

کد و لایه‌های اصلی همراز شامل realtime، sync، event bus، storage/CDN hooks، Search Core، WebRTC signaling، Push registration، AI Core، Bots/Mini Apps، Economy و Admin Control Plane است و روی آن hardening و release gates اجرا شده است. **این snapshot هنوز Release Ready اعلام نمی‌شود** تا سه package-lock واقعی تولید شوند و build/runtime/integration evidence واقعی برای Android، Windows و backend در محیط دارای toolchain ثبت شود. برای deployment واقعی نیز credential و زیرساخت‌هایی مثل FCM/APNs، TURN/SFU، domain/TLS، object storage/CDN و درگاه پرداخت باید واقعاً پیکربندی و تست شوند.

## Part 1/15

This iteration hardens the HTTP/WebSocket edge, adds health/readiness checks, corrects Docker Compose health dependencies, switches product identity to همراز, and adds the initial Flutter mobile client foundation.


## Part 2/15
Authentication was hardened with short-lived access tokens, hashed refresh sessions, device/session revocation, OTP-ready recovery, account security audit, rate limiting and automatic Web refresh.


## Self-hosted deployment

Part 10 adds a self-hosted deployment topology in `docker-compose.selfhosted.yml`. It keeps the API, WebSocket, PostgreSQL, Redis, MinIO and web edge under your control. Search defaults to the embedded Hamraz Search Core, so OpenSearch is not required.

For a production deployment, set a real domain, strong secrets and TLS/DNS configuration in the environment before exposing the edge publicly.
