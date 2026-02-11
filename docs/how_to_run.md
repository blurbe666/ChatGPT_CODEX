# Run & Test Completely Online (No Software Install on Your PC)

Yes — you can run and test this project online without installing Godot, Android Studio, or SDK tools locally.

This repo now supports a cloud workflow using **GitHub Actions**:
- Web build (play in browser via GitHub Pages)
- Android APK build artifact (download and install on your phone)

---

## What was added for online testing
- `godot_app/export_presets.cfg` with `Web` and `Android` export presets.
- `.github/workflows/online-build-and-test.yml` cloud pipeline.
- `scripts/build_web.sh` helper for local/CI web export parity.

---

## Zero-install method (GitHub web UI only)

## Step 1: Push this repo to GitHub
If your code is already on GitHub, skip this.

## Step 2: Enable GitHub Pages
1. Open your GitHub repo.
2. Go to **Settings → Pages**.
3. Under Build and deployment, set **Source = GitHub Actions**.

## Step 3: Trigger cloud build
1. Go to **Actions** tab.
2. Open workflow: **Online Build & Test (No Local Install)**.
3. Click **Run workflow**.

This runs three jobs:
1. **web-build**: exports HTML5 build.
2. **deploy-pages**: deploys web build to GitHub Pages.
3. **android-apk-build**: attempts APK export and uploads APK artifact.

---

## Test in browser (fully online)
After workflow succeeds:
1. Open Actions run summary.
2. In `deploy-pages` job, open the published URL.
3. Play directly in browser (desktop/mobile browser supported).

---

## Get APK without local build tools
After workflow succeeds:
1. Open same Actions run.
2. Download artifact named **android-apk**.
3. Copy APK to Android device.
4. Install APK (allow unknown sources if prompted).

---

## If Android artifact fails
`android-apk-build` is marked `continue-on-error` so web deployment still works.

Most common fix:
- Ensure repo contains a valid Android export preset in `godot_app/export_presets.cfg` (already included).
- Re-run workflow after adjusting package/signing fields for your org if required.

---

## Gameplay checks after launch
Use these controls to validate the prototype:
- Upgrade Town Hall/Farm/Mine
- Dragon Hunt + egg hatching
- PvE and PvP simulation
- Story choice (Order/Freedom)
- Save Progress

---

## Optional: command-line build if you ever want it
Even though not required, local scripts still exist:
- `./scripts/build_android.sh`
- `./scripts/build_web.sh`
- `./scripts/install_godot4.sh`
