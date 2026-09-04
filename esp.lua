local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESP = {
    Enabled = false,
    BoxEnabled = false,
    CornerBoxEnabled = false,
    ThreeDBoxEnabled = false,
    Drawings = {}
}

local function newDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties or {}) do
        drawing[prop] = value
    end
    drawing.Visible = false
    return drawing
end

local function createDrawings(player)
    local drawings = {
        Box = newDrawing("Square", {
            Color = Color3.fromRGB(0, 255, 0),
            Thickness = 1.5,
            Filled = false,
            Transparency = 1
        }),
        BoxOutline = newDrawing("Square", {
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 1.5,
            Filled = false,
            Transparency = 1
        }),
        CornerLines = {},
        ThreeDLines = {}
    }

    for i = 1, 8 do
        drawings.CornerLines[i] = newDrawing("Line", {
            Color = Color3.fromRGB(255, 255, 0),
            Thickness = 1.5,
            Transparency = 1
        })
    end

    for i = 1, 12 do
        drawings.ThreeDLines[i] = newDrawing("Line", {
            Color = Color3.fromRGB(0, 150, 255),
            Thickness = 1.2,
            Transparency = 1
        })
    end

    return drawings
end

function ESP:ToggleBox(state)
    self.BoxEnabled = state
    if not state then
        for _, drawings in pairs(self.Drawings) do
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
        end
    end
end

function ESP:ToggleCornerBox(state)
    self.CornerBoxEnabled = state
    if not state then
        for _, drawings in pairs(self.Drawings) do
            for _, line in ipairs(drawings.CornerLines) do
                line.Visible = false
            end
        end
    end
end

function ESP:Toggle3DBox(state)
    self.ThreeDBoxEnabled = state
    if not state then
        for _, drawings in pairs(self.Drawings) do
            for _, line in ipairs(drawings.ThreeDLines) do
                line.Visible = false
            end
        end
    end
end

function ESP:Toggle(state)
    self.Enabled = state
    self:ToggleBox(state)
    self:ToggleCornerBox(state)
    self:Toggle3DBox(state)
end

local function getCharacterBounds(character)
    local min = Vector3.new(math.huge, math.huge, math.huge)
    local max = Vector3.new(-math.huge, -math.huge, -math.huge)
    local foundPart = false

    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            foundPart = true
            local partMin = part.Position - part.Size / 2
            local partMax = part.Position + part.Size / 2

            min = Vector3.new(
                math.min(min.X, partMin.X),
                math.min(min.Y, partMin.Y),
                math.min(min.Z, partMin.Z)
            )
            max = Vector3.new(
                math.max(max.X, partMax.X),
                math.max(max.Y, partMax.Y),
                math.max(max.Z, partMax.Z)
            )
        end
    end

    if not foundPart then return nil end
    return min, max
end

local function worldToScreen(worldPos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local function updateCornerLines(lines, topLeft, topRight, bottomLeft, bottomRight)
    local cornerLength = 8

    lines[1].From = topLeft
    lines[1].To = topLeft + Vector2.new(cornerLength, 0)
    lines[2].From = topLeft
    lines[2].To = topLeft + Vector2.new(0, cornerLength)

    lines[3].From = topRight
    lines[3].To = topRight - Vector2.new(cornerLength, 0)
    lines[4].From = topRight
    lines[4].To = topRight + Vector2.new(0, cornerLength)

    lines[5].From = bottomLeft
    lines[5].To = bottomLeft + Vector2.new(cornerLength, 0)
    lines[6].From = bottomLeft
    lines[6].To = bottomLeft - Vector2.new(0, cornerLength)

    lines[7].From = bottomRight
    lines[7].To = bottomRight - Vector2.new(cornerLength, 0)
    lines[8].From = bottomRight
    lines[8].To = bottomRight - Vector2.new(0, cornerLength)

    for _, line in ipairs(lines) do
        line.Visible = true
    end
end

local function update3DLines(lines, corners)
    local edges = {
        {1, 2}, {2, 4}, {4, 3}, {3, 1},
        {5, 6}, {6, 8}, {8, 7}, {7, 5},
        {1, 5}, {2, 6}, {3, 7}, {4, 8}
    }

    for i, edge in ipairs(edges) do
        local from, to = corners[edge[1]], corners[edge[2]]
        lines[i].From = from
        lines[i].To = to
        lines[i].Visible = true
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        local isValid = character and humanoid and humanoid.Health > 0 and rootPart
        local shouldDrawAny = (ESP.BoxEnabled or ESP.CornerBoxEnabled or ESP.ThreeDBoxEnabled) and isValid

        local drawings = ESP.Drawings[player]
        if not drawings then
            drawings = createDrawings(player)
            ESP.Drawings[player] = drawings
        end

        if not shouldDrawAny then
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
            for _, line in ipairs(drawings.CornerLines) do line.Visible = false end
            for _, line in ipairs(drawings.ThreeDLines) do line.Visible = false end
            continue
        end

        local min, max = getCharacterBounds(character)
        if not min or not max then
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
            for _, line in ipairs(drawings.CornerLines) do line.Visible = false end
            for _, line in ipairs(drawings.ThreeDLines) do line.Visible = false end
            continue
        end

        local corners3D = {
            Vector3.new(min.X, min.Y, min.Z), Vector3.new(min.X, min.Y, max.Z),
            Vector3.new(min.X, max.Y, min.Z), Vector3.new(min.X, max.Y, max.Z),
            Vector3.new(max.X, min.Y, min.Z), Vector3.new(max.X, min.Y, max.Z),
            Vector3.new(max.X, max.Y, min.Z), Vector3.new(max.X, max.Y, max.Z)
        }

        local screenCorners = {}
        local anyOnScreen = false
        for i, corner in ipairs(corners3D) do
            local screenPos, onScreen = worldToScreen(corner)
            screenCorners[i] = screenPos
            if onScreen then anyOnScreen = true end
        end

        if not anyOnScreen then
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
            for _, line in ipairs(drawings.CornerLines) do line.Visible = false end
            for _, line in ipairs(drawings.ThreeDLines) do line.Visible = false end
            continue
        end

        local screenMin = Vector2.new(math.huge, math.huge)
        local screenMax = Vector2.new(-math.huge, -math.huge)
        for _, corner in ipairs(screenCorners) do
            screenMin = Vector2.new(math.min(screenMin.X, corner.X), math.min(screenMin.Y, corner.Y))
            screenMax = Vector2.new(math.max(screenMax.X, corner.X), math.max(screenMax.Y, corner.Y))
        end

        -- Round screen coordinates to whole pixels for stability
        screenMin = Vector2.new(math.floor(screenMin.X + 0.5), math.floor(screenMin.Y + 0.5))
        screenMax = Vector2.new(math.floor(screenMax.X + 0.5), math.floor(screenMax.Y + 0.5))

        if ESP.BoxEnabled then
            local box = drawings.Box
            local outline = drawings.BoxOutline
            local boxSize = Vector2.new(screenMax.X - screenMin.X, screenMax.Y - screenMin.Y)
            local boxPos = screenMin

            box.Size = boxSize
            box.Position = boxPos
            box.Visible = true

            local outlineOffset = 1
            outline.Size = boxSize + Vector2.new(outlineOffset * 2, outlineOffset * 2)
            outline.Position = boxPos - Vector2.new(outlineOffset, outlineOffset)
            outline.Visible = true
        else
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
        end

        if ESP.CornerBoxEnabled then
            local topLeft = screenMin
            local topRight = Vector2.new(screenMax.X, screenMin.Y)
            local bottomLeft = Vector2.new(screenMin.X, screenMax.Y)
            local bottomRight = screenMax
            updateCornerLines(drawings.CornerLines, topLeft, topRight, bottomLeft, bottomRight)
        else
            for _, line in ipairs(drawings.CornerLines) do line.Visible = false end
        end

        if ESP.ThreeDBoxEnabled then
            update3DLines(drawings.ThreeDLines, screenCorners)
        else
            for _, line in ipairs(drawings.ThreeDLines) do line.Visible = false end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local drawings = ESP.Drawings[player]
    if drawings then
        drawings.Box:Remove()
        drawings.BoxOutline:Remove()
        for _, line in ipairs(drawings.CornerLines) do line:Remove() end
        for _, line in ipairs(drawings.ThreeDLines) do line:Remove() end
        ESP.Drawings[player] = nil
    end
end)

return ESP
