--[[
============================================================
  YimMenuV2 Lua Test Script
============================================================
  Available APIs:
  - natives.load_natives()
  - script.run_in_callback(func)
  - script.yield(ms)
  - script.register_event_handler(name, func)
  - notify.success/info/warn/error(title, msg)
  - util.joaat("string")
  - print("text")
  - All GTA Native functions (after natives.load_natives()):
    PLAYER.PLAYER_PED_ID()
    ENTITY.GET_ENTITY_COORDS()
    ENTITY.SET_ENTITY_COORDS()
    PED.IS_PED_IN_ANY_VEHICLE()
============================================================
  NOTE: YimMenuV2 Lua does NOT support custom ImGui windows.
  Interaction is via notify and print only.
============================================================
]]

-- 1. Load GTA Native functions (MUST be first)
natives.load_natives()

-- 2. Global variables
local is_running = false
local frame_count = 0
local LOG_INTERVAL = 150  -- print every ~150 frames (~2.5 seconds at 60fps)

-- 3. Main fiber callback
script.run_in_callback(function()
    is_running = true
    notify.info("Test Script", "Lua script started! Check console output.")

    while is_running do
        local player_ped = PLAYER.PLAYER_PED_ID()
        frame_count = frame_count + 1

        if player_ped ~= 0 then
            local pos = ENTITY.GET_ENTITY_COORDS(player_ped, false)
            local px, py, pz = pos:get_coords()
            local heading = ENTITY.GET_ENTITY_HEADING(player_ped)
            local health = ENTITY.GET_ENTITY_HEALTH(player_ped)
            local max_health = ENTITY.GET_ENTITY_MAX_HEALTH(player_ped)
            local in_vehicle = PED.IS_PED_IN_ANY_VEHICLE(player_ped, false)

            -- === First run: print full player info ===
            if not _G._first_run_done then
                print("=== Player Info ===")
                print(string.format("Position: X=%.2f, Y=%.2f, Z=%.2f", px, py, pz))
                print(string.format("Heading: %.2f", heading))
                print(string.format("Health: %d/%d", health, max_health))
                print(string.format("In Vehicle: %s", tostring(in_vehicle)))

                if in_vehicle then
                    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
                    local speed = ENTITY.GET_ENTITY_SPEED(vehicle) * 3.6
                    print(string.format("Speed: %.1f km/h", speed))
                end

                print("===================")
                print("[Test.lua] Console will auto-update every ~2.5 seconds.")
                _G._first_run_done = true
            end

            -- === Periodic log: every ~2.5 seconds ===
            if frame_count % LOG_INTERVAL == 0 then
                local speed_str = ""
                if in_vehicle then
                    local vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, false)
                    local speed = ENTITY.GET_ENTITY_SPEED(vehicle) * 3.6
                    speed_str = string.format(" | Speed: %.1f km/h", speed)
                end

                print(string.format("[Status] Frame:%d HP:%d/%d Pos:(%.1f, %.1f, %.1f) Hdg:%.1f Veh:%s%s",
                    frame_count,
                    health, max_health,
                    px, py, pz,
                    heading,
                    tostring(in_vehicle),
                    speed_str))
            end
        else
            -- Player ped not available (e.g. loading screen)
            if frame_count % LOG_INTERVAL == 0 then
                print("[Test.lua] Waiting for player ped... (frame " .. frame_count .. ")")
            end
        end

        script.yield(0)
    end
end)

-- 4. Unload handler
function OnUnload()
    is_running = false
    _G._first_run_done = nil
    notify.info("Test Script", "Lua script unloaded.")
    print("[Test.lua] Script unloaded.")
end

-- 5. Register events
script.register_event_handler("unload", OnUnload)

-- Print startup message
print("[Test.lua] Loaded successfully!")
notify.info("Test Script", "Lua test script loaded. Check console for player info.")
