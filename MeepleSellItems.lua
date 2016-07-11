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

local Unusable = {
    ["Hunter"] = {

    },
    ["Warrior"] = {
        ["Weapons"] = {
            ["Two-Handed Axes"] = false,
            ["Wands"] = true
        },
        ["Armor"] = {
            ["Cloth"] = true,
            ["Mail"] = true,
            ["Leather"] =  true
        }
        -- In WoW 7.x the below works:
        --[LE_ITEM_CLASS_WEAPON] = {
        --    [LE_ITEM_WEAPON_WAND] = true
        --}
    },
    ["Death Knight"] = {

    },
    ["Druid"] = {

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

end

frame:SetScript( "OnEvent", frame.OnEvent);

SLASH_MEEPLESELLITEM1 = "/meeplesellitem";

local function checkUseableGear( itemLink, classId, subClassId, bag, slot, typ)
    print(classId);
    print(subClassId);
    print(typ);

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
            return;
        end

        if ( not isCollected) then
            print(" - Not Collected, Equip to learn");
        end
    else
        if ( item[4] < 600) then
            print(" - LEarned, Selling item now (<600 ilvl");
            -- safe_sell_item(bag, slot);
        end

    end

end

local function checkRareGear( itemLink, bag, slot, isBoe, isCollected, isSoulbound)
    local item = { GetItemInfo( itemLink)};
    local classId = item[12];
    local subClassId = item[13];

    if ( item[9] ~= "") then
        if ( not isCollected) then
            print(" - Not Collected, Equip to learn");
        end
    else
        if ( item[4] < 600) then
            print(" - LEarned, Selling item now (<600 ilvl");
            -- safe_sell_item(bag, slot);
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

    if (MerchantFrame:IsVisible()) then
        -- Merchant window is open, prepare to scan/sell items
    else
        -- scan for items that are not learned from mogging.
        for bag = 4, 4, 1 do
            for slot = 1, GetContainerNumSlots( bag), 1 do
                local itemLink = GetContainerItemLink( bag, slot);
                local itemId = GetContainerItemID( bag, slot);

                if ( itemLink ~= nil) then
                    local id = itemLink:match("item:(%d+)");
                    local color = itemLink:match("|c(%w+)|H");
                    local name, link, quality, itemLevel, reqLevel, class, subClass, maxStack, equipSlot, itemTexture = GetItemInfo( itemLink);

                    print("Bag [" .. slot .. "]: " .. id .. " [" .. color .. "]: " .. itemLink .. " [" .. class .. "]");
                    if ( subClass ~= nil) then
                        print("  SubClass [" .. subClass .. "]");
                    end

                    if ( quality == LE_ITEM_QUALITY_UNCOMMON) then
                        checkGreenGear(itemLink, bag, slot, boe, collected, sb);
                    elseif ( quality == LE_ITEM_QUALITY_RARE) then
                        print(" - Blue Quality");
                    end

                end

            end

        end

    end


end
