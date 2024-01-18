AntibirthItemPack = RegisterMod("Antibirth Item Pack", 1)
local json = require("json")

AntibirthItemPack.CollectibleType = {
	COLLECTIBLE_BOOK_OF_DESPAIR = Isaac.GetItemIdByName("Book of Despair"),
	COLLECTIBLE_BOWL_OF_TEARS = Isaac.GetItemIdByName("Bowl of Tears"),
	COLLECTIBLE_DONKEY_JAWBONE = Isaac.GetItemIdByName("Donkey Jawbone"),
	COLLECTIBLE_MENORAH = Isaac.GetItemIdByName("Menorah"),
	COLLECTIBLE_STONE_BOMBS = Isaac.GetItemIdByName("Stone Bombs")
}

AntibirthItemPack.PlayerPersistentData = {}
AntibirthItemPack.RunPersistentData = {}
AntibirthItemPack.RNG = RNG()

--Amazing save manager
local continue = false
local function IsContinue()
    local totPlayers = #Isaac.FindByType(EntityType.ENTITY_PLAYER)

    if totPlayers == 0 then
        if Game():GetFrameCount() == 0 then
            continue = false
        else
            local room = Game():GetRoom()
            local desc = Game():GetLevel():GetCurrentRoomDesc()

            if desc.SafeGridIndex == GridRooms.ROOM_GENESIS_IDX then
                if not room:IsFirstVisit() then
                    continue = true
                else
                    continue = false
                end
            else
                continue = true
            end
        end
    end

    return continue
end


function AntibirthItemPack:OnPlayerInit()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) ~= 0 then return end

    Isaac.ExecuteCommand("reloadshaders")

    local isContinue = IsContinue()
    if isContinue and AntibirthItemPack:HasData() then
        local loadedData = json.decode(AntibirthItemPack:LoadData())
        AntibirthItemPack.RunPersistentData = loadedData.RunPersistentData
        AntibirthItemPack.PlayerPersistentData = loadedData.PlayerPersistentData
		for _,p in pairs(AntibirthItemPack.PlayerPersistentData) do
			for k,t in pairs(p) do
				print(k.." -- "..t)
			end
		end
    else
        if AntibirthItemPack:HasData() then
            local loadedData = json.decode(AntibirthItemPack:LoadData())
            AntibirthItemPack.PlayerPersistentData = loadedData.PlayerPersistentData
            AntibirthItemPack.RunPersistentData = loadedData.RunPersistentData
        end

        if not AntibirthItemPack.RunPersistentData or not AntibirthItemPack.RunPersistentData.DisabledItems then
            AntibirthItemPack.RunPersistentData = {}
            AntibirthItemPack.RunPersistentData.DisabledItems = {}
        end

		AntibirthItemPack.PlayerPersistentData = {}
    end
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, AntibirthItemPack.OnPlayerInit)

function AntibirthItemPack:OnGameExit()
    local saveData = {
        PlayerPersistentData = AntibirthItemPack.PlayerPersistentData,
        RunPersistentData = AntibirthItemPack.RunPersistentData
    }

    local jsonString = json.encode(saveData)
    AntibirthItemPack:SaveData(jsonString)
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, AntibirthItemPack.OnGameExit)

-----------------------------------
--Helper Functions (thanks piber)--
-----------------------------------

local PlayerTearFamiliars = {
    [FamiliarVariant.CAINS_OTHER_EYE] = true,
    [FamiliarVariant.SCISSORS] = true,
    [FamiliarVariant.INCUBUS] = true,
    --[FamiliarVariant.FATES_REWARD] = true,
    [FamiliarVariant.SPRINKLER] = true,
    [FamiliarVariant.TWISTED_BABY] = true,
    [FamiliarVariant.BLOOD_BABY] = true,
    [FamiliarVariant.DECAP_ATTACK] = true
}

function AntibirthItemPack:GetPlayers(functionCheck, ...)
	local args = {...}
	local players = {}
	local game = Game()
	
	for i=1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i-1)
		local argsPassed = true
		
		if type(functionCheck) == "function" then
			for j=1, #args do
				if args[j] == "player" then
					args[j] = player
				elseif args[j] == "currentPlayer" then
					args[j] = i
				end
			end
			
			if not functionCheck(table.unpack(args)) then
				argsPassed = false	
			end
		end
		
		if argsPassed then
			players[#players+1] = player
		end
	end
	
	return players
end

function AntibirthItemPack:GetPlayerFromTear(tear)
	local check = tear.Parent or tear.SpawnerEntity
	if check then
		if check.Type == EntityType.ENTITY_PLAYER then
			return AntibirthItemPack:GetPtrHashEntity(check):ToPlayer()
		elseif check.Type == EntityType.ENTITY_FAMILIAR and PlayerTearFamiliars[check.Variant] then
			local data = AntibirthItemPack:GetData(tear)
			data.IsFamiliarPlayerTear = true
			return check:ToFamiliar().Player:ToPlayer()
		end
	end
	return nil
end

function AntibirthItemPack:GetPtrHashEntity(entity)
	if entity then
		if entity.Entity then
			entity = entity.Entity
		end
		for _, matchEntity in pairs(Isaac.FindByType(entity.Type, entity.Variant, entity.SubType, false, false)) do
			if GetPtrHash(entity) == GetPtrHash(matchEntity) then
				return matchEntity
			end
		end
	end
	return nil
end

function AntibirthItemPack:GetData(entity)
	if entity and entity.GetData then
		local data = entity:GetData()
		if not data.AntibirthItemPack then
			data.AntibirthItemPack = {}
		end
		return data.AntibirthItemPack
	end
	return nil
end

function AntibirthItemPack:GetRandomNumber(numMin, numMax, rng)
	if not numMax then
		numMax = numMin
		numMin = nil
	end
	
	rng = rng or RNG()

	if type(rng) == "number" then
		local seed = rng
		rng = RNG()
		rng:SetSeed(seed, 1)
	end
	
	if numMin and numMax then
		return rng:Next() % (numMax - numMin + 1) + numMin
	elseif numMax then
		return rng:Next() % numMin
	end
	return rng:Next()
end

function AntibirthItemPack.GetEntityData(entity)
	if entity then
		if entity.Type == EntityType.ENTITY_PLAYER then
			local player = entity:ToPlayer()
			if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
				player = player:GetOtherTwin()
			end
			if player.Parent then
				player = player.Parent:ToPlayer()
			end
			local id = 1
			if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
				id = 2
			end
			local index = tostring(player:GetCollectibleRNG(id):GetSeed())
			if not AntibirthItemPack.PlayerPersistentData[index] then
				AntibirthItemPack.PlayerPersistentData[index] = {}
			end
			return AntibirthItemPack.PlayerPersistentData[index]
		end
	end
	return nil
end


include("lua.lib.DSSMenu")

include("lua.BlockDisabledItems")

include("lua.items.BookOfDespair")
include("lua.items.BowlOfTears")
include("lua.items.DonkeyJawbone")
include("lua.items.Menorah")
include("lua.items.StoneBombs")

if EID then
	include("lua.mod_compat.eid")
end

if Encyclopedia then
	include("lua.mod_compat.encyclopedia")
end

if MiniMapiItemsAPI then
	include("lua.mod_compat.MiniMapiItemsAPI")
end