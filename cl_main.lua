local QBCore = exports['qb-core']:GetCoreObject()
local isTalking = false
local isRadio = false
local voiceLevel = 2
local hungry = 100
local thirst = 100
local hudStatus = false
local isDead = false

local adSu, animSu, bodySu = "amb@world_human_drinking@beer@male@idle_a", "idle_c", 49   
local adSigara, animSigara, bodySigara = "amb@world_human_smoking@male@male_b@idle_a", "idle_a", 49 
local adYemek, animYemek, bodyYemek = "mp_player_inteat@burger", "mp_player_int_eat_burger", 49

AddEventHandler('bad:playerdead', function(dead)
	isDead = dead
end)

-- ses seviyesi, bagirma, fisildama ve normal (3 = bagirma, 2 = normal, 1 = fisildama)
RegisterNetEvent('agac-hud:setVoiceLevel')
AddEventHandler('agac-hud:setVoiceLevel', function(level)
    voiceLevel = level
end)

-- konusuyor/konusmuyor (true = konusuyor, false = konusmuyor)
-- eger eventi triggerlarken radio kismini true yaparsaniz konusma rengi farklilasir
RegisterNetEvent('agac-hud:setTalkingState')
AddEventHandler('agac-hud:setTalkingState', function(state, radio)
    if radio == true then
        isTalking = 'radio'
    else
        isTalking = state
    end
end)

-- aktif olarak bir telsizde mi (true = telsizde, false = telsizde degil)
RegisterNetEvent('agac-hud:setRadioState')
AddEventHandler('agac-hud:setRadioState', function(state)
    isRadio = state
end)

RegisterNetEvent('agac-hud:loadHud')
AddEventHandler('agac-hud:loadHud', function()
    isLoggedIn = true
    hudStatus = true
    SendNUIMessage({
        type = 'hudactive'
    })
end)

RegisterCommand('debughud', function()
    TriggerEvent('agac-hud:loadHud')
end)

RegisterCommand('hud', function()
    if hudStatus then
        SendNUIMessage({
            type = 'huddeactive'
        })
        hudStatus = false
    else
        SendNUIMessage({
            type = 'hudactive'
        })
        hudStatus = true
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()
        PlayerData = QBCore.Functions.GetPlayerData()
        if isLoggedIn then
            wait = 1
            pData = {
                health = GetEntityHealth(PlayerPedId()) / 2,
                armor = GetPedArmour(PlayerPedId()),
                hungry = PlayerData.metadata["hunger"],
                thirst = PlayerData.metadata["thirst"],
                oxygen = math.ceil(100 - GetPlayerSprintStaminaRemaining(PlayerId())),
                stress = 12,
                talking = isTalking,
                radio = isRadio,
                voicelevel = voiceLevel,
            }
            hungry = PlayerData.metadata["hunger"]
            thirst = PlayerData.metadata["thirst"]
            SendNUIMessage({
                type = 'update',
                data = pData
            })
        else
            wait = 1000
        end
        Citizen.Wait(wait) -- hud verilerinin guncellenme milisaniyesi
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- hudun arac veya normal hali icin guncellenme milisaniyesi
        if IsPedInAnyVehicle(PlayerPedId()) then
            if currentType ~= 'vehicle' then
                SendNUIMessage({
                    type = 'open',
                    data = 'vehicle'
                })
                currentType = 'vehicle'
            end
        else
            if currentType ~= 'normal' then
                SendNUIMessage({
                    type = 'open',
                    data = 'normal'
                })
                currentType = 'normal'
            end
        end
    end
end)

-- aracta radar aktif, arac disi radar inaktif (radar yani minimap)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5) -- kontrol milisaniyesi
        if not IsPedInAnyVehicle(PlayerPedId(), true) then
            DisplayRadar(false)
        else
            DisplayRadar(true)
        end
    end
end)

Citizen.CreateThread( function()
    while true do
        local player = PlayerPedId()
        local wait = 1000 -- default guncellenme milisaniyesi
        if currentType == 'vehicle' then
            wait = 300 -- eger aractaysa verilerin guncellenme milisaniyesi
            if IsPedInAnyVehicle(player, false) then
                local vehdata = {
                    speed = math.floor(((GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId()))) * 2.236936) * 1.609344), -- KMH
                    fuel = GetVehicleFuelLevel(GetVehiclePedIsIn(PlayerPedId())), -- fuel exportu koymayi unutma
                }
                SendNUIMessage({
                    type = 'updatespeed',
                    data = vehdata,
                })
                
            end
        end
        Citizen.Wait(wait)
    end
end)

-- Minimap
Citizen.CreateThread(function()
	RequestStreamedTextureDict("circlemap", false)
	while not HasStreamedTextureDictLoaded("circlemap") do
		Wait(100)
	end

	AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")

	SetMinimapClipType(1)
	SetMinimapComponentPosition('minimap', 'L', 'B', -0.0085, -0.010, 0.128, 0.221)
	SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.010 + 0.10, 0.010 + 0.10, 0.10 - 0.026, 0.15 - 0.026 ) -- MARKER
	SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.0067, 0.020, 0.178, 0.262)

    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)

    while true do
        Citizen.Wait(100)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

-- Status

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)
		if isLoggedIn then
			TriggerServerEvent("agac-hud:savedata:server", hungry, thirst)
		end
	end
end)

RegisterNetEvent('agac-hud:eatOrDrink')
AddEventHandler('agac-hud:eatOrDrink', function(itemName, eatOrDrink, addValue, EODTime)
	if not IsAnimated then
		QBCore.Functions.TriggerCallback("bad-base:removeItem", function(result)
			if result then
				local totalTime = EODTime
				if eatOrDrink == "eat" then
					animasyonVeProp(adYemek, animYemek, bodyYemek, '', 18905, 0.13, 0.05, 0.02, -50.0, 16.0, 60.0, totalTime, true) 
				elseif eatOrDrink == "drink" then
					animasyonVeProp(adSu, animSu, bodySu, '', 57005, 0.13, 0.02, -0.05, -85.0, 175.0, 0.0, totalTime, true) 	
				end
				local minAddStatusValue = addValue
				while totalTime > 0 do
					Citizen.Wait(1000) -- 1 Saniye
					totalTime = totalTime - 1000
					if eatOrDrink == "eat" then
						local yeniDeger = hungry + minAddStatusValue 
						hungry = yeniDeger
                        TriggerServerEvent("agac-hud:savedata:server", hungry, thirst)
						if yeniDeger > 100.0 then hungry = 100.0 end
					elseif eatOrDrink == "drink" then
						local yeniDeger = thirst + minAddStatusValue 
						thirst = yeniDeger
                        TriggerServerEvent("agac-hud:savedata:server", hungry, thirst)
						if yeniDeger > 100.0 then thirst = 100.0 end
					end
				end
			end
		end, itemName, 1)
	end
end)

RegisterNetEvent('agac-hud:sigara')
AddEventHandler('agac-hud:sigara', function()	
            local i = 0
            QBCore.Functions.Progressbar("sigara", "Tüttürüyorsun", 20000, false, true, { -- p1: menu name, p2: yazı, p3: ölü iken kullan, p4:iptal edilebilir
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = adSigara,
                anim = animSigara,
                flags = bodySigara,
            }, { -- prop1
                model = "ng_proc_cigarette01a",
                bone = 64017,
                coords = { x = 0.010, y = 0.0, z = 0.0 },
                rotation = { x = 50.0, y = 0.0, z = 80.0 }, 
            }, {}, function() -- Done
                    QBCore.Functions.TriggerCallback("bad-base:removeItem", function(result)
                    TriggerEvent('efe:levelayarla', false, math.random(5,10))
            end, function() -- Cancel
            end)
        end, 'sigara', 1)
		IsAnimated = false		
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        Citizen.Wait(0)
        if IsPedArmed(ped, 6) then
            ShowHudComponentThisFrame(14)
        end
    end
end)

function animasyonVeProp(ad, anim, body, prop, propD1, propD2, propD3, propD4, propD5, propD6, propD7, time, cancel)
	if not IsAnimated then
		IsAnimated = true
		QBCore.Functions.Progressbar("icveye", "Kullanılıyor", time, false, false, { -- p1: menu name, p2: yazı, p3: ölü iken kullan, p4:iptal edilebilir
			disableMovement = false,
			disableCarMovement = false,
			disableMouse = false,
			disableCombat = true,
		}, {
			animDict = ad,
			anim = anim,
			flags = body,
		}, { -- prop1
			model = prop,
			bone = propD1,
			coords = { x = propD2, y = propD3, z = propD4 },
			rotation = { x = propD5, y = propD6, z = propD7 }, 
        }, function() -- Done
            IsAnimated = false
        end, function() -- Cancel
            IsAnimated = false
        end)
	end
    IsAnimated = false
end

function gotunYiyorsaAracSur()
	local rastgele = math.random(1, #RandomVehicleInteraction)
	return RandomVehicleInteraction[rastgele]
end

function loadPropDict(model)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(500)
	end
end

lastDamageTime = GetGameTimer()
Citizen.CreateThread(function()
	while true do
        local playerPed = PlayerPedId()
        PlayerData = QBCore.Functions.GetPlayerData()
		if isLoggedIn then
			if not PlayerData.metadata['injail'] and not isDead then
				if hungry > 0.0 then
					hungry = hungry - 0.20
				end
				if thirst > 0.0 then
					thirst = thirst - 0.20
				end
			end
			if hungry > 100.0 then
				hungry = 100.0
			elseif hungry < 0.0 then
				hungry = 0.0
			end	
            if thirst > 100 then
				thirst = 100
			elseif thirst < 0.0 then
				thirst = 0.0
			end	
            Citizen.Wait(50)
            if aclik == 3.0 or thirst == 3.0 then
                local playerPed = PlayerPedId()
                local adamincan = GetEntityHealth(playerPed)
                SetEntityHealth(playerPed, adamincan - 15)
                QBCore.Functions.Notify("Kendini kötü hissediyorsun!", "error", 5000)
            end
		end
		if HasPedBeenDamagedByWeapon(ped, 0, 2) then
			lastDamageTime = GetGameTimer() + 30000  -- 300000
			ClearEntityLastDamageEntity(ped)
			ClearEntityLastWeaponDamage(ped)
		end
		Citizen.Wait(10000)
	end
end)

RegisterNetEvent('revlendinfulleustamk')
AddEventHandler('revlendinfulleustamk', function()
    if hungry < 50 or thirst < 50 then
        hungry = 50
        thirst = 50
        TriggerServerEvent("agac-hud:savedata:server", hungry, thirst)
    end
end)
