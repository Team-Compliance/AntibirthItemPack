local BowlMouseClick = {LEFT = 0, RIGHT = 1, WHEEL = 2, BACK = 3, FORWARD = 4}
local BowlOfTears = {}
if REPENTOGON then
	function BowlOfTears:ChargeOnFire(dir, amount, owner)
		if owner then
			local player = owner:ToPlayer()
			if not player then return end
			for i = 0,2 do
				if player:GetActiveItem(i) == AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
					player:AddActiveCharge(1, ActiveSlot.SLOT_PRIMARY, true, false, true)
				end
			end
		end
	end
	AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, BowlOfTears.ChargeOnFire)

else
	local function FireTear(player)
		local data = AntibirthItemPack:GetData(player)
		if data.PrevDelay and player.HeadFrameDelay > data.PrevDelay and player.HeadFrameDelay > 1 then 
			AntibirthItemPack:ChargeBowl(player)
		end 
		data.PrevDelay = player.HeadFrameDelay
	end

	local function LudoCharge(entity)
		local player = AntibirthItemPack:GetPlayerFromTear(entity)
		local data = AntibirthItemPack:GetData(entity)
		if player then
			if player:GetActiveWeaponEntity() and entity.FrameCount > 0 then
				if entity.TearFlags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO and GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(entity) then
					if math.fmod(entity.FrameCount, player.MaxFireDelay) == 1 and not data.KnifeLudoCharge then
						AntibirthItemPack:ChargeBowl(player)
						data.KnifeLudoCharge = true
					elseif math.fmod(entity.FrameCount, player.MaxFireDelay) == ((player.MaxFireDelay - 2) > 1 and (player.MaxFireDelay - 2) or 1) and data.KnifeLudoCharge then
						data.KnifeLudoCharge = nil
					end
				end
			end
		end
	end

	--firing tears updates the bowl
	function BowlOfTears:TearBowlCharge(player)
		if not player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) and not player:HasWeaponType(WeaponType.WEAPON_KNIFE)
		and not player:HasWeaponType(WeaponType.WEAPON_ROCKETS) and not player:HasWeaponType(WeaponType.WEAPON_TECH_X)
		and not player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
			FireTear(player)
		end
	end

	--updating knife charge
	function BowlOfTears:KnifeBowlCharge(entityKnife)
		local player = AntibirthItemPack:GetPlayerFromTear(entityKnife)
		local data = AntibirthItemPack:GetData(entityKnife)
		if player then
			if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN
			or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then return end
			local sk = entityKnife:GetSprite()
			if entityKnife.Variant == 10 and entityKnife.SubType == 0 then --spirit sword
				if sk:GetFrame() == 3 and not data.SwordSpin then
					AntibirthItemPack:ChargeBowl(player)
					data.SwordSpin = true
				elseif data.SwordSpin then
					for _,s in ipairs({"Left","Right","Down","Up"}) do
						if (sk:IsPlaying("Attack"..s) or sk:IsPlaying("Spin"..s)) and sk:GetFrame() == 2 then
							data.SwordSpin = nil
							break
						end
					end
				end
			elseif entityKnife:IsFlying() and not data.Flying then --knife flies
				data.Flying = true
				if GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(entityKnife) then
					AntibirthItemPack:ChargeBowl(player)
				end
			elseif not entityKnife:IsFlying() and data.Flying then --one charge check
				data.Flying = nil
			elseif entityKnife.Variant == 1 or entityKnife.Variant == 3 and GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(entityKnife) then
				if sk:GetFrame() == 1 and not data.BoneSwing then
					AntibirthItemPack:ChargeBowl(player)
					data.BoneSwing = true
				end
			else
				LudoCharge(entityKnife)
			end
		end
	end

	--updating ludo charge and fired from bowl tears
	function BowlOfTears:TearUpdateBOT(entityTear)
		local player = AntibirthItemPack:GetPlayerFromTear(entityTear)
		--updating charges with ludo
		if player then
			LudoCharge(entityTear)
			--updating slight height and acceleration of tears from bowl
			--[[if entityTear.FrameCount == 1 and TC_SaltLady:GetData(entityTear).FromBowl then
				--local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS)
				entityTear.Height = TC_SaltLady:GetRandomNumber(-40,-24, TC_SaltLady.Globals.rng)
				entityTear.FallingAcceleration = 1 / TC_SaltLady:GetRandomNumber(1,5,TC_SaltLady.Globals.rng)
			end]]
		end
	end

	--chargin lasers
	function BowlOfTears:BrimstoneBowlCharge(entityLaser)
		if entityLaser.SpawnerType == EntityType.ENTITY_PLAYER and not AntibirthItemPack:GetData(entityLaser).isSpreadLaser then
			local player = AntibirthItemPack:GetPlayerFromTear(entityLaser)
			if player then
				if player:HasWeaponType(WeaponType.WEAPON_TECH_X) then
					FireTear(player)
				elseif player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) and player:GetActiveWeaponEntity() then
					local delay = player:GetActiveWeaponEntity().SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO and player.MaxFireDelay or 5
					if math.fmod(player:GetActiveWeaponEntity().FrameCount, delay) == 1 then
						AntibirthItemPack:ChargeBowl(player)
					end
				end
			end
		end
	end

	--that one scene from Dr. Strangelove 
	function BowlOfTears:EpicBowlCharge(entityRocet)
		local player = AntibirthItemPack:GetPlayerFromTear(entityRocet)
		if player then
			AntibirthItemPack:ChargeBowl(player)
		end
	end

	AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BowlOfTears.TearBowlCharge)
	AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, BowlOfTears.KnifeBowlCharge)
	AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, BowlOfTears.TearUpdateBOT)
	AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, BowlOfTears.BrimstoneBowlCharge)
	AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, BowlOfTears.EpicBowlCharge, EffectVariant.ROCKET)
end
--lifting and hiding bowl
function BowlOfTears:UseBowl(collectibleType, rng, player, useFlags, slot, customdata)
	local data = AntibirthItemPack:GetData(player)
	if data.HoldingBowl ~= slot then
		data.HoldingBowl = slot
		player:AnimateCollectible(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "LiftItem", "PlayerPickup")
		data.BowlWaitFrames = 20
	else
		data.HoldingBowl = nil
		data.BowlWaitFrames = 0
		player:AnimateCollectible(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
	end
	local returntable = {Discharge = false, Remove = false, ShowAnim = false} --don't discharge, don't remove item, don't show animation
	return returntable
end

--reseting state/slot number on new room
function BowlOfTears:BowlRoomUpdate()
	for _,player in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
		AntibirthItemPack:GetData(player).HoldingBowl = nil
		AntibirthItemPack:GetData(player).BowlWaitFrames = 0
	end
end

--taiking damage to reset state/slot number
function BowlOfTears:DamagedWithBowl(player)
	AntibirthItemPack:GetData(player).HoldingBowl = nil
	AntibirthItemPack:GetData(player).BowlWaitFrames = 0
end

--shooting tears from bowl
function BowlOfTears:BowlShoot(player)
	local data = AntibirthItemPack:GetData(player)
	local slot = data.HoldingBowl
	--local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS)
	if slot and slot ~= -1 then
		if player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS and data.HoldingBowl ~= 2 then
			data.HoldingBowl = nil
			player:AnimateCollectible(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
			data.BowlWaitFrames = 0
		end
	end
	if slot then
		local idx = player.ControllerIndex
		local left = Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT,idx)
		local right = Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT,idx)
		local up = Input.GetActionValue(ButtonAction.ACTION_SHOOTUP,idx)
		local down = Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN,idx)
		local mouseclick = Input.IsMouseBtnPressed(BowlMouseClick.LEFT)
		local sprite = player:GetSprite()
		if data.BowlWaitFrames then
			data.BowlWaitFrames = data.BowlWaitFrames - 1
		else
			data.BowlWaitFrames = 0
		end
		if (left > 0 or right > 0 or down > 0 or up > 0 or mouseclick) and data.BowlWaitFrames <= 0 then
			local angle
			if mouseclick then
				angle = (Input.GetMousePosition(true) - player.Position):Normalized():GetAngleDegrees()
			else
				angle = Vector(right-left,down-up):Normalized():GetAngleDegrees()
			end
			local shootVector = Vector.FromAngle(angle)
			local charge = slot ~= -1 and Isaac.GetItemConfig():GetCollectible(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS).MaxCharges or 0
			for i= 1,AntibirthItemPack:GetRandomNumber(10,16,AntibirthItemPack.RNG) do
				--local angle = Vector(TC_SaltLady:GetRandomNumber(-2,2,TC_SaltLady.Globals.rng),TC_SaltLady:GetRandomNumber(-2,2,TC_SaltLady.Globals.rng))
				local tear = player:FireTear(player.Position,(shootVector*player.ShotSpeed):Rotated(AntibirthItemPack:GetRandomNumber(-10,10, AntibirthItemPack.RNG))*AntibirthItemPack:GetRandomNumber(6,10,AntibirthItemPack.RNG) + player.Velocity,false,true,false,player)
				tear.FallingSpeed = AntibirthItemPack:GetRandomNumber(-15,-3, AntibirthItemPack.RNG)
                tear.Height = AntibirthItemPack:GetRandomNumber(-60,-40, RNG())
                tear.FallingAcceleration = AntibirthItemPack:GetRandomNumber(0.5,0.6, AntibirthItemPack.RNG)
				if REPENTOGON then
					if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
						tear.CollisionDamage = math.max(player.Damage, player.Damage * player:GetWeapon(1):GetCharge() / player.MaxFireDelay)
					end
				else
					tear.CollisionDamage = player.Damage
				end
				AntibirthItemPack:GetData(tear).FromBowl = true
			end
			if charge > 0 then
				if AntibirthItemPack:GetCharge(player, slot) < charge then
					player:SetSoulCharge(player:GetSoulCharge() - 1)
					player:SetBloodCharge(player:GetBloodCharge() - 1)
				end
				player:SetActiveCharge(math.max(0, AntibirthItemPack:GetCharge(player, slot) - charge),slot)
			end
			data.HoldingBowl = nil
			data.BowlWaitFrames = 0
			player:AnimateCollectible(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
				for i=1, 3 do
					player:AddWisp(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, player.Position)
				end
			end
		end
	end
end

function BowlOfTears:WispUpdateBOT(wisp)
	local player = wisp.Player
	local data = AntibirthItemPack:GetData(wisp)
	if player:HasCollectible(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS) then
		if wisp.SubType == AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
			if not data.Timeout then
				data.Timeout = 90
			end
			if data.Timeout > 0 then
				data.Timeout = data.Timeout - 1
			else
				wisp:Kill()
			end
		end
	end
end

AntibirthItemPack:AddCallback(ModCallbacks.MC_USE_ITEM, BowlOfTears.UseBowl, AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS)
AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BowlOfTears.BowlRoomUpdate)
AntibirthItemPack:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BowlOfTears.DamagedWithBowl, EntityType.ENTITY_PLAYER)
AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BowlOfTears.BowlShoot)
AntibirthItemPack:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BowlOfTears.WispUpdateBOT, FamiliarVariant.WISP)


--self explanatory
function AntibirthItemPack:GetCharge(player,slot)
	return player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
end

function AntibirthItemPack:BatteryChargeMult(player)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and 2 or 1
end

--hud and sfx reactions in all slots
function AntibirthItemPack:ChargeBowl(player)
	for slot = 0,2 do
		if player:GetActiveItem(slot) == AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
			local charge = AntibirthItemPack:GetCharge(player,slot)
			if charge < 6 * AntibirthItemPack:BatteryChargeMult(player) then
				player:SetActiveCharge(charge+1,slot)
				Game():GetHUD():FlashChargeBar(player,slot)
				if charge >= 5 then
					SFXManager():Play(SoundEffect.SOUND_ITEMRECHARGE)
				else
					SFXManager():Play(SoundEffect.SOUND_BEEP)
				end
			end
		end
	end
end