-- vim: set ts=3 sw=3 foldmethod=indent:
if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...
   
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
         local oblitProc = select(7, UnitBuff("player", DKROT.spells["Obliteration"]))
         local rp = UnitPower("PLAYER")
         local fs_rp = DKROT:has("Improved Frost Presence") and 25 or 40
    
         -- Horn of Winter
         if DKROT:CanUse("Horn of Winter") and DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end

         -- Pillar of Frost on CD
         if DKROT:CanUse("Pillar of Frost") and DKROT:isOffCD("Pillar of Frost") then
            if DKROT:BossOrPlayer("TARGET") then
               return "Pillar of Frost"
            end
         end

         -- Plague Leech when we have two runes to return, or diseases are about to fall off
         if DKROT:CanUse("Plague Leech") 
            and DKROT:isOffCD("Plague Leech") 
            and DKROT:FullyDepletedRunes() >= 2
            and (dFF > 0 and dBP > 0)
         then
            if (dFF < 5 or dBP < 5) or (
               DKROT:FullyDepletedRunes() >= 2 and DKROT:GetCD("Outbreak") and DKROT:CanUse("Outbreak")
            ) then
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

         -- Howling Blast if Rime is procced
         if rimeProc and DKROT:isOffCD("Howling Blast") then
            return "Howling Blast"
         end

         -- Obliterate if Killing Machine is procced or Unholy runes are capped
         if DKROT:CanUse("Obliterate") and DKROT:isOffCD("Obliterate") and (kmProc or lunholy < 0.5) then
            return "Obliterate"
         end

         -- Blood Tap if we need runes for Soul Reaper
         if DKROT:CanUse("Blood Tap") and DKROT:CanUse("Soul Reaper")
            and DKROT:CanSoulReaper(true) and bloodCharges >= 5
            and DKROT:FullyDepletedRunes() >= 1
         then
            return "Blood Tap"
         end

         -- Outbreak if we are missing a disease
         if DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") and (dFF == 0 or dBP == 0) then
            return "Outbreak"
         end

         -- Plague Strike if we're missing Blood Plague
         if DKROT:isOffCD("Plague Strike") and dBP == 0 then
            return "Plague Strike"
         end

         -- Howling Blast if we're missing Frost Fever
         if kmProc and DKROT:isOffCD("Howling Blast") and dFF == 0 then
            return "Howling Blast"
         end

         -- Frost Strike if RP is over 75
         if rp >= 75 then
            return "Frost Strike"
         end

         -- Obliterate if runes are capped
         if DKROT:CanUse("Obliterate") and lunholy < 0.5 or lfrost < 0.5 or lblood < 0.5 then
            return "Obliterate"
         end

         -- Frost Strike with KM is NOT active and RP is over 25
         if not kmProc and rp >= fs_rp then
            return "Frost Strike"
         end

         -- Empower Rune Weapon if all runes are depleted and we are out of RP
         if DKROT:CanUse("Empower Rune Weapon") and rp < fs_rp and DKROT:DepletedRunes() == 6 then
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
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 and (dFF > 0 and dBP > 0) then
            if (dFF < 5 or dBP < 5) or (DKROT:CanUse("Outbreak") and DKROT:GetCD("Outbreak") < 1.5)
               or (kmProc and not DKROT:isOffCD("Obliterate"))
            then
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
         if DKROT:CanUse("Obliterate") and lunholy == 0 then
            return "Obliterate"
         end

         -- Blood Tap if we have 10 or more charges
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 and DKROT:FullyDepletedRunes() >= 1 then
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
         if rp >= fs_rp then
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

   local dualwield = {
      Name = "Dual Wield",
      InternalName = "FROSTDWDEF",
      ToggleSpells = { "Pillar of Frost", "Plague Leech", "Soul Reaper", "Defile", "Outbreak", "Blood Tap", "Empower Rune Weapon", "Army of the Dead" },
      SuggestedTalents = { "Plague Leech", {"Defile", "Necrotic Plague"}, "Blood Tap" },
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
         local wakeProc = select(7, UnitBuff("player", DKROT.spells["Frozen Wake"]))
         local oblitProc = select(7, UnitBuff("player", DKROT.spells["Obliteration"]))
         local rp = UnitPower("PLAYER")
         local fs_rp = DKROT:has("Improved Frost Presence") and 25 or 40
    
         -- Horn of Winter
         if DKROT:CanUse("Horn or Winter") and DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end

         -- Pillar of Frost on CD
         if DKROT:CanUse("Pillar of Frost") and DKROT:isOffCD("Pillar of Frost") then
            if DKROT:BossOrPlayer("TARGET") then
               return "Pillar of Frost"
            end
         end

         -- Plague Leech when we have two runes to return and
         -- Killing Machine is not up, or diseases are about to fall off
         if DKROT:CanUse("Plague Leech") 
            and DKROT:isOffCD("Plague Leech") 
            and DKROT:FullyDepletedRunes() >= 2
            and (dFF > 0 and dBP > 0)
         then
            if (dFF < 5 or dBP < 5) or (
               not kmProc and DKROT:FullyDepletedRunes() >= 2 and DKROT:GetCD("Outbreak") and DKROT:CanUse("Outbreak")
            ) then
               return "Plague Leech"
            end
         end

         -- Blood Tap with 10 or more charges and RP over 76 or rp over 20 with KM proc
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and (rp >= 76 or (rp >= 20 and kmProc)) and DKROT:FullyDepletedRunes() >= 1 then
            return "Blood Tap"
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and DKROT:CanSoulReaper() then
            return "Soul Reaper"
         end

         -- Defile 
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
             return "Defile"
         end

         -- Blood Tap if needed for defile
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and not DKROT:isOffCD("Defile") and DKROT:FullyDepletedRunes() >= 1 then
             return "Blood Tap"
         end

         -- Frost Strike with Killing Machine and over 88 RP
         if (kmProc and rp >= 88) or rp >= 88 then
            return "Frost Strike"
         end

         -- Obliterate if Killing machine is active and we dont have enough RP for
         -- Frost Strike, Unholy Runes are capped or Obliteration buff is missing
         if DKROT:CanUse("Obliterate") and DKROT:isOffCD("Obliterate") or DKROT:GetCD("Obliterate") < 1 then
            if (kmProc and rp < fs_rp) or (lunholy < 0.5 and not (fd or lfd)) or (DKROT:TierBonus(DKROT.Tiers.TIER18_2p) and not oblitProc) then
               return "Obliterate"
            end
         end

         -- Howling Blast if frost and death runes are capped or Rime is procced
         if (death >= 1 or lfrost < 0.5) or rimeProc then
             return "Howling Blast"
         end

         -- Blood Tap if we have more than 10 stacks
         if DKROT:CanUse("Blood Tap") 
            and bloodCharges >= 5 and (frost > 0 and death < 1) 
            and DKROT:CanSoulReaper(true) and DKROT:FullyDepletedRunes() > 1
         then
             return "Blood Tap"
         end

         -- Outbreak if either disease is missing
         if DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") and (dFF == 0 or dBP == 0) then
            return "Outbreak"
         end

         -- Plague Strike if blood plague is missing
         if dBP == 0 and DKROT:isOffCD("Plague Strike") then
            return "Plague Strike"
         end

         -- Howling Blast if we have a death or Frost rune up
         if death >= 1 or frost == 0 then
            return "Howling Blast"
         end

         -- Frost Strike if we have Tier17 2p bonus and runic power is over 50
         -- and there's less than 5 seconds left on Piller of Frost CD
         if DKROT:TierBonus(DKROT.Tiers.TIER17_2p) and rp >= 50 and DKROT:GetCD("Pillar of Frost") < 5 then
            return "Frost Strike"
         end

         -- Frost Strike if we have more than 25 RP
         if rp >= fs_rp then
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
         local fs_rp = DKROT:has("Improved Frost Presence") and 25 or 40
    
         -- Horn of Winter
         if DKROT:CanUse("Horn of Winter") and DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return "Horn of Winter"
         end

         -- Pllar of Frost on CD
         if DKROT:CanUse("Pillar of Frost") and DKROT:isOffCD("Pillar of Frost") then
            if DKROT:BossOrPlayer("TARGET") then
               return "Pillar of Frost"
            end
         end

         -- Frost Strike with Killing Machine
         if kmProc and rp >= fs_rp then
            return "Frost Strike"
         end

         -- Obliterate if we have an unholy rune
         if DKROT:CanUse("Obliterate") and DKROT:isOffCD("Obliterate") then
             return "Obliterate"
         end

         -- Blood Boil
         if dBP > 0 and DKROT:isOffCD("Blood Boil") then
             return "Blood Boil"
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
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
         if rp >= fs_rp then
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
         if DKROT:CanUse("Empower Rune Weapon") and rp < fs_rp and DKROT:DepletedRunes() == 6 then
            if DKROT:isOffCD("Empower Rune Weapon") and DKROT:BossOrPlayer("TARGET") then
               return "Empower Rune Weapon"
            end
         end

         -- If nothing else can be done
         return nil
      end
   }

   DKROT_RegisterRotation(DKROT.SPECS.FROST, twohand)
   DKROT_RegisterRotation(DKROT.SPECS.FROST, dualwield)

   -- Function to determine AOE rotation for Frost Spec
   function DKROT:FrostAOEMove()
      -- Rune Info
      local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
      local unholy, lunholy, ud, lud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
      local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
      local death = DKROT:DeathRunes()
      local fs_rp = DKROT:has("Improved Frost Presence") and 25 or 40

      -- AOE:Howling Blast if both Frost runes and/or both Death runes are up
      if DKROT:QuickAOESpellCheck("Howling Blast") and ((lfrost <= 0) or (lblood <= 0) or (lunholy <= 0 and lud)) then
         return "Howling Blast"
      end

      -- AOE:DnD if both Unholy Runes are up
      if DKROT:QuickAOESpellCheck("Death and Decay") and (lunholy <= 0) then
         return "Death and Decay", true
      end

      -- AOE:Frost Strike if RP capped
      if DKROT:QuickAOESpellCheck("Frost Strike") and (UnitPower("player") > 88) then
         return "Frost Strike"
      end

      -- AOE:Howling Blast
      if DKROT:QuickAOESpellCheck("Howling Blast") and (frost <= 0 or death >= 1) then
         return "Howling Blast"
      end

      -- AOE:DnD
      if DKROT:QuickAOESpellCheck("Death and Decay") and (unholy <= 0) then
         return "Death and Decay"
      end

      -- AOE:Frost Strike
      if DKROT:QuickAOESpellCheck("Frost Strike") and UnitPower("player") >= fs_rp then
         return "Frost Strike"
      end

      -- AOE:PS
      if DKROT:QuickAOESpellCheck("Plague Strike") and (unholy <= 0) then
         return "Plague Strike"
      end

      return nil
   end
end
