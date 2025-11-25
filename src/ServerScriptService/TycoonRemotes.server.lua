local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage:WaitForChild("Constants"))

local function ensureRemote(name, className)
    local remotesFolder = ReplicatedStorage:FindFirstChild(Constants.RemotesFolderName)
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = Constants.RemotesFolderName
        remotesFolder.Parent = ReplicatedStorage
    end

    local existing = remotesFolder:FindFirstChild(name)
    if existing and existing:IsA(className) then
        return existing
    end

    if existing then
        existing:Destroy()
    end

    local remote = Instance.new(className)
    remote.Name = name
    remote.Parent = remotesFolder
    return remote
end

return {
    EnsureEvent = function(name)
        return ensureRemote(name, "RemoteEvent")
    end,
    EnsureFunction = function(name)
        return ensureRemote(name, "RemoteFunction")
    end,
}
