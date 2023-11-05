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
	local player = entityTear.SpawnerEntity:ToPlayer()

	if collider:IsActiveEnemy(true) then
		SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS)
		
		local JawBonerng = player:GetCollectibleRNG(AntibirthItemPack.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE)
		local heartSpawnChance = AntibirthItemPack:GetRandomNumber(1, 100, JawBonerng)
		local heartSpawn
		
		collider:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
		
		if collider.HitPoints <= entityTear.CollisionDamage then
			if not collider:IsBoss() then
				if heartSpawnChance > 1 and heartSpawnChance <= 9 then
					heartSpawn = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, collider.Position, Vector.Zero, player):ToPickup()
					heartSpawn.Timeout = 60
				elseif heartSpawnChance <= 1 then
					heartSpawn = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, collider.Position, Vector.Zero, player):ToPickup()
					heartSpawn.Timeout = 60
				end
			end
		end
	end
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, AntibirthItemPack.MeatySound, 1001)

function AntibirthItemPack:OnBulletReflectedByJawbone(projectile)
	local projectileData = projectile:GetData()
	for i, entity in pairs(Isaac.FindInRadius(projectile.Position, 20, EntityPartition.ENEMY)) do
		if projectileData.ReflectedByJawbone and projectileData.ReflectedByJawbone == true then
			entity:TakeDamage(3.5, 0, EntityRef(p), 0)
			projectile:Kill()
			SFXManager():Stop(SoundEffect.SOUND_DEATH_BURST_SMALL)
		end
	end
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, AntibirthItemPack.OnBulletReflectedByJawbone)

function AntibirthItemPack:SpawnJawbone(player)
	local jawbone = Isaac.Spawn(2, 1001, 0, player.Position, Vector.Zero, player):ToTear()
	local data = AntibirthItemPack:GetData(jawbone)
	local jawboneDamage = (player.Damage * 8) + 10
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
		jawboneDamage = (player.Damage * 8) + 16
	end
	
	local JawBonerng = player:GetCollectibleRNG(AntibirthItemPack.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE)


	data.isJawbone = true
	jawbone.Parent = player
	jawbone.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
	jawbone.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
	jawbone.CollisionDamage = jawboneDamage
	jawbone:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_EXTRA_GORE)
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
	
	for i, entity in pairs(Isaac.FindInRadius(jawbone.Position, 120, EntityPartition.BULLET)) do
		local projectile = entity:ToProjectile()
		local projectileData = projectile:GetData()
		local angle = ((player.Position - projectile.Position) * -1):GetAngleDegrees()
		local reflectChance = AntibirthItemPack:GetRandomNumber(1, 100, JawBonerng)
		
		if not projectileData.ReflectedByJawbone then
			projectileData.ReflectedByJawbone = false
		end
		
		if reflectChance <= 25 then
			projectileData.ReflectedByJawbone = true
			projectile.Velocity = Vector.FromAngle(angle):Resized(10)
		else
			projectile:Die()
		end
	end
end