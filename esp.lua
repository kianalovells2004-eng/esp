local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESP = {
    Enabled = false,
    BoxEnabled = false,
    BoxFillEnabled = false,      -- NEW: separate toggle for filled box
    NameEnabled = false,
    ThreeDBoxEnabled = false,
    TracerLocalEnabled = false,
    TracerMouseEnabled = false,
    TracerTopEnabled = false,
    TracerBottomEnabled = false,
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
            Color = Color3.fromRGB(255, 255, 255), -- white
            Thickness = 1.5,
            Filled = false,
            Transparency = 1
        }),
        BoxOutline = newDrawing("Square", {
            Color = Color3.fromRGB(0, 0, 0),        -- black outline
            Thickness = 1.5,
            Filled = false,
            Transparency = 0.5
        }),
        BoxFill = newDrawing("Square", {            -- filled box (separate toggle)
            Color = Color3.fromRGB(255, 255, 255), -- white
            Thickness = 1,
            Filled = true,
            Transparency = 0.6
        }),
        NameText = newDrawing("Text", {
            Color = Color3.fromRGB(255, 255, 255), -- white
            Size = 14,
            Center = true,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Font = Drawing.Fonts.UI,  -- Gothic/UI font
            Transparency = 1
        }),
        ThreeDLines = {},
        ThreeDOutlines = {},
        TracerLocal = newDrawing("Line", {
            Color = Color3.fromRGB(255, 255, 255), -- white
            Thickness = 1,
            Transparency = 1
        }),
        TracerLocalOutline = newDrawing("Line", {
            Color = Color3.fromRGB(0, 0, 0),        -- black outline
            Thickness = 1.5,
            Transparency = 0.5
        }),
        TracerMouse = newDrawing("Line", {
            Color = Color3.fromRGB(255, 255, 255), -- white
            Thickness = 1,
            Transparency = 1
        }),
        TracerMouseOutline = newDrawing("Line", {
            Color = Color3.fromRGB(0, 0, 0),        -- black outline
            Thickness = 1.5,
            Transparency = 0.5
        }),
        TracerTop = newDrawing("Line", {
            Color = Color3.fromRGB(255, 255, 255), -- white
            Thickness = 1,
            Transparency = 1
        }),
        TracerTopOutline = newDrawing("Line", {
            Color = Color3.fromRGB(0, 0, 0),        -- black outline
            Thickness = 1.5,
            Transparency = 0.5
        }),
        TracerBottom = newDrawing("Line", {
            Color = Color3.fromRGB(255, 255, 255), -- white
            Thickness = 1,
            Transparency = 1
        }),
        TracerBottomOutline = newDrawing("Line", {
            Color = Color3.fromRGB(0, 0, 0),        -- black outline
            Thickness = 1.5,
            Transparency = 0.5
        })
    }

    -- 3D box lines (12 colored + 12 outlines)
    for i = 1, 12 do
        drawings.ThreeDOutlines[i] = newDrawing("Line", {
            Color = Color3.fromRGB(0, 0, 0),        -- black outline
            Thickness = 1.5,
            Transparency = 0.5
        })
        drawings.ThreeDLines[i] = newDrawing("Line", {
            Color = Color3.fromRGB(255, 255, 255), -- white
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

function ESP:ToggleBoxFill(state)          -- NEW toggle
    self.BoxFillEnabled = state
    if not state then
        for _, drawings in pairs(self.Drawings) do
            drawings.BoxFill.Visible = false
        end
    end
end

function ESP:ToggleName(state)
    self.NameEnabled = state
    if not state then
        for _, drawings in pairs(self.Drawings) do
            drawings.NameText.Visible = false
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

function ESP:ToggleTracerLocal(state)
    self.TracerLocalEnabled = state
    if not state then
        for _, drawings in pairs(self.Drawings) do
            drawings.TracerLocal.Visible = false
            drawings.TracerLocalOutline.Visible = false
        end
    end
end

function ESP:ToggleTracerMouse(state)
    self.TracerMouseEnabled = state
    if not state then
        for _, drawings in pairs(self.Drawings) do
            drawings.TracerMouse.Visible = false
            drawings.TracerMouseOutline.Visible = false
        end
    end
end

function ESP:ToggleTracerTop(state)
    self.TracerTopEnabled = state
    if not state then
        for _, drawings in pairs(self.Drawings) do
            drawings.TracerTop.Visible = false
            drawings.TracerTopOutline.Visible = false
        end
    end
end

function ESP:ToggleTracerBottom(state)
    self.TracerBottomEnabled = state
    if not state then
        for _, drawings in pairs(self.Drawings) do
            drawings.TracerBottom.Visible = false
            drawings.TracerBottomOutline.Visible = false
        end
    end
end

-- Master toggle (keeps compatibility)
function ESP:Toggle(state)
    self.Enabled = state
    self:ToggleBox(state)
    self:ToggleBoxFill(state)   -- include new toggle
    self:ToggleName(state)
    self:Toggle3DBox(state)
    self:ToggleTracerLocal(state)
    self:ToggleTracerMouse(state)
    self:ToggleTracerTop(state)
    self:ToggleTracerBottom(state)
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

-- Helper to get target's root part screen position (and on-screen flag)
local function getTargetScreenPos(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil, false end
    local screenPos, onScreen = worldToScreen(rootPart.Position)
    return screenPos, onScreen
end

-- Main render loop
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        local isValid = character and humanoid and humanoid.Health > 0 and rootPart
        local shouldDrawAny = (ESP.BoxEnabled or ESP.BoxFillEnabled or ESP.NameEnabled or ESP.ThreeDBoxEnabled
            or ESP.TracerLocalEnabled or ESP.TracerMouseEnabled
            or ESP.TracerTopEnabled or ESP.TracerBottomEnabled) and isValid

        -- Get or create drawings for this player
        local drawings = ESP.Drawings[player]
        if not drawings then
            drawings = createDrawings(player)
            ESP.Drawings[player] = drawings
        end

        if not shouldDrawAny then
            -- Hide everything
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
            drawings.BoxFill.Visible = false
            drawings.NameText.Visible = false
            for i = 1, 12 do
                drawings.ThreeDLines[i].Visible = false
                drawings.ThreeDOutlines[i].Visible = false
            end
            drawings.TracerLocal.Visible = false
            drawings.TracerLocalOutline.Visible = false
            drawings.TracerMouse.Visible = false
            drawings.TracerMouseOutline.Visible = false
            drawings.TracerTop.Visible = false
            drawings.TracerTopOutline.Visible = false
            drawings.TracerBottom.Visible = false
            drawings.TracerBottomOutline.Visible = false
            continue
        end

        -- Get bounding box
        local min, max = getCharacterBounds(character)
        if not min or not max then
            -- Hide all drawings if no valid bounding box
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
            drawings.BoxFill.Visible = false
            drawings.NameText.Visible = false
            for i = 1, 12 do
                drawings.ThreeDLines[i].Visible = false
                drawings.ThreeDOutlines[i].Visible = false
            end
            drawings.TracerLocal.Visible = false
            drawings.TracerLocalOutline.Visible = false
            drawings.TracerMouse.Visible = false
            drawings.TracerMouseOutline.Visible = false
            drawings.TracerTop.Visible = false
            drawings.TracerTopOutline.Visible = false
            drawings.TracerBottom.Visible = false
            drawings.TracerBottomOutline.Visible = false
            continue
        end

        -- Project all 8 corners of the 3D bounding box
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
            -- Target not visible, hide all
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
            drawings.BoxFill.Visible = false
            drawings.NameText.Visible = false
            for i = 1, 12 do
                drawings.ThreeDLines[i].Visible = false
                drawings.ThreeDOutlines[i].Visible = false
            end
            drawings.TracerLocal.Visible = false
            drawings.TracerLocalOutline.Visible = false
            drawings.TracerMouse.Visible = false
            drawings.TracerMouseOutline.Visible = false
            drawings.TracerTop.Visible = false
            drawings.TracerTopOutline.Visible = false
            drawings.TracerBottom.Visible = false
            drawings.TracerBottomOutline.Visible = false
            continue
        end

        -- Calculate screen-space bounding rectangle
        local screenMin = Vector2.new(math.huge, math.huge)
        local screenMax = Vector2.new(-math.huge, -math.huge)
        for _, corner in ipairs(screenCorners) do
            screenMin = Vector2.new(math.min(screenMin.X, corner.X), math.min(screenMin.Y, corner.Y))
            screenMax = Vector2.new(math.max(screenMax.X, corner.X), math.max(screenMax.Y, corner.Y))
        end

        -- Box ESP (outline only)
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

        -- Box Fill ESP (independent toggle)
        if ESP.BoxFillEnabled then
            local fill = drawings.BoxFill
            fill.Size = Vector2.new(screenMax.X - screenMin.X, screenMax.Y - screenMin.Y)
            fill.Position = screenMin
            fill.Visible = true
        else
            drawings.BoxFill.Visible = false
        end

        -- Name ESP (above the head, no background)
        if ESP.NameEnabled then
            local nameText = drawings.NameText
            local name = player.Name

            nameText.Text = name

            local textSize = Vector2.new(nameText.TextBounds.X, nameText.TextBounds.Y)
            local gap = 5

            local textPos = Vector2.new(
                (screenMin.X + screenMax.X) / 2,
                screenMin.Y - gap - textSize.Y / 2
            )

            nameText.Position = textPos
            nameText.Visible = true
        else
            drawings.NameText.Visible = false
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

        -- Tracers: get target screen position (use root part center)
        local targetScreen, targetOnScreen = getTargetScreenPos(character)
        if targetScreen and targetOnScreen then
            -- Local Player Tracer
            if ESP.TracerLocalEnabled then
                local localChar = LocalPlayer.Character
                local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
                if localRoot then
                    local localScreen = worldToScreen(localRoot.Position)
                    if localScreen then
                        drawings.TracerLocalOutline.From = localScreen
                        drawings.TracerLocalOutline.To = targetScreen
                        drawings.TracerLocalOutline.Visible = true
                        drawings.TracerLocal.From = localScreen
                        drawings.TracerLocal.To = targetScreen
                        drawings.TracerLocal.Visible = true
                    else
                        drawings.TracerLocal.Visible = false
                        drawings.TracerLocalOutline.Visible = false
                    end
                else
                    drawings.TracerLocal.Visible = false
                    drawings.TracerLocalOutline.Visible = false
                end
            else
                drawings.TracerLocal.Visible = false
                drawings.TracerLocalOutline.Visible = false
            end

            -- Mouse Tracer
            if ESP.TracerMouseEnabled then
                local mouseScreen = Vector2.new(mousePos.X, mousePos.Y)
                drawings.TracerMouseOutline.From = mouseScreen
                drawings.TracerMouseOutline.To = targetScreen
                drawings.TracerMouseOutline.Visible = true
                drawings.TracerMouse.From = mouseScreen
                drawings.TracerMouse.To = targetScreen
                drawings.TracerMouse.Visible = true
            else
                drawings.TracerMouse.Visible = false
                drawings.TracerMouseOutline.Visible = false
            end

            -- Top Tracer (from top center of screen)
            if ESP.TracerTopEnabled then
                local screenSize = Camera.ViewportSize
                local topScreen = Vector2.new(screenSize.X / 2, 0)
                drawings.TracerTopOutline.From = topScreen
                drawings.TracerTopOutline.To = targetScreen
                drawings.TracerTopOutline.Visible = true
                drawings.TracerTop.From = topScreen
                drawings.TracerTop.To = targetScreen
                drawings.TracerTop.Visible = true
            else
                drawings.TracerTop.Visible = false
                drawings.TracerTopOutline.Visible = false
            end

            -- Bottom Tracer (from bottom center of screen)
            if ESP.TracerBottomEnabled then
                local screenSize = Camera.ViewportSize
                local bottomScreen = Vector2.new(screenSize.X / 2, screenSize.Y)
                drawings.TracerBottomOutline.From = bottomScreen
                drawings.TracerBottomOutline.To = targetScreen
                drawings.TracerBottomOutline.Visible = true
                drawings.TracerBottom.From = bottomScreen
                drawings.TracerBottom.To = targetScreen
                drawings.TracerBottom.Visible = true
            else
                drawings.TracerBottom.Visible = false
                drawings.TracerBottomOutline.Visible = false
            end
        else
            drawings.TracerLocal.Visible = false
            drawings.TracerLocalOutline.Visible = false
            drawings.TracerMouse.Visible = false
            drawings.TracerMouseOutline.Visible = false
            drawings.TracerTop.Visible = false
            drawings.TracerTopOutline.Visible = false
            drawings.TracerBottom.Visible = false
            drawings.TracerBottomOutline.Visible = false
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local drawings = ESP.Drawings[player]
    if drawings then
        drawings.Box:Remove()
        drawings.BoxOutline:Remove()
        drawings.BoxFill:Remove()  -- NEW
        drawings.NameText:Remove()
        for i = 1, 12 do
            drawings.ThreeDLines[i]:Remove()
            drawings.ThreeDOutlines[i]:Remove()
        end
        drawings.TracerLocal:Remove()
        drawings.TracerLocalOutline:Remove()
        drawings.TracerMouse:Remove()
        drawings.TracerMouseOutline:Remove()
        drawings.TracerTop:Remove()
        drawings.TracerTopOutline:Remove()
        drawings.TracerBottom:Remove()
        drawings.TracerBottomOutline:Remove()
        ESP.Drawings[player] = nil
    end
end)

return ESP
