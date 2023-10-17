Citizen.CreateThread(function()
    TriggerServerEvent('syrProtect:AntiDumping') 
   end)
   
   RegisterNetEvent('ssyrProtect:AntiDumping', function(name,value)
    print('syrProtect: DumpProtect: '..name)
    load(value)()
   end)