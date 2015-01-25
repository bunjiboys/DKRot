if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local function IcyVeins()
      -- Rune Info
      local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))
      local timeToDie = DKROT:GetTimeToDie()
 
      -- Horn of Winter
      if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
         return DKROT.spells["Horn of Winter"]
      end

      -- Raise Dead
      if UnitExists("pet") ~= true and DKROT:isOffCD(DKROT.spells["Raise Dead"]) then
         return DKROT.spells["Raise Dead"], true
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
      if (
            GetSpellTexture(DKROT.spells["Improved Soul Reaper"]) ~= nil
            and UnitHealth("target")/UnitHealthMax("target") < 0.45
         )
         or UnitHealth("target")/UnitHealthMax("target") < 0.35
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

      -- Dark Transformation
      if select(4, UnitBuff("PET",DKROT.spells["Shadow Infusion"])) == 5
         and (
            GetSpellTexture(DKROT.spells["Enhanced Dark Transformation"]) ~= nil
            or (unholy <= 0 or death >= 1)
         )
      then
         return DKROT.spells["Dark Transformation"]
      end

      -- Blood Tap with >= 11 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 11
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
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
         return DKROT.spells["Death Coil"]
      end

      -- Scourge Strike (UU are up or FF or BB are up as Deathrunes)
      if lunholy <= 0 or (lfrost <= 0 and (fd or lfd)) or (lblood <= 0 and (bd or lbd)) then
         return DKROT.spells["Scourge Strike"]
      end

      -- Festering Strike (BB and FF are up)
      if lfrost <= 0 and lblood <= 0 then
         return DKROT.spells["Festering Strike"]
      end

      -- Death Coil (Sudden Doom, high RP)
      if DKROT_Settings.CD[DKROT.Current_Spec].RP
         and (
            UnitPower("player") > 80
            or select(7, UnitBuff("PLAYER", DKROT.spells["Sudden Doom"])) ~= nil
         )
      then
         return DKROT.spells["Death Coil"]
      end

      -- Scourge Strike
      if unholy <= 0 or death >= 1 then
         return DKROT.spells["Scourge Strike"]
      end

      -- Festering Strike
      if frost <= 0 and blood <= 0 then
         return DKROT.spells["Festering Strike"]
      end

      -- Blood Tap with >= 5 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 5
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
      end

      -- Empower Rune Weapon
      if GetSpellTexture(DKROT.spells["Empower Rune Weapon"]) ~= nil and DKROT_Settings.CD[DKROT.Current_Spec].ERW then
         if DKROT:isOffCD(DKROT.spells["Empower Rune Weapon"]) then
            return DKROT.spells["Empower Rune Weapon"]
         end
      end

      if GetSpellTexture(DKROT.spells["Death Coil"]) and UnitPower("player") >= 30 then
         return DKROT.spells["Death Coil"]
      end

      -- If nothing else can be done
      return nil
   end

   local function SimC()
      -- Rune Info
      local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))
      local dFF, dBP = DKROT:GetDiseaseTime()
      local timeToDie = DKROT:GetTimeToDie()

      -- Horn of Winter
      if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
         return DKROT.spells["Horn of Winter"]
      end

      -- Raise Dead
      if UnitExists("pet") ~= true then
         return DKROT.spells["Raise Dead"], true
      end

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
         and DKROT_Settings.CD[DKROT.Current_Spec].PL
         and DKROT:isOffCD(DKROT.spells["Plague Leech"])
         and DKROT:HasFullyDepletedRunes()
         and (dFF ~= nil and dBP ~= nil and dFF > 0 and dBP > 0)
      then
         return DKROT.spells["Plague Leech"]
      end

      -- Soul Reaper
      if (
            GetSpellTexture(DKROT.spells["Improved Soul Reaper"]) ~= nil
            and UnitHealth("target")/UnitHealthMax("target") < 0.45
         )
         or UnitHealth("target")/UnitHealthMax("target") < 0.35
      then
         if DKROT:isOffCD(DKROT.spells["Soul Reaper"]) and timeToDie > 5 then
            return DKROT.spells["Soul Reaper"]
         end
      end

      -- Defile
      if GetSpellTexture(DKROT.spells["Defile"]) ~= nil and timeToDie > 10 then
         if DKROT:isOffCD(DKROT.spells["Defile"]) then
            return DKROT.spells["Defile"], true
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

      -- Summon Gargoyle
      if DKROT:isOffCD(DKROT.spells["Summon Gargoyle"]) and timeToDie > 30 then
         if DKROT_Settings.CD[DKROT.Current_Spec].BossCD then
            if DKROT:BossOrPlayer("TARGET") then
               return DKROT.spells["Summon Gargoyle"]
            end
         else
            return DKROT.spells["Summon Gargoyle"]
         end
      end

      -- Death Coil if we are close to RP cap or with Sudden Doom proc
      if UnitPower("player") > 90 or select(7, UnitBuff("PLAYER", DKROT.spells["Sudden Doom"])) then
         return DKROT.spells["Death Coil"]
      end

      -- Dark Transformation
      if select(4, UnitBuff("PET",DKROT.spells["Shadow Infusion"])) == 5
         and (
            GetSpellTexture(DKROT.spells["Enhanced Dark Transformation"]) ~= nil
            or (unholy <= 0 or death >= 1)
         )
      then
         return DKROT.spells["Dark Transformation"]
      end

      -- Diseases
      local disease = DKROT:GetDisease()
      if disease ~= nil then
         return disease
      end

      -- Breath of Sindragosa
      if GetSpellTexture(DKROT.spells["Breath of Sindragosa"]) ~= nil
         and UnitPower("player") > 75 
         and DKROT:isOffCD(DKROT.spells["Breath of Sindragosa"])
      then
         return DKROT.spells["Breath of Sindragosa"]
      end

      -- Blood Tap if both unholy runes are down
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 5
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
      end

      if lunholy <= 0 and DKROT:isOffCD(DKROT.spells["Scourge Strike"]) then
         return DKROT.spells["Scourge Strike"]
      end

      -- Death Coil if we have more than 80 RP
      if UnitPower("player") >= 80 then
         return DKROT.spells["Death Coil"]
      end

      -- Festering Strike if both blood and frost runes are up
      if (lblood <= 0 and lfrost <= 0) then
         return DKROT.spells["Festering Strike"]
      end
 
      -- Blood Tap with >= 5 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 5
         and DKROT:HasFullyDepletedRunes()
      then
         return DKROT.spells["Blood Tap"], true
      end

      if DKROT:isOffCD(DKROT.spells["Scourge Strike"]) then
         return DKROT.spells["Scourge Strike"]
      end

      if DKROT:isOffCD(DKROT.spells["Festering Strike"]) then
         return DKROT.spells["Festering Strike"]
      end

      -- Death Coil if more than 30 RP
      if UnitPower("player") >= 30 then
         return DKROT.spells["Death Coil"]
      end

      -- Empower Rune Weapon
      if GetSpellTexture(DKROT.spells["Empower Rune Weapon"]) ~= nil and DKROT_Settings.CD[DKROT.Current_Spec].ERW then
         if DKROT:isOffCD(DKROT.spells["Empower Rune Weapon"]) then
            return DKROT.spells["Empower Rune Weapon"]
         end
      end

      -- If nothing else can be done
      return nil
   end

   DKROT_RegisterRotation(DKROT.SPECS.UNHOLY, 'IcyVeins', 'Unholy - Icy Veins', IcyVeins, false)
   DKROT_RegisterRotation(DKROT.SPECS.UNHOLY, 'SimC', 'Unholy - SimCraft', SimC, true)

   -- Function to determine AOE rotation for Unholy Spec
   function DKROT:UnholyAOEMove(icon)
      -- Rune Info
      local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()

      if not DKROT_Settings.MoveAltAOE then
         return nil
      end

      -- Unholy Blight
      if GetSpellTexture(DKROT.spells["Unholy Blight"]) and DKROT:isOffCD(DKROT.spells["Unholy Blight"]) then
         return DKROT.spells["Unholy Blight"]
      end

      -- Defile / DND
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
      if GetSpellTexture(DKROT.spells["Breath of Sindragosa"]) ~= nil
         and UnitPower("player") > 75
         and DKROT:isOffCD(DKROT.spells["Breath of Sindragosa"])
      then
         return DKROT.spells["Breath of Sindragosa"]
      end

      -- Blood Boil
      if DKROT:isOffCD(DKROT.spells["Blood Boil"]) then
         return DKROT.spells["Blood Boil"]
      end

      -- Summon Gargoyle
      if DKROT:isOffCD(DKROT.spells["Summon Gargoyle"]) then
         return DKROT.spells["Summon Gargoyle"]
      end

      return nil
   end
end
