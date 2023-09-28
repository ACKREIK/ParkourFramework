--!strict
export type PlayerInfo = {
    Velocity:Vector3,
    Gravity:Vector3,
    MinGravity:Vector3,
    MaxGravity:Vector3,
    GravityAdd:Vector3,
    GroundOffset:number,
    RegularSpeed:number,
    Humanoid:Humanoid?,
    Primary:Part?,
    Drag:number,
    Height:number,
    CollisionShapes:{Part},
    CanCollideDisabled:boolean?,
    VelocityHolder:BodyVelocity?,
    GravityAffectance:number,
    Grounded:boolean,
    WalkSpeed:number,
    WalkSpeedDropOff:number,
    WalkSpeedMaximum:number,
    WalkSpeedMinimum:number,
    WalkSpeedAddition:number,
    DeltaMulti:number,
    LastMove:Vector3,
}

return {}