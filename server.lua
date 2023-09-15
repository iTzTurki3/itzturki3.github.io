local Proxy = module("vrp", "lib/Proxy")
local vRP = Proxy.getInterface("vRP")

local screens = {}
local cinemaIndex = 1

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    for k, v in pairs(config.Statics) do
        screens[k] = {
            url = "",
            owner_id = 0,
            owner_name = v.owner,
            id = k,
            heading = v.location[4],
            pos = v.location,
            volume = 0.0,
            type = "static"
        }
    end
    print("~ Done Load Static Screens ~")
  end)

function dlog(title, message)
    local connect = {{
        ["color"] = config.Logsystem.Color,
        ["title"] = "**" .. title .. "**",
        ["description"] = message,
        ["footer"] = {
            ["text"] = "Made With ❤️ By Pars#0011 - " .. os.date("%c")
        }
    }}
    PerformHttpRequest(config.Logsystem.WebhookUrl, function(err, text, headers)
    end, 'POST', json.encode({
        username = config.Logsystem.Username,
        avatar_url = config.Logsystem.AvatarUrl,
        embeds = connect
    }), {
        ['Content-Type'] = 'application/json'
    })
end

RegisterServerEvent("Pars_cinema:server:spawn", function()
    local source = source
    TriggerClientEvent('Pars_cinema:client:asyncScreens', source, screens)
end)

RegisterCommand(config.General.TabletCommand, function(source, args, rawCommand)
    local uid = vRP.getUserId({source})
    if vRP.hasPermission({uid, config.General.Permission}) then
        TriggerClientEvent("Pars_cinema:client:openTablet", source, "full-permission")
    else
        local list = {}
        for k, v in pairs(config.Permissions) do
            if (v[tostring(uid)] ~= nil) then
                table.insert(list, k)
            end
        end
        if (#list > 0) then
            TriggerClientEvent("Pars_cinema:client:openTablet", source, "half-permission", list)
        else
            TriggerClientEvent("pNotify:SendNotification", source, {
                text = "لا تملك الصلاحية",
                type = "error",
                timeout = 3000
            })
        end
    end
end)

RegisterServerEvent('Pars_cinema:server:async', function(heading, pos)
    local source = source
    local uid = vRP.getUserId({source})
    if vRP.hasPermission({uid, config.General.Permission}) then
        local owner_name = GetPlayerName(source)
        dlog("Add cinema screen",
            "Player: **" .. uid .. " | " .. owner_name .. "**\nScreen position: **x=" .. pos[1] .. ", y=" .. pos[2] ..
                ", z=" .. pos[3] .. ", h=" .. heading .. "**")
        local objid = cinemaIndex .. "_kingdomsc"
        cinemaIndex = cinemaIndex + 1
        screens[objid] = {
            url = "",
            owner_id = uid,
            owner_name = owner_name,
            id = objid,
            heading = heading,
            pos = pos,
            volume = 0.0,
            type = "dynamic"
        }
        TriggerClientEvent('Pars_cinema:client:async', -1, objid, uid, GetPlayerName(source), heading, pos)
    else
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = "لا تملك الصلاحية",
            type = "error",
            timeout = 3000
        })
    end
end)

RegisterServerEvent('Pars_cinema:server:asyncUrl', function(id, url, volume)
    local source = source
    local uid = vRP.getUserId({source})
    if vRP.hasPermission({uid, config.General.Permission}) or config.Permissions[id][tostring(uid)] ~= nil then
        dlog("Cinema play video",
            "Player: **" .. uid .. " | " .. GetPlayerName(source) .. "**\nPlay url: **" .. url .. "**\nScreen owner: **" ..
                screens[id].owner_id .. " | " .. screens[id].owner_name .. "**\nScreen Id: **" .. id .. "**")
        screens[id].url = url
        screens[id].volume = volume
        TriggerClientEvent('Pars_cinema:client:asyncUrl', -1, id, url, volume)
    else
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = "لا تملك الصلاحية",
            type = "error",
            timeout = 3000
        })
    end
end)

RegisterServerEvent('Pars_cinema:server:asyncRemove', function(owner_id, owner_name, id)
    local source = source
    local uid = vRP.getUserId({source})
    if vRP.hasPermission({uid, config.General.Permission}) then
        dlog("Remove cinema screen",
            "Player: **" .. uid .. " | " .. GetPlayerName(source) .. "**\nScreen owner: **" .. owner_id .. " | " ..
                owner_name .. "**\nScreen id: **" .. id .. "**")
        config.Permissions[id] = nil
        if (screens[id] ~= nil) then
            screens[id] = nil
        end
        TriggerClientEvent('Pars_cinema:client:asyncRemove', -1, id)
    else
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = "لا تملك الصلاحية",
            type = "error",
            timeout = 3000
        })
    end
end)

RegisterServerEvent('Pars_cinema:server:asyncVolume', function(id, volume)
    local source = source
    local uid = vRP.getUserId({source})
    if vRP.hasPermission({uid, config.General.Permission}) or config.Permissions[id][tostring(uid)] ~= nil then
        screens[id].volume = volume
        TriggerClientEvent('Pars_cinema:client:asyncVolume', -1, id, volume)
    else
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = "لا تملك الصلاحية",
            type = "error",
            timeout = 3000
        })
    end
end)

RegisterServerEvent('Pars_cinema:server:addNewScreen', function()
    local source = source
    local uid = vRP.getUserId({source})
    if vRP.hasPermission({uid, config.General.Permission}) then
        TriggerClientEvent("Pars_cinema:client:createObject", source)
    else
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = "لا تملك الصلاحية",
            type = "error",
            timeout = 3000
        })
    end
end)

RegisterServerEvent('Pars_cinema:server:asyncpause', function(id)
    local source = source
    local uid = vRP.getUserId({source})
    if vRP.hasPermission({uid, config.General.Permission}) or config.Permissions[id][tostring(uid)] ~= nil then
        if (screens[id] ~= nil) then
            screens[id].url = ""
        end
        TriggerClientEvent("Pars_cinema:client:asyncpause", -1, id)
    else
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = "لا تملك الصلاحية",
            type = "error",
            timeout = 3000
        })
    end
end)

RegisterServerEvent("Pars_cinema:server:addPermission", function(cinema_id)
    local source = source
    local uid = vRP.getUserId({source})
    if vRP.hasPermission({uid, config.General.Permission}) then
        vRP.prompt({source, "player id:", "", function(player, target_id)
            target_id = tonumber(target_id)
            if (not target_id) then
                return
            end
            if (config.Permissions[cinema_id] == nil) then
                config.Permissions[cinema_id] = {}
            end
            if (config.Permissions[cinema_id][tostring(target_id)] == nil) then
                config.Permissions[cinema_id][tostring(target_id)] = true
            else
                TriggerClientEvent("pNotify:SendNotification", source, {
                    text = "اللاعب لديه الصلاحية بالفعل",
                    type = "error",
                    timeout = 3000
                })
            end
        end})
    else
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = "لا تملك الصلاحية",
            type = "error",
            timeout = 3000
        })
    end
end)

RegisterServerEvent('Pars_cinema:server:getPermissions', function(cinema_id, cb_index)
    local source = source
    local uid = vRP.getUserId({source})
    if vRP.hasPermission({uid, config.General.Permission}) then
        local permissionList = {}
        if (config.Permissions[cinema_id] ~= nil) then
            for k, _ in pairs(config.Permissions[cinema_id]) do
                local target_source = vRP.getUserSource({tonumber(k)})
                local player_name = "Offline"
                if (target_source ~= nil) then
                    player_name = GetPlayerName(target_source)
                end
                table.insert(permissionList, {
                    id = tonumber(k),
                    username = player_name
                })
            end
        end
        TriggerClientEvent('Pars_cinema:client:asyncPermissions', source, permissionList, cb_index)
    else
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = "لا تملك الصلاحية",
            type = "error",
            timeout = 3000
        })
    end
end)
RegisterServerEvent('Pars_cinema:server:removePermission', function(cinema_id, player_id)
    local source = source
    local uid = vRP.getUserId({source})
    if vRP.hasPermission({uid, config.General.Permission}) then
        if (config.Permissions[cinema_id] ~= nil and config.Permissions[cinema_id][tostring(player_id)] ~= nil) then
            config.Permissions[cinema_id][tostring(player_id)] = nil
        end
    else
        TriggerClientEvent("pNotify:SendNotification", source, {
            text = "لا تملك الصلاحية",
            type = "error",
            timeout = 3000
        })
    end
end)
