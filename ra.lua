local Notification = require(game:GetService("ReplicatedStorage").Notification)
Notification.new("<Color=Cyan>W-MB<Color=/>"):Display()
wait(0.25)
repeat
    wait()
until game.Players.LocalPlayer
wait(2.5)

local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", screenGui)
local title = Instance.new("TextLabel", frame)
local status = Instance.new("TextLabel", frame)

frame.Size = UDim2.new(0, 300, 0, 60)
frame.Position = UDim2.new(0.5, -150, 0.03, 0)
frame.BackgroundTransparency = 1

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 120, 0)
stroke.Thickness = 2
stroke.Transparency = 0
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

title.Text = "W-MB Hop | Darkbeard"
title.Size = UDim2.new(1, 0, 0.5, 0)
title.TextColor3 = Color3.fromRGB(255, 120, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true

status.Text = "Status: https://discord.gg/AEf8duPy9p"
status.Position = UDim2.new(0, 0, 0.5, 0)
status.Size = UDim2.new(1, 0, 0.5, 0)
status.TextColor3 = Color3.fromRGB(255, 120, 0)
status.BackgroundTransparency = 1
status.Font = Enum.Font.SourceSansBold
status.TextScaled = true

setclipboard("")
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", "Marines")
game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer("getjob")
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClientAnalyticsEvent"):FireServer({["Platform"] = "Mobile"})
hookfunction(require(game:GetService("ReplicatedStorage").Effect.Container.Death), function() end)
hookfunction(require(game:GetService("ReplicatedStorage").Effect.Container.Respawn), function() end)
hookfunction(require(game:GetService("ReplicatedStorage"):WaitForChild("GuideModule")).ChangeDisplayedNPC, function() end)
require(game.ReplicatedStorage.Util.CameraShaker):Stop()

if game.PlaceId == 2753915549 then
    World1 = true
elseif game.PlaceId == 4442272183 then
    World2 = true
elseif game.PlaceId == 7449423635 then
    World3 = true
end

local isTeleporting = false

function WaitHRP(q0)
    if not q0 then return end
    return q0.Character:WaitForChild("HumanoidRootPart", 9)
end

function CheckNearestTeleporter(aI)
    local vcspos = aI.Position
    local minDist = math.huge
    local chosenTeleport = nil
    local y = game.PlaceId
    local TableLocations = {}

    if y == 4442272183 then -- Sea 2
        TableLocations = {
            ["Dark Arena"] = Vector3.new(-9511, 163, 6158), -- Vị trí Dark Arena
            ["Swan Mansion"] = Vector3.new(-390, 332, 673),
            ["Swan Room"] = Vector3.new(2285, 15, 905),
            ["Cursed Ship"] = Vector3.new(923, 126, 32852),
            ["Zombie Island"] = Vector3.new(-6509, 83, -133)
        }
    end

    for _, v in pairs(TableLocations) do
        local dist = (v - vcspos).Magnitude
        if dist < minDist then
            minDist = dist
            chosenTeleport = v
        end
    end
    
    local playerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    if minDist <= (vcspos - playerPos).Magnitude then
        return chosenTeleport
    end
end

function requestEntrance(teleportPos)
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", teleportPos)
    local char = game.Players.LocalPlayer.Character.HumanoidRootPart
    char.CFrame = char.CFrame + Vector3.new(0, 50, 0)
    task.wait(0.5)
end

function topos(Pos)
    local plr = game.Players.LocalPlayer
    if plr.Character and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("HumanoidRootPart") then
        if not Pos then return end
        local Distance = (Pos.Position - plr.Character.HumanoidRootPart.Position).Magnitude
        local nearestTeleport = CheckNearestTeleporter(Pos)
        if nearestTeleport then
            requestEntrance(nearestTeleport)
        end
        if not plr.Character:FindFirstChild("PartTele") then
            local PartTele = Instance.new("Part", plr.Character)
            PartTele.Size = Vector3.new(10, 1, 10)
            PartTele.Name = "PartTele"
            PartTele.Anchored = true
            PartTele.Transparency = 1
            PartTele.CanCollide = false
            PartTele.CFrame = WaitHRP(plr).CFrame
            PartTele:GetPropertyChangedSignal("CFrame"):Connect(function()
                if not isTeleporting then return end
                task.wait()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local targetCFrame = PartTele.CFrame
                    WaitHRP(plr).CFrame = CFrame.new(targetCFrame.Position.X, Pos.Position.Y, targetCFrame.Position.Z)
                end
            end)
        end
        isTeleporting = true
        local SpeedTw = getgenv().TweenSpeed
        if Distance <= 250 then SpeedTw = SpeedTw * 3 end
        local targetCFrame = CFrame.new(Pos.Position.X, Pos.Position.Y, Pos.Position.Z)
        local Tween = game:GetService("TweenService"):Create(plr.Character.PartTele, TweenInfo.new(Distance / SpeedTw, Enum.EasingStyle.Linear), {CFrame = Pos})
        Tween:Play()
        Tween.Completed:Connect(function(status)
            if status == Enum.PlaybackState.Completed then
                if plr.Character:FindFirstChild("PartTele") then
                    plr.Character.PartTele:Destroy()
                end
                isTeleporting = false
            end
        end)
    end
end

getgenv().TweenSpeed = 350

function stopTeleport()

isTeleporting = false
    local plr = game.Players.LocalPlayer
    if plr.Character:FindFirstChild("PartTele") then
        plr.Character.PartTele:Destroy()
    end
end

spawn(function()
    while task.wait() do
        if not isTeleporting then stopTeleport() end
    end
end)

spawn(function()
    local plr = game.Players.LocalPlayer
    while task.wait() do
        pcall(function()
            if plr.Character:FindFirstChild("PartTele") then
                if (plr.Character.HumanoidRootPart.Position - plr.Character.PartTele.Position).Magnitude >= 100 then
                    stopTeleport()
                end
            end
        end)
    end
end)

local plr = game.Players.LocalPlayer
local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function() stopTeleport() end)
end
plr.CharacterAdded:Connect(onCharacterAdded)
if plr.Character then onCharacterAdded(plr.Character) end

spawn(function()
    pcall(function()
        while wait() do
            if _G.FarmBoss then
                if not game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    local Noclip = Instance.new("BodyVelocity")
                    Noclip.Name = "BodyClip"
                    Noclip.Parent = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
                    Noclip.MaxForce = Vector3.new(100000, 100000, 100000)
                    Noclip.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)
end)

spawn(function()
    pcall(function()
        game:GetService("RunService").Stepped:Connect(function()
            if _G.FarmBoss then
                for _, v in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    end)
end)

PosY = 25
Type = 1
spawn(function()
    while wait() do
        if Type == 1 then Pos = CFrame.new(0, PosY, -19)
        elseif Type == 2 then Pos = CFrame.new(19, PosY, 0)
        elseif Type == 3 then Pos = CFrame.new(0, PosY, 19)
        elseif Type == 4 then Pos = CFrame.new(-19, PosY, 0) end
    end
end)

spawn(function()
    while wait(.1) do
        Type = 1 wait(0.2) Type = 2 wait(0.2) Type = 3 wait(0.2) Type = 4 wait(0.2)
    end
end)

_G.FastAttack = true
if _G.FastAttack then
    local _ENV = (getgenv or getrenv or getfenv)()
    local function SafeWaitForChild(parent, childName)
        local success, result = pcall(function() return parent:WaitForChild(childName) end)
        if not success or not result then warn("noooooo: " .. childName) end
        return result
    end
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local CollectionService = game:GetService("CollectionService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    if not Player then warn("Không tìm thấy người chơi cục bộ.") return end
    local Remotes = SafeWaitForChild(ReplicatedStorage, "Remotes")
    if not Remotes then return end
    local CommF = SafeWaitForChild(Remotes, "CommF_")
    local Settings = { AutoClick = true, ClickDelay = 0 }
    local Module = {}
    Module.FastAttack = (function()
        if _ENV.rz_FastAttack then return _ENV.rz_FastAttack end
        local FastAttack = { Distance = 100, attackMobs = true, attackPlayers = true, Equipped = nil }
        local RegisterAttack = SafeWaitForChild(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"), "RE/RegisterAttack")
        local RegisterHit = SafeWaitForChild(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"), "RE/RegisterHit")
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
            if not BasePart or #OthersEnemies == 0 then return end
            RegisterAttack:FireServer(Settings.ClickDelay or 0)
            RegisterHit:FireServer(BasePart, OthersEnemies)
        end
        function FastAttack:AttackNearest()
            local OthersEnemies = {}
            local Part1 = ProcessEnemies(OthersEnemies, game:GetService("Workspace").Enemies)
            local Part2 = ProcessEnemies(OthersEnemies, game:GetService("Workspace").Characters)
            local character = Player.Character
            if not character then return end
            local equippedWeapon = character:FindFirstChildOfClass("Tool")
            if equippedWeapon and equippedWeapon:FindFirstChild("LeftClickRemote") then
                for _, enemyData in ipairs(OthersEnemies) do
                    local enemy = enemyData[1]
                    local direction = (enemy.HumanoidRootPart.Position - character:GetPivot().Position).Unit
                    pcall(function() equippedWeapon.LeftClickRemote:FireServer(direction, 1) end)
                end
            elseif #OthersEnemies > 0 then self:Attack(Part1 or Part2, OthersEnemies) else task.wait(0) end
        end
        function FastAttack:BladeHits()
            local Equipped = IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool")
            if Equipped and Equipped.ToolTip ~= "Gun" then self:AttackNearest() else task.wait(0) end
        end
        task.spawn(function()
            while task.wait(Settings.ClickDelay) do if Settings.AutoClick then FastAttack:BladeHits() end end
        end)
        _ENV.rz_FastAttack = FastAttack
        return FastAttack
    end)()
end

function AutoHaki()
if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end

function EquipWeapon(ToolSe)
    if game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe) then
        local Tool = game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe)
        wait(.1)
        game.Players.LocalPlayer.Character.Humanoid:EquipTool(Tool)
    end
end

_G.SelectWeapon = "Melee"
task.spawn(function()
    while wait() do
        pcall(function()
            if _G.SelectWeapon == "Melee" then
                for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Melee" then
                        if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
                            _G.SelectWeapon = v.Name
                        end
                    end
                end
            elseif _G.SelectWeapon == "Sword" then
                for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Sword" then
                        if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
                            _G.SelectWeapon = v.Name
                        end
                    end
                end
            end
        end)
    end
end)

_G.FarmBoss = true
spawn(function()
    while wait() do
        if _G.FarmBoss then
            pcall(function()
                local enemies = game:GetService("Workspace").Enemies
                if enemies:FindFirstChild("Darkbeard") then
                    for _, v in pairs(enemies:GetChildren()) do
                        if v.Name == "Darkbeard" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat
                                task.wait()
                                AutoHaki()
                                EquipWeapon(_G.SelectWeapon)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                topos(v.HumanoidRootPart.CFrame * Pos)
                                sethiddenproperty(game:GetService("Players").LocalPlayer, "SimulationRadius", math.huge)
                            until not _G.FarmBoss or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                else
                    local darkbeard = game:GetService("ReplicatedStorage"):FindFirstChild("Darkbeard")
                    if darkbeard then
                        topos(darkbeard.HumanoidRootPart.CFrame * CFrame.new(5, 10, 7))
                    else
                        loadstring(game:HttpGet("https://xeterapi.vercel.app/api/Dark"))() -- Gắn API của bạn vào đây
                    end
                end
            end)
        end
    end
end)