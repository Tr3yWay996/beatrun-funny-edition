if SERVER then return end
chat.AddText(Color(0,200,255), "[Beatrun] Tidal.lua loaded on client!")

local success, _ = pcall(require, "gwsockets")
if not success or not GWSockets then
    chat.AddText(Color(255,0,0), "[Beatrun] gwsockets module not found or failed to load!")
    return
end
local RespawnRewinding = "courses" -- "never", "yeah" or "courses"
local socket = GWSockets.createWebSocket("ws://localhost:24123/")
socket:open()

function socket:onConnected()
    chat.AddText(Color(0,255,0), "[Beatrun] Connected to TIDAL API WebSocket!")
end

function socket:onError(txt)
    chat.AddText(Color(255,0,0), "[Beatrun] TIDAL WebSocket error: ", txt)
end

function socket:onDisconnected()
    chat.AddText(Color(255,150,0), "[Beatrun] Disconnected from TIDAL API WebSocket!")
end

concommand.Add("beatrun_tidal-rewind", function()
    if socket and socket:isConnected() then
        local msg = util.TableToJSON({ action = "seek", time = 0 })
        socket:write(msg)
        chat.AddText(Color(0,200,255), "[Beatrun] Sent rewind command to TIDAL API.")
    else
        chat.AddText(Color(255,0,0), "[Beatrun] TIDAL WebSocket not connected.")
    end
end)

concommand.Add("beatrun_tidal-pause", function()
    if socket and socket:isConnected() then
        local msg = util.TableToJSON({ action = "pause" })
        socket:write(msg)
        chat.AddText(Color(0,200,255), "[Beatrun] Sent pause command to TIDAL API.")
    else
        chat.AddText(Color(255,0,0), "[Beatrun] TIDAL WebSocket not connected.")
    end
end)

concommand.Add("beatrun_tidal-resume", function()
    if socket and socket:isConnected() then
        local msg = util.TableToJSON({ action = "resume" })
        socket:write(msg)
        chat.AddText(Color(0,200,255), "[Beatrun] Sent resume command to TIDAL API.")
    else
        chat.AddText(Color(255,0,0), "[Beatrun] TIDAL WebSocket not connected.")
    end
end)

concommand.Add("beatrun_tidal-toggle", function()
    if socket and socket:isConnected() then
        local msg = util.TableToJSON({ action = "toggle" })
        socket:write(msg)
        chat.AddText(Color(0,200,255), "[Beatrun] Sent toggle command to TIDAL API.")
    else
        chat.AddText(Color(255,0,0), "[Beatrun] TIDAL WebSocket not connected.")
    end
end)

local function TidalAutoComplete(cmd, args, ...)
    local possibleArgs = { ... }
    local autoCompletes = {}

    local arg = string.Split(args:TrimLeft(), " ")
    local lastItem = nil
    for i, str in pairs(arg) do
        if (str == "" and (lastItem and lastItem == "")) then table.remove(arg, i) end
        lastItem = str
    end

    local numArgs = #arg
    local lastArg = table.remove(arg, numArgs)
    local prevArgs = table.concat(arg, " ")
    if (#prevArgs > 0) then prevArgs = " " .. prevArgs end

    local possibilities = possibleArgs[numArgs] or { lastArg }
    for _, acStr in pairs(possibilities) do
        if (not acStr:StartsWith(lastArg)) then continue end
        table.insert(autoCompletes, cmd .. prevArgs .. " " .. acStr)
    end

    return autoCompletes
end

concommand.Add("beatrun_rw_tgl", function(ply, cmd, args)
    local a = args[1] and args[1]:lower() or nil
    if a == "yeah" or a == "on" or a == "enable" then
        RespawnRewinding = "yeah"
    elseif a == "never" or a == "off" or a == "disable" then
        RespawnRewinding = "never"
    elseif a == "courses" then
        RespawnRewinding = "courses"
    else
        -- cycle order: never -> yeah -> courses -> never
        if RespawnRewinding == "never" then
            RespawnRewinding = "yeah"
        elseif RespawnRewinding == "yeah" then
            RespawnRewinding = "courses"
        else
            RespawnRewinding = "never"
        end
    end
    chat.AddText(Color(0,200,255), "[Beatrun] TIDAL respawn seek mode: " .. RespawnRewinding)
end, function(cmd, args)
    return TidalAutoComplete(cmd, args, { "yeah", "never", "courses" })
end)

hook.Add("BeatrunSpawn", "TidalRespawnSeek", function(spawntime, replay)
    -- Determine if currently inside a course
    local inCourse = (Course_Name and Course_Name ~= "") or false

    if RespawnRewinding == "never" then return end
    if RespawnRewinding == "courses" and not inCourse then return end

    local msg = util.TableToJSON({ action = "seek", time = 0 })
    socket:write(msg)
    chat.AddText(Color(0,200,255), "[Beatrun] Respawn detected (mode: " .. RespawnRewinding .. ").")
end)

hook.Add("BeatrunHUDCourse", "BeatrunHUDCourse", function(spawntime, replay)
    InCourse = not (not Course_Name or Course_Name == "")
end)

concommand.Add("debug-RespawnRewind", function()
    print(RespawnRewinding)
end)
concommand.Add("debug-InCourse", function()
    print(InCourse)
end)