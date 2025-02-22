local inShop = false
local shopUIOpen = false

CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, shop in pairs(Config.ShopCoords) do
            local dist = #(playerCoords - shop)

            if dist < 5.0 then
                sleep = 5
                DrawMarker(20, shop.x, shop.y, shop.z - 1.0, 
                    0, 0, 0, -- Direction (no change)
                    180.0, 0, 0, -- Rotation (Invert on X-axis)
                    0.8, 0.8, 1.0, -- Scale
                    247, 219, 5, 150, -- Color (Green with 150 alpha)
                    false, false, 2, false, nil, nil, false)

                if dist < 1.5 and not shopUIOpen then
                    exports["UnixTextUI"]:triggerInteraction()
                    if IsControlJustPressed(0, 38) then -- E Key
                        OpenShopUI()
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

function OpenShopUI()
    print("Attempting to open shop UI...")

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openShop",
        items = Config.Items
    })

    print("NUI message sent to open UI!")
end

Citizen.CreateThread(function()
    for _, shop in pairs(Config.ShopCoords) do
        local blip = AddBlipForCoord(shop.x, shop.y, shop.z)
        SetBlipSprite(blip, 52) -- Shop icon
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Shop")
        EndTextCommandSetBlipName(blip)
    end
end)
function OpenShopUI()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openShop", items = Config.Items })
    shopUIOpen = true
end

RegisterNUICallback('closeShop', function()
    SetNuiFocus(false, false)
    shopUIOpen = false
end)

RegisterNUICallback('buyItem', function(data)
    TriggerServerEvent('shop:buyItem', data.item, data.amount)
end)

function ShowHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end


-- GETTING PLAYER DATA FROM SERVER.LUA
RegisterNUICallback("requestPlayerData", function(_, cb)
    TriggerServerEvent("shop:getPlayerData")
    cb("ok")
end)

RegisterNetEvent("shop:sendPlayerData")
AddEventHandler("shop:sendPlayerData", function(fullName, cash)
    SendNUIMessage({
        action = "updatePlayerData",
        playerName = fullName,
        playerCash = cash
    })
end)
