--!strict

-- Types
type NetSuccessInfo = {
    Success:boolean,
    Error:string,
    ExData:{any}?,
}

type Character = any?

-- Services
local RunService = game:GetService("RunService")
local First = game:GetService("ReplicatedFirst")
local Replicated = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local PService = game:GetService("Players")
local CommunicationRemote = Replicated:WaitForChild("Shared"):WaitForChild("Talk")
local Keycode = Enum.KeyCode
local InputType = Enum.UserInputType

-- MODULES
local Util = require(Replicated.Shared.Util)
local Collision = require(script:WaitForChild("Collision"))
local Ref = require(script:WaitForChild("PlayerType"))

-- Fix roblox type checking
local pcall = pcall

-- Globals
local Main:Ref.PlayerInfo = {
    Velocity = Vector3.new(0,0,0),
    Gravity = Vector3.new(0,-2,0),
    MinGravity = Vector3.new(0,-2,0),
    MaxGravity = Vector3.new(0,-10,0),
    GroundOffset = 3,
    RegularSpeed =  5,
    Humanoid = nil,
    Primary = nil,
    Drag = 1.25,
}
local Player = PService.LocalPlayer
local Character:Character = nil

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
until Player and Player.Character and Player.Character.PrimaryPart and Player.Character:FindFirstChild("Humanoid")

function CharacterAdded(NewCharacter)
    if Character then
        Character:Destroy()
	end
	
	Main.Humanoid = NewCharacter.Humanoid
	Main.Primary = NewCharacter.HumanoidRootPart
	
    Character = NewCharacter

    if Main.Humanoid then
        for Index, Part:Part in pairs(NewCharacter:GetDescendants()) do
            if Part:IsA("BasePart") then
                Part.CanCollide = false
                Part.Massless = true
                Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            end
        end
        
        Main.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        
        for Index,State in pairs(Enum.HumanoidStateType:GetEnumItems()) do
            if not table.find({Enum.HumanoidStateType.None, Enum.HumanoidStateType.Physics}, State) then
                local suc, err = pcall(function()
                    Main.Humanoid:SetStateEnabled(State, false)
                end)
                if err then warn(err) end
            end
        end
    end
end
CharacterAdded(Player.Character)
Player.CharacterAdded:Connect(CharacterAdded)

Player.CharacterRemoving:Connect(function()
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
        local Controller = Player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
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

function IsPressing(BindList:{Enum.KeyCode}, Key:InputObject):boolean
    return table.find(BindList, Key.KeyCode) and true or false
end

-- Input
function Input(Key:InputObject, UIProccessed:boolean)
    if UIProccessed then return end
    
    if table.find(Keybinds.LogDebug, Key.KeyCode) then
        Util.Catch(DebuggingRequest(), debug.traceback())
    end

    if IsPressing(Keybinds.Jump, Key) then
        Main.Velocity += Vector3.new(0,50,0)
    end
end

UIS.InputBegan:Connect(Input)

function Update(Delta:number):NetSuccessInfo
    local Succ1, Err1
    local Succ,Err = pcall(function()
        if not Character then
            Succ1 = false
            Err1 = "Character not loaded"
            return nil, nil
        end

        local E, NT = Collision.Collide(Main, Delta)

        if not E.Success then
            Succ1 = E.Success
            Err1 = E.Error
        end

        Main = NT

        return nil,nil
    end)

    return {Success = (not Succ1 and Succ1 or Succ), Error = Err1 or Err or ""}
end

RunService.Heartbeat:Connect(Update)