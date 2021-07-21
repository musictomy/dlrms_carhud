--------- Variables ---------
local currentSpeed = 0.0
local cruiseSpeed = 999.0
local cruiseIsOn = false
local SeatbeltON = false
local speedBuffer = {}
local velBuffer = {}
--------- Variables End ---------
local ui = false
function SetDisplayUI(bool) 
    SendNUIMessage({
        action = 'ui',
        ui = bool
    })
end
--------- Compass ---------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local ped = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsIn(ped)

        if IsPedInVehicle(ped, vehicle, false) and not pauseMenuOn then 
            local directions = Config.Directions
            local zones = Config.Zones 
            local position = GetEntityCoords(ped)

            direction = directions[math.floor((GetEntityHeading(ped) + 22.5) / 45.0)]
            zoneName = zones[GetNameOfZone(position.x, position.y, position.z)]
            streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(position.x, position.y, position.z))
            
            SendNUIMessage({
                action = 'compass',
                streetName = streetName,
                zoneName = zoneName,
                direction = direction
            })
        end
    end
end)
--------- Compass End ---------

--------- Main ---------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        local ped = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local pauseMenuOn = IsPauseMenuActive()

        if IsPedInVehicle(ped, vehicle, false) and not pauseMenuOn then 
            ui = true
            local speedLimit = Config.SpeedAlertLimit
            local speedType = Config.SpeedType
            local gear = math.floor(GetVehicleCurrentGear(vehicle))
            local fuel = math.floor(GetVehicleFuelLevel(vehicle))
            local fuelLimit = Config.FuelAlertLimit
            local engineControl = GetIsVehicleEngineRunning(vehicle)
            local signalLights = GetVehicleIndicatorLights(vehicle)
            local handbrake = GetVehicleHandbrake(vehicle) 
            
            if speedType == 'kmh' then
                speed = math.floor(GetEntitySpeed(vehicle) * 3.6)
            elseif speedType == 'mph' then
                speed =  math.floor(GetEntitySpeed(vehicle) * 2.23694) -- or 2.23694
            end

            local vehVal, lowBeamsOn, highbeamsOn = GetVehicleLightsState(vehicle)
            if lowBeamsOn == 1 and highbeamsOn == 0 then
                lights = 'normal'
            elseif lowBeamsOn == 1 and highbeamsOn == 1 or lowBeamsOn == 0 and highbeamsOn == 1 then
                lights = 'high'
            else
                lights = 'off'
            end

            SendNUIMessage({
                action = 'ui',
                ui = true,
                speedType = speedType,
                pauseMenuOn = pauseMenuOn,
                engineControl = engineControl,
                speedLimit = speedLimit,
                fuelLimit = fuelLimit,
                lights = lights,
                handbrake = handbrake,
                signalLights = signalLights,
                speed = speed,
                gear = gear,
                fuel = fuel,
            })
           
            SendNUIMessage({
                action = 'seatbelt',
                isCar = isCar,
                SeatbeltON = SeatbeltON
            })
            SendNUIMessage({
                action = 'cruise',
                cruiseIsOn = cruiseIsOn
            })
        else
            ui = false
            SendNUIMessage({
                action = 'ui',
                ui = false,
            })
            Citizen.Wait(500)
        end
    end
end)
--------- Main End ---------

--------- Cruise Control ---------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local ped = GetPlayerPed(-1)
        local vehicle = GetVehiclePedIsIn(ped, false)

        if IsPedInVehicle(ped, vehicle, false) and GetPedInVehicleSeat(vehicle, -1) == ped and GetIsVehicleEngineRunning(vehicle) then
            local prevSpeed = currentSpeed
            currentSpeed = GetEntitySpeed(vehicle)

            if IsControlJustPressed(0, Config.CruiseInput) then
                cruiseSpeed = currentSpeed
                cruiseIsOn = not cruiseIsOn
            end
            local maxSpeed = cruiseIsOn and cruiseSpeed or GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel")
            SetEntityMaxSpeed(vehicle, maxSpeed)
        else
            cruiseIsOn = false
            Citizen.Wait(300)
        end
    end
end)
--------- Cruise Control End ---------

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
        local vehicle = GetVehiclePedIsIn(ped, false)
        isCar = IsCar(vehicle)

        if IsPedInVehicle(ped, vehicle, false) and isCar then
            if SeatbeltON then 
                DisableControlAction(0, 75, true)  -- Disable exit vehicle when stop
                DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
            end
            
            speedBuffer[2] = speedBuffer[1]
            speedBuffer[1] = GetEntitySpeed(vehicle)

            if not SeatbeltON and speedBuffer[2] ~= nil and GetEntitySpeedVector(vehicle, true).y > 1.0 and speedBuffer[1] > 100.0 / 3.6 and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
                local co = GetEntityCoords(ped)
                local fw = Fwv(ped)
                SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
                SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
                Citizen.Wait(1)
                SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
            end
                
            velBuffer[2] = velBuffer[1]
            velBuffer[1] = GetEntityVelocity(vehicle)
                
            if IsControlJustPressed(0, Config.SeatBeltInput) then
                SeatbeltON = not SeatbeltON 
                if SeatbeltON then
                    TriggerEvent("seatbelt:sounds", "buckle", Config.SeatBeltVolume)
                    TriggerEvent('dlrms_notify', 'success','Emniyet kemeri takıldı!')
                else 
                    TriggerEvent("seatbelt:sounds", "unbuckle", Config.SeatBeltVolume)
                    TriggerEvent('dlrms_notify', 'error','Emniyet kemeri çıkartıldı!')
                end
            end
        else
            SeatbeltON = false
            speedBuffer[1], speedBuffer[2] = 0.0, 0.0
            Citizen.Wait(300)
        end
    end
end)
--------- Seatbelt End ---------