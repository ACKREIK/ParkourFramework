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


return Util