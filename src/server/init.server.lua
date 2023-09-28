--!strict


-- Variables
local RunService = game:GetService("RunService")
local First = game:GetService("ReplicatedFirst")
local Replicated = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CommunicationRemote = Replicated:WaitForChild("Shared"):WaitForChild("Talk")
local Keycode = Enum.KeyCode
local InputType = Enum.UserInputType

-- Fix Roblox typechecking bug
local require = require

-- MODULES
local Util = require(Replicated.Shared.Util)
local Administrators = require(script.Administrators)

-- Method Loading
local Methods = {}

function LoadMethod(ModuleScript:ModuleScript)
    if ModuleScript:IsA("ModuleScript") then
        local Main = require(ModuleScript)
    
        for Method, MethodList in pairs(Main) do
            Methods[Method] = MethodList
        end
    end
end

for i,Module in pairs(script.Modules:GetChildren()) do
    LoadMethod(Module)
end

script.Modules.ChildAdded:Connect(function(Module)
    LoadMethod(Module)
end)

-- Client - Server data management
function Get(Player:Player, ...) -- Client requesting, server sending
    return -- WIP Function
end

function Receive(Player:Player, MethodType, MethodName, ...): {boolean|string} -- Client sending, server recieving
    -- Seperate Method checking vs argument checking
    local InvalidArguments = Util.TypeCheck(Player, "Player", false) or Util.TypeCheck(MethodType, "string", false) or Util.TypeCheck(MethodName, "string", false)
    or not Methods[MethodType] or not Methods[MethodType][MethodName]

    if InvalidArguments then
		return {false, `{not Methods[MethodType] and "Invalid Method" or not Methods[MethodType][MethodName] and "Invalid Request" or "Invalid arguments."}`}
    end

	local Success, Error = Methods[MethodType][MethodName](Player, ...) 
	return {Success, Error}
end

local DataFunctions = {
    ["Send"] = Receive,
    ["Request"] = Get,
}

function CommunicationRequested(Player:Player, SelectedMethod:string, ...): {boolean|string}
    if Util.TypeCheck(Player, "Player", true) and SelectedMethod == "DebugLogInfo" and Administrators.IsAdmin(Player) then
        
        local Traceback = debug.traceback()

        warn(`CLIENT REQUESTED DEBUG LOG, ADMINISTRATOR {Player}`)

        local TextTable = {
            `{Traceback}:`,
            `Method Table = `.. "{".. `{Util.TableToString(Methods, "")}`.. "}",
        }
        local FString = [[DEBUG LOG]]

        for i,v in pairs(TextTable) do
            FString = `{FString} \n {v} `
        end

        print(FString)
        
        warn(`DEBUG LOG FINISHED`)
        
        return {Success = true, Error = nil}
    end

    local InvalidArguments = Util.TypeCheck(Player, "Player", false) or Util.TypeCheck(SelectedMethod, "string", false) or not DataFunctions[SelectedMethod]

    if InvalidArguments then
        return {Success = false, Error = "One or more specified arguments were invalid."}
    end

    local Info = DataFunctions[SelectedMethod](Player, ...)

    return Info
end

-- Main Communication
CommunicationRemote.OnServerInvoke = CommunicationRequested