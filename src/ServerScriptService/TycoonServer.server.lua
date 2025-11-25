local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Remotes = require(script.Parent:WaitForChild("TycoonRemotes"))
local MoneyService = require(script.Parent:WaitForChild("MoneyService"))
local GamepassService = require(script.Parent:WaitForChild("GamepassService"))

local purchaseButtonEvent = Remotes.EnsureEvent(Constants.PurchaseButtonEvent)

local money = MoneyService.new({
    startingCash = 150,
    incomePerTick = Constants.DefaultIncome,
    incomeInterval = Constants.IncomeInterval,
})

local function findButtonConfig(button)
    local configuration = button and button:FindFirstChild("Configuration")
    if not configuration then
        return nil
    end

    local costValue = configuration:FindFirstChild("Cost")
    local prefabValue = configuration:FindFirstChild("Prefab")
    if not costValue or not costValue:IsA("NumberValue") then
        return nil
    end

    return {
        cost = costValue.Value,
        prefab = prefabValue and prefabValue.Value,
    }
end

local function grantPurchase(player, button)
    if not button then
        return
    end

    local config = findButtonConfig(button)
    if not config then
        warn("Button missing configuration", button:GetFullName())
        return
    end

    local ok, message = money:tryPurchase(player, config.cost)
    if not ok then
        warn(string.format("%s could not afford %s: %s", player.Name, button:GetFullName(), message))
        return
    end

    if config.prefab and config.prefab:IsDescendantOf(ServerStorage) then
        local clone = config.prefab:Clone()
        clone.Parent = workspace
    end

    CollectionService:RemoveTag(button, "TycoonButton")
    if button:IsA("BasePart") then
        button.Transparency = 0.7
        button.CanCollide = false
    end

    local prompt = button:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then
        prompt.Enabled = false
    end
end

local function onButtonPurchase(player, button)
    if typeof(button) ~= "Instance" or not button:IsDescendantOf(workspace) then
        warn("Rejected invalid button purchase request")
        return
    end

    if not CollectionService:HasTag(button, "TycoonButton") then
        warn("Purchase request for untagged button", button:GetFullName())
        return
    end

    grantPurchase(player, button)
end

purchaseButtonEvent.OnServerEvent:Connect(onButtonPurchase)
money:hookPlayers()
GamepassService.start()
