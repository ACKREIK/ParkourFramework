--!strict
local Util = {}

Util.TypeCheck = function(Value:any, Type:string, SuccessVariable:boolean)
    -- Returns using ==/~=/>=/<= always have parentheses for cleanliness
    if Value then
        return (Value ~= nil) == SuccessVariable
    else
        if typeof(Value) == "Instance" then
            return Value:IsA(Type) == SuccessVariable
        else
            return (typeof(Value) == Type) == SuccessVariable
        end
    end
end

Util.Clock = function(Initial:number, Max:number)
    return os.clock() - Initial >= Max
end

Util.Catch = function(GenericSucErrorTable, Trace)
    if not GenericSucErrorTable.Success then
        warn(`{Trace} Failed: {GenericSucErrorTable.Error}`)
        return true
    else
        return false
    end
end

Util.AddTabs = function(String:string, TabAmount:number)
    if TabAmount > 0 then
        for i=1, TabAmount do
            String = `    {String}`
        end
    end

    return String
end

Util.TableToString = function(Table:{any}, CurrentString:string?, Depth:number)
    if not Depth then
        Depth = 0
    end
    for Index,Next in pairs(Table) do
        if typeof(Next) == "table" then
			CurrentString = `{CurrentString} \n {Util.AddTabs("", Depth)}{Index} = {Util.TableToString(Next, CurrentString, Depth + 1)}`
        else
            CurrentString = `{CurrentString} \n {Util.AddTabs("", Depth)}{Index} = {Next},`
        end
    end

    return CurrentString
end

Util.ToLocal = function(Init:CFrame|Part, Vector:Vector3)
	if typeof(Init) == "CFrame" then
		return Init:VectorToObjectSpace(Vector)
	elseif typeof(Init) == "Instance" and Init:IsA("BasePart") then
		return Init.CFrame:VectorToObjectSpace(Vector)
	else
		return Vector
	end
end

Util.ToGlobal = function(Init:CFrame|Part, Vector:Vector3)
	if typeof(Init) == "CFrame" then
		return Init:VectorToWorldSpace(Vector)
	elseif typeof(Init) == "Instance" and Init:IsA("BasePart") then
		return Init.CFrame:VectorToWorldSpace(Vector)
	else
		return Vector
	end
end

Util.RemoveY = function(Vector:Vector3)
    return Vector - Vector3.new(0, Vector.Y, 0)
end


return Util