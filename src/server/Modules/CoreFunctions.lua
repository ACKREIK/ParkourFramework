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

-- Modules
local Util = require(Replicated.Shared.Util)

-- Main
local CoreFunctions = {
    Core = {
        LoadCharacter = function(Player:Player, ...)
            if Player and Player.Character then
                Player:LoadCharacter()
                return {Success = true, Error = ""}
            else
                return {Success = false, Error = "Failed to load character"}
            end
        end,
        LoadCharacterWithPosition = function(Player:Player, ...)
            if Player and Player.Character then
                local Position = Player.Character:GetPivot()
                Player:LoadCharacter()
                local IntialTime = os.clock()
                
                repeat
                    RunService.Heartbeat:Wait()
                until (not Player or not Player:IsDescendantOf(Players)) or (Player and Player.Character and Player.Character:GetPivot()) or (Util.Clock(IntialTime, 5))

                local Success, Error

                if Player and Player:IsDescendantOf(Players) and Player.Character and Player.Character:GetPivot() then
                    Player.Character:PivotTo(Position)
                    Success = true
                    Error = ""
                else
                    Success = false
                    Error = "Failed to reposition player"
                end

                return {Success = Success, Error = Error}
            else
                return {Success = false, Error = "Failed to load character"}
            end
        end,
    }
}

return CoreFunctions