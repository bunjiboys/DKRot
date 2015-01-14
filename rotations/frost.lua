if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local function IcyVeins2H()
      -- Rune Info
      local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))
 
      -- Horn of Winter
      if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
         return DKROT.spells["Horn of Winter"]
      end

      -- Death Pact
      if GetSpellTexture(DKROT.spells["Death Pact"]) ~= nil
         and (UnitHealth("player") / UnitHealthMax("player")) < 0.30
      then
         if DKROT:isOffCD(DKROT.spells["Death Pact"]) then
            return DKROT.spells["Death Pact"], true
         end
      end

      -- Soul Reaper
      if GetSpellTexture(DKROT.spells["Soul Reaper"]) ~= nil
         and UnitHealth("target")/UnitHealthMax("target") < 0.35
      then
         if DKROT:isOffCD(DKROT.spells["Soul Reaper"]) then
            return DKROT.spells["Soul Reaper"]
         end
      end

      -- Defile
      if GetSpellTexture(DKROT.spells["Defile"]) ~= nil then
         if DKROT:isOffCD(DKROT.spells["Defile"]) then
            return DKROT.spells["Defile"], true
         end
      end

      -- Diseases
      local disease = DKROT:GetDisease()
      if disease ~= nil then
         return disease
      end

      -- Breath of Sindragosa
      if GetSpellTexture(DKROT.spells["Breath of Sindragosa"]) ~= nil and UnitPower("player") > 30 then
         if DKROT:isOffCD(DKROT.spells["Breath of Sindragosa"]) then
            return DKROT.spells["Breath of Sindragosa"]
         end
      end

      -- Obliterate with killing machine or runes overcaped
      if GetSpellTexture(DKROT.spells["Obliterate"]) ~= nil
         and select(1,IsUsableSpell(DKROT.spells["Obliterate"]))
         and (select(7,UnitBuff("player", DKROT.spells["Killing Machine"])) ~= nil
         or (lfrost <= 0 or lunholy <= 0 or (lblood <= 0 and lbd)))
      then
         return DKROT.spells["Obliterate"]
      end

      -- Blood Tap with >= 11 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 11
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
      end

      -- Frost Strike if rp overcaped
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") > 76 then
         return DKROT.spells["Frost Strike"]
      end

      -- Obliterate
      if GetSpellTexture(DKROT.spells["Obliterate"]) ~= nil then
         if select(1,IsUsableSpell(DKROT.spells["Obliterate"])) then
            return DKROT.spells["Obliterate"]
         end
      else
         -- Howling Blast
         if frost <= 0 then
            return DKROT.spells["Howling Blast"]
         end

         -- Plague Strike
         if unholy <= 0 then
            return DKROT.spells["Plague Strike"]
         end
      end

      -- Rime Howling Blast
      if select(7,UnitBuff("player", DKROT.spells["Freezing Fog"])) ~= nil then
         return DKROT.spells["Howling Blast"]
      end

      -- Frost Strike
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") >= 25 then
         return DKROT.spells["Frost Strike"]
      end

      -- Blood Tap with >= 5 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 5
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
      end

      -- Empower Rune Weapon if we have it enabled and we have at least 3 runes depleted
      if GetSpellTexture(DKROT.spells["Empower Rune Weapon"]) ~= nil
         and DKROT_Settings.CD[DKROT.Current_Spec].ERW
         and DKROT:DepletedRunes() >= 3
      then
         if DKROT:isOffCD(DKROT.spells["Empower Rune Weapon"]) then
            return DKROT.spells["Empower Rune Weapon"]
         end
      end

      -- If nothing else can be done
      return nil
   end
      
   local function IcyVeinsDualWield()
      -- Rune Info
      local frost, lfrost = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))
 
      -- Horn of Winter
      if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
         return DKROT.spells["Horn of Winter"]
      end

      -- Death Pact
      if GetSpellTexture(DKROT.spells["Death Pact"]) ~= nil
         and (UnitHealth("player") / UnitHealthMax("player")) < 0.30
      then
         if DKROT:isOffCD(DKROT.spells["Death Pact"]) then
            return DKROT.spells["Death Pact"], true
         end
      end

      -- Soul Reaper
      if GetSpellTexture(DKROT.spells["Soul Reaper"]) ~= nil
         and (death >= 1 or frost <= 0)
         and UnitHealth("target")/UnitHealthMax("target") < 0.35
      then
         if DKROT:isOffCD(DKROT.spells["Soul Reaper"]) then
            return DKROT.spells["Soul Reaper"]
         end
      end

      -- Defile
      if GetSpellTexture(DKROT.spells["Defile"]) ~= nil then
         if DKROT:isOffCD(DKROT.spells["Defile"]) then
            return DKROT.spells["Defile"], true
         end
      end

      -- Breath of Sindragosa
      if GetSpellTexture(DKROT.spells["Breath of Sindragosa"]) ~= nil and UnitPower("player") > 30 then
         if DKROT:isOffCD(DKROT.spells["Breath of Sindragosa"]) then
            return DKROT.spells["Breath of Sindragosa"]
         end
      end

      --Blood Tap with >= 11 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 11
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
      end

      --Frost Strike if Killing Machine is procced
      if DKROT_Settings.CD[DKROT.Current_Spec].RP
         and UnitPower("player") >= 25
         and select(7,UnitBuff("player", DKROT.spells["Killing Machine"])) ~= nil
      then
         return DKROT.spells["Frost Strike"]
      end

      -- Frost Strike if RP capped
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") > 88 then
         return DKROT.spells["Frost Strike"]
      end

      -- Diseases
      local disease = DKROT:GetDisease()
      if disease ~= nil then
         return disease
      end

      -- Howling Blast with both frost or both death off cooldown
      if lblood <= 0 or lfrost <= 0 then
         return DKROT.spells["Howling Blast"]
      end

      -- Obliterate when Killing Machine is procced and both Unholy Runes are off cooldown
      if GetSpellTexture(DKROT.spells["Obliterate"])~=nil
         and select(1,IsUsableSpell(DKROT.spells["Obliterate"]))
         and lunholy <= 0
         and select(7,UnitBuff("player", DKROT.spells["Killing Machine"])) ~= nil
      then
         return DKROT.spells["Obliterate"]
      end

      -- Howling Blast if Rime procced
      if select(7,UnitBuff("player", DKROT.spells["Freezing Fog"])) ~= nil then
         return DKROT.spells["Howling Blast"]
      end

      -- Obliterate when second Unholy Rune is nearly off cooldown
      if GetSpellTexture(DKROT.spells["Obliterate"])~=nil then
         if lunholy <= 2 and not ud and (frost <= 0 or blood <= 0) then
            return DKROT.spells["Obliterate"]
         end
      end

      -- Howling Blast
      if death >= 1 or frost <= 0 then
         return DKROT.spells["Howling Blast"]
      end

      -- Blood Tap with >= 5 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 5
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
      end

      -- Frost Strike
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") > 39 then
         return DKROT.spells["Frost Strike"]
      end

      -- Empower Rune Weapon if we have it enabled and we have at least 3 runes depleted
      if GetSpellTexture(DKROT.spells["Empower Rune Weapon"]) ~= nil
         and DKROT_Settings.CD[DKROT.Current_Spec].ERW
         and DKROT:DepletedRunes() >= 3
      then
         if DKROT:isOffCD(DKROT.spells["Empower Rune Weapon"]) then
            return DKROT.spells["Empower Rune Weapon"]
         end
      end

      -- If nothing else can be done
      return nil
   end

   local function SimC2H()
      -- Rune Info
      local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local dFF, dBP = DKROT:GetDiseaseTime()
      local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))
 
      -- Death Pact
      if GetSpellTexture(DKROT.spells["Death Pact"]) ~= nil
         and (UnitHealth("player") / UnitHealthMax("player")) < 0.30
      then
         if DKROT:isOffCD(DKROT.spells["Death Pact"]) then
            return DKROT.spells["Death Pact"], true
         end
      end

      -- Plague Leech if we have enabled it in the rotation, and we have a fully depleted rune
      if GetSpellTexture(DKROT.spells["Plague Leech"])
         and DKROT:isOffCD(DKROT.spells["Plague Leech"])
         and DKROT:HasFullyDepletedRunes()
         and (dFF ~= nil and dBP ~= nil and dFF > 0 and dBP > 0)
         and DKROT_Settings.CD[DKROT.Current_Spec].PL
      then
         return DKROT.spells["Plague Leech"]
      end

      -- Soul Reaper
      if GetSpellTexture(DKROT.spells["Soul Reaper"]) ~= nil
         and UnitHealth("target")/UnitHealthMax("target") < 0.35
      then
         if DKROT:isOffCD(DKROT.spells["Soul Reaper"]) then
            return DKROT.spells["Soul Reaper"]
         end
      end

      -- Defile
      if GetSpellTexture(DKROT.spells["Defile"]) ~= nil then
         if DKROT:isOffCD(DKROT.spells["Defile"]) then
            return DKROT.spells["Defile"]
         end
      end
 
      -- Rime Howling Blast if we need to refresh
      local rimeProc = select(7, UnitBuff("player", DKROT.spells["Freezing Fog"]))
      if rimeProc ~= nil 
         and (dFF == nil or dFF < 5)
      then
         return DKROT.spells["Howling Blast"]
      end

      -- Diseases
      local disease = DKROT:GetDisease()
      if disease ~= nil then
         return disease
      end

      -- Breath of Sindragosa
      if GetSpellTexture(DKROT.spells["Breath of Sindragosa"]) ~= nil and UnitPower("player") > 75 then
         if DKROT:isOffCD(DKROT.spells["Breath of Sindragosa"]) then
            return DKROT.spells["Breath of Sindragosa"]
         end
      end

      -- Obliterate with killing machine or runes overcaped
      if GetSpellTexture(DKROT.spells["Obliterate"]) ~= nil
         and select(1,IsUsableSpell(DKROT.spells["Obliterate"]))
         and (select(7,UnitBuff("player", DKROT.spells["Killing Machine"])) ~= nil
         or (lfrost <= 0 or lunholy <= 0 or (lblood <= 0 and lbd)))
      then
         return DKROT.spells["Obliterate"]
      end

      -- Blood Tap with >= 11 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 11
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
      end

      -- Frost Strike if rp overcaped
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") > 76 then
         return DKROT.spells["Frost Strike"]
      end
 
      -- Howling Blast if Rime is procced
      if rimeProc ~= nil then
         return DKROT.spells["Howling Blast"]
      end

      -- Obliterate
      if GetSpellTexture(DKROT.spells["Obliterate"]) ~= nil then
         if select(1,IsUsableSpell(DKROT.spells["Obliterate"])) then
            return DKROT.spells["Obliterate"]
         end
      else
         -- Howling Blast
         if frost <= 0 then
            return DKROT.spells["Howling Blast"]
         end

         --Plague Strike
         if unholy <= 0 then
            return DKROT.spells["Plague Strike"]
         end
      end

      -- Frost Strike
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") >= 25 then
         return DKROT.spells["Frost Strike"]
      end

      -- Blood Tap with >= 5 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 5
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
      end

      -- Empower Rune Weapon if we have it enabled and we have at least 3 runes depleted
      if GetSpellTexture(DKROT.spells["Empower Rune Weapon"]) ~= nil
         and DKROT_Settings.CD[DKROT.Current_Spec].ERW
         and DKROT:DepletedRunes() >= 3
      then
         if DKROT:isOffCD(DKROT.spells["Empower Rune Weapon"]) then
            return DKROT.spells["Empower Rune Weapon"]
         end
      end

      -- If nothing else can be done
      return nil
   end

   DKROT_RegisterRotation(DKROT.SPECS.FROST, 'IcyVeins2H', '2H Frost - Icy Veins', IcyVeins2H, false)
   DKROT_RegisterRotation(DKROT.SPECS.FROST, 'IcyVeinsDualWield', 'Dual Wield Frost - Icy Veins', IcyVeinsDualWield, false)
   DKROT_RegisterRotation(DKROT.SPECS.FROST, 'SimC2H', '2H Frost - SimCraft', SimC2H, true)
end
