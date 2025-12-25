local activeBottles = {}

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
    activeBottles[netId] = item
end)

-- Sync spin to all clients
RegisterNetEvent('bk_bottlespin:server:syncSpin', function(netId, duration, targetHeading)
    TriggerClientEvent('bk_bottlespin:client:syncSpin', -1, netId, duration, targetHeading)
end)

-- Pickup bottle and return item
RegisterNetEvent('bk_bottlespin:server:pickupBottle', function(netId, itemType)
    local src = source
    local entity = NetworkGetEntityFromNetworkId(netId)
    
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
        activeBottles[netId] = nil
        
        -- Give item back
        exports.ox_inventory:AddItem(src, itemType, 1)
        exports.qbx_core:Notify(src, Config.Locales['bottle_picked_up'], 'success')
    end
end)