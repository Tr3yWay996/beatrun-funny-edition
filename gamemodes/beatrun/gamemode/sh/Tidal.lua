if SERVER then return end
chat.AddText(Color(0,200,255), "[Beatrun] Tidal.lua loaded on client!")

local success, _ = pcall(require, "gwsockets")
if not success or not GWSockets then
    chat.AddText(Color(255,0,0), "[Beatrun] gwsockets module not found or failed to load!")
    return
end
local tidalRespawnEnabled = false -- This is on by default, can be toggled via console command
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

local function TidalAutoComplete( cmd, args, ... )
	local possibleArgs = { ... }
	local autoCompletes = {}

	--TODO: Handle "test test" "test test" type arguments
	local arg = string.Split( args:TrimLeft(), " " )

	local lastItem = nil
	for i, str in pairs( arg ) do
		if ( str == "" && ( lastItem && lastItem == "" ) ) then table.remove( arg, i ) end
		lastItem = str
	end -- Remove empty entries. Can this be done better?

	local numArgs = #arg
	local lastArg = table.remove( arg, numArgs )
	local prevArgs = table.concat( arg, " " )
	if ( #prevArgs > 0 ) then prevArgs = " " .. prevArgs end

	local possibilities = possibleArgs[ numArgs ] or { lastArg }
	for _, acStr in pairs( possibilities ) do
		if ( !acStr:StartsWith( lastArg ) ) then continue end
		table.insert( autoCompletes, cmd .. prevArgs .. " " .. acStr )
	end
		
	return autoCompletes
end

concommand.Add("beatrun_tidal_respawn_toggle", function(ply, cmd, args)
    if args[1] == "enabled" then
        tidalRespawnEnabled = true
    elseif args[1] == "disabled" then
        tidalRespawnEnabled = false
    else
        tidalRespawnEnabled = not tidalRespawnEnabled
    end
    chat.AddText(Color(0,200,255), "[Beatrun] TIDAL respawn seek is now " .. (tidalRespawnEnabled and "ENABLED" or "DISABLED"))
end, function(cmd, args)
    return TidalAutoComplete(cmd, args, { "enabled", "disabled" })
end)

hook.Add("BeatrunSpawn", "TidalRespawnSeek", function(spawntime, replay)
    if tidalRespawnEnabled then
        chat.AddText(Color(0,200,255), "[Beatrun] Respawn detected!.")
        local msg = util.TableToJSON({ action = "seek", time = 0 })
        socket:write(msg)
    end
end)