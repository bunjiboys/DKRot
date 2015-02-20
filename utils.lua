if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   -- Register a rotation
   function DKROT_RegisterRotation_old(spec, intname, rotname, rotfunc, def, spells, talents)
      local currentDefault = DKROT:GetDefaultSpecRotation(spec)
      if currentDefault ~= nil and def == true then
         local specName = select(2, GetSpecializationInfo(spec))
         local defSpecName = DKROT.Rotations[spec][currentDefault].name
         DKROT:Log("Cannot register " .. rotname .. " as the new default spec rotation for '" .. specName .. "' as there is already a default rotation (" .. defSpecName .. ") registered. Registering as non-default")
         def = false
      end
      DKROT.Rotations[spec][intname] = {
         name = rotname,
         func = rotfunc,
         default = def,
         spells = spells or {},
         talents = talents or {},
         prepull = DKROT['DefaultPrePull'],
         aoe = nil
      }
   end

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
      return (dur + start - DKROT.curtime - DKROT.GCD <= 0)
   end

   function DKROT:isItemOffCD(item)
      local start, dur = GetItemCooldown(item)
      return (dur + start - DKROT.curtime - DKROT.GCD <= 0)
   end

   function DKROT:GetCD(spell)
      local start, dur = GetSpellCooldown(DKROT.spells[spell])
      return dur + start - DKROT.curtime - DKROT.GCD
   end

   -- Check to see if a rune is ready to be used
   function DKROT:isRuneOffCD(rune)
      local start, dur, cool = GetRuneCooldown(rune)
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
         DKROT.Sweep = GetTime()
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
      local outbreak = DKROT_Settings.CD[DKROT.Current_Spec].Outbreak and
         IsSpellKnown(77575) and
         DKROT:isOffCD("Outbreak")

      -- Check if Unholy Blight is up, is known and Player wants to use it in rotation
      local unholyblight = DKROT_Settings.CD[DKROT.Current_Spec].UB and
         IsSpellKnown(115989) and
         DKROT:isOffCD("Unholy Blight")

      -- Check if Plague Leech is up, is known and Player wants to use it in rotation
      local plagueleech = DKROT_Settings.CD[DKROT.Current_Spec].PL and
         IsSpellKnown(123693) and
         DKROT:isOffCD("Plague Leech")


      -- Apply Frost Fever
      if FFexpires == nil or FFexpires < 2 then
         if outbreak then -- if can use outbreak, then do it
            return DKROT.spells["Outbreak"]

         elseif unholyblight then -- if can use Unholy Blight, then do it
            return DKROT.spells["Unholy Blight"]

         elseif (DKROT.Current_Spec == DKROT.SPECS.UNHOLY) and ((DKROT:RuneCDs(DKROT.SPECS.UNHOLY) <= 0) or DKROT:DeathRunes() >= 1) then -- Unholy: Plague Strike
            return DKROT.spells["Plague Strike"]

         elseif (DKROT.Current_Spec == DKROT.SPECS.FROST) and ((DKROT:RuneCDs(DKROT.SPECS.FROST) <= 0) or DKROT:DeathRunes() >= 1) then -- Frost: Howling Blast
            return DKROT.spells["Howling Blast"]
            
         elseif ((DKROT:RuneCDs(DKROT.SPECS.FROST) <= 0) or DKROT:DeathRunes() >= 1) then -- Other: Icy Touch
            return DKROT.spells["Icy Touch"]
         end
      end

      -- Apply Blood Plague
      if (DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption ~= DKROT.DiseaseOptions.Single or outbreak) then
         if (BPexpires == nil or BPexpires < 3) then
            -- Add Death Grip as first priority until PS is in range
            if DKROT_Settings.DG and (IsSpellInRange(DKROT.spells["Plague Strike"], "target")) == 0 and IsUsableSpell(DKROT.spells["Death Grip"]) then
               return DKROT.spells["Death Grip"]
            end

            if plagueleech and BPexpires ~= nil and DKROT:DepletedRunes() > 0 then
               return DKROT.spells["Plague Leech"]

            elseif outbreak then -- if can use outbreak, then do it
               return DKROT.spells["Outbreak"]

            elseif unholyblight then -- if can use Unholy Blight, then do it
               return DKROT.spells["Unholy Blight"]

            elseif ((DKROT:RuneCDs(DKROT.SPECS.UNHOLY) <= 0) or DKROT:DeathRunes() >= 1) then -- if rune availible, then use Plague Strike
               return DKROT.spells["Plague Strike"]
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
         if not DKROT:HasTalent(talent) then
            local talentName = select(2, GetTalentInfoByID(DKROT.Talents[talent]))
            table.insert(missing, talentName)
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
      if (canUse == nil or canUse) and DKROT:has(spell) then
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
   function DKROT:CanSoulReaper()
      local hp = DKROT:HealthPct("TARGET")
      local timeToDie = DKROT:GetTimeToDie()

      if DKROT:isOffCD("Soul Reaper") 
         and timeToDie and timeToDie >= 5 
         and ((DKROT:has("Improved Soul Reaper") and hp < 45.5) or hp < 35.5)
      then
         return true
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
end
