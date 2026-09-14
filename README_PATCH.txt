# v0.2.2 CI Fix Patch

Replace these files in the GitHub repository:
- scripts/main.gd
- scripts/npc.gd
- scripts/player.gd
- export_presets.cfg

Fixes:
- Godot 4.3 Variant/type inference parse errors
- constant-expression error in FACE_DIRS
- explicit float/int/String typing for warnings-as-errors CI
- Android version 0.2.2 / version code 22
- signed debug APK enabled
