if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local function IcyVeins(icon)
      --Rune Info
      local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local bloodCharges = select(4,UnitBuff("player", DKROT.spells["Blood Charge"]))

      -- Death Pact
      if GetSpellTexture(DKROT.spells["Death Pact"]) ~= nil
         and (UnitHealth("player") / UnitHealthMax("player")) < 0.30
      then
         if DKROT:isOffCD(DKROT.spells["Death Pact"]) then
            return GetSpellTexture(DKROT.spells["Death Pact"])
         end
      end

      --Bone Shield
      if GetSpellTexture(DKROT.spells["Bone Shield"]) ~= nil
      and select(7, UnitBuff("player", DKROT.spells["Bone Shield"])) == nil   then
         if DKROT:isOffCD(DKROT.spells["Bone Shield"]) then
            return GetSpellTexture(DKROT.spells["Bone Shield"])
         end
      end

      -- Defile
      if GetSpellTexture(DKROT.spells["Defile"]) ~= nil then
         if DKROT:isOffCD(DKROT.spells["Defile"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Defile"])
         end
      end

      --Soul Reaper
      if lblood <= 2 and GetSpellTexture(DKROT.spells["Soul Reaper"]) ~= nil
         and UnitHealth("target")/UnitHealthMax("target") < 0.35
      then
         if DKROT:isOffCD(DKROT.spells["Soul Reaper"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Soul Reaper"])
         end
      end

      --Diseases
      local disease, move = DKROT:GetDisease(icon)
      if disease then return move end

      --Death Strike
      if GetSpellTexture(DKROT.spells["Death Strike"]) ~= nil
      and select(1,IsUsableSpell(DKROT.spells["Death Strike"])) then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Death Strike"])
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

      --Blood Boil if we have a blood rune
      if GetSpellTexture(DKROT.spells["Blood Boil"]) and blood <= 0 then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Blood Boil"])
      end

      --Death Coil
      if UnitPower("player") >= 40 then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Death Coil"])
      end

      --Crimson Scourge BB
      if select(7,UnitBuff("player", DKROT.spells["Crimson Scourge"])) ~= nil then
         if DKROT_Settings.MoveAltDND then
            --Death and Decay
            if GetSpellTexture(DKROT.spells["Death and Decay"]) ~= nil then
               if DKROT:isOffCD(DKROT.spells["Death and Decay"]) then
                  DKROT.Move.AOE:SetAlpha(1)
                  DKROT.Move.AOE.Icon:SetTexture(GetSpellTexture(DKROT.spells["Death and Decay"]))
               end
            end
         end
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Blood Boil"])
      end

      --Blood Tap with >= 5 Charges
      if GetSpellTexture(DKROT.spells["Blood Tap"])
         and DKROT_Settings.CD[DKROT.Current_Spec].BT
         and bloodCharges ~= nil and bloodCharges >= 5
         and (frost >= 0 or unholy >= 0 or blood >= 0)
      then
         return DKROT:GetRangeandIcon(icon, DKROT.spells["Blood Tap"])
      end

      --Empower Rune Weapon if we have runes to activate and we're not RP capped
      if GetSpellTexture(DKROT.spells["Empower Rune Weapon"]) ~= nil
         and DKROT_Settings.CD[DKROT.Current_Spec].ERW
         and (frost >= 0 or unholy >= 0 or blood >= 0)
         and UnitPower("player") < 80
      then
         if DKROT:isOffCD(DKROT.spells["Empower Rune Weapon"]) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Empower Rune Weapon"])
         end
      end

      --If nothing else can be done
      return nil
   end

   DKROT:RegisterRotation(DKROT.SPECS.BLOOD, 'IcyVeins', 'Icy Veins', IcyVeins)

   -- Function to determine rotation for Blood Spec
   function DKROT:BloodMove(icon)
      return DKROT.Rotations[DKROT.SPECS.BLOOD]["IcyVeins"]["func"](icon)
   end
end
