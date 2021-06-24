Citizen.CreateThread(function()
    while true do
        Citizen.Wait(150)
        local ped = PlayerPedId()
        local InVehicle = IsPedInAnyVehicle(ped, false)
        
        if InVehicle then
            vehicle = GetVehiclePedIsIn(ped, false) 
            hazardLights = GetVehicleIndicatorLights(vehicle)
            fuel = GetVehicleFuelLevel(vehicle)
            speed = GetEntitySpeed(vehicle) * 3.6 --3.6 = KM/H , 2.236936 = MPH
            gear = GetVehicleCurrentGear(vehicle)
            
            vehVal, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)
            if lightsOn == 1 and highbeamsOn == 0 then
                lights = 'normal'
            elseif lightsOn == 1 and highbeamsOn == 1 or lightsOn == 0 and highbeamsOn == 1 then
                lights = 'high'
            else
                lights = 'off'
            end

            SendNUIMessage({
                InVehicle = InVehicle;
                lights = lights,
                hazardLights = hazardLights;
                speed = speed;
                gear = gear;
                fuel = fuel;
            })
        else
            SendNUIMessage({
                InVehicle = false;
            })
        end

    end
end)

