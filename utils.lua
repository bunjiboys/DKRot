if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   -- Register a rotation
   function DKROT_RegisterRotation(spec, intname, rotname, rotfunc, def)
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
         default = def
      }
   end

   -- Get default rotation for spec
   function DKROT:GetDefaultSpecRotation(spec)
      if spec == nil then
         spec = DKROT.Current_Spec
      end

      for rotName, rotInfo in pairs(DKROT.Rotations[spec]) do
         if rotInfo.default then
            return rotName
         end
      end

      return nil
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
      local start, dur = GetSpellCooldown(spell)
      return (dur + start - DKROT.curtime - DKROT.GCD <= 0)
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

   function DKROT:TimeToDie()
      if DKROT.TTD == nil then
         DKROT.TTD = {}
      end

      local now = GetTime()

      -- Cleanup old entries in the table
      if (now - DKROT.SweepTTD) > 2 then
         for guid, info in pairs(DKROT.TTD) do
            local tss = now - info.lastUpdate
            if (now - info.lastUpdate) > 10 then
               DKROT.TTD[guid] = nil
            end
         end
         DKROT.SweepTTD = GetTime()
      end

      local target = UnitGUID("TARGET")
      if target ~= nil and UnitCanAttack("PLAYER", "TARGET") then
         if not DKROT.TTD[target] then
            DKROT.TTD[target] = {
               maxHealth = UnitHealth("TARGET"),
               startTime = now,
               lastUpdate = now
            }
         else
            DKROT.TTD[target].lastUpdate = now
         end

         local curHealth = UnitHealth("TARGET")
         local diff = DKROT.TTD[target].maxHealth - curHealth

         -- Target isnt taking damage, might be invulnerable
         if diff == 0 then
            return 99999
         end

         local dps = diff / (now - DKROT.TTD[target].startTime)

         return DKROT:round(curHealth / dps, 2)
      end

      return 99999
   end

   function DKROT:BossOrPlayer(unit)
      -- Player targets should be considered High Level to allow
      -- for full rotation use in PvP
      if UnitPlayerControlled(unit) or UnitLevel(unit) == -1 then
         return true
      end
   end
end
