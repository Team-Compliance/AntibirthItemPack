local BookOfDespair = {}

function BookOfDespair:UseBookOfDespair(_Type, RNG, player, flags, slot, data)
	if flags & UseFlag.USE_CARBATTERY == 0 then
		local tempEffects = player:GetEffects():GetCollectibleEffectNum(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR)
		if tempEffects == 0 then
			if REPENTOGON then
				ItemOverlay.Show(Isaac.GetGiantBookIdByName("Book of Despair"), 0 , player)
			elseif GiantBookAPI then
				GiantBookAPI.playGiantBook("Appear", "Despair.png", Color(228/255, 228/255, 228/255, 1, 0, 0, 0), Color(228/255, 228/255, 228/255, 153/255, 0, 0, 0), Color(225/255, 225/255, 225/255, 128/255, 0, 0, 0))
			end
		end
		SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 0.8, 0, false, 1)
	end
	
	return true
end

function BookOfDespair:Despair_CacheEval(player, cacheFlag)
	local tempEffects = player:GetEffects():GetCollectibleEffectNum(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR)
	if tempEffects > 0 then
		local currentTears = 30 / (player.MaxFireDelay + 1)
		local usesMul = 0
		for count = 1, tempEffects do
			usesMul = usesMul + (2 / count)
		end
		local newTears = currentTears * usesMul
		player.MaxFireDelay = math.max((30 / newTears) - 1, -0.75)
	end
end

AntibirthItemPack:AddCallback(ModCallbacks.MC_USE_ITEM, BookOfDespair.UseBookOfDespair, AntibirthItemPack.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR)
AntibirthItemPack:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BookOfDespair.Despair_CacheEval, CacheFlag.CACHE_FIREDELAY)