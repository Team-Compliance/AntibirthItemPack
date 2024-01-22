local StoneBombs = {}

local directions = {
	0,
	90,
	180,
	270
}

function StoneBombs:SB_BombUpdate(bomb)
	local player = AntibirthItemPack:GetPlayerFromTear(bomb)
	local data = AntibirthItemPack:GetData(bomb)
	
	if player then
		if bomb.FrameCount == 1 then
			if bomb.Type == EntityType.ENTITY_BOMB then
				if bomb.Variant ~= BombVariant.BOMB_THROWABLE then
					if player:HasCollectible(AntibirthItemPack.CollectibleType.COLLECTIBLE_STONE_BOMBS) then
						if data.isStoneBomb == nil then
							data.isStoneBomb = true
						end
					end
				end
			end
		end
	end
	
	if data.isStoneBomb then
		local sprite = bomb:GetSprite()

		if bomb.FrameCount == 1 then
			if bomb.Variant == BombVariant.BOMB_NORMAL then
				if not bomb:HasTearFlags(TearFlags.TEAR_BRIMSTONE_BOMB) then
					if bomb:HasTearFlags(TearFlags.TEAR_GOLDEN_BOMB) then
						sprite:ReplaceSpritesheet(0, "gfx/items/pick ups/bombs/costumes/stone_bombs_gold.png")
					else
						sprite:ReplaceSpritesheet(0, "gfx/items/pick ups/bombs/costumes/stone_bombs.png")
					end
					sprite:LoadGraphics()
				end
			end
		end
		
		if sprite:IsPlaying("Explode") then
			StoneBombs:SB_Explode(bomb, player)
		end
	end
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, StoneBombs.SB_BombUpdate)

function StoneBombs:SB_Explode(bomb, player)
	for _, dir in pairs(directions) do
		local crackwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKWAVE, 1, bomb.Position, bomb.Velocity, player)
		crackwave:ToEffect().Rotation = dir
	end
end

function StoneBombs:CrackWavePits(effect)
	local room = Game():GetRoom()
	if effect.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_NOPITS then
		if room:GetGridEntityFromPos(effect.Position) and room:GetGridEntityFromPos(effect.Position):GetType() == GridEntityType.GRID_PIT then
			room:GetGridEntityFromPos(effect.Position):ToPit():MakeBridge(nil)
		end
	end
end

AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, StoneBombs.SB_BombUpdate)