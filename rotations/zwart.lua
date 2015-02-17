if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local zwart = {
      Name = "zwart",
      InternalName = "zwart",
      ToggleSpells = { "Summon Gargoyle", "Plague Leech", "Soul Reaper", "Defile", "Outbreak", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { "Blood Tap" },
      DefaultRotation = false,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local timeToDie = DKROT:GetTimeToDie()
         local dFF, dBP = DKROT:GetDiseaseTime()
         local bloodCharges = select(4, UnitBuff("PLAYER", DKROT.spells["Blood Charge"])) or 0
         local shadowInfusion = select(4, UnitBuff("PET", DKROT.spells["Shadow Infusion"])) or 0
         local suddenDoom = select(4, UnitBuff("PLAYER", DKROT.spells["Sudden Doom"]))
         local npStacks = select(4, UnitDebuff("TARGET", DKROT.spells["Necrotic Plague"])) or 0
         local rp = UnitPower("PLAYER")
    
         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return DKROT.spells["Horn of Winter"]
         end

         -- Raise Dead
         if UnitExists("pet") ~= true and DKROT:isOffCD("Raise Dead") then
            return DKROT.spells["Raise Dead"], true
         end

         -- Plague Leech if we have two fully depleted runes and diseases are about to expire or outbreak is almost off CD
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and (DKROT:FullyDepletedRunes() >= 2 or DKROT:GetCD("Outbreak") < 1.5) then
            return DKROT.spells["Plague Leech"]
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:isOffCD("Soul Reaper") and DKROT:CanSoulReaper() then
            return DKROT.spells["Soul Reaper"]
         end

         -- Blood Tap if we need a rune for Soul Reaper
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and DKROT:CanSoulReaper() and unholy > 0 and death == 0 then
            return DKROT.spells["Soul Reaper"]
         end

         -- Use strength pot if we havent already
         if UnitBuff("PLAYER", DKROT.spells["Draenic Strength Potion"]) == nil and DKROT:HasItemInBags(109219) and DKROT:isItemOffCD(109219) then
            if DKROT:BloodlustActive() and DKROT:HealthPct("TARGET") < 85 then
               return 109219, true
            end
         end

         -- Summon Gargoyle on Cooldown
         if DKROT:CanUse("Summon Gargoyle") and DKROT:isOffCD("Summon Gargoyle") then
            return DKROT.spells["Summon Gargoyle"]
         end

         -- Disease checks
         if dFF == 0 or dBP == 0 then
            if DKROT:CanUse("Unholy Blight") and DKROT:isOffCD("Unholy Blight") then
               return DKROT.spells["Unholy Blight"]

            elseif DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") then
               return DKROT.spells["Outbreak"]

            elseif DKROT:isOffCD("Plague Strike") then
               return DKROT.spells["Plague Strike"]
            end
         end

         -- Defile if talent is selected and its off cd
         if DKROT:HasTalent("Defile") and DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return DKROT.spells["Defile"]
         end

         -- Festering Strike when NP duration is less than the cooldown of Unholy Blight
         if DKROT:isOffCD("Festering Strike") and DKROT:HasTalent("Necrotic Plague") and DKROT:HasTalent("Unholy Blight") then
            local ubcd = DKROT:GetCD(DKROT.spells["Unholy Blight"])

            if dFF < ubcd then
               return DKROT.spells["Festering Strike"]
            end
         end

         -- Dark Transformation on CD
         if shadowInfusion >= 5 then
            return DKROT.spells["Dark Transformation"]
         end

         -- Outbreak if Necrotic Plague is active with less than 15 stacks
         if DKROT:CanUse("Outbreak") and DKROT:HasTalent("Necrotic Plague") then
            if DKROT:isOffCD("Outbreak") and npStacks <= 14 then
               return DKROT.spells["Outbreak"]
            end
         end

         -- Blood Tap
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and DKROT:FullyDepletedRunes() > 0 then
            return DKROT.spells["Blood Tap"]
         end

         -- Empower Rune Weapon
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:isOffCD("Empower Rune Weapon") and rp < 25 then
            return DKROT.spells["Empower Rune Weapon"]
         end

         -- If nothing else can be done
         return nil
      end,
   }

   DKROT_RegisterRotation(DKROT.SPECS.UNHOLY, zwart)
end
