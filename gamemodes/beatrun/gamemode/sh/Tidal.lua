if SERVER then return end
chat.AddText(Color(0,200,255), "[Beatrun] Tidal.lua loaded on client!")

local success, _ = pcall(require, "gwsockets")
if not success or not GWSockets then
    chat.AddText(Color(255,0,0), "[Beatrun] gwsockets module not found or failed to load!")
    return
end

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

net.Receive("BeatrunSpawn", function()
    chat.AddText(Color(0,200,255), "[Beatrun] Respawn detected!.")
        local msg = util.TableToJSON({ action = "seek", time = 0 })
        socket:write(msg)
end)