local HttpService = game:GetService("HttpService")
local placeId = game.PlaceId
local UniverseID = nil

-- Lấy UniverseID từ PlaceID
pcall(function()
    UniverseID = HttpService:JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/"..placeId.."/universe")).universeId
end)

-- Tự động chạy script theo từng game
if UniverseID == 7018190066 then
    -- Dead Rails
    loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidip1/Hack/refs/heads/main/deadrails"))()
elseif UniverseID == 126884695634066 then
    -- Grow A Garden
    loadstring(game:HttpGet("https://raw.githubusercontent.com/skibidip1/Hack/refs/heads/main/growagarden"))()
end
