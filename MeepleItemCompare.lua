
local isTooltipDone;
local tooltipDetails = {};

local function OnGameTooltipCleared()
    isTooltipDone = nil;
end

local function OnGameTooltipShow(tooltip, ...)
    print("OnGameTooltipShow");
    print(tooltip:GetName());
    local leftText, rightText;

    for k = 1, tooltip:NumLines() do
        print("K: " .. k);
        leftText = _G["GameToolTipTextLeft" .. k]:GetText();
        rightText = _G["GameToolTipTextRight" .. k]:GetText();

        if ( rightText == nil) then
            rightText = "";
        end

        print(" : " .. leftText " | " .. rightText);

    end

end

local function parseTooltip(tooltip)
    local leftText, rightText;

    if (toolip ~= nil) then
        for k = 1, tooltip:NumLines() do
            leftText = _G["GameToolTipTextLeft" .. k]:GetText();
            rightText = _G["GameToolTipTextRight" .. k]:GetText();

            if (leftText:match("+(%d+) Strength")) then
                tooltipDetails["Strength"] = leftText:match("+(%d+) Strength");

            end

        end
    end

end

local function OnGameSetItem( tooltip, bag, slot)
    if ( not isTooltipDone) and tooltip then
        isTooltipDone = true;

        local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)

        if ( not readable) then -- see if this works or not. else 'readable ~= nil'
            tooltip:AddLine("Stat changes:", 1, 1, 1); -- see what the 1, 1, 1 do. if i remember it was making the text gray.

            local itemLink = GetContainerItemLink( bag, slot);
            local charItem = nil; -- TODO: get the currently equipped item from the same slot to compare against.

            if ( itemLink ~= nil) then
                local _, _, _, _, _, _, _, _, equipSlot, _ = GetItemInfo(itemLink)
                -- charItem = getEquippedItem via equipSlot some how.

                tooltip:AddLine("- Strength: +125", 1, 1, 1); -- same with the 1, 1, 1, also see if this can be used to make the text green or red for +/-
                -- pretty much go thru each stat on both equipped and mouseovered item.
                -- - if the item is not found on
            end

        end

    end

end

function init_tooltips()

    GameTooltip:HookScript("OnTooltipCleared", OnGameTooltipCleared);
    GameTooltip:HookScript("OnShow", OnGameTooltipShow);
    hooksecurefunc(Gametooltip, "SetBagItem", function( self, bag, slot) OnGameSetItem(self, bag, slot); end)

end