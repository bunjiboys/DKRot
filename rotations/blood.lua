-- vim: set ts=3 sw=3 foldmethod=indent:
if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local icyveins = {
      Name = "Icy Veins",
      InternalName = "IcyVeins",
      ToggleSpells = { "Outbreak", "Death Pact", "Defile", "Breath of Sindragosa", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { },
      DefaultRotation = false,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local bloodCharges = select(4,UnitBuff("player", DKROT.spells["Blood Charge"]))

         -- Death Pact
         if DKROT:CanUse("Death Pact") and DKROT:HealthPct("PLAYER") < 30 then
            if DKROT:isOffCD("Death Pact") then
               return "Death Pact", true
            end
         end

         -- Bone Shield
         if DKROT:has("Bone Shield") and select(7, UnitBuff("player", DKROT.spells["Bone Shield"])) == nil then
            if DKROT:isOffCD("Bone Shield") then
               return "Bone Shield", true
            end
         end

         -- Horn of Winter
         if DKROT:CanUse("Horn of Winter") and DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return "Defile", true
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Diseases
         local disease = DKROT:GetDisease()
         if disease ~= nil then
            return disease
         end

         -- Death Strike
         if DKROT:CanUse("Death Strike") and select(1,IsUsableSpell(DKROT.spells["Death Strike"])) then
            return "Death Strike"
         end

         -- Breath of Sindragosa
         if DKROT:CanUse("Breath of Sindragosa") and UnitPower("player") > 30 then
            if DKROT:isOffCD("Breath of Sindragosa") then
               return "Breath of Sindragosa"
            end
         end

         -- Blood Tap with >= 11 Charges
         if DKROT:CanUse("Blood Tap") and bloodCharges ~= nil and bloodCharges >= 11 and DKROT:FullyDepletedRunes() > 0 then
            return "Blood Tap"
         end

         -- Blood Boil if we have a blood rune
         if blood <= 0 then
            return "Blood Boil"
         end

         -- Death Coil
         if UnitPower("player") >= 30 then
            return "Death Coil"
         end

         -- Crimson Scourge BB
         if select(7,UnitBuff("player", DKROT.spells["Crimson Scourge"])) ~= nil then
            return "Blood Boil"
         end

         -- Blood Tap with >= 5 Charges
         if DKROT:CanUse("Blood Tap") and bloodCharges ~= nil and bloodCharges >= 5 and DKROT:FullyDepletedRunes() > 0 then
            return "Blood Tap", true
         end

         -- Empower Rune Weapon if we have it enabled and we have at least 3 runes depleted
         if DKROT:CanUse("Empower Rune Weapon")
            and DKROT:DepletedRunes() >= 3
         then
            if DKROT:isOffCD("Empower Rune Weapon") then
               return "Empower Rune Weapon"
            end
         end

         -- If nothing else can be done
         return nil
      end
   }

   local simcraft = {
      Name = "SimCraft",
      InternalName = "SimC",
      ToggleSpells = { "Outbreak", "Death Pact", "Lichborne", "Defile", "Dancing Rune Weapon", "Breath of Sindragosa", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { },
      DefaultRotation = true,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local bloodCharges = select(4,UnitBuff("player", DKROT.spells["Blood Charge"]))
         local healthPct = (UnitHealth("PLAYER") / UnitHealthMax("PLAYER")) * 100

         -- Death Pact
         if DKROT:has("Death Pact") and healthPct < 50 and DKROT:isOffCD("Death Pact") then
            return "Death Pact", true
         end

         -- Bone Shield
         if select(7, UnitBuff("player", DKROT.spells["Bone Shield"])) == nil and DKROT:isOffCD("Bone Shield") then
            return "Bone Shield", true
         end

         -- Horn of Winter
         if DKROT:CanUse("Horn of Winter") and DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter", true
         end

         -- Lichborne
         if DKROT:CanUse("Lichborne") and UnitHealth("PLAYER") < 90 and DKROT:isOffCD("Lichborne") then
            return "Lichborne", true
         end

         -- Death Strike if we are below 60% health
         if healthPct < 60 and DKROT:isOffCD("Death Strike") then
            return "Death Strike"
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return "Defile", true
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Diseases
         local disease = DKROT:GetDisease()
         if disease ~= nil then
            return disease
         end

         -- Dancing Rune Weapon
         if DKROT:CanUse("Dancing Rune Weapon") and healthPct < 80 and DKROT:isOffCD("Dancing Rune Weapon") then
            if DKROT:BossOrPlayer("TARGET") then
               return "Dancing Rune Weapon", true
            end
         end

         -- Death Strike
         if DKROT:CanUse("Death Strike") and (lunholy <= 0 or lfrost <= 0) and DKROT:isOffCD("Death Strike") then
            return "Death Strike"
         end

         -- Death Coil if more than 70 RP
         if UnitPower("PLAYER") >= 70 then
            return "Death Coil"
         end

         -- Blood Boil if we have a blood rune
         if lblood <= 0 or select(7,UnitBuff("player", DKROT.spells["Crimson Scourge"])) then
            return "Blood Boil"
         end

         -- Blood Tap with >= 5 Charges
         if DKROT:CanUse("Blood Tap")
            and bloodCharges ~= nil and bloodCharges >= 5
            and DKROT:FullyDepletedRunes() > 0
         then
            return "Blood Tap", true
         end

         -- Death Coil
         if UnitPower("player") >= 30 then
            return "Death Coil"
         end

         -- Empower Rune Weapon if we have it enabled and we have at least 3 runes depleted
         if DKROT:CanUse("Empower Rune Weapon")
            and DKROT:isOffCD("Empower Rune Weapon")
            and DKROT:DepletedRunes() >= 3
            and DKROT:BossOrPlayer("TARGET")
         then
            return "Empower Rune Weapon"
         end

         -- If nothing else can be done
         return nil
      end
   }

   local troxismdef = {
      Name = "Troxism - Defile",
      InternalName = "TroxismDef",
      ToggleSpells = { "Outbreak", "Death Pact", "Defile", "Dancing Rune Weapon", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { },
      DefaultRotation = false,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local bloodCharges = select(4,UnitBuff("player", DKROT.spells["Blood Charge"]))
         local healthPct = (UnitHealth("PLAYER") / UnitHealthMax("PLAYER")) * 100
         local crimsonProc = select(4, UnitBuff("PLAYER", DKROT.spells["Crimson Scourge"]))
         local rp = UnitPower("PLAYER")
         local boneShield = select(7, UnitBuff("player", DKROT.spells["Bone Shield"]))

         -- Death Pact
         if DKROT:has("Death Pact") and healthPct < 50 and DKROT:isOffCD("Death Pact") then
            return "Death Pact", true
         end

         -- Bone Shield
         if boneShield and DKROT:isOffCD("Bone Shield") then
            return "Bone Shield", true
         end

         -- Horn of Winter
         if DKROT:CanUse("Horn of Winter") and DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter", true
         end

         -- Death Strike if we are below 70% health or runes are about to cap
         if DKROT:CanUse("Death Strike") and healthPct < 70 or (lunholy <= 1 or lfrost <= 1) and DKROT:isOffCD("Death Strike") then
            return "Death Strike"
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Blood Boil if we are or are about to cap blood runes
         if lblood <= 1 then
            return "Blood Boil"
         end

         -- Diseases
         local disease = DKROT:GetDisease()
         if disease ~= nil then
            return disease
         end

         if crimsonProc then
            if DKROT:isOffCD("Defile") and DKROT:CanUse("Defile") then
               return "Defile"
            else
               return "Blood Boil"
            end
         end

         -- Dancing Rune Weapon
         if DKROT:CanUse("Dancing Rune Weapon") and healthPct < 80 and DKROT:isOffCD("Dancing Rune Weapon") then
            if DKROT:BossOrPlayer("TARGET") then
               return "Dancing Rune Weapon", true
            end
         end

         -- Death Coil
         if rp >= 50 then
            return "Death Coil"
         end

         -- Blood Tap with >= 5 Charges
         if DKROT:CanUse("Blood Tap")
            and bloodCharges ~= nil and bloodCharges >= 5
            and DKROT:FullyDepletedRunes() > 0
         then
            return "Blood Tap", true
         end

         -- Plague Leech
         if DKROT:CanUse("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 and DKROT:isOffCD("Outbreak") then
            if DKROT:isOffCD("Plague Leech") then
               return "Plague Leech"
            end
         end

         -- Empower Rune Weapon if we have it enabled and all runes are depleted
         if DKROT:CanUse("Empower Rune Weapon")
            and DKROT:isOffCD("Empower Rune Weapon")
            and DKROT:DepletedRunes() >= 3
            and DKROT:BossOrPlayer("TARGET")
         then
            return "Empower Rune Weapon"
         end

         -- If nothing else can be done
         return nil
      end
   }

   DKROT_RegisterRotation(DKROT.SPECS.BLOOD, icyveins)
   DKROT_RegisterRotation(DKROT.SPECS.BLOOD, simcraft)
   DKROT_RegisterRotation(DKROT.SPECS.BLOOD, troxismdef)
end
