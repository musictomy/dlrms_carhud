local directions = { [0] = 'K', [1] = 'KB', [2] = 'B', [3] = 'GB', [4] = 'G', [5] = 'GD', [6] = 'D', [7] = 'KD', [8] = 'K' } 
local zones = { ['AIRP'] = "Los Santos International Airport", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo", ['BANHAMC'] = "Banham Canyon Dr", ['BANNING'] = "Banning", ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon", ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge", ['CANNY'] = "Raton Canyon", ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills", ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain State Wilderness", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis", ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora Desert", ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", ['EBURO'] = "El Burro Heights", ['ELGORL'] = "El Gordo Lighthouse", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GOLF'] = "GWC and Golfing Society", ['GRAPES'] = "Grapeseed", ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack", ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir", ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta", ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo", ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OCEANA'] = "Pacific Ocean", ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands", ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach", ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Lights Track", ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski Mountain Range", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row", ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal", ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci", ['VINE'] = "Vinewood", ['WINDF'] = "Ron Alternates Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", ['ZP_ORT'] = "Port of South Los Santos", ['ZQ_UAR'] = "Davis Quartz" }
----------------------------------------------
local currentSpeed = 0.0
local cruiseSpeed = 999.0
local cruiseIsOn = false
local pedInVeh = false
local speedBuffer = {}
local velBuffer = {}
local SeatbeltON = false
----------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local position = GetEntityCoords(ped)

        direction = directions[math.floor((GetEntityHeading(ped) + 22.5) / 45.0)]
        zoneName = zones[GetNameOfZone(position.x, position.y, position.z)]
        streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(position.x, position.y, position.z))
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local pauseMenuOn = IsPauseMenuActive()

        if IsPedInVehicle(ped, vehicle, false) and not pauseMenuOn then 
            pedInVeh = true 
            if pedInVeh then
                local speedLimit = Config.SpeedLimit
                local fuelLimit = Config.FuelLimit
                local signalLights = GetVehicleIndicatorLights(vehicle)
                local fuel = GetVehicleFuelLevel(vehicle)
                local speed = GetEntitySpeed(vehicle) * 3.6 --3.6 = KM/H , 2.236936 = MPH
                local gear = GetVehicleCurrentGear(vehicle)
                local engineControl = GetIsVehicleEngineRunning(vehicle)
                
                local vehVal, lowBeamsOn, highbeamsOn = GetVehicleLightsState(vehicle)
                if lowBeamsOn == 1 and highbeamsOn == 0 then
                    lights = 'normal'
                elseif lowBeamsOn == 1 and highbeamsOn == 1 or lowBeamsOn == 0 and highbeamsOn == 1 then
                    lights = 'high'
                else
                    lights = 'off'
                end
                ----------------------------------
                SendNUIMessage({
                    pedInVeh = true,
                    pauseMenuOn = pauseMenuOn,
                    cruiseIsOn = cruiseIsOn,
                    engineControl = engineControl,
                    speedLimit = speedLimit,
                    fuelLimit = fuelLimit,
                    streetName = streetName,
                    zoneName = zoneName,
                    direction = direction,
                    lights = lights,
                    signalLights = signalLights,
                    speed = speed,
                    gear = gear,
                    fuel = fuel,
                    SeatbeltON = SeatbeltON
                })
            end
        else
            SendNUIMessage({
                pedInVeh = false,
            })
        end
    end
end)

-- Cruise Control
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local vehicleClass = GetVehicleClass(vehicle)

        if IsPedInVehicle(ped, vehicle, false) and GetIsVehicleEngineRunning(vehicle) and vehicleClass ~= 13 then
            pedInVeh = true
            
            local prevSpeed = currentSpeed
            currentSpeed = GetEntitySpeed(vehicle)

            if (GetPedInVehicleSeat(vehicle, -1) == ped) then
                if IsControlJustReleased(0, Config.CruiseInput) then
                    cruiseSpeed = currentSpeed
                    cruiseIsOn = not cruiseIsOn
                end
                local maxSpeed = cruiseIsOn and cruiseSpeed or GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel")
                SetEntityMaxSpeed(vehicle, maxSpeed)
            else
                pedInVeh = false
                cruiseIsOn = false
            end
        end
        Citizen.Wait(10)
    end
end)

--------- Seatbelt ---------
AddEventHandler('seatbelt:sounds', function(soundFile, soundVolume)
    SendNUIMessage({
        transactionType = 'playSound',
        transactionFile = soundFile,
        transactionVolume = soundVolume
    })
end)

function IsCar(veh)
    local vc = GetVehicleClass(veh)
    return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end	

function Fwv(entity)
    local hr = GetEntityHeading(entity) + 90.0
    if hr < 0.0 then hr = 360.0 + hr end
    hr = hr * 0.0174533
    return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end
 
Citizen.CreateThread(function()
	while true do
	Citizen.Wait(1)
  
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped)

    if vehicle ~= 0 and (pedInVeh or IsCar(vehicle)) then
        pedInVeh = true

        if SeatbeltON then 
            DisableControlAction(0, 75, true)  -- Disable exit vehicle when stop
            DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
        end

        speedBuffer[2] = speedBuffer[1]
        speedBuffer[1] = GetEntitySpeed(vehicle)

        if not SeatbeltON and speedBuffer[2] ~= nil and GetEntitySpeedVector(vehicle, true).y > 1.0 and speedBuffer[1] > (80.0 / 3.6) and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
            local co = GetEntityCoords(ped)
            local fw = Fwv(ped)
            SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
            SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
            Citizen.Wait(1)
            SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
        end
        
        velBuffer[2] = velBuffer[1]
        velBuffer[1] = GetEntityVelocity(vehicle)
            
        if IsControlJustPressed(0, Config.SeatBeltInput) and GetLastInputMethod(0) then
            SeatbeltON = not SeatbeltON 
            if SeatbeltON then
                Citizen.Wait(1)
                TriggerEvent("seatbelt:sounds", "buckle", Config.SeatBeltVolume)
            else 
                TriggerEvent("seatbelt:sounds", "unbuckle", Config.SeatBeltVolume)
            end
        end

        elseif pedInVeh then
            pedInVeh = false
            SeatbeltON = false
            speedBuffer[1], speedBuffer[2] = 0.0, 0.0
        end
    end
end)
