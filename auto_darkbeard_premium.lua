-- Khởi tạo thông báo
local Notification = require(game:GetService("ReplicatedStorage").Notification)
Notification.new("<Color=Cyan>W-MB<Color=/>"):Display()
task.wait(0.25)

-- Chờ người chơi
repeat task.wait() until game.Players.LocalPlayer
task.wait(2.5)

-- Khởi tạo UI
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("PlayerGui not found!")
    return
end

local gui = Instance.new("ScreenGui")
gui.Name = "DoughOverlay"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 0.4
background.Visible = true
background.Parent = gui

local topText = Instance.new("TextLabel")
topText.Size = UDim2.new(1, 0, 0.1, 0)
topText.Position = UDim2.new(0, 0, 0, 0)
topText.BackgroundTransparency = 1
topText.Text = "W-MB | Auto Darkbeard"
topText.TextColor3 = Color3.fromRGB(255, 255, 255)
topText.TextScaled = true
topText.Font = Enum.Font.FredokaOne
topText.Parent = background

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0.05, 0)
statusText.Position = UDim2.new(0, 0, 0.08, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "Status: Initializing..."
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.TextScaled = true
statusText.Font = Enum.Font.FredokaOne
statusText.Parent = background

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(1, 0, 0.04, 0)
timeLabel.Position = UDim2.new(0, 0, 0.9, 0)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "Time: 0 Hours 0 Minutes 0 Seconds"
timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timeLabel.TextScaled = true
timeLabel.Font = Enum.Font.FredokaOne
timeLabel.Parent = background

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 200, 0, 200)
logo.Position = UDim2.new(0.5, -100, 0.4, -100)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://103669192616432" -- Kiểm tra ID này
logo.Parent = background

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0.95, 0, 0.05, 0)
infoLabel.Position = UDim2.new(0.025, 0, 0.94, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.new(1, 1, 1)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.FredokaOne
infoLabel.Text = "Loading..."
infoLabel.Parent = background

spawn(function()
    while wait(1) do
        pcall(function()
            if player.Data and player.Data.Level and player.Data.Beli and player.Data.Fragments then
                local level = player.Data.Level.Value
                local beli = player.Data.Beli.Value
                local frags = player.Data.Fragments.Value
                infoLabel.Text = "Player: " .. player.DisplayName .. " | Level: " .. level .. " | Beli: " .. beli .. " | Fragments: " .. frags
            else
                infoLabel.Text = "Player: " .. player.DisplayName .. " | Data not available"
            end
        end)
    end
end)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(0, 15, 0, 70)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundTransparency = 0.1
toggleButton.BorderSizePixel = 0
toggleButton.Text = "Open"
toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamSemibold
toggleButton.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = toggleButton

local isOpen = false
toggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    background.Visible = isOpen
    toggleButton.Text = isOpen and "Close" or "Open"
end)

local seconds = 0
spawn(function()
    while wait(1) do
        seconds += 1
        local hrs = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        local secs = seconds % 60
        timeLabel.Text = "Time: " .. hrs .. " Hours " .. mins .. " Minutes " .. secs .. " Seconds"
    end
end)

-- Các cài đặt ban đầu
setclipboard("")
game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Marines")
require(game.ReplicatedStorage.Util.CameraShaker):Stop()

-- Xác định thế giới
local World1, World2, World3
if game.PlaceId == 2753915549 then
    World1 = true
elseif game.PlaceId == 4442272183 then
    World2 = true
elseif game.PlaceId == 7449423635 then
    World3 = true
else
    statusText.Text = "Status: Wrong Sea, please go to Second Sea (PlaceId: " .. game.PlaceId .. ")"
    warn("Invalid PlaceId: " .. game.PlaceId)
    return
end

if not World2 then
    statusText.Text = "Status: Please go to Second Sea"
    return
end

-- Hàm hỗ trợ
function WaitHRP(player)
    if not player then return end
    local character = player.Character
    if character then
        return character:WaitForChild("HumanoidRootPart", 9)
    end
    return nil
end

-- Hàm teleport
local isTeleporting = false
function CheckNearestTeleporter(pos)
    local vcspos = pos.Position
    local minDist = math.huge
    local chosenTeleport = nil
    local TableLocations = {
        ["Kingdom of Rose"] = Vector3.new(-394, 139, 2289),
        ["Dark Arena"] = Vector3.new(3876, 15, -3889),
        ["Green Zone"] = Vector3.new(-2250, 73, -2819)
    }
    
    for _, v in pairs(TableLocations) do
        local dist = (v - vcspos).Magnitude
        if dist < minDist then
            minDist = dist
            chosenTeleport = v
        end
    end

    local playerPos = WaitHRP(game.Players.LocalPlayer) and game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    if playerPos and minDist <= (vcspos - playerPos).Magnitude then
        return chosenTeleport
    end
end

function requestEntrance(teleportPos)
    pcall(function()
        game.ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", teleportPos)
        local char = WaitHRP(game.Players.LocalPlayer)
        if char then
            char.CFrame = char.CFrame + Vector3.new(0, 50, 0)
        end
    end)
    task.wait(0.5)
end

function topos(pos)
    local plr = game.Players.LocalPlayer
    local hrp = WaitHRP(plr)
    if not hrp or not plr.Character or not plr.Character.Humanoid or plr.Character.Humanoid.Health <= 0 then
        statusText.Text = "Status: Waiting for character..."
        task.wait(1)
        return
    end

    local distance = (pos.Position - hrp.Position).Magnitude
    local nearestTeleport = distance > 1000 and CheckNearestTeleporter(pos)
    
    if nearestTeleport then
        requestEntrance(nearestTeleport)
        task.wait(1)
    end

    local partTele = plr.Character:FindFirstChild("PartTele")
    if not partTele then
        partTele = Instance.new("Part", plr.Character)
        partTele.Size = Vector3.new(10, 1, 10)
        partTele.Name = "PartTele"
        partTele.Anchored = true
        partTele.Transparency = 1
        partTele.CanCollide = false
        partTele.CFrame = hrp.CFrame
        
        partTele:GetPropertyChangedSignal("CFrame"):Connect(function()
            if not isTeleporting then return end
            task.wait()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local targetCFrame = partTele.CFrame
                WaitHRP(plr).CFrame = CFrame.new(targetCFrame.Position.X, pos.Position.Y, targetCFrame.Position.Z)
            end
        end)
    end
    
    isTeleporting = true
    local speed = getgenv().TweenSpeed or 350
    if distance <= 250 then
        speed = speed * 3
    end

    local tween = game:GetService("TweenService"):Create(
        partTele,
        TweenInfo.new(distance / speed, Enum.EasingStyle.Linear),
        {CFrame = pos}
    )
    tween:Play()
    
    tween.Completed:Connect(function(status)
        if status == Enum.PlaybackState.Completed then
            if plr.Character:FindFirstChild("PartTele") then
                plr.Character.PartTele:Destroy()
            end
            isTeleporting = false
        end
    end)
end

function stopTeleport()
    isTeleporting = false
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character:FindFirstChild("PartTele") then
        plr.Character.PartTele:Destroy()
    end
end

spawn(function()
    while task.wait() do
        if not isTeleporting then
            stopTeleport()
        end
    end
end)

spawn(function()
    local plr = game.Players.LocalPlayer
    while task.wait() do
        pcall(function()
            if plr.Character and plr.Character:FindFirstChild("PartTele") then
                if (plr.Character.HumanoidRootPart.Position - plr.Character.PartTele.Position).Magnitude >= 100 then
                    stopTeleport()
                end
            end)
        end)
    end
end)

local plr = game.Players.LocalPlayer
local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        stopTeleport()
    end)
end

plr.CharacterAdded:Connect(onCharacterAdded)
if plr.Character then
    onCharacterAdded(plr.Character)
end

-- Noclip
spawn(function()
    pcall(function()
        while task.wait() do
            if _G.FarmBoss then
                if not game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    local noclip = Instance.new("BodyVelocity")
                    noclip.Name = "BodyClip"
                    noclip.Parent = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
                    noclip.MaxForce = Vector3.new(100000, 100000, 100000)
                    noclip.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    end)
end)

spawn(function()
    pcall(function()
        game:GetService("RunService").Stepped:Connect(function()
            if _G.FarmBoss then
                for _, v in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end)
            end
        end)
    end)
end)

-- Vị trí tấn công
local PosY = 25
local Type = 1
spawn(function()
    while task.wait() do
        if Type == 1 then
            Pos = CFrame.new(0, PosY, -19)
        elseif Type == 2 then
            Pos = CFrame.new(19, PosY, 0)
        elseif Type == 3 then
            Pos = CFrame.new(0, PosY, 19)
        elseif Type == 4 then
            Pos = CFrame.new(-19, PosY, 0)
        end
    end
end)

spawn(function()
    while task.wait(0.1) do
        Type = 1
        task.wait(0.2)
        Type = 2
        task.wait(0.2)
        Type = 3
        task.wait(0.2)
        Type = 4
        task.wait(0.2)
    end
end)

-- Tấn công nhanh
_G.FastAttack = true
if _G.FastAttack then
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local CollectionService = game:GetService("CollectionService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local Validator = Remotes:WaitForChild("Validator")
    local CommF = Remotes:WaitForChild("CommF_")
    local CommE = Remotes:WaitForChild("CommE")
    local Net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
    local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
    local RegisterHit = Net:WaitForChild("RE/RegisterHit")

    local Settings = {
        AutoClick = true,
        ClickDelay = 0
    }

    local FastAttack = {
        Distance = 100,
        attackMobs = true,
        attackPlayers = false,
        Equipped = nil
    }

    local function IsAlive(character)
        return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
    end

    local function ProcessEnemies(OthersEnemies, Folder)
        local BasePart = nil
        for _, Enemy in Folder:GetChildren() do
            local Head = Enemy:FindFirstChild("Head")
            if Head and IsAlive(Enemy) and Player:DistanceFromCharacter(Head.Position) < FastAttack.Distance then
                if Enemy ~= Player.Character then
                    table.insert(OthersEnemies, {Enemy, Head})
                    BasePart = Head
                end
            end
        end
        return BasePart
    end

    function FastAttack:Attack(BasePart, OthersEnemies)
        if not BasePart or #OthersEnemies == 0 then
            return
        end
        pcall(function()
            RegisterAttack:FireServer(Settings.ClickDelay or 0)
            RegisterHit:FireServer(BasePart, OthersEnemies)
        end)
    end

    function FastAttack:AttackNearest()
        local OthersEnemies = {}
        local Part1 = ProcessEnemies(OthersEnemies, game:GetService("Workspace").Enemies)
        local Part2 = ProcessEnemies(OthersEnemies, game:GetService("Workspace").Characters)

        local character = Player.Character
        if not character then
            return
        end

        local equippedWeapon = character:FindFirstChildOfClass("Tool")
        if equippedWeapon and equippedWeapon:FindFirstChild("LeftClickRemote") then
            for _, enemyData in ipairs(OthersEnemies) do
                local enemy = enemyData[1]
                local direction = (enemy.HumanoidRootPart.Position - character:GetPivot().Position).Unit
                pcall(function()
                    equippedWeapon.LeftClickRemote:FireServer(direction, 1)
                end)
            end
        elseif #OthersEnemies > 0 then
            self:Attack(Part1 or Part2, OthersEnemies)
        else
            task.wait(0)
        end
    end

    function FastAttack:BladeHits()
        local Equipped = IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool")
        if Equipped and Equipped.ToolTip ~= "Gun" then
            self:AttackNearest()
        else
            task.wait(0)
        end
    end

    task.spawn(function()
        while task.wait(Settings.ClickDelay) do
            if Settings.AutoClick then
                pcall(function()
                    FastAttack:BladeHits()
                end)
            end
        end)
    end
end

-- Hàm hỗ trợ
function AutoHaki()
    pcall(function()
        if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HasBuso") then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
        end
    end)
end

function EquipWeapon(ToolSe)
    pcall(function()
        if game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe) then
            local Tool = game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe)
            task.wait(0.1)
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(Tool)
        end
    end)
end

_G.SelectWeapon = "Melee"
task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.SelectWeapon == "Melee" then
                for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Melee" then
                        _G.SelectWeapon = v.Name
                        break
                    end
                end
            end
        end)
    end
end)

-- Hàm gọi API
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local function scrapeAPI()
    local success, response = pcall(function()
        return game:HttpGet("https://hostserver.porry.store/bloxfruit/bot/JobId/darkbread")
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        if data and data.JobId then
            return data
        else
            warn("Invalid API response: " .. tostring(response))
            return nil
        end
    else
        warn("Failed to fetch API: " .. tostring(response))
        return nil
    end
end

-- Hàm nhảy server
local function autoHopIfNeeded()
    local maxAttempts = 3
    local attempt = 1
    while attempt <= maxAttempts do
        statusText.Text = "Status: Hopping to new server... (Attempt " .. attempt .. "/" .. maxAttempts .. ")"
        local data = scrapeAPI()
        if data and data.JobId then
            for _, job in ipairs(data.JobId) do
                for jobId, _ in pairs(job) do
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId)
                    end)
                    task.wait(5)
                    return
                end
            end
        end
        statusText.Text = "Status: No Darkbeard server found (Attempt " .. attempt .. "/" .. maxAttempts .. ")"
        warn("No JobId found for hopping")
        attempt = attempt + 1
        task.wait(2)
    end
    statusText.Text = "Status: Failed to find Darkbeard server"
end

-- Logic đánh Darkbeard
_G.FarmBoss = true
spawn(function()
    while task.wait() do
        if _G.FarmBoss then
            pcall(function()
                print("Checking for Darkbeard...")
                local enemies = game:GetService("Workspace").Enemies
                local plr = game.Players.LocalPlayer
                local hrp = WaitHRP(plr)
                if not hrp or not plr.Character or not plr.Character.Humanoid or plr.Character.Humanoid.Health <= 0 then
                    statusText.Text = "Status: Waiting for character..."
                    print("Character not ready")
                    task.wait(1)
                    return
                end

                -- Kiểm tra và đánh Darkbeard
                local foundBoss = false
                for _, v in pairs(enemies:GetChildren()) do
                    if v.Name == "Darkbeard" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        foundBoss = true
                        statusText.Text = "Status: Fighting Darkbeard"
                        repeat
                            task.wait()
                            if not plr.Character or not plr.Character.Humanoid or plr.Character.Humanoid.Health <= 0 then
                                break
                            end
                            AutoHaki()
                            EquipWeapon(_G.SelectWeapon)
                            v.HumanoidRootPart.CanCollide = false
                            v.Humanoid.WalkSpeed = 0
                            topos(v.HumanoidRootPart.CFrame * Pos)
                            sethiddenproperty(plr, "SimulationRadius", math.huge)
                        until not _G.FarmBoss or not v.Parent or v.Humanoid.Health <= 0
                    end
                end

                -- Teleport hoặc nhảy server nếu không tìm thấy boss
                if not foundBoss then
                    local darkbeard = game:GetService("ReplicatedStorage"):FindFirstChild("Darkbeard")
                    if darkbeard then
                        statusText.Text = "Status: Moving to Darkbeard"
                        topos(darkbeard.HumanoidRootPart.CFrame * CFrame.new(5, 10, 7))
                    else
                        topos(CFrame.new(3876, 15, -3889)) -- Teleport đến Dark Arena
                        statusText.Text = "Status: Waiting at Dark Arena"
                        task.wait(5)
                        autoHopIfNeeded()
                    end
                end
            end)
        end
    end
end)