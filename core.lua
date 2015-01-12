if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...
   DKROT:Debug("Starting")

   ----- Create Main Frame -----
   DKROT.MainFrame = CreateFrame("Button", "DKROT", UIParent)
   DKROT.MainFrame:RegisterEvent("ADDON_LOADED")
   DKROT.MainFrame:SetWidth(94)
   DKROT.MainFrame:SetHeight(68)
   DKROT.MainFrame:SetFrameStrata("BACKGROUND")

   ----- Locals -----
   -- Constants
   local PLAYER_NAME, PLAYER_RACE, PLAYER_PRESENCE = UnitName("player"), select(2, UnitRace("player")), 0
   local BBUUFF, BBFFUU, UUBBFF, UUFFBB, FFUUBB, FFBBUU = 1, 2, 3, 4, 5, 6
   local DISEASE_BOTH, DISEASE_ONE, DISEASE_NONE = 2, 1, 0
   local THREAT_OFF, THREAT_HEALTH, THREAT_ANALOG, THREAT_DIGITAL = 0, 0.1, 1, 99
   local IS_BUFF = 2
   local ITEM_LOAD_THRESHOLD = .5
   local RUNE_COLOR = {
      {1, 0, 0},     -- Blood
      {0, 0.95, 0},  -- Unholy
      {0, 1, 1},     -- Frost
      {0.8, 0.1, 1}  -- Death
   }
   local RuneTexture = {
      "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood",
      "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy",
      "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost",
      "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death",
   }

   -- Variables
   local loaded, mutex = false, false
   local mousex, mousey
   local darksim = {0, 0}
   local simtime = 0
   local bsamount = 0
   local launchtime = 0
   local updatetimer = 0
   local resize = nil
   local delayedInit = false
   DKROT:Debug("Locals Done")

   ------ Update Frames ------
   -- In:location - name or location of the settings for specific CD   frame- frame in which to set the icon for
   -- Out:: N/A (does not return but does set icon settings
   function DKROT:UpdateCD(location, frame)
      -- Reset Icon
      frame.Time:SetText("")
      frame.Stack:SetText("")

      -- Easy access to settings variables
      local cdLoc = DKROT_Settings.CD[DKROT.Current_Spec][location] and DKROT_Settings.CD[DKROT.Current_Spec][location][1] or nil
      local cdIsBuff = DKROT_Settings.CD[DKROT.Current_Spec][location][IS_BUFF]

      -- If the option is not set to nothing
      if cdLoc and cdLoc ~= DKROT_OPTIONS_FRAME_VIEW_NONE then
         frame:SetAlpha(1)
         frame.Icon:SetVertexColor(1, 1, 1, 1)

         -- Priority Icon
         if cdLoc == DKROT_OPTIONS_CDR_CD_PRIORITY then
            -- If targeting something that you can attack and is not dead
            if (UnitCanAttack("player", "target") and (not UnitIsDead("target"))) then
               -- Get Icon from Priority Rotation
               frame.Icon:SetTexture(DKROT:GetNextMove(frame.Icon))
            else
               frame.Icon:SetTexture(nil)
            end

         -- Presence
         elseif cdLoc == DKROT_OPTIONS_CDR_CD_PRESENCE then
            frame.Icon:SetTexture(nil)
            if PLAYER_PRESENCE > 0 then
               frame.Icon:SetTexture(select(1, GetShapeshiftFormInfo(PLAYER_PRESENCE)))
            end

         -- Buff or Debuff
         elseif cdIsBuff then
            local icon, count, dur, expirationTime

            if cdLoc == DKROT.spells["Dark Simulacrum"] then
               local id

               -- If its more than 5 seconds since last time, locate the button 
               -- that has Dark Simulacrum on it
               if (DKROT.curtime - simtime) >= 5 then
                  simtime = DKROT.curtime
                  for i = 1, 120 do
                     _, id = GetActionInfo(i)
                     if id == 77606 then
                        darksim[1] = i
                        darksim[2] = 0
                        DKROT:Debug("Dark Simulacrum Action Slot " .. i)
                        break
                     end
                  end
               end

               -- Set the icon to the DS mirrored spell
               _, id = GetActionInfo(darksim[1])
               if id ~= nil and id ~= 77606 then
                  if DKROT_Settings.Range and IsSpellInRange(GetSpellInfo(id), "target") == 0 then
                     frame.Icon:SetVertexColor(0.8, 0.05, 0.05, 1)
                  end

                  frame.Icon:SetTexture(GetSpellTexture(id))

                  if darksim[2] == 0 or darksim[2] < DKROT.curtime then
                     darksim[2] = DKROT.curtime + 20
                  end

                  frame.Time:SetText(floor(darksim[2] - DKROT.curtime))
                  return
               end
            end

            -- if its on a target then its a debuff, otherwise its a buff
            if DKROT.Cooldowns.Buffs[cdLoc][1] == "target" then
               _, _, icon, count, _, dur, expirationTime = UnitDebuff("target", cdLoc)
            else
               _, _, icon, count, _, dur, expirationTime = UnitBuff(DKROT.Cooldowns.Buffs[cdLoc][1], cdLoc)
            end
            frame.Icon:SetTexture(icon)

            -- If not an aura, set time
            if icon ~= nil and ceil(expirationTime - DKROT.curtime) > 0 then
               frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
               frame.Time:SetText(DKROT:formatTime(ceil(expirationTime - DKROT.curtime)))
               if DKROT_Settings.CD[DKROT.Current_Spec][location][1] == DKROT.spells["Blood Shield"] then
                  count = bsamount
               end

               if count > 1 then
                  frame.Stack:SetText(count)
               end
            end

         -- Move (spell to be cast)
         elseif DKROT:inTable(DKROT.Cooldowns.Moves, cdLoc) then
            local icon = GetSpellTexture(cdLoc)
            if icon ~= nil then
               -- Check if move is off CD
               if DKROT:isOffCD(cdLoc) and IsUsableSpell(cdLoc) then
                  icon = DKROT:GetRangeandIcon(frame.Icon, cdLoc)
               else
                  icon = nil
               end
            end
            frame.Icon:SetTexture(icon)

         -- Trinkets
         elseif cdLoc == DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT1 or cdLoc == DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT2 then
            local invSlotID = (cdLoc == DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT1 and 13 or 14)
            local trinketID = GetInventoryItemID("player", invSlotID)
            local trinket = (trinketID ~= nil and DKROT.Cooldowns.Trinkets[trinketID] or nil)

            if trinket ~= nil then
               if trinket.type == DKROT.TrinketType.OnUse then
                  local start, dur, active = GetItemCooldown(trinketID)
                  frame.Icon:SetTexture(GetmItemIcon(trinketID))

                  if active then
                     frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
                     frame.Time:SetText(DKROT:formatTime(t))

                     if DKROT_Settings.CDS then
                        frame.c:SetCooldown(start, dur)
                     end
                  end

               elseif trinket.type == DKROT.TrinketType.Stacking then
                  local start, dur, active = GetItemCooldown(trinketID)
                  local _, _, icon, stacks, _, dur, expTime = UnitBuff("PLAYER", select(1, GetSpellInfo(trinket.spell)))

                  if icon ~= nil then
                     frame.Icon:SetTexture(icon)
                     frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
                     frame.Time:SetText(DKROT:formatTime(math.floor(expTime - DKROT.curtime)))

                     if stacks > 1 then
                        frame.Stack:SetText(stacks)
                     end
                  else
                     frame.Icon:SetTexture(GetItemIcon(trinketID))
                     if active then
                        frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
                        frame.Time:SetText(DKROT:formatTime(t))

                        if DKROT_Settings.CDS then
                           frame.c:SetCooldown(start, dur)
                        end
                     end
                  end

               elseif trinket.type == DKROT.TrinketType.RRPM then
                  local _, _, _, _, _, dur, expTime = UnitBuff("PLAYER", select(1, GetSpellInfo(trinket.spell)))
                  frame.Icon:SetTexture(select(3, GetSpellInfo(trinket.spell)))

                  if dur ~= nil then
                     frame.Time:SetText(DKROT:formatTime(math.floor(expTime - DKROT.curtime)))

                     if DKROT_Settings.CDS then
                        frame.c:SetCooldown(math.ceil(expTime - dur), dur)
                     else
                        frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
                     end
                  end
               end
            else
               frame.Icon:SetTexture(nil)
            end

         -- Racials
         elseif cdLoc == DKROT_OPTIONS_CDR_RACIAL then
            local icon = DKROT:GetRangeandIcon(frame.Icon, DKROT.spells[PLAYER_RACE])
            frame.Icon:SetTexture(icon)
            if icon ~= nil then
               start, dur, active =  GetSpellCooldown(DKROT.spells[PLAYER_RACE])
               local t = ceil(start + dur - DKROT.curtime)
               if active == 1 and dur > 7 then
                  if DKROT_Settings.CDS then
                     frame.c:SetCooldown(start, dur)
                  end

                  frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
                  frame.Time:SetText(DKROT:formatTime(t))
               end
            end

         -- Cooldown
         else
            local icon = DKROT:GetRangeandIcon(frame.Icon, cdLoc)
            frame.Icon:SetTexture(icon)
            if icon ~= nil then
               start, dur, active =  GetSpellCooldown(cdLoc)
               local t = ceil(start + dur - DKROT.curtime)
               if active == 1 and dur > 7 then
                  if DKROT_Settings.CDS then
                     frame.c:SetCooldown(start, dur)
                  end

                  frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
                  frame.Time:SetText(DKROT:formatTime(t))
               end
            end
         end
         -- if the icon is nil, then just hide the frame
         if frame.Icon:GetTexture() == nil then
            frame:SetAlpha(0)
         end
      else
         cdLoc = DKROT_OPTIONS_FRAME_VIEW_NONE
         frame:SetAlpha(0)
      end
   end

   -- Used to move individual frames where they are suppose to be displayed, also enables and disables mouse depending on settings
   function DKROT:MoveFrame(self)
      local loc = DKROT_Settings.Location[self:GetName()]
      self:ClearAllPoints()
      self:SetPoint(loc.Point, loc.Rel, loc.RelPoint, loc.X, loc.Y)
      self:SetBackdropColor(0, 0, 0, DKROT_Settings.Trans)
      self:EnableMouse(not DKROT_Settings.Locked)

      if loc.Scale ~= nil then
         self:SetScale(loc.Scale)
      else
         loc.Scale = 1
      end
   end

   -- Called to update all the frames positions and scales
   function DKROT:UpdatePosition()
      for idx, frame in pairs(DKROT.MovableFrames) do
         DKROT:MoveFrame(_G[frame.frame])
      end

      DKROT:Debug("UpdatePosition")
   end

   function DKROT_UnlockUI()
      for idx, movFrame in pairs(DKROT.MovableFrames) do
         local frame = _G[movFrame.frame]
         if frame.overlay == nil then
            if frame:GetObjectType() == "Button" then
               frame.overlay = CreateFrame("Button", movFrame.frame .. "Overlay", frame)
            else
               frame.overlay = CreateFrame("Frame", movFrame.frame .. "Overlay", frame)
            end

            frame.overlay:EnableMouse(false)
            frame.overlay:SetBackdrop({
               bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
               tile = true,
               tileSize = 16
            })
            frame.overlay:SetBackdropColor(0, 1, 0, 0.5)
            frame.overlay:SetFrameLevel(frame:GetFrameLevel() + 10)
            frame.overlay:SetAllPoints(frame)
         else
            frame.overlay:SetAlpha(1)
         end
      end
   end

   function DKROT_LockUI()
      for idx, movFrame in pairs(DKROT.MovableFrames) do
         local frame = _G[movFrame.frame]
         if frame.overlay ~= nil then
            frame.overlay:SetAlpha(0)
         end
      end
   end

   function DKROT:BuildRuneBar()
      local runebar = ""
      local place = 1
      local b1, b2, u1, u2, f1, f2 = 1, 2, 3, 4, 5, 6
      local order = {
         [BBUUFF] = { 1, 2, 3, 4, 5, 6 },
         [BBFFUU] = { 1, 2, 5, 6, 3, 4 },
         [UUBBFF] = { 3, 4, 1, 2, 5, 6 },
         [UUFFBB] = { 3, 4, 5, 6, 1, 2 },
         [FFUUBB] = { 5, 6, 3, 4, 1, 2 },
         [FFBBUU] = { 5, 6, 1, 2, 3, 4 },
      }

      for _, rune in pairs(order[DKROT_Settings.RuneOrder]) do
         local start, cooldown = GetRuneCooldown(rune)
         local r, g, b = unpack(RUNE_COLOR[GetRuneType(rune)])
         local cdtime = start + cooldown - DKROT.curtime

         if DKROT_Settings.RuneBars then
            DKROT.RuneBars[place]:SetMinMaxValues(0, cooldown)
            DKROT.RuneBars[place]:SetValue(cdtime)
            DKROT.RuneBars[place].back:SetTexture(r, g, b, 0.2)
            DKROT.RuneBars[place].Spark:SetTexture(RuneTexture[GetRuneType(rune)])
            DKROT.RuneBars[place].Spark:SetPoint("CENTER", DKROT.RuneBars[place], "BOTTOM", 0, (cdtime <= 0 and 0) or (cdtime < cooldown and (80*cdtime)/cooldown) or 80)

            if cdtime > 0 then
               DKROT.RuneBars[place].Spark.c.lock = false
               DKROT.RuneBars[place]:SetAlpha(0.75)
            end

            if cdtime <= 0 and not DKROT.RuneBars[place].Spark.c.lock then
               DKROT.RuneBars[place].Spark.c:SetCooldown(0,0)
               DKROT.RuneBars[place].Spark.c.lock = true
               DKROT.RuneBars[place]:SetAlpha(1)
            end

            place = place + 1
         end

         cdtime = math.ceil(cdtime)
         if cdtime >= cooldown or cdtime >= 10 then
            cdtime = "X"
         elseif cdtime <= 0 then
            cdtime = "*"
         end
         runebar = runebar .. string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, cdtime)
      end

      return runebar
   end

   -- Main function for updating all information
   function DKROT:UpdateUI()
      if (UnitCanAttack("player", "target") and (not UnitIsDead("target"))) then
         DKROT.MainFrame:SetAlpha(DKROT_Settings.NormTrans)
      else
         DKROT.MainFrame:SetAlpha(DKROT_Settings.CombatTrans)
      end

      if DKROT_Settings.Locked == false and (DKROT.LockDialog == nil or DKROT.LockDialog == false) then
         DKROT_UnlockUI()
         DKROT.LockDialog = true
         StaticPopup_Show("DKROT_FRAME_UNLOCKED")
      end

      -- GCD
      local gcdStart, gcdDur
      DKROT.GCD, gcdStart, gcdDur = DKROT:GetGCD()
      if DKROT_Settings.GCD and DKROT.GCD ~= 0 then
         DKROT.Move.c:SetCooldown(gcdStart, gcdDur)
      end

      -- Runes
      DKROT.RuneBar:SetAlpha((DKROT_Settings.Rune and 1) or 0)
      DKROT.RuneBarHolder:SetAlpha((DKROT_Settings.RuneBars and 1) or 0)
      if DKROT_Settings.Rune or DKROT_Settings.RuneBars then
         DKROT.RuneBar.Text:SetText(DKROT:BuildRuneBar())
      end

      -- RunicPower
      if DKROT_Settings.RP then
         DKROT.RunicPower:SetAlpha(1)
         DKROT.RunicPower.Text:SetText(string.format("|cff00ffff%.3d|r", UnitPower("player")))
      else
         DKROT.RunicPower:SetAlpha(0)
      end

      -- Diseases
      if DKROT_Settings.Disease then
         DKROT.Diseases:SetAlpha(1)

         if DKROT:SpellKnown(DKROT.spells["Necrotic Plague"]) then
            DKROT.Diseases.FF:SetAlpha(0)
            DKROT.Diseases.BP:SetAlpha(0)
            DKROT.Diseases.NP:SetAlpha(1)

            DKROT.Diseases.NP.Icon:SetVertexColor(1, 1, 1, 1)
            DKROT.Diseases.NP.Time:SetText("")
            DKROT.Diseases.NP.Stack:SetText("")

            if UnitCanAttack("player", "target") and (not UnitIsDead("target")) then
               local _, _, _, stacks, _, _, expires = UnitDebuff("TARGET", DKROT.spells["Necrotic Plague"], nil, "PLAYER")

               if expires ~= nil and (expires - DKROT.curtime) > 0 then
                  DKROT.Diseases.NP.Icon:SetVertexColor(.5, .5, .5, 1)
                  DKROT.Diseases.NP.Time:SetText(string.format("|cffffffff%.2d|r", expires - DKROT.curtime))
                  DKROT.Diseases.NP.Stack:SetText(stacks)
               end
            end
         else
            DKROT.Diseases.FF:SetAlpha(1)
            DKROT.Diseases.BP:SetAlpha(1)
            DKROT.Diseases.NP:SetAlpha(0)
            DKROT.Diseases.FF.Icon:SetVertexColor(1, 1, 1, 1)
            DKROT.Diseases.BP.Icon:SetVertexColor(1, 1, 1, 1)
            DKROT.Diseases.FF.Time:SetText("")
            DKROT.Diseases.BP.Time:SetText("")

            if UnitCanAttack("player", "target") and (not UnitIsDead("target")) then
               local expires = select(7,UnitDebuff("TARGET", DKROT.spells["Frost Fever"], nil, "PLAYER"))
               if  expires ~= nil and (expires - DKROT.curtime) > 0 then
                  DKROT.Diseases.FF.Icon:SetVertexColor(.5, .5, .5, 1)
                  DKROT.Diseases.FF.Time:SetText(string.format("|cffffffff%.2d|r", expires - DKROT.curtime))
               end

               expires = select(7,UnitDebuff("TARGET", DKROT.spells["Blood Plague"], nil, "PLAYER"))
               if expires ~= nil and (expires - DKROT.curtime) > 0 then
                  DKROT.Diseases.BP.Icon:SetVertexColor(.5, .5, .5, 1)
                  DKROT.Diseases.BP.Time:SetText(string.format("|cffffffff%.2d|r", expires - DKROT.curtime))
               end
            end
         end
      else
         DKROT.Diseases:SetAlpha(0)
      end

      -- Priority Icon
      DKROT.AOE:SetAlpha(0)
      DKROT.Interrupt:SetAlpha(0)
      if DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][1] ~= DKROT_OPTIONS_FRAME_VIEW_NONE then
         DKROT.Move:SetAlpha(1)
         -- DKROT.MoveBackdrop:SetAlpha(1)
         DKROT:UpdateCD("DKROT_CDRPanel_DD_Priority", DKROT.Move)

         -- If Priority on Main Icon
         if DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][1] == DKROT_OPTIONS_CDR_CD_PRIORITY then
            -- Show Interrupt icon
            if DKROT_Settings.MoveAltInterrupt then
               local castInfo = UnitCastingInfo("target")
               local spell, notint = select(1, castInfo), select(9, castInfo)

               if spell == nil then
                  local chanInfo = UnitChannelInfo("target")
                  spell = select(1, chanInfo)
                  notint = select(8, chanInfo)
               end

               if spell ~= nil and not notint then
                  if DKROT:isOffCD(DKROT.spells["Mind Freeze"]) then
                     DKROT.Interrupt:SetAlpha(1)
                  end
               end
            end
         end
      else
         DKROT.Move:SetAlpha(0)
         -- DKROT.MoveBackdrop:SetAlpha(0)
      end

      -- CDs
      for i = 1, #CDDisplayList do
         if DKROT_Settings.CD[DKROT.Current_Spec][ceil(i/2)] then
            DKROT.CD[ceil(i/2)]:SetAlpha(1)
            DKROT:UpdateCD(CDDisplayList[i], DKROT.CD[CDDisplayList[i]])
         else
            DKROT.CD[ceil(i/2)]:SetAlpha(0)
         end
      end

      bsamount = (select(15, UnitBuff("PLAYER", DKROT.spells["Blood Shield"])) or 0)
   end

   do -- Disease Tracker
      -- Create a DT Frame
      function DKROT:DTCreateFrame()
         local frame = CreateFrame('StatusBar', nil, DKROT.DT)
         frame:SetHeight(24)
         frame:SetWidth(DKROT.DT:GetWidth()-2)
         frame:SetStatusBarTexture([[Interface\Tooltips\UI-Tooltip-Background]])
         frame:SetStatusBarColor(1, 0, 0);
         frame:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = -1, right = -1, top = -1, bottom = -1},}
         frame:SetBackdropColor(0, 0, 0, 0.5)

         frame.Name = frame:CreateFontString(nil, 'OVERLAY')
         frame.Name:SetPoint("LEFT", frame, 3, 0)
         frame.Name:SetFont(DKROT.font, 13, "OUTLINE")

         return frame
      end

      -- Gather the info and apply them to it's frame
      function DKROT:DTUpdateInfo(guid, info)
         if not DKROT_Settings.DT.Target and UnitGUID("target") == guid then
            return
         end

         -- Create Frame
         if info.Frame == nil then info.Frame = DKROT:DTCreateFrame() end
         info.Frame:SetAlpha(DKROT_Settings.DTTrans)

         -- Set Settings
         if info.spot == nil or info.spot ~= DKROT.DT.spot then
            info.spot = DKROT.DT.spot
            info.Frame:ClearAllPoints()

            if DKROT_Settings.DT.GrowDown then
               info.Frame:SetPoint("TOP", 0, -(DKROT.DT.spot*27)-1)
            else
               info.Frame:SetPoint("BOTTOM", 0, (DKROT.DT.spot*27)+1)
            end
         end

         -- Change Colour
         if DKROT_Settings.DT.TColours then
            if (UnitGUID("target") == guid) then
               info.Frame:SetBackdropColor(0.1, 0.75, 0.1, 0.9)

            elseif (UnitGUID("focus") == guid) then
               info.Frame:SetBackdropColor(0.2, 0.2, 0.75, 0.9)

            else
               info.Frame:SetBackdropColor(0, 0, 0, 0.5)
            end
         end

         -- Threat
         info.Frame:SetMinMaxValues(DKROT_Settings.DT.Threat, 100)
         if DKROT_Settings.DT.Threat ~= THREAT_OFF and info.Threat ~= nil then
            info.Frame:SetValue(info.Threat)
         else
            info.Frame:SetValue(0)
         end

         -- Name
         local name = info.Name
         local color
         if DKROT_Settings.DT.CColours then
            color = RAID_CLASS_COLORS[select(2, GetPlayerInfoByGUID(guid))]
         end

         if color == nil then
            color = {}
            color.r, color.g, color.b = 1, 1, 1
         end

         name = (string.len(name) > 9 and string.gsub(name, '%s?(.)%S+%s', '%1. ') or name)
         info.Frame.Name:SetText(string.format("|cff%02x%02x%02x%.9s|r", color.r*255, color.g*255, color.b*255, name))

         -- Dots
         if info.Frame.Icons == nil or info.OldDots ~= info.NumDots then
            local count = 0
            local texture
            if info.Frame.Icons ~= nil then
               for j, v in pairs(info.Frame.Icons) do
                  info.Frame.Icons[j]:SetAlpha(0)
               end
               info.Frame.Icons = nil
            end
            info.Frame.Icons = {}
            info.OldDots = info.NumDots
            for j, v in pairs(info.Spells) do
               info.Frame.Icons[j] = DKROT:CreateIcon("DKROT.DT."..j, info.Frame, j, 20)
               info.Frame.Icons[j].Time:SetFont(DKROT.font, 11, "OUTLINE")
               info.Frame.Icons[j]:SetPoint("RIGHT", -(count*22)-1, 0)
               info.Frame.Icons[j].Icon:SetTexture(GetSpellTexture(DKROT.DTspells[j][1]))
               count = count + 1
            end
         end

         -- Update Dots
         if info.Frame.Icons ~= nil and next(info.Spells) ~= nil then
            for j, v in pairs(info.Spells) do
               if v ~= nil and info.Frame.Icons[j]~= nil then
                  local t = floor(v - DKROT.curtime)
                  if t >= 0 then
                     info.Frame.Icons[j]:SetAlpha(1)
                     info.Frame.Icons[j].Icon:SetVertexColor(0.5, 0.5, 0.5, 1)

                     if t > DKROT_Settings.DT.Warning then
                        info.Frame.Icons[j].Time:SetText(DKROT:formatTime(t))
                     else
                        info.Frame.Icons[j].Time:SetText(format("|cffff2222%s|r", DKROT:formatTime(t)))
                     end
                  else
                     info.NumDots = info.NumDots - 1
                     info.Frame.Icons[j]:SetAlpha(0)
                     info.Spells[j] = nil
                  end
               else
                  if info.Frame.Icons[j]~= nil then
                     info.Frame.Icons[j]:SetAlpha(0)
                  end

                  info.NumDots = info.NumDots - 1
                  info.Spells[j] = nil
               end
            end
         else
            return
         end

         info.Updated = true
         DKROT.DT.spot = DKROT.DT.spot + 1
      end

      -- Update the frames
      function DKROT:DTUpdateFrames()
         local function updateGUIDFrame(guid)
            if DKROT.DT.Unit[guid] ~= nil then
               DKROT.DT.Unit[guid].Updated = false

               if DKROT.DT.spot < DKROT_Settings.DT.Numframes then
                  DKROT:DTUpdateInfo(guid, DKROT.DT.Unit[guid])
               end

               if DKROT.DT.Unit[guid].Updated == false and DKROT.DT.Unit[guid]~= nil and DKROT.DT.Unit[guid].Frame ~= nil then
                  DKROT.DT.Unit[guid].Frame:SetAlpha(0)
                  if next(DKROT.DT.Unit[guid].Spells) == nil then DKROT.DT.Unit[guid] = nil end
               end
            end
         end

         DKROT.DT.spot = 0

         local targetguid, focusguid

         if DKROT_Settings.DT.TPriority then
            targetguid, focusguid = UnitGUID("target"), UnitGUID("focus")
            updateGUIDFrame(targetguid)
            if targetguid ~= focusguid then updateGUIDFrame(focusguid) end
         end

         for k, v in pairs(DKROT.DT.Unit) do
            if k ~= targetguid and k ~= focusguid then updateGUIDFrame(k) end
         end
      end

      -- Update Threat and Dots from checking target infos
      local updatedGUIDs = {}
      function DKROT:DTCheckTargets()
         local function updateGUIDInfo(unit)
            local guid = UnitGUID(unit)
            if guid ~= nil and updatedGUIDs[guid] == nil then
               if UnitIsDead(unit) and DKROT.DT.Unit[guid] ~= nil and DKROT.DT.Unit[guid].Frame ~= nil then
                  DKROT.DT.Unit[guid].Frame:SetAlpha(0)
                  DKROT.DT.Unit[guid].Frame = nil
                  DKROT.DT.Unit[guid] = nil
               end

               if select(1, UnitDebuff(unit, 1, "PLAYER")) ~= nil then
                  local name, expt
                  for j= 1, 10 do
                     name, _, _, _, _, _, expt = UnitDebuff(unit, j, "PLAYER")
                     if name == nil then break end
                     if DKROT_Settings.DT.Dots[name] then
                        if DKROT.DT.Unit[guid] == nil then
                           local targetName = UnitName(unit)
                           DKROT.DT.Unit[guid] = {}
                           DKROT.DT.Unit[guid].Spells = {}
                           DKROT.DT.Unit[guid].NumDots = 0
                           DKROT.DT.Unit[guid].Name = select(3, string.find(targetName, "(.-)-")) or targetName
                        end

                        updatedGUIDs[guid] = true

                        if DKROT.DT.Unit[guid].Spells[name] == nil then
                           DKROT.DT.Unit[guid].NumDots = DKROT.DT.Unit[guid].NumDots + 1
                        end
                        if name == DKROT.spells["Death and Decay"] then
                           DKROT.DT.Unit[guid].Spells[name] = select(1, GetSpellCooldown(name)) + 10
                        else
                           DKROT.DT.Unit[guid].Spells[name] = expt
                        end

                        if DKROT_Settings.DT.Threat ~= THREAT_OFF then
                           DKROT.DT.Unit[guid].Threat = select(3, UnitDetailedThreatSituation("player", unit))
                           if DKROT_Settings.DT.Threat == THREAT_HEALTH then
                              DKROT.DT.Unit[guid].Threat = (UnitHealth(unit)/UnitHealthMax(unit))*100
                           end
                        end
                     end
                  end
               end
            end
         end

         updatedGUIDs = {}
         updateGUIDInfo("target")
         updateGUIDInfo("focus")
         updateGUIDInfo("pettarget")
         for i = 1, MAX_BOSS_FRAMES do
            updateGUIDInfo("boss"..i)
         end
      end
   end

   -- Priority System
   do
      -- Called to update a priority icon with next move
      function DKROT:GetNextMove(icon)
         -- Call correct function based on spec
         if DKROT_Settings.MoveAltAOE then
            if (DKROT.Current_Spec == DKROT.SPECS.UNHOLY) then
               DKROT.AOE:SetAlpha(1)
               DKROT.AOE.Icon:SetTexture(DKROT:UnholyAOEMove(DKROT.AOE.Icon))

            elseif (DKROT.Current_Spec == DKROT.SPECS.FROST) then
               DKROT.AOE:SetAlpha(1)
               DKROT.AOE.Icon:SetTexture(DKROT:FrostAOEMove(DKROT.AOE.Icon))

            elseif (DKROT.Current_Spec == DKROT.SPECS.BLOOD) then
               DKROT.AOE:SetAlpha(1)
               DKROT.AOE.Icon:SetTexture(DKROT:BloodAOEMove(DKROT.AOE.Icon))
            end
         end

         -- return DKROT.Rotations[DKROT.Current_Spec][DKROT_Settings.CD[DKROT.Current_Spec].Rotation].func(icon)
         local nextCast, noCheckRange = DKROT.Rotations[DKROT.Current_Spec][DKROT_Settings.CD[DKROT.Current_Spec].Rotation].func()
         if noCheckRange ~= nil and noCheckRange == true then
            return GetSpellTexture(nextCast)
         else
            return DKROT:GetRangeandIcon(icon, nextCast)
         end
      end

      -- Determines if player is in range with spell and sets colour and icon accordingly
      -- In: icon: icon in which to change the vertex colour of   move: spellID of spell to be cast next
      -- Out: returns the texture of the icon (probably unessesary since icon is now being passed in, will look into it more)
      function DKROT:GetRangeandIcon(icon, move)
         if move ~= nil then
            if DKROT_Settings.Range and IsSpellInRange(move, "target") == 0 then
               icon:SetVertexColor(0.8, 0.05, 0.05, 1)
            else
               icon:SetVertexColor(1, 1, 1, 1)
            end
            return GetSpellTexture(move)
         end

         return nil
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
         local start, dur, cool
         for i = 1, 6 do
            if GetRuneType(i) == 4 then
               if DKROT:isRuneOffCD(i) then
                  count = count + 1
               end
            end
         end
         return count
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

      function DKROT:HasFullyDepletedRunes()
         if DKROT:isRuneOffCD(1) ~= true and DKROT:isRuneOffCD(2) ~= true then
            return true
         elseif DKROT:isRuneOffCD(3) ~= true and DKROT:isRuneOffCD(4) ~= true then
            return true
         elseif DKROT:isRuneOffCD(5) ~= true and DKROT:isRuneOffCD(6) ~= true then
            return true
         end

         return false
      end

      -- Returns if move is off cooldown or not
      function DKROT:QuickAOESpellCheck(move)
         if DKROT_Settings.MoveAltAOE and GetSpellTexture(move) ~= nil then
            if DKROT:isOffCD(move) then
               return true
            end
         end
         return false
      end

      function DKROT:GetDiseaseTime()
         local ff, bp

         local expires = select(7,UnitDebuff("TARGET", DKROT.spells["Frost Fever"], nil, "PLAYER"))
         if expires ~= nil then
            ff = expires - DKROT.curtime
         end

         expires = select(7,UnitDebuff("TARGET", DKROT.spells["Blood Plague"], nil, "PLAYER"))
         if expires ~= nil then
            bp = expires - DKROT.curtime
         end

         expires = select(7, UnitDebuff("TARGET", DKROT.spells["Necrotic Plague"], nil, "PLAYER"))
         if expires ~= nil then
            local np = expires - DKROT.curtime
            ff = np
            bp = np
         end

         return ff, bp
      end

      -- Determines if Diseases need to be refreshed or applied
      function DKROT:GetDisease()
         -- If settings not to worry about diseases, then break
         if DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption == DISEASE_NONE then
            return nil
         end

         -- Get Duration left on diseases
         local FFexpires, BPexpires, NPexpires
         local expires = select(7,UnitDebuff("TARGET", DKROT.spells["Frost Fever"], nil, "PLAYER"))
         if expires ~= nil then
            FFexpires = expires - DKROT.curtime
         end

         expires = select(7,UnitDebuff("TARGET", DKROT.spells["Blood Plague"], nil, "PLAYER"))
         if expires ~= nil then
            BPexpires = expires - DKROT.curtime
         end

         expires = select(7, UnitDebuff("TARGET", DKROT.spells["Necrotic Plague"], nil, "PLAYER"))
         if expires ~= nil then
            NPexpires = expires - DKROT.curtime
         end

         -- Check if Outbreak is off CD, is known and Player wants to use it in rotation
         local outbreak = DKROT_Settings.CD[DKROT.Current_Spec].Outbreak and
            IsSpellKnown(77575) and
            DKROT:isOffCD(DKROT.spells["Outbreak"])

         -- Check if Unholy Blight is up, is known and Player wants to use it in rotation
         local unholyblight = DKROT_Settings.CD[DKROT.Current_Spec].UB and
            IsSpellKnown(115989) and
            DKROT:isOffCD(DKROT.spells["Unholy Blight"])

         -- Check if Plague Leech is up, is known and Player wants to use it in rotation
         local plagueleech = DKROT_Settings.CD[DKROT.Current_Spec].PL and
            IsSpellKnown(123693) and
            DKROT:isOffCD(DKROT.spells["Plague Leech"])


         -- Apply Frost Fever
         if (FFexpires == nil or FFexpires < 2) and NPexpires == nil then
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
         if (DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption ~= DISEASE_ONE or outbreak) then
            if (BPexpires == nil or BPexpires < 3) then
               -- Necrotic plague acts as both frost fever and blood plague
               if NPexpires ~= nil and NPexpires > 3 then
                  return nil
               end

               -- Add Death Grip as first priority until PS is in range
               if DKROT_Settings.DG and (IsSpellInRange(DKROT.spells["Plague Strike"], "target")) == 0 and IsUsableSpell(DKROT.spells["Death Grip"]) then
                  return DKROT.spells["Death Grip"]
               end

               if plagueleech and (BPexpires ~= nil or NPexpires ~= nil) and DKROT:DepletedRunes() > 0 then
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


      -- Function to determine AOE rotation for Unholy Spec
      function DKROT:UnholyAOEMove(icon)
         -- Diseases > Dark Transformation > Death and Decay > SS if both Unholy and/or all Death runes are up >
         -- BB + IT if both pairs of Blood and Frost runes are up >   DC
         -- > SS > BB + IT

         -- Rune Info
         local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()

         -- AOE:Death and Decay
         if DKROT:QuickAOESpellCheck(DKROT.spells["Death and Decay"]) and (unholy <= 0 or death >= 1) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Death and Decay"])
         end

         -- AOE:Blood Boil
         if DKROT:QuickAOESpellCheck(DKROT.spells["Blood Boil"]) and (blood <= 0 or death >= 1) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Blood Boil"])
         end

         -- Scourge Strike
         if (lunholy <= 0) then
            return DKROT:GetRangeandIcon(icon, nil)
         end

         -- AOE:Death Coil
         if DKROT_Settings.CD[DKROT.Current_Spec].RP
         and (UnitPower("player") >= 40
            or select(7, UnitBuff("PLAYER",DKROT.spells["Sudden Doom"])) ~= nil) then
            return DKROT:GetRangeandIcon(icon, nil)
         end

         return nil
      end

      -- Function to determine AOE rotation for Frost Spec
      function DKROT:FrostAOEMove(icon)

         -- Rune Info
         local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud, lud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()

         -- AOE:Howling Blast if both Frost runes and/or both Death runes are up
         if DKROT:QuickAOESpellCheck(DKROT.spells["Howling Blast"]) and ((lfrost <= 0) or (lblood <= 0) or (lunholy <= 0 and lud)) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Howling Blast"])
         end

         -- AOE:DnD if both Unholy Runes are up
         if DKROT:QuickAOESpellCheck(DKROT.spells["Death and Decay"]) and (lunholy <= 0) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Death and Decay"])
         end

         -- AOE:Frost Strike if RP capped
         if DKROT:QuickAOESpellCheck(DKROT.spells["Frost Strike"]) and (UnitPower("player") > 88) then
            return DKROT:GetRangeandIcon(icon, nil)
         end

         -- AOE:Howling Blast
         if DKROT:QuickAOESpellCheck(DKROT.spells["Howling Blast"]) and (frost <= 0 or death >= 1) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Howling Blast"])
         end

         -- AOE:DnD
         if DKROT:QuickAOESpellCheck(DKROT.spells["Death and Decay"]) and (unholy <= 0) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Death and Decay"])
         end

         -- AOE:Frost Strike
         if DKROT:QuickAOESpellCheck(DKROT.spells["Frost Strike"]) and UnitPower("player") >= 20 then
            return DKROT:GetRangeandIcon(icon, nil)
         end

         -- AOE:PS
         if DKROT:QuickAOESpellCheck(DKROT.spells["Plague Strike"]) and (unholy <= 0) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Plague Strike"])
         end

         return nil
      end

      -- Function to determine AOE rotation for Blood Spec
      function DKROT:BloodAOEMove(icon)
         return nil
      end

   end

   -- Function to check spec and presence
   function DKROT:CheckSpec()
      -- Set all settings to default
      DKROT.Current_Spec = DKROT.SPECS.UNKNOWN
      if GetSpecialization() == 1 then
         DKROT.Current_Spec = DKROT.SPECS.BLOOD
      elseif GetSpecialization() == 2 then
         DKROT.Current_Spec = DKROT.SPECS.FROST
      elseif GetSpecialization() == 3 then
         DKROT.Current_Spec = DKROT.SPECS.UNHOLY
      end

      -- Presence
      PLAYER_PRESENCE = 0
      for i = 1, GetNumShapeshiftForms() do
         local icon, _, active = GetShapeshiftFormInfo(i)
         if active then
            PLAYER_PRESENCE = i
         end
      end

      DKROT:Debug("Check Spec - " .. DKROT.Current_Spec)
      DKROT:OptionsRefresh()
   end

   function DKROT:Initialize()
      DKROT:Debug("Initialize")

      if InCombatLockdown() then
         if delayedInit == false then
            delayedInit = true
            DKROT:Log("Delaying initialization due to combat lockdown")
         end

         return
      end

      mutex = true

      DKROT:LoadSpells()
      DKROT:LoadCooldowns()

      if not DKROT:LoadTrinkets() and (DKROT.curtime - launchtime < ITEM_LOAD_THRESHOLD) then
         DKROT:Debug("Initialize Failed")
         mutex = false
         return
      end

      if (DKROT.curtime - launchtime >= ITEM_LOAD_THRESHOLD) then
         DKROT:Debug("Launch Threshold Met")
      end

      if DKROT.debug then
         DKROT:Debug("~~Spell Difference Start~~")
         for k, v in pairs(DKROT.spells) do
            if v == nil or k ~= v then
               DKROT:Debug(k.." =/= ".. v)
            end
         end
         DKROT:Debug("~~Spell Difference End~~")
      end

      -- DKROT:SetDefaults()
      -- Check Settings
      DKROT:CheckSettings()
      DKROT:Debug("Initialize - Version " .. DKROT_Settings.Version)

      if DKROT_Settings.DT.Combat or not DKROT_Settings.DT.Enable then
         DKROT.MainFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
      else
         DKROT.MainFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
      end

      DKROT.MainFrame:SetAlpha(0)
      DKROT:CreateCDs()
      DKROT:CreateUI()

      -- Setup Masque if enabled
      local MSQ = LibStub("Masque", true)
      if MSQ then
         local msqMainGrp = MSQ:Group("DKRot")
         local msqCDGrp = MSQ:Group("DKRot", "Cooldowns")
         local msqDiseaseGrp = MSQ:Group("DKRot", "Diseases")

         msqMainGrp:AddButton(DKROT.Move)
         msqMainGrp:AddButton(DKROT.AOE)
         msqMainGrp:AddButton(DKROT.Interrupt)

         msqDiseaseGrp:AddButton(DKROT.Diseases.NP)
         msqDiseaseGrp:AddButton(DKROT.Diseases.FF)
         msqDiseaseGrp:AddButton(DKROT.Diseases.BP)

         for i = 1, #CDDisplayList do
            msqCDGrp:AddButton(DKROT.CD[CDDisplayList[i]])
         end
      end
      
      local PosPanel = DKROT:SetupPositionPanel(function() DKROT:PositionUpdate() end)

      InterfaceOptions_AddCategory(DKROT_Options)
      InterfaceOptions_AddCategory(DKROT_FramePanel)
      InterfaceOptions_AddCategory(DKROT_CDRPanel)
      InterfaceOptions_AddCategory(DKROT_CDPanel)
      InterfaceOptions_AddCategory(DKROT_DTPanel)
      InterfaceOptions_AddCategory(DKROT_PositionPanel)
      InterfaceOptions_AddCategory(DKROT_ABOUTPanel)

      DKROT_CDRPanel_DG_Text:SetText(DKROT.spells["Death Grip"])
      DKROT:CheckSpec()

      -- Initialize all dropdowns
      UIDropDownMenu_Initialize(DKROT_FramePanel_Rune_DD, DKROT_Rune_DD_OnLoad)
      UIDropDownMenu_Initialize(DKROT_CDRPanel_Diseases_DD, DKROT_Diseases_OnLoad)
      UIDropDownMenu_Initialize(DKROT_CDRPanel_DD_Priority, DKROT_CDRPanel_DD_OnLoad)
      UIDropDownMenu_Initialize(DKROT_CDRPanel_Rotation, DKROT_Rotations_OnLoad)
      for i = 1, #CDDisplayList do
         UIDropDownMenu_Initialize(_G[CDDisplayList[i]], DKROT_CDRPanel_DD_OnLoad)
      end
      UIDropDownMenu_Initialize(DKROT_FramePanel_ViewDD, DKROT_FramePanel_ViewDD_OnLoad)
      UIDropDownMenu_Initialize(DKROT_DTPanel_DD_Threat, DKROT_DTPanel_Threat_OnLoad)
      DKROT:Debug("Initialize - Dropdowns Done")

      mutex = nil
      loaded = true

      collectgarbage()
   end

   DKROT:Debug("Functions Done")

   -- --- Events-- ---
   -- Register Events
   DKROT.MainFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
   DKROT.MainFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
   DKROT.MainFrame:RegisterEvent("ADDON_LOADED")
   -- DKROT:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
   -- DKROT:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

   -- Function to be called when events triggered
   local slottimer = 0
   DKROT.MainFrame:SetScript("OnEvent", function(_, e, ...)
      if e == "ADDON_LOADED" then
         local addonName = ...
         if addonName == "DKRot" then
            DKROT.MainFrame:UnregisterEvent("ADDON_LOADED")
            if DKROT_Settings ~= nil and DKROT_Settings.UpdateWarning ~= true then
               StaticPopup_Show("DKROT_UPDATE_WARNING")
               DKROT_Settings.UpdateWarning = true
            end
         end
      end

      -- Delayed addon initialization due to combat lockdown
      if loaded then
         if e == "COMBAT_LOG_EVENT_UNFILTERED" then
            local _, event, _, _, casterName, _, _,targetguid, targetName, _, _, _, spellName = ...
            if (event == "UNIT_DIED" or event == "UNIT_DESTROYED") and DKROT.DT.Unit[targetguid] ~= nil then
               if DKROT.DT.Unit[targetguid].Frame ~= nil then
                  DKROT.DT.Unit[targetguid].Frame:SetAlpha(0)
                  DKROT.DT.Unit[targetguid].Frame = nil
               end
               DKROT.DT.Unit[targetguid] = nil
            end

            if (casterName == PLAYER_NAME) and DKROT_Settings.DT.Dots[spellName] and targetName ~= PLAYER_NAME then
               DKROT.curtime = GetTime()
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

                  if spellName == DKROT.spells["Death and Decay"] then
                     DKROT.DT.Unit[targetguid].Spells[spellName] = select(1, GetSpellCooldown(spellName)) + 10
                  else
                     DKROT.DT.Unit[targetguid].Spells[spellName] = DKROT.DTspells[spellName][2] + DKROT.curtime
                  end

               elseif (event == "SPELL_AURA_REMOVED") then
                  if DKROT.DT.Unit[targetguid] ~= nil and  DKROT.DT.Unit[targetguid][spellName] ~= nil then
                      DKROT.DT.Unit[targetguid].Spells[spellName] = nil
                      DKROT.DT.Unit[targetguid].NumDots = DKROT.DT.Unit[targetguid].NumDots - 1
                  end
               end
            end
         else
            DKROT:CheckSpec()
         end
      end
   end)

   -- Main function to run addon
   local DTupdatetimer = 0
   local DTchecktimer = 0
   local scheduledInit = false
   DKROT.MainFrame:SetScript("OnUpdate", function()
      DKROT.curtime = GetTime()
      -- Make sure it only updates at max, once every 0.15 sec
      if (DKROT.curtime - updatetimer >= 0.08) then
         updatetimer = DKROT.curtime

         if (not loaded) and (not mutex) then
            if launchtime == 0 then launchtime = DKROT.curtime;DKROT:Debug("Launchtime Set") end
            DKROT:Initialize()
         elseif loaded then
            -- Check if visibility conditions are met, if so update the information in the addon
            if not UnitHasVehicleUI("player") 
               and (
                  (InCombatLockdown() and DKROT_Settings.VScheme == DKROT_OPTIONS_FRAME_VIEW_NORM)
                  or (DKROT_Settings.VScheme == DKROT_OPTIONS_FRAME_VIEW_SHOW)
                  or not DKROT_Settings.Locked
                  or (
                     DKROT_Settings.VScheme ~= DKROT_OPTIONS_FRAME_VIEW_HIDE 
                     and UnitCanAttack("player", "target") 
                     and not UnitIsDead("target")
                  )
               )
            then
               DKROT:UpdateUI()
            else
               DKROT.MainFrame:SetAlpha(0)
            end

            if resize ~= nil then
               x, y = GetCursorPosition()
               local sizex = (x - mousex + resize:GetWidth())/resize:GetWidth()
               local sizey = (mousey - y + resize:GetHeight())/resize:GetHeight()
               if sizex < sizey then
                  if sizex > 1 then
                     resize:SetScale(sizex)
                  end
               else
                  if sizey > 1 then
                     resize:SetScale(sizey)
                  end
               end
            end
         end
      end
      if loaded and DKROT_Settings.DT.Enable then
         if (DKROT.curtime - DTchecktimer >= DKROT_Settings.DT.Update) then
            DTchecktimer = DKROT.curtime
            DKROT:DTCheckTargets()
         end
         if (DKROT.curtime - DTupdatetimer >= 0.5) then
            DTupdatetimer = DKROT.curtime
            DKROT:DTUpdateFrames()
         end
      end
   end)

   -- --- Options-- ---
   -- Setup slash command
   SLASH_DKROT1 = '/dkrot'
   SlashCmdList["DKROT"] = function()
      InterfaceOptionsFrame_OpenToCategory(DKROT_FramePanel)
      InterfaceOptionsFrame_OpenToCategory(DKROT_FramePanel)
      DKROT:Debug("Slash Command Used")
   end

   -- Update the Blizzard interface Options with settings
   function DKROT:OptionsRefresh()
      if DKROT_Settings ~= nil and DKROT_Settings.Version ~= nil and DKROT_Settings.Version == DKROT_VERSION then
         -- Frame
         DKROT_FramePanel_GCD:SetChecked(DKROT_Settings.GCD)
         DKROT_FramePanel_CDS:SetChecked(DKROT_Settings.CDS)
         DKROT_FramePanel_CDEDGE:SetChecked(DKROT_Settings.CDEDGE)
         DKROT_FramePanel_Range:SetChecked(DKROT_Settings.Range)
         DKROT_FramePanel_Rune:SetChecked(DKROT_Settings.Rune)
         DKROT_FramePanel_RuneBars:SetChecked(DKROT_Settings.RuneBars)
         DKROT_FramePanel_RP:SetChecked(DKROT_Settings.RP)
         DKROT_FramePanel_Disease:SetChecked(DKROT_Settings.Disease)
         DKROT_FramePanel_Locked:SetChecked(DKROT_Settings.Locked)
         DKROT_FramePanel_Trans:SetNumber(DKROT_Settings.Trans)
         DKROT_FramePanel_Trans:SetCursorPosition(0)
         DKROT_FramePanel_CombatTrans:SetNumber(DKROT_Settings.CombatTrans)
         DKROT_FramePanel_CombatTrans:SetCursorPosition(0)
         DKROT_FramePanel_NormalTrans:SetNumber(DKROT_Settings.NormTrans)
         DKROT_FramePanel_NormalTrans:SetCursorPosition(0)

         -- View Dropdown
         UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme)
         UIDropDownMenu_SetText(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme)

         UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder)
         UIDropDownMenu_SetText(DKROT_FramePanel_Rune_DD, DKROT_OPTIONS_FRAME_RUNE_ORDER[DKROT_Settings.RuneOrder])


         -- CD/R
         DKROT_CDRPanel_Outbreak_Text:SetText(DKROT.spells["Outbreak"])
         DKROT_CDRPanel_UB_Text:SetText(DKROT.spells["Unholy Blight"])
         DKROT_CDRPanel_PL_Text:SetText(DKROT.spells["Plague Leech"])
         DKROT_CDRPanel_ERW_Text:SetText(DKROT.spells["Empower Rune Weapon"])
         DKROT_CDRPanel_BT_Text:SetText(DKROT.spells["Blood Tap"])
         DKROT_CDRPanel_DP_Text:SetText(DKROT.spells["Death Pact"])
         if (DKROT.Current_Spec == DKROT.SPECS.UNHOLY) then
            DKROT_CDRPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_UNHOLY)
            DKROT_CDPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_UNHOLY)
         elseif (DKROT.Current_Spec == DKROT.SPECS.FROST) then
            DKROT_CDRPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_FROST)
            DKROT_CDPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_FROST)
         elseif (DKROT.Current_Spec == DKROT.SPECS.BLOOD) then
            DKROT_CDRPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_BLOOD)
            DKROT_CDPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_BLOOD)
         else
            DKROT_CDRPanel_Title_Spec:SetText(DKROT_OPTIONS_DKROT_SPEC_None)
            DKROT_CDPanel_Title_Spec:SetText(DKROT_OPTIONS_DKROT_SPEC_None)
         end

         -- Disease Dropdown
         UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Diseases_DD, DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption)

         local text
         if DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption == DISEASE_BOTH then
            text = DKROT_OPTIONS_CDR_DISEASES_DD_BOTH
         elseif DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption == DISEASE_ONE then
            text = DKROT_OPTIONS_CDR_DISEASES_DD_ONE
         else
            text = DKROT_OPTIONS_CDR_DISEASES_DD_NONE
         end
         UIDropDownMenu_SetText(DKROT_CDRPanel_Diseases_DD, text)

         -- Rotation
         local current_rotation = DKROT_Settings.CD[DKROT.Current_Spec].Rotation
         if current_rotation == nil then
            if DKROT.Current_Spec ~= DKROT.SPECS.UNKNOWN then
               for rotName, rotInfo in pairs(DKROT.Rotations[DKROT.Current_Spec]) do
                  if rotInfo.default == true then
                     current_rotation = rotName
                     break
                  end
               end
               UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Rotation, current_rotation)
               UIDropDownMenu_SetText(DKROT_CDRPanel_Rotation, DKROT.Rotations[DKROT.Current_Spec][current_rotation].name)
            end
         end

         DKROT_CDRPanel_Outbreak:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].Outbreak)
         DKROT_CDRPanel_UB:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].UB)
         DKROT_CDRPanel_PL:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].PL)
         DKROT_CDRPanel_ERW:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].ERW)
         DKROT_CDRPanel_BT:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].BT)
         DKROT_CDRPanel_DP:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].DP)
         DKROT_CDRPanel_IRP:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].RP)
         DKROT_CDRPanel_MoveAltInterrupt:SetChecked(DKROT_Settings.MoveAltInterrupt)
         DKROT_CDRPanel_MoveAltAOE:SetChecked(DKROT_Settings.MoveAltAOE)
         DKROT_CDRPanel_MoveAltDND:SetChecked(DKROT_Settings.MoveAltDND)
         DKROT_CDRPanel_UseHoW:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].UseHoW)
         DKROT_CDRPanel_DG:SetChecked(DKROT_Settings.DG)
         DKROT_CDRPanel_DD_CD1:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec][1])
         DKROT_CDRPanel_DD_CD2:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec][2])
         DKROT_CDRPanel_DD_CD3:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec][3])
         DKROT_CDRPanel_DD_CD4:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec][4])

         -- Priority Dropdown
         if DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"] ~= nil and DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][1] ~= nil then
            UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_DD_Priority, DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][1]..((DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][IS_BUFF] and " (Buff)") or ""))
            UIDropDownMenu_SetText(DKROT_CDRPanel_DD_Priority, DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][1]..((DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][IS_BUFF] and " (Buff)") or ""))
         end

         -- Cooldown Dropdown
         for i = 1, #CDDisplayList do
            if _G[CDDisplayList[i]] ~= nil and DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]] ~= nil and DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]][1] ~= nil then
               UIDropDownMenu_SetSelectedValue(_G[CDDisplayList[i]], DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]][1]..((DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]][IS_BUFF] and " (Buff)") or ""))
               UIDropDownMenu_SetText(_G[CDDisplayList[i]], DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]][1]..((DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]][IS_BUFF] and " (Buff)") or ""))
            end
         end

         -- Disease Tracker
         DKROT_DTPanel_Enable:SetChecked(DKROT_Settings.DT.Enable)
         DKROT_DTPanel_CColours:SetChecked(DKROT_Settings.DT.CColours)
         DKROT_DTPanel_TColours:SetChecked(DKROT_Settings.DT.TColours)
         DKROT_DTPanel_Target:SetChecked(DKROT_Settings.DT.Target)
         DKROT_DTPanel_TPriority:SetChecked(DKROT_Settings.DT.TPriority)
         DKROT_DTPanel_GrowDown:SetChecked(DKROT_Settings.DT.GrowDown)
         DKROT_DTPanel_CombatLog:SetChecked(DKROT_Settings.DT.Combat)
         DKROT_DTPanel_Update:SetNumber(DKROT_Settings.DT.Update)
         DKROT_DTPanel_Update:SetCursorPosition(0)
         DKROT_DTPanel_NumFrames:SetNumber(DKROT_Settings.DT.Numframes)
         DKROT_DTPanel_NumFrames:SetCursorPosition(0)
         DKROT_DTPanel_Warning:SetNumber(DKROT_Settings.DT.Warning)
         DKROT_DTPanel_Warning:SetCursorPosition(0)
         DKROT_DTPanel_Trans:SetNumber(DKROT_Settings.DTTrans)
         DKROT_DTPanel_Trans:SetCursorPosition(0)
         UIDropDownMenu_SetSelectedValue(DKROT_DTPanel_DD_Threat, DKROT_Settings.DT.Threat)
         if DKROT_Settings.DT.Threat == THREAT_OFF then text = DKROT_OPTIONS_DT_THREAT_OFF
         elseif DKROT_Settings.DT.Threat == THREAT_HEALTH then text = DKROT_OPTIONS_DT_THREAT_HEALTH
         elseif DKROT_Settings.DT.Threat == THREAT_ANALOG then text = DKROT_OPTIONS_DT_THREAT_ANALOG
         elseif DKROT_Settings.DT.Threat == THREAT_DIGITAL then text = DKROT_OPTIONS_DT_THREAT_DIGITAL
         end
         UIDropDownMenu_SetText(DKROT_DTPanel_DD_Threat, text)

         DKROT_DTPanel_DOTS_FF_Text:SetText(DKROT.spells["Frost Fever"])
         DKROT_DTPanel_DOTS_FF:SetChecked(DKROT_Settings.DT.Dots[DKROT.spells["Frost Fever"]])
         DKROT_DTPanel_DOTS_BP_Text:SetText(DKROT.spells["Blood Plague"])
         DKROT_DTPanel_DOTS_BP:SetChecked(DKROT_Settings.DT.Dots[DKROT.spells["Blood Plague"]])
         DKROT_DTPanel_DOTS_DD_Text:SetText(DKROT.spells["Death and Decay"])
         DKROT_DTPanel_DOTS_DD:SetChecked(DKROT_Settings.DT.Dots[DKROT.spells["Death and Decay"]])
         DKROT_DTPanel_DOTS_DF_Text:SetText(DKROT.spells["Defile"])
         DKROT_DTPanel_DOTS_DF:SetChecked(DKROT_Settings.DT.Dots[DKROT.spells["Defile"]])
         DKROT_DTPanel_DOTS_NP_Text:SetText(DKROT.spells["Necrotic Plague"])
         DKROT_DTPanel_DOTS_NP:SetChecked(DKROT_Settings.DT.Dots[DKROT.spells["Necrotic Plague"]])

         -- About Options
         DKROT_ABOUTHTML:SetText("<html><body><p>" .. DKROT_ABOUT_BODY .. "</p></body></html>");
         DKROT_ABOUTHTML:SetSpacing(2);

         DKROT:Debug("OptionsRefresh")
         DKROT:UpdatePosition()

         if DKROT.LockDialog == true and DKROT_Settings.Locked == true then
            DKROT_LockUI()
            StaticPopup_Hide("DKROT_FRAME_UNLOCKED")
            DKROT.LockDialog = false
         end
      else
         DKROT:Debug("ERROR OptionsRefresh - " .. (DKROT_Settings == nil and "Settings are nil") or (DKROT_Settings.Version == nil and "Version is nil") or ("Invalid Version" .. DKROT_Settings.Version))
      end
   end

   -- Check if options are valid and save them to settings if so
   function DKROT_OptionsOkay()
      if DKROT_Settings ~= nil and (DKROT_Settings.Version ~= nil and DKROT_Settings.Version == DKROT_VERSION) then
         -- Frame
         DKROT_Settings.GCD = DKROT_FramePanel_GCD:GetChecked()
         DKROT_Settings.CDEDGE = DKROT_FramePanel_CDEDGE:GetChecked()
         DKROT_Settings.CDS = DKROT_FramePanel_CDS:GetChecked()
         DKROT_Settings.CDEDGE = DKROT_FramePanel_CDEDGE:GetChecked()
         DKROT_Settings.Range = DKROT_FramePanel_Range:GetChecked()
         DKROT_Settings.Rune = DKROT_FramePanel_Rune:GetChecked()
         DKROT_Settings.RuneBars = DKROT_FramePanel_RuneBars:GetChecked()
         DKROT_Settings.RP = DKROT_FramePanel_RP:GetChecked()
         DKROT_Settings.Disease = DKROT_FramePanel_Disease:GetChecked()
         DKROT_Settings.Locked = DKROT_FramePanel_Locked:GetChecked()

         -- Transparency
         if DKROT_FramePanel_Trans:GetNumber() >= 0 and DKROT_FramePanel_Trans:GetNumber() <= 1 then
            DKROT_Settings.Trans = DKROT_FramePanel_Trans:GetNumber()
         else
            DKROT_FramePanel_Trans:SetNumber(DKROT_Settings.Trans)
         end
         if DKROT_FramePanel_CombatTrans:GetNumber() >= 0 and DKROT_FramePanel_CombatTrans:GetNumber() <= 1 then
            DKROT_Settings.CombatTrans = DKROT_FramePanel_CombatTrans:GetNumber()
         else
            DKROT_FramePanel_CombatTrans:SetNumber(DKROT_Settings.CombatTrans)
         end
         if DKROT_FramePanel_NormalTrans:GetNumber() >= 0 and DKROT_FramePanel_NormalTrans:GetNumber() <= 1 then
            DKROT_Settings.NormTrans = DKROT_FramePanel_NormalTrans:GetNumber()
         else
            DKROT_FramePanel_NormalTrans:SetNumber(DKROT_Settings.NormTrans)
         end

         -- CD/R
         DKROT_Settings.MoveAltInterrupt = DKROT_CDRPanel_MoveAltInterrupt:GetChecked()
         DKROT_Settings.MoveAltAOE = DKROT_CDRPanel_MoveAltAOE:GetChecked()
         DKROT_Settings.MoveAltDND = DKROT_CDRPanel_MoveAltDND:GetChecked()
         DKROT_Settings.DG = DKROT_CDRPanel_DG:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].UseHoW = DKROT_CDRPanel_UseHoW:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].Outbreak = DKROT_CDRPanel_Outbreak:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].UB = DKROT_CDRPanel_UB:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].PL = DKROT_CDRPanel_PL:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].ERW = DKROT_CDRPanel_ERW:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].BT = DKROT_CDRPanel_BT:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].DP = DKROT_CDRPanel_DP:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].RP = DKROT_CDRPanel_IRP:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec][1] = (DKROT_CDRPanel_DD_CD1:GetChecked())
         DKROT_Settings.CD[DKROT.Current_Spec][2] = (DKROT_CDRPanel_DD_CD2:GetChecked())
         DKROT_Settings.CD[DKROT.Current_Spec][3] = (DKROT_CDRPanel_DD_CD3:GetChecked())
         DKROT_Settings.CD[DKROT.Current_Spec][4] = (DKROT_CDRPanel_DD_CD4:GetChecked())

         -- Disease Timers
         DKROT_Settings.DT.Enable = DKROT_DTPanel_Enable:GetChecked()
         if not DKROT_Settings.DT.Enable then
            for k, v in pairs(DKROT.DT.Unit) do
               DKROT.DT.Unit[k].Frame:SetAlpha(0)
               DKROT.DT.Unit[k].Frame = nil
            end
            collectgarbage()
         end
         DKROT_Settings.DT.CColours = DKROT_DTPanel_CColours:GetChecked()
         DKROT_Settings.DT.TColours = DKROT_DTPanel_TColours:GetChecked()
         DKROT_Settings.DT.Target = DKROT_DTPanel_Target:GetChecked()
         DKROT_Settings.DT.TPriority = DKROT_DTPanel_TPriority:GetChecked()
         DKROT_Settings.DT.GrowDown = DKROT_DTPanel_GrowDown:GetChecked()
         DKROT_Settings.DT.Combat = DKROT_DTPanel_CombatLog:GetChecked()
         if DKROT_DTPanel_Update:GetNumber() >= 0.1 and DKROT_DTPanel_Update:GetNumber() <= 10 then
            DKROT_Settings.DT.Update = DKROT_DTPanel_Update:GetNumber()
         else
            DKROT_DTPanel_Update:SetNumber(DKROT_Settings.DT.Update)
         end
         if DKROT_DTPanel_NumFrames:GetNumber() >= 1 and DKROT_DTPanel_NumFrames:GetNumber() <= 10 then
            DKROT_Settings.DT.Numframes = DKROT_DTPanel_NumFrames:GetNumber()
         else
            DKROT_DTPanel_NumFrames:SetNumber(DKROT_Settings.DT.Numframes)
         end
         if DKROT_DTPanel_Warning:GetNumber() >= 0 and DKROT_DTPanel_Warning:GetNumber() <= 10 then
            DKROT_Settings.DT.Warning = DKROT_DTPanel_Warning:GetNumber()
         else
            DKROT_DTPanel_Warning:SetNumber(DKROT_Settings.DT.Warning)
         end
         if DKROT_DTPanel_Trans:GetNumber() >= 0 and DKROT_DTPanel_Trans:GetNumber() <= 1 then
            DKROT_Settings.DTTrans = DKROT_DTPanel_Trans:GetNumber()
         else
            DKROT_DTPanel_Trans:SetNumber(DKROT_Settings.DTTrans)
         end
         DKROT_Settings.DT.Dots[DKROT.spells["Frost Fever"]] = DKROT_DTPanel_DOTS_FF:GetChecked()
         DKROT_Settings.DT.Dots[DKROT.spells["Blood Plague"]] = DKROT_DTPanel_DOTS_BP:GetChecked()
         DKROT_Settings.DT.Dots[DKROT.spells["Death and Decay"]] = DKROT_DTPanel_DOTS_DD:GetChecked()
         DKROT_Settings.DT.Dots[DKROT.spells["Defile"]] = DKROT_DTPanel_DOTS_DF:GetChecked()
         DKROT_Settings.DT.Dots[DKROT.spells["Necrotic Plague"]] = DKROT_DTPanel_DOTS_NP:GetChecked()

         if DKROT_Settings.DT.Combat or not DKROT_Settings.DT.Enable then
            DKROT.MainFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
         else
            DKROT.MainFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
         end

         -- Change the cooldown spiral edge settings
         DKROT.Move.c:SetDrawEdge(DKROT_Settings.CDEDGE)

         DKROT:Debug("OptionsOkay")
         DKROT:OptionsRefresh()
      else
         DKROT:Debug("ERROR OptionsOkay - " .. (DKROT_Settings == nil and "Settings are nil") or (DKROT_Settings.Version == nil and "Version is nil") or ("Invalid Version" .. DKROT_Settings.Version))
      end
   end

   -- Checks to make sure that none of the settings are nil, which will lead to the addon not working properly
   function DKROT:CheckSettings()
      DKROT:Debug("Check Settings Start")

      local specs = {DKROT.SPECS.UNKNOWN, DKROT.SPECS.BLOOD, DKROT.SPECS.FROST, DKROT.SPECS.UNHOLY}
      local spots = {"Priority", "CD1_One", "CD1_Two", "CD2_One", "CD2_Two", "CD3_One", "CD3_Two", "CD4_One", "CD4_Two"}

      -- Defaults
      if DKROT_Settings == nil then
         DKROT_Settings = {}
         DKROT_Settings.Locked = true
         DKROT_Settings.Range = true
         DKROT_Settings.GCD = true
         DKROT_Settings.Rune = true
         DKROT_Settings.RuneOrder = BBFFUU
         DKROT_Settings.RP = true
         DKROT_Settings.Disease = true
         DKROT_Settings.CD = {}
         DKROT_Settings.UpdateWarning = true
         DKROT:CooldownDefaults()
      end

      -- General Settings
      if DKROT_Settings.RuneOrder == nil then  DKROT_Settings.RuneOrder = BBUUFF end
      if DKROT_Settings.Trans == nil then DKROT_Settings.Trans = 0.5 end
      if DKROT_Settings.CombatTrans == nil then DKROT_Settings.CombatTrans = 1.0 end
      if DKROT_Settings.NormTrans == nil then DKROT_Settings.NormTrans = 1.0 end
      if DKROT_Settings.DTTrans == nil then DKROT_Settings.DTTrans = 1.0 end
      if DKROT_Settings.VScheme == nil then DKROT_Settings.VScheme = DKROT_OPTIONS_FRAME_VIEW_NORM end

      -- CDs
      if DKROT_Settings.CD == nil then
         DKROT_Settings.CD = {}
         DKROT:CooldownDefaults()
      end
      for i=1,#specs do
         if DKROT_Settings.CD[specs[i]] == nil then DKROT_Settings.CD[specs[i]] = {}   end
         if DKROT_Settings.CD[specs[i]].DiseaseOption == nil then DKROT_Settings.CD[specs[i]].DiseaseOption = DISEASE_BOTH end
         for j=1,#spots do
            if DKROT_Settings.CD[specs[i]]["DKROT_CDRPanel_DD_"..spots[j]] == nil or
               DKROT_Settings.CD[specs[i]]["DKROT_CDRPanel_DD_"..spots[j]][1] == nil then
               DKROT_Settings.CD[specs[i]]["DKROT_CDRPanel_DD_"..spots[j]] = {DKROT_OPTIONS_FRAME_VIEW_NONE, nil}
            end
         end
      end

      -- DT
      if DKROT_Settings.DT == nil then
         DKROT_Settings.DT = {}
         DKROT_Settings.DT.Enable = true
         DKROT_Settings.DT.Target = true
         DKROT_Settings.DT.TPriority = true
         DKROT_Settings.DT.CColours = true
         DKROT_Settings.DT.TColours = true
      end
      if DKROT_Settings.DT.Update == nil then DKROT_Settings.DT.Update = 2.5 end
      if DKROT_Settings.DT.Numframes == nil then DKROT_Settings.DT.Numframes = 5 end
      if DKROT_Settings.DT.Warning == nil then DKROT_Settings.DT.Warning = 3 end
      if DKROT_Settings.DT.Threat == nil then DKROT_Settings.DT.Threat = THREAT_ANALOG end
      if DKROT_Settings.DT.Dots == nil then
         DKROT_Settings.DT.Dots = {}
         DKROT_Settings.DT.Dots[DKROT.spells["Frost Fever"]] = true
         DKROT_Settings.DT.Dots[DKROT.spells["Blood Plague"]] = true
         DKROT_Settings.DT.Dots[DKROT.spells["Death and Decay"]] = true
      end

      -- Frame Location
      if DKROT_Settings.Location == nil then DKROT_Settings.Location = {} end
      if DKROT_Settings.Location["DKROT"] == nil then
         DKROT_Settings.Location["DKROT"] = {
            Point = "Center",
            Rel = nil,
            RelPoint = "CENTER",
            X = 0,
            Y = 0,
            Scale = 1
         }
      end
      for idx, el in pairs(DKROT.MovableFrames) do
         if DKROT_Settings.Location[el.frame] == nil then
            DKROT_Settings.Location[el.frame] = DKROT.DefaultLocations[el.frame]
         end
      end

      DKROT_Settings.Version = DKROT_VERSION

      wipe(specs)
      wipe(spots)
      collectgarbage()
      DKROT:Debug("Check Settings Complete")
   end

   -- Set frame location back to Defaults
   function DKROT_SetLocationDefault()
      DKROT_Settings.Location = {}

      for idx, el in pairs(DKROT.MovableFrames) do
         DKROT_Settings.Location[el.frame] = DKROT:deepcopy(DKROT.DefaultLocations[el.frame])
      end

      -- DKROT:OptionsRefresh()
      DKROT:UpdatePosition()
      DKROT:Debug("SetLocationDefault Done")
   end

   -- Set all settings back to default
   function DKROT_SetDefaults()
      if DKROT_Settings ~= nil then wipe(DKROT_Settings); DKROT_Settings = nil end
      DKROT:CheckSettings()

      DKROT:OptionsRefresh()
      DKROT:Debug("SetDefaults Done")
   end

   function DKROT_Rune_DD_OnLoad()
      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[BBUUFF]
      info.value      = BBUUFF
      info.func       = function() DKROT_Settings.RuneOrder = BBUUFF; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[BBFFUU]
      info.value      = BBFFUU
      info.func       = function() DKROT_Settings.RuneOrder = BBFFUU; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[UUBBFF]
      info.value      = UUBBFF
      info.func       = function() DKROT_Settings.RuneOrder = UUBBFF; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[UUFFBB]
      info.value      = UUFFBB
      info.func       = function() DKROT_Settings.RuneOrder = UUFFBB; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[FFUUBB]
      info.value      = FFUUBB
      info.func       = function() DKROT_Settings.RuneOrder = FFUUBB; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[FFBBUU]
      info.value      = FFBBUU
      info.func       = function() DKROT_Settings.RuneOrder = FFBBUU; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)
   end

   function DKROT_DTPanel_Threat_OnLoad()
      info            = {}
      info.text       = DKROT_OPTIONS_DT_THREAT_OFF
      info.value      = THREAT_OFF
      info.func       = function() DKROT_Settings.DT.Threat = THREAT_OFF;UIDropDownMenu_SetSelectedValue(DKROT_DTPanel_DD_Threat, DKROT_Settings.DT.Threat); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_DT_THREAT_ANALOG
      info.value      = THREAT_ANALOG
      info.func       = function() DKROT_Settings.DT.Threat = THREAT_ANALOG;UIDropDownMenu_SetSelectedValue(DKROT_DTPanel_DD_Threat, DKROT_Settings.DT.Threat); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_DT_THREAT_DIGITAL
      info.value      = THREAT_DIGITAL
      info.func       = function() DKROT_Settings.DT.Threat = THREAT_DIGITAL;UIDropDownMenu_SetSelectedValue(DKROT_DTPanel_DD_Threat, DKROT_Settings.DT.Threat); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_DT_THREAT_HEALTH
      info.value      = THREAT_HEALTH
      info.func       = function() DKROT_Settings.DT.Threat = THREAT_HEALTH;UIDropDownMenu_SetSelectedValue(DKROT_DTPanel_DD_Threat, DKROT_Settings.DT.Threat); end
      UIDropDownMenu_AddButton(info)
   end

   -- function to handle the View dropdown box
   function DKROT_FramePanel_ViewDD_OnLoad()
      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_VIEW_NORM
      info.value      = DKROT_OPTIONS_FRAME_VIEW_NORM
      info.func       = function() DKROT_Settings.VScheme = DKROT_OPTIONS_FRAME_VIEW_NORM;UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_VIEW_TARGET
      info.value      = DKROT_OPTIONS_FRAME_VIEW_TARGET
      info.func       = function() DKROT_Settings.VScheme = DKROT_OPTIONS_FRAME_VIEW_TARGET;UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_VIEW_SHOW
      info.value      = DKROT_OPTIONS_FRAME_VIEW_SHOW
      info.func       = function() DKROT_Settings.VScheme = DKROT_OPTIONS_FRAME_VIEW_SHOW;UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_VIEW_HIDE
      info.value      = DKROT_OPTIONS_FRAME_VIEW_HIDE
      info.func       = function() DKROT_Settings.VScheme = DKROT_OPTIONS_FRAME_VIEW_HIDE;UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme); end
      UIDropDownMenu_AddButton(info)
   end

   -- function to handle the Disease dropdown box
   function DKROT_Diseases_OnLoad(self)
      local info = {}
      info.text = DKROT_OPTIONS_CDR_DISEASES_DD_BOTH
      info.value = DISEASE_BOTH
      info.func = function() DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption = DISEASE_BOTH;UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Diseases_DD,  DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption); end
      UIDropDownMenu_AddButton(info)

      info = {}
      info.text = DKROT_OPTIONS_CDR_DISEASES_DD_ONE
      info.value = DISEASE_ONE
      info.func = function() DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption = DISEASE_ONE;UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Diseases_DD,  DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption); end
      UIDropDownMenu_AddButton(info)

      info = {}
      info.text = DKROT_OPTIONS_CDR_DISEASES_DD_NONE
      info.value = DISEASE_NONE
      info.func = function() DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption = DISEASE_NONE;UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Diseases_DD,  DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption); end
      UIDropDownMenu_AddButton(info)
   end

   -- Initialize the rotation list
   function DKROT_Rotations_OnLoad(self)
      for key, rotation in pairs(DKROT.Rotations[DKROT.Current_Spec]) do
         local info = {}
         info.text = rotation.name
         info.value = key
         info.func = function()
            DKROT_Settings.CD[DKROT.Current_Spec].Rotation = key
            UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Rotation, DKROT_Settings.CD[DKROT.Current_Spec].Rotation)
         end
         UIDropDownMenu_AddButton(info)
      end

      -- Select rotation
      local current_rotation = DKROT_Settings.CD[DKROT.Current_Spec].Rotation
      if current_rotation == nil then
         if DKROT.Current_Spec ~= DKROT.SPECS.UNKNOWN then
            for rotName, rotInfo in pairs(DKROT.Rotations[DKROT.Current_Spec]) do
               if rotInfo.default == true then
                  current_rotation = rotName
                  break
               end
            end
            UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Rotation, current_rotation)
            UIDropDownMenu_SetText(DKROT_CDRPanel_Rotation, DKROT.Rotations[DKROT.Current_Spec][current_rotation].name)
         end
      end

      UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Rotation, current_rotation)
      UIDropDownMenu_SetText(DKROT_CDRPanel_Rotation, DKROT.Rotations[DKROT.Current_Spec][current_rotation].name)
   end

   -- function to handle the CD dropdown boxes
   function DKROT_CDRPanel_DD_OnLoad(self, level)
      -- If specified level, or base
      level = level or 1

      -- Template for an item in the dropdown box
      local function DKROT_CDRPanel_DD_Item (panel, spell, buff)
         local info = {}
         info.text = spell .. ((buff and " (Buff)") or "")
         info.value = spell .. ((buff and " (Buff)") or "")
         info.func = function()
            DKROT_Settings.CD[DKROT.Current_Spec][panel:GetName()][1] = spell
            DKROT_Settings.CD[DKROT.Current_Spec][panel:GetName()][2] = buff
            UIDropDownMenu_SetSelectedValue(panel, spell .. ((buff and " (Buff)") or ""))
            CloseDropDownMenus()
         end
         return info
      end

      -- Function to add specs specific CDs
      local function AddSpecCDs(Spec)
         for i = 1, #Spec do
            if (DKROT.Cooldowns.Buffs[Spec[i]] == nil or DKROT.Cooldowns.Buffs[Spec[i]][2]) then
               UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, Spec[i]), 2)
            end
            if DKROT.Cooldowns.Buffs[Spec[i]] ~= nil then
               UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, Spec[i], true), 2)
            end
         end
      end

      -- If base level
      if level == 1 then
         -- Add unique items to dropdown
         UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_CDR_CD_PRIORITY), 1)
         UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_CDR_CD_PRESENCE), 1)
         UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_FRAME_VIEW_NONE), 1)
         UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_CDR_RACIAL), 1)

         -- Setup nested dropdowns
         info.hasArrow = true
         info.notClickable = 1

         -- Spec Specific CDs
         info.text = DKROT_OPTIONS_CDR_CD_SPEC
         info.value = {["Level1_Key"] = "Spec";}
         UIDropDownMenu_AddButton(info)

         -- Normal CDs
         info.text = DKROT_OPTIONS_CDR_CD_NORMAL
         info.value = {["Level1_Key"] = "Normal";}
         UIDropDownMenu_AddButton(info)

         -- Moves
         info.text = DKROT_OPTIONS_CDR_CD_MOVES
         info.value = {["Level1_Key"] = "Moves";}
         UIDropDownMenu_AddButton(info)

         -- Talents
         info.text = DKROT_OPTIONS_CDR_CD_TALENTS
         info.value = {["Level1_Key"] = "Talents";}
         UIDropDownMenu_AddButton(info)

         -- Trinkets
         info.text = DKROT_OPTIONS_CDR_CD_TRINKETS
         info.value = {["Level1_Key"] = "Trinkets";}
         UIDropDownMenu_AddButton(info)

      -- If nested menu
      elseif level == 2 then
         -- Check what the "parent" is
         local key = UIDROPDOWNMENU_MENU_VALUE["Level1_Key"]

         if key == "Spec" then
            if (DKROT.Current_Spec == DKROT.SPECS.UNHOLY) then
               AddSpecCDs(DKROT.Cooldowns.UnholyCDs)
            elseif (DKROT.Current_Spec == DKROT.SPECS.FROST) then
               AddSpecCDs(DKROT.Cooldowns.FrostCDs)
            elseif (DKROT.Current_Spec == DKROT.SPECS.BLOOD) then
               AddSpecCDs(DKROT.Cooldowns.BloodCDs)
            end

         elseif key == "Normal" then
            AddSpecCDs(DKROT.Cooldowns.NormCDs)

         elseif key == "Moves" then
            for i = 1, #DKROT.Cooldowns.Moves do
               if GetSpellTexture(DKROT.Cooldowns.Moves[i]) ~= nil then
                  UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT.Cooldowns.Moves[i]), 2)
               end
            end

         elseif key == "Talents" then
            AddSpecCDs(DKROT.Cooldowns.TalentCDs)

         elseif key == "Trinkets" then
            UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT1), 2)
            UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT2), 2)
         end
      end
   end

   function DKROT:PositionUpdate()
      local el = _G[UIDropDownMenu_GetSelectedValue(DKROT_PositionPanel_Element)]
      local name = el:GetName()
      local x = DKROT.PositionPanel_X:GetValue()
      local y = DKROT.PositionPanel_Y:GetValue()
      local scale = DKROT.PositionPanel_Scale:GetValue()
      local point = UIDropDownMenu_GetSelectedValue(DKROT.PositionPanel_Point)
      local relPoint = UIDropDownMenu_GetSelectedValue(DKROT.PositionPanel_RelPoint)
      local relFrame = UIDropDownMenu_GetSelectedValue(DKROT.PositionPanel_RelFrame)

      DKROT_Settings.Location[name].X = x
      DKROT_Settings.Location[name].Y = y
      DKROT_Settings.Location[name].Scale = scale
      DKROT_Settings.Location[name].Point = point
      DKROT_Settings.Location[name].Rel = relFrame
      DKROT_Settings.Location[name].RelPoint = relPoint

      DKROT:MoveFrame(el)
   end
else
   print("DKRot: Not a DK")
   DKROT_Options = nil
   DKROT_FramePanel = nil
   DKROT_CDRPanel = nil
   DKROT_CDPanel = nil
   DKROT_ABOUTPanel = nil
end
