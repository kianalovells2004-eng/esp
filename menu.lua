local rawUrl = "https://raw.githubusercontent.com/kianalovells2004-source/Uni/refs/heads/main/movement.lua"
local success, result = pcall(game.HttpGet, game, rawUrl)

if not success or not result then
    error("Failed to fetch movement.lua: " .. tostring(result))
end

local movementModule, err = loadstring(result)
if not movementModule then
    error("Syntax error in movement.lua: " .. tostring(err))
end

local Movement = movementModule()

-- Load Pepsi's UI Library
local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)("Pepsi's UI Library")
local window = library:CreateWindow({ Name = "Uni Hub" })

-- Movement Tab
local movementTab = window:CreateTab({ Name = "Movement" })
local statsSection = movementTab:CreateSection({ Name = "Stats", Side = "Left" })
local utilitySection = movementTab:CreateSection({ Name = "Utilities", Side = "Right" })

-- Speed Controls
statsSection:AddToggle({
    Name = "Enable Speed",
    Value = false,
    Flag = "EnableSpeed",
    Callback = function(state)
        Movement:SetSpeed(state)
    end
})

statsSection:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 250,
    Value = 16,
    Flag = "WalkSpeedValue",
    Callback = function(val)
        Movement.SpeedValue = val
    end
})

-- Jump Controls
statsSection:AddToggle({
    Name = "Enable Jump Power",
    Value = false,
    Flag = "EnableJump",
    Callback = function(state)
        Movement:SetJump(state)
    end
})

statsSection:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 300,
    Value = 50,
    Flag = "JumpPowerValue",
    Callback = function(val)
        Movement.JumpValue = val
    end
})

-- Utilities
utilitySection:AddToggle({
    Name = "Auto BHop",
    Value = false,
    Flag = "AutoBHop",
    Callback = function(state)
        Movement:SetAutoBhop(state)
    end
})

utilitySection:AddToggle({
    Name = "No Jump Cooldown",
    Value = false,
    Flag = "NoJumpCooldown",
    Callback = function(state)
        Movement:SetNoJumpCooldown(state)
    end
})

utilitySection:AddToggle({
    Name = "Infinite Jump",
    Value = false,
    Flag = "InfiniteJump",
    Callback = function(state)
        Movement:SetInfJump(state)
    end
})

utilitySection:AddToggle({
    Name = "Noclip",
    Value = false,
    Flag = "Noclip",
    Callback = function(state)
        Movement:SetNoclip(state)
    end
})
