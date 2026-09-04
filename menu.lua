local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/kianalovells2004-eng/esp/refs/heads/main/esp.lua"))()

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
