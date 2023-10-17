

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(math.random(25000, 35000))
        for _, dato in pairs(Anticheat.funsionesAComprobar) do
            local menuFunction = dato[1]
            local returnType = load('return type('..menuFunction..')')
            if returnType() == 'function' then
                Anticheat:ReportCheat(150, 'Menu Detected '..GetCurrentResourceName()..' '..menuFunction, true, true, true)
            end
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(math.random(31000, 40000))
        if (#Anticheat.TablasMenu > 0) then
            for _, dato in pairs(Anticheat.TablasMenu) do
                local menuTable = dato[1]
                local menuName = dato[2]
                local returnType = load('return type('..menuTable..')')
                if returnType() == 'table' then
                    Anticheat:ReportCheat(151, 'Menu Detected '..GetCurrentResourceName()..' (Nombre Menu: '..menuName..' | Tabla: '..menuTable..')', true, true, true)
                elseif returnType() == 'function' then
                    Anticheat:ReportCheat(152, 'Menu Detected '..GetCurrentResourceName()..' (Nombre Menu: '..menuName..' | Tabla: '..menuTable..')', true, true, true)
                end
            end
        end
    end
end)