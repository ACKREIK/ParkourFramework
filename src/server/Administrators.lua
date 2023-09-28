--!strict
local Administrators = {
    game.CreatorId, -- Me
}

function Administrators.IsAdmin(Player:Player)
    return table.find(Administrators, Player.UserId)
end

return Administrators