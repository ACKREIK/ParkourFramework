--!strict
local Collision = {}
local PT = require(script.Parent:WaitForChild("PlayerType"))
local Util = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Util"))

local Whitelist = {workspace:WaitForChild("Collision")}
local Parameters = RaycastParams.new()
local Overlap = OverlapParams.new()
Parameters.FilterDescendantsInstances = Whitelist
Parameters.FilterType = Enum.RaycastFilterType.Include
Overlap.FilterDescendantsInstances = Whitelist
Overlap.FilterType = Enum.RaycastFilterType.Include

local Player = game:GetService("Players").LocalPlayer
local Cast = function(Origin:Vector3, RelativeDirection:Vector3, Parameters:RaycastParams?)
    return workspace:Raycast(Origin, RelativeDirection, Parameters)
end

function Collision.Collide(InfoTable:PT.PlayerInfo, Delta:number)-- No typing here, on purpose. :{Success:boolean, Error:string, ExData:any?}
    local Success, Error = nil,nil
    local CF = Player.Character:GetPivot() :: CFrame
    local Position = CF.Position
    local Rotation = CF.Rotation

    if InfoTable.Gravity.Magnitude < InfoTable.MaxGravity.Magnitude then
        
    end

    InfoTable.Velocity += InfoTable.Gravity
    InfoTable.Velocity /= InfoTable.Drag

    local Next = CFrame.lookAt(Vector3.new(0,0,0), Vector3.new(0,0,0) + InfoTable.Velocity - InfoTable.Gravity)

    local function VectorToSpeed(V:Vector3)
        return V * (InfoTable.RegularSpeed + InfoTable.Velocity.Magnitude) * Delta
    end
    local EndOffset = Position

    local Rays = {
        Forwards = Cast(Position, VectorToSpeed(Next.LookVector), Parameters),
        Backwards = Cast(Position, VectorToSpeed(-Next.LookVector), Parameters),
        Left = Cast(Position, VectorToSpeed(-Next.RightVector), Parameters),
        Right = Cast(Position, VectorToSpeed(Next.RightVector), Parameters),
        Up = Cast(Position, VectorToSpeed(Next.UpVector), Parameters),
        Down = Cast(Position, VectorToSpeed(-Next.UpVector), Parameters),
    }

    for Index,Ray in pairs(Rays) do
        if not Ray then continue end

        local Offset = Position - Ray.Position
        EndOffset += Offset
    end

    if Rays.Down then
        EndOffset += CF.UpVector * InfoTable.GroundOffset
    end

    Player.Character:PivotTo(Rotation + EndOffset)

    return {Success = Success, Error = Error}, InfoTable
end

return Collision