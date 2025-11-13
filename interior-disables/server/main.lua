lib.callback.register('interior-disables:getPerms', function(source, allowedIds)
    if type(allowedIds) ~= 'table' or #allowedIds == 0 then
        return false
    end

    local identifiers = GetPlayerIdentifiers(source)
    local playerDiscord

    for i = 1, #identifiers do
        local discord = identifiers[i]:match('discord:(%d+)')
        if discord then
            playerDiscord = discord
            break
        end
    end

    if not playerDiscord then
        return false
    end

    for i = 1, #allowedIds do
        if tostring(playerDiscord) == tostring(allowedIds[i]) then
            return true
        end
    end

    return false
end)
