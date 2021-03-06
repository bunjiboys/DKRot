-- vim: set ts=3 sw=3 foldmethod=indent:
if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   function DKROT_RegisterRotation(spec, rotation)
      local currentDefault = DKROT:GetDefaultSpecRotation(spec)
      local def = rotation["DefaultRotation"]
      if currentDefault ~= nil and def == true then
         local specName = select(2, GetSpecializationInfo(spec))
         local defSpecName = DKROT.Rotations[spec][currentDefault].name
         DKROT:Log("Cannot register " .. rotation["Name"] .. " as the new default spec rotation for '" .. specName .. "' as there is already a default rotation (" .. defSpecName .. ") registered. Registering as non-default")
         def = false
      end

      DKROT.Rotations[spec][rotation["InternalName"]] = {
         name = rotation["Name"],
         func = rotation["MainRotation"],
         default = def,
         spells = rotation["ToggleSpells"],
         talents = rotation["SuggestedTalents"],
         prepull = rotation["PrePull"] or DKROT['DefaultPrePull'],
         aoe = rotation["AOERotation"] or nil
      }
   end

   -- Get default rotation for spec
   function DKROT:GetDefaultSpecRotation(spec)
      if spec == nil then
         spec = DKROT.Current_Spec
      end

      for rotName, rotInfo in pairs(DKROT.Rotations[spec]) do
         if rotInfo.default then
            return rotName, rotInfo
         end
      end

      return nil
   end

   -- Get the current selected rotation, or the default if the current is invalid
   function DKROT:GetCurrentRotation()
      if DKROT.Rotations[DKROT.Current_Spec][DKROT_Settings.CD[DKROT.Current_Spec].Rotation] == nil then
         local rotName, rotInfo = DKROT:GetDefaultSpecRotation(DKROT.Current_Spec)
         return rotName
      else
         return DKROT_Settings.CD[DKROT.Current_Spec].Rotation
      end
   end

   -- Get spellID by name
   function DKROT:GetSpellID(spell)
      return select(7, GetSpellInfo(spell))
   end

   -- Check if we need to use Horn of Winter (missing buff)
   function DKROT:UseHoW()
      local battleShout = select(1, GetSpellInfo(6673))
      local trueShotAura = select(1, GetSpellInfo(19506))

      if UnitBuff("PLAYER", DKROT.spells["Horn of Winter"]) ~= nil
         or UnitBuff("PLAYER", battleShout) ~= nil
         or UnitBuff("PLAYER", trueShotAura) ~= nil
      then
         return false
      end

      return true
   end

   -- Chat log function
   function DKROT:Log(message)
      DEFAULT_CHAT_FRAME:AddMessage("|cFFC41F3BDKRot:|r " .. message)
   end

   -- Debug log function
   function DKROT:Debug(message)
      if DKROT.debug then
         DEFAULT_CHAT_FRAME:AddMessage("|cFFC41F3BDKRot |cFF00FFFF[DEBUG]|r:|r " .. message)
      end
   end

   function DKROT:round(num, idp)
      local mult = 10 ^ (idp or 0)
      return math.floor(num * mult + 0.5) / mult
   end

   function DKROT:deepcopy(orig)
      local orig_type = type(orig)
      local copy
      if orig_type == 'table' then
         copy = {}
         for orig_key, orig_value in next, orig, nil do
            copy[DKROT:deepcopy(orig_key)] = DKROT:deepcopy(orig_value)
         end
         setmetatable(copy, DKROT:deepcopy(getmetatable(orig)))
      else -- number, string, boolean, etc
         copy = orig
      end
      return copy
   end

   function DKROT:CheckFrameDependency(frame, target, stack)
      stack = (stack or {})
      local i = 0
      for idx, element in pairs(DKROT.MovableFrames) do
         i = i + 1

         if i > 30 then
            return "iterations exceeded"
         end

         if element.frame == target then
            local relFrame = select(2, _G[element.frame]:GetPoint()):GetName()

            if relFrame == "UIParent" then
               return nil
            end

            table.insert(stack, DKROT:GetFrame(target))

            if relFrame == frame then
               table.insert(stack, DKROT:GetFrame(frame))
               return stack
            end

            return DKROT:CheckFrameDependency(frame, relFrame, stack)
         end
      end

      return nil
   end

   function DKROT:ShowErrorMessage(message)
      StaticPopup_Show("DKROT_ERROR_MESSAGE")
   end

   function DKROT:GetFrame(frame, fullObject)
      for idx, el in pairs(DKROT.MovableFrames) do
         if el.frame == frame then
            if fullObject == true then
               return el
            end

            return el.name
         end
      end

      return nil
   end

   function DKROT_printr(var, level)
      level = level ~= nil and level + 1 or 0
      for k,v in pairs(var) do
         if type(v) == "table" then
            print(string.rep("   ", level) .. k .. " = {")
            DKROT_printr(v, level)
            print(string.rep("   ", level) .. "}")
         else
            print(string.rep("   ", level) .. k .. " = " .. tostring(v))
         end

      end
   end

   function DKROT:SpellKnown(spell)
      return GetSpellTexture(spell) and true or false
   end

   -- In: timeleft - seconds
   -- Out: formated string of hours, minutes and seconds
   function DKROT:formatTime(timeleft)
      if timeleft > 3600 then
         return format("%dh:%dm", timeleft/3600, ((timeleft%3600)/60))
      elseif timeleft > 600 then
         return format("%dm", timeleft/60)
      elseif timeleft > 60 then
         return format("%d:%2.2d", timeleft/60, timeleft%60)
      end
      return timeleft
   end

   -- In: start- when the spell cd started  dur- duration of the cd
   -- Out: returns if the spell is or will be off cd in the next GCD
   function DKROT:isOffCD(spell)
      local start, dur = GetSpellCooldown(DKROT.spells[spell])
      if not (start and dur) then
         return false
      end
      return (dur + start - DKROT.curtime - DKROT.GCD <= 0)
   end

   function DKROT:isItemOffCD(item)
      local start, dur = GetItemCooldown(item)
      if not (start and dur) then
          return false
      end
      return (dur + start - DKROT.curtime - DKROT.GCD <= 0)
   end

   function DKROT:GetCD(spell)
      local start, dur = GetSpellCooldown(DKROT.spells[spell])
      if not (start and dur) then
          return 9999
      end
      return dur + start - DKROT.curtime - DKROT.GCD
   end

   -- Check to see if a rune is ready to be used
   function DKROT:isRuneOffCD(rune)
      local start, dur, cool = GetRuneCooldown(rune)
      if not (start and dur) then
          return false
      end
      return cool or (dur + start - DKROT.curtime - DKROT.GCD <= 0)
   end

   -- In:tabl - table to check if key is in it  key- key you are looking for
   -- Out: returns true if key is in table
   function DKROT:inTable(tabl, key)
      for i = 1, #tabl do
         if tabl[i] == key then return true end
      end
      return false
   end

   -- Return the duration and start/duration of the GCD or 0,nil,nil if GCD is ready
   function DKROT:GetGCD()
      local start, dur = GetSpellCooldown(61304)
      if dur ~= 0 and start ~= nil then
         return dur - (DKROT.curtime - start), start, dur
      else
         return 0, nil, nil
      end
   end

   function DKROT:GetTimeToDie()
      local now = GetTime()
      local target = UnitGUID("TARGET")

      if (now - DKROT.TimeToDie.LastUpdate) < 1 and DKROT.TimeToDie.Targets[target] ~= nil then
         return DKROT.TimeToDie.Targets[target].ttd
      end

      -- Cleanup old entries in the table
      if (now - DKROT.TimeToDie.Sweep) > 5 then
         for guid, info in pairs(DKROT.TimeToDie.Targets) do
            local tss = now - info.lastUpdate
            if (now - info.lastUpdate) > 30 then
               DKROT.TimeToDie.Targets[guid] = nil
            end
         end
         DKROT.TimeToDie.Sweep = GetTime()
      end

      if target ~= nil and UnitCanAttack("PLAYER", "TARGET") then
         local curHealth = UnitHealth("TARGET")
         if not DKROT.TimeToDie.Targets[target] then
            DKROT.TimeToDie.Targets[target] = {
               maxHealth = curHealth,
               startTime = now,
               lastUpdate = now,
               ttd = nil
            }

         else
            local diff = DKROT.TimeToDie.Targets[target].maxHealth - curHealth
            local dps = diff / (now - DKROT.TimeToDie.Targets[target].startTime)

            local ttd = diff > 0 and DKROT:round(curHealth / dps, 1) or 99999
            DKROT.TimeToDie.Targets[target].ttd = ttd < 1800 and ttd or nil
            DKROT.TimeToDie.Targets[target].lastUpdate = now
         end

         DKROT.TimeToDie.LastUpdate = now
         return DKROT.TimeToDie.Targets[target].ttd
      end

      return nil
   end

   function DKROT:BossOrPlayer(unit)
      -- Player targets should be considered High Level to allow
      -- for full rotation use in PvP
      if DKROT_Settings.CD[DKROT.Current_Spec].BossCD then
         if UnitPlayerControlled(unit) or UnitLevel(unit) == -1 then
            return true
         end

         return false
      else
         return true
      end
   end

   function DKROT:SimpleNumbers(val)
      if val > 1000 then
         return tostring(DKROT:round(val/1000, 1)) .. "k"
      else
         return val
      end
   end

   function DKROT:FormatTTD(ttd)
      if ttd and ttd > 60 then
         local minutes = math.floor(ttd / 60)
         local seconds = ttd - (minutes * 60)
         return string.format("|cffC41F3B%dm %ds|r", minutes, seconds)
      else
         return string.format("|cffC41F3B%ds|r", DKROT:round(ttd))
      end
   end

   -- Gives CD of rune type specified
   -- In: r: type of rune set to be queried
   -- Out:  time1: the lowest cd of the 2 runes being queried  time2: the higher of the cds  RT1: returns true if lowest cd rune is a death rune, RT2: same as RT1 except higher CD rune
   function DKROT:RuneCDs(r)
      -- Get individual rune numbers
      local a, b
      if r == DKROT.SPECS.UNHOLY then a, b = 3, 4
      elseif r == DKROT.SPECS.FROST then a, b = 5, 6
      elseif r == DKROT.SPECS.BLOOD then a, b = 1, 2
      end

      -- Get CD of first rune
      local start, dur, cool = GetRuneCooldown(a)
      local time1 = (cool and 0) or (dur - (DKROT.curtime - start + DKROT.GCD))

      -- Get CD of second rune
      local start, dur, cool = GetRuneCooldown(b)
      local time2 = (cool and 0) or (dur - (DKROT.curtime - start + DKROT.GCD))

      -- if second rune will be off CD before first, then return second then first rune, else vice versa
      if time1 > time2 then
         return time2, time1, GetRuneType(b) == 4, GetRuneType(a) == 4
      else
         return time1, time2, GetRuneType(a) == 4, GetRuneType(b) == 4
      end
   end

   -- Helper function to easily check if a spell is known
   function DKROT:has(spell)
      return GetSpellTexture(DKROT.spells[spell]) and true or false
   end

   -- Return the percentage health of the unit
   function DKROT:HealthPct(unit)
      return (UnitHealth(unit) / UnitHealthMax(unit)) * 100
   end

   -- Returns the number of available runes of a specific type
   -- in: runeType: The type of rune to fetch information for, allowDeathRunes: Whether or not to count deathrunes
   -- out: availableRunes: number of available runes
   function DKROT:RuneIsAvailable(runeType, allowDeathRunes)
      allowDeathRunes = allowDeathRunes or false

      local availableRunes = 0
      for i = 1,6 do
         local rt = GetRuneType(i)
         if rt == runeType or (allowDeathRunes == true and rt == 4) then
            availableRunes = availableRunes + 1
         end
      end

      return availableRunes
   end

   -- Returns the total number of Death runes off CD
   function DKROT:DeathRunes()
      local count = 0
      local tcount = 0
      local start, dur, cool
      for i = 1, 6 do
         if GetRuneType(i) == 4 then
            tcount = tcount + 1
            if DKROT:isRuneOffCD(i) then
               count = count + 1
            end
         end
      end
      return count, tcount
   end

   -- Returns the number of depleted runes (runes on CD)
   function DKROT:DepletedRunes()
      local count = 6
      for i = 1, 6 do
         if DKROT:isRuneOffCD(i) then
            count = count - 1
         end
      end
      return count
   end

   function DKROT:FullyDepletedRunes()
      local count = 0

      if DKROT:isRuneOffCD(1) ~= true and DKROT:isRuneOffCD(2) ~= true then
         count = count + 1
      end

      if DKROT:isRuneOffCD(3) ~= true and DKROT:isRuneOffCD(4) ~= true then
         count = count + 1
      end

      if DKROT:isRuneOffCD(5) ~= true and DKROT:isRuneOffCD(6) ~= true then
         count = count + 1
      end

      return count
   end

   function DKROT:GetDiseaseTime()
      local ff, bp = 0, 0
      local expires = nil

      if DKROT:HasTalent("Necrotic Plague") then
         expires = select(7, UnitDebuff("TARGET", DKROT.spells["Necrotic Plague"], nil, "PLAYER"))
         if expires ~= nil then
            np = expires - DKROT.curtime
            ff = np
            bp = np
         end
      else
         expires = select(7, UnitDebuff("TARGET", DKROT.spells["Frost Fever"], nil, "PLAYER"))
         if expires ~= nil then
            ff = expires - DKROT.curtime
         end

         expires = select(7, UnitDebuff("TARGET", DKROT.spells["Blood Plague"], nil, "PLAYER"))
         if expires ~= nil then
            bp = expires - DKROT.curtime
         end
      end

      return ff, bp
   end

   -- Determines if Diseases need to be refreshed or applied
   function DKROT:GetDisease()
      -- If settings not to worry about diseases, then break
      if DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption == DKROT.DiseaseOptions.None then
         return nil
      end

      -- Get Duration left on diseases
      local FFexpires, BPexpires
      local expires = select(7,UnitDebuff("TARGET", DKROT.spells["Frost Fever"], nil, "PLAYER"))
      if expires ~= nil then
         FFexpires = expires - DKROT.curtime
      end

      expires = select(7,UnitDebuff("TARGET", DKROT.spells["Blood Plague"], nil, "PLAYER"))
      if expires ~= nil then
         BPexpires = expires - DKROT.curtime
      end

      -- Necrotic Plague cannot be refreshed, no reason to even try
      expires = select(7, UnitDebuff("TARGET", DKROT.spells["Necrotic Plague"], nil, "PLAYER"))
      if expires ~= nil then
         return nil
      end

      -- Check if Outbreak is off CD, is known and Player wants to use it in rotation
      local outbreak = DKROT_Settings.CD[DKROT.Current_Spec].Outbreak
         and IsSpellKnown(77575)
         and DKROT:isOffCD("Outbreak")
         and DKROT:CanUse("Outbreak")

      -- Check if Unholy Blight is up, is known and Player wants to use it in rotation
      local unholyblight = DKROT_Settings.CD[DKROT.Current_Spec].UB
         and IsSpellKnown(115989)
         and DKROT:isOffCD("Unholy Blight")

      -- Check if Plague Leech is up, is known and Player wants to use it in rotation
      local plagueleech = DKROT_Settings.CD[DKROT.Current_Spec].PL
         and IsSpellKnown(123693)
         and DKROT:isOffCD("Plague Leech")

      -- Apply Frost Fever
      if FFexpires == nil or FFexpires < 2 then
         if outbreak then -- if can use outbreak, then do it
            return "Outbreak"

         elseif unholyblight and DKROT:CanUse("Unholy Blight") then -- if can use Unholy Blight, then do it
            return "Unholy Blight"

         elseif (DKROT.Current_Spec == DKROT.SPECS.UNHOLY) and ((DKROT:RuneCDs(DKROT.SPECS.UNHOLY) <= 0) or DKROT:DeathRunes() >= 1) then -- Unholy: Plague Strike
            return "Plague Strike"

         elseif (DKROT.Current_Spec == DKROT.SPECS.FROST) and ((DKROT:RuneCDs(DKROT.SPECS.FROST) <= 0) or DKROT:DeathRunes() >= 1) then -- Frost: Howling Blast
            return "Howling Blast"

         elseif ((DKROT:RuneCDs(DKROT.SPECS.FROST) <= 0) or DKROT:DeathRunes() >= 1) then -- Other: Icy Touch
            return "Icy Touch"
         end
      end

      -- Apply Blood Plague
      if (DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption ~= DKROT.DiseaseOptions.Single or outbreak) then
         if (BPexpires == nil or BPexpires < 3) then
            -- Add Death Grip as first priority until PS is in range
            if DKROT_Settings.DG and (IsSpellInRange(DKROT.spells["Plague Strike"], "target")) == 0 and IsUsableSpell(DKROT.spells["Death Grip"]) then
               return "Death Grip"
            end

            if plagueleech and BPexpires ~= nil and DKROT:DepletedRunes() > 0 then
               return "Plague Leech"

            elseif outbreak then -- if can use outbreak, then do it
               return "Outbreak"

            elseif unholyblight then -- if can use Unholy Blight, then do it
               return "Unholy Blight"

            elseif ((DKROT:RuneCDs(DKROT.SPECS.UNHOLY) <= 0) or DKROT:DeathRunes() >= 1) then -- if rune availible, then use Plague Strike
               return "Plague Strike"
            end
         end
      end

      return nil
   end

   function DKROT:CheckRotationOptions()
      local curRot = DKROT_Settings.CD[DKROT.Current_Spec].Rotation
      local active_rot = DKROT.Rotations[DKROT.Current_Spec][curRot]
      if DKROT_Settings.CD[DKROT.Current_Spec].RotationOptions == nil then
         DKROT_Settings.CD[DKROT.Current_Spec].RotationOptions = {}
      end

      if DKROT_Settings.CD[DKROT.Current_Spec].RotationOptions[curRot] == nil then
         DKROT_Settings.CD[DKROT.Current_Spec].RotationOptions[curRot] = {}
         for idx, spell in pairs(active_rot.spells) do
            DKROT_Settings.CD[DKROT.Current_Spec].RotationOptions[curRot][spell] = true
         end
      end
   end

   function DKROT:CheckRotationTalents()
      local curRot = DKROT_Settings.CD[DKROT.Current_Spec].Rotation
      local active_rot = DKROT.Rotations[DKROT.Current_Spec][curRot]

      local missing = {}
      for idx, talent in pairs(active_rot.talents) do
         -- Handle multiple talents correctly
         if type(talent) == "table" then
            local haveTalents = false
            local talentNames = { }
            for subidx, subtalent in pairs(talent) do
               local subTalentName = select(2, GetTalentInfoByID(DKROT.Talents[subtalent]))
               table.insert(talentNames, subTalentName)

               if DKROT:HasTalent(subtalent) then
                  haveTalents = true
               end
            end

            if not haveTalents then
               table.insert(missing, table.concat(talentNames, " / "))
            end
         else
            if not DKROT:HasTalent(talent) then
               local talentName = select(2, GetTalentInfoByID(DKROT.Talents[talent]))
               table.insert(missing, talentName)
            end
         end
      end

      if table.getn(missing) > 0 then
         DKROT:Log("Some of the suggested talents for rotation are missing: " .. table.concat(missing, ", "))
      end
   end

   function DKROT:CanUse(spell)
      local curRot = DKROT_Settings.CD[DKROT.Current_Spec].Rotation
      local canUse = DKROT_Settings.CD[DKROT.Current_Spec].RotationOptions[curRot][spell]

      -- Default to using, if not set
      if DKROT:has(spell) and (canUse == nil or canUse) then
         return true
      end

      return false
   end

   function DKROT:HasTalent(talent)
      return select(4, GetTalentInfoByID(DKROT.Talents[talent], GetActiveSpecGroup()))
   end

   function DKROT:HasItemInBags(item)
      for bag = 0, NUM_BAG_SLOTS do
         for slot = 1, GetContainerNumSlots(bag) do
            if item == GetContainerItemID(bag, slot) then
               return true
            end
         end
      end

      return false
   end

   function DKROT:DefaultPrePull()
      -- Army of the Dead if more than 5 seconds are left on the timer
      if DKROT.PullTimer - DKROT.curtime >= 5 and DKROT:isOffCD("Army of the Dead") then
         return DKROT.spells["Army of the Dead"]
      end

      -- Use strength pot if we havent already
      if UnitBuff("PLAYER", DKROT.spells["Draenic Strength Potion"]) == nil then
         if DKROT:HasItemInBags(109219) and DKROT:isItemOffCD(109219) then
            return 109219, true
         end
      end

      if DKROT:HasTalent("Death's Advance") and DKROT:isOffCD("Death's Advance") then
         return DKROT.spells["Death's Advance"]
      end
   end

   -- Is the target in soul reaper range
   function DKROT:CanSoulReaper(ignoreCD)
      local hp = DKROT:HealthPct("TARGET")
      local timeToDie = DKROT:GetTimeToDie()
      local impSR = DKROT:has("Improved Soul Reaper")

      if timeToDie and timeToDie >= 5 and ((impSR and hp < 45.5) or hp < 35.5) then
         if ignoreCD or DKROT:isOffCD("Soul Reaper") then
            return true
         end
      end

      return false
   end

   function DKROT:BloodlustActive()
      for idx, buff in pairs({"Bloodlust", "Heroism", "Time Warp", "Ancient Hysteria" }) do
         if UnitBuff("PLAYER", DKROT.spells[buff]) then
            return true
         end
      end

      return false
   end

   function DKROT_Export()
      local talents = {}
      for tier = 1, GetMaxTalentTier() do
         local talentID = select(2, GetTalentRowSelectionInfo(tier))
         local id, name = GetTalentInfoByID(talentID)
         table.insert(talents, {["id"] = id, ["name"] = name})
      end

      local trinket1 = GetInventoryItemID("PLAYER", 13)
      local trinket2 = GetInventoryItemID("PLAYER", 14)

      local data = {
         Settings = DKROT_Settings,
         Talents = talents,
         Locale = GetLocale(),
         Spec = select(2, GetSpecializationInfo(GetSpecialization())),
         Rotation = DKROT:GetCurrentRotation(),
         Version = GetAddOnMetadata("DKROT", "Version"),
         Trinkets = {
            slot1 = { id = trinket1, select(1, GetItemInfo(trinket1)) },
            slot2 = { id = trinket2, select(1, GetItemInfo(trinket2)) }
         }

      }
      local encoded = DKROT.Base64:encode(DataDumper(data))

      local frame = CreateFrame("Frame", "DKROT.Export", UIParent, "DialogBoxFrame")
      frame:SetSize(600, 400)
      frame:SetBackdrop({
         bgFile = [[Interface\FrameGeneral\UI-Background-Rock]],
         edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
         tile = true, tileSize = 256, edgeSize = 16,
         insets = { left = 4, right = 4, top = 4, bottom = 4 }
      })
      frame:RegisterForDrag("LeftButton")
      frame:SetPoint("CENTER")
      frame:SetMovable(true)

      local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      title:SetPoint("TOP", 0, -10)
      title:SetFontObject(GameFontHighlight)
      title:SetText("DKROT Export")

      local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      desc:SetPoint("BOTTOMLEFT", 10, 55)
      desc:SetFontObject(GameFontNormal)
      desc:SetText("Please copy/paste the above data to the form at http://dkrot.bunjiboys.dk/ and copy the\nresulting URL to the bug report on Curse.com")
      desc:SetJustifyH("LEFT")

      local scroll = CreateFrame("ScrollFrame", "DKROT.Export.Scroll", frame, FauxPanelScrollFrameTemplate)
      scroll:SetPoint("TOP", title, "BOTTOM", 0, -5)
      scroll:SetPoint("LEFT", 10, 0)
      scroll:SetPoint("RIGHT", -40, 0)
      scroll:SetPoint("BOTTOM", 0, 90)
      scroll:EnableMouseWheel(true)

      local scrollbar = CreateFrame("Slider", nil, scroll, "UIPanelScrollBarTemplate")
      scrollbar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 4, -16)
      scrollbar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 4, 16)
      scrollbar:SetMinMaxValues(1, 200)
      scrollbar:SetValueStep(10)
      scrollbar.scrollStep = 10
      scrollbar:SetValue(0)
      scrollbar:SetWidth(16)
      scrollbar:SetScript("OnValueChanged", function (self, value)
         self:GetParent():SetVerticalScroll(value)
      end)

      local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
      scrollbg:SetAllPoints(scrollbar)
      scrollbg:SetTexture(0, 0, 0, 0.4)
      frame.scrollbar = scrollbar

      local edit = CreateFrame("EditBox", "DKROT.Export.Edit", frame)
      edit:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
      edit:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0, 0)
      edit:SetMultiLine(true)
      edit:SetAutoFocus(false)
      edit:SetFontObject(GameFontHighlightSmall)
      edit:EnableMouse(true)
      edit:SetBackdrop({
         bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
         edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
         tile = true, tileSize = 1, edgeSize = 2,
      })
      edit:SetBackdropColor(0, 0, 0, 0.5)
      edit:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.80)
      edit:SetTextInsets(4, 4, 4, 4)
      edit:SetText(encoded)
      edit:HighlightText(0, -1)
      edit:SetSize(560, 330)

      scroll:SetScrollChild(edit)

      edit:SetScript("OnEscapePressed", function() edit:ClearFocus() end)
      frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
      frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
      scroll:SetScript("OnScrollRangeChanged", function(self, x, y)
         scrollbar:SetMinMaxValues(0, y)
      end)

      frame:Show()
      edit:SetFocus()
   end

   function DKROT:GetRuneTotals()
      local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local runes = { }

      if lfrost == 0 then runes["frost"] = 2 elseif frost == 0 then runes["frost"] = 1 else runes["frost"] = 0 end
      if lunholy == 0 then runes["unholy"] = 2 elseif unholy == 0 then runes["unholy"] = 1 else runes["unholy"] = 0 end
      if lblood == 0 then runes["blood"] = 2 elseif blood == 0 then runes["blood"] = 1 else runes["blood"] = 0 end
      runes["death"] = death

      return runes
   end

   function DKROT:TierBonus(searchTier)
      local tierMask = 0

      for tier, iids in pairs(DKROT.TierItems) do
         local pieces = 0

         for idx, iid in pairs(iids) do
            if IsEquippedItem(iid) then
               pieces = pieces + 1
            end
         end

         if pieces >= 4 then
            tierMask = bit.bor(tierMask, DKROT.Tiers[tier .. "_4p"], DKROT.Tiers[tier .. "_2p"])
         elseif pieces >= 2 then
            tierMask = bit.bor(tierMask, DKROT.Tiers[tier .. "_2p"])
         end
      end

      if bit.band(tierMask, searchTier) > 0 then
         return true
      end

      return false
   end

   function DKROT:GetActiveTargets()
      local now = GetTime()

      -- Cleanup old entries in the table
      if (now - DKROT.ActiveTargets.Sweep) > 0.5 then
         for guid, lastUpdate in pairs(DKROT.ActiveTargets.Targets) do
            local tss = now - lastUpdate
            if (now - lastUpdate) > (DKROT_Settings.ActiveTargetThreshold or 3) then
               DKROT.ActiveTargets.Targets[guid] = nil
            end
         end

         DKROT.ActiveTargets.Sweep = now
      end

      DKROT.ActiveTargets.LastUpdate = now
      return tableSize(DKROT.ActiveTargets.Targets)
   end

   -- Utility function on string to check ending of string against keyword
   function string.endswith(String, End)
      return End == '' or string.sub(String, -string.len(End)) == End
   end

   function tableSize(t)
       local cnt = 0
       for obj in pairs(t) do
           cnt = cnt + 1
       end

       return cnt
   end

   -- The base64 code below is courtesy of Alex Kloss (http://lua-users.org/wiki/BaseSixtyFour)
   -- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
   -- licensed under the terms of the LGPL2
   DKROT.Base64 = {}
   DKROT.Base64.chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

   function DKROT.Base64:encode(data)
      return ((data:gsub('.', function(x)
                  local r ,b='',x:byte()
                  for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
                  return r;
         end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
               if (#x < 6) then return '' end
               local c=0
               for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
               return DKROT.Base64.chars:sub(c+1,c+1)
         end)..({ '', '==', '=' })[#data%3+1])
   end

   function DKROT.Base64:decode(data)
       data = string.gsub(data, '[^'.. DKROT.Base64.chars ..'=]', '')
       return (data:gsub('.', function(x)
           if (x == '=') then return '' end
           local r,f='',(DKROT.Base64.chars:find(x)-1)
           for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
           return r;
       end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
           if (#x ~= 8) then return '' end
           local c=0
           for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
           return string.char(c)
       end))
   end
end
