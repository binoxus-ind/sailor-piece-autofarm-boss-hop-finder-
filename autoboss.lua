-- ============================================================
-- 🔥 AUTO BOSS FARM - DRAGGABLE UI FIXED
-- ============================================================

print("🔥 AUTO BOSS FARM WITH GUI LOADED")
print("========================================")

-- ============ CEK APAKAH SUDAH ADA GUI ============
if _G.BossFarmGUI then
    _G.BossFarmGUI:Destroy()
    _G.BossFarmGUI = nil
end

-- ============ STATE / SETTINGS ============
_G.BossFarmState = _G.BossFarmState or {
    BossName = "StrongestShinobiBoss",
    WeaponName = "Atomic",
    KillAuraRange = "200",
    AutoSkill = true,
    isRunning = false,
}

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
}

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
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -160)
    mainFrame.Size = UDim2.new(0, 400, 0, 340)
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
    
    -- ===== TITLE BAR (DRAGGABLE) =====
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
    
    -- ===== DRAG FUNCTION - FIXED =====
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end
    
    local function stopDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragStart = nil
            startPos = nil
        end
    end
    
    local function updateDrag(input)
        if dragging and dragStart and startPos and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
    
    -- Pake InputBegan dan InputEnded
    titleBar.InputBegan:Connect(startDrag)
    titleBar.InputEnded:Connect(stopDrag)
    
    -- Mouse movement
    game:GetService("UserInputService").InputChanged:Connect(updateDrag)
    
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
            print("[STATE] Boss Name saved:", _G.BossFarmState.BossName)
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
            print("[STATE] Weapon Name saved:", _G.BossFarmState.WeaponName)
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
            print("[STATE] Range saved:", _G.BossFarmState.KillAuraRange)
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
        
        print("[STATE] Auto Skill saved:", _G.BossFarmState.AutoSkill)
    end)
    
    -- ===== RETRY COUNTER LABEL =====
    local retryLabel = Instance.new("TextLabel")
    retryLabel.Name = "RetryLabel"
    retryLabel.Parent = content
    retryLabel.BackgroundTransparency = 1
    retryLabel.Size = UDim2.new(1, 0, 0, 20)
    retryLabel.Position = UDim2.new(0, 0, 0, 195)
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
    statusLabel.Position = UDim2.new(0, 0, 0, 210)
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
    actionBtn.Position = UDim2.new(0, 0, 0, 240)
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
    
    -- ===== HOP SERVER DENGAN AUTO RETRY =====
    local function hopServerWithQueue()
        debugPrint("🔄 Hopping ke server baru...")
        _G.BossFarm.RetryCount = 0
        
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local player = game.Players.LocalPlayer
        
        if not player then
            debugPrint("❌ Player not found!")
            return false
        end
        
        while _G.BossFarm.RetryCount < _G.BossFarm.MaxRetries do
            _G.BossFarm.RetryCount = _G.BossFarm.RetryCount + 1
            retryLabel.Text = "🔄 Retry " .. _G.BossFarm.RetryCount .. "/" .. _G.BossFarm.MaxRetries
            
            debugPrint("🔄 Attempt #" .. _G.BossFarm.RetryCount .. " to find server...")
            
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
                    debugPrint("✅ Server found on attempt #" .. _G.BossFarm.RetryCount)
                    
                    retryLabel.Text = "✅ Found server!"
                    task.wait(0.5)
                    retryLabel.Text = ""
                    
                    queue_on_teleport([[
                        print("✅ QUEUE ON TELEPORT EXECUTED!")
                        loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/yourusername/yourscript/main.lua"))()
                    ]])
                    
                    TeleportService:TeleportToPlaceInstance(placeId, targetServer, player)
                    debugPrint("✅ Queue on teleport set!")
                    return true
                end
            end
            
            debugPrint("⚠️ Attempt #" .. _G.BossFarm.RetryCount .. " failed, retrying...")
            retryLabel.Text = "❌ Retry " .. _G.BossFarm.RetryCount .. " failed"
            task.wait(2)
        end
        
        debugPrint("❌ All retries failed! Using fallback...")
        retryLabel.Text = "⚠️ Fallback teleport"
        task.wait(1)
        TeleportService:Teleport(placeId)
        return false
    end
    
    -- ===== TELEPORT KE BOSS DENGAN AUTO RETRY =====
    local function teleportToBossWithRetry(boss)
        debugPrint("🚀 Teleport ke boss...")
        _G.BossFarm.RetryCount = 0
        
        if not boss then
            debugPrint("❌ Boss is nil!")
            return false
        end
        
        local targetPart = nil
        targetPart = boss:FindFirstChild("HumanoidRootPart")
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
        
        while _G.BossFarm.RetryCount < _G.BossFarm.MaxRetries do
            _G.BossFarm.RetryCount = _G.BossFarm.RetryCount + 1
            retryLabel.Text = "🔄 Teleport Retry " .. _G.BossFarm.RetryCount .. "/" .. _G.BossFarm.MaxRetries
            
            debugPrint("🔄 Teleport attempt #" .. _G.BossFarm.RetryCount)
            
            local bossPos = targetPart.Position
            local targetCFrame = targetPart.CFrame * CFrame.new(0, 0, 5)
            rootPart.CFrame = targetCFrame
            
            task.wait(0.2)
            local afterPos = rootPart.Position
            local distance = (afterPos - bossPos).Magnitude
            
            debugPrint("📏 Jarak ke boss:", distance, "studs")
            
            if distance <= 15 then
                debugPrint("✅ Teleport BERHASIL! Distance:", distance)
                retryLabel.Text = "✅ Teleport success!"
                task.wait(0.5)
                retryLabel.Text = ""
                _G.BossFarm.RetryCount = 0
                return true
            else
                debugPrint("⚠️ Teleport attempt #" .. _G.BossFarm.RetryCount .. " failed, distance:", distance)
                retryLabel.Text = "❌ Retry " .. _G.BossFarm.RetryCount .. " failed"
                task.wait(1)
            end
        end
        
        debugPrint("⚠️ All teleport retries failed!")
        retryLabel.Text = "⚠️ Teleport failed"
        task.wait(1)
        retryLabel.Text = ""
        _G.BossFarm.RetryCount = 0
        return false
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
        
        updateUI()
        
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
                
                local teleportSuccess = teleportToBossWithRetry(boss)
                
                if teleportSuccess then
                    debugPrint("✅ Teleport successful!")
                    _G.BossFarm.killAuraEnabled = true
                    
                    while _G.BossFarm.isRunning and _G.BossFarm.killAuraEnabled do
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
                        
                        local bossCheck, spawned = findBoss(_G.BossFarm.BossName)
                        if not spawned then
                            debugPrint("💀 Boss mati!")
                            _G.BossFarm.killAuraEnabled = false
                            break
                        end
                        
                        task.wait(0.1)
                    end
                else
                    debugPrint("⚠️ Teleport failed after retries!")
                    statusLabel.Text = "⚠️ Teleport failed"
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
    end
    
    -- ============ START/STOP BUTTON ACTION ============
    actionBtn.MouseButton1Click:Connect(function()
        if _G.BossFarm.isRunning then
            _G.BossFarm.isRunning = false
            _G.BossFarm.killAuraEnabled = false
            _G.BossFarmState.isRunning = false
            _G.BossFarm.RetryCount = 0
            updateUI()
            statusLabel.Text = "⏸️ Stopped"
            retryLabel.Text = ""
        else
            task.spawn(autoFarmLoop)
        end
    end)
    
    -- ============ FINALIZE GUI ============
    updateUI()
    
    _G.BossFarmGUI = screenGui
    screenGui.Parent = game:GetService("CoreGui")
    
    print("✅ GUI Created Successfully!")
    print("[STATE] Loaded settings:", _G.BossFarmState)
end

-- ============ CREATE GUI ============
createGUI()

print("========================================")
print("✅ Boss Farm GUI Loaded!")
print("📌 Draggable UI - Drag title bar")
print("📌 Auto Retry on teleport failure")
print("📌 Click START to begin farming")
print("========================================")
