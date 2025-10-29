# CheryClose

CheryClose is a WhatsApp-first Android sales enablement app for South African Chery salespeople. The repository contains:

- `docs/PRD.md` — the full product requirements and technical specification.
- `cheryclose_app/` — a Flutter project implementing the MVP experience with lead capture, follow-ups, finance calculator, sharing tools, poster builder, analytics, and settings.

## Getting started

1. Install Flutter (3.13 or newer recommended) and Android Studio / command-line tools.
2. From the repository root, run `cd cheryclose_app`.
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Launch the Android app on an emulator or device:
   ```bash
   flutter run
   ```

   The Android Gradle wrapper JAR is fetched automatically the first time the
   build runs. Ensure `curl` (macOS/Linux) or PowerShell/curl (Windows) is
   available so the download can succeed.

## Project structure

Key Flutter directories:

- `lib/` — application source organised by feature (share, leads, calculator, poster, library, analytics, settings) plus core theming and data models.
- `assets/` — seed content for models, captions, follow-up plans, objection replies, and templates.
- `android/` — Gradle project configuration for building the Android APK.
- `test/` — placeholder for widget and integration tests.

## Feature highlights

- **Share hub** — browse models, personalise captions, and share via Android Sharesheet.
- **Lead manager** — POPIA-compliant lead capture with consent gate, follow-up assignments, and stage tracking.
- **Finance calculator** — South Africa-friendly finance formula with running-cost comparison and one-tap share.
- **QR poster builder** — exports 1080×1920 PNG posters with QR codes linking to your WhatsApp number.
- **Library** — searchable model sheets, objection replies, and message templates.
- **Analytics dashboard** — quick snapshot of captured leads, follow-ups, test drives, and deals.
- **Settings** — configure salesperson identity, WhatsApp number, and default interest rate.

For more product context refer to the [PRD](docs/PRD.md).
