local _, Cell = ...
local L = Cell.L

-- Polyfills for WotLK 3.3.5a

-- C_Timer
if not C_Timer then
    C_Timer = {}
    local Ticker = {}
    Ticker.__index = Ticker

    function Ticker:Cancel()
        self._cancelled = true
    end

    function Ticker:IsCancelled()
        return self._cancelled
    end

    local function CreateTimer(duration, callback, isTicker)
        local timer = setmetatable({}, Ticker)
        local total = 0
        local frame = CreateFrame("Frame")
        frame:SetScript("OnUpdate", function(self, elapsed)
            if timer:IsCancelled() then
                self:SetScript("OnUpdate", nil)
                return
            end
            total = total + elapsed
            if total >= duration then
                if isTicker then
                    total = 0
                    callback(timer)
                else
                    self:SetScript("OnUpdate", nil)
                    callback()
                end
            end
        end)
        return timer
    end

    function C_Timer.After(duration, callback)
        CreateTimer(duration, callback, false)
    end

    function C_Timer.NewTimer(duration, callback)
        return CreateTimer(duration, callback, false)
    end

    function C_Timer.NewTicker(duration, callback, iterations)
        -- iterations not fully supported in this simple polyfill, assuming infinite for now or handled by callback
        return CreateTimer(duration, callback, true)
    end
end

-- C_Spell
if not C_Spell then
    C_Spell = {}
    function C_Spell.GetSpellInfo(spellId)
        return GetSpellInfo(spellId)
    end
    function C_Spell.GetSpellTexture(spellId)
        return GetSpellTexture(spellId)
    end
    function C_Spell.IsSpellInRange(spellId, unit)
        return IsSpellInRange(GetSpellInfo(spellId), unit)
    end
    function C_Spell.GetSpellCooldown(spellId)
        return GetSpellCooldown(spellId)
    end
    function C_Spell.GetSpellLink(spellId)
        return GetSpellLink(spellId)
    end
    function C_Spell.GetSpellCharges(spellId)
        -- WotLK doesn't have spell charge system (added in Legion)
        -- Return nil to indicate no charges available
        -- Retail format: currentCharges, maxCharges, cooldownStartTime, cooldownDuration, chargeModRate
        return nil
    end
end

-- C_Item
if not C_Item then
    C_Item = {}
    function C_Item.IsItemInRange(itemId, unit)
        return IsItemInRange(itemId, unit)
    end
end

-- C_UnitAuras
if not C_UnitAuras then
    C_UnitAuras = {}
    function C_UnitAuras.GetAuraDataBySlot(unit, slot)
        -- This is a simplified mapping. Real C_UnitAuras returns a table.
        local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, slot)
        if name then
            return {
                name = name,
                icon = icon,
                count = count,
                debuffType = debuffType,
                duration = duration,
                expirationTime = expirationTime,
                sourceUnit = unitCaster,
                isStealable = isStealable,
                spellId = spellId,
                points = {} -- Placeholder
            }
        end
        return nil
    end

    function C_UnitAuras.GetAuraDataBySpellName(unit, spellName, filter)
         local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, spellName, nil, filter)
         if name then
            return {
                name = name,
                icon = icon,
                count = count,
                debuffType = debuffType,
                duration = duration,
                expirationTime = expirationTime,
                sourceUnit = unitCaster,
                isStealable = isStealable,
                spellId = spellId,
                points = {} -- Placeholder
            }
        end
        return nil
    end

    function C_UnitAuras.GetAuraSlots(unit, filter, maxSlots)
        -- WotLK polyfill: Iterate through auras and return slot table
        local slots = {}
        local index = 1
        local max = maxSlots or 40 -- Default max auras
        
        while index <= max do
            local name = UnitAura(unit, index, filter)
            if name then
                table.insert(slots, index)
                index = index + 1
            else
                break
            end
        end
        
        return slots
    end

    -- Stub functions for private aura anchors (retail feature not in WotLK)
    function C_UnitAuras.AddPrivateAuraAnchor(...)
        -- No-op in WotLK
        return nil
    end

    function C_UnitAuras.RemovePrivateAuraAnchor(...)
        -- No-op in WotLK
        return nil
    end
end

-- C_Map
if not C_Map then
    C_Map = {}
    function C_Map.GetBestMapForUnit(unit)
        -- Very basic fallback
        return GetCurrentMapAreaID()
    end
end

-- C_ChatInfo
if not C_ChatInfo then
    C_ChatInfo = {}
    function C_ChatInfo.SendAddonMessage(prefix, text, channel, target)
        SendAddonMessage(prefix, text, channel, target)
    end
end

-- C_AddOns
if not C_AddOns then
    C_AddOns = {}
    function C_AddOns.GetAddOnMetadata(addon, field)
        return GetAddOnMetadata(addon, field)
    end
end

-- C_PvP
if not C_PvP then
    C_PvP = {}
    function C_PvP.IsBattleground()
        local inInstance, instanceType = IsInInstance()
        return instanceType == "pvp"
    end
end

-- C_TooltipInfo
if not C_TooltipInfo then
    C_TooltipInfo = {}
    function C_TooltipInfo.GetSpellByID(spellId)
        -- Placeholder, returns empty table or minimal info
        return { lines = {} } 
    end
end

-- SOUNDKIT
if not SOUNDKIT then
    SOUNDKIT = {
        U_CHAT_SCROLL_BUTTON = "UChatScrollButton",
        IG_MAINMENU_OPTION_CHECKBOX_ON = "igMainMenuOptionCheckBoxOn",
        IG_MAINMENU_OPTION_CHECKBOX_OFF = "igMainMenuOptionCheckBoxOff",
        IG_MAINMENU_OPEN = "igMainMenuOpen",
        IG_MAINMENU_CLOSE = "igMainMenuClose",
        IG_ABILITY_PAGE_TURN = "igAbilityPageTurn",
        IG_CHARACTER_INFO_TAB = "igCharacterInfoTab",
        IG_BACKPACK_OPEN = "igBackPackOpen",
        IG_BACKPACK_CLOSE = "igBackPackClose",
    }
end

-- C_ClassTalents (Retail talent system, not in WotLK)
if not C_ClassTalents then
    C_ClassTalents = {}
    function C_ClassTalents.GetActiveConfigID()
        -- WotLK uses GetActiveTalentGroup() which returns 1 or 2
        return GetActiveTalentGroup()
    end
end

-- C_Traits (Retail talent tree system, not in WotLK)
if not C_Traits then
    C_Traits = {}
    function C_Traits.GetNodeInfo(configID, nodeID)
        -- WotLK doesn't have trait nodes
        -- Return nil to indicate node info not available
        return nil
    end
end

-- C_SpecializationInfo (MoP+ spec system, not in WotLK)
if not C_SpecializationInfo then
    C_SpecializationInfo = {}
    function C_SpecializationInfo.GetSpecialization()
        -- WotLK doesn't have specializations (added in MoP)
        -- Return nil to indicate no spec system
        return nil
    end
    function C_SpecializationInfo.GetSpecializationInfo(specIndex)
        -- Return nil to indicate no spec info available
        return nil
    end
end

-- C_NamePlate (Modern nameplate API, not in WotLK)
if not C_NamePlate then
    C_NamePlate = {}
    function C_NamePlate.GetNamePlates(issecure)
        -- WotLK has no nameplate API
        -- Return empty table
        return {}
    end
end

-- Wrath: alias RegisterAttributeDriver/UnregisterAttributeDriver to StateDriver versions
if not RegisterAttributeDriver and RegisterStateDriver then
    function RegisterAttributeDriver(frame, attribute, state)
        return RegisterStateDriver(frame, attribute, state)
    end
end

if not UnregisterAttributeDriver and UnregisterStateDriver then
    function UnregisterAttributeDriver(frame, attribute)
        return UnregisterStateDriver(frame, attribute)
    end
end


-- GetNumClasses (doesn't exist in WotLK 3.3.5a)
if not GetNumClasses then
    function GetNumClasses()
        -- WotLK has 10 classes: Warrior, Paladin, Hunter, Rogue, Priest, Death Knight, Shaman, Mage, Warlock, Druid
        return 10
    end
end

-- Font constants (don't exist in WotLK 3.3.5a)
if not UNIT_NAME_FONT_CHINESE then
    -- Use standard WotLK font as fallback
    UNIT_NAME_FONT_CHINESE = "Fonts\\FRIZQT__.TTF"
end

-- User requested fonts
if not UNIT_NAME_FONT_KOREAN then
    UNIT_NAME_FONT_KOREAN = "Fonts\\FRIZQT__.TTF"
end
if not UNIT_NAME_FONT_ROMAN then
    UNIT_NAME_FONT_ROMAN = "Fonts\\FRIZQT__.TTF"
end

-- GetClassColor (doesn't exist in WotLK 3.3.5a)
if not GetClassColor then
    function GetClassColor(classFile)
        local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
        if color then
            return color.r, color.g, color.b, string.format("%02x%02x%02x%02x", 255, color.r * 255, color.g * 255, color.b * 255)
        end
        -- Fallback to white if class not found
        return 1, 1, 1, "ffffffff"
    end
end

-- Difficulty constants (don't exist in WotLK 3.3.5a)
-- Mythic difficulty was added in later expansions
if not PLAYER_DIFFICULTY6 then
    PLAYER_DIFFICULTY6 = "Mythic"
end

-- MapUtil (doesn't exist in WotLK 3.3.5a)
if not MapUtil then
    MapUtil = {}
    function MapUtil.GetMapParentInfo(mapID, mapType, topMost)
        -- WotLK doesn't have the modern map system
        -- Return basic zone info using legacy API
        local zoneName = GetZoneText()
        if zoneName and zoneName ~= "" then
            return {
                name = zoneName,
                mapID = mapID or 0
            }
        end
        return nil
    end
end

-- Enum (doesn't exist in WotLK 3.3.5a)
if not Enum then
    Enum = {}
end

-- UIMapType enum (retail feature, doesn't exist in WotLK)
if not Enum.UIMapType then
    Enum.UIMapType = {
        Cosmic = 0,
        World = 1,
        Continent = 2,
        Zone = 3,
        Dungeon = 4,
        Micro = 5,
        Orphan = 6
    }
end

-- UnitIsGroupLeader (doesn't exist in WotLK 3.3.5a)
if not UnitIsGroupLeader then
    function UnitIsGroupLeader(unit)
        -- In WotLK, we need to check differently for party vs raid
        if UnitInRaid(unit) then
            -- In raid, check if unit is the raid leader
            if UnitIsUnit(unit, "player") then
                return IsRaidLeader()
            else
                -- For other units in raid, we can't directly check in WotLK
                -- This is a limitation of the WotLK API
                return false
            end
        else
            -- In party, check if unit is the party leader
            return UnitIsPartyLeader(unit)
        end
    end
end

-- UnitIsGroupAssistant (doesn't exist in WotLK 3.3.5a)
if not UnitIsGroupAssistant then
    function UnitIsGroupAssistant(unit)
        -- Only applies to raids in WotLK
        if UnitInRaid(unit) then
            if UnitIsUnit(unit, "player") then
                return IsRaidOfficer()
            else
                -- For other units in raid, we can't directly check in WotLK
                -- This is a limitation of the WotLK API
                return false
            end
        end
        return false
    end
end

-- PlaySound wrapper for WotLK compatibility
-- In WotLK 3.3.5a, PlaySound signature is different from retail
-- Store original PlaySound and wrap it to handle errors gracefully
do
    local _originalPlaySound = PlaySound
    if _originalPlaySound then
        PlaySound = function(soundKit, channel)
            -- In WotLK, PlaySound only takes soundFile/soundName, not soundKitID + channel
            -- Silently fail if sound doesn't work
            pcall(_originalPlaySound, soundKit)
        end
    end
end

-- GetNormalizedRealmName
-- In WotLK 3.3.5a (Ascension), this function exists but might be broken (calls nil 'Sub')
-- We overwrite it to ensure it works correctly
GetNormalizedRealmName = function()
    local realm = GetRealmName()
    if not realm then return "" end
    -- Remove spaces to normalize
    return string.gsub(realm, "%s+", "")
end

-- IsEncounterInProgress (doesn't exist in WotLK 3.3.5a)
-- Always override to ensure it exists
function IsEncounterInProgress()
    -- WotLK doesn't have encounter tracking API
    -- Return false to allow UI updates (no encounter in progress)
    return false
end

-- Group API polyfills
if not IsInRaid then
    function IsInRaid()
        return GetNumRaidMembers() > 0
    end
end

if not IsInGroup then
    function IsInGroup()
        return GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0
    end
end

-- GetNumGroupMembers polyfill (doesn't exist in WotLK 3.3.5a)
if not GetNumGroupMembers then
    function GetNumGroupMembers()
        if GetNumRaidMembers() > 0 then
            return GetNumRaidMembers()
        elseif GetNumPartyMembers() > 0 then
            return GetNumPartyMembers() + 1 -- +1 for player
        else
            return 1 -- Just player (solo)
        end
    end
end

-------------------------------------------------
-- GROUP_ROSTER_UPDATE Event Compatibility Layer
-- In WotLK 3.3.5a, GROUP_ROSTER_UPDATE doesn't exist.
-- Instead, we have PARTY_MEMBERS_CHANGED and RAID_ROSTER_UPDATE.
--
-- IMPORTANT: Individual files that need GROUP_ROSTER_UPDATE should
-- also register for PARTY_MEMBERS_CHANGED and RAID_ROSTER_UPDATE
-- and handle them the same way as GROUP_ROSTER_UPDATE.
--
-- This global proxy provides a fallback for frames that may not
-- have been updated yet.
-------------------------------------------------
do
    -- Track frames that have registered GROUP_ROSTER_UPDATE handlers
    local groupRosterFrames = setmetatable({}, {__mode = "k"}) -- weak keys
    
    -- The proxy frame that listens to actual WotLK events
    local proxyFrame = CreateFrame("Frame", "CellGroupRosterProxy")
    proxyFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
    proxyFrame:RegisterEvent("RAID_ROSTER_UPDATE")
    proxyFrame:RegisterEvent("PARTY_MEMBER_ENABLE")
    proxyFrame:RegisterEvent("PARTY_MEMBER_DISABLE")
    
    -- Debounce to avoid firing multiple times per frame
    local lastFireTime = 0
    local DEBOUNCE_TIME = 0.1
    
    proxyFrame:SetScript("OnEvent", function(self, event, ...)
        local now = GetTime()
        if now - lastFireTime < DEBOUNCE_TIME then
            return
        end
        lastFireTime = now
        
        -- Fire GROUP_ROSTER_UPDATE on all registered frames
        for frame in pairs(groupRosterFrames) do
            if frame and frame:IsVisible() then
                local handler = frame:GetScript("OnEvent")
                if handler then
                    -- Use pcall to prevent errors from breaking the loop
                    pcall(handler, frame, "GROUP_ROSTER_UPDATE")
                end
            end
        end
    end)
    
    -- Provide a way to register frames for the proxy
    function Cell_RegisterForGroupRosterProxy(frame)
        if frame then
            groupRosterFrames[frame] = true
        end
    end
    
    -- Provide a way to unregister frames from the proxy
    function Cell_UnregisterFromGroupRosterProxy(frame)
        if frame then
            groupRosterFrames[frame] = nil
        end
    end
    
    -- Provide a way to manually trigger GROUP_ROSTER_UPDATE (for init)
    function Cell_FireGroupRosterUpdate()
        for frame in pairs(groupRosterFrames) do
            if frame then
                local handler = frame:GetScript("OnEvent")
                if handler then
                    pcall(handler, frame, "GROUP_ROSTER_UPDATE")
                end
            end
        end
    end
end
