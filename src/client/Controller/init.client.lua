--!strict

-- Types
type NetSuccessInfo = {
    Success:boolean,
    Error:string,
    ExData:{any}?,
}

-- Services
local RunService = game:GetService("RunService")
local First = game:GetService("ReplicatedFirst")
local Replicated = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CommunicationRemote = Replicated:WaitForChild("Shared"):WaitForChild("Talk")
local Keycode = Enum.KeyCode
local InputType = Enum.UserInputType

-- MODULES
local Util = require(Replicated.Shared.Util)

-- Globals
local Self = Players.LocalPlayer
local Character = nil
local Main = {}

function Send(...) : NetSuccessInfo
    local Info = CommunicationRemote:InvokeServer("Send", ...) :: NetSuccessInfo

    return Info
end

function Request(...) : NetSuccessInfo
    local Info = CommunicationRemote:InvokeServer("Request", ...) :: NetSuccessInfo

    return Info
end

function DebuggingRequest() : NetSuccessInfo
    print("Requesting debug input")

    local Info = CommunicationRemote:InvokeServer("DebugLogInfo") :: NetSuccessInfo

    return Info
end

Send("Core", "LoadCharacter")

-- Wait for game loading
repeat
    RunService.Stepped:Wait()
until Self and Self.Character


Character = Self.Character
Self.CharacterAdded:Connect(function(NewCharacter)
    if Character then
        Character:Destroy()
    end

    Character = NewCharacter
end)

Self.CharacterRemoving:Connect(function()
    if Character then
        Character:Destroy()
        Character = nil
    end
end)

local Keybinds = {
    Jump = {
        Keycode.ButtonA,
        Keycode.Space
    },
    Run = {
        Keycode.LeftShift,
    },
    Crouch = {
        Keycode.C
    },
    Shiftlock = {
        Keycode.LeftControl,
    },

    -- Debugging
    LogDebug = {
        Keycode.L,
        Keycode.F10,
    }
}

function OnControlsUpdated()
    -- Rebind Shiftlock function
    local function RebindShiftlock()
        local Controller = Self.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
        local Bindings:StringValue = Controller:FindFirstChild("BoundKeys")

        if not Bindings then
            Bindings = Instance.new("StringValue", Controller)
        end
        
        Bindings.Name = "BoundKeys"
        local ShiftlockControls = {}
        for i,Keybind:Enum.KeyCode in pairs(Keybinds.Shiftlock) do
            ShiftlockControls[i] = Keybind.Name
        end

        local Controls = `{table.concat(ShiftlockControls, ",")}`
        Bindings.Value = Controls
    end
    

    RebindShiftlock()
end

OnControlsUpdated() -- Inital controls updating

-- Input
function Input(Key:InputObject, UIProccessed:boolean)
    if UIProccessed then return end
    
    if table.find(Keybinds.LogDebug, Key.KeyCode) then
        Util.Catch(DebuggingRequest(), debug.traceback())
    end
end

UIS.InputBegan:Connect(Input)