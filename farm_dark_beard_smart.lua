
local Notification = require(game:GetService("ReplicatedStorage").Notification)
Notification.new("<Color=Cyan>W-MB<Color=/>"):Display()
wait(0.25)
repeat wait() until game.Players.LocalPlayer
wait(2.5)

getgenv().TweenSpeed = 350
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

    if y == 2753915549 then
        TableLocations = {
            ["Sky3"] = Vector3.new(-7894, 5547, -380),
            ["Sky3Exit"] = Vector3.new(-4607, 874, -1667),
            ["UnderWater"] = Vector3.new(61163, 11, 1819),
            ["UnderwaterExit"] = Vector3.new(4050, -1, -1814)
        }
    elseif y == 4442272183 then
        TableLocations = {
            ["Swan Mansion"] = Vector3.new(-390, 332, 673),
            ["Swan Room"] = Vector3.new(2285, 15, 905),
            ["Cursed Ship"] = Vector3.new(923, 126, 32852),
            ["Zombie Island"] = Vector3.new(-6509, 83, -133)
        }
    elseif y == 7449423635 then
        TableLocations = {
            ["Floating Turtle"] = Vector3.new(-12462, 375, -7552),
            ["Hydra Island"] = Vector3.new(5662, 1013, -335),
            ["Mansion"] = Vector3.new(-12462, 375, -7552),
            ["Castle"] = Vector3.new(-5036, 315, -3179),
            ["Beautiful Pirate"] = Vector3.new(5319, 23, -93),
            ["Temple of Time"] = Vector3.new(28286, 14897, 103)
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
        if nearestTeleport then requestEntrance(nearestTeleport) end

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
        local Tween = game:GetService("TweenService"):Create(
            plr.Character.PartTele,
            TweenInfo.new(Distance / SpeedTw, Enum.EasingStyle.Linear),
            {CFrame = Pos}
        )
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

function AutoHaki()
    if not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end

function EquipWeapon(ToolSe)
    if not Nill then
        if game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe) then
            Tool = game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe)
            wait(.1)
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(Tool)
        end
    end
end

_G.SelectWeapon = "Melee"
_G.FarmBoss = true

spawn(function()
    while wait() do
        if _G.FarmBoss and not BypassTP then
            pcall(function()
                local enemies = game:GetService("Workspace").Enemies
                if enemies:FindFirstChild("Dark Beard") then
                    for _, v in pairs(enemies:GetChildren()) do
                        if v.Name == "Dark Beard" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            repeat
                                task.wait()
                                AutoHaki()
                                EquipWeapon(_G.SelectWeapon)
                                v.HumanoidRootPart.CanCollide = false
                                v.Humanoid.WalkSpeed = 0
                                topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
                                sethiddenproperty(game:GetService("Players").LocalPlayer, "SimulationRadius", math.huge)
                            until not _G.FarmBoss or not v.Parent or v.Humanoid.Health <= 0
                        end
                    end
                else
                    local darkBeard = game:GetService("ReplicatedStorage"):FindFirstChild("Dark Beard")
                    if darkBeard and darkBeard:FindFirstChild("HumanoidRootPart") then
                        topos(darkBeard.HumanoidRootPart.CFrame * CFrame.new(5, 10, 7))
                    else
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/giaotrinhhoc/Api/refs/heads/main/Dark.txt"))()
                    end
                end
            end)
        end
    end
end)
