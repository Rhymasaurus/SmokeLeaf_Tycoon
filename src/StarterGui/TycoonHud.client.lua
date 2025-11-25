local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local remotesFolder = ReplicatedStorage:WaitForChild(Constants.RemotesFolderName)
local currencyChangedEvent = remotesFolder:WaitForChild(Constants.CurrencyChangedEvent)
local purchaseGamepassEvent = remotesFolder:WaitForChild(Constants.PurchaseGamepassEvent)
local requestShopDataFunction = remotesFolder:WaitForChild(Constants.RequestShopDataFunction)

local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TycoonHud"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local moneyLabel = Instance.new("TextLabel")
moneyLabel.AnchorPoint = Vector2.new(1, 0)
moneyLabel.Position = UDim2.new(1, -20, 0, 20)
moneyLabel.Size = UDim2.new(0, 200, 0, 40)
moneyLabel.BackgroundColor3 = Color3.fromRGB(14, 19, 28)
moneyLabel.BackgroundTransparency = 0.15
moneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
moneyLabel.TextScaled = true
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.Text = "$0"
moneyLabel.Parent = screenGui

local shopFrame = Instance.new("Frame")
shopFrame.AnchorPoint = Vector2.new(0, 1)
shopFrame.Position = UDim2.new(0, 20, 1, -20)
shopFrame.Size = UDim2.new(0, 320, 0, 260)
shopFrame.BackgroundColor3 = Color3.fromRGB(17, 22, 31)
shopFrame.BackgroundTransparency = 0.25
shopFrame.BorderSizePixel = 0
shopFrame.Parent = screenGui

local shopTitle = Instance.new("TextLabel")
shopTitle.BackgroundTransparency = 1
shopTitle.Size = UDim2.new(1, -20, 0, 28)
shopTitle.Position = UDim2.new(0, 10, 0, 10)
shopTitle.Font = Enum.Font.GothamSemibold
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
shopTitle.Text = "Gamepass Shop"
shopTitle.TextColor3 = Color3.new(1, 1, 1)
shopTitle.TextScaled = true
shopTitle.Parent = shopFrame

local shopList = Instance.new("UIListLayout")
shopList.SortOrder = Enum.SortOrder.LayoutOrder
shopList.Padding = UDim.new(0, 6)
shopList.Parent = shopFrame
shopList.HorizontalAlignment = Enum.HorizontalAlignment.Center
shopList.FillDirection = Enum.FillDirection.Vertical
shopList.VerticalAlignment = Enum.VerticalAlignment.Top

local shopContainer = Instance.new("ScrollingFrame")
shopContainer.Size = UDim2.new(1, -20, 1, -48)
shopContainer.Position = UDim2.new(0, 10, 0, 40)
shopContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
shopContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
shopContainer.ScrollBarThickness = 6
shopContainer.BackgroundTransparency = 1
shopContainer.Parent = shopFrame
local innerList = Instance.new("UIListLayout")
innerList.SortOrder = Enum.SortOrder.LayoutOrder
innerList.Padding = UDim.new(0, 8)
innerList.Parent = shopContainer

local function animateCash(value)
    moneyLabel.Text = string.format("$%s", tostring(value))
    local flash = TweenService:Create(moneyLabel, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(52, 152, 219),
    })
    flash:Play()
    flash.Completed:Wait()
    TweenService:Create(moneyLabel, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(14, 19, 28),
    }):Play()
end

local function renderShop(gamepasses)
    for _, child in ipairs(shopContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for index, item in ipairs(gamepasses) do
        local entry = Instance.new("Frame")
        entry.Name = string.format("Gamepass_%s", item.id)
        entry.Size = UDim2.new(1, 0, 0, 72)
        entry.BackgroundColor3 = Color3.fromRGB(24, 33, 46)
        entry.BackgroundTransparency = 0.1
        entry.BorderSizePixel = 0
        entry.LayoutOrder = index
        entry.Parent = shopContainer

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 56, 0, 56)
        icon.Position = UDim2.new(0, 8, 0.5, -28)
        icon.BackgroundTransparency = 1
        icon.Image = item.icon or "rbxassetid://0"
        icon.Parent = entry

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0, 76, 0, 6)
        title.Size = UDim2.new(1, -160, 0, 24)
        title.Font = Enum.Font.GothamSemibold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Text = item.name
        title.TextColor3 = Color3.new(1, 1, 1)
        title.TextScaled = true
        title.Parent = entry

        local description = Instance.new("TextLabel")
        description.BackgroundTransparency = 1
        description.Position = UDim2.new(0, 76, 0, 30)
        description.Size = UDim2.new(1, -160, 0, 36)
        description.Font = Enum.Font.Gotham
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextYAlignment = Enum.TextYAlignment.Top
        description.TextWrapped = true
        description.Text = item.description
        description.TextColor3 = Color3.fromRGB(190, 199, 216)
        description.TextSize = 14
        description.Parent = entry

        local buyButton = Instance.new("TextButton")
        buyButton.AnchorPoint = Vector2.new(1, 0.5)
        buyButton.Position = UDim2.new(1, -12, 0.5, 0)
        buyButton.Size = UDim2.new(0, 110, 0, 38)
        buyButton.Text = "Buy"
        buyButton.Font = Enum.Font.GothamBold
        buyButton.TextColor3 = Color3.new(1, 1, 1)
        buyButton.BackgroundColor3 = Color3.fromRGB(67, 181, 129)
        buyButton.AutoButtonColor = true
        buyButton.Parent = entry

        buyButton.MouseButton1Click:Connect(function()
            purchaseGamepassEvent:FireServer(item.id)
        end)
    end
end

currencyChangedEvent.OnClientEvent:Connect(function(balance)
    animateCash(balance)
end)

local success, shopData = pcall(function()
    return requestShopDataFunction:InvokeServer()
end)
if success and shopData then
    renderShop(shopData)
end

