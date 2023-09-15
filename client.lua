local duiObj = nil
local tx = nil
local cinemaObj = {}
local cinmHash = GetHashKey(config.General.ObjectName)
local changeVolTimeout = true
local createStatics = false

AddEventHandler("playerSpawned", function()
    if (not createStatics) then
        createStatics = true
        RequestModel(cinmHash)
        while not HasModelLoaded(cinmHash) do
            Citizen.Wait(1)
        end
        local txd = CreateRuntimeTxd('csmodgnik_1_e4')
        duiObj = CreateDui(config.General.LauncherWebsite, 1024, 1024)
        _G.duiObj = duiObj
        local dui = GetDuiHandle(duiObj)
        tx = CreateRuntimeTextureFromDuiHandle(txd, 'csmodgnik_2_e4', dui)
        AddReplaceTexture(config.General.ObjectName, config.General.TextureName, 'csmodgnik_1_e4', 'csmodgnik_2_e4')
        TriggerServerEvent('Pars_cinema:server:spawn')
    end
end)

Citizen.CreateThread(function()
    while (not tx) do
        Citizen.Wait(0)
    end
    while true do
        local selfPosition = GetEntityCoords(GetPlayerPed(-1))
        local list = {}
        for _, v in pairs(cinemaObj) do
            local distance = GetDistanceBetweenCoords(selfPosition[1], selfPosition[2], selfPosition[3], v.location[1], v.location[2], v.location[3])
            table.insert(list, {
                id = v.id,
                maxVolume = v.maxVolume,
                distance = distance
            })
        end
        SendDuiMessage(duiObj, json.encode({
            action = "update",
            list = list
        }))
        Citizen.Wait(300)
    end
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
end)

RegisterNUICallback('play', function(data, cb)
    local object = cinemaObj[data.id]
    if (object ~= nil) then
        local pos = GetEntityCoords(GetPlayerPed(-1))
        if (data.id ~= "" and data.url ~= "") then
            if GetDistanceBetweenCoords(pos[1], pos[2], pos[3], object.location[1], object.location[2],
                object.location[3], true) <= config.General.ControlDistance then
                TriggerServerEvent('Pars_cinema:server:asyncUrl', data.id, data.url, data.volume)
            else
                TriggerEvent("pNotify:SendNotification", {
                    text = "يجب ان تكون قريب من الشاشة",
                    type = "error",
                    timeout = 3000
                })
            end
        end
    end
end)

RegisterNUICallback('remove', function(data, cb)
    local object = cinemaObj[data.id]
    if (object ~= nil) then
        if (object.type ~= "static") then
            if (data.id ~= "") then
                local pos = GetEntityCoords(GetPlayerPed(-1))
                if (GetDistanceBetweenCoords(pos[1], pos[2], pos[3], object.location[1], object.location[2],
                    object.location[3]) <= config.General.ControlDistance) then
                    cb({
                        state = true
                    })
                    TriggerServerEvent('Pars_cinema:server:asyncRemove', object.owner_id, object.owner_name,
                        data.id)
                else
                    TriggerEvent("pNotify:SendNotification", {
                        text = "يجب ان تكون قريب من الشاشة",
                        type = "error",
                        timeout = 3000
                    })
                end
            else
                cb({
                    state = false
                })
            end
        else
            cb({
                state = false
            })
            TriggerEvent("pNotify:SendNotification", {
                text = "لا يمكنك حذف الشاشات الثابتة",
                type = "error",
                timeout = 3000
            })
        end
    else
        cb({
            state = false
        })
    end
end)

RegisterNetEvent('Pars_cinema:client:asyncRemove', function(id)
    SendDuiMessage(duiObj, json.encode {
        action = "remove",
        id = id
    })
    DeleteEntity(cinemaObj[id].object)
    cinemaObj[id] = nil
end)

RegisterNetEvent('Pars_cinema:client:asyncUrl', function(id, url, volume)
    cinemaObj[id].url = url
    cinemaObj[id].maxVolume = volume
    cinemaObj[id].play_state = true
    SendDuiMessage(duiObj, json.encode({
        action = "add",
        id = id,
        url = url,
        maxVolume = volume
    }))
end)

RegisterNUICallback('changeVolume', function(data, cb)
    if changeVolTimeout then
        changeVolTimeout = false
        Citizen.CreateThread(function()
            Citizen.Wait(2500)
            changeVolTimeout = true
        end)
        local object = cinemaObj[data.id]
        if (object ~= nil) then
            TriggerServerEvent("Pars_cinema:server:asyncVolume", data.id, data.volume)
        end
    end
end)

RegisterNetEvent('Pars_cinema:client:asyncVolume', function(id, volume)
    local object = cinemaObj[id]
    if (object ~= nil) then
        object.maxVolume = volume
    end
end)

RegisterNUICallback('add_permission', function(data, cb)
    local object = cinemaObj[data.id]
    if (object ~= nil) then
        TriggerServerEvent('Pars_cinema:server:addPermission', data.id)
    end
end)

RegisterNetEvent("Pars_cinema:client:openTablet", function(state, CinemaID)
    SetNuiFocus(true, true)
    local list = {}
    local pos = GetEntityCoords(GetPlayerPed(-1))
    if (state == "half-permission") then
        for kk, vv in pairs(CinemaID) do
            local object = cinemaObj[vv]
            table.insert(list, {
                id = object.id,
                owner_id = object.owner_id,
                owner_name = object.owner_name,
                distance = GetDistanceBetweenCoords(pos[1], pos[2], pos[3], object.location[1], object.location[2],
                    object.location[3], true)
            })
        end
    else
        for _, v in pairs(cinemaObj) do
            table.insert(list, {
                id = v.id,
                owner_id = v.owner_id,
                owner_name = v.owner_name,
                distance = GetDistanceBetweenCoords(pos[1], pos[2], pos[3], v.location[1], v.location[2], v.location[3],
                    true)
            })
        end
    end
    SendNUIMessage({
        action = "show_tablet",
        list = list
    })
end)

RegisterNUICallback('addNewScreen', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent("Pars_cinema:server:addNewScreen")
end)

RegisterNUICallback('updateState', function(data, cb)
    cinemaObj[data.id].play_state = false
end)

RegisterNUICallback('pause', function(data, cb)
    local object = cinemaObj[data.id]
    if (object ~= nil) then
        TriggerServerEvent('Pars_cinema:server:asyncpause', data.id)
    end
end)

RegisterNetEvent('Pars_cinema:client:asyncpause', function(id)
    local object = cinemaObj[id]
    if (object ~= nil) then
        cinemaObj[id].play_state = false
        SendDuiMessage(duiObj, json.encode({
            action = 'pause',
            id = id
        }))
    end
end)

RegisterNetEvent("Pars_cinema:client:createObject", function()
    local tmpObj = CreateObject(cinmHash, 0.0, 0.0, 0.0, false, false, false)
    SetEntityCollision(tmpObj, false, false)
    SetEntityAlpha(tmpObj, 150, false)
    SetEntityLodDist(tmpObj, 500)
    SendDuiMessage(duiObj, json.encode {
        action = "hide"
    })
    Citizen.CreateThread(function()
        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        local heading = GetEntityHeading(GetPlayerPed(-1))
        local cancel = false
        SetEntityHeading(tmpObj, heading)
        while true do
            if (IsControlPressed(0, 27)) then
                x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(tmpObj, 0.0, 0.05, 0.0))
            end
            if (IsControlPressed(0, 173)) then
                x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(tmpObj, 0.0, -0.05, 0.0))
            end
            if (IsControlPressed(0, 174)) then
                x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(tmpObj, -0.05, 0.0, 0.0))
            end
            if (IsControlPressed(0, 175)) then
                x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(tmpObj, 0.05, 0.00, 0.0))
            end
            if (IsControlPressed(0, 208)) then
                z = z + 0.05
            end
            if (IsControlPressed(0, 207)) then
                z = z - 0.05
            end
            SetEntityCoords(tmpObj, x, y, z, 0, 0, 0, 0)
            if IsControlJustPressed(0, 38) then
                break
            end
            if (IsControlJustPressed(0, 322)) then
                cancel = true
                break
            end
            Citizen.Wait(0)
        end
        if (not cancel) then
            TriggerServerEvent('Pars_cinema:server:async', heading, GetEntityCoords(tmpObj))
            Citizen.Wait(500)
            SetNuiFocus(true, true)
            local list = {}
            local pos = GetEntityCoords(GetPlayerPed(-1))
            for _, v in pairs(cinemaObj) do
                table.insert(list, {
                    id = v.id,
                    owner_id = v.owner_id,
                    owner_name = v.owner_name,
                    distance = GetDistanceBetweenCoords(pos[1], pos[2], pos[3], v.location[1], v.location[2],
                        v.location[3], true)
                })
            end
            SendNUIMessage({
                action = "show_tablet",
                list = list
            })
        end
        DeleteEntity(tmpObj)
    end)
end)

RegisterNetEvent('Pars_cinema:client:async', function(cid, owner_id, owner_name, heading, pos)
    local tmpObj = CreateObject(cinmHash, pos[1], pos[2], pos[3] - 3.0, false, false, false)
    SetEntityCollision(tmpObj, false, false)
    SetEntityHeading(tmpObj, heading)
    SetEntityLodDist(tmpObj, 500)
    cinemaObj[cid] = {
        owner_id = owner_id,
        owner_name = owner_name,
        object = tmpObj,
        object_hash = GetHashKey(tmpObj),
        location = GetEntityCoords(tmpObj),
        heading = heading,
        id = cid,
        type = "dynamic",
        play_state = false
    }
    SendDuiMessage(duiObj, json.encode({
        action = "setting",
        StopBackground = config.General.StopBackground
    }))
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if (duiObj ~= nil) then
        DestroyDui(duiObj)
    end
    for k, v in pairs(cinemaObj) do
        if (v.type ~= "static") then
            DeleteEntity(v.object)
        end
    end
end)

local cbList = {}
local cbIndex = 0
RegisterNUICallback('getPermission', function(data, cb)
    cbIndex = cbIndex + 1
    cbList[cbIndex] = cb
    TriggerServerEvent('Pars_cinema:server:getPermissions', data.id, cbIndex)
end)
RegisterNetEvent('Pars_cinema:client:asyncPermissions', function(list, cb_index)
    if cbList[cb_index] ~= nil then
        cbList[cb_index]({
            list = list
        })
    end
end)
RegisterNUICallback('removePermission', function(data, cb)
    TriggerServerEvent('Pars_cinema:server:removePermission', data.id, data.player_id)
end)

RegisterNetEvent('Pars_cinema:client:asyncScreens', function(screens)
    Citizen.CreateThread(function()
        for k, v in pairs(screens) do
            local tmpObj = CreateObject(cinmHash, v.pos[1], v.pos[2], v.pos[3], false, false, false)
            SetEntityCollision(tmpObj, false, false)
            SetEntityHeading(tmpObj, v.heading)
            SetEntityLodDist(tmpObj, 500)
            cinemaObj[v.id] = {
                owner_id = v.owner_id,
                owner_name = v.owner_name,
                object = tmpObj,
                object_hash = GetHashKey(tmpObj),
                location = v.pos,
                heading = v.heading,
                id = v.id,
                play_state = false,
                type = v.type
            }
            Citizen.Wait(2500)
            TriggerEvent('Pars_cinema:client:asyncUrl', v.id, v.url, v.volume)
        end
        Citizen.Wait(2000)
        SendDuiMessage(duiObj, json.encode({
            action = "setting",
            StopBackground = config.General.StopBackground
        }))
    end)
end)

RegisterNUICallback('copyLocation', function(data, cb)
    local object = cinemaObj[data.id]
    if (object ~= nil) then
        local x = object.location[1]
        local y = object.location[2]
        local z = object.location[3] - 3.0
        local h = object.heading
        cb({
            location = x .. ', ' .. y .. ', ' .. z .. ', ' .. h
        })
        TriggerEvent("pNotify:SendNotification", {
            text = "تم نسخ احداثيات الشاشة",
            type = "success",
            timeout = 3000
        })
    end
end)
