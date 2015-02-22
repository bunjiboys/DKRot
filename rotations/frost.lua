if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local icyveins = {
      Name = "Icy Veins - Two-Hand",
      InternalName = "IcyVeins2H",
      ToggleSpells = { "Death Pact", "Plague Leech", "Soul Reaper", "Defile", "Breath of Sindragosa", "Outbreak", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { },
      DefaultRotation = false,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))
         local rimeProc = select(7, UnitBuff("player", DKROT.spells["Freezing Fog"]))
         local kmProc = select(7, UnitBuff("player", DKROT.spells["Killing Machine"]))
         local rp = UnitPower("PLAYER")
    
         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end

         -- Death Pact
         if DKROT:CanUse("Death Pact") and (UnitHealth("player") / UnitHealthMax("player")) < 0.30 then
            if DKROT:isOffCD("Death Pact") then
               return "Death Pact", true
            end
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return "Defile", true
         end

         -- Diseases
         local disease = DKROT:GetDisease()
         if disease ~= nil then
            return disease
         end

         -- Breath of Sindragosa
         if DKROT:CanUse("Breath of Sindragosa") and UnitPower("player") > 30 then
            if DKROT:isOffCD("Breath of Sindragosa") then
               return "Breath of Sindragosa"
            end
         end

         -- Obliterate with killing machine or runes overcaped
         if DKROT:has("Obliterate") and select(1,IsUsableSpell(DKROT.spells["Obliterate"]))
            and (kmproc or (lfrost <= 0 or lunholy <= 0 or (lblood <= 0 and lbd)))
         then
            return "Obliterate"
         end

         -- Blood Tap with >= 11 Charges
         if DKROT:CanUse("Blood Tap")
            and DKROT_Settings.CD[DKROT.Current_Spec].BT
            and bloodCharges ~= nil and bloodCharges >= 11
            and DKROT:FullyDepletedRunes() > 0
         then
            return "Blood Tap", true
         end

         -- Frost Strike if rp overcaped
         if DKROT_Settings.CD[DKROT.Current_Spec].RP and UnitPower("player") > 76 then
            return "Frost Strike"
         end

         -- Obliterate
         if DKROT:has("Obliterate") then
            if select(1,IsUsableSpell(DKROT.spells["Obliterate"])) then
               return "Obliterate"
            end
         else
            -- Howling Blast
            if frost <= 0 then
               return "Howling Blast"
            end

            -- Plague Strike
            if unholy <= 0 then
               return "Plague Strike"
            end
         end

         -- Rime Howling Blast
         if rimeProc then
            return "Howling Blast"
         end

         -- Frost Strike
         if DKROT_Settings.CD[DKROT.Current_Spec].RP and rp >= 25 then
            return "Frost Strike"
         end

         -- Blood Tap with >= 5 Charges
         if DKROT:CanUse("Blood Tap")
            and DKROT_Settings.CD[DKROT.Current_Spec].BT
            and bloodCharges ~= nil and bloodCharges >= 5
            and DKROT:FullyDepletedRunes() > 0
         then
            return "Blood Tap", true
         end

         -- Empower Rune Weapon if we have it enabled and we have at least 3 runes depleted
         if DKROT:CanUse("Empower Rune Weapon")
            and DKROT_Settings.CD[DKROT.Current_Spec].ERW
            and DKROT:DepletedRunes() >= 3
         then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
         end

         -- If nothing else can be done
         return nil
      end
   }
      
   local icyveinsdw = {
      Name = "Icy Veins - Dual Wield",
      InternalName = "IcyVeinsDualWield",
      ToggleSpells = { "Death Pact", "Plague Leech", "Soul Reaper", "Defile", "Breath of Sindragosa", "Outbreak", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { },
      DefaultRotation = false,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))
         local kmProc = select(7, UnitBuff("player", DKROT.spells["Killing Machine"]))
         local rimeProc = select(7, UnitBuff("player", DKROT.spells["Freezing Fog"]))
    
         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end

         -- Death Pact
         if DKROT:CanUse("Death Pact")
            and (UnitHealth("player") / UnitHealthMax("player")) < 0.30
         then
            if DKROT:isOffCD("Death Pact") then
               return "Death Pact", true
            end
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Defile
         if DKROT:CanUse("Defile") then
            if DKROT:isOffCD("Defile") then
               return "Defile", true
            end
         end

         -- Breath of Sindragosa
         if DKROT:CanUse("Breath of Sindragosa") and UnitPower("player") > 30 then
            if DKROT:isOffCD("Breath of Sindragosa") then
               return "Breath of Sindragosa"
            end
         end

         -- Blood Tap with >= 11 Charges
         if DKROT:CanUse("Blood Tap")
            and DKROT_Settings.CD[DKROT.Current_Spec].BT
            and bloodCharges ~= nil and bloodCharges >= 11
            and DKROT:FullyDepletedRunes() > 0
         then
            return "Blood Tap", true
         end

         -- Frost Strike if Killing Machine is procced
         if UnitPower("player") >= 25 and kmProc then
            return "Frost Strike"
         end

         -- Frost Strike if RP capped
         if UnitPower("player") > 88 then
            return "Frost Strike"
         end

         -- Diseases
         local disease = DKROT:GetDisease()
         if disease ~= nil then
            return disease
         end

         -- Howling Blast with both frost or both death off cooldown
         if lblood <= 0 or lfrost <= 0 then
            return "Howling Blast"
         end

         -- Obliterate when Killing Machine is procced and both Unholy Runes are off cooldown
         if select(1,IsUsableSpell(DKROT.spells["Obliterate"])) and lunholy <= 0 and kmProc then
            return "Obliterate"
         end

         -- Howling Blast if Rime procced
         if rimeProc then
            return "Howling Blast"
         end

         -- Obliterate when second Unholy Rune is nearly off cooldown
         if lunholy <= 2 and not ud and (frost <= 0 or blood <= 0) then
            return "Obliterate"
         end

         -- Howling Blast
         if death >= 1 or frost <= 0 then
            return "Howling Blast"
         end

         -- Blood Tap with >= 5 Charges
         if DKROT:CanUse("Blood Tap") and bloodCharges ~= nil and bloodCharges >= 5 and DKROT:FullyDepletedRunes() > 0 then
            return "Blood Tap", true
         end

         -- Frost Strike
         if UnitPower("player") > 39 then
            return "Frost Strike"
         end

         -- Empower Rune Weapon if we have it enabled and we have at least two fully depleted runes
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:FullyDepletedRunes() >= 2 then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
         end

         -- If nothing else can be done
         return nil
      end
   }

   local simcraft = {
      Name = "SimCraft - Two-Hand",
      InternalName = "SimC2H",
      ToggleSpells = { "Death Pact", "Plague Leech", "Soul Reaper", "Defile", "Breath of Sindragosa", "Outbreak", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { },
      DefaultRotation = true,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local dFF, dBP = DKROT:GetDiseaseTime()
         local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))
         local kmProc = select(7, UnitBuff("player", DKROT.spells["Killing Machine"]))
         local rimeProc = select(7, UnitBuff("player", DKROT.spells["Freezing Fog"]))

         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end
    
         -- Death Pact
         if DKROT:CanUse("Death Pact") and (UnitHealth("player") / UnitHealthMax("player")) < 0.30 then
            if DKROT:isOffCD("Death Pact") then
               return "Death Pact", true
            end
         end

         -- Plague Leech if we have enabled it in the rotation, and we have a fully depleted rune
         if DKROT:CanUse("Plague Leech")
            and DKROT:isOffCD("Plague Leech")
            and DKROT:FullyDepletedRunes() > 0 and (dFF > 0 and dBP > 0)
         then
            return "Plague Leech"
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return "Defile"
         end

         -- Blood Tap with >= 11 Charges
         if DKROT:CanUse("Blood Tap") and bloodCharges ~= nil and bloodCharges >= 11 and DKROT:FullyDepletedRunes() > 0 then
            return "Blood Tap", true
         end
    
         -- Rime Howling Blast if we need to refresh
         if rimeProc ~= nil and (dFF < 5) then
            return "Howling Blast"
         end

         -- Diseases
         local disease = DKROT:GetDisease()
         if disease ~= nil then
            return disease
         end

         -- Breath of Sindragosa
         if DKROT:CanUse("Breath of Sindragosa") and UnitPower("player") > 75 then
            if DKROT:isOffCD("Breath of Sindragosa") then
               return "Breath of Sindragosa"
            end
         end

         -- Obliterate with killing machine or runes overcaped
         if DKROT:has("Obliterate")
            and select(1,IsUsableSpell(DKROT.spells["Obliterate"]))
            and (kmProc or (lfrost <= 0 or lunholy <= 0 or (lblood <= 0 and lbd)))
         then
            return "Obliterate"
         end

         -- Frost Strike if rp overcaped
         if UnitPower("player") > 76 then
            return "Frost Strike"
         end
    
         -- Howling Blast if Rime is procced
         if rimeProc ~= nil then
            return "Howling Blast"
         end

         -- Obliterate
         if select(1,IsUsableSpell(DKROT.spells["Obliterate"])) then
            return "Obliterate"
         else
            -- Howling Blast
            if frost <= 0 then
               return "Howling Blast"
            end

            --Plague Strike
            if unholy <= 0 then
               return "Plague Strike"
            end
         end

         -- Frost Strike
         if UnitPower("player") >= 25 then
            return "Frost Strike"
         end

         -- Blood Tap with >= 5 Charges
         if DKROT:CanUse("Blood Tap")
            and bloodCharges ~= nil and bloodCharges >= 5
            and DKROT:FullyDepletedRunes() > 0
         then
            return "Blood Tap", true
         end

         -- Empower Rune Weapon if we have it enabled and we have at least 3 runes depleted
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:FullyDepletedRunes() >= 2 then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
         end

         -- If nothing else can be done
         return nil
      end
   }

   local simcraftdw = {
      Name = "SimCraft - Dual Wield",
      InternalName = "SimCDualWield",
      ToggleSpells = { "Death Pact", "Plague Leech", "Soul Reaper", "Defile", "Breath of Sindragosa", "Outbreak", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { },
      DefaultRotation = false,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local dFF, dBP = DKROT:GetDiseaseTime()
         local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"]))
         local rimeProc = select(7, UnitBuff("player", DKROT.spells["Freezing Fog"]))
         local kmProc = select(7, UnitBuff("player", DKROT.spells["Killing Machine"]))
         local rp = UnitPower("PLAYER")

         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end
    
         -- Death Pact
         if DKROT:CanUse("Death Pact") and (UnitHealth("player") / UnitHealthMax("player")) < 0.30 then
            if DKROT:isOffCD("Death Pact") then
               return "Death Pact", true
            end
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Blood Tap with >= 11 Charges
         if DKROT:CanUse("Blood Tap")
            and bloodCharges ~= nil and bloodCharges >= 11
            and DKROT:FullyDepletedRunes() > 0
         then
            return "Blood Tap", true
         end

         -- Breath of Sindragosa
         if DKROT:CanUse("Breath of Sindragosa") and rp > 75 then
            if DKROT:isOffCD("Breath of Sindragosa") then
               return "Breath of Sindragosa"
            end
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return "Defile"
         end
    
         -- Howling Blast as long as it wont cap out RP
         if DKROT:isOffCD("Howling Blast") and rp < 88 then
            return "Howling Blast"
         end

         -- Obliterate when it wont cap RP
         if DKROT:has("Obliterate")
            and select(1, IsUsableSpell(DKROT.spells["Obliterate"]))
            and rp < 76
         then
            return "Obliterate"
         end

         -- Frost Strike w/Killing Machine and high RP
         if kmProc and rp >= 50 and DKROT:isOffCD("Frost Strike") then
            return "Frost Strike"
         end
    
         -- Howling Blast if we have at least one full frost or death rune up
         if frost <= 0 or death > 0 then
            return "Howling Blast"
         end

         -- Diseases
         local disease = DKROT:GetDisease()
         if disease ~= nil then
            return disease
         end
    
         -- Howling Blast if Rime is procced
         if rimeProc then
            return "Howling Blast"
         end

         -- Frost Strike
         if rp > 76 then
            return "Frost Strike"
         end

         if unholy <= 0 and kmProc and DKROT:isOffCD("Obliterate") then
            return "Obliterate"
         end

         if DKROT:isOffCD("Howling Blast") then
            return "Howling Blast"
         end

         -- Blood Tap with >= 5 Charges
         if DKROT:CanUse("Blood Tap")
            and bloodCharges ~= nil and bloodCharges >= 5
            and DKROT:FullyDepletedRunes() > 0
         then
            return "Blood Tap", true
         end

         -- Plague Leech if we have enabled it in the rotation, and we have a fully depleted rune
         if DKROT:CanUse("Plague Leech")
            and DKROT:isOffCD("Plague Leech")
            and DKROT:FullyDepletedRunes() > 0
            and (dFF > 0 and dBP > 0)
         then
            return "Plague Leech"
         end

         -- Empower Rune Weapon if we have it enabled and we have at least 2 runes fully depleted
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:FullyDepletedRunes() >= 2 then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
         end

         if rp >= 25 then
            return "Frost Strike"
         end

         -- If nothing else can be done
         return nil
      end
   }

   local skullflower = {
      Name = "Skullflower - Two-Hand",
      InternalName = "SF2H",
      ToggleSpells = { "Pillar of Frost", "Plague Leech", "Soul Reaper", "Defile", "Outbreak", "Blood Tap", "Empower Rune Weapon", "Army of the Dead" },
      SuggestedTalents = { "Plague Leech", "Defile", "Blood Tap" },
      DefaultRotation = false,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death, tdeath = DKROT:DeathRunes()
         local dFF, dBP = DKROT:GetDiseaseTime()
         local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"])) or 0
         local rimeProc = select(7, UnitBuff("player", DKROT.spells["Freezing Fog"]))
         local kmProc = select(7, UnitBuff("player", DKROT.spells["Killing Machine"]))
         local rp = UnitPower("PLAYER")
    
         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end

         -- Pillar of Frost on CD
         if DKROT:CanUse("Pillar of Frost") and DKROT:isOffCD("Pillar of Frost") then
            if DKROT:BossOrPlayer("TARGET") then
               return "Pillar of Frost"
            end
         end

         -- Plague Leech when we have two runes to return and 
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 and dFF > 0 and dBP > 0
         then
            local start, dur, _ = GetSpellCooldown(DKROT.spells["Outbreak"])
            if (duration == 0 or ((start + dur) < DKROT.curtime))
               or (kmProc and not DKROT:isOffCD("Obliterate"))
            then
               return "Plague Leech"
            end
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return "Defile"
         end

         -- Howling Blast with Rime Proc
         if rimeProc then
            return "Howling Blast"
         end

         -- Obliterate with Killing Machine
         if kmProc and DKROT:isOffCD("Obliterate") then
            return "Obliterate"
         end

         -- Blood tap if we need runes for KM Obliterate, or we're at 10 or more changes
         if DKROT:CanUse("Blood Tap") and DKROT:FullyDepletedRunes() > 0 and (
               bloodCharges >= 10 or (bloodCharges >= 5 and kmProc and not DKROT:isOffCD("Obliterate"))
            )
         then
            return "Blood Tap"
         end

         -- Outbreak with we're missing diseases
         if DKROT:CanUse("Outbreak") and (dFF == 0 or dBP == 0) and DKROT:isOffCD("Outbreak") then
            return "Outbreak"
         end

         -- Plague Strike if we cant use outbreak to apply Blood Plague
         if dBP == 0 and DKROT:isOffCD("Plague Strike") then
            return "Plague Strike"
         end

         -- Howling Blast if we cant use outbreak to apply Frost Fever
         if dFF == 0 and DKROT:isOffCD("Howling Blast") then
            return "Howling Blast"
         end

         -- Frost Strike when we have 75 or more RP and less than or 10 Blood Charges
         if rp >= 75 and bloodCharges <= 10 then
            return "Frost Strike"
         end

         -- Obliterate when we have capped runes or close to recharging
         if (lunholy < 2 and lfrost < 2) or lblood < 2 then
            return "Obliterate"
         end

         -- Frost Strike when we dont have KM proc and we have enough RP
         if rp >= 25 and not kmProc then
            return "Frost Strike"
         end

         -- Plague Leech if we have 2 runes depleted
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 and dFF > 0 and dBP > 0 then
            return "Plague Leech"
         end

         -- Empower Rune Weapon if all runes are depleted and we are out of RP
         if DKROT:CanUse("Empower Rune Weapon") and rp < 25 and DKROT:DepletedRunes() == 6 then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
         end

         if DKROT:CanUse("Army of the Dead") and DKROT:isOffCD("Army of the Dead") and DKROT:BossOrPlayer("TARGET") then
            return "Army of the Dead"
         end

         -- If nothing else can be done
         return nil
      end,
      AOERotation = function()
         -- Rune Info
         local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death, tdeath = DKROT:DeathRunes()
         local dFF, dBP = DKROT:GetDiseaseTime()
         local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"])) or 0
         local rimeProc = select(7, UnitBuff("player", DKROT.spells["Freezing Fog"]))
         local kmProc = select(7, UnitBuff("player", DKROT.spells["Killing Machine"]))
         local rp = UnitPower("PLAYER")

         -- Pillar of Frost if its available
         if DKROT:CanUse("Pillar of Frost") and DKROT:isOffCD("Pillar of Frost") then
            return "Pillar of Frost"
         end

         -- Outbreak if both Frost Fever and Blood Plague are missing
         if DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") and dFF == 0 and dBP == 0 then
            return "Outbreak"
         end

         -- Plague Strike if Blood Plague is missing
         if DKROT:isOffCD("Plague Strike") and dBP == 0 then
            return "Plague Strike"
         end

         -- Howling Blast if Frost Fever is missing
         if DKROT:isOffCD("Howling Blast") and dFF == 0 then
            return "Howling Blast"
         end

         -- Plague Leech with two fully depleted runes and diseases are about to run out,
         -- outbreak is off or about to come off CD, or we need a rune for KM Obliterate
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 then
            if (dFF < 5 or dBP < 5) or DKROT:GetCD("Outbreak") < 1.5 or (kmProc and not DKROT:isOffCD("Obliterate")) then
               return "Plague Leech"
            end
         end

         -- Blood Boil
         if DKROT:isOffCD("Blood Boil") then
            return "Blood Boil"
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return "Defile"
         end

         -- Howling Blast with Rime Proc or Frost or Death runes are capped
         if rimeProc and (lfrost == 0 or death >= 2) then
            return "Howling Blast"
         end

         -- Obliterate when Unholy runes are capped
         if lunholy == 0 then
            return "Obliterate"
         end

         -- Blood Tap if we have 10 or more charges
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 then
            return "Blood Tap"
         end

         -- Frost Strike with high RP
         if rp >= 88 then
            return "Frost Strike"
         end

         -- Howling Blast if Death or Frost runes are capped
         if lfrost == 0 or death >= 2 then
            return "Howling Blast"
         end

         -- Frost Strike if we can
         if rp >= 25 then
            return "Frost Strike"
         end

         -- Empower Rune Weapon if all runes are depleted
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:FullyDepletedRunes() == 3 then
            return "Empower Rune Weapon"
         end

         -- Army of the Dead
         if DKROT:CanUse("Army of the Dead") and DKROT:isOffCD("Army of the Dead") then
            return "Army of the Dead"
         end

         -- Can't do anything else
         return nil
      end
   }

   local skullflowerdw = {
      Name = "Skullflower - Dual Wield",
      InternalName = "SFDW",
      ToggleSpells = { "Pillar of Frost", "Plague Leech", "Soul Reaper", "Defile", "Outbreak", "Blood Tap", "Empower Rune Weapon", "Army of the Dead" },
      SuggestedTalents = { "Plague Leech", "Defile", "Blood Tap" },
      DefaultRotation = false,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death, tdeath = DKROT:DeathRunes()
         local dFF, dBP = DKROT:GetDiseaseTime()
         local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"])) or 0
         local rimeProc = select(7, UnitBuff("player", DKROT.spells["Freezing Fog"]))
         local kmProc = select(7, UnitBuff("player", DKROT.spells["Killing Machine"]))
         local rp = UnitPower("PLAYER")
    
         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end

         -- Pillar of Frost on CD
         if DKROT:CanUse("Pillar of Frost") and DKROT:isOffCD("Pillar of Frost") then
            if DKROT:BossOrPlayer("TARGET") then
               return "Pillar of Frost"
            end
         end

         -- Plague Leech when we have a fully depleted rune
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 and dFF > 0 and dBP > 0 then
            return "Plague Leech"
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return "Defile"
         end

         -- Frost Strike with Killing Machine or Runic Power is above 88
         if (kmProc and rp >= 25) or rp >= 88 then
            return "Frost Strike"
         end

         -- Outbreak if we're missing diseases
         if DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") and (dFF == 0 or dBP == 0) then
            return "Outbreak"
         end

         -- Plague Strike if we're missing blood plague
         if DKROT:isOffCD("Plague Strike") and dBP == 0 then
            return "Plague Strike"
         end

         -- Howling Blast if we're missing Frost Fever, we have a Rime proc or both Frost and Death runes are capped
         if (dFF == 0 and DKROT:isOffCD("Howling Blast")) or rimeProc or (lfrost == 0 and lblood == 0) then
            return "Howling Blast"
         end

         -- Obliterate when Unholy runes are capped
         if DKROT:isOffCD("Obliterate") and lunholy == 0 then
            return "Obliterate"
         end

         -- Blood Tap when we have 10 or more changes
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 and DKROT:FullyDepletedRunes() > 0 then
            return "Blood Tap"
         end

         -- Howling Blast when a Death or Frost rune is capped
         if DKROT:isOffCD("Howling Blast") and (blood == 0 or frost == 0) then
            return "Howling Blast"
         end

         -- Frost Strike when we have enough RP
         if rp >= 25 then
            return "Frost Strike"
         end

         -- Empower Rune Weapon if all runes are depleted and we are out of RP
         if DKROT:CanUse("Empower Rune Weapon") and rp < 25 and DKROT:DepletedRunes() == 6 then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
         end

         -- Army of the Dead if we can't do anything else
         if DKROT:CanUse("Army of the Dead") and DKROT:isOffCD("Army of the Dead") and DKROT:BossOrPlayer("TARGET") then
            return "Army of the Dead"
         end

         -- If nothing else can be done
         return nil
      end,
      AOERotation = function()
         -- Rune Info
         local frost, lfrost, fd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death, tdeath = DKROT:DeathRunes()
         local dFF, dBP = DKROT:GetDiseaseTime()
         local bloodCharges = select(4, UnitBuff("player", DKROT.spells["Blood Charge"])) or 0
         local rimeProc = select(7, UnitBuff("player", DKROT.spells["Freezing Fog"]))
         local kmProc = select(7, UnitBuff("player", DKROT.spells["Killing Machine"]))
         local rp = UnitPower("PLAYER")

         -- Pillar of Frost if its available
         if DKROT:CanUse("Pillar of Frost") and DKROT:isOffCD("Pillar of Frost") then
            return "Pillar of Frost"
         end

         -- Outbreak if both Frost Fever and Blood Plague are missing
         if DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") and dFF == 0 and dBP == 0 then
            return "Outbreak"
         end

         -- Plague Strike if Blood Plague is missing
         if DKROT:isOffCD("Plague Strike") and dBP == 0 then
            return "Plague Strike"
         end

         -- Howling Blast if Frost Fever is missing
         if DKROT:isOffCD("Howling Blast") and dFF == 0 then
            return "Howling Blast"
         end

         -- Plague Leech with two fully depleted runes and diseases are about to run out,
         -- outbreak is off or about to come off CD, or we need a rune for KM Obliterate
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 then
            return "Plague Leech"
         end

         -- Blood Boil
         if DKROT:isOffCD("Blood Boil") then
            return "Blood Boil"
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return "Defile"
         end

         -- Howling Blast with Rime Proc or Frost or Death runes are capped
         if rimeProc and (lfrost == 0 or death >= 2) then
            return "Howling Blast"
         end

         -- Plague Strike when Unholy runes are capped and Blood Plague is missing
         if lunholy == 0 and dBP == 0 then
            return "Plague Strike"
         end

         -- Obliterate when Unholy runes are capped
         if lunholy == 0 then
            return "Obliterate"
         end

         -- Blood Tap if we have 10 or more charges
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 then
            return "Blood Tap"
         end

         -- Howling Blast if Death or Frost runes are capped
         if lfrost == 0 or death >= 2 then
            return "Howling Blast"
         end

         -- Frost Strike if we can
         if rp >= 25 then
            return "Frost Strike"
         end

         -- Empower Rune Weapon if all runes are depleted
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:FullyDepletedRunes() == 3 then
            return "Empower Rune Weapon"
         end

         -- Army of the Dead
         if DKROT:CanUse("Army of the Dead") and DKROT:isOffCD("Army of the Dead") then
            return "Army of the Dead"
         end

         -- Can't do anything else
         return nil
      end
   }

   DKROT_RegisterRotation(DKROT.SPECS.FROST, icyveins)
   DKROT_RegisterRotation(DKROT.SPECS.FROST, icyveinsdw)
   DKROT_RegisterRotation(DKROT.SPECS.FROST, simcraft)
   DKROT_RegisterRotation(DKROT.SPECS.FROST, simcraftdw)
   DKROT_RegisterRotation(DKROT.SPECS.FROST, skullflower)
   DKROT_RegisterRotation(DKROT.SPECS.FROST, skullflowerdw)

   -- Function to determine AOE rotation for Frost Spec
   function DKROT:FrostAOEMove()
      -- Rune Info
      local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud, lud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()

      -- AOE:Howling Blast if both Frost runes and/or both Death runes are up
      if DKROT:QuickAOESpellCheck(DKROT.spells["Howling Blast"]) and ((lfrost <= 0) or (lblood <= 0) or (lunholy <= 0 and lud)) then
         return "Howling Blast"
      end

      -- AOE:DnD if both Unholy Runes are up
      if DKROT:QuickAOESpellCheck(DKROT.spells["Death and Decay"]) and (lunholy <= 0) then
         return "Death and Decay", true
      end

      -- AOE:Frost Strike if RP capped
      if DKROT:QuickAOESpellCheck(DKROT.spells["Frost Strike"]) and (UnitPower("player") > 88) then
         return "Frost Strike"
      end

      -- AOE:Howling Blast
      if DKROT:QuickAOESpellCheck(DKROT.spells["Howling Blast"]) and (frost <= 0 or death >= 1) then
         return "Howling Blast"
      end

      -- AOE:DnD
      if DKROT:QuickAOESpellCheck(DKROT.spells["Death and Decay"]) and (unholy <= 0) then
         return "Death and Decay"
      end

      -- AOE:Frost Strike
      if DKROT:QuickAOESpellCheck(DKROT.spells["Frost Strike"]) and UnitPower("player") >= 20 then
         return "Frost Strike"
      end

      -- AOE:PS
      if DKROT:QuickAOESpellCheck(DKROT.spells["Plague Strike"]) and (unholy <= 0) then
         return "Plague Strike"
      end

      return nil
   end
end
