function AntibirthItemPack:PostNewRoom()
	for _, player in pairs(AntibirthItemPack:GetPlayers()) do
		local data = AntibirthItemPack:GetData(player)
		data.ExtraSpins = 0 --just in case it gets interrupted
	end
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, AntibirthItemPack.PostNewRoom)

function AntibirthItemPack:PlayerHurt(TookDamage, DamageAmount, DamageFlags, DamageSource, DamageCountdownFrames)
	local player = TookDamage:ToPlayer()
	local data = AntibirthItemPack:GetData(player)
	
	if player:HasCollectible(AntibirthItemPack.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE) then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
			data.ExtraSpins = data.ExtraSpins + 1
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) then
			data.ExtraSpins = data.ExtraSpins + 2
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) then
			data.ExtraSpins = data.ExtraSpins + 3
		end
		
		AntibirthItemPack:SpawnJawbone(player)
	end
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, AntibirthItemPack.PlayerHurt, EntityType.ENTITY_PLAYER)


function AntibirthItemPack:JawboneUpdate(jawbone)
	local player = AntibirthItemPack:GetPlayerFromTear(jawbone)
	local data = AntibirthItemPack:GetData(player)
	local sprite = jawbone:GetSprite()
	
	if sprite:IsPlaying("SpinLeft") or sprite:IsPlaying("SpinUp") or sprite:IsPlaying("SpinRight") or sprite:IsPlaying("SpinDown") then
		jawbone.Position = player.Position
		SFXManager():Stop(SoundEffect.SOUND_TEARS_FIRE)
	else
		jawbone:Remove()
		if data.ExtraSpins > 0 then
			AntibirthItemPack:SpawnJawbone(player)
			data.ExtraSpins = data.ExtraSpins - 1
		end
	end
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, AntibirthItemPack.JawboneUpdate, 1001)

function AntibirthItemPack:MeatySound(entityTear, collider, low)
	if collider:IsActiveEnemy(true) then
		SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS)
	end
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, AntibirthItemPack.MeatySound, 1001)

function AntibirthItemPack:SpawnJawbone(player)
	local jawbone = Isaac.Spawn(2, 1001, 0, player.Position, Vector.Zero, player):ToTear()
	local data = AntibirthItemPack:GetData(jawbone)
	
	data.isJawbone = true
	jawbone.Parent = player
	jawbone.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
	jawbone.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
	jawbone.CollisionDamage = (player.Damage * 8) + 10
	jawbone:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_SHIELDED | TearFlags.TEAR_HP_DROP | TearFlags.TEAR_EXTRA_GORE)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
		jawbone:AddTearFlags(TearFlags.TEAR_POISON)
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) then
		jawbone:AddTearFlags(TearFlags.TEAR_ICE)
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) then
		jawbone:AddTearFlags(TearFlags.TEAR_LIGHT_FROM_HEAVEN)
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER) then
		jawbone:AddTearFlags(TearFlags.TEAR_COIN_DROP_DEATH)
	end
	
	local sprite = jawbone:GetSprite()
	local headDirection = player:GetHeadDirection()
	if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) or player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) or player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) then
		sprite.PlaybackSpeed = 2
	end
	
	if headDirection == Direction.LEFT then
		sprite:Play("SpinLeft", true)
	elseif headDirection == Direction.UP then
		sprite:Play("SpinUp", true)
	elseif headDirection == Direction.RIGHT then
		sprite:Play("SpinRight", true)
	elseif headDirection == Direction.DOWN then
		sprite:Play("SpinDown", true)
	end
	
	SFXManager():Play(SoundEffect.SOUND_SWORD_SPIN)
end