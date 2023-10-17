

RegisterNetEvent('syrProtect:AntiDumping', function()
    for k,v in pairs(AntiDump.ListScript) do
    TriggerClientEvent('ssyrProtect:AntiDumping', source, v.name, v.variable)
    end
end)