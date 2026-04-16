# SpendSense

Flutter lab project for tracking and categorizing spend events.

## Quick start

1. Install Flutter and Android SDK.
2. Connect your Android phone by USB and enable USB debugging.
3. From the project root:

```bash
flutter pub get
```

## Run on a real Android phone (USB) with local API

If your backend API is running on your laptop at port `8000`, use ADB reverse so the phone can reach it as `127.0.0.1:8000`:

```bash
adb reverse tcp:8000 tcp:8000
```

Then run:

```bash
flutter run --dart-define=SPENDSENSE_API_BASE_URL=http://127.0.0.1:8000
```

## Run with API on LAN

If your API is hosted on a LAN IP, pass that IP:

```bash
flutter run --dart-define=SPENDSENSE_API_BASE_URL=http://<YOUR_LAN_IP>:8000
```

## Notes

- `SPENDSENSE_API_BASE_URL` defaults to `http://127.0.0.1:8000` when not provided.
- Android cleartext HTTP is enabled in debug builds for local/lab testing.
- API endpoint expected by app: `POST /transaction`.
