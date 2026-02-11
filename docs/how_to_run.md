# How to Run and Build APK (Complete Prototype)

This repository includes a **playable Godot prototype** and a **one-command build script** for Android APK export.

## Included playable project
- `godot_app/project.godot`
- `godot_app/scenes/main.tscn`
- `godot_app/scripts/game_state.gd`
- `godot_app/scripts/main.gd`

## One-command APK build script
- `scripts/build_android.sh`

---

## Quick start (desktop test)
1. Install Godot 4.2+.
2. Import `godot_app/project.godot` in Godot.
3. Press **Play** and verify:
   - resource ticks
   - building upgrades
   - dragon hunt / egg hatching
   - PvE/PvP actions

---

## Install Godot CLI quickly (if missing)
If `godot4` is not found, use the helper installer script (downloads official Linux binary):

```bash
./scripts/install_godot4.sh
```

Then ensure `~/.local/bin` is on PATH (or pass `--dest` when installing).

---

## One-time Android setup (Godot editor)
You only do this once on your machine:

1. **Editor > Manage Export Templates** → install templates matching your Godot version.
2. **Editor Settings > Export > Android**:
   - set `adb`
   - set `jarsigner`
   - set debug keystore (or default)
3. **Project > Export...**:
   - Add preset: **Android**
   - Keep preset name exactly: `Android`
   - Save (this generates `godot_app/export_presets.cfg`)

---

## Build APK with one command
From repo root:

```bash
./scripts/build_android.sh
```

Default output:
- `build/EpochOfEmbersPrototype-debug.apk`

### Release build
```bash
./scripts/build_android.sh --release
```

### Custom output path
```bash
./scripts/build_android.sh --output build/MyCustomName.apk
```

---

## Install APK on Android
If `adb` is installed:

```bash
adb install -r build/EpochOfEmbersPrototype-debug.apk
```

Or copy the APK to your device and install manually.

---

## Gameplay controls in current build
- **Upgrade Town Hall/Farm/Mine**: spend resources and start timed upgrade.
- **Dragon Hunt**: chance to get egg; eggs hatch over time.
- **Run PvE**: progression fight simulation.
- **Run PvP Raid**: raid simulation with loot/loss.
- **Story Choice: Order/Freedom**: changes morality axis.
- **Save Progress**: writes local save to device storage.

---

## Troubleshooting
- **`ERROR: Missing export_presets.cfg`**:
  - Open Godot → Project > Export... → add Android preset named `Android`.
- **`Godot CLI not found`**:
  - Install Godot and ensure `godot4` (or `godot`) is in PATH.
- **APK installs but won’t open**:
  - Rebuild with only `arm64-v8a` enabled in Android preset.
- **Keystore/signing issues**:
  - Start with debug build; configure release signing later.

---

## Legacy starter scripts
`starter/unity` and `starter/godot` contain reference snippets. The runnable APK target is `godot_app/`.
