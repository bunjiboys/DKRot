if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local function IcyVeins2H(icon)
      --Rune Info
      local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()

      -- Death Pact
      if GetSpellTexture(DKROT.spells["Death Pact"]) ~= nil
         and (UnitHealth("player") / UnitHealthMax("player")) < 0.30
      then
         if DKROT:isOffCD(DKROT.spells["Death Pact"]) then
            return GetSpellTexture(DKROT.spells["Death Pact"])
         end
      end

      if GetSpellTexture(DKROT.spells["Soul Reaper"]) ~= nil
         and UnitHealth("target")/UnitHealthMax("target") < 0.35
      then
         if DKROT:isOffCD(DKROT.spells["Soul Reaper"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Soul Reaper"])
         end
      end

      -- Defile
      if GetSpellTexture(DKROT.spells["Defile"]) ~= nil then
         if DKROT:isOffCD(DKROT.spells["Defile"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Defile"])
         end
      end

      --Diseases
      local disease, move = DKROT:GetDisease(icon)
      if disease then return move end
      local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))

      -- Breath of Sindragosa
      if GetSpellTexture(DKROT.spells["Breath of Sindragosa"]) ~= nil and UnitPower("player") > 30 then
         if DKROT:isOffCD(DKROT.spells["Breath of Sindragosa"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Breath of Sindragosa"])
         end
      end

      --Obliterate with killing machine or runes overcaped
      if GetSpellTexture(DKROT.spells["Obliterate"]) ~= nil
         and select(1,IsUsableSpell(DKROT.spells["Obliterate"]))
         and (select(7,UnitBuff("player", DKROT.spells["Killing Machine"])) ~= nil
         or (lfrost <= 0 or lunholy <= 0 or (lblood <= 0 and lbd)))
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Obliterate"])
      end

      --Blood Tap with >= 11 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 11
         and (frost >= 0 or unholy >= 0 or blood >= 0)
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Blood Tap"])
      end

      --Frost Strike if rp overcaped
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") > 76 then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Frost Strike"])
      end

      --Obliterate
      if GetSpellTexture(DKROT.spells["Obliterate"]) ~= nil then
         if select(1,IsUsableSpell(DKROT.spells["Obliterate"])) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Obliterate"])
         end
      else
         --Howling Blast
         if frost <= 0 then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Howling Blast"])
         end

         --Plague Strike
         if unholy <= 0 then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Plague Strike"])
         end
      end

      --Rime Howling Blast
      if select(7,UnitBuff("player", DKROT.spells["Freezing Fog"])) ~= nil then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Howling Blast"])
      end

      --Frost Strike
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") >= 25 then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Frost Strike"])
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
      if GetSpellTexture(DKROT.spells["Empower Rune Weapon"]) ~= nil
      and DKROT_Settings.CD[DKROT.Current_Spec].ERW then
         if DKROT:isOffCD(DKROT.spells["Empower Rune Weapon"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Empower Rune Weapon"])
         end
      end

      -- If nothing else can be done
      return nil
   end
      
   local function IcyVeinsDualWield(icon)
      --Rune Info
      local frost, lfrost = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))

      -- Death Pact
      if GetSpellTexture(DKROT.spells["Death Pact"]) ~= nil
         and (UnitHealth("player") / UnitHealthMax("player")) < 0.30
      then
         if DKROT:isOffCD(DKROT.spells["Death Pact"]) then
            return GetSpellTexture(DKROT.spells["Death Pact"])
         end
      end

      --Soul Reaper
      if GetSpellTexture(DKROT.spells["Soul Reaper"]) ~= nil
         and (death >= 1 or frost <= 0)
         and UnitHealth("target")/UnitHealthMax("target") < 0.35
      then
         if DKROT:isOffCD(DKROT.spells["Soul Reaper"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Soul Reaper"])
         end
      end

      -- Defile
      if GetSpellTexture(DKROT.spells["Defile"]) ~= nil then
         if DKROT:isOffCD(DKROT.spells["Defile"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Defile"])
         end
      end

      -- Breath of Sindragosa
      if GetSpellTexture(DKROT.spells["Breath of Sindragosa"]) ~= nil and UnitPower("player") > 30 then
         if DKROT:isOffCD(DKROT.spells["Breath of Sindragosa"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Breath of Sindragosa"])
         end
      end

      --Blood Tap with >= 11 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 11
         and (frost >= 0 or unholy >= 0 or blood >= 0)
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Blood Tap"])
      end

      --Frost Strike if Killing Machine is procced
      if DKROT_Settings.CD[DKROT.Current_Spec].RP
         and UnitPower("player") >= 25
         and select(7,UnitBuff("player", DKROT.spells["Killing Machine"])) ~= nil
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Frost Strike"])
      end

      --Frost Strike if RP capped
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") > 88 then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Frost Strike"])
      end

      --Diseases
      local disease, move = DKROT:GetDisease(icon)
      if disease then return move end

      --Death and Decay
      if GetSpellTexture(DKROT.spells["Death and Decay"]) ~= nil
         and DKROT_Settings.MoveAltDND and lunholy <= 0
      then
         if DKROT:isOffCD(DKROT.spells["Death and Decay"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Death and Decay"])
         end
      end

      --Howling Blast with both frost or both death off cooldown
      if lblood <= 0 or lfrost <= 0 then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Howling Blast"])
      end

      --Obliterate when Killing Machine is procced and both Unholy Runes are off cooldown
      if GetSpellTexture(DKROT.spells["Obliterate"])~=nil
         and select(1,IsUsableSpell(DKROT.spells["Obliterate"]))
         and lunholy <= 0
         and select(7,UnitBuff("player", DKROT.spells["Killing Machine"])) ~= nil
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Obliterate"])
      end

      --Howling Blast if Rime procced
      if select(7,UnitBuff("player", DKROT.spells["Freezing Fog"])) ~= nil then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Howling Blast"])
      end

      --Obliterate when second Unholy Rune is nearly off cooldown
      if GetSpellTexture(DKROT.spells["Obliterate"])~=nil then
         if lunholy <= 2 and not ud and (frost <= 0 or blood <= 0) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Obliterate"])
         end
      else --Plague Strike
         if unholy <= 0 then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Plague Strike"])
         end
      end

      --Howling Blast
      if death >= 1 or frost <= 0 then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Howling Blast"])
      end

      --Blood Tap with >= 5 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 5
         and (frost >= 0 or unholy >= 0 or blood >= 0)
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Blood Tap"])
      end

      --Frost Strike
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") > 39 then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Frost Strike"])
      end

      --Empower Rune Weapon
      if GetSpellTexture(DKROT.spells["Empower Rune Weapon"]) ~= nil
      and DKROT_Settings.CD[DKROT.Current_Spec].ERW then
         if DKROT:isOffCD(DKROT.spells["Empower Rune Weapon"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Empower Rune Weapon"])
         end
      end

      --If nothing else can be done
      return nil
   end

   DKROT:RegisterRotation(DKROT.SPECS.FROST, 'IcyVeins2H', 'Icy Veins - Twohand', IcyVeins2H)
   DKROT:RegisterRotation(DKROT.SPECS.FROST, 'IcyVeinsDualWield', 'Icy Veins - Dual Wield', IcyVeinsDualWield)

   -- Function to determine rotation for Frost Spec
   function DKROT:FrostMove(icon)
      if DKROT_Settings.CD[DKROT.Current_Spec].AltRot then
         return DKROT.Rotations[DKROT.SPECS.FROST]["IcyVeinsDualWield"]["func"](icon)
      end

      return DKROT.Rotations[DKROT.SPECS.FROST]["IcyVeins2H"]["func"](icon)
   end
end
