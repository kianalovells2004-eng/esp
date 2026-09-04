local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Movement = {
    SpeedEnabled = false,
    SpeedValue = 16,
    JumpEnabled = false,
    JumpValue = 50,
    InfJumpEnabled = false,
    NoclipEnabled = false,
    NoJumpCooldownEnabled = false,
    AutoBhopEnabled = false,
    DisabledConnections = {}
}

-- Disables the humanoid jump property signal connections responsible for jump delay
local function applyNoJumpCooldown(character)
    if not Movement.NoJumpCooldownEnabled then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    task.spawn(function()
        local signal = humanoid:GetPropertyChangedSignal("Jump")
        local connections = (getconnections and getconnections(signal)) or {}

        -- Wait briefly if client script hasn't bound the signal yet
        local retries = 0
        while #connections == 0 and retries < 20 and Movement.NoJumpCooldownEnabled do
            task.wait(0.1)
            connections = (getconnections and getconnections(signal)) or {}
            retries = retries + 1
        end

        if Movement.NoJumpCooldownEnabled then
            for _, conn in ipairs(connections) do
                conn:Disable()
                table.insert(Movement.DisabledConnections, conn)
            end
        end
    end)
end

-- Re-apply on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    if Movement.NoJumpCooldownEnabled then
        applyNoJumpCooldown(char)
    end
end)

-- Movement & Auto BHop Loop
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")

    if humanoid then
        if Movement.SpeedEnabled then
            humanoid.WalkSpeed = Movement.SpeedValue
        end
        if Movement.JumpEnabled then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = Movement.JumpValue
        end

        -- Auto BHop: Triggers jump state instantly when touching ground while moving
        if Movement.AutoBhopEnabled and humanoid.FloorMaterial ~= Enum.Material.Air and humanoid.MoveDirection.Magnitude > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip Loop
RunService.Stepped:Connect(function()
    if Movement.NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Infinite Jump connection
UserInputService.JumpRequest:Connect(function()
    if Movement.InfJumpEnabled then
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

function Movement:SetSpeed(enabled, value)
    self.SpeedEnabled = enabled
    if value then self.SpeedValue = value end
    if not enabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 end
    end
end

function Movement:SetJump(enabled, value)
    self.JumpEnabled = enabled
    if value then self.JumpValue = value end
    if not enabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.JumpPower = 50 end
    end
end

function Movement:SetNoclip(enabled)
    self.NoclipEnabled = enabled
end

function Movement:SetInfJump(enabled)
    self.InfJumpEnabled = enabled
end

function Movement:SetAutoBhop(enabled)
    self.AutoBhopEnabled = enabled
end

function Movement:SetNoJumpCooldown(enabled)
    self.NoJumpCooldownEnabled = enabled
    if enabled then
        if LocalPlayer.Character then
            applyNoJumpCooldown(LocalPlayer.Character)
        end
    else
        for _, conn in ipairs(self.DisabledConnections) do
            if conn.Enable then
                conn:Enable()
            end
        end
        table.clear(self.DisabledConnections)
    end
end

return Movement
