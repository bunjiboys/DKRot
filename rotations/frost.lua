if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...
   
   local function dw_def_tier18_4p()
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

      -- Soul Reaper
      if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
         return "Soul Reaper"
      end

      -- Blood Tap if we have more than 10 stacks
      if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and (frost > 0 and death < 1) and DKROT:CanSoulReaper(true) then
          return "Blood Tap"
      end

      -- Frost Strike with Killing Machine
      if kmProc and rp >= 25 then
         return "Frost Strike"
      end

      -- Obliterate if we have an unholy rune
      if DKROT:isOffCD("Obliterate") or kmProc then
          return "Obliterate"
      end

      -- Defile
      if DKROT:isOffCD("Defile") then
          return "Defile"
      end

      -- Blood Tap
      if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and not DKROT:isOffCD("Defile") then
          return "Blood Tap"
      end

      -- Frost Strike with Killing Machine or Runic Power is above 88
      if rp >= 88 then
         return "Frost Strike"
      end

      -- Howling Blast if we have either a death or a frost rune, or Rime is procced
      if DKROT:isOffCD("Howling Blast") and ((death == 0 or frost == 0) or rimeProc) then
          return "Howling Blast"
      end

      -- Blood Tap if we have over 10 charges and depleted runes
      if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 and DKROT:FullyDepletedRunes() > 0 then
          return "Blood Tap"
      end

      -- Frost Strike with Killing Machine or Runic Power is above 76
      if rp >= 76 then
         return "Frost Strike"
      end

      -- Outbreak if we are missing blood plague
      if DKROT:CanUse("Outbreak") and dBP == 0 and DKROT:isOffCD("Outbreak") then
          return "Outbreak"
      end

      -- Plague Strike if we're missing blood plague
      if DKROT:isOffCD("Plague Strike") and dBP == 0 then
         return "Plague Strike"
      end

      -- Howling Blast if we have 2 or more death+frost runes
      if death >= 2 or lfrost == 0 or (death == 1 and frost == 0) then
          return "Howling Blast"
      end

      -- Blood Tap if we have enough charges and depleted runes
      if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and DKROT:FullyDepletedRunes() > 0 then
          return "Blood Tap"
      end

      -- Plague Leech when we have a fully depleted rune
      if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 and dFF > 0 and dBP > 0 then
         return "Plague Leech"
      end

      -- Empower Rune Weapon if all runes are depleted and we are out of RP
      if DKROT:CanUse("Empower Rune Weapon") and rp < 25 and DKROT:DepletedRunes() == 6 then
         if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
            return "Empower Rune Weapon"
         end
      end

      -- If nothing else can be done
      return nil
   end

   local function dw_def()
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

      -- Blood Tap with 10 or more charges and RP over 76 or rp over 20 with KM proc
      if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and (rp >= 76 or (rp >= 20 and kmProc))  then
         return "Blood Tap"
      end

      -- Soul Reaper
      if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
         return "Soul Reaper"
      end

      -- Blood Tap if we have more than 10 stacks
      if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and (frost > 0 and death < 1) and DKROT:CanSoulReaper(true) then
          return "Blood Tap"
      end

      -- Defile 
      if DKROT:isOffCD("Defile") then
          return "Defile"
      end

      -- Blood Tap if needed for defile
      if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and not DKROT:isOffCD("Defile") then
          return "Blood Tap"
      end

      -- Frost Strike with Killing Machine and over 88 RP
      if kmProc and rp >= 88 then
         return "Frost Strike"
      end

      -- Howling Blast if we have a death or frost rune or missing frost fever
      if (death >= 1 or frost == 0) or dFF == 0 then
          return "Howling Blast"
      end

      -- Plague Strike if blood plague is missing
      if dBP == 0 and DKROT:isOffCD("Plague Strike") then
          return "Plague Strike"
      end

      -- Howling Blast if Rime is active
      if rimeProc and DKROT:isOffCD("Howling Blast") then
          return "Howling Blast"
      end

      -- Frost Strike if we have Tier17 2p bonus and runic power is over 50
      -- and there's less than 5 seconds left on Piller of Frost CD
      if DKROT:TierBonus(DKROT.Tiers.TIER17_2p) and rp >= 50 and DKROT:GetCD("Pillar of Frost") < 5 then
          return "Frost Strike"
      end

      -- Frost Strike if we have more than 76 RP
      if rp >= 76 then
          return "Frost Strike"
      end

      -- Obliterate if we have an unholy rune and Killing Machine is NOT up
      if DKROT:isOffCD("Obliterate") and not kmProc then
          return "Obliterate"
      end

      -- Howling Blast if death + frost runes combined is more than 2 runes
      if death >= 2 or lfrost == 0 or (death == 1 and frost == 0) then
          return "Howling Blast"
      end

      -- Blood Tap
      if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 then
          return "Blood Tap"
      end

      -- Plague Leech when we have a fully depleted rune
      if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 and dFF > 0 and dBP > 0 then
         return "Plague Leech"
      end

      -- Empower Rune Weapon if all runes are depleted and we are out of RP
      if DKROT:CanUse("Empower Rune Weapon") and rp < 25 and DKROT:DepletedRunes() == 6 then
         if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
            return "Empower Rune Weapon"
         end
      end

      -- If nothing else can be done
      return nil
   end

   local twohand = {
      Name = "Two-Hand",
      InternalName = "FROST2H",
      ToggleSpells = { "Pillar of Frost", "Plague Leech", "Soul Reaper", "Defile", "Outbreak", "Blood Tap", "Empower Rune Weapon", "Army of the Dead" },
      SuggestedTalents = { "Plague Leech", "Defile", "Blood Tap" },
      DefaultRotation = true,
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

         -- Plague Leech when we have two runes to return
         if DKROT:CanUse("Plague Leech") 
            and DKROT:isOffCD("Plague Leech") 
            and DKROT:FullyDepletedRunes() > 0
            and dFF > 0 
            and dBP > 0
         then
            return "Plague Leech"
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Blood Tap if we need runes for Soul Reaper
         if DKROT:CanUse("Blood Tap") and DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper(true) and bloodCharges >= 5 then
            return "Blood Tap"
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return "Defile"
         end

         -- Howling Blast with Rime and Killing Machine procs
         if rimeProc and kmProc and (dBP > 5 or dFF > 5) then
            return "Howling Blast"
         end

         -- Obliterate with KM proc
         if kmProc and DKROT:isOffCD("Obliterate") then
            return "Obliterate"
         end

         -- Blood Tap if KM proc is up and we have depleted runes
         if DKROT:CanUse("Blood Tap") and kmProc and bloodCharges >= 5 and DKROT:FullyDepletedRunes() > 0 then
            return "Blood Tap"
         end

         -- Howling Blast if we're missing Frost Fever and Rime is procced
         if DKROT:isOffCD("Howling Blast") and dFF == 0 and rimeProc then
            return "Howling Blast"
         end

         -- Outbreak if we're missing both diseases
         if DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") and dFF == 0 and dBP == 0 then
            return "Outbreak"
         end

         -- Howling Blast if Frost Fever is missing
         if DKROT:isOffCD("Howling Blast") and dFF == 0 then
            return "Howling Blast"
         end

         -- Plague Strike if Blood Plague is missing
         if DKROT:isOffCD("Plague Strike") and dBP == 0 then
            return "Plague Strike"
         end

         -- Blood Tap if we have more than 10 charges and high RP
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 and rp > 76 then
            return "Blood Tap"
         end

         -- Frost Strike when we have more than 76 RP
         if rp > 76 then
            return "Frost Strike"
         end

         -- Howling Blast if Rime is up and we are close to capping runes
         if DKROT:isOffCD("Howling Blast") and rimeProc and (lblood <= 2 or lfrost <= 2 or lunholy <= 2) then
            return "Howling Blast"
         end

         -- Obliterate if we are about to cap runes
         if DKROT:isOffCD("Obliterate") and (lblood <= 2 or lfrost <= 2 or lunholy <= 2) then
            return "Obliterate"
         end

         -- Plague Leech if rune pairs are about to become ready and diseases are about to drop
         if DKROT:CanUse("Plague Leech")
            and DKROT:isOffCD("Plague Leech")
            and (dFF < 3 or dBP < 3)
            and DKROT:FullyDepletedRunes() > 0
            and (
               (blood <= 1 and unholy <= 1)
               or (frost <= 1 and unholy <= 1)
               or (blood <= 1 and unholy <= 1)
            )
         then
            return "Plague Leech"
         end 

         -- Frost Strike if we wont overcap blood charges and Obliterate is not about to be ready
         if rp >= 25 and bloodCharges <= 10 and DKROT:GetCD("Obliterate") <= 1 then
            return "Frost Strike"
         end

         -- Howling Blast if Rime is procced
         if DKROT:isOffCD("Howling Blast") and rimeProc then
            return "Howling Blast"
         end

         -- Obliterate if we are close to capping runes or Bloodlust is up
         if DKROT:isOffCD("Obliterate")
            and (
               DKROT:BloodlustActive()
               or lblood <= 3.5
               or lfrost <= 3.5
               or lunholy <= 3.5
               or DKROT:GetCD("Plague Leech") <= 4
            )
         then
            return "Obliterate"
         end

         -- Blood Tap if we have more than 10 stacks and 20 RP, or some runes are about to cap
         if DKROT:CanUse("Blood Tap")
            and DKROT:FullyDepletedRunes() > 0
            and bloodCharges >= 5
            and (
               (bloodCharges >= 10 and rp >= 20)
               or (
                  lblood >= 3
                  or lfrost >= 3
                  or lunholy >= 3
               )
            )
         then
            return "Blood Tap"
         end

         -- Frost Strike if possible, without KM
         if rp >= 25 and not kmProc then
            return "Frost Strike"
         end

         -- Empower Rune Weapon if all runes are depleted and we are out of RP
         if DKROT:CanUse("Empower Rune Weapon") and rp < 25 and DKROT:DepletedRunes() == 6 then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
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

   local dw_def = {
      Name = "DW - Defile",
      InternalName = "FROSTDWDEF",
      ToggleSpells = { "Pillar of Frost", "Plague Leech", "Soul Reaper", "Defile", "Outbreak", "Blood Tap", "Empower Rune Weapon", "Army of the Dead" },
      SuggestedTalents = { "Plague Leech", "Defile", "Blood Tap" },
      DefaultRotation = false,
      MainRotation = function()
         if DKROT:TierBonus(DKROT.Tiers.TIER18_4p) then
            return dw_def_tier18_4p()
         else
            return dw_def()
         end
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

         -- Frost Strike with Killing Machine
         if kmProc and rp >= 25 then
            return "Frost Strike"
         end

         -- Obliterate if we have an unholy rune
         if DKROT:isOffCD("Obliterate") then
             return "Obliterate"
         end

         -- Blood Boil
         if dBP > 0 and DKROT:isOffCD("Blood Boil") then
             return "Blood Boil"
         end

         -- Defile
         if DKROT:isOffCD("Defile") then
             return "Defile"
         end

         -- Howling Blast
         if DKROT:isOffCD("Howling Blast") then
             return "Howling Blast"
         end

         -- Blood Tap if we have more than 10 stacks
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 and DKROT:FullyDepletedRunes() > 0 then
             return "Blood Tap"
         end

         -- Frost Strike with Killing Machine or Runic Power is above 88
         if rp >= 88 then
            return "Frost Strike"
         end

         -- Plague Strike if we're missing blood plague
         if DKROT:isOffCD("Plague Strike") and dBP == 0 and lunholy == 0 then
            return "Plague Strike"
         end

         -- Blood Tap if we have enough charges and depleted runes
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and DKROT:FullyDepletedRunes() > 0 then
             return "Blood Tap"
         end

         -- Frost Strike if possible
         if rp >= 25 then
             return "Frost Strike"
         end
 
         -- Plague Leech when we have a fully depleted rune
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 and dFF > 0 and dBP > 0 then
            return "Plague Leech"
         end

         -- Plague Strike if we're missing blood plague
         if DKROT:isOffCD("Plague Strike") and dBP == 0 and unholy == 0 then
            return "Plague Strike"
         end

         -- Empower Rune Weapon if all runes are depleted and we are out of RP
         if DKROT:CanUse("Empower Rune Weapon") and rp < 25 and DKROT:DepletedRunes() == 6 then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
         end

         -- If nothing else can be done
         return nil
      end
   }

   local dw_np = {
      Name = "DW - Necrotic Plague",
      InternalName = "FROSTDWNP",
      ToggleSpells = { "Pillar of Frost", "Soul Reaper", "Outbreak", "Blood Tap", "Empower Rune Weapon", "Army of the Dead" },
      SuggestedTalents = { "Unholy Blight", "Necrotic Plague", "Blood Tap" },
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
         local npStacks = select(4, UnitDebuff("TARGET", DKROT.spells["Necrotic Plague"])) or 0
    
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

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Blood Tap if needed for Soul Reaper
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5
            and DKROT:CanSoulReaper() and not DKROT:isOffCD("Soul Reaper")
            and DKROT:FullyDepletedRunes() > 0
         then
            return "Blood Tap"
         end

         -- Frost Strike if Killing Machine is up
         if rp >= 25 and kmProc then
            return "Frost Strike"
         end

         -- Obliterate if we have at least one full unholy rune or Killing Machine is up
         if DKROT:isOffCD("Obliterate") and (unholy == 0 or kmProc) then
            return "Obliterate"
         end

         -- Frost Strike if we have more than 88 RP
         if rp >= 88 then
            return "Frost Strike"
         end

         -- Howling Blast if we have a death or frost rune, or Rime is up
         if (death >= 1 or frost == 0) or rimeProc then
            return "Howling Blast"
         end

         -- Blood Tap if we have more than 10 charges
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and DKROT:FullyDepletedRunes() > 0 then
            return "Blood Tap"
         end

         -- Frost Strike if we have more than 76 RP
         if rp >= 76 then
            return "Frost Strike"
         end

         -- Applying diseases if missing
         if (dFF == 0 or dBP == 0) or npStacks <= 10 then
            -- Unholy Blight
            if DKROT:isOffCD("Unholy Blight") then
               return "Unholy Blight"
            end

            -- Outbreak if we're missing disease on target
            if DKROT:isOffCD("Outbreak") then
               return "Outbreak"
            end

            -- Plague Strike if we're missing disease on target
            if DKROT:isOffCD("Plague Strike") and npStacks == 0 then
               return "Plague Strike"
            end
         end

         -- Howling Blast if death + frost runes combines to more than 2 runes
         if death >= 2 or lfrost == 0 or (death == 1 and frost == 0) then
            return "Howling Blast"
         end

         -- Outbreak if Necrotic Plague is not fully stacked
         if DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") and npStacks <= 14 then
            return "Outbreak"
         end

         -- Blood Tap if we can
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and DKROT:FullyDepletedRunes() > 0 then
            return "Blood Tap"
         end

         -- Empower Rune Weapon if all runes are depleted and we are out of RP
         if DKROT:CanUse("Empower Rune Weapon") and rp < 25 and DKROT:DepletedRunes() == 6 then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
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

         -- Frost Strike with Killing Machine
         if kmProc and rp >= 25 then
            return "Frost Strike"
         end

         -- Obliterate if we have an unholy rune
         if DKROT:isOffCD("Obliterate") then
             return "Obliterate"
         end

         -- Blood Boil
         if dBP > 0 and DKROT:isOffCD("Blood Boil") then
             return "Blood Boil"
         end

         -- Defile
         if DKROT:isOffCD("Defile") then
             return "Defile"
         end

         -- Howling Blast
         if DKROT:isOffCD("Howling Blast") then
             return "Howling Blast"
         end

         -- Blood Tap if we have more than 10 stacks
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 and DKROT:FullyDepletedRunes() > 0 then
             return "Blood Tap"
         end

         -- Frost Strike with Killing Machine or Runic Power is above 88
         if rp >= 88 then
            return "Frost Strike"
         end

         -- Plague Strike if we're missing blood plague
         if DKROT:isOffCD("Plague Strike") and dBP == 0 and lunholy == 0 then
            return "Plague Strike"
         end

         -- Blood Tap if we have enough charges and depleted runes
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and DKROT:FullyDepletedRunes() > 0 then
             return "Blood Tap"
         end

         -- Frost Strike if possible
         if rp >= 25 then
             return "Frost Strike"
         end
 
         -- Plague Leech when we have a fully depleted rune
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 and dFF > 0 and dBP > 0 then
            return "Plague Leech"
         end

         -- Plague Strike if we're missing blood plague
         if DKROT:isOffCD("Plague Strike") and dBP == 0 and unholy == 0 then
            return "Plague Strike"
         end

         -- Empower Rune Weapon if all runes are depleted and we are out of RP
         if DKROT:CanUse("Empower Rune Weapon") and rp < 25 and DKROT:DepletedRunes() == 6 then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
         end

         -- If nothing else can be done
         return nil
      end
   }

   DKROT_RegisterRotation(DKROT.SPECS.FROST, twohand)
   DKROT_RegisterRotation(DKROT.SPECS.FROST, dw_def)
   DKROT_RegisterRotation(DKROT.SPECS.FROST, dw_np)

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
