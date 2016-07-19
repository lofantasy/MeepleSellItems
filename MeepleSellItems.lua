--
-- Created by IntelliJ IDEA.
-- User: shadowwa
-- Date: 7/10/2016
-- Time: 6:46 PM
-- To change this template use File | Settings | File Templates.
--

local frame = CreateFrame("FRAME");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("PLAYER_LOGOUT");
frame:RegisterEvent("BANKFRAME_OPENED");
frame:RegisterEvent("BANKFRAME_CLOSED");

local GlobalAddonName = ...

local isEnchanter = false
local className;
local Unusable;
local isBankOpen = false;

local inspectScantip = CreateFrame("GameTooltip", GlobalAddonName .."ScanningTooltip", nil, "GameTooltipTemplate")
inspectScantip:SetOwner(UIParent, "ANCHOR_NONE")

--[[ should put this into a parent file. want to use it for the item compare ]]--
local Unusable = {
    ["Hunter"] = {

    },
    ["Warrior"] = {
        [LE_ITEM_CLASS_WEAPON] = {
            [LE_ITEM_WEAPON_WAND] = true
        },
        [LE_ITEM_CLASS_ARMOR] = {
            [LE_ITEM_ARMOR_CLOTH] = true,
            [LE_ITEM_ARMOR_LEATHER] = true,
            [LE_ITEM_ARMOR_MAIL] = true
        }
    },
    ["Death Knight"] = {
        [LE_ITEM_CLASS_WEAPON] = {
            [LE_ITEM_WEAPON_STAFF] = true,

        },
        [LE_ITEM_CLASS_ARMOR] = {
            [LE_ITEM_ARMOR_CLOTH] = true,
            [LE_ITEM_ARMOR_LEATHER] = true,
            [LE_ITEM_ARMOR_MAIL] = true
        }
    },
    ["Druid"] = {

    },
    ["Shaman"] = {
        [LE_ITEM_CLASS_WEAPON] = {
            [LE_ITEM_WEAPON_SWORD1H] = true,
            [LE_ITEM_WEAPON_CROSSBOW] = true,
            [LE_ITEM_WEAPON_BOWS] = true,
            [LE_ITEM_WEAPON_WAND] = true,
            [LE_ITEM_WEAPON_GUNS] = true,
            [LE_ITEM_WEAPON_POLEARM] = true,
        },
        [LE_ITEM_CLASS_ARMOR] = {
            [LE_ITEM_ARMOR_CLOTH] = true,
            [LE_ITEM_ARMOR_LEATHER] = true,
            [LE_ITEM_ARMOR_PLATE] = true
        }
    }
}

function frame:OnEvent(event, arg1)
    if (event == "ADDON_LOADED" and arg1 == "MeepleSellItems") then
        local realmName = GetRealmName();
        local char = GetUnitName("player", true);

        fullName = char .. " - " .. realmName;
        className = UnitClass("player")
        print(className);

    end

    if ( event == "BANKFRAME_OPENED") then
        isBankOpen = true;
    end

    if ( event == "BANKFRAME_CLOSED") then
        isBankOpen = false;
    end

    if ( event == "PLAYER_LOGIN") then
        init_tooltips();
    end

end

frame:SetScript( "OnEvent", frame.OnEvent);

SLASH_MEEPLESELLITEM1 = "/meeplesellitem";

local function safe_sell_item(bag, slot)
    if (MerchantFrame:IsVisible()) then
        UseContainerItem(bag,slot);
    end
end


local function checkUseableGear( itemLink, classId, subClassId, bag, slot, typ)

    if ( Unusable[className][ classId][ subClassId] and typ ~= "INVTYPE_CLOAK") then
        -- safe_sell_item( bag, slot);
        return true;
    end

    return false;
end


local function checkGreenGear( itemLink, bag, slot, isBoe, isCollected, isSoulBound)
    local item = { GetItemInfo( itemLink)};
    local classId = item[12];
    local subClassId = item[13];

    if ( item[9] ~= "") then
        if ( checkUseableGear( itemLink, classId, subClassId, bag, slot, item[9])) then
            print("  - Unuseable item found, sell at merchant");
            safe_sell_item(bag, slot);
            return;
        end

        if ( not isCollected) then
            print(" - Not Collected, Equip to learn");
        else
            if ( item[4] < 600) then
                print(" - Learned, Selling item now (<600 ilvl)");
                safe_sell_item(bag, slot);
            end
        end

    end

end

local function checkRareGear( itemLink, bag, slot, isBoe, isCollected, isSoulBound)
    local item = { GetItemInfo( itemLink)};
    local classId = item[12];
    local subClassId = item[13];

    if ( item[9] ~= "") then
        if ( checkUseableGear( itemLink, classId, subClassId, bag, slot, item[9])) then
            print("  - Unuseable item found, sell at merchant");
            safe_sell_item(bag, slot);
            return;
        end

        if ( not isCollected) then
            print(" - Not Collected, Equip to learn");
        else
            -- Known issue: timewarped bases the actual ilvl off the items tru ilevel. aka, if its a 200 ilvl but with timewarped its 630 the item[4] will show 200.
            -- - there is a bonus ID of 615 that shows its timewarped

            if ( item[4] < 600) then
                print(" - Learned, Selling item now (<600 ilvl)");
                safe_sell_item(bag, slot);
            end

        end

    end

end

local function checkEpicGear( itemLink, bag, slot, isBoe, isCollected, isSoulBound)
    local item = { GetItemInfo( itemLink)};
    local classId = item[12];
    local subClassId = item[13];

    if ( item[9] ~= "") then
        if ( checkUseableGear( itemLink, classId, subClassId, bag, slot, item[9])) then
            if ( isSoulBound) then
                print("  - Unuseable item found, sell at merchant");
                safe_sell_item(bag, slot);
            else
                print("  - BOE Item, Send to toon that can use it");
            end

            return;
        end

        if ( not isCollected) then
            print("  - Not Collected, Equip to learn");
        else
            if ( item[4] < 600) then
                print("  - Learned, Selling item now (<600 ilvl)");

                if ( isSoulBound) then
                    safe_sell_item(bag, slot);
                end

            end

        end

    end

end

function ScanTooltipOfBagItem(bag, slot)
    local isBOE = false;
    local isCollected = true;
    local isSoulBound = false;

    inspectScantip:SetBagItem(bag, slot);

    for k = 1, inspectScantip:NumLines() do
        if _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText() == ITEM_BIND_ON_EQUIP then
            isBOE = true
            -- break
        elseif _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText() == "You haven't collected this appearance" then
            -- I am going to assume with the release of 7.x there will be a new API for this information. there IS a new Blizzard plugin for it but i see no source to it yet.
            isCollected = false;
        elseif _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText() == ITEM_SOULBOUND then
            isSoulBound = true;
        end
    end
    inspectScantip:ClearLines();

    return isBOE, isCollected, isSoulBound;

end

function SlashCmdList.MEEPLESELLITEM()
    DEFAULT_CHAT_FRAME:AddMessage("" .. UnitClass("player"));

--    if (MerchantFrame:IsVisible()) then
--        -- Merchant window is open, prepare to scan/sell items
--    else
        -- scan for items that are not learned from mogging.
        for bag = 3, 3, 1 do
            for slot = 1, GetContainerNumSlots( bag), 1 do
                local itemLink = GetContainerItemLink( bag, slot);
                local itemId = GetContainerItemID( bag, slot);

                if ( itemLink ~= nil) then
                    local id = itemLink:match("item:(%d+)");
                    local color = itemLink:match("|c(%w+)|H");
                    local name, link, quality, itemLevel, reqLevel, class, subClass, maxStack, equipSlot, itemTexture = GetItemInfo( itemLink);

                    if ( class == "Armor" or class == "Weapon") then

                        print("Bag [" .. slot .. "]: " .. id .. " [" .. color .. "]: " .. itemLink .. " [" .. class .. "] ilvl [" .. itemLevel .. "]");
                        if ( subClass ~= nil) then
                            print("  SubClass [" .. subClass .. "]");
                        end
                        -- Debug:
                        --DEFAULT_CHAT_FRAME:AddMessage(":  " .. itemLink:gsub("|", "||"));
                        --FindBonuses(itemLink, itemId, bag, slot);
                        -- ^ this is to show what bonuses the item actually has. need to work on figuring out timewalking.

                        if ( subClass == "Miscellaneous") then

                        else

                            local isBoe, isCollected, soulBound = ScanTooltipOfBagItem(bag, slot);

                            if ( quality == LE_ITEM_QUALITY_UNCOMMON) then
                                checkGreenGear(itemLink, bag, slot, isBoe, isCollected, soulBound);
                            elseif ( quality == LE_ITEM_QUALITY_RARE) then
                                checkRareGear(itemLink, bag, slot, isBoe, isCollected, soulBound);
                            elseif ( quality == LE_ITEM_QUALITY_EPIC) then
                                checkEpicGear(itemLink, bag, slot, isBoe, isCollected, soulBound);
                            end

                        end

                    end

                end

            end

        end

--    end


end


-- Borrowed from another addon while i figure out what it does.
local majorBonuses = {
    [451] = true,
    [450] = true,
    [564] = true, -- Socket
    [566] = true, -- Heroic
    [567] = true,
    -- [518] = true, -- Item Level 530
    -- [519] = true, -- Item Level 550
    -- [520] = true, -- Item Level 570
    -- [521] = true, -- Item Level 600
    -- [522] = true, -- Item Level 615
    [524] = true, -- Item Level 630
    [525] = true,
    [526] = true,
    [527] = true,
    [593] = true,
    [617] = true,
    [618] = true,
    [558] = true,
    [559] = true,
    [594] = true,
    [619] = true,
    [620] = true,
}

--[[
Faceguard of the Hammer Clan: |cff0070dd|Hitem:127639::::::::100:73:512:22:2:615:656:100:::|h[Faceguard of the Hammer Clan]|h|r
    Timewarped Warforged, Item Level 675, Str, Stam, Haste, Int, Plate.
    - 615 = timewarped
    - 656 = timewarped warforged

Bonegrider Breastplate: |cff0070dd|Hitem:127623::::::::100:73:512:22:1:615:100:::|h[Bonegrider Breastplate]|h|r
    Timewarped, item level 660, str, stam, crit, int
 ]]--

function FindBonuses(link, id, bag, slot)
    if link then
        local bonusesNum, bonusesString = link:match("item:%d+:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:([0-9%-]*):([0-9:]*)");
        if ( bonusesString == nil) then
            bonusesString = "";
        end
        if ( bonusesNum == nil) then
            bonusesNum = -1;
        end

        if bonusesNum and bonusesString and tonumber(bonusesNum) then
            for i = 1, tonumber(bonusesNum) do
                local bonus = bonusesString:match("^[0-9%-]+")

                if bonus then
                    DEFAULT_CHAT_FRAME:AddMessage("-- " .. bonus);
                    bonus = tonumber(bonus)
                    if majorBonuses[bonus] then
                        return bonus
                    end
                end

                if bonusesString:find(":") then
                    bonusesString = bonusesString:gsub("^[^:]*:","")
                end
            end
        end

        DEFAULT_CHAT_FRAME:AddMessage("Bonus (" .. bonusesNum .. "), vals [" .. bonusesString .. "]");

    end

end
