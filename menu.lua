-- Fetch movement logic (ensure movement.lua is loaded or executed first)
local Movement = getgenv().MovementModule or loadstring(game:HttpGet("https://raw.githubusercontent.com/kianalovells2004-eng/esp/refs/heads/main/movement.lua"))()

-- Load Pepsi UI Library
local PepsiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/pepsi-ui/pepsi/main/library.lua"))()

local Window = PepsiLibrary:CreateWindow({
    Name = "Movement Suite",
    Theme = "Dark"
})

local MovementTab = Window:CreateTab("Movement")
local MainSection = MovementTab:CreateSection("Bhop & Speed Controls")

-- AutoHop Toggle with 'X' Keybind
MainSection:CreateToggle({
    Name = "Auto Hop (Bhop)",
    Default = false,
    Keybind = Enum.KeyCode.X,
    Callback = function(state)
        Movement.AutoHop = state
    end
})

-- Direct Velocity Speed Toggle
MainSection:CreateToggle({
    Name = "Velocity Speed",
    Default = false,
    Callback = function(state)
        Movement.SpeedEnabled = state
    end
})

-- Speed Slider (Default: 32)
MainSection:CreateSlider({
    Name = "Speed Studs",
    Min = 16,
    Max = 120,
    Default = 32,
    Precision = 0,
    Callback = function(value)
        Movement.SpeedValue = value
    end
})

-- No Jump Cooldown Toggle
MainSection:CreateToggle({
    Name = "Bypass Jump Cooldown",
    Default = true,
    Callback = function(state)
        Movement.NoJumpCooldown = state
    end
})
