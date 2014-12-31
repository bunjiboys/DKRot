if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local function IcyVeins(icon)
      if DKROT_Settings.CD[DKROT.Current_Spec].AltRot then
         return DKROT:UnholyMoveAlt(icon)
      end

      --Rune Info
      local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local disease, move = DKROT:GetDisease(icon)
      local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))

      -- Raise Dead
      if GetSpellTexture(DKROT.spells["Raise Dead"]) ~= nil and UnitExists("pet") ~= true then
         return GetSpellTexture(DKROT.spells["Raise Dead"])
      end

      -- Death Pact
      if GetSpellTexture(DKROT.spells["Death Pact"]) ~= nil
         and (UnitHealth("player") / UnitHealthMax("player")) < 0.30
      then
         if DKROT:isOffCD(DKROT.spells["Death Pact"]) then
            return GetSpellTexture(DKROT.spells["Death Pact"])
         end
      end

      -- Soul Reaper
      if GetSpellTexture(DKROT.spells["Soul Reaper"]) ~= nil and (death >= 1 or unholy <= 0)
      then
         if (
               GetSpellTexture(DKROT.spells["Improved Soul Reaper"]) ~= nil
               and UnitHealth("target")/UnitHealthMax("target") < 0.45
            )
            or UnitHealth("target")/UnitHealthMax("target") < 0.35
         then
            if DKROT:isOffCD(DKROT.spells["Soul Reaper"]) then
               return DKROT:GetRangeandIcon(icon, DKROT.spells["Soul Reaper"])
            end
         end
      end

      -- Defile
      if GetSpellTexture(DKROT.spells["Defile"]) ~= nil then
         if DKROT:isOffCD(DKROT.spells["Defile"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Defile"])
         end
      end

      -- Diseases
      if disease then return move end

      -- Dark Transformation
      if GetSpellTexture(DKROT.spells["Dark Transformation"]) ~= nil
         and select(4, UnitBuff("PET",DKROT.spells["Shadow Infusion"])) == 5
         and (unholy <= 0 or death >= 1)
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Dark Transformation"])
      end

      -- Blood Tap with >= 11 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 11
         and (frost >= 0 or unholy >= 0 or blood >= 0)
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Blood Tap"])
      end

      -- Death Coil if ghoul is not transformed or have 5 stacks
      if DKROT_Settings.CD[DKROT.Current_Spec].RP
         and (
            UnitPower("player") >= 30
            or select(7, UnitBuff("PLAYER",DKROT.spells["Sudden Doom"])) ~= nil
         )
         and select(4, UnitBuff("PET",DKROT.spells["Shadow Infusion"])) ~= 5
         and UnitBuff("PET",DKROT.spells["Dark Transformation"]) == nil
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Death Coil"])
      end

      --Scourge Strike (UU are up or FF or BB are up as Deathrunes)
      if lunholy <= 0 or (lfrost <= 0 and (fd or lfd)) or (lblood <= 0 and (bd or lbd)) then
         if DKROT_Settings.MoveAltDND then
            --Death and Decay
            if GetSpellTexture(DKROT.spells["Death and Decay"]) ~= nil then
               if DKROT:isOffCD(DKROT.spells["Death and Decay"]) then
                  DKROT.Move.AOE:SetAlpha(1)
                  DKROT.Move.AOE.Icon:SetTexture(GetSpellTexture(DKROT.spells["Death and Decay"]))
               end
            end
         end
         if GetSpellTexture(DKROT.spells["Scourge Strike"]) ~= nil then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Scourge Strike"])
         else
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Plague Strike"])
         end
      end

      -- Festering Strike (BB and FF are up)
      if GetSpellTexture(DKROT.spells["Festering Strike"]) ~= nil then
         if lfrost <= 0 and lblood <= 0 then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Festering Strike"])
         end
      end

      -- Death Coil (Sudden Doom, high RP)
      if DKROT_Settings.CD[DKROT.Current_Spec].RP
         and (
            UnitPower("player") > 80
            or select(7, UnitBuff("PLAYER",DKROT.spells["Sudden Doom"])) ~= nil
         )
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Death Coil"])
      end

      -- Scourge Strike
      if unholy <= 0 or death >= 1 then
         if DKROT_Settings.MoveAltDND then
            --Death and Decay
            if GetSpellTexture(DKROT.spells["Death and Decay"]) ~= nil then
               if DKROT:isOffCD(DKROT.spells["Death and Decay"]) then
                  DKROT.Move.AOE:SetAlpha(1)
                  DKROT.Move.AOE.Icon:SetTexture(GetSpellTexture(DKROT.spells["Death and Decay"]))
               end
            end
         end
         if GetSpellTexture(DKROT.spells["Scourge Strike"]) ~= nil then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Scourge Strike"])
         else
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Plague Strike"])
         end
      end

      -- Festering Strike
      if GetSpellTexture(DKROT.spells["Festering Strike"]) ~= nil then
         if frost <= 0 and blood <= 0 then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Festering Strike"])
         end
      end

      --Blood Tap with >= 5 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 5
         and (frost >= 0 or unholy >= 0 or blood >= 0)
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Blood Tap"])
      end

      --Empower Rune Weapon
      if GetSpellTexture(DKROT.spells["Empower Rune Weapon"]) ~= nil and DKROT_Settings.CD[DKROT.Current_Spec].ERW then
         if DKROT:isOffCD(DKROT.spells["Empower Rune Weapon"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Empower Rune Weapon"])
         end
      end

      if GetSpellTexture(DKROT.spells["Death Coil"]) and UnitPower("player") >= 30 then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Death Coil"])
      end

      -- If nothing else can be done
      return nil
   end

   DKROT:RegisterRotation(DKROT.SPECS.UNHOLY, 'IcyVeins', 'Icy Veins', IcyVeins)

   -- Function to determine rotation for Unholy Spec
   function DKROT:UnholyMove(icon)
      return DKROT.Rotations[DKROT.SPECS.UNHOLY]["IcyVeins"]["func"](icon)
   end
end
