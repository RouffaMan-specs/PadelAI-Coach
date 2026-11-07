# Padel AI Coach — iPhone MVP (GitHub cloud-build edition)

This is a native SwiftUI/Xcode starter project. You can trigger an unsigned iOS build from GitHub without owning a Mac or entering a credit card.

## 1. Create a GitHub repository (Windows or iPhone)
1. Create a free account at https://github.com/signup.
2. Create a new repository named `PadelAICoach`.
3. For the simplest setup, choose **Public**. Public repositories can use GitHub-hosted standard runners without consuming the private-repository free-minute allowance. If you choose Private, check current Actions minutes and storage limits first.
4. Extract this ZIP on Windows.
5. Upload the extracted project contents (including the hidden `.github` folder) to the repository. The easiest route is GitHub's web interface: **Add file → Upload files**. Make sure `.github/workflows/ios-build.yml` is included.

Do not commit Apple passwords, certificates, API keys, or private video footage. This source repository contains no credentials.

## 2. Run the cloud build
1. Open the repository on GitHub.
2. Select **Actions**.
3. Select **Build Padel AI Coach (unsigned iOS app)**.
4. Click **Run workflow**.
5. Wait for the job to finish. If it fails, open the failed step and copy the error text for troubleshooting.
6. Under **Artifacts**, download `PadelAICoach-unsigned-IPA`. GitHub packages it as a ZIP; extract it to obtain `PadelAICoach-unsigned.ipa`.

The workflow uses a GitHub-hosted macOS runner and Xcode. The IPA is intentionally unsigned; it is not directly installable yet.

## 3. Sign and install from Windows
1. Download Sideloadly from its official site: https://sideloadly.io/
2. Connect your iPhone to Windows by USB, unlock it, and tap **Trust This Computer** if prompted.
3. Open Sideloadly, select your iPhone, and drag `PadelAICoach-unsigned.ipa` into the IPA field.
4. Enter your Apple Account when prompted. Use only the official Sideloadly app and never share your Apple password with anyone. If two-factor authentication is enabled, follow the on-screen Apple verification flow.
5. Start sideloading and follow any prompts on the iPhone.
6. On the iPhone, if required, enable Developer Mode (Settings → Privacy & Security → Developer Mode) and trust the developer profile (Settings → General → VPN & Device Management).
7. Launch Padel AI Coach.

Free Apple Account signing is temporary (typically 7 days). Re-sign/refresh the app before expiry. Free provisioning has Apple's own restrictions; consult current Apple documentation. No paid Apple Developer membership is included.

Official references:
- Apple account and free development: https://developer.apple.com/support/compare-memberships/
- GitHub Actions usage: https://docs.github.com/en/billing/managing-billing-for-your-products/managing-billing-for-github-actions/about-billing-for-github-actions
- Sideloadly: https://sideloadly.io/

## 4. MVP status and limitations
Included:
- SwiftUI iPhone app shell and recording/history tabs.
- Rear camera preview via AVFoundation.
- Manual match start/finish and manual rally clip capture.
- Local SwiftData match history.
- A placeholder interface for a future rally detector.

Not included / not yet validated:
- Automatic rally/break recognition (the current detector intentionally never ends a rally automatically).
- Rolling pre-buffer to preserve the first seconds of a rally.
- AI player tracking or team-only analysis.
- Cloud upload, coaching insights, or a backend.
- A verified build on a physical iPhone.

The app needs camera permission and must remain in the foreground while recording. Keep the phone powered and cool, mount it securely, and test in a safe practice session first.

## 5. Troubleshooting
- If the GitHub build fails, open **Actions → failed run → failed step**, then share the error log (remove any personal data).
- If Sideloadly reports a signing/provisioning error, share the exact error text, not your password or verification code.
- If the app installs but the camera does not start, check Settings → Padel AI Coach → Camera.
