return {
    developers = {
        command = 'currentIntId',
        type = 'all', -- clipboard, notify, print or all
        discord_id = {
            '764196391652163625',
        },
    },
    interiors = {
        [137473] = {
            disables = {
                run = false,
                jump = false,
                weapon = false,
                attack = false,
                animations = true,
                scenarios = true,
                combatCover = false,
                customKeys = {}
            },
            textui_settings = {
                text = 'Olet sisätiloissa.',
                position = 'right-center',
                icon = 'house',
                iconColor = 'green',
                iconAnimation = false,
                alignIcon = 'center',
                style = {}
                -- ## https://coxdocs.dev/ox_lib/Modules/Interface/Client/textui
            }
        }
    }
}
