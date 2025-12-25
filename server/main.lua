local activeBottles = {}

local function isValidItem(item)
    return item ~= nil and Config.Items[item] ~= nil
end

local function entityMatchesItem(entity, item)
    if not DoesEntityExist(entity) then return false end
    local model = GetEntityModel(entity)
    return model ~= 0 and isValidItem(item) and model == Config.Items[item].model
end

-- Register usable items based on config
CreateThread(function()
    for item, data in pairs(Config.Items) do
        exports.qbx_core:CreateUseableItem(item, function(source, itemData)
            local src = source
            TriggerClientEvent('bk_bottlespin:client:spawnBottle', src, item)
            exports.ox_inventory:RemoveItem(src, item, 1)
        end)
    end
end)

-- Register bottle on server
RegisterNetEvent('bk_bottlespin:server:registerBottle', function(netId, item)
    local src = source
    if not netId or not isValidItem(item) then return end
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end
    if not entityMatchesItem(entity, item) then return end
    if NetworkGetEntityOwner(entity) ~= src then return end

    activeBottles[netId] = item
end)

-- Sync spin to all clients
RegisterNetEvent('bk_bottlespin:server:syncSpin', function(netId, duration, targetHeading)
    if not activeBottles[netId] then return end
    TriggerClientEvent('bk_bottlespin:client:syncSpin', -1, netId, duration, targetHeading)
end)

-- Pickup bottle and return item
RegisterNetEvent('bk_bottlespin:server:pickupBottle', function(netId)
    local src = source
    local itemType = activeBottles[netId]
    if not itemType or not isValidItem(itemType) then return end
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entityMatchesItem(entity, itemType) then return end

    if DoesEntityExist(entity) then
        DeleteEntity(entity)
        activeBottles[netId] = nil

        -- Give item back (server-trusted item)
        exports.ox_inventory:AddItem(src, itemType, 1)
        exports.qbx_core:Notify(src, Config.Locales['bottle_picked_up'], 'success')
    end
end)

