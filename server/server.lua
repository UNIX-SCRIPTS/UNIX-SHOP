if Config.Framework == "ESX" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "QBCore" then
    QBCore = exports['qb-core']:GetCoreObject()
end

RegisterServerEvent('shop:buyItem')
AddEventHandler('shop:buyItem', function(item, amount)
    local src = source
    local xPlayer

    if Config.Framework == "ESX" then
        xPlayer = ESX.GetPlayerFromId(src)
    elseif Config.Framework == "QBCore" then
        xPlayer = QBCore.Functions.GetPlayer(src)
    end

    local itemData = nil
    for _, v in pairs(Config.Items) do
        if v.item == item then
            itemData = v
            break
        end
    end

    if itemData then
        local totalCost = itemData.price * amount
        local hasMoney = false

        if Config.Framework == "ESX" then
            if xPlayer.getMoney() >= totalCost then
                xPlayer.removeMoney(totalCost)
                hasMoney = true
            end
        elseif Config.Framework == "QBCore" then
            if xPlayer.Functions.RemoveMoney('cash', totalCost) then
                hasMoney = true
            end
        end

        if hasMoney then
            xPlayer.addInventoryItem(item, amount)
            TriggerClientEvent('shop:notify', src, "Purchase successful!", "success")
        else
            TriggerClientEvent('shop:notify', src, "Not enough money!", "error")
        end
    end
end)

-- FETCHING PLAYER DETAILS 

RegisterNetEvent("shop:getPlayerData")
AddEventHandler("shop:getPlayerData", function()
    local src = source
    local xPlayer = nil

    if Config.Framework == "ESX" then
        xPlayer = ESX.GetPlayerFromId(src)
    elseif Config.Framework == "QBCore" then
        xPlayer = QBCore.Functions.GetPlayer(src)
    end

    if not xPlayer then return end

    -- Default values
    local firstName, lastName, userName = "User", "", GetPlayerName(src)
    local cash = 0

    -- Fetch player data based on framework
    if Config.Framework == "ESX" then
        if xPlayer.get("firstName") then firstName = xPlayer.get("firstName") end
        if xPlayer.get("lastName") then lastName = xPlayer.get("lastName") end
        cash = xPlayer.getMoney() -- Get cash in hand
    elseif Config.Framework == "QBCore" then
        if xPlayer.PlayerData.charinfo.firstname then firstName = xPlayer.PlayerData.charinfo.firstname end
        if xPlayer.PlayerData.charinfo.lastname then lastName = xPlayer.PlayerData.charinfo.lastname end
        cash = xPlayer.Functions.GetMoney("cash") -- Get cash in hand
    end

    -- Combine first & last name, fallback to username
    local fullName = firstName .. (lastName ~= "" and " " .. lastName or "")
    if fullName == "User" then fullName = userName end

    -- Send name & cash balance to the client
    TriggerClientEvent("shop:sendPlayerData", src, fullName, cash)
end)
