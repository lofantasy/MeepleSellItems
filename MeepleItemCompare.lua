local GlobalAddonName = ...

MeepleSellItems = {};

local isTooltipDone;
local tooltipDetails = {};
local charDetails = {};

-- /run SocketInventoryITem(16);


local inspectScantip = CreateFrame("GameTooltip", GlobalAddonName .. "ScanningTooltip", nil, "GameTooltipTemplate")
inspectScantip:SetOwner(UIParent, "ANCHOR_NONE")

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

            if (rightText == nil) then
                rightText = "";
            end

            print(" : " .. leftText .. " | " .. rightText);
        end
    end
end

local function scanEquippedTooltip(itemLink, compare, hasStat)
    inspectScantip:SetHyperlink(itemLink);

    for k = 1, inspectScantip:NumLines() do
       -- print(": " ..  _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText());

        if (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^(%d+) Armor")) then
            compare["Armor"] = _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^(%d+) Armor");
            hasStat["Armor"] = 1;

        elseif (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^+(%d+) Intellect")) then
            compare["Intellect"] = _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("+(%d+) Intellect");
            hasStat["Intellect"] = 1;

        elseif (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^+(%d+) Strength")) then
            compare["Strength"] = _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("+(%d+) Strength");
            hasStat["Strength"] = 1;

        elseif (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^+(%d+) Agility$")) then
            compare["Agility"] = _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("+(%d+) Agility$");
            hasStat["Agility"] = 1;

        elseif (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^+(%d+) Stamina")) then
            -- charDetails["Stamina"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Stamina");
            compare["Stamina"] = _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("+(%d+) Stamina");
            hasStat["Stamina"] = 1;

        elseif (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^+(%d+) Critical Strike")) then
            -- charDetails["Critical Strike"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Critical Strike");
            compare["Critical Strike"] = _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("+(%d+) Critical Strike");
            hasStat["Critical Strike"] = 1;

        elseif (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^+(%d+) Haste")) then
            -- charDetails["Haste"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Haste");
            compare["Haste"] = _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("+(%d+) Haste");
            hasStat["Haste"] = 1;

        elseif (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^+(%d+) Mastery")) then
            -- charDetails["Mastery"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Mastery");
            compare["Mastery"] = _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("+(%d+) Mastery");
            hasStat["Mastery"] = 1;

        elseif (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^+(%d+) Versatility")) then
            -- charDetails["Versatility"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Versatility");
            compare["Versatility"] = _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("+(%d+) Versatility");
            hasStat["Versatility"] = 1;

        elseif (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^+(%d+) Avoidance")) then
            -- charDetails["Avoidance"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Avoidance");
            compare["Avoidance"] = _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("+(%d+) Avoidance");
            hasStat["Avoidance"] = 1;

        elseif (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^+(%d+) Speed")) then
            -- charDetails["Speed"] = _G[GlobalAddonName.."ScanningTooltipTextLeft"..k]:GetText():match("+(%d+) Speed");
            compare["Speed"] = _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("+(%d+) Speed");
            hasStat["Speed"] = 1;

        elseif (_G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText():match("^<Shift Right Click to Socket>")) then
            compare["Socket"] = 1;
            hasStat["Socket"] = 1;
            print("Matched!");

        else
            -- print("UnParsed: " .. _G[GlobalAddonName .. "ScanningTooltipTextLeft" .. k]:GetText());
        end
    end

    inspectScantip:ClearLines();
end

-- TODO: try to join parseTooltip & scanEquippedTooltip to be a single setup instead of two different functions

local function parseTooltip(tooltip, compare, hasStat)
    local leftText, rightText;

    if (tooltip ~= nil) then
        for k = 1, tooltip:NumLines() do
            leftText = _G["GameTooltipTextLeft" .. k]:GetText();
            rightText = _G["GameTooltipTextRight" .. k]:GetText();

            if (leftText:match("^(%d+) Armor")) then
                compare["Armor"] = leftText:match("^(%d+) Armor");
                hasStat["Armor"] = 1;

            elseif (leftText:match("+(%d+) Strength")) then
                -- tooltipDetails["Strength"] = leftText:match("^+(%d+) Strength");
                compare["Strength"] = leftText:match("+(%d+) Strength");
                hasStat["Strength"] = 1;

            elseif (leftText:match("+(%d+) Intellect")) then
                -- tooltipDetails["Intellect"] = leftText:match("^+(%d+) Intellect");
                compare["Intellect"] = leftText:match("+(%d+) Intellect");
                hasStat["Intellect"] = 1;

            elseif (leftText:match("+(%d+) Agility")) then
                -- tooltipDetails["Agility"] = leftText:match("^+(%d+) Agility");
                compare["Agility"] = leftText:match("+(%d+) Agility");
                hasStat["Agility"] = 1;

            elseif (leftText:match("^+(%d+) Stamina")) then
                -- tooltipDetails["Stamina"] = leftText:match("+(%d+) Stamina");
                compare["Stamina"] = leftText:match("+(%d+) Stamina");
                hasStat["Stamina"] = 1;

            elseif (leftText:match("^+(%d+) Haste")) then
                -- tooltipDetails["Haste"] = leftText:match("+(%d+) Haste");
                compare["Haste"] = leftText:match("+(%d+) Haste");
                hasStat["Haste"] = 1;

            elseif (leftText:match("^+(%d+) Mastery")) then
                -- tooltipDetails["Mastery"] = leftText:match("+(%d+) Mastery");
                compare["Mastery"] = leftText:match("+(%d+) Mastery");
                hasStat["Mastery"] = 1;

            elseif (leftText:match("^+(%d+) Critical Strike")) then
                -- tooltipDetails["Critical Strike"] = leftText:match("+(%d+) Critical Strike");
                compare["Critical Strike"] = leftText:match("+(%d+) Critical Strike");
                hasStat["Critical Strike"] = 1;

            elseif (leftText:match("^+(%d+) Versatility")) then
                -- tooltipDetails["Critical Strike"] = leftText:match("+(%d+) Versatility");
                compare["Versatility"] = leftText:match("+(%d+) Versatility");
                hasStat["Versatility"] = 1;

            elseif (leftText:match("^+(%d+) Avoidance")) then
                -- tooltipDetails["Critical Strike"] = leftText:match("+(%d+) Avoidance");
                compare["Avoidance"] = leftText:match("+(%d+) Avoidance");
                hasStat["Avoidance"] = 1;

            elseif (leftText:match("^+(%d+) Speed")) then
                -- tooltipDetails["Critical Strike"] = leftText:match("+(%d+) Speed");
                compare["Speed"] = leftText:match("+(%d+) Speed");
                hasStat["Speed"] = 1;

            elseif (leftText:match("^<Shift Right Click to Socket>")) then
                compare["Socket"] = 1;
                hasStat["Socket"] = 1;

            else
                -- print("UnParsed: " .. leftText);
            end
        end

        -- TODO: since some itesm can / do have str|int, str|Agi, int|agi, ect. blank out the one depending on the class currently being used.
        -- aka, DK would use str, blank out int/agi.
    end
end

local slots = {
    ["INVTYPE_AMMO"] = 0,
    ["INVTYPE_HEAD"] = 1,
    ["INVTYPE_NECK"] = 2,
    ["INVTYPE_SHOULDER"] = 3,
    ["INVTYPE_BODY"] = 4,
    ["INVTYPE_CHEST"] = 5,
    ["INVTYPE_ROBE"] = 5,
    ["INVTYPE_WAIST"] = 6,
    ["INVTYPE_LEGS"] = 7,
    ["INVTYPE_FEET"] = 8,
    ["INVTYPE_WRIST"] = 9,
    ["INVTYPE_HAND"] = 10,
    ["INVTYPE_FINGER1"] = 11,
    ["INVTYPE_FINGER"] = 11,
    ["INVTYPE_FINGER2"] = 12,
    ["INVTYPE_TRINKET"] = 13,
    ["INVTYPE_TRINKET1"] = 13,
    ["INVTYPE_TRINKET2"] = 14,
    ["INVTYPE_BACK"] = 15,
    ["INVTYPE_CLOAK"] = 15,
    ["INVTYPE_MAINHAND"] = 16,
    ["INVTYPE_2HWEAPON"] = 16,
    ["INVTYPE_WEAPON"] = 16,
    ["INVTYPE_OFFHAND"] = 17,
    ["INVTYPE_RANGED"] = 18,
    ["INVTYPE_TABARD"] = 19,
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

 ]] --

local function compareStats(stat, compare, hasStat, tooltip, statValue, coefficient)
    local equippedStat = 0;
    local itemStat = 0;

    if (compare["item"][stat] ~= nil) then
        itemStat = compare["item"][stat] -- tooltipDetails[stat];
    end

    if (compare["equipped"][stat] ~= nil) then
        equippedStat = compare["equipped"][stat] -- charDetails[stat];
    end

    local val = ((equippedStat - itemStat) * -1);

    if (hasStat["item"][stat] == 1 or hasStat["equipped"][stat] == 1) then
        local _r, _g, _b, _prefix, _val, _change, _colour;

        if (val < 0) then
            _prefix = "-";
            _val = ( val * -1);
            _r = 0.77
            _g = 0.12
            _b = 0.23
            _colour = "C41F3B"
        elseif (val == 0) then
            _prefix = " "
            _val = val;
            _r = 1.00
            _g = 1.00
            _b = 1.00
            _colour = "FFFFFF";
        else
            _prefix = "+"
            _val = val;
            _r = 0.20
            _g = 1.00
            _b = 0.50
            _colour = "00FF00"
        end

        if (statValue > 0) then
            if (coefficient > 0) then
                _change = ((val * coefficient) / statValue)
            else
                _change = (val / statValue);
            end

            if (_change < 0) then
                _change = ( _change * -1);
            end

            local leftText = "|cff" .. _colour .. format("%2s%.0f %s", _prefix, _val, stat);
            local rightText = "|cFF" .. _colour .. format("%s%.2f%%", _prefix, _change);

            tooltip:AddDoubleLine(leftText, rightText);
        else
            tooltip:AddLine(format("%2s%.0f %s", _prefix, _val, stat), _r, _g, _b);
        end

    end

end

local function compareStats__old(stat, compare, hasStat)
    local equippedStat = 0;
    local itemStat = 0;

    if (compare["item"][stat] ~= nil) then
        itemStat = compare["item"][stat] -- tooltipDetails[stat];
    end

    if (compare["equipped"][stat] ~= nil) then
        equippedStat = compare["equipped"][stat] -- charDetails[stat];
    end

    --[[
        if equipped has stat, it must be on the other end. . then again. if item ahs it. it do to. heh. dammit.

        if item || equipped has it. calc the results

        return true, ((equip .. ) * -1);

        the other end, local needed, val = compareStats(...);
            if needed == true, show stat.
     ]] --

    print("  EquippeD: " .. equippedStat);
    print("  itemStat: " .. itemStat);
    print("  " .. stat .. ": " .. ((equippedStat - itemStat) * -1));

    local val = ((equippedStat - itemStat) * -1);

    if (hasStat["item"][stat] == 1 or hasStat["equipped"][stat] == 1) then
        if (val < 0) then
            return true, "", val, 0.77, 0.12, 0.23;
        elseif (val == 0) then
            return true, " ", val, 1, 1, 1;
        else
            return true, "+", val, 0.2, 1.0, 0.0;
        end
    else
        return false, 0
    end


    -- return ((equippedStat - itemStat) * -1);
end

local function OnGameSetItem(tooltip, bag, slot)
    if (not isTooltipDone) and tooltip then
        isTooltipDone = true;

        local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)

        if (not readable) then -- see if this works or not. else 'readable ~= nil'
        print(bag .. ", " .. slot);
        local itemLink = GetContainerItemLink(bag, slot);
        local charItem = nil; -- TODO: get the currently equipped item from the same slot to compare against.

        if (itemLink ~= nil) then
            local itemDetails = { GetItemInfo(itemLink) };

            if (itemDetails[6] == "Armor" or itemDetails[6] == "Weapon") then
                tooltip:ClearLines();
                tooltip:SetOwner(UIParent, "ANCHOR_NONE")
                tooltip:SetHyperlink(itemLink);

                --[[ re-write the tooltip. just for giggles? ]]--
--                tooltip:ClearLines();
--                for k = 1, tooltip:NumLines() do
--                    leftText = _G["GameTooltipTextLeft" .. k]:GetText();
--                    rightText = _G["GameTooltipTextRight" .. k]:GetText();
--
--                    tooltip:AddLine("1");
--                end
                --[[ re-write the tooltip. just for giggles? ]]--

                tooltip:AddLine(" ");
                tooltip:AddLine("Stat changes:", 1, 1, 1); -- see what the 1, 1, 1 do. if i remember it was making the text gray.

                local equipSlot = itemDetails[9];

                charItem = GetInventoryItemLink("player", slots[equipSlot]);


                print("EquipSlot: " .. equipSlot);
                print(charItem);

                local compare = {
                    ["equipped"] = {
                        ["Armor"] = 0,
                        ["Strength"] = 0,
                        ["Agility"] = 0,
                        ["Intellect"] = 0,
                        ["Stamina"] = 0,
                        ["Critical STrike"] = 0,
                        ["Haste"] = 0,
                        ["Versatility"] = 0,
                        ["Mastery"] = 0,
                        ["Avoidance"] = 0,
                        ["Speed"] = 0,
                        ["Socket"] = 0
                    },
                    ["item"] = {
                        ["Armor"] = 0,
                        ["Strength"] = 0,
                        ["Agility"] = 0,
                        ["Intellect"] = 0,
                        ["Stamina"] = 0,
                        ["Critical STrike"] = 0,
                        ["Haste"] = 0,
                        ["Versatility"] = 0,
                        ["Mastery"] = 0,
                        ["Avoidance"] = 0,
                        ["Speed"] = 0,
                        ["Socket"] = 0
                    }
                }

                local hasStat = {
                    ["equipped"] = {
                        ["Armor"] = 0,
                        ["Strength"] = 0,
                        ["Agility"] = 0,
                        ["Intellect"] = 0,
                        ["Stamina"] = 0,
                        ["Critical STrike"] = 0,
                        ["Haste"] = 0,
                        ["Versatility"] = 0,
                        ["Mastery"] = 0,
                        ["Avoidance"] = 0,
                        ["Speed"] = 0,
                        ["Socket"] = 0
                    },
                    ["item"] = {
                        ["Armor"] = 0,
                        ["Strength"] = 0,
                        ["Agility"] = 0,
                        ["Intellect"] = 0,
                        ["Stamina"] = 0,
                        ["Critical STrike"] = 0,
                        ["Haste"] = 0,
                        ["Versatility"] = 0,
                        ["Mastery"] = 0,
                        ["Avoidance"] = 0,
                        ["Speed"] = 0,
                        ["Socket"] = 0
                    }
                }

                parseTooltip(tooltip, compare["item"], hasStat["item"]);
                scanEquippedTooltip(charItem, compare["equipped"], hasStat["equipped"]);

                -- tooltip:AddLine("- Strength: +125", 1, 1, 1); -- same with the 1, 1, 1, also see if this can be used to make the text green or red for +/-
                -- pretty much go thru each stat on both equipped and mouseovered item.
                -- - if the item is not found on

                -- Mastery: val, coefficient = getMasteryEffect() (DK  : 1.50)
                -- Mastery: val, coefficient = getMasteryEffect() (mage: 0.75)
                --      - (1946 * 0.75) / 110 = 13.27
                -- Mastery: 110 : lvl 100: 1946 [+13.27] :
                --   Haste: 100 : lvl 100: 1476 [+14.76] : Haste / 100
                --    Crit: 110 : lvl 100: 1625 [+14.77] : Crit / 110
                --    Vers: 130 : lvl 100:  356 [+2.74/+1.37] : ( vars / 130 && vars / 260 )

                -- displaySpeed = format("%.2f", speed);

                -- local mastery, coefficient = GetMasteryEffect(); | this gives you back your current Sheet Mastery.
                local mastery, coefficient = GetMasteryEffect();

                compareStats("Armor", compare, hasStat, tooltip, 0, 0);
                compareStats("Strength", compare, hasStat, tooltip, 0, 0);
                compareStats("Intellect", compare, hasStat, tooltip, 0, 0);
                compareStats("Agility", compare, hasStat, tooltip, 0, 0);
                compareStats("Critical Strike", compare, hasStat, tooltip, 110, 0);
                compareStats("Haste", compare, hasStat, tooltip, 100, 0);
                compareStats("Versatility", compare, hasStat, tooltip, 130, 0);
                compareStats("Mastery", compare, hasStat, tooltip, 110, coefficient);
                compareStats("Avoidance", compare, hasStat, tooltip, 0, 0);
                compareStats("Speed", compare, hasStat, tooltip, 0, 0);
                compareStats("Socket", compare, hasStat, tooltip, 0, 0);


                -- tooltip:AddDoubleLine("LEft", "Right", 1, 1, 1, 0.2, 0.3, 0.4)
                -- Socket?
                -- Leech?
                -- DW vs 2H
                -- Handle trinkets better. some reason its showing Str / haste / mastery with values from HELM

                tooltip:Show();
            end
        end
        end
    end
end

local function addToTooltip(tooltip, itemLink)
    local itemInfo = GetItemInfo(itemLink)

    if not itemInfo then
        MeepleSellItems.cachedItemLink = nil;
        MeepleSellItems.cachedTooltipText = nil;
        return;
    end

    -- OnGameSetItem()

    local itemType = select(6, GetItemInfo(itemLink));

    if ( itemType == "Armor" or itemType == "Weapon") then
        local equipSlot = select(9, GetItemInfo(itemLink));
        local charItem = GetInventoryItemLink("player", slots[equipSlot]);
        local _, coefficient = GetMasteryEffect();

        tooltip:AddLine(" ");
        tooltip:AddLine("Stat changes: ", 1, 1, 1);

        local compare = {
            ["equipped"] = {
                ["Armor"] = 0,
                ["Strength"] = 0,
                ["Agility"] = 0,
                ["Intellect"] = 0,
                ["Stamina"] = 0,
                ["Critical STrike"] = 0,
                ["Haste"] = 0,
                ["Versatility"] = 0,
                ["Mastery"] = 0,
                ["Avoidance"] = 0,
                ["Speed"] = 0,
                ["Socket"] = 0
            },
            ["item"] = {
                ["Armor"] = 0,
                ["Strength"] = 0,
                ["Agility"] = 0,
                ["Intellect"] = 0,
                ["Stamina"] = 0,
                ["Critical STrike"] = 0,
                ["Haste"] = 0,
                ["Versatility"] = 0,
                ["Mastery"] = 0,
                ["Avoidance"] = 0,
                ["Speed"] = 0,
                ["Socket"] = 0
            }
        }

        local hasStat = {
            ["equipped"] = {
                ["Armor"] = 0,
                ["Strength"] = 0,
                ["Agility"] = 0,
                ["Intellect"] = 0,
                ["Stamina"] = 0,
                ["Critical STrike"] = 0,
                ["Haste"] = 0,
                ["Versatility"] = 0,
                ["Mastery"] = 0,
                ["Avoidance"] = 0,
                ["Speed"] = 0,
                ["Socket"] = 0
            },
            ["item"] = {
                ["Armor"] = 0,
                ["Strength"] = 0,
                ["Agility"] = 0,
                ["Intellect"] = 0,
                ["Stamina"] = 0,
                ["Critical STrike"] = 0,
                ["Haste"] = 0,
                ["Versatility"] = 0,
                ["Mastery"] = 0,
                ["Avoidance"] = 0,
                ["Speed"] = 0,
                ["Socket"] = 0
            }
        }

        parseTooltip(tooltip, compare["item"], hasStat["item"]);
        scanEquippedTooltip(charItem, compare["equipped"], hasStat["equipped"]);

        compareStats("Armor", compare, hasStat, tooltip, 0, 0);
        compareStats("Strength", compare, hasStat, tooltip, 0, 0);
        compareStats("Intellect", compare, hasStat, tooltip, 0, 0);
        compareStats("Agility", compare, hasStat, tooltip, 0, 0);
        compareStats("Critical Strike", compare, hasStat, tooltip, 110, 0);
        compareStats("Haste", compare, hasStat, tooltip, 100, 0);
        compareStats("Versatility", compare, hasStat, tooltip, 130, 0);
        compareStats("Mastery", compare, hasStat, tooltip, 110, coefficient);
        compareStats("Avoidance", compare, hasStat, tooltip, 0, 0);
        compareStats("Speed", compare, hasStat, tooltip, 0, 0);
        compareStats("Socket", compare, hasStat, tooltip, 0, 0);

        local bonusesNum, bonusesString = itemLink:match("item:%d+:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:[0-9%-]*:([0-9%-]*):([0-9:]*)");
        -- thought above, knowing what bonus id is for socket, i could use that. but i am not sure its needed. thou +200 gems are kidna nice
        -- print(bonusesNum .. ", " .. bonusesString);

        tooltip:Show();
    end

end

local function meepleAttackItemTooltip(self)
    -- Hook for normal tooltips.
    MeepleSellItems.tooltip = self
    local link = select(2, self:GetItem())
    if link then
        addToTooltip(CanIMogIt.tooltip, link)
    end
end

local function onSetHyperlink(self, link)
    -- Hook for Hyperlinked tooltips.
    print("onSetHyperink(*)");
    MeepleSellItems.tooltip = self
    local type, id = string.match(link, "^(%a+):(%d+)")
    if not type or not id then return end
    if type == "item" then
        print("Hyperlink?");
        addToTooltip(MeepleSellItems.tooltip, link)
    end
end

function init_tooltips()

    GameTooltip:HookScript("OnTooltipSetItem", meepleAttackItemTooltip);
    ItemRefTooltip:HookScript("OnTooltipSetItem",meepleAttackItemTooltip);
    ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
    ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
    ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
    ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)

    -- GameTooltip:HookScript("OnShow", OnGameTooltipShow);

    --    GameTooltip:HookScript("OnTooltipCleared", OnGameTooltipCleared);
    --    hooksecurefunc(GameTooltip, "SetBagItem", function(self, bag, slot) OnGameSetItem(self, bag, slot); end)
    hooksecurefunc(GameTooltip, "SetHyperlink", onSetHyperlink);

end
