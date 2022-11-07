local mod = AntibirthItemPack

LaserVariant = {BRIMSTONE = 1, TECHNOLOGY = 2, MEGA_BLAST = 6,  TECH_BRIMSTONE = 9, TECH_ZERO = 10, BIG_BRIM = 11, TECHSTONE = 14}
BowlMouseClick = {LEFT = 0, RIGHT = 1, WHEEL = 2, BACK = 3, FORWARD = 4}
mod.MaxExtraTears = 1

local function FireTear(player)
	local data = mod:GetData(player)
	if data.PrevDelay and player.HeadFrameDelay > data.PrevDelay and player.HeadFrameDelay > 1 then 
		mod:ChargeBowl(player)
	end 
	data.PrevDelay = player.HeadFrameDelay
end
--firing tears updates the bowl
function mod:TearBowlCharge(player)
	if not player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) and not player:HasWeaponType(WeaponType.WEAPON_KNIFE)
	and not player:HasWeaponType(WeaponType.WEAPON_ROCKETS) and not player:HasWeaponType(WeaponType.WEAPON_TECH_X)
	and not player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
		FireTear(player)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.TearBowlCharge)

local function LudoCharge(entity)
	local player = mod:GetPlayerFromTear(entity)
	local data = mod:GetData(entity)
	if player then
		if player:GetActiveWeaponEntity() and entity.FrameCount > 0 then
			if entity.TearFlags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO and GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(entity) then
				if math.fmod(entity.FrameCount, player.MaxFireDelay) == 1 and not data.KnifeLudoCharge then
					mod:ChargeBowl(player)
					data.KnifeLudoCharge = true
				elseif math.fmod(entity.FrameCount, player.MaxFireDelay) == ((player.MaxFireDelay - 2) > 1 and (player.MaxFireDelay - 2) or 1) and data.KnifeLudoCharge then
					data.KnifeLudoCharge = nil
				end
			end
		end
	end
end

--updating knife charge
function mod:KnifeBowlCharge(entityKnife)
	local player = mod:GetPlayerFromTear(entityKnife)
	local data = mod:GetData(entityKnife)
	if player then
		if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN
		or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then return end
		local sk = entityKnife:GetSprite()
		if entityKnife.Variant == 10 and entityKnife.SubType == 0 then --spirit sword
			if sk:GetFrame() == 3 and not data.SwordSpin then
				mod:ChargeBowl(player)
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
				mod:ChargeBowl(player)
			end
		elseif not entityKnife:IsFlying() and data.Flying then --one charge check
			data.Flying = nil
		elseif entityKnife.Variant == 1 or entityKnife.Variant == 3 and GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(entityKnife) then
			if sk:GetFrame() == 1 and not data.BoneSwing then
				mod:ChargeBowl(player)
				data.BoneSwing = true
			end
		else
			LudoCharge(entityKnife)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, mod.KnifeBowlCharge)

--updating ludo charge and fired from bowl tears
function mod:TearUpdate(entityTear)
	local player = mod:GetPlayerFromTear(entityTear)
	--updating charges with ludo
	if player then
		LudoCharge(entityTear)
				--updating slight height and acceleration of tears from bowl
		--[[if entityTear.FrameCount == 1 and mod:GetData(entityTear).FromBowl then
			local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS)
			entityTear.Height = mod:GetRandomNumber(-40,-24,rng)
			entityTear.FallingAcceleration = 1 / mod:GetRandomNumber(1,5,rng)
		end]]
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.TearUpdate)

--chargin lasers
function mod:BrimstoneBowlCharge(entityLaser)
	if entityLaser.SpawnerType == EntityType.ENTITY_PLAYER and not mod:GetData(entityLaser).isSpreadLaser then
		local player = mod:GetPlayerFromTear(entityLaser)
		if player then
			if player:HasWeaponType(WeaponType.WEAPON_TECH_X) then
				FireTear(player)
			elseif player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) and player:GetActiveWeaponEntity() then
				local delay = player:GetActiveWeaponEntity().SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO and player.MaxFireDelay or 5
				if math.fmod(player:GetActiveWeaponEntity().FrameCount, delay) == 1 then
					mod:ChargeBowl(player)
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.BrimstoneBowlCharge)

--that one scene from Dr. Strangelove 
function mod:EpicBowlCharge(entityRocet)
	local player = mod:GetPlayerFromTear(entityRocet)
	if player then
		mod:ChargeBowl(player)
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.EpicBowlCharge, EffectVariant.ROCKET)

--lifting and hiding bowl
function mod:UseBowl(_,_,player,_,slot)
	local data = mod:GetData(player)
	if data.HoldingBowl ~= slot then
		data.HoldingBowl = slot
		player:AnimateCollectible(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "LiftItem", "PlayerPickup")
	else
		data.HoldingBowl = nil
		player:AnimateCollectible(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
	end
	local returntable = {Discharge = false, Remove = false, ShowAnim = false} --don't discharge, don't remove item, don't show animation
	return returntable
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseBowl, CollectibleType.COLLECTIBLE_BOWL_OF_TEARS)

--reseting state/slot number on new room
function mod:BowlRoomUpdate()
	for _,player in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
		mod:GetData(player).HoldingBowl = nil
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.BowlRoomUpdate)

--taiking damage to reset state/slot number
function mod:DamagedWithBowl(player)
	mod:GetData(player).HoldingBowl = nil
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.DamagedWithBowl, EntityType.ENTITY_PLAYER)

--shooting tears from bowl
function mod:BowlShoot(player)
	local data = mod:GetData(player)
	local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS)
	if data.HoldingBowl ~= -1 then
		if player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == CollectibleType.COLLECTIBLE_BOWL_OF_TEARS and data.HoldingBowl then
			data.HoldingBowl = nil
			player:AnimateCollectible(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
		end
	end
	if data.HoldingBowl then
		local idx = player.ControllerIndex
		local left = Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT,idx)
		local right = Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT,idx)
		local up = Input.GetActionValue(ButtonAction.ACTION_SHOOTUP,idx)
		local down = Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN,idx)
		local mouseclick = Input.IsMouseBtnPressed(BowlMouseClick.LEFT)
		if left > 0 or right > 0 or down > 0 or up > 0 or mouseclick then
			local angle
			if mouseclick then
				angle = (Input.GetMousePosition(true) - player.Position):Normalized():GetAngleDegrees()
			else
				angle = Vector(right-left,down-up):Normalized():GetAngleDegrees()
			end
			local shootVector = Vector.FromAngle(angle)
			local charge = data.HoldingBowl ~= -1 and mod:GetCharge(player,data.HoldingBowl) or 6
			for i= 1,mod:GetRandomNumber(charge+4,charge*2+4,rng) do
				--local angle = Vector(mod:GetRandomNumber(-2,2,rng),mod:GetRandomNumber(-2,2,rng))
				local tear = player:FireTear(player.Position,(shootVector*player.ShotSpeed):Rotated(mod:GetRandomNumber(-10,10,rng))*mod:GetRandomNumber(6,10,rng) + player.Velocity,false,true,false,player)
				tear.FallingSpeed = mod:GetRandomNumber(-15,-3, rng)
                		tear.Height = mod:GetRandomNumber(-60,-40, rng)
                		tear.FallingAcceleration = mod:GetRandomNumber(0.5,0.6, rng)
				mod:GetData(tear).FromBowl = true
			end
			if data.HoldingBowl == -1 then
				for slot = 0,2 do
					if player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
						if charge < 6 then
							player:SetSoulCharge(player:GetSoulCharge() - 6 + charge)
							player:SetBloodCharge(player:GetBloodCharge() - 6 + charge)
						end
						player:SetActiveCharge(0,slot)
					end
				end
			elseif data.HoldingBowl ~= -1 then
				if charge < 6 then
					player:SetSoulCharge(player:GetSoulCharge() - 6 + charge)
					player:SetBloodCharge(player:GetBloodCharge() - 6 + charge)
				end
				player:SetActiveCharge(0,data.HoldingBowl)
			end
			data.HoldingBowl = nil
			player:AnimateCollectible(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
				for i=1, 3 do
					player:AddWisp(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, player.Position)
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.BowlShoot)


--self explanatory
function mod:GetCharge(player,slot)
	return player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
end

--hud and sfx reactions in all slots
function mod:ChargeBowl(player)
	for slot = 0,2 do
		if player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
			local charge = mod:GetCharge(player,slot)
			local battery = player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY)
			if not battery and charge < 6 or battery and charge < 12 then
				player:SetActiveCharge(charge+1,slot)
				Game():GetHUD():FlashChargeBar(player,slot)
				if charge == 5 or charge == 11 then
					SFXManager():Play(SoundEffect.SOUND_ITEMRECHARGE)
				else
					SFXManager():Play(SoundEffect.SOUND_BEEP)
				end
			end
		end
	end
end

function mod:WispUpdate(wisp)
	local player = wisp.Player
	local data = mod:GetData(wisp)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS) then
		if wisp.SubType == CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
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

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.WispUpdate, FamiliarVariant.WISP)
