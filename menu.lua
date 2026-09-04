local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/kianalovells2004-eng/esp/refs/heads/main/esp.lua"))()
local Movement = loadstring(game:HttpGet("https://raw.githubusercontent.com/kianalovells2004-eng/movement/refs/heads/main/movement.lua"))()

local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)("Pepsi's UI Library")
local window = library:CreateWindow({ Name = "ESP Hub" })

-- ESP Tab
local espTab = window:CreateTab({ Name = "ESP" })
local espSection = espTab:CreateSection({ Name = "Visuals", Side = "Left" })

espSection:AddToggle({
    Name = "Box ESP",
    Value = false,
    Flag = "BoxESP",
    Callback = function(value)
        ESP:ToggleBox(value)
    end
})

espSection:AddToggle({
    Name = "2D Box Fill",
    Value = false,
    Flag = "BoxFill",
    Callback = function(value)
        ESP:ToggleBoxFill(value)
    end
})

espSection:AddToggle({
    Name = "Name ESP",
    Value = false,
    Flag = "NameESP",
    Callback = function(value)
        ESP:ToggleName(value)
    end
})

espSection:AddToggle({
    Name = "3D Box ESP",
    Value = false,
    Flag = "ThreeDBoxESP",
    Callback = function(value)
        ESP:Toggle3DBox(value)
    end
})

espSection:AddToggle({
    Name = "Local Player Tracer",
    Value = false,
    Flag = "TracerLocal",
    Callback = function(value)
        ESP:ToggleTracerLocal(value)
    end
})

espSection:AddToggle({
    Name = "Mouse Tracer",
    Value = false,
    Flag = "TracerMouse",
    Callback = function(value)
        ESP:ToggleTracerMouse(value)
    end
})

espSection:AddToggle({
    Name = "Top Tracer",
    Value = false,
    Flag = "TracerTop",
    Callback = function(value)
        ESP:ToggleTracerTop(value)
    end
})

espSection:AddToggle({
    Name = "Bottom Tracer",
    Value = false,
    Flag = "TracerBottom",
    Callback = function(value)
        ESP:ToggleTracerBottom(value)
    end
})

-- Movement Tab
local moveTab = window:CreateTab({ Name = "Movement" })
local moveSection = moveTab:CreateSection({ Name = "Movement", Side = "Left" })

moveSection:AddToggle({
    Name = "Fly",
    Value = false,
    Flag = "Fly",
    Callback = function(value)
        Movement:ToggleFly(value)
    end
})

moveSection:AddSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 200,
    Value = 50,
    Flag = "FlySpeed",
    Callback = function(value)
        Movement:SetFlySpeed(value)
    end
})

moveSection:AddToggle({
    Name = "Noclip",
    Value = false,
    Flag = "Noclip",
    Callback = function(value)
        Movement:ToggleNoclip(value)
    end
})

moveSection:AddToggle({
    Name = "Infinite Jump",
    Value = false,
    Flag = "InfiniteJump",
    Callback = function(value)
        Movement:ToggleInfiniteJump(value)
    end
})

moveSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Value = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        Movement:SetWalkSpeed(value)
    end
})

moveSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 200,
    Value = 50,
    Flag = "JumpPower",
    Callback = function(value)
        Movement:SetJumpPower(value)
    end
})
