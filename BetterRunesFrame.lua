RUNE_BUTTON_HEIGHT = 40;
RUNE_HEADER_BUTTON_HEIGHT = 23;

function RuneButtonOnClick(mouseButton, abilityID, equipmentSlot)
    C_Engraving.CastRune(abilityID);
    if mouseButton == "RightButton" then
        UseInventoryItem(equipmentSlot);
        for i = 1, STATICPOPUP_NUMDIALOGS do
            local popupFrame = _G["StaticPopup" .. i];
            if popupFrame.which == "REPLACE_ENCHANT" and popupFrame:IsVisible() then
                popupFrame.button1:Click();
                break
            end
        end
    end
end

function UpdateButtons()
    local numHeaders = 0;
    local numRunes = 0;
    local scrollFrame = EngravingFrame.scrollFrame;
    local buttons = scrollFrame.buttons;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local currentOffset = 0;
    local currentHeader = 1;
    EngravingFrame_HideAllHeaders();
    local currentButton = 1;
    local categories = C_Engraving.GetRuneCategories(true, true);
    numHeaders = #categories;
    local rune_by_id = {};
    local prevRowStart = 1;
    for _, category in ipairs(categories) do
        if currentOffset < offset then
            currentOffset = currentOffset + 1;
        else
            local button = buttons[currentButton];
            if button then
                header = _G["EngravingFrameHeader"..currentHeader];
				if header then
                    if prevRowStart > 1 then
                        button:ClearAllPoints();
                        button:SetPoint("TOPLEFT", buttons[prevRowStart], "BOTTOMLEFT");
                    end
                    prevRowStart = currentButton;
                    header:ClearAllPoints();
					header:SetPoint("BOTTOMLEFT", button, 0 , 0);
                    header:Show();
					currentHeader = currentHeader + 1;
					currentButton = currentButton + 1;
				end
            end
        end
        local runes = C_Engraving.GetRunesForCategory(category, true);
        numRunes = numRunes + #runes;
        for runeIndex, rune in ipairs(runes) do
            rune_by_id[rune.skillLineAbilityID] = rune;
            if currentOffset < offset then
				currentOffset = currentOffset + 1;
			else
				local button = buttons[currentButton];
				if button then
                    local abilityID = button.skillLineAbilityID;
                    local equipmentSlot = rune_by_id[abilityID].equipmentSlot;
                    button:SetScript("OnClick", function(_, mouseButton)
                        RuneButtonOnClick(mouseButton, abilityID, equipmentSlot);
                    end);
                    button.name:Hide();
                    button.typeName:Hide();
                    button:SetWidth(RUNE_BUTTON_HEIGHT);
                    local prevButton = buttons[currentButton - 1];
                    button:ClearAllPoints();
                    if runeIndex % 4 == 1 then
                        button:SetPoint("TOPLEFT", buttons[prevRowStart], "BOTTOMLEFT");
                        prevRowStart = currentButton;
                    else
                        button:SetPoint("LEFT", prevButton, "RIGHT");
                    end
                    button:Show();
					currentButton = currentButton + 1;
				end
			end
        end
    end
    while currentButton <= #buttons do
        local button = buttons[currentButton];
        button:Hide();
        currentButton = currentButton + 1;
    end
    local totalHeight = math.floor(numRunes / 4) * RUNE_BUTTON_HEIGHT;
    totalHeight = totalHeight + (numHeaders * RUNE_HEADER_BUTTON_HEIGHT);
    HybridScrollFrame_Update(scrollFrame, totalHeight+10, 348);
end

local function AddMoreButtons()
    local scrollFrame = EngravingFrame.scrollFrame;
    local buttons = scrollFrame.buttons;
    local parentName = scrollFrame:GetName();
    local buttonName = parentName and (parentName .. "Button") or nil;
    local point = "TOP";
    local relativePoint = "BOTTOM";

    for i = #buttons, 15 do
        local button = CreateFrame("BUTTON", buttonName and (buttonName..1) or nil, scrollFrame.scrollChild, "RuneSpellButtonTemplate");
        tinsert(buttons, button);
    end
end

local function EventHandler(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "Blizzard_EngravingUI" then
        AddMoreButtons()
        hooksecurefunc("EngravingFrame_UpdateRuneList", UpdateButtons);
    end
end

local frame = CreateFrame("Frame");
frame:RegisterEvent("ADDON_LOADED");
frame:SetScript("OnEvent", EventHandler);


