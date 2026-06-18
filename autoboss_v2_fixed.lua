-- ============================================================
-- 🔥 AUTO BOSS FARM - WITH TELEPORT COUNTDOWN & SERVER HOP DELAY
-- ============================================================

print("🔥 AUTO BOSS FARM WITH GUI LOADED")
print("========================================")

-- ============ FUNGSI READ/WRITE CONFIG ============
local function getConfigPath()
    local paths = {
        "workspace//BossFarmConfig.json",
        "BossFarmConfig.json",
    }
    
    for _, path in pairs(paths) do
        local success, result = pcall(function()
            return isfile(path)
        end)
        if success and result then
            return path
        end
    end
    
    return "workspace//BossFarmConfig.json"
end

local CONFIG_PATH = getConfigPath()
print("[CONFIG] Using path:", CONFIG_PATH)

-- ============ LOAD CONFIG ============
local function loadConfig()
    local defaultConfig = {
        BossName = "StrongestShinobiBoss",
        WeaponName = "Atomic",
        KillAuraRange = "200",
        AutoSkill = true,
        isRunning = false,
        TeleportDelay = true,
        ReTeleportDistance = 6,
        ServerHopDelay = 3, -- Delay sebelum hop server (detik)
    }
    
    local success, result = pcall(function()
        return isfile(CONFIG_PATH)
    end)
    
    if success and result then
        local readSuccess, content = pcall(function()
            return readfile(CONFIG_PATH)
        end)
        
        if readSuccess and content and content ~= "" then
            local decodeSuccess, config = pcall(function()
                return game:GetService("HttpService"):JSONDecode(content)
            end)
            
            if decodeSuccess and config then
                print("[CONFIG] Config loaded from file!")
                return config
            end
        end
    end
    
    print("[CONFIG] Using default config")
    return defaultConfig
end

-- ============ SAVE CONFIG ============
local function saveConfig(config)
    local success, json = pcall(function()
        return game:GetService("HttpService"):JSONEncode(config)
    end)
    
    if success and json then
        local writeSuccess, err = pcall(function()
            writefile(CONFIG_PATH, json)
        end)
        
        if writeSuccess then
            print("[CONFIG] Config saved to file!")
            return true
        end
    end
    return false
end

-- ============ LOAD STATE ============
local loadedConfig = loadConfig()

_G.BossFarmState = {
    BossName = loadedConfig.BossName or "StrongestShinobiBoss",
    WeaponName = loadedConfig.WeaponName or "Atomic",
    KillAuraRange = loadedConfig.KillAuraRange or "200",
    AutoSkill = loadedConfig.AutoSkill ~= nil and loadedConfig.AutoSkill or true,
    isRunning = loadedConfig.isRunning or false,
    TeleportDelay = loadedConfig.TeleportDelay ~= nil and loadedConfig.TeleportDelay or true,
    ReTeleportDistance = loadedConfig.ReTeleportDistance or 6,
    ServerHopDelay = loadedConfig.ServerHopDelay or 3,
}

print("[STATE] Loaded config:", _G.BossFarmState)

-- ============ CEK APAKAH SUDAH ADA GUI ============
if _G.BossFarmGUI then
    _G.BossFarmGUI:Destroy()
    _G.BossFarmGUI = nil
end

-- ============ VARIABEL GLOBAL ============
_G.BossFarm = {
    Running = false,
    BossName = _G.BossFarmState.BossName,
    WeaponName = _G.BossFarmState.WeaponName,
    KillAuraRange = tonumber(_G.BossFarmState.KillAuraRange) or 200,
    AutoSkill = _G.BossFarmState.AutoSkill,
    SkillKeys = {1, 2, 3, 4},
    SkillDelay = 0.5,
    CurrentServerId = game.JobId,
    killAuraEnabled = false,
    isRunning = _G.BossFarmState.isRunning or false,
    lastSkillTime = 0,
    RetryCount = 0,
    MaxRetries = 5,
    TeleportDelay = _G.BossFarmState.TeleportDelay,
    ReTeleportDistance = _G.BossFarmState.ReTeleportDistance or 6,
    ServerHopDelay = _G.BossFarmState.ServerHopDelay or 3,
    CancelTeleport = false,
}

-- ============ FUNGSI NOTIFICATION ============
local function sendNotification(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3,
        })
    end)
end

-- ============ BUAT GUI ============
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BossFarmGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- ===== MAIN FRAME =====
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -240)
    mainFrame.Size = UDim2.new(0, 420, 0, 480)
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    mainFrame.Selectable = true
    
    -- Shadow
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Parent = mainFrame
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.Position = UDim2.new(0.02, 0, 0.02, 0)
    shadow.Size = UDim2.new(0.96, 0, 0.96, 0)
    shadow.ZIndex = 0
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.Parent = mainFrame
    corner.CornerRadius = UDim.new(0, 12)
    
    -- ===== TITLE BAR =====
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    titleBar.BackgroundTransparency = 0
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.Active = true
    titleBar.Selectable = true
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = titleBar
    titleCorner.CornerRadius = UDim.new(0, 12)
    
    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.Text = "⚔️ Boss Farm Settings"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamSemibold
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Parent = titleBar
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    closeBtn.BackgroundTransparency = 0
    closeBtn.BorderSizePixel = 0
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.Parent = closeBtn
    closeCorner.CornerRadius = UDim.new(0, 6)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        _G.BossFarmGUI = nil
    end)
    
    -- ===== DRAG FUNCTION =====
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local UserInputService = game:GetService("UserInputService")
    
    local function isInTitleBar(position)
        local absPos = titleBar.AbsolutePosition
        local absSize = titleBar.AbsoluteSize
        return position.X >= absPos.X and position.X <= absPos.X + absSize.X and
               position.Y >= absPos.Y and position.Y <= absPos.Y + absSize.Y
    end
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            if isInTitleBar(input.Position) then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragStart = nil
            startPos = nil
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.TouchMoved:Connect(function(touch)
        if dragging and dragStart and startPos then
            local delta = touch.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- ===== CONTENT FRAME =====
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Parent = mainFrame
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 15, 0, 55)
    content.Size = UDim2.new(1, -30, 1, -70)
    
    -- ===== BOSS NAME INPUT =====
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = content
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0, 25)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.Text = "🎯 Boss Name"
    nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.Gotham
    
    local nameBox = Instance.new("TextBox")
    nameBox.Name = "BossNameBox"
    nameBox.Parent = content
    nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    nameBox.BorderSizePixel = 0
    nameBox.Position = UDim2.new(0, 0, 0, 25)
    nameBox.Size = UDim2.new(1, 0, 0, 30)
    nameBox.PlaceholderText = "Enter boss name..."
    nameBox.Text = _G.BossFarmState.BossName
    nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameBox.TextSize = 14
    nameBox.Font = Enum.Font.Gotham
    nameBox.ClearTextOnFocus = false
    
    local nameCorner = Instance.new("UICorner")
    nameCorner.Parent = nameBox
    nameCorner.CornerRadius = UDim.new(0, 6)
    
    nameBox.FocusLost:Connect(function()
        if nameBox.Text ~= "" then
            _G.BossFarmState.BossName = nameBox.Text
            _G.BossFarm.BossName = nameBox.Text
            saveConfig(_G.BossFarmState)
        end
    end)
    
    -- ===== WEAPON NAME INPUT =====
    local weaponLabel = Instance.new("TextLabel")
    weaponLabel.Parent = content
    weaponLabel.BackgroundTransparency = 1
    weaponLabel.Size = UDim2.new(1, 0, 0, 25)
    weaponLabel.Position = UDim2.new(0, 0, 0, 65)
    weaponLabel.Text = "🔧 Weapon Name"
    weaponLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    weaponLabel.TextSize = 14
    weaponLabel.TextXAlignment = Enum.TextXAlignment.Left
    weaponLabel.Font = Enum.Font.Gotham
    
    local weaponBox = Instance.new("TextBox")
    weaponBox.Name = "WeaponNameBox"
    weaponBox.Parent = content
    weaponBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    weaponBox.BorderSizePixel = 0
    weaponBox.Position = UDim2.new(0, 0, 0, 90)
    weaponBox.Size = UDim2.new(1, 0, 0, 30)
    weaponBox.PlaceholderText = "Enter weapon name..."
    weaponBox.Text = _G.BossFarmState.WeaponName
    weaponBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    weaponBox.TextSize = 14
    weaponBox.Font = Enum.Font.Gotham
    weaponBox.ClearTextOnFocus = false
    
    local weaponCorner = Instance.new("UICorner")
    weaponCorner.Parent = weaponBox
    weaponCorner.CornerRadius = UDim.new(0, 6)
    
    weaponBox.FocusLost:Connect(function()
        if weaponBox.Text ~= "" then
            _G.BossFarmState.WeaponName = weaponBox.Text
            _G.BossFarm.WeaponName = weaponBox.Text
            saveConfig(_G.BossFarmState)
        end
    end)
    
    -- ===== RANGE INPUT =====
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Parent = content
    rangeLabel.BackgroundTransparency = 1
    rangeLabel.Size = UDim2.new(0.5, 0, 0, 25)
    rangeLabel.Position = UDim2.new(0, 0, 0, 130)
    rangeLabel.Text = "📡 Range"
    rangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    rangeLabel.TextSize = 14
    rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
    rangeLabel.Font = Enum.Font.Gotham
    
    local rangeBox = Instance.new("TextBox")
    rangeBox.Name = "RangeBox"
    rangeBox.Parent = content
    rangeBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    rangeBox.BorderSizePixel = 0
    rangeBox.Position = UDim2.new(0, 0, 0, 155)
    rangeBox.Size = UDim2.new(0.4, 0, 0, 30)
    rangeBox.PlaceholderText = "200"
    rangeBox.Text = _G.BossFarmState.KillAuraRange
    rangeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeBox.TextSize = 14
    rangeBox.Font = Enum.Font.Gotham
    rangeBox.ClearTextOnFocus = false
    
    local rangeCorner = Instance.new("UICorner")
    rangeCorner.Parent = rangeBox
    rangeCorner.CornerRadius = UDim.new(0, 6)
    
    rangeBox.FocusLost:Connect(function()
        local num = tonumber(rangeBox.Text)
        if num then
            _G.BossFarmState.KillAuraRange = rangeBox.Text
            _G.BossFarm.KillAuraRange = num
            saveConfig(_G.BossFarmState)
        end
    end)
    
    -- ===== AUTO SKILL TOGGLE =====
    local skillToggle = Instance.new("TextButton")
    skillToggle.Name = "SkillToggle"
    skillToggle.Parent = content
    skillToggle.BackgroundColor3 = _G.BossFarmState.AutoSkill and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    skillToggle.BorderSizePixel = 0
    skillToggle.Position = UDim2.new(0.55, 0, 0, 155)
    skillToggle.Size = UDim2.new(0.4, 0, 0, 30)
    skillToggle.Text = _G.BossFarmState.AutoSkill and "✅ Auto Skill ON" or "❌ Auto Skill OFF"
    skillToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    skillToggle.TextSize = 13
    skillToggle.Font = Enum.Font.GothamBold
    
    local skillCorner = Instance.new("UICorner")
    skillCorner.Parent = skillToggle
    skillCorner.CornerRadius = UDim.new(0, 6)
    
    skillToggle.MouseButton1Click:Connect(function()
        _G.BossFarmState.AutoSkill = not _G.BossFarmState.AutoSkill
        _G.BossFarm.AutoSkill = _G.BossFarmState.AutoSkill
        
        skillToggle.BackgroundColor3 = _G.BossFarmState.AutoSkill and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        skillToggle.Text = _G.BossFarmState.AutoSkill and "✅ Auto Skill ON" or "❌ Auto Skill OFF"
        saveConfig(_G.BossFarmState)
    end)
    
    -- ===== TELEPORT DELAY TOGGLE =====
    local delayToggle = Instance.new("TextButton")
    delayToggle.Name = "DelayToggle"
    delayToggle.Parent = content
    delayToggle.BackgroundColor3 = _G.BossFarmState.TeleportDelay and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    delayToggle.BorderSizePixel = 0
    delayToggle.Position = UDim2.new(0, 0, 0, 195)
    delayToggle.Size = UDim2.new(1, 0, 0, 25)
    delayToggle.Text = _G.BossFarmState.TeleportDelay and "⏱️ Teleport Delay: ON" or "⏱️ Teleport Delay: OFF"
    delayToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    delayToggle.TextSize = 13
    delayToggle.Font = Enum.Font.GothamBold
    
    local delayCorner = Instance.new("UICorner")
    delayCorner.Parent = delayToggle
    delayCorner.CornerRadius = UDim.new(0, 6)
    
    delayToggle.MouseButton1Click:Connect(function()
        _G.BossFarmState.TeleportDelay = not _G.BossFarmState.TeleportDelay
        _G.BossFarm.TeleportDelay = _G.BossFarmState.TeleportDelay
        
        delayToggle.BackgroundColor3 = _G.BossFarmState.TeleportDelay and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        delayToggle.Text = _G.BossFarmState.TeleportDelay and "⏱️ Teleport Delay: ON" or "⏱️ Teleport Delay: OFF"
        saveConfig(_G.BossFarmState)
    end)
    
    -- ===== RE-TELEPORT DISTANCE INPUT =====
    local reTeleLabel = Instance.new("TextLabel")
    reTeleLabel.Parent = content
    reTeleLabel.BackgroundTransparency = 1
    reTeleLabel.Size = UDim2.new(0.5, 0, 0, 25)
    reTeleLabel.Position = UDim2.new(0, 0, 0, 225)
    reTeleLabel.Text = "🔄 Re-Teleport at"
    reTeleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    reTeleLabel.TextSize = 13
    reTeleLabel.TextXAlignment = Enum.TextXAlignment.Left
    reTeleLabel.Font = Enum.Font.Gotham
    
    local reTeleBox = Instance.new("TextBox")
    reTeleBox.Name = "ReTeleBox"
    reTeleBox.Parent = content
    reTeleBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    reTeleBox.BorderSizePixel = 0
    reTeleBox.Position = UDim2.new(0.5, 0, 0, 225)
    reTeleBox.Size = UDim2.new(0.2, 0, 0, 25)
    reTeleBox.PlaceholderText = "6"
    reTeleBox.Text = tostring(_G.BossFarmState.ReTeleportDistance or 6)
    reTeleBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    reTeleBox.TextSize = 13
    reTeleBox.Font = Enum.Font.Gotham
    reTeleBox.ClearTextOnFocus = false
    
    local reTeleCorner = Instance.new("UICorner")
    reTeleCorner.Parent = reTeleBox
    reTeleCorner.CornerRadius = UDim.new(0, 6)
    
    reTeleBox.FocusLost:Connect(function()
        local num = tonumber(reTeleBox.Text)
        if num and num > 0 then
            _G.BossFarmState.ReTeleportDistance = num
            _G.BossFarm.ReTeleportDistance = num
            saveConfig(_G.BossFarmState)
        end
    end)
    
    -- ===== SERVER HOP DELAY INPUT (NEW) =====
    local hopDelayLabel = Instance.new("TextLabel")
    hopDelayLabel.Parent = content
    hopDelayLabel.BackgroundTransparency = 1
    hopDelayLabel.Size = UDim2.new(0.5, 0, 0, 25)
    hopDelayLabel.Position = UDim2.new(0, 0, 0, 255)
    hopDelayLabel.Text = "🌐 Server Hop Delay"
    hopDelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    hopDelayLabel.TextSize = 13
    hopDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
    hopDelayLabel.Font = Enum.Font.Gotham
    
    local hopDelayBox = Instance.new("TextBox")
    hopDelayBox.Name = "HopDelayBox"
    hopDelayBox.Parent = content
    hopDelayBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    hopDelayBox.BorderSizePixel = 0
    hopDelayBox.Position = UDim2.new(0.5, 0, 0, 255)
    hopDelayBox.Size = UDim2.new(0.2, 0, 0, 25)
    hopDelayBox.PlaceholderText = "3"
    hopDelayBox.Text = tostring(_G.BossFarmState.ServerHopDelay or 3)
    hopDelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    hopDelayBox.TextSize = 13
    hopDelayBox.Font = Enum.Font.Gotham
    hopDelayBox.ClearTextOnFocus = false
    
    local hopDelayCorner = Instance.new("UICorner")
    hopDelayCorner.Parent = hopDelayBox
    hopDelayCorner.CornerRadius = UDim.new(0, 6)
    
    hopDelayBox.FocusLost:Connect(function()
        local num = tonumber(hopDelayBox.Text)
        if num and num > 0 then
            _G.BossFarmState.ServerHopDelay = num
            _G.BossFarm.ServerHopDelay = num
            saveConfig(_G.BossFarmState)
            print("[STATE] Server Hop Delay saved:", num)
        end
    end)
    
    -- ===== RETRY COUNTER LABEL =====
    local retryLabel = Instance.new("TextLabel")
    retryLabel.Name = "RetryLabel"
    retryLabel.Parent = content
    retryLabel.BackgroundTransparency = 1
    retryLabel.Size = UDim2.new(1, 0, 0, 20)
    retryLabel.Position = UDim2.new(0, 0, 0, 285)
    retryLabel.Text = ""
    retryLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    retryLabel.TextSize = 12
    retryLabel.Font = Enum.Font.Gotham
    
    -- ===== STATUS LABEL =====
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Parent = content
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, 0, 0, 25)
    statusLabel.Position = UDim2.new(0, 0, 0, 305)
    statusLabel.Text = _G.BossFarm.isRunning and "🔄 Running" or "⏸️ Idle"
    statusLabel.TextColor3 = _G.BossFarm.isRunning and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(150, 150, 150)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    
    -- ===== START/STOP BUTTON =====
    local actionBtn = Instance.new("TextButton")
    actionBtn.Name = "ActionBtn"
    actionBtn.Parent = content
    actionBtn.BackgroundColor3 = _G.BossFarm.isRunning and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(50, 150, 255)
    actionBtn.BorderSizePixel = 0
    actionBtn.Position = UDim2.new(0, 0, 0, 335)
    actionBtn.Size = UDim2.new(1, 0, 0, 40)
    actionBtn.Text = _G.BossFarm.isRunning and "⏹️ Stop" or "▶️ Start"
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.TextSize = 16
    actionBtn.Font = Enum.Font.GothamBold
    
    local actionCorner = Instance.new("UICorner")
    actionCorner.Parent = actionBtn
    actionCorner.CornerRadius = UDim.new(0, 8)
    
    -- ===== UPDATE UI =====
    local function updateUI()
        if _G.BossFarm.isRunning then
            actionBtn.Text = "⏹️ Stop"
            actionBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
            statusLabel.Text = "🔄 Farming " .. _G.BossFarm.BossName
            statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            _G.BossFarmState.isRunning = true
        else
            actionBtn.Text = "▶️ Start"
            actionBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
            statusLabel.Text = "⏸️ Idle"
            statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            _G.BossFarmState.isRunning = false
            retryLabel.Text = ""
            _G.BossFarm.RetryCount = 0
        end
    end
    
    -- ============ CORE SCRIPT ============
    local function debugPrint(...)
        local args = {...}
        local msg = ""
        for i, v in ipairs(args) do
            msg = msg .. tostring(v) .. " "
        end
        print("[BOSS FARM] " .. msg)
    end
    
    local function findBoss(bossname)
        local NPCsFolder = workspace:FindFirstChild("NPCs")
        if NPCsFolder then
            for _, v in pairs(NPCsFolder:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("Boss") and v:FindFirstChild("Boss").Value == true then
                    if v.Name == bossname then
                        local humanoid = v:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            return v, true
                        end
                    end
                end
            end
        end
        return nil, false
    end
    
    -- ===== TELEPORT COUNTDOWN =====
    local function teleportCountdown()
        if not _G.BossFarm.TeleportDelay then
            return true
        end
        
        _G.BossFarm.CancelTeleport = false
        local countdown = 2
        
        sendNotification("⏱️ Teleport in " .. countdown .. "s", "Click STOP to cancel", 3)
        
        while countdown > 0 do
            if _G.BossFarm.CancelTeleport then
                sendNotification("❌ Teleport Cancelled", "You stopped the teleport", 2)
                return false
            end
            
            if not _G.BossFarm.isRunning then
                return false
            end
            
            if countdown > 1 then
                sendNotification("⏱️ Teleport in " .. countdown .. "s", "Click STOP to cancel", 1)
            end
            
            task.wait(1)
            countdown = countdown - 1
        end
        
        if _G.BossFarm.CancelTeleport or not _G.BossFarm.isRunning then
            return false
        end
        
        sendNotification("🚀 Teleporting!", "Moving to boss location", 2)
        return true
    end
    
    -- ===== SERVER HOP DELAY =====
    local function serverHopDelay()
        local delay = _G.BossFarm.ServerHopDelay or 3
        if delay <= 0 then return true end
        
        debugPrint("⏳ Server hop delay:", delay, "detik")
        sendNotification("⏳ Hopping in " .. delay .. "s", "Click STOP to cancel", 3)
        
        for i = delay, 1, -1 do
            if not _G.BossFarm.isRunning then
                debugPrint("❌ Hop cancelled - farm stopped")
                return false
            end
            
            if i > 1 then
                sendNotification("⏳ Hopping in " .. i .. "s", "Click STOP to cancel", 1)
            end
            task.wait(1)
        end
        
        if not _G.BossFarm.isRunning then
            return false
        end
        
        sendNotification("🌐 Hopping Server!", "Searching for boss...", 2)
        return true
    end
    
    -- ===== HOP SERVER =====
    local function hopServerWithQueue()
        debugPrint("🔄 Hopping ke server baru...")
        _G.BossFarm.RetryCount = 0
        
        -- ===== SERVER HOP DELAY =====
        if not serverHopDelay() then
            debugPrint("⚠️ Server hop cancelled!")
            return false
        end
        
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local player = game.Players.LocalPlayer
        
        if not player then
            debugPrint("❌ Player not found!")
            return false
        end
        
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(
                game:HttpGetAsync("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100")
            )
        end)
        
        if success and result and result.data then
            local servers = {}
            for _, v in ipairs(result.data) do
                if v.id ~= game.JobId and v.playing < v.maxPlayers then
                    table.insert(servers, v.id)
                end
            end
            
            if #servers > 0 then
                local targetServer = servers[math.random(1, #servers)]
                debugPrint("🎯 Target server:", targetServer)
                
                local queueSuccess, queueErr = pcall(function()
                    queue_on_teleport([[
                        print("✅ QUEUE ON TELEPORT EXECUTED!")
                        loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/binoxus-ind/sailor-piece-autofarm-boss-hop-finder-/refs/heads/main/autoboss_v2_fixed.lua"))()
                    ]])
                end)
                
                if not queueSuccess then
                    debugPrint("⚠️ Queue on teleport error:", queueErr)
                else
                    debugPrint("✅ Queue on teleport set!")
                end
                
                TeleportService:TeleportToPlaceInstance(placeId, targetServer, player)
                return true
            end
        end
        
        debugPrint("🔄 Fallback: Teleport biasa")
        TeleportService:Teleport(placeId)
        return false
    end
    
    -- ===== GET TARGET PART =====
    local function getTargetPart(boss)
        if not boss then return nil end
        
        local targetPart = boss:FindFirstChild("HumanoidRootPart")
        if not targetPart then
            targetPart = boss.PrimaryPart
        end
        if not targetPart then
            for _, child in pairs(boss:GetChildren()) do
                if child:IsA("BasePart") then
                    targetPart = child
                    break
                end
            end
        end
        return targetPart
    end
    
    -- ===== TELEPORT KE BOSS =====
    local function teleportToBoss(boss)
        if not boss then
            debugPrint("❌ Boss is nil!")
            return false
        end
        
        local targetPart = getTargetPart(boss)
        if not targetPart then
            debugPrint("❌ No valid part found!")
            return false
        end
        
        local player = game.Players.LocalPlayer
        if not player or not player.Character then
            debugPrint("❌ Player not ready!")
            return false
        end
        
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            debugPrint("❌ HumanoidRootPart not found!")
            return false
        end
        
        -- Teleport
        local bossPos = targetPart.Position
        local targetCFrame = targetPart.CFrame * CFrame.new(0, 0, 5)
        rootPart.CFrame = targetCFrame
        
        task.wait(0.2)
        local afterPos = rootPart.Position
        local distance = (afterPos - bossPos).Magnitude
        
        debugPrint("📏 Jarak ke boss:", distance, "studs")
        
        if distance <= 15 then
            debugPrint("✅ Teleport BERHASIL! Distance:", distance)
            return true
        else
            debugPrint("⚠️ Teleport GAGAL! Distance:", distance)
            return false
        end
    end
    
    -- ===== TELEPORT DENGAN COUNTDOWN & RE-TELEPORT =====
    local function teleportWithCountdownAndRetry(boss)
        debugPrint("🚀 Memulai proses teleport...")
        
        -- COUNTDOWN
        if not teleportCountdown() then
            debugPrint("⚠️ Teleport cancelled by user!")
            return false
        end
        
        -- TELEPORT
        local success = teleportToBoss(boss)
        
        if success then
            return true
        else
            -- RE-TELEPORT OTOMATIS
            debugPrint("🔄 Teleport gagal, mencoba re-teleport...")
            sendNotification("🔄 Re-Teleporting", "Attempting again...", 2)
            
            -- Coba ulang 3x
            for i = 1, 3 do
                if not _G.BossFarm.isRunning then
                    return false
                end
                
                retryLabel.Text = "🔄 Re-Teleport attempt " .. i .. "/3"
                debugPrint("🔄 Re-teleport attempt #" .. i)
                
                task.wait(0.5)
                success = teleportToBoss(boss)
                
                if success then
                    retryLabel.Text = "✅ Re-Teleport success!"
                    task.wait(0.5)
                    retryLabel.Text = ""
                    sendNotification("✅ Re-Teleport Success!", "Arrived at boss", 2)
                    return true
                end
                
                task.wait(0.5)
            end
            
            retryLabel.Text = "❌ Re-Teleport failed"
            task.wait(0.5)
            retryLabel.Text = ""
            return false
        end
    end
    
    -- ===== MONITOR POSISI =====
    local function monitorPosition(boss)
        if not boss then return true end
        
        local targetPart = getTargetPart(boss)
        if not targetPart then return true end
        
        local player = game.Players.LocalPlayer
        if not player or not player.Character then return true end
        
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return true end
        
        local distance = (rootPart.Position - targetPart.Position).Magnitude
        local triggerDistance = _G.BossFarm.ReTeleportDistance or 6
        
        if distance > triggerDistance then
            debugPrint("⚠️ Player terlalu jauh dari boss! Jarak:", distance, ">", triggerDistance)
            sendNotification("🔄 Player terlalu jauh!", "Re-teleporting...", 2)
            return false
        end
        
        return true
    end
    
    local function equipWeapon(weaponName)
        local player = game.Players.LocalPlayer
        if not player then return false end
        
        local character = player.Character
        if not character then return false end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return false end
        
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == weaponName then
                return true
            end
        end
        
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == weaponName then
                    debugPrint("🔧 Equip weapon:", weaponName)
                    humanoid:EquipTool(tool)
                    task.wait(0.1)
                    return true
                end
            end
        end
        
        return false
    end
    
    local function castSkill(skillIndex)
        local player = game.Players.LocalPlayer
        if not player or not player.Character then return end
        
        local remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("AbilitySystem")
        if remoteEvent then
            remoteEvent = remoteEvent:FindFirstChild("Remotes")
            if remoteEvent then
                remoteEvent = remoteEvent:FindFirstChild("RequestAbility")
            end
        end
        
        if not remoteEvent then
            remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            if remoteEvent then
                remoteEvent = remoteEvent:FindFirstChild("RequestAbility")
            end
        end
        
        if not remoteEvent then
            remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RequestAbility")
        end
        
        if remoteEvent then
            pcall(function()
                remoteEvent:FireServer(skillIndex)
            end)
        end
    end
    
    local function getHitboxPosition(npc)
        local rootPart = npc:FindFirstChild("HumanoidRootPart")
        if rootPart then return rootPart.Position end
        if npc.PrimaryPart then return npc.PrimaryPart.Position end
        for _, child in pairs(npc:GetChildren()) do
            if child:IsA("BasePart") then
                return child.Position
            end
        end
        return nil
    end
    
    -- ============ MAIN FARM LOOP ============
    local function autoFarmLoop()
        debugPrint("🚀 Starting auto farm for:", _G.BossFarm.BossName)
        
        _G.BossFarm.isRunning = true
        _G.BossFarm.killAuraEnabled = false
        _G.BossFarm.lastSkillTime = 0
        _G.BossFarm.CurrentServerId = game.JobId
        _G.BossFarm.RetryCount = 0
        _G.BossFarm.CancelTeleport = false
        
        updateUI()
        saveConfig(_G.BossFarmState)
        sendNotification("✅ Auto Farm Started", "Target: " .. _G.BossFarm.BossName, 3)
        
        while _G.BossFarm.isRunning do
            local player = game.Players.LocalPlayer
            if not player or not player.Character then
                task.wait(1)
                continue
            end
            
            if game.JobId ~= _G.BossFarm.CurrentServerId then
                _G.BossFarm.CurrentServerId = game.JobId
                debugPrint("🔄 Server baru:", _G.BossFarm.CurrentServerId)
                _G.BossFarm.killAuraEnabled = false
                _G.BossFarm.lastSkillTime = 0
                
                repeat
                    task.wait(0.5)
                until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
                
                task.wait(1)
            end
            
            local boss, isSpawned = findBoss(_G.BossFarm.BossName)
            
            if isSpawned and boss then
                statusLabel.Text = "✅ Found " .. _G.BossFarm.BossName
                
                equipWeapon(_G.BossFarm.WeaponName)
                
                -- TELEPORT DENGAN COUNTDOWN & RE-TELEPORT
                local teleportSuccess = teleportWithCountdownAndRetry(boss)
                
                if teleportSuccess then
                    debugPrint("✅ Teleport successful!")
                    _G.BossFarm.killAuraEnabled = true
                    
                    while _G.BossFarm.isRunning and _G.BossFarm.killAuraEnabled do
                        -- CEK POSISI PLAYER TERHADAP BOSS
                        if not monitorPosition(boss) then
                            debugPrint("🔄 Player terlalu jauh, re-teleporting...")
                            _G.BossFarm.killAuraEnabled = false
                            
                            -- Coba re-teleport
                            local reTeleSuccess = teleportWithCountdownAndRetry(boss)
                            if reTeleSuccess then
                                debugPrint("✅ Re-teleport success, resuming kill aura...")
                                _G.BossFarm.killAuraEnabled = true
                            else
                                debugPrint("❌ Re-teleport failed!")
                                break
                            end
                        end
                        
                        local player2 = game.Players.LocalPlayer
                        if not player2 or not player2.Character then 
                            task.wait(0.1)
                            continue 
                        end
                        
                        local rootPart = player2.Character:FindFirstChild("HumanoidRootPart")
                        if not rootPart then 
                            task.wait(0.1)
                            continue 
                        end
                        
                        equipWeapon(_G.BossFarm.WeaponName)
                        
                        if _G.BossFarm.AutoSkill then
                            local currentTime = tick()
                            if currentTime - _G.BossFarm.lastSkillTime >= _G.BossFarm.SkillDelay then
                                for _, skillIndex in pairs(_G.BossFarm.SkillKeys) do
                                    if _G.BossFarm.killAuraEnabled then
                                        castSkill(skillIndex)
                                        task.wait(0.1)
                                    end
                                end
                                _G.BossFarm.lastSkillTime = currentTime
                            end
                        end
                        
                        local NPCsFolder = workspace:FindFirstChild("NPCs")
                        if NPCsFolder then
                            local playerPos = rootPart.Position
                            
                            for _, npc in pairs(NPCsFolder:GetChildren()) do
                                if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                                    local humanoid = npc:FindFirstChild("Humanoid")
                                    if humanoid and humanoid.Health > 0 then
                                        local npcPos = getHitboxPosition(npc)
                                        if npcPos then
                                            local distance = (playerPos - npcPos).Magnitude
                                            if distance <= _G.BossFarm.KillAuraRange then
                                                local remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("CombatSystem")
                                                if remoteEvent then
                                                    remoteEvent = remoteEvent:FindFirstChild("Remotes")
                                                    if remoteEvent then
                                                        remoteEvent = remoteEvent:FindFirstChild("RequestHit")
                                                    end
                                                end
                                                if not remoteEvent then
                                                    remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RequestHit")
                                                end
                                                if remoteEvent then
                                                    remoteEvent:FireServer(npcPos)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        -- CEK BOSS MASIH HIDUP
                        local bossCheck, spawned = findBoss(_G.BossFarm.BossName)
                        if not spawned then
                            debugPrint("💀 Boss mati!")
                            _G.BossFarm.killAuraEnabled = false
                            sendNotification("💀 Boss Defeated!", "Searching for next...", 2)
                            break
                        end
                        
                        task.wait(0.1)
                    end
                else
                    debugPrint("⚠️ Teleport failed after retries!")
                    statusLabel.Text = "⚠️ Teleport failed"
                    sendNotification("❌ Teleport Failed", "Retrying...", 2)
                end
                
                task.wait(1)
                
            else
                statusLabel.Text = "❌ Not found - Hopping..."
                debugPrint("❌ Boss tidak ditemukan! Hop server...")
                
                _G.BossFarm.killAuraEnabled = false
                
                local oldJobId = game.JobId
                hopServerWithQueue()
                
                repeat
                    task.wait(1)
                until game.JobId ~= oldJobId or not _G.BossFarm.isRunning
                
                _G.BossFarm.CurrentServerId = game.JobId
                
                repeat
                    task.wait(0.5)
                until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
                
                task.wait(1)
            end
        end
        
        debugPrint("🛑 Auto farm stopped!")
        updateUI()
        saveConfig(_G.BossFarmState)
        sendNotification("🛑 Auto Farm Stopped", "Farm has been stopped", 2)
    end
    
    -- ============ START/STOP BUTTON ACTION ============
    actionBtn.MouseButton1Click:Connect(function()
        if _G.BossFarm.isRunning then
            _G.BossFarm.isRunning = false
            _G.BossFarm.killAuraEnabled = false
            _G.BossFarm.CancelTeleport = true
            _G.BossFarmState.isRunning = false
            saveConfig(_G.BossFarmState)
            updateUI()
            statusLabel.Text = "⏸️ Stopped"
            retryLabel.Text = ""
            sendNotification("🛑 Stopped", "Auto farm stopped", 2)
            print("[BUTTON] Stopped")
        else
            _G.BossFarmState.isRunning = true
            saveConfig(_G.BossFarmState)
            updateUI()
            print("[BUTTON] Started")
            task.spawn(autoFarmLoop)
        end
    end)
    
    -- ============ AUTO START ============
    if _G.BossFarmState.isRunning then
        print("[AUTO] Detected running state, auto-starting...")
        task.spawn(autoFarmLoop)
    end
    
    -- ============ FINALIZE GUI ============
    updateUI()
    
    _G.BossFarmGUI = screenGui
    screenGui.Parent = game:GetService("CoreGui")
    
    print("✅ GUI Created Successfully!")
    print("[STATE] Loaded config:", _G.BossFarmState)
    print("[CONFIG] Config saved to:", CONFIG_PATH)
end

-- ============ CREATE GUI ============
createGUI()

print("========================================")
print("✅ Boss Farm GUI Loaded!")
print("📌 Draggable - PC & Mobile (FIXED)")
print("📌 Config saved to file (permanent)")
print("📌 Auto resume on reload")
print("📌 Teleport Delay: 2 seconds (toggle)")
print("📌 Auto Re-Teleport if too far")
print("📌 Server Hop Delay: " .. _G.BossFarm.ServerHopDelay .. " seconds")
print("========================================")
