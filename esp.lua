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

-- Helper to create a new drawing object
local function newDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties or {}) do
        drawing[prop] = value
    end
    drawing.Visible = false
    return drawing
end

-- Create all drawing objects for a player
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
            Thickness = 3,               -- thicker than main box
            Filled = false,
            Transparency = 0.5           -- semi-transparent
        }),
        CornerLines = {},                -- colored lines
        CornerOutlines = {},             -- black outline lines
        ThreeDLines = {},                -- colored lines
        ThreeDOutlines = {}              -- black outline lines
    }

    -- Corner box: 8 colored lines and 8 outline lines
    for i = 1, 8 do
        drawings.CornerOutlines[i] = newDrawing("Line", {
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 3.5,             -- thicker than colored (1.5 + 2)
            Transparency = 0.5
        })
        drawings.CornerLines[i] = newDrawing("Line", {
            Color = Color3.fromRGB(255, 255, 0),
            Thickness = 1.5,
            Transparency = 1
        })
    end

    -- 3D box: 12 colored lines and 12 outline lines
    for i = 1, 12 do
        drawings.ThreeDOutlines[i] = newDrawing("Line", {
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 3,               -- thicker than colored (1.2 + 1.8)
            Transparency = 0.5
        })
        drawings.ThreeDLines[i] = newDrawing("Line", {
            Color = Color3.fromRGB(0, 150, 255),
            Thickness = 1.2,
            Transparency = 1
        })
    end

    return drawings
end

-- Toggle functions
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
            for i = 1, 8 do
                drawings.CornerLines[i].Visible = false
                drawings.CornerOutlines[i].Visible = false
            end
        end
    end
end

function ESP:Toggle3DBox(state)
    self.ThreeDBoxEnabled = state
    if not state then
        for _, drawings in pairs(self.Drawings) do
            for i = 1, 12 do
                drawings.ThreeDLines[i].Visible = false
                drawings.ThreeDOutlines[i].Visible = false
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

-- Calculate world-space bounding box of character
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

-- Update corner box lines with dynamic corner length
local function updateCornerLines(drawings, topLeft, topRight, bottomLeft, bottomRight)
    local boxWidth = topRight.X - topLeft.X
    local boxHeight = bottomLeft.Y - topLeft.Y
    -- Dynamic corner length: proportional to box size, clamped between 2 and 8 pixels
    local cornerLength = math.clamp(math.min(boxWidth, boxHeight) * 0.25, 2, 8)

    local positions = {
        {topLeft, topLeft + Vector2.new(cornerLength, 0)},
        {topLeft, topLeft + Vector2.new(0, cornerLength)},
        {topRight, topRight - Vector2.new(cornerLength, 0)},
        {topRight, topRight + Vector2.new(0, cornerLength)},
        {bottomLeft, bottomLeft + Vector2.new(cornerLength, 0)},
        {bottomLeft, bottomLeft - Vector2.new(0, cornerLength)},
        {bottomRight, bottomRight - Vector2.new(cornerLength, 0)},
        {bottomRight, bottomRight - Vector2.new(0, cornerLength)}
    }

    for i = 1, 8 do
        local outline = drawings.CornerOutlines[i]
        local line = drawings.CornerLines[i]
        outline.From = positions[i][1]
        outline.To = positions[i][2]
        outline.Visible = true
        line.From = positions[i][1]
        line.To = positions[i][2]
        line.Visible = true
    end
end

-- Update 3D box lines from 8 projected corners
local function update3DLines(drawings, corners)
    local edges = {
        {1, 2}, {2, 4}, {4, 3}, {3, 1},
        {5, 6}, {6, 8}, {8, 7}, {7, 5},
        {1, 5}, {2, 6}, {3, 7}, {4, 8}
    }

    for i, edge in ipairs(edges) do
        local from, to = corners[edge[1]], corners[edge[2]]
        drawings.ThreeDOutlines[i].From = from
        drawings.ThreeDOutlines[i].To = to
        drawings.ThreeDOutlines[i].Visible = true
        drawings.ThreeDLines[i].From = from
        drawings.ThreeDLines[i].To = to
        drawings.ThreeDLines[i].Visible = true
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
            -- Hide everything
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
            for i = 1, 8 do
                drawings.CornerLines[i].Visible = false
                drawings.CornerOutlines[i].Visible = false
            end
            for i = 1, 12 do
                drawings.ThreeDLines[i].Visible = false
                drawings.ThreeDOutlines[i].Visible = false
            end
            continue
        end

        local min, max = getCharacterBounds(character)
        if not min or not max then
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
            for i = 1, 8 do
                drawings.CornerLines[i].Visible = false
                drawings.CornerOutlines[i].Visible = false
            end
            for i = 1, 12 do
                drawings.ThreeDLines[i].Visible = false
                drawings.ThreeDOutlines[i].Visible = false
            end
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
            for i = 1, 8 do
                drawings.CornerLines[i].Visible = false
                drawings.CornerOutlines[i].Visible = false
            end
            for i = 1, 12 do
                drawings.ThreeDLines[i].Visible = false
                drawings.ThreeDOutlines[i].Visible = false
            end
            continue
        end

        local screenMin = Vector2.new(math.huge, math.huge)
        local screenMax = Vector2.new(-math.huge, -math.huge)
        for _, corner in ipairs(screenCorners) do
            screenMin = Vector2.new(math.min(screenMin.X, corner.X), math.min(screenMin.Y, corner.Y))
            screenMax = Vector2.new(math.max(screenMax.X, corner.X), math.max(screenMax.Y, corner.Y))
        end

        -- Box ESP with outline
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

        -- Corner Box ESP with dynamic corner length
        if ESP.CornerBoxEnabled then
            local topLeft = screenMin
            local topRight = Vector2.new(screenMax.X, screenMin.Y)
            local bottomLeft = Vector2.new(screenMin.X, screenMax.Y)
            local bottomRight = screenMax
            updateCornerLines(drawings, topLeft, topRight, bottomLeft, bottomRight)
        else
            for i = 1, 8 do
                drawings.CornerLines[i].Visible = false
                drawings.CornerOutlines[i].Visible = false
            end
        end

        -- 3D Box ESP
        if ESP.ThreeDBoxEnabled then
            update3DLines(drawings, screenCorners)
        else
            for i = 1, 12 do
                drawings.ThreeDLines[i].Visible = false
                drawings.ThreeDOutlines[i].Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local drawings = ESP.Drawings[player]
    if drawings then
        drawings.Box:Remove()
        drawings.BoxOutline:Remove()
        for i = 1, 8 do
            drawings.CornerLines[i]:Remove()
            drawings.CornerOutlines[i]:Remove()
        end
        for i = 1, 12 do
            drawings.ThreeDLines[i]:Remove()
            drawings.ThreeDOutlines[i]:Remove()
        end
        ESP.Drawings[player] = nil
    end
end)

return ESP
