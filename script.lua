local HttpService = game:GetService("HttpService")
local placeId = game.PlaceId
local UniverseID = nil

pcall(function()
    UniverseID = HttpService:JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/"..placeId.."/universe")).universeId
end)

if UniverseID == 7018190066 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidip1/Hack/main/deadrails"))()
elseif UniverseID == 7436755782 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidip1/Hack/main/Growagarden"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidip1/Hack/main/default"))()
end
