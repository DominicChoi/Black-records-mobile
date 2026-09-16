# v0.2.5 — Mobile HUD & Minimap Polish

- Minimap enlarged and redrawn with road, river, village blocks and north-route landmarks.
- Added police station, north forest and mine entrance landmark markers.
- Quest-relevant landmarks pulse to guide the player without replacing exploration.
- NPC positions appear on the minimap; the currently interactable NPC is highlighted.
- Player marker is now a direction arrow based on actual movement.
- Virtual joystick now has a dead zone, progressive output, clearer active/inactive feedback and directional ticks.
- Interaction button dynamically changes between 조사 / 대화 / 입장 and is disabled when there is no nearby target.
- Added action hint text showing the nearby NPC name/role or police station.
- Top HUD now separates area name, chapter objective and clock/weather.
- Re-typed main.gd Variant-prone values to avoid reintroducing Godot 4.3 warnings-as-errors.
- Existing save key, scene names, NPC IDs and interaction flow remain unchanged.
