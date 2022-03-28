local mod = AntibirthItemPack

function mod:UseBookOfDespair(_Type, RNG, player, flags, slot, data)
	if not (flags & UseFlag.USE_CARBATTERY > 0) then
		local tempEffects = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR)
		if GiantBookAPI and tempEffects == 0 then
			GiantBookAPI.playGiantBook("Appear", "Despair.png", Color(228/255, 228/255, 228/255, 1, 0, 0, 0), Color(228/255, 228/255, 228/255, 153/255, 0, 0, 0), Color(225/255, 225/255, 225/255, 128/255, 0, 0, 0))
		end
		SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 0.8, 0, false, 1)
	end
	
	return true
end

function mod:Despair_CacheEval(player, cacheFlag)
	local tempEffects = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR)
	
	if tempEffects > 0 then
		for count = 1, tempEffects do
			local currentTears = 30 / (player.MaxFireDelay + 1)
			local newTears = currentTears * 2
			if count > 1 then
				newTears = currentTears * 1.5
			end
			player.MaxFireDelay = math.max((30 / newTears) - 1, -0.75)
		end
	end
end

--Minimap Items Compatibility
if MiniMapiItemsAPI then
    local frame = 1
    local bookofdespairSprite = Sprite()
    bookofdespairSprite:Load("gfx/ui/minimapitems/antibirthitempack_bookofdespair_icon.anm2", true)
    MiniMapiItemsAPI:AddCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR, bookofdespairSprite, "CustomIconBookOfDepair", frame)
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseBookOfDespair, CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.Despair_CacheEval, CacheFlag.CACHE_FIREDELAY)