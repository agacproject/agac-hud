local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent("agac-hud:savedata:server")
AddEventHandler("agac-hud:savedata:server", function(yemek, su)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)	
    if xPlayer then
        xPlayer.Functions.SetMetaData("hunger", yemek)
        xPlayer.Functions.SetMetaData("thirst", su)
    end
end)
