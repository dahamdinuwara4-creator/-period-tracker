# Period Tracker

Simple, private period tracker. All data stays on the device (no server).

- `docs/index.html` - single-file web version (Sinhala / English). Open it in a browser, or host it
  (GitHub Pages: Settings > Pages > deploy from branch main, folder `/docs`). On iPhone: Safari > Share > Add to Home Screen.
  It shows predicted dates only. A web page cannot send notifications while closed.
- `flutter_app/` - Flutter source (Android + iOS) that schedules local notifications.
  Not yet built or tested on a device.

## Run the Flutter app
```
cd flutter_app
flutter create .          # generates android/ and ios/ folders
git checkout lib/main.dart pubspec.yaml   # restore ours if flutter create replaced them
flutter pub get
flutter run
```
Android extra setup: enable core library desugaring in `android/app/build.gradle`, and add
`POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED` permissions plus the boot receiver from the
`flutter_local_notifications` docs to `AndroidManifest.xml`. iOS builds need a Mac with Xcode.

## Known limits
- Predictions are estimates, not medical advice.
- iOS needs a Mac + Apple developer account to publish.

## Build the iPhone app without a Mac (Codemagic)
1. Push this repo to GitHub.
2. Get an Apple Developer account, register a bundle id (e.g. `com.yourname.periodtracker`), and create the app in App Store Connect.
3. In Codemagic: add the repo, add an App Store Connect API key (Teams > Integrations), then edit the two values marked `CHANGE` in `codemagic.yaml` to match.
4. Start the `iOS TestFlight` workflow. When it finishes, the build appears in TestFlight; invite your friend by email and she installs it through the TestFlight app.

The app is untested on a real device: expect to fix small build errors on the first run.
