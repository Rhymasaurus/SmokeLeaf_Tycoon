local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local ShopConfig = require(ReplicatedStorage:WaitForChild("ShopConfig"))
local Remotes = require(script.Parent:WaitForChild("TycoonRemotes"))

local purchaseGamepassEvent = Remotes.EnsureEvent(Constants.PurchaseGamepassEvent)
local requestShopFunction = Remotes.EnsureFunction(Constants.RequestShopDataFunction)

local GamepassService = {}
GamepassService.__index = GamepassService

local function findGamepass(id)
    for _, entry in ipairs(ShopConfig.Gamepasses) do
        if entry.id == id then
            return entry
        end
    end
    return nil
end

function GamepassService.start()
    purchaseGamepassEvent.OnServerEvent:Connect(function(player, gamepassId)
        local entry = findGamepass(gamepassId)
        if not entry then
            warn(string.format("%s tried to buy unknown gamepass %s", player.Name, tostring(gamepassId)))
            return
        end

        MarketplaceService:PromptGamePassPurchase(player, entry.id)
    end)

    requestShopFunction.OnServerInvoke = function(player)
        return ShopConfig.Gamepasses
    end
end

return GamepassService
