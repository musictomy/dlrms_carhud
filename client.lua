
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
    local directions = Config.Directions
    local zones = Config.Zones 
    while true do
        Citizen.Wait(1000)
        local ped = GetPlayerPed(-1)
        if pedInVeh then 
            local position = GetEntityCoords(ped)

            direction = directions[math.floor((GetEntityHeading(ped) + 22.5) / 45.0)]
            zoneName = zones[GetNameOfZone(position.x, position.y, position.z)]
            streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(position.x, position.y, position.z))
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        local ped = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local pauseMenuOn = IsPauseMenuActive()

        if IsPedInVehicle(ped, vehicle, false) and not pauseMenuOn then 
            pedInVeh = true
            if pedInVeh then
                local speedLimit = Config.SpeedAlertLimit
                local speedType = Config.SpeedType
                local fuelLimit = Config.FuelAlertLimit
                local signalLights = GetVehicleIndicatorLights(vehicle)
                local fuel = GetVehicleFuelLevel(vehicle)
                local gear = GetVehicleCurrentGear(vehicle)
                local engineControl = GetIsVehicleEngineRunning(vehicle)

                if speedType == 'kmh' then
                    speed = GetEntitySpeed(vehicle) * 3.6
                elseif speedType == 'mph' then
                    speed = GetEntitySpeed(vehicle) * 2.236936 -- or 2.23694
                end
                
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
                    isCar = isCar,
                    speedType = speedType,
                    pauseMenuOn = pauseMenuOn,
                    cruiseIsOn = cruiseIsOn,
                    engineControl = engineControl,
                    speedLimit = speedLimit,
                    fuelLimit = fuelLimit,
                    lights = lights,
                    signalLights = signalLights,
                    streetName = streetName,
                    zoneName = zoneName,
                    direction = direction,
                    speed = speed,
                    gear = gear,
                    fuel = fuel,
                    SeatbeltON = SeatbeltON
                })
                ----------------------------------
            end
        else
            SendNUIMessage({
                pedInVeh = false,
            })
            Citizen.Wait(500)
        end
    end
end)

-- Cruise Control
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        local ped = GetPlayerPed(-1)
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
        else
            Citizen.Wait(500)
        end
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
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(ped)
    isCar = IsCar(vehicle)

    if vehicle ~= 0 and isCar then
        pedInVeh = true

        if SeatbeltON then 
            DisableControlAction(0, 75, true)  -- Disable exit vehicle when stop
            DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
        end

        speedBuffer[2] = speedBuffer[1]
        speedBuffer[1] = GetEntitySpeed(vehicle)

        velBuffer[2] = velBuffer[1]
        velBuffer[1] = GetEntityVelocity(vehicle)

        if not SeatbeltON and speedBuffer[2] ~= nil and GetEntitySpeedVector(vehicle, true).y > 1.0 and speedBuffer[1] > (80.0 / 3.6) and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
            local co = GetEntityCoords(ped)
            local fw = Fwv(ped)
            SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
            SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
            Citizen.Wait(1)
            SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
        end
            
        if IsControlJustPressed(0, Config.SeatBeltInput) then
            SeatbeltON = not SeatbeltON 
            if SeatbeltON then
                TriggerEvent("seatbelt:sounds", "buckle", Config.SeatBeltVolume)
            else 
                TriggerEvent("seatbelt:sounds", "unbuckle", Config.SeatBeltVolume)
            end
        end

        elseif pedInVeh then
            pedInVeh = false
            SeatbeltON = false
            speedBuffer[1], speedBuffer[2] = 0.0, 0.0
            Citizen.Wait(500)
        end
        
    end
        SendNUIMessage({
        })
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1000)
        if not SeatbeltON and pedInVeh and GetIsVehicleEngineRunning(GetVehiclePedIsIn(GetPlayerPed(-1), false)) and Config.SeatBeltAlarm then
            TriggerEvent("seatbelt:sounds", "seatbelt", Config.SeatBeltVolume)
        end    
	end
end)