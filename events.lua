-- vim: set ts=3 sw=3 foldmethod=indent:
if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local function evtAddonLoaded(...)
      local addonName = ...
      if addonName == "DKRot" then
         DKROT.MainFrame:UnregisterEvent("ADDON_LOADED")
         if DKROT_Settings ~= nil and DKROT_Settings.UpdateWarning ~= true then
            StaticPopup_Show("DKROT_UPDATE_WARNING")
            DKROT_Settings.UpdateWarning = true
         end
      end
   end

   local function evtCombatLogEventUnfiltered(...)
      local _, event, _, _, casterName, _, _,targetguid, targetName, _, _, _, spellName = ...
      DKROT.curtime = GetTime()

      if (event == "UNIT_DIED" or event == "UNIT_DESTROYED") and DKROT.DT.Unit[targetguid] ~= nil then
         if DKROT.DT.Unit[targetguid].Frame ~= nil then
            DKROT.DT.Unit[targetguid].Frame:SetAlpha(0)
            DKROT.DT.Unit[targetguid].Frame = nil
         end
         DKROT.DT.Unit[targetguid] = nil
      end

      -- If we hit someone and its not a dot ticking, add / update time for the active
      -- target tracking. Excluding spell_periodic_damage means we only track targets
      -- actively being hit by our spells as dotted targets might be moved away
      if casterName == DKROT.PLAYER_NAME and targetName ~= DKROT.PLAYER_NAME and (
         (
            event:endswith('_DAMAGE') or event:endswith('_AURA_APPLIED') or event:endswith('_AURA_REFRESH')
         ) and event ~= 'SPELL_PERIODIC_DAMAGE'
      ) then
         DKROT.ActiveTargets.Targets[targetguid] = DKROT.curtime
      end

      if casterName == PLAYER_NAME and DKROT_Settings.DT.Dots[spellName] and targetName ~= PLAYER_NAME then
         if (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
            if DKROT.DT.Unit[targetguid] == nil then
               DKROT.DT.Unit[targetguid] = {}
               DKROT.DT.Unit[targetguid].Spells = {}
               DKROT.DT.Unit[targetguid].NumDots = 0
               DKROT.DT.Unit[targetguid].Name = select(3, string.find(targetName, "(.-)-")) or targetName
            end

            if DKROT.DT.Unit[targetguid].Spells[spellName] == nil then
               DKROT.DT.Unit[targetguid].NumDots = DKROT.DT.Unit[targetguid].NumDots + 1
            end

            if spellName == DKROT.spells["Death and Decay"] or spellName == DKROT.spells["Defile"] then
               DKROT.DT.Unit[targetguid].Spells[spellName] = select(1, GetSpellCooldown(spellName)) + 10
            else
               DKROT.DT.Unit[targetguid].Spells[spellName] = select(7, UnitDebuff("TARGET", spellName))
            end

         elseif (event == "SPELL_AURA_REMOVED") then
            if DKROT.DT.Unit[targetguid] ~= nil and  DKROT.DT.Unit[targetguid][spellName] ~= nil then
                DKROT.DT.Unit[targetguid].Spells[spellName] = nil
                DKROT.DT.Unit[targetguid].NumDots = DKROT.DT.Unit[targetguid].NumDots - 1
            end
         end
      end
   end

   local function evtPlayerEnterCombat(...)
      DKROT.TimeToDie.Targets = {}
      DKROT.TimeToDie.Sweep = DKROT.curtime

      DKROT.ActiveTargets.Targets = { }
      DKROT.ActiveTargets.Sweep = DKROT.curtime
   end

   local function evtPlayerTalentChanged(...)
      DKROT:CheckSpec()
      DKROT:OptionsRefresh()

      if evt == "ACTIVE_TALENT_GROUP_CHANGED" then
         DKROT:CheckRotationTalents()
      end
   end

   local function evtChatMsgAddon(...)
      local prefix, message, channel, sender = ...
      if prefix == "D4" then
         local handler, time, name = ("\t"):split(message)
         if handler == "PT" then
            DKROT.PullTimer = GetTime() + tonumber(time)
            DKROT:Debug("Received a DBM pull timer")
         end
      end
   end

   local events = {
      ["ADDON_LOADED"] = evtAddonLoaded,
      ["COMBAT_LOG_EVENT_UNFILTERED"]= evtCombatLogEventUnfiltered,
      ["PLAYER_ENTER_COMBAT"] = evtPlayerEnterCombat,
      ["PLAYER_TALENT_UPDATE"] = evtPlayerTalentChanged,
      ["PLAYER_TALENT_GROUP_CHANGED"] = evtPlayerTalentChanged,
      ["CHAT_MSG_ADDON"] = evtChatMsgAddon
   }

   function DKROT.EventHandler(self, evt, ...)
      if evt == 'ADDON_LOADED' or (DKROT.loaded and events[evt] ~= nil) then
         events[evt](...)
      end
   end
end
