local BlockDisabledItems = {}


function BlockDisabledItems:OnGameStart(isContinue)
    if isContinue then return end

    local itemPool = Game():GetItemPool()

    for _, disabledItem in ipairs(AntibirthItemPack.RunPersistentData.DisabledItems) do
        itemPool:RemoveCollectible(disabledItem)
    end
    if CCO and CCO.JOB_MOD then
		itemPool:RemoveCollectible(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR) --remove our book of despair if job mod is detected
	end
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, BlockDisabledItems.OnGameStart)


local isDisablingItem = false

function BlockDisabledItems:PostGetCollectible(selectedItem, poolType, decrease, seed)
    if isDisablingItem then return end

    local isDisabledItem = false

    for _, disabledItem in ipairs(AntibirthItemPack.RunPersistentData.DisabledItems) do
        if selectedItem == disabledItem then
            isDisabledItem = true
            break
        end
    end

    if not isDisabledItem then return end


    local itemPool = Game():GetItemPool()

    local rng = RNG()
    rng:SetSeed(seed, 35)

    isDisablingItem = true
    local newItem = itemPool:GetCollectible(poolType, decrease, rng:Next() * 1000)
    isDisablingItem = false

    return newItem
end
AntibirthItemPack:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, BlockDisabledItems.PostGetCollectible)