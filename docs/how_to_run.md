# How to Run the Starter Project

This repository currently contains **design docs** and **starter gameplay scripts** (not a complete runnable game build yet).

## What exists today
- `docs/game_blueprint.md`: full game concept/design.
- `starter/unity/Scripts/*.cs`: Unity starter scripts.
- `starter/godot/scripts/*.gd`: Godot starter scripts.

---

## Option A: Run in Unity (recommended for this starter)

## 1) Install tools
- Unity Hub
- Unity Editor **2022.3 LTS** (or newer LTS)
- Android Build Support module (SDK/NDK + OpenJDK) if targeting Android

## 2) Create a Unity project
1. Open Unity Hub → **New Project**.
2. Template: **3D (Core)** (or URP if preferred).
3. Name: `EpochOfEmbers`.
4. Create project.

## 3) Copy starter scripts
Copy these files into your Unity project's `Assets/Scripts/` folder:
- `starter/unity/Scripts/GameLoopManager.cs`
- `starter/unity/Scripts/DragonBreedingSystem.cs`

## 4) Create a test scene
1. In Unity, create an empty GameObject named `GameSystems`.
2. Attach components:
   - `GameLoopManager`
   - `DragonBreedingSystem`
3. Press **Play**.
4. Open Console to see economy ticks and dragon hatch logs.

## 5) Quick manual test in Play Mode
- In Inspector, set `baseRareEggChance` to `1.0` for guaranteed egg generation.
- Add a temporary button or call from another script:
  ```csharp
  public class DevTrigger : MonoBehaviour
  {
      public DragonBreedingSystem dragonSystem;

      private void Start()
      {
          dragonSystem.TryGenerateEgg("cosmic");
      }
  }
  ```
- You should see "New egg acquired" then "Egg hatched" after duration.

## 6) Build for Android (optional)
1. File → Build Settings → Android → Switch Platform.
2. Player Settings:
   - Package name (e.g., `com.yourstudio.epochofembers`)
   - Minimum API level (recommend Android 8+)
3. Connect device or configure emulator.
4. Build and Run.

---

## Option B: Run in Godot 4

## 1) Install tools
- Godot **4.2+**
- Android export template (if targeting Android)

## 2) Create a Godot project
1. New Project → `EpochOfEmbersGodot`.
2. Renderer: Forward+ or Mobile.

## 3) Copy starter scripts
Copy into your Godot project, for example:
- `res://scripts/game_loop_manager.gd`
- `res://scripts/dragon_system.gd`

## 4) Wire a test scene
1. Create a scene with root `Node` named `GameSystems`.
2. Add two child Nodes:
   - `GameLoop`
   - `DragonSystem`
3. Attach:
   - `game_loop_manager.gd` to `GameLoop`
   - `dragon_system.gd` to `DragonSystem`
4. Add a temporary driver script to root:
   ```gdscript
   extends Node

   @onready var dragon_system: DragonSystem = $DragonSystem

   func _ready() -> void:
       dragon_system.base_rare_egg_chance = 1.0
       dragon_system.try_generate_egg("cosmic")
   ```
5. Run scene and check Output panel for tick/hatching logs.

## 5) Export Android (optional)
1. Project → Install Android Build Template.
2. Editor Settings → Android SDK path.
3. Project → Export → Add Android preset.
4. Export APK/AAB.

---

## Firebase setup note
Firebase is described in the blueprint but **not yet integrated** in code. For next step implementation:
1. Create Firebase project.
2. Add Android app + `google-services.json`.
3. Integrate Auth + Firestore first.
4. Move economy writes and battle resolution to backend-authoritative Cloud Functions.

---

## Current limitation
This repo is a **starter foundation**, not full gameplay content. You can run/test the scripts above, then expand into:
- building placement
- combat scenes
- account services
- UI and data persistence

