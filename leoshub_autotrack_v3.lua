-- Leo's Hub - Auto Track v3 (LocalScript)
-- Place inside StarterCharacterScripts
-- FEATURES: Wall Tech, Fast Jukes, Shiftlock Camera Control, Humanized Tracking, Auto-Walk Offense

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local localPlayer = Players.LocalPlayer
local guiLocked = false
local minimized = false
local enabled = false
local teamCheckEnabled = true
local settingsOpen = false

local settings = {
    stopDistance      = 0.5,
    backDistance      = 5,
    triggerTime       = 10,      -- NOW SET TO 10 AS REQUESTED
    backEnabled       = true,
    triggerEnabled    = true,
    wallTechEnabled   = true,
    jukeEnabled       = true,
    humanizeEnabled   = true,
    shiftlockEnabled  = true,    -- NEW: Enable shiftlock camera control
}

-- ─────────────────────────────────────────────
--  Persist settings
-- ─────────────────────────────────────────────
local saveFile = "leoshub_autotrack_v3.json"

local function saveSettings()
    pcall(function()
        writefile(saveFile, game:GetService("HttpService"):JSONEncode(settings))
    end)
end

local function loadSettings()
    pcall(function()
        if isfile and isfile(saveFile) then
            local data = game:GetService("HttpService"):JSONDecode(readfile(saveFile))
            for k, v in pairs(data) do
                if settings[k] ~= nil then settings[k] = v end
            end
        end
    end)
end

loadSettings()

-- ─────────────────────────────────────────────
--  GUI
-- ─────────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeosHubAutoTrack"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 250)
frame.Position = UDim2.new(0, 20, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 100)
stroke.Thickness = 1.5
stroke.Parent = frame

local dragBar = Instance.new("Frame")
dragBar.Size = UDim2.new(1, 0, 0, 40)
dragBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
dragBar.BorderSizePixel = 0
dragBar.Active = true
dragBar.Parent = frame
Instance.new("UICorner", dragBar).CornerRadius = UDim.new(0, 10)

local dragLabel = Instance.new("TextLabel")
dragLabel.Size = UDim2.new(1, -145, 1, 0)
dragLabel.Position = UDim2.new(0, 12, 0, 0)
dragLabel.BackgroundTransparency = 1
dragLabel.Text = "⠿ Leo's Hub v3"
dragLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
dragLabel.Font = Enum.Font.GothamBold
dragLabel.TextSize = 17
dragLabel.TextXAlignment = Enum.TextXAlignment.Left
dragLabel.Parent = dragBar

local settingsBtn = Instance.new("TextButton")
settingsBtn.Size = UDim2.new(0, 34, 0, 34)
settingsBtn.Position = UDim2.new(1, -142, 0, 3)
settingsBtn.BackgroundTransparency = 1
settingsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
settingsBtn.Text = "⚙"
settingsBtn.TextSize = 22
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.BorderSizePixel = 0
settingsBtn.Parent = dragBar

local minButton = Instance.new("TextButton")
minButton.Size = UDim2.new(0, 34, 0, 34)
minButton.Position = UDim2.new(1, -105, 0, 3)
minButton.BackgroundTransparency = 1
minButton.TextColor3 = Color3.fromRGB(200, 200, 200)
minButton.Text = "－"
minButton.TextSize = 20
minButton.Font = Enum.Font.GothamBold
minButton.BorderSizePixel = 0
minButton.Parent = dragBar

local pinButton = Instance.new("TextButton")
pinButton.Size = UDim2.new(0, 34, 0, 34)
pinButton.Position = UDim2.new(1, -70, 0, 3)
pinButton.BackgroundTransparency = 1
pinButton.TextColor3 = Color3.fromRGB(200, 200, 200)
pinButton.Text = "📌"
pinButton.TextSize = 20
pinButton.Font = Enum.Font.GothamBold
pinButton.BorderSizePixel = 0
pinButton.Parent = dragBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 34, 0, 34)
closeButton.Position = UDim2.new(1, -38, 0, 3)
closeButton.BackgroundTransparency = 1
closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
closeButton.Text = "✕"
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = dragBar

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 290, 0, 48)
toggleBtn.Position = UDim2.new(0, 15, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
toggleBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
toggleBtn.Text = "● AUTO TRACK: OFF"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = contentFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local teamBtn = Instance.new("TextButton")
teamBtn.Size = UDim2.new(0, 290, 0, 48)
teamBtn.Position = UDim2.new(0, 15, 0, 66)
teamBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 60)
teamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teamBtn.Text = "🛡 TEAM CHECK: ON"
teamBtn.Font = Enum.Font.GothamBold
teamBtn.TextSize = 16
teamBtn.BorderSizePixel = 0
teamBtn.Parent = contentFrame
Instance.new("UICorner", teamBtn).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 290, 0, 30)
statusLabel.Position = UDim2.new(0, 15, 0, 122)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Must be holding the bomb"
statusLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = contentFrame

-- ─────────────────────────────────────────────
--  Settings panel
-- ─────────────────────────────────────────────
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(1, 0, 1, -40)
settingsFrame.Position = UDim2.new(0, 0, 0, 40)
settingsFrame.BackgroundTransparency = 1
settingsFrame.Visible = false
settingsFrame.Parent = frame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 650)
scrollFrame.Parent = settingsFrame

local TOGGLE_H = 46

local function createSetting(labelText, key, step, minVal, maxVal, posY, toggleKey)
    if toggleKey then
        local toggleLabel = Instance.new("TextButton")
        toggleLabel.Size = UDim2.new(0, 290, 0, 38)
        toggleLabel.Position = UDim2.new(0, 15, 0, posY)
        toggleLabel.BorderSizePixel = 0
        toggleLabel.Font = Enum.Font.GothamBold
        toggleLabel.TextSize = 15
        toggleLabel.Parent = scrollFrame
        Instance.new("UICorner", toggleLabel).CornerRadius = UDim.new(0, 8)

        local function updateToggle()
            if settings[toggleKey] then
                toggleLabel.Text = "✅ " .. labelText .. ": ON"
                toggleLabel.BackgroundColor3 = Color3.fromRGB(30, 100, 60)
                toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                toggleLabel.Text = "⬜ " .. labelText .. ": OFF"
                toggleLabel.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
                toggleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
        updateToggle()
        toggleLabel.MouseButton1Click:Connect(function()
            settings[toggleKey] = not settings[toggleKey]
            updateToggle()
            saveSettings()
        end)
        posY = posY + TOGGLE_H
    end

    local valueTitle = Instance.new("TextLabel")
    valueTitle.Size = UDim2.new(0, 290, 0, 20)
    valueTitle.Position = UDim2.new(0, 15, 0, posY)
    valueTitle.BackgroundTransparency = 1
    valueTitle.TextColor3 = Color3.fromRGB(140, 140, 160)
    valueTitle.Font = Enum.Font.Gotham
    valueTitle.TextSize = 13
    valueTitle.TextXAlignment = Enum.TextXAlignment.Left
    valueTitle.Text = labelText .. "  (min " .. minVal .. "  /  max " .. maxVal .. ")"
    valueTitle.Parent = scrollFrame

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 48, 0, 42)
    minusBtn.Position = UDim2.new(0, 15, 0, posY + 22)
    minusBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.Text = "－"
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 20
    minusBtn.BorderSizePixel = 0
    minusBtn.Parent = scrollFrame
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 8)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 140, 0, 42)
    valueLabel.Position = UDim2.new(0, 70, 0, posY + 22)
    valueLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 16
    valueLabel.BorderSizePixel = 0
    valueLabel.Text = string.format("%.1f", settings[key])
    valueLabel.Parent = scrollFrame
    Instance.new("UICorner", valueLabel).CornerRadius = UDim.new(0, 8)

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 48, 0, 42)
    plusBtn.Position = UDim2.new(0, 218, 0, posY + 22)
    plusBtn.BackgroundColor3 = Color3.fromRGB(30, 130, 50)
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.Text = "＋"
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 20
    plusBtn.BorderSizePixel = 0
    plusBtn.Parent = scrollFrame
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 8)

    minusBtn.MouseButton1Click:Connect(function()
        settings[key] = math.max(minVal, settings[key] - step)
        valueLabel.Text = string.format("%.1f", settings[key])
        saveSettings()
    end)

    plusBtn.MouseButton1Click:Connect(function()
        settings[key] = math.min(maxVal, settings[key] + step)
        valueLabel.Text = string.format("%.1f", settings[key])
        saveSettings()
    end)
end

local function createToggleOnly(labelText, toggleKey, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 290, 0, 38)
    btn.Position = UDim2.new(0, 15, 0, posY)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Parent = scrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local function update()
        if settings[toggleKey] then
            btn.Text = "✅ " .. labelText .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(30, 100, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = "⬜ " .. labelText .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
    update()
    btn.MouseButton1Click:Connect(function()
        settings[toggleKey] = not settings[toggleKey]
        update()
        saveSettings()
    end)
end

-- Original settings
createSetting("Stop Distance", "stopDistance", 0.5, 0.5, 1,   10)
createSetting("Back Distance", "backDistance", 1,   1,   15,  90,  "backEnabled")
createSetting("Trigger Time",  "triggerTime",  0.5, 0.5, 10,  226, "triggerEnabled")

-- New toggle-only settings
createToggleOnly("Wall Tech (Glide Along Walls)", "wallTechEnabled", 390)
createToggleOnly("Juke Defense (FAST)",           "jukeEnabled",     436)
createToggleOnly("Humanized Offense",             "humanizeEnabled", 482)
createToggleOnly("Shiftlock + Camera Control",    "shiftlockEnabled",528)

-- ─────────────────────────────────────────────
--  Dragging
-- ─────────────────────────────────────────────
local dragging, dragStart, startPos = false, nil, nil

dragBar.InputBegan:Connect(function(input)
    if guiLocked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

dragBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and not guiLocked and (
        input.UserInputType == Enum.UserInputType.MouseMovement or
        input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

settingsBtn.MouseButton1Click:Connect(function()
    settingsOpen = not settingsOpen
    contentFrame.Visible = not settingsOpen
    settingsFrame.Visible = settingsOpen
    frame.Size = UDim2.new(0, 320, 0, settingsOpen and 500 or 250)
    settingsBtn.TextColor3 = settingsOpen
        and Color3.fromRGB(255, 200, 50)
        or Color3.fromRGB(200, 200, 200)
end)

minButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        contentFrame.Visible = false
        settingsFrame.Visible = false
        frame.Size = UDim2.new(0, 320, 0, 40)
        minButton.Text = "＋"
    else
        contentFrame.Visible = not settingsOpen
        settingsFrame.Visible = settingsOpen
        frame.Size = UDim2.new(0, 320, 0, settingsOpen and 500 or 250)
        minButton.Text = "－"
    end
end)

pinButton.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    pinButton.Text = guiLocked and "🔒" or "📌"
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ─────────────────────────────────────────────
--  Toggle helpers
-- ─────────────────────────────────────────────
local function setEnabled(state)
    enabled = state
    if state then
        toggleBtn.Text = "● AUTO TRACK: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        stroke.Color = Color3.fromRGB(255, 60, 60)
    else
        toggleBtn.Text = "● AUTO TRACK: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        toggleBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        stroke.Color = Color3.fromRGB(80, 80, 100)
        statusLabel.Text = "Must be holding the bomb"
        statusLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
    end
end

local function setTeamCheck(state)
    teamCheckEnabled = state
    if state then
        teamBtn.Text = "🛡 TEAM CHECK: ON"
        teamBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 60)
        teamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        teamBtn.Text = "🛡 TEAM CHECK: OFF"
        teamBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        teamBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
    end
end

toggleBtn.MouseButton1Click:Connect(function() setEnabled(not enabled) end)
teamBtn.MouseButton1Click:Connect(function() setTeamCheck(not teamCheckEnabled) end)

-- ─────────────────────────────────────────────
--  Team / enemy detection
-- ─────────────────────────────────────────────
local function isGreenHighlighted(otherPlayer)
    local theirChar = otherPlayer.Character
    if not theirChar then return false end
    local highlight = theirChar:FindFirstChildOfClass("Highlight")
    if highlight then
        local c = highlight.FillColor
        if c.G > 0.4 and c.G > c.R * 1.5 and c.G > c.B * 1.5 then return true end
        local c2 = highlight.OutlineColor
        if c2.G > 0.4 and c2.G > c2.R * 1.5 and c2.G > c2.B * 1.5 then return true end
    end
    for _, v in ipairs(theirChar:GetDescendants()) do
        if v:IsA("Highlight") then
            local c = v.FillColor
            if c.G > 0.4 and c.G > c.R * 1.5 and c.G > c.B * 1.5 then return true end
        end
        if v:IsA("SelectionBox") then
            local c = v.Color3
            if c.G > 0.4 and c.G > c.R * 1.5 and c.G > c.B * 1.5 then return true end
        end
    end
    for _, v in ipairs(theirChar:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            local c = v.Color
            if c.G > 0.5 and c.G > c.R * 2 and c.G > c.B * 2 then return true end
        end
    end
    return false
end

local function isEnemy(otherPlayer)
    if not teamCheckEnabled then return true end
    return not isGreenHighlighted(otherPlayer)
end

local function getClosestEnemy(myRoot)
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and isEnemy(player) then
            local theirChar = player.Character
            if theirChar then
                local theirRoot  = theirChar:FindFirstChild("HumanoidRootPart")
                local theirHuman = theirChar:FindFirstChild("Humanoid")
                if theirRoot and theirHuman and theirHuman.Health > 0 then
                    local dist = (myRoot.Position - theirRoot.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = {root = theirRoot, player = player, dist = dist}
                    end
                end
            end
        end
    end
    return closest
end

local function getToolTimer(tool)
    if not tool then return nil end
    for _, v in ipairs(tool:GetDescendants()) do
        if (v:IsA("NumberValue") or v:IsA("IntValue")) and
           (v.Name:lower():find("time") or v.Name:lower():find("count")) then
            return tonumber(v.Value)
        end
    end
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("TextLabel") then
            local num = tonumber(v.Text)
            if num then return num end
        end
    end
    return nil
end

local function getPlayerHoldingBomb(myRoot)
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        local char = player.Character
        if not char then continue end
        local tool = char:FindFirstChildOfClass("Tool")
        local root = char:FindFirstChild("HumanoidRootPart")
        if tool and root then
            local dist = (myRoot.Position - root.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = {player = player, root = root}
            end
        end
    end
    if closest then return closest.player, closest.root end
    return nil, nil
end

-- ─────────────────────────────────────────────
--  Wall Tech (glide along walls)
-- ─────────────────────────────────────────────
local RAY_LEN   = 2.5
local WALL_CAST = RaycastParams.new()
WALL_CAST.FilterType = Enum.RaycastFilterType.Exclude

local function applyWallTech(myRoot, intendedDir, humanoid)
    local char = localPlayer.Character
    if char then WALL_CAST.FilterDescendantsInstances = {char} end

    local origin = myRoot.Position
    local result = Workspace:Raycast(origin, intendedDir * RAY_LEN, WALL_CAST)

    if result then
        local wallNormal = result.Normal
        local slideDir = (intendedDir - wallNormal * intendedDir:Dot(wallNormal)).Unit

        if slideDir.Magnitude > 0.1 then
            local slideTarget = myRoot.Position + slideDir * 6
            humanoid:MoveTo(slideTarget)
            return true
        end
    end
    return false
end

-- ─────────────────────────────────────────────
--  FAST JUKE (defense)
--  MUCH FASTER: shorter bursts, longer distances, rapid succession
-- ─────────────────────────────────────────────
local jukeState = {
    active      = false,
    direction   = Vector3.new(1, 0, 0),
    timer       = 0,
    cooldown    = 0,
    JUKE_DUR    = 0.15,  -- FASTER: 0.15s bursts (was 0.35)
    JUKE_CD_MIN = 0.08,  -- FASTER: 0.08s cooldown (was 0.5)
    JUKE_CD_MAX = 0.25,  -- FASTER: 0.25s max (was 1.2)
    JUKE_DIST   = 12,    -- BIGGER distance per juke
}

local function tickJuke(dt, myRoot, awayDir, humanoid)
    if jukeState.active then
        jukeState.timer = jukeState.timer - dt
        if jukeState.timer <= 0 then
            jukeState.active   = false
            jukeState.cooldown = jukeState.JUKE_CD_MIN +
                math.random() * (jukeState.JUKE_CD_MAX - jukeState.JUKE_CD_MIN)
        end
    else
        jukeState.cooldown = jukeState.cooldown - dt
        if jukeState.cooldown <= 0 then
            local up    = Vector3.new(0, 1, 0)
            local right = awayDir:Cross(up).Unit
            jukeState.direction = (math.random(0, 1) == 0) and right or -right
            jukeState.active    = true
            jukeState.timer     = jukeState.JUKE_DUR
        end
    end

    if jukeState.active then
        local blendDir = (jukeState.direction * 0.7 + awayDir * 0.3).Unit
        local target   = myRoot.Position + blendDir * jukeState.JUKE_DIST
        if settings.wallTechEnabled then
            if not applyWallTech(myRoot, blendDir, humanoid) then
                humanoid:MoveTo(target)
            end
        else
            humanoid:MoveTo(target)
        end
        return true
    end
    return false
end

-- ─────────────────────────────────────────────
--  SHIFTLOCK + HUMANIZED CAMERA CONTROL
--  Spazzes the camera left/right when attacking
--  Turns to face opponent (bomb in right hand)
-- ─────────────────────────────────────────────
local cameraState = {
    active         = false,
    spazzIntensity = 0,
    spazzTimer     = 0,
    targetYaw      = 0,
    baseYaw        = 0,
}

local function updateShiftlockCamera(myRoot, targetPos, dt)
    if not settings.shiftlockEnabled then return end
    
    -- Activate shiftlock (over-shoulder camera)
    cameraState.active = true
    
    -- Calculate direction to target (opponent)
    local dirToTarget = (targetPos - myRoot.Position)
    if dirToTarget.Magnitude > 0 then
        dirToTarget = dirToTarget.Unit
    end
    
    -- Get base yaw from direction
    local baseYaw = math.atan2(dirToTarget.X, dirToTarget.Z)
    
    -- Add humanized spazz: rapid left/right camera twitches
    -- This simulates muscle spazzing/twitching while aiming
    cameraState.spazzTimer = cameraState.spazzTimer - dt
    if cameraState.spazzTimer <= 0 then
        -- Random spazz intensity (0.3 to 0.8 radians = ~17-46 degrees)
        cameraState.spazzIntensity = 0.3 + math.random() * 0.5
        cameraState.spazzTimer = 0.05 + math.random() * 0.08  -- new spazz every 50-130ms
    end
    
    -- Apply oscillating spazz
    local spazzAmount = math.sin(cameraState.spazzTimer * 100) * cameraState.spazzIntensity
    local finalYaw = baseYaw + spazzAmount
    
    -- Position camera behind character's right shoulder (bomb in right hand)
    local offsetDist = 8
    local offsetHeight = 1.5
    local offsetSide = 4  -- right side offset for bomb visibility
    
    -- Calculate camera position
    local offsetX = math.sin(finalYaw) * offsetSide - math.cos(finalYaw) * offsetDist
    local offsetZ = math.cos(finalYaw) * offsetSide + math.sin(finalYaw) * offsetDist
    
    local cameraPos = myRoot.Position + Vector3.new(offsetX, offsetHeight, offsetZ)
    
    -- Look slightly ahead of target (humanized lead)
    local lookTarget = targetPos + Vector3.new(0, 1, 0)
    
    Camera.CFrame = CFrame.new(cameraPos, lookTarget)
end

-- ─────────────────────────────────────────────
--  Humanized offense
--  Slight positional drift + throttled updates
-- ─────────────────────────────────────────────
local humanizeState = {
    offset      = Vector3.new(0, 0, 0),
    driftTimer  = 0,
    DRIFT_INT   = 0.18,
    MAX_OFFSET  = 1.4,
    updateTimer = 0,
    UPDATE_INT  = 0.08,
}

local function humanizedMoveTo(myRoot, targetPos, humanoid, dt)
    humanizeState.driftTimer = humanizeState.driftTimer - dt
    if humanizeState.driftTimer <= 0 then
        local m = humanizeState.MAX_OFFSET
        humanizeState.offset = Vector3.new(
            (math.random() * 2 - 1) * m,
            0,
            (math.random() * 2 - 1) * m
        )
        humanizeState.driftTimer = humanizeState.DRIFT_INT + math.random() * 0.12
    end

    humanizeState.updateTimer = humanizeState.updateTimer - dt
    if humanizeState.updateTimer > 0 then return end
    humanizeState.updateTimer = humanizeState.UPDATE_INT + math.random() * 0.06

    local adjustedTarget = targetPos + humanizeState.offset
    local intendedDir    = (adjustedTarget - myRoot.Position)

    if intendedDir.Magnitude > 0.2 then
        intendedDir = intendedDir.Unit
        if settings.wallTechEnabled then
            if not applyWallTech(myRoot, intendedDir, humanoid) then
                humanoid:MoveTo(adjustedTarget)
            end
        else
            humanoid:MoveTo(adjustedTarget)
        end
    end
end

-- ─────────────────────────────────────────────
--  AUTO-WALK TO OPPONENT AT START
--  When offense starts (holding bomb), walk toward closest enemy
-- ─────────────────────────────────────────────
local function autoWalkToOpponent(myRoot, humanoid)
    local enemyData = getClosestEnemy(myRoot)
    if enemyData then
        local dist = (myRoot.Position - enemyData.root.Position).Magnitude
        
        -- Walk toward opponent if far away
        if dist > settings.stopDistance + 5 then
            local dirToEnemy = (enemyData.root.Position - myRoot.Position).Unit
            local targetPos = myRoot.Position + dirToEnemy * 10
            
            if settings.wallTechEnabled then
                if not applyWallTech(myRoot, dirToEnemy, humanoid) then
                    humanoid:MoveTo(targetPos)
                end
            else
                humanoid:MoveTo(targetPos)
            end
            return true
        end
    end
    return false
end

-- ─────────────────────────────────────────────
--  Main loop
-- ─────────────────────────────────────────────
local hadTool   = false
local backingUp = false

RunService.Heartbeat:Connect(function(dt)
    local character = localPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local myRoot   = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not myRoot then return end

    local myTool    = character:FindFirstChildOfClass("Tool")
    local holdingTool = myTool ~= nil

    if hadTool and not holdingTool then backingUp = true end
    if holdingTool then backingUp = false end
    hadTool = holdingTool

    if not enabled then
        humanoid:MoveTo(myRoot.Position)
        backingUp = false
        cameraState.active = false
        return
    end

    -- ── DEFENSE: back up + juke + wall tech ──
    if backingUp and settings.backEnabled then
        cameraState.active = false
        local bomberPlayer, bomberRoot = getPlayerHoldingBomb(myRoot)
        if bomberRoot then
            local dist    = (myRoot.Position - bomberRoot.Position).Magnitude
            local awayDir = (myRoot.Position - bomberRoot.Position)
            if awayDir.Magnitude > 0 then awayDir = awayDir.Unit end

            if dist < settings.backDistance then
                statusLabel.Text      = "💨 Backing from " .. bomberPlayer.Name
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)

                local juked = false
                if settings.jukeEnabled then
                    juked = tickJuke(dt, myRoot, awayDir, humanoid)
                end

                if not juked then
                    local retreatTarget = myRoot.Position + awayDir * settings.backDistance
                    if settings.wallTechEnabled then
                        if not applyWallTech(myRoot, awayDir, humanoid) then
                            humanoid:MoveTo(retreatTarget)
                        end
                    else
                        humanoid:MoveTo(retreatTarget)
                    end
                end
            else
                backingUp = false
                jukeState.cooldown = 0
                jukeState.active   = false
                statusLabel.Text      = "✅ Safe!"
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
            end
        else
            backingUp = false
        end
        return
    end

    -- ── Guard: must hold bomb ──
    if not holdingTool then
        statusLabel.Text      = "Must be holding the bomb"
        statusLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
        humanoid:MoveTo(myRoot.Position)
        cameraState.active = false
        return
    end

    -- ── Trigger timer check ──
    local timerValue  = getToolTimer(myTool)
    local shouldTrack = false

    if settings.triggerEnabled then
        if timerValue ~= nil then
            if timerValue <= settings.triggerTime then
                shouldTrack = true
            else
                statusLabel.Text      = "⏳ Walking to opponent... " .. string.format("%.1f", timerValue) .. "s"
                statusLabel.TextColor3 = Color3.fromRGB(200, 180, 50)
                -- AUTO-WALK instead of waiting
                autoWalkToOpponent(myRoot, humanoid)
                return
            end
        else
            shouldTrack = true
        end
    else
        shouldTrack = true
    end

    -- ── OFFENSE: track closest enemy + shiftlock camera + humanized movement ──
    if shouldTrack then
        local enemyData = getClosestEnemy(myRoot)
        if enemyData then
            local dist = (myRoot.Position - enemyData.root.Position).Magnitude
            statusLabel.Text      = "🎯 " .. enemyData.player.Name .. " | " .. math.floor(dist) .. " studs"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

            if dist > settings.stopDistance then
                -- Update shiftlock camera (with humanized spazz)
                updateShiftlockCamera(myRoot, enemyData.root.Position, dt)
                
                -- Move toward enemy with humanization or wall tech
                if settings.humanizeEnabled then
                    humanizedMoveTo(myRoot, enemyData.root.Position, humanoid, dt)
                else
                    local intendedDir = (enemyData.root.Position - myRoot.Position).Unit
                    if settings.wallTechEnabled then
                        if not applyWallTech(myRoot, intendedDir, humanoid) then
                            humanoid:MoveTo(enemyData.root.Position)
                        end
                    else
                        humanoid:MoveTo(enemyData.root.Position)
                    end
                end
            else
                humanoid:MoveTo(myRoot.Position)
                updateShiftlockCamera(myRoot, enemyData.root.Position, dt)
            end
        else
            statusLabel.Text      = "No targets found"
            statusLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
            cameraState.active = false
        end
    end
end)

-- Allow manual input to override (user can click and control character)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Keyboard then
        -- User taking manual control resets camera control temporarily
        -- But script continues running; user can switch back to auto
    end
end)
