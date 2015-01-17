if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local function IcyVeins()
      -- Rune Info
      local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local bloodCharges = select(4,UnitBuff("player", DKROT.spells["Blood Charge"]))
      local timeToDie = DKROT:TimeToDie()

      -- Death Pact
      if GetSpellTexture(DKROT.spells["Death Pact"]) ~= nil
         and (UnitHealth("player") / UnitHealthMax("player")) < 0.30
      then
         if DKROT:isOffCD(DKROT.spells["Death Pact"]) then
            return DKROT.spells["Death Pact"], true
         end
      end

      -- Bone Shield
      if GetSpellTexture(DKROT.spells["Bone Shield"]) ~= nil
         and select(7, UnitBuff("player", DKROT.spells["Bone Shield"])) == nil
      then
         if DKROT:isOffCD(DKROT.spells["Bone Shield"]) then
            return DKROT.spells["Bone Shield"], true
         end
      end

      -- Horn of Winter
      if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
         return DKROT.spells["Horn of Winter"]
      end

      -- Defile
      if GetSpellTexture(DKROT.spells["Defile"]) ~= nil then
         if DKROT:isOffCD(DKROT.spells["Defile"]) then
            return DKROT.spells["Defile"], true
         end
      end

      -- Soul Reaper
      if lblood <= 2 and GetSpellTexture(DKROT.spells["Soul Reaper"]) ~= nil
         and UnitHealth("target")/UnitHealthMax("target") < 0.35
      then
         if DKROT:isOffCD(DKROT.spells["Soul Reaper"]) and timeToDie > 5 then
            return DKROT.spells["Soul Reaper"]
         end
      end

      -- Diseases
      local disease = DKROT:GetDisease()
      if disease ~= nil then
         return disease
      end

      -- Death Strike
      if GetSpellTexture(DKROT.spells["Death Strike"]) and select(1,IsUsableSpell(DKROT.spells["Death Strike"])) then
         return DKROT.spells["Death Strike"]
      end

      -- Breath of Sindragosa
      if GetSpellTexture(DKROT.spells["Breath of Sindragosa"]) ~= nil and UnitPower("player") > 30 then
         if DKROT:isOffCD(DKROT.spells["Breath of Sindragosa"]) then
            return DKROT.spells["Breath of Sindragosa"]
         end
      end

      -- Blood Tap with >= 11 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 11
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"]
      end

      -- Blood Boil if we have a blood rune
      if GetSpellTexture(DKROT.spells["Blood Boil"]) and blood <= 0 then
         return DKROT.spells["Blood Boil"]
      end

      -- Death Coil
      if UnitPower("player") >= 30 then
         return DKROT.spells["Death Coil"]
      end

      -- Crimson Scourge BB
      if select(7,UnitBuff("player", DKROT.spells["Crimson Scourge"])) ~= nil then
         return DKROT.spells["Blood Boil"]
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

   local function SimC()
      -- Rune Info
      local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local bloodCharges = select(4,UnitBuff("player", DKROT.spells["Blood Charge"]))
      local healthPct = (UnitHealth("PLAYER") / UnitHealthMax("PLAYER")) * 100
      local timeToDie = DKROT:TimeToDie()

      -- Death Pact
      if GetSpellTexture(DKROT.spells["Death Pact"]) and healthPct < 50 then
         if DKROT:isOffCD(DKROT.spells["Death Pact"]) then
            return DKROT.spells["Death Pact"], true
         end
      end

      -- Bone Shield
      if select(7, UnitBuff("player", DKROT.spells["Bone Shield"])) == nil then
         if DKROT:isOffCD(DKROT.spells["Bone Shield"]) then
            return DKROT.spells["Bone Shield"], true
         end
      end

      -- Horn of Winter
      if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
         return DKROT.spells["Horn of Winter"], true
      end

      -- Lichborne
      if GetSpellTexture(DKROT.spells["Lichborne"]) and UnitHealth("PLAYER") < 90 then
         if DKROT:isOffCD(DKROT.spells["Lichborne"]) then
            return DKROT.spells["Lichborne"], true
         end
      end

      -- Death Strike if we are below 60% health
      if healthPct < 60 and DKROT:isOffCD(DKROT.spells["Death Strike"]) then
         return DKROT.spells["Death Strike"]
      end

      -- Defile
      if GetSpellTexture(DKROT.spells["Defile"]) ~= nil then
         if DKROT:isOffCD(DKROT.spells["Defile"]) then
            return DKROT.spells["Defile"], true
         end
      end

      -- Soul Reaper
      if lblood <= 2 and GetSpellTexture(DKROT.spells["Soul Reaper"]) ~= nil
         and UnitHealth("target")/UnitHealthMax("target") < 0.35
      then
         if DKROT:isOffCD(DKROT.spells["Soul Reaper"]) and timeToDie > 5 then
            return DKROT.spells["Soul Reaper"]
         end
      end

      -- Diseases
      local disease = DKROT:GetDisease()
      if disease ~= nil then
         return disease
      end

      -- Dancing Rune Weapon
      if healthPct < 80 and DKROT:isOffCD(DKROT.spells["Dancing Rune Weapon"]) then
         return DKROT.spells["Dancing Rune Weapon"], true
      end

      -- Death Strike
      if (lunholy <= 0 or lfrost <= 0) and DKROT:isOffCD(DKROT.spells["Death Strike"]) then
         return DKROT.spells["Death Strike"]
      end

      -- Death Coil if more than 70 RP
      if UnitPower("PLAYER") >= 70 then
         return DKROT.spells["Death Coil"]
      end

      -- Blood Boil if we have a blood rune
      if lblood <= 0 or select(7,UnitBuff("player", DKROT.spells["Crimson Scourge"])) then
         return DKROT.spells["Blood Boil"]
      end

      -- Blood Tap with >= 5 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 5
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
      end

      -- Death Coil
      if UnitPower("player") >= 30 then
         return DKROT.spells["Death Coil"]
      end

      -- Empower Rune Weapon if we have it enabled and we have at least 3 runes depleted
      if GetSpellTexture(DKROT.spells["Empower Rune Weapon"]) ~= nil
         and DKROT_Settings.CD[DKROT.Current_Spec].ERW
         and DKROT:isOffCD(DKROT.spells["Empower Rune Weapon"])
         and DKROT:DepletedRunes() >= 3
      then
         return DKROT.spells["Empower Rune Weapon"]
      end

      -- If nothing else can be done
      return nil
   end

   DKROT_RegisterRotation(DKROT.SPECS.BLOOD, 'IcyVeins', 'Blood - Icy Veins', IcyVeins, false)
   DKROT_RegisterRotation(DKROT.SPECS.BLOOD, 'SimC', 'Blood - SimCraft', SimC, true)
end
