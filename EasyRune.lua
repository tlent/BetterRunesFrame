function RuneButtonOnClick(mouseButton, abilityID, equipmentSlot)
    C_Engraving.CastRune(abilityID)
    if mouseButton == "RightButton" then
        UseInventoryItem(equipmentSlot)
        for i = 1, STATICPOPUP_NUMDIALOGS do
            local popupFrame = _G["StaticPopup" .. i]
            if popupFrame.which == "REPLACE_ENCHANT" and popupFrame:IsVisible() then
                popupFrame.button1:Click()
                break
            end
        end
    end
end

function UpdateButtons()
    local rune_by_id = {}
    local categories = C_Engraving.GetRuneCategories(false, false)
    for _, category in ipairs(categories) do
        local runes = C_Engraving.GetRunesForCategory(category, true)
        for _, rune in ipairs(runes) do
            rune_by_id[rune.skillLineAbilityID] = rune
        end
    end

    local buttons = EngravingFrame.scrollFrame.buttons
    -- workaround for button 13 never being hidden but causing issues
    if C_Engraving.IsEquippedFilterEnabled() then
        local button = buttons[13]
        if button then
            button:Hide()
        end
    end

    for _, button in ipairs(buttons) do
        if button and button:IsShown() then
            local abilityID = button.skillLineAbilityID
            local equipmentSlot = rune_by_id[button.skillLineAbilityID].equipmentSlot
            button:SetScript("OnClick", function(_, mouseButton)
                RuneButtonOnClick(mouseButton, abilityID, equipmentSlot)
            end)
        end
    end
end

local function EventHandler(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "Blizzard_EngravingUI" then
        hooksecurefunc("EngravingFrame_UpdateRuneList", UpdateButtons)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", EventHandler)


