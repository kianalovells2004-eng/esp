local url = "https://raw.githubusercontent.com/kianalovells2004-source/Uni/refs/heads/main/esp.lua"
local success, result = pcall(game.HttpGet, game, url)

if not success or not result then
    error("HTTP Fetch Failed: Check your URL or internet connection.")
end

local espModule, syntaxError = loadstring(result)
if not espModule then
    error("Lua Syntax Error in esp.lua: " .. tostring(syntaxError))
end

local ESP = espModule()
local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)("Pepsi's UI Library")
local window = library:CreateWindow({ Name = "ESP Hub" })
local espTab = window:CreateTab({ Name = "ESP" })
local section = espTab:CreateSection({ Name = "Visuals", Side = "Left" })

section:AddToggle({
    Name = "Box ESP",
    Value = false,
    Flag = "BoxESP",
    Callback = function(value)
        ESP:ToggleBox(value)
    end
})

section:AddToggle({
    Name = "Corner Box ESP",
    Value = false,
    Flag = "CornerBoxESP",
    Callback = function(value)
        ESP:ToggleCornerBox(value)
    end
})

section:AddToggle({
    Name = "3D Box ESP",
    Value = false,
    Flag = "ThreeDBoxESP",
    Callback = function(value)
        ESP:Toggle3DBox(value)
    end
})
