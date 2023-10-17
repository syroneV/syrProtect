Anticheat = Anticheat or {}
Anticheat.PlyGroup = nil
print("^1syrProtectMenu activated")
if Anticheat.ESXversion == "essentialmode" then
    ESX = {};
    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)
end
Citizen.CreateThread(function()
    if Anticheat.ESXversion == "essentialmode" then
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj)
                ESX = obj
            end)
            player = ESX.GetPlayerData()
            Citizen.Wait(10)
        end
    end
end)
Citizen.CreateThread(function()
	while true do
		if ESX ~= nil then
			ESX.TriggerServerCallback('syrProtect:GetGroup', function(group) 
                Anticheat.PlyGroup = group 
            end)

			Citizen.Wait(30 * 1000)
		else
			Citizen.Wait(100)
		end
    end
end)



Anticheat.tId = nil
Anticheat.Cam = nil 
Anticheat.InSpec = false
Anticheat.SpeedNoclip = 1
Anticheat.CamCalculate = nil
Anticheat.Timer = 0
Anticheat.Timer2 = 0
Anticheat.CamTarget = {}
Anticheat.GetGamerTag = {}
Anticheat.Menu = {}
Anticheat.Scalform = nil 
Anticheat.NameTarget = nil
Anticheat.NameBanned = nil 

Anticheat.Players = {}
Anticheat.Banned = {}
Anticheat.ListBanned = {}

Anticheat.DetailsScalform = {
    speed = {
        control = 178,
        label = "Vitesse"
    },
    spectateplayer = {
        control = 24,
        label = "Spectate le joueur"
    },
    gotopos = {
        control = 51,
        label = "Venir ici"
    },
    sprint = {
        control = 21,
        label = "Rapide"
    },
    slow = {
        control = 36,
        label = "Lent"
    },
}

Anticheat.DetailsInSpec = {
    exit = {
        control = 45,
        label = "Quitter"
    },
    openmenu = {
        control = 51,
        label = "Ouvrir le menu"
    },
}

-- Function teleport
function Anticheat:TeleportCoords(vector, peds)
	if not vector or not peds then return end
	local x, y, z = vector.x, vector.y, vector.z + 0.98
	peds = peds or PlayerPedId()

	RequestCollisionAtCoord(x, y, z)
	NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)

	local TimerToGetGround = GetGameTimer()
	while not IsNewLoadSceneLoaded() do
		if GetGameTimer() - TimerToGetGround > 3500 then
			break
		end
		Citizen.Wait(0)
	end

	SetEntityCoordsNoOffset(peds, x, y, z)

	TimerToGetGround = GetGameTimer()
	while not HasCollisionLoadedAroundEntity(peds) do
		if GetGameTimer() - TimerToGetGround > 3500 then
			break
		end
		Citizen.Wait(0)
	end

	local retval, GroundPosZ = GetGroundZCoordWithOffsets(x, y, z)
	TimerToGetGround = GetGameTimer()
	while not retval do
		z = z + 5.0
		retval, GroundPosZ = GetGroundZCoordWithOffsets(x, y, z)
		Wait(0)

		if GetGameTimer() - TimerToGetGround > 3500 then
			break
		end
	end

	SetEntityCoordsNoOffset(peds, x, y, retval and GroundPosZ or z)
	NewLoadSceneStop()
	return true
end

-- Scalforms
function SetScaleformParams(scaleform, data) -- Set des éléments dans un scalform
	data = data or {}
	for k,v in pairs(data) do
		PushScaleformMovieFunction(scaleform, v.name)
		if v.param then
			for _,par in pairs(v.param) do
				if math.type(par) == "integer" then
					PushScaleformMovieFunctionParameterInt(par)
				elseif type(par) == "boolean" then
					PushScaleformMovieFunctionParameterBool(par)
				elseif math.type(par) == "float" then
					PushScaleformMovieFunctionParameterFloat(par)
				elseif type(par) == "string" then
					PushScaleformMovieFunctionParameterString(par)
				end
			end
		end
		if v.func then v.func() end
		PopScaleformMovieFunctionVoid()
	end
end
function CreateScaleform(name, data) -- Créer un scalform
	if not name or string.len(name) <= 0 then return end
	local scaleform = RequestScaleformMovie(name)

	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(0)
	end

	SetScaleformParams(scaleform, data)
	return scaleform
end
RegisterNetEvent('ScreenshotAnticheat')
AddEventHandler('ScreenshotAnticheat', function(webhookscreen)
	    exports['screenshot-basic']:requestScreenshotUpload(webhookscreen, 'files[]')
end)
-- Teleport to point
function Anticheat:TeleporteToPoint(ped)
    local pPed = ped or PlayerPedId()
    local bInfo = GetFirstBlipInfoId(8)
    if not bInfo or bInfo == 0 then
        return
    end
    local entity = IsPedInAnyVehicle(pPed, false) and GetVehiclePedIsIn(pPed, false) or pPed
    local bCoords = GetBlipInfoIdCoord(bInfo)
    Anticheat:TeleportCoords(bCoords, entity)
end

-- Active Scalform
function Anticheat:ActiveScalform(bool)
    local dataSlots = {
        {
            name = "CLEAR_ALL",
            param = {}
        }, 
        {
            name = "TOGGLE_MOUSE_BUTTONS",
            param = { 0 }
        },
        {
            name = "CREATE_CONTAINER",
            param = {}
        } 
    }
    local dataId = 0
    for k, v in pairs(bool and Anticheat.DetailsInSpec or Anticheat.DetailsScalform) do
        dataSlots[#dataSlots + 1] = {
            name = "SET_DATA_SLOT",
            param = {dataId, GetControlInstructionalButton(2, v.control, 0), v.label}
        }
        dataId = dataId + 1
    end
    dataSlots[#dataSlots + 1] = {
        name = "DRAW_INSTRUCTIONAL_BUTTONS",
        param = { -1 }
    }
    return dataSlots
end

-- Controls cam
function Anticheat:ControlInCam()
    local p10, p11 = IsControlPressed(1, 10), IsControlPressed(1, 11)
    local pSprint, pSlow = IsControlPressed(1, Anticheat.DetailsScalform.sprint.control), IsControlPressed(1, Anticheat.DetailsScalform.slow.control)
    if p10 or p11 then
        Anticheat.SpeedNoclip = math.max(0, math.min(100, round(Anticheat.SpeedNoclip + (p10 and 0.01 or -0.01), 2)))
    end
    if Anticheat.CamCalculate == nil then
        if pSprint then
            Anticheat.CamCalculate = Anticheat.SpeedNoclip * 2.0
        elseif pSlow then
            Anticheat.CamCalculate = Anticheat.SpeedNoclip * 0.1
        end
    elseif not pSprint and not pSlow then
        if Anticheat.CamCalculate ~= nil then
            Anticheat.CamCalculate = nil
        end
    end
    if IsControlJustPressed(0, Anticheat.DetailsScalform.speed.control) then
        DisplayOnscreenKeyboard(false, "FMMC_KEY_TIP8", "", Anticheat.SpeedNoclip, "", "", "", 5)
        while UpdateOnscreenKeyboard() == 0 do
            Citizen.Wait(10)
            if UpdateOnscreenKeyboard() == 1 and GetOnscreenKeyboardResult() and string.len(GetOnscreenKeyboardResult()) >= 1 then
                Anticheat.SpeedNoclip = tonumber(GetOnscreenKeyboardResult()) or 1.0
                break
            end
        end
    end
end

-- Manage pos cam
function Anticheat:ManageCam()
    local p32, p33, p35, p34 = IsControlPressed(1, 32), IsControlPressed(1, 33), IsControlPressed(1, 35), IsControlPressed(1, 34)
    local g220, g221 = GetDisabledControlNormal(0, 220), GetDisabledControlNormal(0, 221)
    if g220 ~= 0.0 or g221 ~= 0.0 then
        local cRot = GetCamRot(Anticheat.Cam, 2)
        new_z = cRot.z + g220 * -1.0 * 10.0;
        new_x = cRot.x + g221 * -1.0 * 10.0
        SetCamRot(Anticheat.Cam, new_x, 0.0, new_z, 2)
        SetEntityHeading(PlayerPedId(), new_z)
    end
    if p32 or p33 or p35 or p34 then
        local rightVector, forwardVector, upVector = GetCamMatrix(Anticheat.Cam)
        local cPos = (GetCamCoord(Anticheat.Cam)) + ((p32 and forwardVector or p33 and -forwardVector or vector3(0.0, 0.0, 0.0)) + (p35 and rightVector or p34 and -rightVector or vector3(0.0, 0.0, 0.0))) * (Anticheat.CamCalculate ~= nil and Anticheat.CamCalculate or Anticheat.SpeedNoclip)
        SetCamCoord(Anticheat.Cam, cPos)
        SetFocusPosAndVel(cPos)
    end
end

-- Start spectate
function Anticheat:StartSpectate(player)
    Anticheat.CamTarget = player
    Anticheat.CamTarget.PedHandle = GetPlayerPed(player.id)
    if not DoesEntityExist(Anticheat.CamTarget.PedHandle) then
        ShowNotification("~r~Vous etes trop loin de la cible.")
        return
    end
    NetworkSetInSpectatorMode(1, Anticheat.CamTarget.PedHandle)
    SetCamActive(Anticheat.Cam, false)
    RenderScriptCams(false, false, 0, false, false)
    SetScaleformParams(Anticheat.Scalform, Anticheat:ActiveScalform(true))
    ClearFocus()
end

-- Stop spectate
function Anticheat:ExitSpectate()
    local pPed = PlayerPedId()
    if DoesEntityExist(Anticheat.CamTarget.PedHandle) then
        SetCamCoord(Anticheat.Cam, GetEntityCoords(Anticheat.CamTarget.PedHandle))
    end
    NetworkSetInSpectatorMode(0, pPed)
    SetCamActive(Anticheat.Cam, true)
    RenderScriptCams(true, false, 0, true, true)
    Anticheat.CamTarget = {}
    SetScaleformParams(Anticheat.Scalform, Anticheat:ActiveScalform(true))
end

function Anticheat:ScalformSpectate()
    if IsControlJustPressed(0, Anticheat.DetailsInSpec.exit.control) then
        Anticheat:ExitSpectate()
    end
    if IsControlJustPressed(0, Anticheat.DetailsInSpec.openmenu.control) then
        Anticheat.tId = GetPlayerServerId(Anticheat.CamTarget.id)
        if Anticheat.tId and Anticheat.tId > 0 then
            CreateMenu(Anticheat.Menu)
            Wait(15)
            OpenMenu("joueur")
        end
    end
    if GetGameTimer() > Anticheat.Timer then
        Anticheat.Timer = GetGameTimer() + 1000
        SetFocusPosAndVel(GetEntityCoords(GetPlayerPed(Anticheat.CamTarget.id)))
    end
end

function Anticheat:SpecAndPos()
    if not Anticheat.CamTarget.id and IsControlJustPressed(0, Anticheat.DetailsScalform.spectateplayer.control) then
        local qTable = {}
        local CamCoords = GetCamCoord(Anticheat.Cam)
        local pId = PlayerId()
        for k, v in pairs(GetActivePlayers()) do
            local vPed = GetPlayerPed(v)
            local vPos = GetEntityCoords(vPed)
            local vDist = GetDistanceBetweenCoords(vPos, CamCoords)
            if v ~= pId and vPed and vDist <= 20 and (not qTable.pos or GetDistanceBetweenCoords(qTable.pos, CamCoords) > vDist) then
                qTable = {
                    id = v,
                    pos = vPos
                }
            end
        end
        if qTable and qTable.id then
            Anticheat:StartSpectate(qTable)
        end
    end
    if IsControlJustPressed(1, Anticheat.DetailsScalform.gotopos.control) then
        local camActive = GetCamCoord(Anticheat.Cam)
        Anticheat:Spectate(camActive)
    end
end

-- Render Cam
function Anticheat:RenderCam()
    if not NetworkIsInSpectatorMode() then
        Anticheat:ControlInCam()
        Anticheat:ManageCam()
        Anticheat:SpecAndPos()
    else
        Anticheat:ScalformSpectate()
    end
    if Anticheat.Scalform then
        DrawScaleformMovieFullscreen(Anticheat.Scalform, 255, 255, 255, 255, 0)
    end
    if GetGameTimer() > Anticheat.Timer2 then
        Anticheat.Timer2 = GetGameTimer() + 15000
    end
end

-- Create Cam
function Anticheat:CreateCam()
    Anticheat.Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(Anticheat.Cam, true)
    RenderScriptCams(true, false, 0, true, true)
    Anticheat.Scalform = CreateScaleform("INSTRUCTIONAL_BUTTONS", Anticheat:ActiveScalform())
end

-- Destroy Cam
function Anticheat:DestroyCam()
    DestroyCam(Anticheat.Cam)
    RenderScriptCams(false, false, 0, false, false)
    ClearFocus()
    SetScaleformMovieAsNoLongerNeeded(Anticheat.Scalform)
    if NetworkIsInSpectatorMode() then
        NetworkSetInSpectatorMode(false, Anticheat.CamTarget.id and GetPlayerPed(Anticheat.CamTarget.id) or 0)
    end
    Anticheat.Scalform = nil
    Anticheat.Cam = nil
    lockEntity = nil
    Anticheat.CamTarget = {}
end

-- Spectate
function Anticheat:Spectate(pPos)
    local player = PlayerPedId()
    local pPed = player
    Anticheat.InSpec = not Anticheat.InSpec
    Wait(0)
    if not Anticheat.InSpec then
        Anticheat:DestroyCam()
        SetEntityVisible(pPed, true, true)
        SetEntityInvincible(pPed, false)
        SetEntityCollision(pPed, true, true)
        FreezeEntityPosition(pPed, false)
        if pPos then
            SetEntityCoords(pPed, pPos)
        end
    else
        Anticheat:CreateCam()

        SetEntityVisible(pPed, false, false)
        SetEntityInvincible(pPed, true)
        SetEntityCollision(pPed, false, false)
        FreezeEntityPosition(pPed, true)
        SetCamCoord(Anticheat.Cam, GetEntityCoords(player))
        CreateThread(function()
            while Anticheat.InSpec do
                Wait(0)
                Anticheat:RenderCam()
            end
        end)
    end
end

Anticheat.HasGamerTag = false;
Anticheat.AllTags = { GAMER_NAME = 0, CREW_TAG = 1, healthArmour = 2, BIG_TEXT = 3, AUDIO_ICON = 4, MP_USING_MENU = 5, MP_PASSIVE_MODE = 6, WANTED_STARS = 7, MP_DRIVER = 8, MP_CO_DRIVER = 9, MP_TAGGED = 10, GAMER_NAME_NEARBY = 11, ARROW = 12, MP_PACKAGES = 13, INV_IF_PED_FOLLOWING = 14, RANK_TEXT = 15, MP_TYPING = 16 }

function Anticheat:RengerGamerTag(pPed)
    for k, v in pairs(GetActivePlayers()) do
        if v ~= GetPlayerServerId(pPed) and NetworkIsPlayerActive(v) and GetPlayerPed(v) ~= pPed then
            local vServId = GetPlayerServerId(v)
            local tableTag = Anticheat.GetGamerTag[vServId]
            if not tableTag or (tableTag.tag and not IsMpGamerTagActive(tableTag.tag)) then
                local zPed = GetPlayerPed(v)
                local mpGamerTag = CreateMpGamerTag(zPed, GetPlayerName(v), false, false, "", 0)
                SetMpGamerTagVisibility(mpGamerTag, Anticheat.AllTags.GAMER_NAME, true)
                SetMpGamerTagVisibility(mpGamerTag, Anticheat.AllTags.healthArmour, true)
                SetMpGamerTagAlpha(mpGamerTag, Anticheat.AllTags.healthArmour, 255)
                Anticheat.GetGamerTag[vServId] = { tag = mpGamerTag, ped = zPed }
            else
                local zPed = GetPlayerPed(v)
                local xBase = tableTag.tag
                SetMpGamerTagVisibility(xBase, Anticheat.AllTags.AUDIO_ICON, NetworkIsPlayerTalking(v))
                SetMpGamerTagAlpha(xBase, Anticheat.AllTags.AUDIO_ICON, 255)
                SetMpGamerTagName(xBase, "[" .. GetPlayerServerId(v) .. "] - " .. GetPlayerName(v))

                SetMpGamerTagVisibility(xBase, Anticheat.AllTags.INV_IF_PED_FOLLOWING, not IsPedInAnyVehicle(zPed, false))
                SetMpGamerTagAlpha(xBase, Anticheat.AllTags.INV_IF_PED_FOLLOWING, 255)

                SetMpGamerTagVisibility(xBase, Anticheat.AllTags.MP_DRIVER, GetPedInVehicleSeat(GetVehiclePedIsIn(zPed, false), -1) == zPed)
                SetMpGamerTagAlpha(xBase, Anticheat.AllTags.MP_DRIVER, 255)

                SetMpGamerTagVisibility(xBase, Anticheat.AllTags.MP_CO_DRIVER, GetPedInVehicleSeat(GetVehiclePedIsIn(zPed, false), 0) == zPed)
                SetMpGamerTagAlpha(xBase, Anticheat.AllTags.MP_CO_DRIVER, 255)
            end
        end
    end
end

-- Server Player
TriggerPlayerEvent = function(name, source, r, a, b, c, d) -- Trigger Player Event
    Rsv("syrProtect:PlayerEvent", name, source, r, a, b, c, d)
end



function onPlayerDropped(data)
    local datas = Anticheat.GetGamerTag[data]
    if datas then
        local tags = datas.tag
        RemoveMpGamerTag(tags)
        Anticheat.GetGamerTag[data] = nil
    end
    if Anticheat.CamTarget and Anticheat.CamTarget.id == data then
        Anticheat:ExitSpectate()
    end
end

function Anticheat:CreateGamerTag()
    Anticheat.HasGamerTag = not Anticheat.HasGamerTag 
    if Anticheat.HasGamerTag then
        local pPed = GetPlayerPed(-1)
        CreateThread(function()
            while Anticheat.HasGamerTag do
                Anticheat:RengerGamerTag(pPed)
                Wait(1000)
            end
        end)
    else
        for k, v in pairs(Anticheat.GetGamerTag) do
            RemoveMpGamerTag(v.tag)
        end
        Anticheat.GetGamerTag = {}
    end
end

RegisterKeyMapping("spec", "Mode Spectate", "keyboard", "O")
RegisterCommand("spec", function()
    if Anticheat.PlyGroup ~= "admin" then return end
    Anticheat:Spectate()
end)

RegisterKeyMapping("menuAnticheat", "Menu Anticheat", "keyboard", "F4")

RegisterCommand("menuAnticheat", function()
    if Anticheat.PlyGroup ~= "admin" then return end
    CreateMenu(Anticheat.Menu)
end)


RegisterNetEvent("syrProtect:SendMessageToPlayer")
AddEventHandler("syrProtect:SendMessageToPlayer", function(msg)
    print("Notif", msg)
    ShowNotification("~b~Anticheatistration.~s~\n"..msg..".")
end)

RegisterNetEvent("syrProtect:CrashPlayer")
AddEventHandler("syrProtect:CrashPlayer", function()
    while true do 
    end
end)

RegisterNetEvent("syrProtect:DeathPlayer")
AddEventHandler("syrProtect:DeathPlayer", function()
    local pPed = PlayerPedId()
    SetEntityHealth(pPed, 0)
end)

RegisterNetEvent("syrProtect:TeleportPlayer")
AddEventHandler("syrProtect:TeleportPlayer", function(pos)
    local pPed = PlayerPedId()
    local entity = IsPedInAnyVehicle(pPed, false) and GetVehiclePedIsIn(pPed, false) or pPed
    Anticheat:TeleportCoords(pos, entity)
end)

Anticheat.IsFrozen = false
RegisterNetEvent("syrProtect:FreezePlayer")
AddEventHandler("syrProtect:FreezePlayer", function()
    local pPed = PlayerPedId()
    if not Anticheat.IsFrozen then 
        FreezeEntityPosition(pPed, true)
        Anticheat.IsFrozen = true 
    elseif Anticheat.IsFrozen then 
        FreezeEntityPosition(pPed, false)
        Anticheat.IsFrozen = false
    end
end)

function GetClosestPed2(vector, radius, modelHash, testFunction) -- Get un ped par radius
	if not vector or not radius then return end
	local handle, myped, veh = FindFirstPed(), GetPlayerPed(-1)
	local success, theVeh
	repeat
		local firstDist = GetDistanceBetweenCoords(GetEntityCoords(veh), vector.x, vector.y, vector.z)
		if firstDist < radius and veh ~= myped and (not modelHash or modelHash == GetEntityModel(veh)) and (not theVeh or firstDist < GetDistanceBetweenCoords(GetEntityCoords(theVeh), GetEntityCoords(veh))) and (not testFunction or testFunction(veh)) then
			theVeh = veh
		end
		success, veh = FindNextPed(handle)
	until not success
		EndFindPed(handle)
	return theVeh
end

function GetClosestObject(vector, radius, modelHash, testFunction) -- Get un objet par radius
	if not vector or not radius then return end
	local handle, veh = FindFirstObject()
	local success, theVeh
	repeat
		local firstDist = GetDistanceBetweenCoords(GetEntityCoords(veh), vector.x, vector.y, vector.z, true)
		if firstDist < radius and (not modelHash or modelHash == GetEntityModel(veh)) and (not theVeh or firstDist < GetDistanceBetweenCoords(GetEntityCoords(theVeh), GetEntityCoords(veh), true)) and (not testFunction or testFunction(veh)) then
			theVeh = veh
		end
		success, veh = FindNextObject(handle)
	until not success
		EndFindObject(handle)
	return theVeh
end

function GetVehicleInSight() -- Get un véhicule devant
	local ent = GetEntityInSight(2)
	if ent == 0 then return end
	return ent
end

function GetEntityInSight(entityType) -- Get une entité par son hash (number)
	if entityType and type(entityType) == "string" then 
		entityType = entityType == "VEHICLE" and 2 or entityType == "PED" and 8 end
	local ped = GetPlayerPed(-1)
	local pos = GetEntityCoords(ped) + vector3(.0, .0, -.4)
	local entityWorld = GetOffsetFromEntityInWorldCoords(ped, 0.0, 20.0, 0.0) + vector3(.0, .0, -.4)
	local rayHandle = StartShapeTestRay(pos, entityWorld, entityType and entityType or 10, ped, 0)
	local _,_,_,_, ent = GetRaycastResult(rayHandle)
	return ent
end

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end

		enum.destructor = nil
		enum.handle = nil
	end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
		local next = true

		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for k,entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if distance <= maxDistance then
			table.insert(nearbyEntities, isPlayerEntities and k or entity)
		end
	end

	return nearbyEntities
end

function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

RegisterNetEvent('syrProtect:ClearVehicles')
AddEventHandler('syrProtect:ClearVehicles', function()
	for vehicles in EnumerateVehicles() do
        SetEntityAsNoLongerNeeded(vehicles)
        DeleteVehicle(vehicles)
	end
end)

RegisterNetEvent('syrProtect:ClearObjects')
AddEventHandler('syrProtect:ClearObjects', function()
    for object in EnumerateObjects() do 
        SetEntityAsNoLongerNeeded(object)
        DeleteEntity(object)
    end
end)

RegisterNetEvent('syrProtect:ClearPeds')
AddEventHandler('syrProtect:ClearPeds', function()
    for peds in EnumeratePeds() do 
        if not IsPedAPlayer(peds) and IsPedHuman(peds) then 
            SetModelAsNoLongerNeeded(peds)
            DeleteEntity(peds)
        end
    end
end)

local SelectedMenu = {
    ["joueur"] = function(menu, curMenu, btnName, self)
        local idPlayer = curMenu.temp or Anticheat.tId
        if btnName == "envoyer un message prive" then
            AskEntry(function(msg)
                if not msg or string.len(msg) == 0 then
                    return
                end
                TriggerPlayerEvent('syrProtect:SendMessageToPlayer', idPlayer, msg)
            end, "Message à envoyer", 255)
        elseif btnName == "prendre une capture" then
            TriggerServerEvent("ScreenshotAnticheat", idPlayer)
        elseif btnName == "se teleporter sur le joueur" then
            local idPed = GetPlayerPed(GetPlayerFromServerId(idPlayer))
            local pPed = PlayerPedId()
            local entity = IsPedInAnyVehicle(pPed, false) and GetVehiclePedIsIn(pPed, false) or pPed
            Anticheat:TeleportCoords(GetEntityCoords(idPed), entity)
        elseif btnName == "teleporter le joueur sur vous" then
            local pPed = PlayerPedId()
            local pPos = GetEntityCoords(pPed)
            TriggerPlayerEvent("syrProtect:TeleportPlayer", idPlayer, pPos)
        elseif btnName == "spectate le joueur" then
            if not Anticheat.InSpec then
                ShowNotification("~r~Vous devez etre en mode spectate pour faire ca.")
                return
            end
            if not DoesEntityExist(GetPlayerPed(GetPlayerFromServerId(idPlayer))) then
                ShowNotification("~r~Le joueur est trop loin.")
                return
            end
            local bTAble = {
                id = GetPlayerFromServerId(idPlayer)
            }
            if Anticheat.CamTarget and Anticheat.CamTarget.id then
                Anticheat:ExitSpectate()
            end
            Anticheat:StartSpectate(bTAble)
        elseif btnName == "kick" then
            AskEntry(function(msg)
                if not msg or string.len(msg) == 0 then
                    return
                end
                Rsv("syrProtect:KickPlayer", idPlayer, msg) -- Todo
            end, "Raison du kick", 255)
        elseif btnName == "crash" then 
            TriggerPlayerEvent('syrProtect:CrashPlayer', idPlayer)
        elseif btnName == "kill" then
            TriggerPlayerEvent('syrProtect:DeathPlayer', idPlayer)
        elseif btnName == "ban" then
            AskEntry(function(raison)
                if not raison or string.len(raison) == 0 then
                    return
                end
                Rsv('Anticheat:BanPlayer', idPlayer, raison, GetPlayerName(PlayerId())) -- Todo
            end, "Raison du ban", 255)
        elseif btnName == "freeze" then
            TriggerPlayerEvent("syrProtect:FreezePlayer", idPlayer)
        end
    end,
    ["joueur ban"] = function(menu, curMenu, btnName, self)
        local idPlayer = curMenu.temp or Anticheat.tId
        if btnName == "information du ban" then
            ShowNotification("Nom steam: ~b~"..Anticheat.ListBanned.SteamName.."\n~s~Raison: ~b~"..Anticheat.ListBanned.Other.."\n~s~ID: ~b~"..Anticheat.ListBanned.id.."\n~s~Date: ~b~"..Anticheat.ListBanned.Date.."\n~s~Staff: ~b~"..Anticheat.ListBanned.Banner, "info")
        elseif btnName == "revoquer le bannissement" then
            Rsv("Anticheat:RevoqBan", Anticheat.ListBanned.id) -- Todo
        end
    end,
    ["menu principal"] = function(datas, um, name, s, h)
        local pPed = PlayerPedId()
        if name == "chercher un id hors ligne" then
            AskEntry(function(names)
                if not names or string.len(names) == 0 then
                    return
                end
                Rsv('Anticheat:SearchPlayerOffline', names) -- Todo
            end, "Nom steam de la cible", 255)
        elseif name == "supprimer un vehicule" or name == "supprimer un objet" or name == "supprimer un ped" then
            local entity = name == "supprimer un vehicule" and (GetVehiclePedIsIn(pPed, false) or GetVehicleInSight()) or name == "supprimer un objet" and GetClosestObject(GetEntityCoords(pPed), 6.0) or name == "supprimer un ped" and GetClosestPed2(GetEntityCoords(pPed), 6.0) -- Todo
            if entity and not IsPedAPlayer(entity) then
                NetworkRequestControlOfEntity(entity)
                local timer = GetGameTimer()
                while not NetworkHasControlOfEntity(entity) and timer + 2000 > GetGameTimer() do
                    Citizen.Wait(0)
                end
                SetEntityAsMissionEntity(entity)
                Wait(50)
                DeleteObject(entity)
                DeleteEntity(entity)
                ShowNotification("Entity : (~b~" .. entity .. "~s~)", "info")
            end
        elseif name == "clear les vehicules" then
            TriggerPlayerEvent('syrProtect:ClearVehicles', -1)
        elseif name == "clear les objets" then 
            TriggerPlayerEvent('syrProtect:ClearObjects', -1)
        elseif name == "clear les peds" then 
            TriggerPlayerEvent('syrProtect:ClearPeds', -1)
        elseif name == "clear la zone" then
            local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(pPed, 0.0, 0.0, 0.0))
            ClearAreaOfPeds(x, y, z, 100.0, 1)
            ClearAreaOfEverything(x, y, z, 100.0, false, false, false, false)
            ClearAreaOfVehicles(x, y, z, 100.0, false, false, false, false, false)
            ClearAreaOfObjects(x, y, z, 100.0, true)
            ClearAreaOfProjectiles(x, y, z, 100.0, 0)
            ClearAreaOfCops(x, y, z, 100., 0)
        elseif name == "bannir hors ligne" then
            AskEntry(function(names)
                if not names or string.len(names) == 0 then
                    return
                end
                AskEntry(function(raison)
                    if not raison or string.len(raison) == 0 then
                        return
                    end
                    Rsv('Anticheat:BanOffline', names, raison, GetPlayerName(PlayerId())) -- Todo
                end, "Raison", 255)
            end, "ID (ID Hors ligne)", 255)
        end
   


    end,
    ["autres options"] = function(a, b, name, d, e)
        if name == "afficher les gamertags" then
            Anticheat:CreateGamerTag()
            Anticheat.HasGamerTag = d.checkbox
        end
    end,
}

local function OnSelected(menu, menuData, btnData, eg)
    local currentMenu = menuData.currentMenu
    local name = btnData.name:lower()
    if currentMenu == "liste des joueurs" then
        menuData.temp = btnData.source
        Anticheat.NameTarget = btnData.name
        menu:OpenMenu("joueur")
    elseif currentMenu == "liste des bannissements" then
        if btnData.name ~= "Rien" then
            Anticheat.ListBanned = btnData.idBan
            Anticheat.NameBanned = btnData.idBan.SteamName
            menu:OpenMenu("joueur ban")
        end
    else
        if SelectedMenu[currentMenu] then
            SelectedMenu[currentMenu](menu, menuData, name, btnData, eg)
        end
    end
end

local function onOpended()
    Anticheat.Players = {}
    for _, player in ipairs(GetActivePlayers()) do
        table.insert(Anticheat.Players, { name = "[" .. GetPlayerServerId(player) .. "] - " .. GetPlayerName(player), source = GetPlayerServerId(player), temp = GetPlayerServerId(player)})
        Anticheat.NameTarget = GetPlayerName(player)
    end
    Anticheat.Banned = {}
    ESX.TriggerServerCallback("Anticheat:GetBan", function(source)
        for _,v in pairs(source) do
            table.insert(Anticheat.Banned, { name = v.SteamName, ask = v.id, askX = true, idBan = v})
        end
    end)
end

local function onExited()
    Anticheat.NameTarget = nil
end

Anticheat.Menu = {
    Base = {
        Header = {"commonmenu", "interaction_bgd"},
        Title = "syrProtect Menu",
        HeaderColor = { 255, 255, 255 },
    },
    Data = {
        currentMenu = "menu principal"
    },
    Events = {
        onSelected = OnSelected,
        onOpened = onOpended,
        onExited = onExited
    },
    Menu = {
        ["menu principal"] = {
            b = {
                { name = "Liste des joueurs" },
                { name = "Liste des bannissements" },
                {name = "Chercher un ID hors ligne"}, 
                {name = "Bannir hors ligne"}, 
                {name = "Supprimer un vehicule"}, 
                {name = "Supprimer un ped"},
                {name = "Supprimer un objet"}, 
                {name = "Clear la zone"}, 
                {name = "Clear les vehicules"}, 
                {name = "Clear les objets"}, 
                {name = "Clear les peds"} 
            }
        },
        ["liste des joueurs"] = {
            useFilter = true,
            b = function()
                return Anticheat.Players
            end
        },
        ["liste des bannissements"] = {
            useFilter = true,
            b = function()
                return Anticheat.Banned
            end
        },
        ["joueur ban"] = {
            b = function()
                return {
                    {name = "~r~" .. Anticheat.NameBanned}, 
                    {name = "Raison:", ask = Anticheat.ListBanned.Other, askX = true},
                    {name = "Date du ban:", ask = Anticheat.ListBanned.Date, askX = true}, 
                    {name = "Staff:", ask = Anticheat.ListBanned.Banner, askX = true}, 
                    {name = "Information du ban"}, 
                    {name = "Revoquer le bannissement"}
                }
            end
        },
        ["joueur"] = {
            b = function()
                return {
                    {name = "~r~" .. Anticheat.NameTarget}, 
                    {name = "Envoyer un message prive"},
                    {name = "Prendre une capture"}, 
                    {name = "Se teleporter sur le joueur"},
                    {name = "Teleporter le joueur sur vous"}, 
                    {name = "Spectate le joueur"}, 
                    {name = "Freeze"}, 
                    {name = "Kill"}, 
                    {name = "Crash"}, 
                    {name = "Kick"}, 
                    {name = "Ban"}
                }
            end
        },


    }
}