local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local remotesFolder = ReplicatedStorage:WaitForChild(Constants.RemotesFolderName)
local purchaseButtonEvent = remotesFolder:WaitForChild(Constants.PurchaseButtonEvent)

local TAG = "TycoonButton"

local function attachPrompt(button)
    if not button:IsA("BasePart") then
        return
    end

    local prompt = button:FindFirstChildWhichIsA("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.Name = "PurchasePrompt"
        prompt.ObjectText = "Purchase"
        prompt.ActionText = "Buy"
        prompt.HoldDuration = 0.25
        prompt.MaxActivationDistance = 10
        prompt.RequiresLineOfSight = false
        prompt.Parent = button
    end

    prompt.Triggered:Connect(function(player)
        if player == Players.LocalPlayer then
            purchaseButtonEvent:FireServer(button)
        end
    end)
end

local function onTagAdded(button)
    attachPrompt(button)
end

for _, button in ipairs(CollectionService:GetTagged(TAG)) do
    attachPrompt(button)
end

CollectionService:GetInstanceAddedSignal(TAG):Connect(onTagAdded)
