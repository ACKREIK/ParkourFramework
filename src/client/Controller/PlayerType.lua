--!strict
export type PlayerInfo = {
    Velocity:Vector3,
    Gravity:Vector3,
    MinGravity:Vector3,
    MaxGravity:Vector3,
    GroundOffset:number,
    RegularSpeed:number,
    Humanoid:Humanoid?,
    Primary:Part?,
    Drag:number,
}

return {}