local spawnedBottles = {}
local hintVisible = false

-- Function to spawn a bottle
RegisterNetEvent('bk_bottlespin:client:spawnBottle', function(item)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local spawnCoords = coords + forward * 1.0
    
    local model = Config.Items[item].model
    lib.requestModel(model)
    
    local _, groundZ = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z, 0)
    local bottle = CreateObject(model, spawnCoords.x, spawnCoords.y, groundZ, true, false, true)
    SetEntityRotation(bottle, 90.0, 0.0, GetEntityHeading(playerPed), 2, true)
    PlaceObjectOnGroundProperly(bottle)
    FreezeEntityPosition(bottle, true)
    
    local netId = NetworkGetNetworkIdFromEntity(bottle)
    SetNetworkIdCanMigrate(netId, true)
    SetNetworkIdExistsOnAllMachines(netId, true)
    
    TriggerServerEvent('bk_bottlespin:server:registerBottle', netId, item)

    exports.qbx_core:Notify(Config.Locales['bottle_placed'], 'success')
end)

-- Function to spin the bottle
local function spinBottle(entity)
    if IsEntityPlayingAnim(entity, "anim", "spin", 3) then return end -- Prevent double spin if already spinning (logic handled by rotation)
    
    local duration = math.random(Config.SpinDuration.min, Config.SpinDuration.max)
    local startTime = GetGameTimer()
    local targetHeading = math.random(0, 359) * 1.0
    
    local netId = NetworkGetNetworkIdFromEntity(entity)
    TriggerServerEvent('bk_bottlespin:server:syncSpin', netId, duration, targetHeading)
end

RegisterNetEvent('bk_bottlespin:client:syncSpin', function(netId, duration, targetHeading)
    if not NetworkDoesNetworkIdExist(netId) then return end
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end
    
    CreateThread(function()
        local startTime = GetGameTimer()
        local startRotation = GetEntityRotation(entity, 2)
        local startZ = startRotation.z
        
        local randomSpins = math.random(3, 8)
        local totalRotation = (360 * randomSpins) + (targetHeading - startZ)
        
        while GetGameTimer() - startTime < duration do
            local elapsed = GetGameTimer() - startTime
            local progress = elapsed / duration
            -- Ease out cubic for a natural stop
            local easeProgress = 1 - math.pow(1 - progress, 3)
            local currentZ = (startZ + (totalRotation * easeProgress)) % 360
            SetEntityRotation(entity, 90.0, 0.0, currentZ, 2, true)
            Wait(0)
        end
        SetEntityRotation(entity, 90.0, 0.0, targetHeading, 2, true)
    end)
end)

local function showSpinHint()
    if hintVisible then return end
    local message = ('[%s] %s'):format(Config.Locales['spin_key'], Config.Locales['spin_bottle'])

    lib.showTextUI(message, {
        position = Config.UI.position,
        style = {
            borderRadius = Config.UI.borderRadius,
            backgroundColor = Config.UI.backgroundColor,
            color = Config.UI.textColor,
            marginTop = Config.UI.offsetTop
        }
    })

    hintVisible = true
end

local function hideSpinHint()
    if not hintVisible then return end
    lib.hideTextUI()
    hintVisible = false
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    hideSpinHint()
end)

-- Interaction Loop
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        local closestBottle = 0
        local minDist = Config.InteractDistance
        
        for item, data in pairs(Config.Items) do
            local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, minDist, data.model, false, false, false)
            if DoesEntityExist(obj) then
                closestBottle = obj
                break
            end
        end
        
        if DoesEntityExist(closestBottle) then
            sleep = 0
            showSpinHint()
            
            if IsControlJustReleased(0, Config.InteractKey) then
                spinBottle(closestBottle)
                exports.qbx_core:Notify(Config.Locales['spin_notification'], 'inform')
            end
        else
            hideSpinHint()
        end
        Wait(sleep)
    end
end)

-- Pickup Command
RegisterCommand(Config.PickupCommand, function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestBottle = 0
    local minDist = Config.InteractDistance
    local itemType = nil
    
    for item, data in pairs(Config.Items) do
        local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, minDist, data.model, false, false, false)
        if DoesEntityExist(obj) then
            closestBottle = obj
            itemType = item
            break
        end
    end
    
    if DoesEntityExist(closestBottle) then
        local netId = NetworkGetNetworkIdFromEntity(closestBottle)
        TriggerServerEvent('bk_bottlespin:server:pickupBottle', netId, itemType)
    else
        exports.qbx_core:Notify(Config.Locales['no_bottle_nearby'], 'error')
    end
end, false)

-- Add suggestion for the pickup command
TriggerEvent('chat:addSuggestion', '/' .. Config.PickupCommand, Config.Locales['pickup_bottle']:format(Config.PickupCommand))