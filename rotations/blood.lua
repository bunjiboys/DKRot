if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   ivspells = { "Death Pact", "Defile", "Breath of Sindragosa", "Blood Tap", "Empower Rune Weapon" }
   local function IcyVeins()
      -- Rune Info
      local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local bloodCharges = select(4,UnitBuff("player", DKROT.spells["Blood Charge"]))
      local timeToDie = DKROT:GetTimeToDie()

      -- Death Pact
      if DKROT:CanUse("Death Pact") and DKROT:HealthPct("PLAYER") < 30 then
         if DKROT:isOffCD("Death Pact") then
            return DKROT.spells["Death Pact"], true
         end
      end

      -- Bone Shield
      if DKROT:has("Bone Shield") and select(7, UnitBuff("player", DKROT.spells["Bone Shield"])) == nil then
         if DKROT:isOffCD("Bone Shield") then
            return DKROT.spells["Bone Shield"], true
         end
      end

      -- Horn of Winter
      if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
         return DKROT.spells["Horn of Winter"]
      end

      -- Defile
      if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
         return DKROT.spells["Defile"], true
      end

      -- Soul Reaper
      if lblood <= 2 and DKROT:has("Soul Reaper") and DKROT:HealthPct("TARGET") < 35 then
         if DKROT:isOffCD("Soul Reaper") and timeToDie > 5 then
            return DKROT.spells["Soul Reaper"]
         end
      end

      -- Diseases
      local disease = DKROT:GetDisease()
      if disease ~= nil then
         return disease
      end

      -- Death Strike
      if select(1,IsUsableSpell(DKROT.spells["Death Strike"])) then
         return DKROT.spells["Death Strike"]
      end

      -- Breath of Sindragosa
      if DKROT:CanUse("Breath of Sindragosa") and UnitPower("player") > 30 then
         if DKROT:isOffCD("Breath of Sindragosa") then
            return DKROT.spells["Breath of Sindragosa"]
         end
      end

      -- Blood Tap with >= 11 Charges
      if DKROT:CanUse("Blood Tap") and bloodCharges ~= nil and bloodCharges >= 11 and DKROT:FullyDepletedRunes() > 0 then
         return DKROT.spells["Blood Tap"]
      end

      -- Blood Boil if we have a blood rune
      if blood <= 0 then
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
      if DKROT:CanUse("Blood Tap") and bloodCharges ~= nil and bloodCharges >= 5 and DKROT:FullyDepletedRunes() > 0 then
         return DKROT.spells["Blood Tap"], true
      end

      -- Empower Rune Weapon if we have it enabled and we have at least 3 runes depleted
      if DKROT:CanUse("Empower Rune Weapon")
         and DKROT:DepletedRunes() >= 3
      then
         if DKROT:isOffCD("Empower Rune Weapon") then
            return DKROT.spells["Empower Rune Weapon"]
         end
      end

      -- If nothing else can be done
      return nil
   end

   scspells = { "Death Pact", "Lichborne", "Defile", "Dancing Rune Weapon", "Breath of Sindragosa", "Blood Tap", "Empower Rune Weapon" }
   local function SimC()
      -- Rune Info
      local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local bloodCharges = select(4,UnitBuff("player", DKROT.spells["Blood Charge"]))
      local healthPct = (UnitHealth("PLAYER") / UnitHealthMax("PLAYER")) * 100
      local timeToDie = DKROT:GetTimeToDie()

      -- Death Pact
      if DKROT:has("Death Pact") and healthPct < 50 then
         if DKROT:isOffCD("Death Pact") then
            return DKROT.spells["Death Pact"], true
         end
      end

      -- Bone Shield
      if select(7, UnitBuff("player", DKROT.spells["Bone Shield"])) == nil then
         if DKROT:isOffCD("Bone Shield") then
            return DKROT.spells["Bone Shield"], true
         end
      end

      -- Horn of Winter
      if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
         return DKROT.spells["Horn of Winter"], true
      end

      -- Lichborne
      if DKROT:CanUse("Lichborne") and UnitHealth("PLAYER") < 90 then
         if DKROT:isOffCD("Lichborne") then
            return DKROT.spells["Lichborne"], true
         end
      end

      -- Death Strike if we are below 60% health
      if healthPct < 60 and DKROT:isOffCD("Death Strike") then
         return DKROT.spells["Death Strike"]
      end

      -- Defile
      if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
         return DKROT.spells["Defile"], true
      end

      -- Soul Reaper
      if lblood <= 2 and DKROT:CanUse("Soul Reaper") and DKROT:HealthPct("TARGET") < 35 then
         if DKROT:isOffCD("Soul Reaper") and timeToDie > 5 then
            return DKROT.spells["Soul Reaper"]
         end
      end

      -- Diseases
      local disease = DKROT:GetDisease()
      if disease ~= nil then
         return disease
      end

      -- Dancing Rune Weapon
      if DKROT:CanUse("Dancing Rune Weapon") and healthPct < 80 and DKROT:isOffCD("Dancing Rune Weapon") then
         if DKROT:BossOrPlayer("TARGET") then
            return DKROT.spells["Dancing Rune Weapon"], true
         end
      end

      -- Death Strike
      if (lunholy <= 0 or lfrost <= 0) and DKROT:isOffCD("Death Strike") then
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
      if DKROT:CanUse("Blood Tap")
         and bloodCharges ~= nil and bloodCharges >= 5
         and DKROT:FullyDepletedRunes() > 0
      then
         return DKROT.spells["Blood Tap"], true
      end

      -- Death Coil
      if UnitPower("player") >= 30 then
         return DKROT.spells["Death Coil"]
      end

      -- Empower Rune Weapon if we have it enabled and we have at least 3 runes depleted
      if DKROT:CanUse("Empower Rune Weapon")
         and DKROT:isOffCD("Empower Rune Weapon")
         and DKROT:DepletedRunes() >= 3
         and DKROT:BossOrPlayer("TARGET")
      then
         return DKROT.spells["Empower Rune Weapon"]
      end

      -- If nothing else can be done
      return nil
   end

   DKROT_RegisterRotation(DKROT.SPECS.BLOOD, 'IcyVeins', 'Blood - Icy Veins', IcyVeins, false, ivspells)
   DKROT_RegisterRotation(DKROT.SPECS.BLOOD, 'SimC', 'Blood - SimCraft', SimC, true, scspells)
end
