local rm = {}

local config = Traitormod.Config

rm.Roles = {}
rm.Objectives = {}

rm.RoundRoles = {}

rm.FindObjective = function(name)
    return rm.Objectives[name]
end

rm.RandomObjective = function(allowedObjectives)
    if allowedObjectives == nil then
        for key, value in pairs(rm.Objectives) do
            table.insert(allowedObjectives, key)
        end
    end

    local objectives = {}

    for _, objective in pairs(rm.Objectives) do
        for _, allowedName in pairs(allowedObjectives) do
            if objective.Name == allowedName then
                table.insert(objectives, objective)
            end
        end
    end

    return objectives[Random.Range(1, #objectives + 1)]
end

rm.AddObjective = function(objective)
    rm.Objectives[objective.Name] = objective

    if Traitormod.Config.ObjectiveConfig[objective.Name] ~= nil then
        for key, value in pairs(Traitormod.Config.ObjectiveConfig[objective.Name]) do
            objective[key] = value
        end
    end
end

rm.CheckObjectives = function(endRound)
    for name, role in pairs(rm.RoundRoles) do
        for _, objective in pairs(role.Objectives) do
            if objective:IsCompleted() and objective.EndRoundObjective == endRound and not objective.Awarded then
                objective:Award()
            end
        end
    end
end

rm.FindRole = function(name)
    return rm.Roles[name]
end

rm.AddRole = function(role)
    rm.Roles[role.Name] = role

    if Traitormod.Config.RoleConfig[role.Name] ~= nil then
        for key, value in pairs(Traitormod.Config.RoleConfig[role.Name]) do
            role[key] = value
        end
    end
end

rm.AssignRole = function(character, newRole)
    for key, role in pairs(rm.RoundRoles) do
        if role.Name == newRole.Name then
            role:NewMember(key)
        end
    end

    rm.RoundRoles[character] = newRole

    newRole:Init(character)
    newRole:Start()
end

rm.AssignRoles = function(characters, newRoles)
    for i = 1, #characters, 1 do
        for character, role in pairs(rm.RoundRoles) do
            if newRoles[i].Name == role.Name then
                role:NewMember(character)
            end
        end
    end

    for i = 1, #characters, 1 do
        rm.RoundRoles[characters[i]] = newRoles[i]
    end

    for i = 1, #characters, 1 do
        newRoles[i]:Init(characters[i])
        newRoles[i]:Start()
    end
end

rm.FindCharactersByRole = function(name)
    local characters = {}

    for character, role in pairs(rm.RoundRoles) do
        if role.Name == name then
            table.insert(characters, character)
        end
    end

    return characters
end

rm.GetRoleByCharacter = function(character)
    return rm.RoundRoles[character]
end

rm.IsSameRole = function (character1, character2)
    local role1, role2

    if type(character1) == "table" then
        role1 = character1
    else
        role1 = rm.GetRoleByCharacter(character1)
    end

    if type(character2) == "table" then
        role2 = character2
    else
        role2 = rm.GetRoleByCharacter(character2)
    end

    if role1 == nil or role2 == nil then return false end

    return role1.Name == role2.Name
end

Hook.Add("think", "Traitormod.RoleManager.Think", function()
    if not Game.RoundStarted then return end
    rm.CheckObjectives(false)
end)

Hook.Add("roundEnd", "Traitormod.RoleManager.RoundEnd", function()
    rm.RoundRoles = {}
end)

return rm
