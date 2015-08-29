-- vim: set ts=3 sw=3 foldmethod=indent:
if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local skullflower = {
      Name = "Skullflower",
      InternalName = "SFNormal",
      ToggleSpells = { "Death Pact", "Plague Leech", "Soul Reaper", "Defile", "Summon Gargoyle", "Outbreak", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { "Defile", "Plague Leech" },
      DefaultRotation = false,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local bloodCharges = select(4, UnitBuff("PLAYER", DKROT.spells["Blood Charge"])) or 0
         local dFF, dBP = DKROT:GetDiseaseTime()
         local shadowInf = select(4, UnitBuff("PET", DKROT.spells["Shadow Infusion"]))
         local doomProc = select(4, UnitBuff("PLAYER", DKROT.spells["Sudden Doom"]))
         local rp = UnitPower("PLAYER")
    
         -- Horn of Winter
         if DKROT:CanUse("Horn of Winter") and DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end

         -- Raise Dead
         if DKROT:CanUse("Raise Dead") and UnitExists("pet") ~= true and DKROT:isOffCD("Raise Dead") then
            return "Raise Dead", true
         end

         -- Plague Leech when we have two runes to return and Outbreak is about to come off cooldown or
         -- diseases are about to drop off
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() > 0 and dFF > 0 and dBP > 0 then
            if DKROT:GetCD("Outbreak") < 1.5 or (dFF < 5 or dBP < 5) then
               return "Plague Leech"
            end
         end

         -- Soul Reaper when below or close to 45% health with improved SR, or close to 35%
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Summon Gargoyle on CD
         if DKROT:CanUse("Summon Gargoyle") and DKROT:isOffCD("Summon Gargoyle") then
            if DKROT:BossOrPlayer("TARGET") then
               return "Summon Gargoyle"
            end
         end

         -- Outbreak when missing one or more diseases
         if DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") and (dFF == 0 or dBP == 0) then
            return "Outbreak"
         end

         -- Plague Strike if diseases are missing
         if DKROT:isOffCD("Plague Strike") and (dFF == 0 or dBP == 0) then
            return "Plague Strike"
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return "Defile"
         end

         -- Festering Strike when both blood and frost runes are capped
         if DKROT:CanUse("Festering Strike") and DKROT:isOffCD("Festering Strike") and lblood == 0 and lfrost == 0 then
            return "Festering Strike"
         end

         -- Scourge Strike when Unholy runes are capped
         if DKROT:CanUse("Scourge Strike") and DKROT:isOffCD("Scourge Strike") and lunholy == 0 then
            return "Scourge Strike"
         end

         -- Dark Transformation on CD with 5 stacks of Shadow Infusion
         if DKROT:CanUse("Dark Transformation") and DKROT:isOffCD("Dark Transformation") and shadowInf == 5 then
            return "Dark Transformation"
         end

         -- Blood Tap when we have 10 or more charges
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 and DKROT:FullyDepletedRunes() > 0 then
            return "Blood Tap"
         end

         -- Death Coil with Sudden Doom or RP almost capped
         if doomProc or (rp >= 80 and bloodCharges <= 10) then
            return "Death Coil"
         end

         -- Scourge Strike when Unholy or Death rune is recharged
         if DKROT:CanUse("Scourge Strike") and unholy == 0 or death >= 1 then
            return "Scourge Strike"
         end

         -- Festering Strike if we have a frost and blood rune ready
         if DKROT:CanUse("Scourge Strike") and blood == 0 and frost == 0 then
            return "Festering Strike"
         end

         -- Blood Tap if we have 5 or more blood charges
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 then
            return "Blood Tap"
         end

         -- Death Coil if we have enough RP
         if rp >= 30 then
            return "Death Coil"
         end

         -- Empower Rune Weapon when all runes are on CD
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:isOffCD("Empower Rune Weapon") and DKROT:DepletedRunes() == 6 then
            if DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
         end

         if DKROT:CanUse("Army of the Dead") and DKROT:isOffCD("Army of the Dead") then
            return "Army of the Dead"
         end

         -- If nothing else is doable
         return nil
      end
   }

   local necroblight = {
      Name = "Necrotic Blight",
      InternalName = "SFNecroBlight",
      ToggleSpells = { "Soul Reaper", "Death and Decay", "Summon Gargoyle", "Outbreak", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { "Necrotic Plague", "Unholy Blight" },
      DefaultRotation = true,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud, lud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local bloodCharges = select(4, UnitBuff("PLAYER", DKROT.spells["Blood Charge"])) or 0
         local dFF, dBP = DKROT:GetDiseaseTime()
         local timeToDie = DKROT:GetTimeToDie()
         local shadowInf = select(4, UnitBuff("PET", DKROT.spells["Shadow Infusion"]))
         local doomProc = select(4, UnitBuff("PLAYER", DKROT.spells["Sudden Doom"]))
         local npStacks = select(4, UnitDebuff("TARGET", DKROT.spells["Necrotic Plague"])) or 0
         local ub = select(4, UnitBuff("PLAYER", DKROT.spells["Unholy Blight"]))
         local rp = UnitPower("PLAYER")
         local runes = DKROT:GetRuneTotals()
         local frostDeaths = (fd == true and lfd == true) and 2 or (fd == true or lfd == true) and 1 or 0
         local unholyDeaths = (ud == true and lud == true) and 2 or (ud == true or lud == true) and 1 or 0
         local bloodDeaths = (bd == true and lbd == true) and 2 or (bd == true or lbd == true) and 1 or 0
         local depRunes = DKROT:FullyDepletedRunes()
         local activeTargets = DKROT:GetActiveTargets()
         local t182p = DKROT:TierBonus(DKROT.Tiers.TIER18_2p)
         local t184p = DKROT:TierBonus(DKROT.Tiers.TIER18_4p)
         local dtcd = (select(7, UnitBuff("PET", "Dark Transformation")) or 0) - GetTime()
         local poolRP = (rp < 90 and dtcd < 10) and true or false

         -- Horn of Winter
         if DKROT:CanUse("Horn of Winter") and DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end

         -- Raise Dead
         if UnitExists("pet") ~= true and DKROT:CanUse("Raise Dead") and DKROT:isOffCD("Raise Dead") then
            return "Raise Dead", true
         end

         -- Dark Transformation on CD with 5 stacks of Shadow Infusion
         if DKROT:CanUse("Dark Transformation") and DKROT:isOffCD("Dark Transformation") and shadowInf == 5 then
            return "Dark Transformation"
         end

         -- Death Coil if we can and Dark Transformation is ready but not active and we have Tier18 4p
         if t184p and DKROT:isOffCD("Dark Transformation") and (rp >= 30 or doomProc) and not UnitBuff("PET", DKROT.spells["Dark Transformation"]) then
            return "Death Coil"
         end

         -- Soul Reaper when below or close to 45% health with improved SR, or close to 35%
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Blood Tap if we need a rune for Soul Reaper
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and DKROT:CanSoulReaper(true) and depRunes >= 1 then
            return "Blood Tap"
         end

         -- Summon Gargoyle
         if DKROT:CanUse("Summon Gargoyle") and DKROT:isOffCD("Summon Gargoyle") and timeToDie and timeToDie > 20 then
            if DKROT:BossOrPlayer("TARGET") then
               return "Summon Gargoyle"
            end
         end

         -- Unholy Blight if we dont have diseases active
         if DKROT:CanUse("Unholy Blight") and DKROT:isOffCD("Unholy Blight") and (dFF == 0 or dBP == 0) then
            return "Unholy Blight"
         end

         -- Outbreak if we are missing a disease
         if DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") and (dFF == 0 or dBP == 0) and ub == nil then
            return "Outbreak"
         end

         -- Plague Strike, if we are missing diseases and Outbreak if on CD
         if DKROT:isOffCD("Plague Strike") and (dFF == 0 or dBP == 0) and ub == nil then
            return "Plague Strike"
         end

         -- DnD
         if DKROT:CanUse("Death and Decay") and DKROT:isOffCD("Death and Decay") and lunholy < 1.5 and activeTargets >= 2 then
            return "Death and Decay", true
         end

         -- Festering Strike if both Blood and Frost runes are capped
         if DKROT:CanUse("Festering Strike") and DKROT:isOffCD("Festering Strike") and lblood < 1.5 and lfrost < 1.5 then
            -- Avoid using death runes on festering strike
            if bloodDeaths == 0 and frostDeaths == 0 then
               return "Festering Strike"
            end
         end

         -- Scourge Strike
         if DKROT:CanUse("Scourge Strike") and lunholy < 1.5 then
            return "Scourge Strike"
         end

         -- Festering Strike if the remaining time on Necrotic Plague is less than the cooldown remaining on Unholy Blight
         if DKROT:CanUse("Festering Strike") and DKROT:isOffCD("Festering Strike")
            and DKROT:HasTalent("Necrotic Plague") and DKROT:HasTalent("Unholy Blight")
         then
            local ubcd = DKROT:GetCD("Unholy Blight")

            if dFF < ubcd and ((dFF < 20) or not (bd or fd)) then
               if timeToDie == nil or timeToDie > dFF then
                  return "Festering Strike"
               end
            end
         end

         -- DnD if we have 2 or more targets
         if DKROT:CanUse("Death and Decay") and DKROT:isOffCD("Death and Decay") and activeTargets >= 2 then
            return "Death and Decay"
         end

         -- Blood Boil if there are more than 3 targets and we have a death rune
         if DKROT:CanUse("Blood Boil") and death >= 1 and activeTargets >= 3 then
            return "Blood Boil"
         end

         -- Outbreak if Necrotic Plague is active with less than 15 stacks
         if DKROT:CanUse("Outbreak") and DKROT:HasTalent("Necrotic Plague") then
            if DKROT:isOffCD("Outbreak") and npStacks <= 14 then
               return "Outbreak"
            end
         end

         -- Blood Tap if we have more than 10 charges
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 and depRunes >= 1 then
            return "Blood Tap"
         end

         -- Death Coil with Sudden Doom or close to RP cap (pool rp if Dark Transformation is about to come up)
         if (doomProc or rp >= 80) and bloodCharges <= 10 and not poolRP then
            return "Death Coil"
         end

         -- Scourge Strike
         if DKROT:CanUse("Scourge Strike") and DKROT:isOffCD("Scourge Strike") then
            return "Scourge Strike"
         end

         -- Festering Strike
         if DKROT:CanUse("Festering Strike") and DKROT:isOffCD("Festering Strike") then
            return "Festering Strike"
         end

         -- Death Coil
         if rp >= 30 and not poolRP then
            return "Death Coil"
         end

         -- Empower Rune Weapon
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:isOffCD("Empower Rune Weapon") and DKROT:FullyDepletedRunes() >= 3 then
            if DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
         end

         -- Nothing else can be done
         return nil
      end
   }

   DKROT_RegisterRotation(DKROT.SPECS.UNHOLY, skullflower)
   DKROT_RegisterRotation(DKROT.SPECS.UNHOLY, necroblight)

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
      if DKROT:CanUse("Unholy Blight") and DKROT:isOffCD("Unholy Blight") then
         return "Unholy Blight"
      end

      -- Defile / DND
      if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
        return "Defile", true
      end

      -- Diseases
      local disease = DKROT:GetDisease()
      if disease ~= nil then
         return disease
      end

      -- Breath of Sindragosa
      if DKROT:CanUse("Breath of Sindragosa")
         and UnitPower("player") > 75
         and DKROT:isOffCD("Breath of Sindragosa")
      then
         return "Breath of Sindragosa"
      end

      -- Blood Boil
      if DKROT:isOffCD("Blood Boil") then
         return "Blood Boil"
      end

      -- Summon Gargoyle
      if DKROT:CanUse("Summon Gargoyle") and DKROT:isOffCD("Summon Gargoyle") then
         return "Summon Gargoyle"
      end

      return nil
   end
end
