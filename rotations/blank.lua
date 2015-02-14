if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local blank = {
      Name = "No Spec",
      InternalName = "BlankMove",
      ToggleSpells = { "Death Pact", "Blood Tap", "Army of the Dead" },
      SuggestedTalents = { },
      DefaultRotation = true,
      MainRotation = function()
         -- Rune Info
         local frost = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))

         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return DKROT.spells["Horn of Winter"]
         end

         -- Diseases
         local disease = DKROT:GetDisease()
         if disease ~= nil then
            return disease
         end

         -- Death Pact
         if DKROT:CanUse("Death Pact") and DKROT:HealthPct("PLAYER") < 30 then
            if DKROT:isOffCD("Death Pact") then
               return DKROT.spells["Death Pact"], true
            end
         end

         -- Blood Tap with >= 11 Charges
         if DKROT:CanUse("Blood Tap")
            and bloodCharges ~= nil and bloodCharges >= 11
            and DKROT:FullyDepletedRunes() > 0
         then
            return DKROT.spells["Blood Tap"], true
         end

         -- Death Coil if overcaped RP
         if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") > 80 then
            return DKROT.spells["Death Coil"]
         end

         -- Death Strike
         if select(1,IsUsableSpell(DKROT.spells["Death Strike"])) then
            return DKROT.spells["Death Strike"]
         end

         if select(1, IsUsableSpell(DKROT.spells["Icy Touch"])) then
            return DKROT.spells["Icy Touch"]
         end

         if select(1, IsUsableSpell(DKROT.spells["Plague Strike"])) then
            return DKROT.spells["Plague Strike"]
         end

         -- Blood Boil
         if select(1, IsUsableSpell(DKROT.spells["Blood Boil"])) then
            return DKROT.spells["Blood Boil"]
         end

         -- Death Coil
         if UnitPower("player") >= 40 then
            return DKROT.spells["Death Coil"]
         end

         -- Blood Tap with >= 5 Charges
         if DKROT:CanUse("Blood Tap")
            and bloodCharges ~= nil and bloodCharges >= 5
            and DKROT:FullyDepletedRunes() > 0
         then
            return DKROT.spells["Blood Tap"], true
         end

         -- Empower Rune Weapon if we have it enabled and we have at least 3 runes depleted
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:DepletedRunes() >= 3
         then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return DKROT.spells["Empower Rune Weapon"]
            end
         end

         -- If nothing else can be done
         return nil
      end
   }

   DKROT_RegisterRotation(DKROT.SPECS.UNKNOWN, blank)
end
