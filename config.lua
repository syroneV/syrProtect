Anticheat = Anticheat or {}
Anticheat.License = ""
Anticheat.ServerName = "SyrProtect"
Anticheat.ServerLogo = "https://cdn.discordapp.com/attachments/1075885824257835089/1111325698141995019/inspecteur-gadget-250.png"

Anticheat.lastHealthData = { health = 0, armor = 0 }
Anticheat.ReportsDone = {}
Anticheat.CamerasEdit = {}
Anticheat.AntiCreateCam = CreateCam
Anticheat.AntiCreateCamera = CreateCamera
Anticheat.AntiDestroyCam = DestroyCam
Anticheat.AntiDestroyAllCams = DestroyAllCams

Anticheat.ESX = true -- Si vous utilisez ESX
Anticheat.ESXversion = "legacy" -- legacy or essentialmode or other (use esx:getsharedobject)
Anticheat.Calif = false -- Si vous utilisez une base california



Anticheat.AntiBackdoor = false -- Verif si il y a des backdoor & cypher au start
Anticheat.AnnounceDiscordBackDoorDetect = true -- Fais une annonce discord si il y a un detect
Anticheat.StopServer = true -- Stop le server si il y a un detect

Anticheat.AntiCarkill = false -- Anti carkill
Anticheat.BlockWheelWeapons = false -- Bolquer la roue des armes sur TAB

Anticheat.IsSpawned = false -- Ne pas toucher

Anticheat.BlockTiny = true -- Bloquer les joueurs en petits
Anticheat.AntiGodmod = true -- Bloquer le godmod
Anticheat.AntiHeal = true -- Bloquer le heal
Anticheat.AntiAmmoComplete = true -- Bloquer le Ammo Complete

Anticheat.CanRagdoll = true -- Si le ped ne peut pas ragdoll sa ban

Anticheat.AntiExplosiveBullets = true -- Anti explosive bullet

Anticheat.AntiLicenseClears = true -- Anti License Clear

Anticheat.AntiKeyboardNativeInjections = true -- Anti Injection via Keyboard

Anticheat.AntiCheatEngine = true -- Anti Engine Cheat

Anticheat.AntiPedChange = false -- Anti Ped Change

Anticheat.AntiStopResource = true

Anticheat.MaxResourceNameLength = 68 -- Vos resources max (Si sa vous ban, changer jusqu'a tombé sur le bon)

Anticheat.AntiResourceStartorStop = true -- Anti resource

Anticheat.DeleteExplodedCars = true -- Delete vehicle if engine health == 0

Anticheat.AntiPedAttack = false -- Delete one ped when he attacks you

Anticheat.AntiGiveWeapon = true -- Anti Give weapon

Anticheat.AntiSuicide = true -- Anti Suicide

Anticheat.ModeBase = "a_m_y_skater_01"

Anticheat.AntiCarjack = false -- Bloquer le carjack
Anticheat.NoReloadLife = true -- Bloquer la vie qui remonte
Anticheat.BlockNightVision = true -- Bloquer la vision nocturne
Anticheat.BlockThermalVision = true -- Bloquer la vision thermique
Anticheat.AntiInfiniteAmmo = true -- Bloquer les armes avec munitions infini
Anticheat.AntiSprintMultiplier = true -- Bloquer le sprint multiplier
Anticheat.AntiSwimMultiplier = true -- Bloquer le swim multiplier

Anticheat.ResourceCount = true

Anticheat.PowerVehicle = true


Anticheat.ExplosionProof = false -- Si les joueur peuvent se faire exploser ou non
Anticheat.CollisionProof = true -- Si les joueurs prennent des dégats lors des collision

Anticheat.AntiTrigger = true -- Bloquer les trigger
Anticheat.Superjump = true -- Bloquer le superjump

Anticheat.AntiFreecam = false -- Bloquer les freecam

Anticheat.AntiChatMessage = true -- Bloquer des mots blacklist dans le chat

Anticheat.AntiExplosion = true -- Bloquer des explosion

Anticheat.AntiSpectate = true -- Bloquer le spectate

Anticheat.AntiStamina = true


-- 1.9
Anticheat.AntiRainbowVehicle = true
Anticheat.AntiPlateChanger  = true
Anticheat.AntiTeleport  = false
Anticheat.MaxFootDistance  = 200
Anticheat.MaxVehicleDistance  = 600
Anticheat.AntiPedChanger = true
Anticheat.AntiWeaponDamageChanger = true
Anticheat.AntiVehicleDamageChanger = true
Anticheat.AntiBringAll = true
Anticheat.AntiVPN = true
Anticheat.AntiInvisible = true
Anticheat.AntiChangeSpeed = true
Anticheat.AntiNoClip = true


AnticheatConfig = AnticheatConfig or {}



AnticheatConfig.Webhook = "https://discord.com/api/webhooks/1077657680354758676/tg2wDi4Eqsepd8kE_1w81_O0m_dBQJb8XDh9kIzcl8huuFvRH7mI7UZrAkES5mvZKawb" -- WebHook pour vos logs

AnticheatConfig.Discord = "discord.gg/" -- Discord quand le joueur se connecte et qu'il est ban

AnticheatConfig.UseDiscord = false -- Si votre serveur utilise discord
AnticheatConfig.UseSteam = false -- Si votre serveur utilise steam







Anticheat.ClearPedsAfterDetection = true

Anticheat.GarageList = { -- Place all of the garage coordinates right here.
	{x = 217.89, y = -804.99, z = 30.91},
}

Anticheat.ClearVehiclesAfterDetection = true
Anticheat.ClearObjectsAfterDetection = true

Anticheat.MaxPedsPerUser = 3
Anticheat.MaxPropsPerUser = 10
Anticheat.MaxVehiclesPerUser = 5
Anticheat.MaxEntitiesPerUser = 10
Anticheat.MaxParticlesPerUser = 3

Anticheat.BlacklistedVehicles = true



Anticheat.AntiClearPedTasks = true
Anticheat.AntiProjectile = true
Anticheat.AntiBlacklistedWeapons = true

