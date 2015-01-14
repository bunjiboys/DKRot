if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   -- Function to determine rotation for No Spec
   local function BlankMove()
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
      if GetSpellTexture(DKROT.spells["Death Pact"]) ~= nil
         and (UnitHealth("player") / UnitHealthMax("player")) < 0.30
      then
         if DKROT:isOffCD(DKROT.spells["Death Pact"]) then
            return DKROT.spells["Death Pact"], true
         end
      end

      -- Blood Tap with >= 11 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 11
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
      end

      -- Death Coil if overcaped RP
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") > 80 then
         return DKROT.spells["Death Coil"]
      end

      -- Death Strike
      if GetSpellTexture(DKROT.spells["Death Strike"]) then
         if select(1,IsUsableSpell(DKROT.spells["Death Strike"])) then
            return DKROT.spells["Death Strike"]
         end

      elseif select(1, IsUsableSpell(DKROT.spells["Icy Touch"])) then
         return DKROT.spells["Icy Touch"]

      elseif select(1, IsUsableSpell(DKROT.spells["Plague Strike"])) then
         return DKROT.spells["Plague Strike"]
      end

      -- Blood Boil
      if select(1, IsUsableSpell(DKROT.spells["Blood Boil"])) then
         return DKROT.spells["Blood Boil"]
      end

      -- Death Coil
      if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") >= 40 then
         return DKROT.spells["Death Coil"]
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

   DKROT_RegisterRotation(DKROT.SPECS.UNKNOWN, 'BlankMove', 'No Spec', BlankMove, true)
end
