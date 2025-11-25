local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Remotes = require(script.Parent:WaitForChild("TycoonRemotes"))

local currencyChangedEvent = Remotes.EnsureEvent(Constants.CurrencyChangedEvent)

local MoneyService = {}
MoneyService.__index = MoneyService

local function createLeaderstats(player, startingCash)
    local stats = Instance.new("Folder")
    stats.Name = Constants.LeaderstatsName
    stats.Parent = player

    local cash = Instance.new("IntValue")
    cash.Name = Constants.DefaultCurrencyName
    cash.Value = startingCash or 0
    cash.Parent = stats

    return cash
end

local function notify(player, balance)
    currencyChangedEvent:FireClient(player, balance)
end

function MoneyService.new(config)
    local self = setmetatable({}, MoneyService)
    self.config = config or {}
    self.startingCash = self.config.startingCash or 100
    self.incomePerTick = self.config.incomePerTick or Constants.DefaultIncome
    self.incomeInterval = self.config.incomeInterval or Constants.IncomeInterval
    return self
end

function MoneyService:adjustBalance(player, delta)
    local stats = player:FindFirstChild(Constants.LeaderstatsName)
    local cash = stats and stats:FindFirstChild(Constants.DefaultCurrencyName)
    if not cash then
        return false
    end

    local newAmount = math.max(0, cash.Value + delta)
    cash.Value = newAmount
    notify(player, newAmount)
    return true
end

function MoneyService:setBalance(player, value)
    local stats = player:FindFirstChild(Constants.LeaderstatsName)
    local cash = stats and stats:FindFirstChild(Constants.DefaultCurrencyName)
    if not cash then
        return false
    end

    cash.Value = math.max(0, value)
    notify(player, cash.Value)
    return true
end

function MoneyService:getBalance(player)
    local stats = player:FindFirstChild(Constants.LeaderstatsName)
    local cash = stats and stats:FindFirstChild(Constants.DefaultCurrencyName)
    return cash and cash.Value or 0
end

function MoneyService:canAfford(player, cost)
    return self:getBalance(player) >= cost
end

function MoneyService:tryPurchase(player, cost)
    if cost < 0 then
        return false, "Invalid cost"
    end

    if not self:canAfford(player, cost) then
        return false, "Not enough funds"
    end

    local success = self:adjustBalance(player, -cost)
    if success then
        return true
    else
        return false, "Failed to update balance"
    end
end

function MoneyService:startIncomeLoop(player)
    task.spawn(function()
        while player.Parent do
            self:adjustBalance(player, self.incomePerTick)
            task.wait(self.incomeInterval)
        end
    end)
end

function MoneyService:hookPlayers()
    Players.PlayerAdded:Connect(function(player)
        local cash = createLeaderstats(player, self.startingCash)
        notify(player, cash.Value)
        self:startIncomeLoop(player)
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        if not player:FindFirstChild(Constants.LeaderstatsName) then
            local cash = createLeaderstats(player, self.startingCash)
            notify(player, cash.Value)
            self:startIncomeLoop(player)
        end
    end
end

return MoneyService
