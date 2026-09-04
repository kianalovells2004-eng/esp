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
    Name = "Name ESP",
    Value = false,
    Flag = "NameESP",
    Callback = function(value)
        ESP:ToggleName(value)
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

section:AddToggle({
    Name = "Local Player Tracer",
    Value = false,
    Flag = "TracerLocal",
    Callback = function(value)
        ESP:ToggleTracerLocal(value)
    end
})

section:AddToggle({
    Name = "Mouse Tracer",
    Value = false,
    Flag = "TracerMouse",
    Callback = function(value)
        ESP:ToggleTracerMouse(value)
    end
})

section:AddToggle({
    Name = "Top Tracer",
    Value = false,
    Flag = "TracerTop",
    Callback = function(value)
        ESP:ToggleTracerTop(value)
    end
})

section:AddToggle({
    Name = "Bottom Tracer",
    Value = false,
    Flag = "TracerBottom",
    Callback = function(value)
        ESP:ToggleTracerBottom(value)
    end
})

section:AddToggle({
    Name = "2D Box Fill",
    Value = false,
    Flag = "BoxFill",
    Callback = function(value)
        ESP:ToggleBoxFill(value)
    end
})
