local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent("bad-hud:savedata:server")
AddEventHandler("bad-hud:savedata:server", function(yemek, su)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)	
    if xPlayer then
        xPlayer.Functions.SetMetaData("hunger", yemek)
        xPlayer.Functions.SetMetaData("thirst", su)
    end
end)
