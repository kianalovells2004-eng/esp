local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESP = {
    Enabled = false,
    Boxes = {}
}

local function createBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Thickness = 1.5
    box.Filled = false
    box.Transparency = 1
    return box
end

function ESP:Toggle(state)
    self.Enabled = state
    if not state then
        for _, box in pairs(self.Boxes) do
            box.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            
            if ESP.Enabled and char and humanoid and humanoid.Health > 0 and rootPart then
                if not ESP.Boxes[player] then
                    ESP.Boxes[player] = createBox()
                end
                
                local box = ESP.Boxes[player]
                local topPos, topVisible = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3.8, 0))
                local bottomPos, bottomVisible = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3.2, 0))
                
                if topVisible or bottomVisible then
                    local boxHeight = math.abs(topPos.Y - bottomPos.Y)
                    local boxWidth = boxHeight / 2
                    
                    box.Size = Vector2.new(boxWidth, boxHeight)
                    box.Position = Vector2.new(topPos.X - (boxWidth / 2), topPos.Y)
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                if ESP.Boxes[player] then
                    ESP.Boxes[player].Visible = false
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESP.Boxes[player] then
        ESP.Boxes[player]:Remove()
        ESP.Boxes[player] = nil
    end
end)

return ESP
