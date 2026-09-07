local codecraft_lib = exports['CCD-Library']:import()
local dealers = {}
local uiConfig = Config.UI or {}
local nuiReady = false
local marketPending = false
local marketItems = nil

if Config.Debug then print('[CCD_BlackMarket] client script loaded') end

local function sendMarketOpen(itemsOverride)
    local uiItems = {}
    local sourceItems = itemsOverride or marketItems or Config.Items or {}
    for index, item in ipairs(sourceItems) do
        uiItems[index] = {
            item = item.item,
            label = item.label,
            category = item.category,
            description = item.description,
            price = item.price,
            currency = item.currency,
            amount = item.amount,
            stock = item.stock,
            icon = item.icon,
            image = item.image,
        }
    end

    SendNUIMessage({
        action = 'open',
        title = uiConfig.title or 'BLACK MARKET',
        subtitle = uiConfig.subtitle or 'Private supply channel',
        currencySymbol = uiConfig.currencySymbol or '$',
        items = uiItems,
    })
end

local function openMarket()
    marketPending = true
    if Config.Debug then
        print(('[CCD_BlackMarket] opening UI; nuiReady=%s'):format(tostring(nuiReady)))
    end
    TriggerServerEvent('CCD_BlackMarket:server:requestOpen')
    TriggerServerEvent('CCD_BlackMarket:server:requestStock')

    CreateThread(function()
        for _ = 1, 12 do
            Wait(250)
            if not marketPending then return end
            sendMarketOpen()
        end
        if marketPending and not nuiReady then
            marketPending = false
            SetNuiFocus(false, false)
            if Config.Debug then
                print('[CCD_BlackMarket] NUI did not become ready; mouse focus released.')
            end
        end
    end)
end

-- Use a qb-target/ox_target event for the dealer interaction. This avoids
-- passing a resource-local Lua closure through qb-target's NUI selection path.
RegisterNetEvent('CCD_BlackMarket:client:openFromTarget', function()
    openMarket()
end)

RegisterNetEvent('CCD_BlackMarket:client:open', function(items)
    marketItems = items
    sendMarketOpen(marketItems)
    SetNuiFocus(true, true)
end)

RegisterNUICallback('ready', function(_, cb)
    nuiReady = true
    if Config.Debug then print('[CCD_BlackMarket] NUI page reported ready') end
    if marketPending then sendMarketOpen() end
    cb({ ok = true })
end)

-- Emergency fallback if the NUI page ever fails to load.
RegisterCommand('ccd_blackmarket_close', function()
    marketPending = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end, false)
RegisterKeyMapping('ccd_blackmarket_close', 'Close black market UI', 'keyboard', 'F10')

RegisterNetEvent('CCD_BlackMarket:client:setStock', function(stock)
    SendNUIMessage({ action = 'stock', stock = stock })
end)

RegisterNetEvent('CCD_BlackMarket:client:purchaseResult', function(success, message, stock)
    SendNUIMessage({
        action = 'purchaseResult',
        success = success,
        message = message,
        stock = stock,
    })
end)

RegisterNUICallback('close', function(_, cb)
    marketPending = false
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

RegisterNUICallback('buy', function(data, cb)
    local index = tonumber(data and data.index)
    if index then
        TriggerServerEvent('CCD_BlackMarket:server:buyItem', index)
    end
    cb({ ok = true })
end)

local function loadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        if Config.Debug then
            print(('[CCD_BlackMarket] Invalid ped model: %s'):format(tostring(model)))
        end
        return nil
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end
    return hash
end

CreateThread(function()
    local model = loadModel(Config.Ped.model)
    if not model then return end

    for index, coords in ipairs(Config.Locations) do
        local ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
        SetEntityAsMissionEntity(ped, true, true)
        FreezeEntityPosition(ped, Config.Ped.frozen)
        SetEntityInvincible(ped, Config.Ped.invincible)
        SetBlockingOfNonTemporaryEvents(ped, Config.Ped.blockEvents)
        if Config.Ped.scenario then
            TaskStartScenarioInPlace(ped, Config.Ped.scenario, 0, true)
        end

        local targetName = ('ccd_blackmarket_dealer_%s'):format(index)
        codecraft_lib.addLocalEntity(ped, targetName, Config.Interaction.label, Config.Interaction.icon,
            Config.Interaction.distance, nil, 'CCD_BlackMarket:client:openFromTarget', nil, 'client')
        dealers[#dealers + 1] = ped
    end

    SetModelAsNoLongerNeeded(model)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    for _, ped in ipairs(dealers) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
end)
