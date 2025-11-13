local CONFIG = require 'shared.config'

local insideInterior = false
local currentInterior

local function enterInterior(interiorId)
    local cfg = CONFIG.interiors[interiorId]
    if not cfg then return end

    insideInterior = true
    currentInterior = interiorId

    local options = cfg.textui_settings
    local text = cfg.textui_settings.text or 'Olet sisätiloissa.'

    lib.showTextUI(text, options)
end

local function exitInterior()
    insideInterior = false
    currentInterior = nil
    lib.hideTextUI()
end

local function disableActions(disables)
    if not disables then return end

    local ped = PlayerPedId()

    if disables.run == false then
        DisableControlAction(0, 21, true)
    end

    if disables.jump == false then
        DisableControlAction(0, 22, true)
    end

    if disables.weapon == false then
        DisablePlayerFiring(PlayerId(), true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 37, true)
    end

    if disables.attack == false then
        DisableControlAction(0, 140, true)
        DisableControlAction(0, 141, true)
        DisableControlAction(0, 142, true)
    end

    if disables.combatCover == false then
        DisableControlAction(0, 44, true)
    end

    if disables.animations == false then
        SetPedCanPlayAmbientAnims(ped, false)
        SetPedCanPlayAmbientBaseAnims(ped, false)
    else
        SetPedCanPlayAmbientAnims(ped, true)
        SetPedCanPlayAmbientBaseAnims(ped, true)
    end

    if disables.scenarios == false and IsPedUsingAnyScenario(ped) then
        ClearPedTasks(ped)
    end

    if disables.customKeys and type(disables.customKeys) == 'table' then
        for _, control in ipairs(disables.customKeys) do
            DisableControlAction(0, control, true)
        end
    end
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local interiorId = GetInteriorFromEntity(ped)

        if interiorId ~= 0 and CONFIG.interiors[interiorId] then
            if not insideInterior then
                enterInterior(interiorId)
            end
        else
            if insideInterior then
                exitInterior()
            end
        end

        local sleep = insideInterior and 1 or 1000
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000

        if insideInterior and currentInterior and CONFIG.interiors[currentInterior] then
            local disables = CONFIG.interiors[currentInterior].disables
            disableActions(disables)
            sleep = 1
        end

        Wait(sleep)
    end
end)

if CONFIG.developers and CONFIG.developers.command then
    RegisterCommand(CONFIG.developers.command, function()
        local allowed = lib.callback.await('interior-disables:getPerms', false, CONFIG.developers.discord_id)
        if not allowed then
            return lib.notify({
                title = 'Interior ID',
                description = 'Sinulla ei ole oikeuksia tähän komentoon.',
                type = 'error'
            })
        end

        local ped = PlayerPedId()
        local interiorId = GetInteriorFromEntity(ped)
        local devCfg = CONFIG.developers
        local msg

        if interiorId ~= 0 then
            msg = ('Nykyinen interiorId: %s'):format(interiorId)
        else
            msg = 'Et ole sisätilassa.'
        end

        local t = devCfg.type

        if (t == 'clipboard' or t == 'all') and interiorId ~= 0 then
            if lib and lib.setClipboard then
                lib.setClipboard(tostring(interiorId))
            end
        end

        if t == 'notify' or t == 'all' then
            if lib and lib.notify then
                lib.notify({
                    title = 'Interior ID',
                    description = msg,
                    type = interiorId ~= 0 and 'success' or 'error'
                })
            end
        end

        if t == 'print' or t == 'all' then
            print(msg)
        end
    end, false)
end
