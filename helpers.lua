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

   -- Display an info box about new rotations first time
   -- user loads the addon after the update
   function DKROT:DisplayUpdateWarning()
      StaticPopupDialogs["DKROT_UPDATE_WARNING"] = {
         text = "DKRot has been updated to support more than just 2 rotations per spec\n\nIf you want to change the rotation to use, open the settings and select the rotation from the dropdown menu\n\nThis warning should only be displayed once\n",
         button1 = "OK",
         button3 = "Open settings",
         OnAlt = function()
            InterfaceOptionsFrame_OpenToCategory(DKROT_CDRPanel)
            InterfaceOptionsFrame_OpenToCategory(DKROT_CDRPanel)
         end,
         timeout = 0,
         whileDead = true,
         hideOnEscape = true,
         showAlert = true,
         preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
      }

      StaticPopup_Show("DKROT_UPDATE_WARNING")
   end
end
