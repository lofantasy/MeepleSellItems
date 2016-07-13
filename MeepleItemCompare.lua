
local GlobalAddonName = ...

local isTooltipDone;
local tooltipDetails = {};
local charDetails = {};


local inspectScantip = CreateFrame("GameTooltip", GlobalAddonName.."ScanningTooltip", nil, "GameTooltipTemplate")
inspectScantip:SetOwner(UIParent, "ANCHOR_NONE")

local yellow = "|cfffffdd0"
local yellowR = 255 / 255
local yellowG = 253 / 255
local yellowB = 208 / 255


local function OnGameTooltipCleared()
    isTooltipDone = nil;
end

local function OnGameTooltipShow(tooltip, ...)
    print("OnGameTooltipShow");
    print(tooltip:GetName());

    local _name, _link = tooltip:GetItem();

    local leftText, rightText;

    if (_name ~= nil) then
        for k = 1, tooltip:NumLines() do
            print("K: " .. k);
            leftText = _G["GameTooltipTextLeft" .. k]:GetText();
            rightText = _G["GameTooltipTextRight" .. k]:GetText();

            if ( rightText == nil) then
                rightText = "";
            end

            print(" : " .. leftText .. " | " .. rightText);

        end
    end


end

local function scanEquippedTooltip(itemLink)
    inspectScantip:SetHyperlink(itemLink);

    for k = 1, inspectScantip:NumLines() do
        print(_G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText());

        if (_G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Intellect")) then
            charDetails["Intellect"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Intellect");

        elseif (_G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Stamina")) then
            charDetails["Stamina"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Stamina");

        elseif (_G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Critical Strike")) then
            charDetails["Critical Strike"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Critical Strike");

        elseif (_G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Haste")) then
            charDetails["Haste"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Haste");

        elseif (_G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Mastery")) then
            charDetails["Mastery"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Mastery");

        end

    end

    inspectScantip:ClearLines();

end


local function parseTooltip(tooltip)
    local leftText, rightText;

    print("Hello ");
    print(tooltip:GetName());
    if (tooltip ~= nil) then
        for k = 1, tooltip:NumLines() do
            leftText = _G["GameTooltipTextLeft" .. k]:GetText();
            rightText = _G["GameTooltipTextRight" .. k]:GetText();

            if (leftText:match("+(%d+) Strength")) then
                tooltipDetails["Strength"] = leftText:match("+(%d+) Strength");

            elseif (leftText:match("+(%d+) Intellect")) then
                tooltipDetails["Intellect"] = leftText:match("+(%d+) Intellect");

            elseif (leftText:match("+(%d+) Stamina")) then
                tooltipDetails["Stamina"] = leftText:match("+(%d+) Stamina");

            elseif (leftText:match("+(%d+) Haste")) then
                tooltipDetails["Haste"] = leftText:match("+(%d+) Haste");

            elseif (leftText:match("+(%d+) Mastery")) then
                tooltipDetails["Mastery"] = leftText:match("+(%d+) Mastery");

            elseif (leftText:match("+(%d+) Critical Strike")) then
                tooltipDetails["Critical Strike"] = leftText:match("+(%d+) Critical Strike");

            else
                print("UnParsed: " .. leftText);
            end



        end
    end

end

local slots = {
    ["INVTYPE_AMMO"]		= 0,
    ["INVTYPE_HEAD"] 		= 1,
    ["INVTYPE_NECK"]		= 2,
    ["INVTYPE_SHOULDER"]	= 3,
    ["INVTYPE_BODY"]		= 4,
    ["INVTYPE_CHEST"]		= 5,
    ["INVTYPE_ROBE"]		= 5,
    ["INVTYPE_WAIST"]		= 6,
    ["INVTYPE_LEGS"]		= 7,
    ["INVTYPE_FEET"]		= 8,
    ["INVTYPE_WRIST"]		= 9,
    ["INVTYPE_HAND"]		= 10,
    ["INVTYPE_FINGER1"]		= 11,
    ["INVTYPE_FINGER"]		= 11,
    ["INVTYPE_FINGER2"]		= 12,
    ["INVTYPE_TRINKET1"]	= 13,
    ["INVTYPE_TRINKET2"]	= 14,
    ["INVTYPE_BACK"]		= 15,
    ["INVTYPE_MAINHAND"]	= 16,
    ["INVTYPE_2HWEAPON"]	= 16,
    ["INVTYPE_WEAPON"]	    = 16,

    ["INVTYPE_OFFHAND"]		= 17,
    ["INVTYPE_RANGED"]		= 18,
    ["INVTYPE_TABARD"]		= 19,
}

--[[
itemDetails = { GetItemInfo(itemLink) }

  1: Name
  2: link
  3: quality
  4: itemLevel
  5: reqLevel
  6: class
  7: subClass
  8: maxStack
  9: equipSlot
 10: itemTexture

 ]]--

local function compareStats(stat)
    local equippedStat = 0;
    local itemStat = 0;

    if ( tooltipDetails[stat] ~= nil) then
        itemStat = tooltipDetails[stat];
    end

    if ( charDetails[stat] ~= nil) then
        equippedStat = charDetails[stat];
    end

    print("EquippeD: " .. equippedStat);
    print("itemStat: " .. itemStat);
    print(stat .. ": " .. ((equippedStat - itemStat) * -1));
    return ((equippedStat - itemStat) * -1);
end

local function OnGameSetItem( tooltip, bag, slot)
    if ( not isTooltipDone) and tooltip then
        isTooltipDone = true;

        local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)

        if ( not readable) then -- see if this works or not. else 'readable ~= nil'
            print(bag .. ", " .. slot);
            local itemLink = GetContainerItemLink( bag, slot);
            local charItem = nil; -- TODO: get the currently equipped item from the same slot to compare against.

            if ( itemLink ~= nil) then
                local itemDetails = {GetItemInfo(itemLink)};

                if ( itemDetails[6] == "Armor" or itemDetails[6] == "Weapon") then
                    tooltip:ClearLines();
                    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
                    tooltip:SetHyperlink(itemLink);

                    tooltip:AddLine(" ");
                    tooltip:AddLine("Stat changes:", 1, 1, 1); -- see what the 1, 1, 1 do. if i remember it was making the text gray.

                    local equipSlot = itemDetails[9];

                    charItem = GetInventoryItemLink("player", slots[equipSlot]);

                    parseTooltip(tooltip);
                    scanEquippedTooltip(charItem);

                    print("EquipSlot: " .. equipSlot);
                    print( charItem);

--                    if ( tooltipDetails["Intellect"] ~= nil and charDetails["Intellect"] ~= nil) then
--                        local intDiff = (charDetails["Intellect"] - tooltipDetails["Intellect"]) * -1;
--                        tooltip:AddLine("- Intellect: " .. intDiff, 1, 1, 1);
--
--
--                    end
--
--                    if ( tooltipDetails["Stamina"] ~= nil and charDetails["Stamina"] ~= nil) then
--                        print("woo?");
--                        local intDiff = (charDetails["Stamina"] - tooltipDetails["Stamina"]) * -1;
--                        if (intDiff < 0) then
--                            -- tooltip:AddLine("- Stamina: |cfffffdd0" .. intDiff .. "|r");
--
--                        else
--                            tooltip:AddLine("- Stamina: " .. intDiff, 1, 1, 1);
--                        end
--                    end
                    tooltip:AddLine("- Intellect: " .. compareStats("Intellect"), 0.77, 0.12, 0.23);
                    tooltip:AddLine("- Stamina: " .. compareStats("Stamina"), 0.77, 0.12, 0.23);

                    tooltip:AddLine("- Critical Strike: " .. compareStats("Critical Strike"));
                    tooltip:AddLine("- Mastery: " .. compareStats("Mastery"));
                    tooltip:AddLine("- Haste: " .. compareStats("Haste"));


                    -- tooltip:AddLine("- Strength: +125", 1, 1, 1); -- same with the 1, 1, 1, also see if this can be used to make the text green or red for +/-
                    -- pretty much go thru each stat on both equipped and mouseovered item.
                    -- - if the item is not found on


                    tooltip:Show();

                end

            end

        end

    end

end


function init_tooltips()

    GameTooltip:HookScript("OnTooltipCleared", OnGameTooltipCleared);
    -- GameTooltip:HookScript("OnShow", OnGameTooltipShow);
    hooksecurefunc(GameTooltip, "SetBagItem", function( self, bag, slot) OnGameSetItem(self, bag, slot); end)

end
