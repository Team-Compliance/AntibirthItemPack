local frame = 1

local bookofdespairSprite = Sprite()
bookofdespairSprite:Load("gfx/ui/minimapitems/antibirthitempack_bookofdespair_icon.anm2", true)
MiniMapiItemsAPI:AddCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR, bookofdespairSprite, "CustomIconBookOfDepair", frame)

local bowloftearsSprite = Sprite()
bowloftearsSprite:Load("gfx/ui/minimapitems/antibirthitempack_bowloftears_icon.anm2", true)
MiniMapiItemsAPI:AddCollectible(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, bowloftearsSprite, "CustomIconBowlOfTears", frame)

local donkeyjawboneSprite = Sprite()
donkeyjawboneSprite:Load("gfx/ui/minimapitems/antibirthitempack_donkeyjawbone_icon.anm2", true)
MiniMapiItemsAPI:AddCollectible(CollectibleType.COLLECTIBLE_DONKEY_JAWBONE, donkeyjawboneSprite, "CustomIconDonkeyJawbone", frame)

local menorahSprite = Sprite()
menorahSprite:Load("gfx/ui/minimapitems/antibirthitempack_menorah_icon.anm2", true)
MiniMapiItemsAPI:AddCollectible(CollectibleType.COLLECTIBLE_MENORAH, menorahSprite, "CustomIconMenorah", frame)

local stonebombsSprite = Sprite()
stonebombsSprite:Load("gfx/ui/minimapitems/antibirthitempack_stonebombs_icon.anm2", true)
MiniMapiItemsAPI:AddCollectible(CollectibleType.COLLECTIBLE_STONE_BOMBS, stonebombsSprite, "CustomIconStoneBombs", frame)