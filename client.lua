Citizen.CreateThread(function()
    while true do
        Citizen.Wait(150)
        local ped = PlayerPedId()
        vehicle = GetVehiclePedIsIn(ped, false) 
        InVehicle = IsPedInVehicle(ped, vehicle, false)
        
        if InVehicle then
            speedLimit = Config.SpeedLimit
            fuelLimit = Config.FuelLimit
            signalLights = GetVehicleIndicatorLights(vehicle)
            fuel = GetVehicleFuelLevel(vehicle)
            speed = GetEntitySpeed(vehicle) * 3.6 --3.6 = KM/H , 2.236936 = MPH
            gear = GetVehicleCurrentGear(vehicle)
            engineControl = GetIsVehicleEngineRunning(vehicle)
            
            vehVal, lowBeamsOn, highbeamsOn = GetVehicleLightsState(vehicle)
            if lowBeamsOn == 1 and highbeamsOn == 0 then
                lights = 'normal'
            elseif lowBeamsOn == 1 and highbeamsOn == 1 or lowBeamsOn == 0 and highbeamsOn == 1 then
                lights = 'high'
            else
                lights = 'off'
            end

            SendNUIMessage({
                InVehicle = InVehicle;
                engineControl = engineControl;
                speedLimit = speedLimit;
                fuelLimit = fuelLimit;
                lights = lights,
                signalLights = signalLights;
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

