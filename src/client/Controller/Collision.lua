--!strict
local Collision = {}
local PT = require(script.Parent:WaitForChild("PlayerType"))
local Util = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Util"))

local Whitelist = {workspace:WaitForChild("Collision")}
local Parameters = RaycastParams.new()
local Overlap = OverlapParams.new()
local NaN = 0/0
Parameters.FilterDescendantsInstances = Whitelist
Parameters.FilterType = Enum.RaycastFilterType.Include
Overlap.FilterDescendantsInstances = Whitelist
Overlap.FilterType = Enum.RaycastFilterType.Include

local Player = game:GetService("Players").LocalPlayer
local Cast = function(Origin:Vector3, RelativeDirection:Vector3)
    return workspace:Raycast(Origin, RelativeDirection, Parameters)
end

local Get = function(Info:PT.PlayerInfo)
    for Index,Part:Part in pairs(Info.CollisionShapes) do
        if not Part.CanCollide and not Info.CanCollideDisabled then
            Part.CanCollide = true
        end
        if workspace:GetPartsInPart(Part, Overlap) then
           return true
        end
    end
    return false
end

function Clamp(Number:number, Max:number?)
    return math.clamp(Number, .1, Max or math.huge)
end

function Collision.Collide(InfoTable:PT.PlayerInfo, Delta:number)-- No typing here, on purpose. :{Success:boolean, Error:string, ExData:any?}
    if not InfoTable.Humanoid or not InfoTable.VelocityHolder then return {Success = false, Error = `{not InfoTable.Humanoid and "No humanoid found" or "VelocityHolder wasn't present"}`}, InfoTable end
    local Success, Error = nil,nil
    --[[
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

    ]]
    local Pivot = Player.Character:GetPivot()

    if (InfoTable.Humanoid.MoveDirection - InfoTable.LastMove).Magnitude >= .25 and InfoTable.Velocity.Magnitude >= 1 then
        local Y = InfoTable.Velocity.Y
        InfoTable.Velocity /= 3 -- Quick turning
        InfoTable.Velocity += Vector3.new(0, Y - InfoTable.Velocity.Y, 0)
    end    

    if InfoTable.Humanoid.MoveDirection.Magnitude > 0 then
        InfoTable.Velocity += InfoTable.Humanoid.MoveDirection * Clamp(InfoTable.WalkSpeed  * Delta * InfoTable.DeltaMulti, InfoTable.WalkSpeedMaximum)
    end

    local OnGround = Cast(Pivot.Position, -Pivot.UpVector * (InfoTable.Height + .25))

    if OnGround then -- Check for hit gorund
        -- Reset gravity
        
		if InfoTable.Velocity.Y < 0 then
            Pivot -= Pivot.Position
            Pivot += OnGround.Position + (Pivot.UpVector * (InfoTable.Height - .25))
			InfoTable.Velocity -= Vector3.new(0,InfoTable.Velocity.Y, 0)
		end
        InfoTable.Gravity = InfoTable.MinGravity
    else
        -- Gravity check
        if InfoTable.Gravity.Magnitude < InfoTable.MaxGravity.Magnitude then
            InfoTable.Gravity += InfoTable.GravityAdd * Clamp(Delta * InfoTable.DeltaMulti)
        else
            InfoTable.Gravity = InfoTable.MaxGravity
        end
    end

    if InfoTable.Humanoid.MoveDirection.Magnitude <= 0 then
        if InfoTable.WalkSpeed > InfoTable.WalkSpeedMinimum then
            if InfoTable.WalkSpeed > 0 then
                InfoTable.WalkSpeed /= Clamp(InfoTable.WalkSpeedDropOff * Delta * InfoTable.DeltaMulti)
            end
        else
            InfoTable.WalkSpeed = InfoTable.WalkSpeedMinimum
        end
    else
        if InfoTable.WalkSpeed < InfoTable.WalkSpeedMaximum then
            InfoTable.WalkSpeed += Clamp(InfoTable.WalkSpeedAddition * Delta * InfoTable.DeltaMulti)
        else
            InfoTable.WalkSpeed = InfoTable.WalkSpeedMaximum
        end
    end

    InfoTable.Grounded = OnGround and true or false
    
    InfoTable.Velocity += InfoTable.Gravity * Clamp(InfoTable.GravityAffectance * Delta * InfoTable.DeltaMulti)
    InfoTable.VelocityHolder.Velocity = InfoTable.Velocity

    if InfoTable.Humanoid.MoveDirection.Magnitude <= 0 then
        InfoTable.Velocity = InfoTable.Velocity:Lerp(Vector3.new(0, InfoTable.Velocity.Y, 0), Clamp(Delta * InfoTable.DeltaMulti))
    end

    local X,Y,Z = Pivot:ToOrientation()

    Pivot *= Pivot.Rotation:Inverse() -- Remove rotation
    
    Pivot *= CFrame.Angles(0, math.rad(Y), Z) -- Remove X/Z rotation
    Player.Character:PivotTo(Pivot + InfoTable.Velocity)

    if Get(InfoTable) then
        Player.Character:PivotTo(Pivot)
    end

    InfoTable.LastMove = InfoTable.Humanoid.MoveDirection

    local FinalPosition = Util.RemoveY(InfoTable.Velocity).Magnitude > 0 and Pivot.Position + Util.RemoveY(InfoTable.Velocity) or Pivot.Position + (Pivot.LookVector*3)

    Player.Character:PivotTo(CFrame.lookAt(Pivot.Position, FinalPosition))

    return {Success = Success or true, Error = Error or ""}, InfoTable
end

return Collision    