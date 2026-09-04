local MovementModule = {
    AutoHop = false,
    SpeedEnabled = false,
    SpeedValue = 32,
    NoJumpCooldown = true
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Disable Jump Cooldowns & Fatigue
local function applyNoJumpCooldown(character)
    if not MovementModule.NoJumpCooldown then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    if getconnections then
        for _, connection in ipairs(getconnections(humanoid:GetPropertyChangedSignal("Jump"))) do
            connection:Disable()
        end
    end

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
end

-- Hook character spawning
if LocalPlayer.Character then
    task.spawn(applyNoJumpCooldown, LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(applyNoJumpCooldown)

-- Core Movement Loop
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not (humanoid and rootPart and humanoid.Health > 0) then return end

    -- AutoHop Trigger
    if MovementModule.AutoHop and humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        humanoid.Jump = true
    end

    -- Direct Velocity Speed Trigger
    if MovementModule.SpeedEnabled then
        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            local currentYVelocity = rootPart.AssemblyLinearVelocity.Y
            rootPart.AssemblyLinearVelocity = Vector3.new(
                moveDirection.X * MovementModule.SpeedValue,
                currentYVelocity,
                moveDirection.Z * MovementModule.SpeedValue
            )
        end
    end
end)

getgenv().MovementModule = MovementModule
return MovementModule
