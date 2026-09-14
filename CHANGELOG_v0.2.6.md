# v0.2.6 — NPC Routine & Dialogue Pass

Priority 4 progress: NPC dialogue and daily-life routines.

- Han Sang-cheol now changes location by time and moves toward the north road after ~21:42 when the follow route is unlocked.
- Jung Woo-jin shifts between reporting, police-station observation, and north-road lookout positions.
- Jang Do-sik moves between the management hut, equipment area, and old mine access road.
- Dialogue now responds to quest state and previously-met characters rather than only time.
- The mobile action hint shows the nearby NPC's current activity (e.g. “북쪽 길 감시”).
- Preserved NPC IDs, scene node names, save flags, and existing `get_dialogue(time)` compatibility through default parameters.
- Re-typed NPC math/loop variables for Godot 4.3 warning-as-error compatibility.
