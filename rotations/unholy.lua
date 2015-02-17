if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local icyveins = {
      Name = "Icy Veins",
      InternalName = "IcyVeins",
      ToggleSpells = { "Death Pact", "Plague Leech", "Soul Reaper", "Defile", "Breath of Sindragosa", "Outbreak", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { "Plague Leech", "Defile" },
      DefaultRotation = false,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local timeToDie = DKROT:GetTimeToDie()
         local bloodCharges = select(4, UnitBuff("PLAYER", DKROT.spells["Blood Charge"]))
         local shadowInfusion = select(4, UnitBuff("PET", DKROT.spells["Shadow Infusion"])) or 0
         local suddenDoom = select(4, UnitBuff("PLAYER", DKROT.spells["Sudden Doom"]))
         local rp = UnitPower("PLAYER")
    
         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return DKROT.spells["Horn of Winter"]
         end

         -- Raise Dead
         if UnitExists("pet") ~= true and DKROT:isOffCD("Raise Dead") then
            return DKROT.spells["Raise Dead"], true
         end

         -- Death Pact
         if DKROT:CanUse("Death Pact") and DKROT:HealthPct("PLAYER") < 30 then
            if DKROT:isOffCD("Death Pact") then
               return DKROT.spells["Death Pact"], true
            end
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and (
               (
                  DKROT:has("Improved Soul Reaper")
                  and DKROT:HealthPct("TARGET") < 45
               )
               or DKROT:HealthPct("TARGET") < 35
            )
         then
            if DKROT:isOffCD("Soul Reaper") then
               return DKROT.spells["Soul Reaper"]
            end
         end

         -- Defile
         if DKROT:CanUse("Defile") then
            if DKROT:isOffCD("Defile") then
               return DKROT.spells["Defile"], true
            end
         end

         -- Diseases
         local disease = DKROT:GetDisease()
         if disease ~= nil then
            return disease
         end

         -- Dark Transformation
         if shadowInfusion == 5 and (
               DKROT:has("Enhanced Dark Transformation") or (unholy <= 0 or death >= 1)
            )
         then
            return DKROT.spells["Dark Transformation"]
         end

         -- Blood Tap with >= 11 Charges
         if DKROT:CanUse("Blood Tap") and bloodCharges ~= nil and bloodCharges >= 11 and DKROT:FullyDepletedRunes() > 0 then
            return DKROT.spells["Blood Tap"], true
         end

         -- Death Coil if ghoul is not transformed or have 5 stacks
         if (rp >= 30 or suddenDoom)
            and shadowInfusion ~= 5
            and UnitBuff("PET", DKROT.spells["Dark Transformation"]) == nil
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
         if rp > 80 or suddenDoom then
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
         if DKROT:CanUse("Blood Tap") and bloodCharges ~= nil and bloodCharges >= 5 and DKROT:FullyDepletedRunes() > 0 then
            return DKROT.spells["Blood Tap"], true
         end

         -- Empower Rune Weapon
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:isOffCD("Empower Rune Weapon") then
            return DKROT.spells["Empower Rune Weapon"]
         end

         if rp >= 30 then
            return DKROT.spells["Death Coil"]
         end

         -- If nothing else can be done
         return nil
      end,
   }

   local simcraft = {
      Name = "SimCraft",
      InternalName = "SimC",
      ToggleSpells = { "Death Pact", "Plague Leech", "Soul Reaper", "Defile", "Summon Gargoyle", "Breath of Sindragosa", "Outbreak", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { "Plague Leech", "Defile" },
      DefaultRotation = true,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local dFF, dBP = DKROT:GetDiseaseTime()
         local timeToDie = DKROT:GetTimeToDie()
         local bloodCharges = select(4, UnitBuff("PLAYER", DKROT.spells["Blood Charge"]))
         local shadowInfusion = select(4, UnitBuff("PET", DKROT.spells["Shadow Infusion"])) or 0
         local suddenDoom = select(4, UnitBuff("PLAYER", DKROT.spells["Sudden Doom"]))
         local rp = UnitPower("PLAYER")

         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return DKROT.spells["Horn of Winter"]
         end

         -- Raise Dead
         if UnitExists("pet") ~= true then
            return DKROT.spells["Raise Dead"], true
         end

         -- Death Pact
         if DKROT:CanUse("Death Pact") and DKROT:HealthPct("PLAYER") < 30 then
            if DKROT:isOffCD("Death Pact") then
               return DKROT.spells["Death Pact"], true
            end
         end

         -- Plague Leech if we have enabled it in the rotation, and we have a fully depleted rune
         if DKROT:CanUse("Plague Leech")
            and DKROT:isOffCD("Plague Leech")
            and DKROT:FullyDepletedRunes() > 0
            and (dFF > 0 and dBP > 0)
         then
            return DKROT.spells["Plague Leech"]
         end

         -- Soul Reaper
         if DKROT:CanUse("Soul Reaper") and (
               (DKROT:has("Improved Soul Reaper") and DKROT:HealthPct("TARGET") < 45)
               or DKROT:HealthPct("TARGET") < 35
            )
         then
            if DKROT:isOffCD("Soul Reaper") and timeToDie > 5 then
               return DKROT.spells["Soul Reaper"]
            end
         end

         -- Defile
         if DKROT:CanUse("Defile") and timeToDie > 10 and DKROT:isOffCD("Defile") then
            return DKROT.spells["Defile"], true
         end

         -- Blood Tap with >= 11 Charges
         if DKROT:CanUse("Blood Tap") and bloodCharges ~= nil and bloodCharges >= 11 and DKROT:FullyDepletedRunes() > 0 then
            return DKROT.spells["Blood Tap"], true
         end

         -- Summon Gargoyle
         if DKROT:CanUse("Summon Gargoyle") and DKROT:isOffCD("Summon Gargoyle") and timeToDie > 30 then
            if DKROT:BossOrPlayer("TARGET") then
               return DKROT.spells["Summon Gargoyle"]
            end
         end

         -- Death Coil if we are close to RP cap or with Sudden Doom proc
         if rp > 90 or suddenDoom then
            return DKROT.spells["Death Coil"]
         end

         -- Dark Transformation
         if shadowInfusion == 5 and (DKROT:has("Enhanced Dark Transformation") or (unholy <= 0 or death >= 1)) then
            return DKROT.spells["Dark Transformation"]
         end

         -- Diseases
         local disease = DKROT:GetDisease()
         if disease ~= nil then
            return disease
         end

         -- Breath of Sindragosa
         if DKROT:CanUse("Breath of Sindragosa") and rp > 75 and DKROT:isOffCD("Breath of Sindragosa") then
            return DKROT.spells["Breath of Sindragosa"]
         end

         -- Blood Tap if both unholy runes are down
         if DKROT:CanUse("Blood Tap")
            and bloodCharges ~= nil and bloodCharges >= 5
            and DKROT:FullyDepletedRunes() > 0
         then
            return DKROT.spells["Blood Tap"], true
         end

         if lunholy <= 0 and DKROT:isOffCD("Scourge Strike") then
            return DKROT.spells["Scourge Strike"]
         end

         -- Death Coil if we have more than 80 RP
         if rp >= 80 then
            return DKROT.spells["Death Coil"]
         end

         -- Festering Strike if both blood and frost runes are up
         if (lblood <= 0 and lfrost <= 0) then
            return DKROT.spells["Festering Strike"]
         end
    
         -- Blood Tap with >= 5 Charges
         if DKROT:CanUse("Blood Tap")
            and bloodCharges ~= nil and bloodCharges >= 5
            and DKROT:FullyDepletedRunes() > 0
         then
            return DKROT.spells["Blood Tap"], true
         end

         if DKROT:isOffCD("Scourge Strike") then
            return DKROT.spells["Scourge Strike"]
         end

         if DKROT:isOffCD("Festering Strike") then
            return DKROT.spells["Festering Strike"]
         end

         -- Death Coil if more than 30 RP
         if rp >= 30 then
            return DKROT.spells["Death Coil"]
         end

         -- Empower Rune Weapon
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:isOffCD("Empower Rune Weapon") then
            return DKROT.spells["Empower Rune Weapon"]
         end

         -- If nothing else can be done
         return nil
      end
   }

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
         local timeToDie = DKROT:GetTimeToDie()
         local shadowInf = select(4, UnitBuff("PET", DKROT.spells["Shadow Infusion"]))
         local doomProc = select(4, UnitBuff("PLAYER", DKROT.spells["Sudden Doom"]))
         local rp = UnitPower("PLAYER")
    
         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return DKROT.spells["Horn of Winter"]
         end

         -- Raise Dead
         if UnitExists("pet") ~= true then
            return DKROT.spells["Raise Dead"], true
         end

         -- Plague Leech when we have two runes to return and 
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 and dFF > 0 and dBP > 0 then
            local start, dur, _ = GetSpellCooldown(DKROT.spells["Outbreak"])
            if (dur == 0 or ((start + dur) < DKROT.curtime))
               or (kmProc and not DKROT:isOffCD("Obliterate"))
            then
               return DKROT.spells["Plague Leech"]
            end
         end

         -- Soul Reaper when below or close to 45% health with improved SR, or close to 35%
         if DKROT:CanUse("Soul Reaper") and DKROT:isOffCD("Soul Reaper") then
            local hp = DKROT:HealthPct("target")
            if (DKROT:has("Improved Soul Reaper") and hp < 45.3) or hp < 35.5 then
               return DKROT.spells["Soul Reaper"]
            end
         end

         -- Summon Gargoyle on CD
         if DKROT:CanUse("Summon Gargoyle") and DKROT:isOffCD("Summon Gargoyle") then
            if DKROT:BossOrPlayer("TARGET") then
               return DKROT.spells["Summon Gargoyle"]
            end
         end

         -- Outbreak when missing one or more diseases
         if DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") and (dFF == 0 or dBP == 0) then
            return DKROT.spells["Outbreak"]
         end

         -- Plague Strike if diseases are missing
         if DKROT:isOffCD("Plague Strike") and (dFF == 0 or dBP == 0) then
            return DKROT.spells["Plague Strike"]
         end

         -- Death and Decay / Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return DKROT.spells["Defile"]
         elseif DKROT:isOffCD("Death and Decay") then
            return DKROT.spells["Death and Decay"]
         end

         -- Scourge Strike when Unholy or Death runes are capped
         if DKROT:isOffCD("Scourge Strike") and (lunholy == 0 or death >= 2) then
            return DKROT.spells["Scourge Strike"]
         end

         -- Festering Strike when both blood and frost runes are capped
         if DKROT:isOffCD("Festering Strike") and lblood == 0 and lfrost == 0 then
            return DKROT.spells["Festering Strike"]
         end

         -- Dark Transformation on CD with 5 stacks of Shadow Infusion
         if DKROT:isOffCD("Dark Transformation") and shadowInf == 5 then
            return DKROT.spells["Dark Transformation"]
         end

         -- Blood Tap when we have 10 or more charges
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 and DKROT:FullyDepletedRunes() > 0 then
            return DKROT.spells["Blood Tap"]
         end

         -- Death Coil with Sudden Doom or RP almost capped
         if doomProc or (rp >= 90 and bloodCharges <= 10) then
            return DKROT.spells["Death Coil"]
         end

         -- Scourge Strike when Unholy or Death rune is recharged
         if unholy == 0 or death >= 1 then
            return DKROT.spells["Scourge Strike"]
         end

         -- Festering Strike if we have a frost and blood rune ready
         if blood == 0 and frost == 0 then
            return DKROT.spells["Festering Strike"]
         end

         -- Blood Tap if we have 5 or more blood charges
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 then
            return DKROT.spells["Blood Tap"]
         end

         -- Death Coil if we have enough RP
         if rp >= 30 then
            return DKROT.spells["Death Coil"]
         end

         -- Empower Rune Weapon when all runes are on CD
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:isOffCD("Empower Rune Weapon") and DKROT:DepletedRunes() == 6 then
            return DKROT.spells["Empower Rune Weapon"]
         end

         if DKROT:CanUse("Army of the Dead") and DKROT:isOffCD("Army of the Dead") then
            return DKROT.spells["Army of the Dead"]
         end

         -- If nothing else is doable
         return nil
      end
   }

   local necroblight = {
      Name = "Necrotic Blight (Skullflower)",
      InternalName = "SFNecroBlight",
      ToggleSpells = { "Death Pact", "Plague Leech", "Soul Reaper", "Death and Decay", "Unholy Blight", "Summon Gargoyle", "Outbreak", "Blood Tap", "Empower Rune Weapon" },
      SuggestedTalents = { "Necrotic Plague", "Unholy Blight" },
      DefaultRotation = false,
      MainRotation = function()
         -- Rune Info
         local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()
         local bloodCharges = select(4, UnitBuff("PLAYER", DKROT.spells["Blood Charge"])) or 0
         local dFF, dBP = DKROT:GetDiseaseTime()
         local timeToDie = DKROT:GetTimeToDie()
         local shadowInf = select(4, UnitBuff("PET", DKROT.spells["Shadow Infusion"]))
         local doomProc = select(4, UnitBuff("PLAYER", DKROT.spells["Sudden Doom"]))
         local npStacks = select(4, UnitDebuff("TARGET", DKROT.spells["Necrotic Plague"])) or 0
         local rp = UnitPower("PLAYER")
    
         -- Horn of Winter
         if DKROT_Settings.CD[DKROT.Current_Spec].UseHoW and DKROT:UseHoW() then
            return DKROT.spells["Horn of Winter"]
         end

         -- Raise Dead
         if UnitExists("pet") ~= true then
            return DKROT.spells["Raise Dead"], true
         end

         -- Plague Leech when we have two runes to return and diseases are about to expire or Outbreak will be ready to re-apply
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and DKROT:FullyDepletedRunes() >= 2 and dFF > 0 and dBP > 0 then
            local start, dur, _ = GetSpellCooldown(DKROT.spells["Outbreak"])
            if (start + dur) < DKROT.curtime and (dFF < 3 or dBP < 3) then
               return DKROT.spells["Plague Leech"]
            end
         end

         -- Soul Reaper when below or close to 45% health with improved SR, or close to 35%
         if DKROT:CanUse("Soul Reaper") and DKROT:isOffCD("Soul Reaper") and DKROT:CanSoulReaper() then
            return DKROT.spells["Soul Reaper"]
         end

         -- Blood Tap if we need a rune for Soul Reaper
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 5 and (frost > 0 and death < 1) and DKROT:CanSoulReaper() then
            return DKROT.spells["Blood Tap"]
         end

         -- Summon Gargoyle
         if DKROT:CanUse("Summon Gargoyle") and DKROT:isOffCD("Summon Gargoyle") and timeToDie > 20 then
            if DKROT:BossOrPlayer("TARGET") then
               return DKROT.spells["Summon Gargoyle"]
            end
         end

         -- Unholy Blight if we dont have diseases active
         if DKROT:CanUse("Unholy Blight") and DKROT:isOffCD("Unholy Blight") and (dFF == 0 or dBP == 0) then
            return DKROT.spells["Unholy Blight"]
         end
         
         -- Outbreak if we are missing a disease
         if DKROT:CanUse("Outbreak") and DKROT:isOffCD("Outbreak") and (dFF == 0 or dBP == 0) then
            return DKROT.spells["Outbreak"]
         end

         -- Plague Strike, if we are missing diseases and Outbreak if on CD
         if DKROT:isOffCD("Plague Strike") and (dFF == 0 or dBP == 0) then
            return DKROT.spells["Plague Strike"]
         end

         -- Defile
         if DKROT:CanUse("Defile") and DKROT:isOffCD("Defile") then
            return DKROT.spells["Defile"], true
         end

         -- DnD
         if DKROT:CanUse("Death and Decay") and DKROT:isOffCD("Death and Decay") and lunholy == 0 then
            return DKROT.spells["Death and Decay"], true
         end

         -- Festering Strike
         if lblood == 0 and lfrost == 0 then
            return DKROT.spells["Festering Strike"]
         end

         -- Scourge Strike
         if lunholy == 0 then
            return DKROT.spells["Scourge Strike"]
         end

         -- Festering Strike if the remaining time on Necrotic Plague is less than the cooldown remaining on Unholy Blight
         if DKROT:isOffCD("Festering Strike") and DKROT:HasTalent("Necrotic Plague") and DKROT:HasTalent("Unholy Blight") then
            local ubcd = DKROT:GetCD(DKROT.spells["Unholy Blight"])

            if dFF < (ubcd / 2) then
               return DKROT.spells["Festering Strike"]
            end
         end

         -- Dark Transformation on CD with 5 stacks of Shadow Infusion
         if DKROT:isOffCD("Dark Transformation") and shadowInf == 5 then
            return DKROT.spells["Dark Transformation"]
         end

         -- Outbreak if Necrotic Plague is active with less than 15 stacks
         if DKROT:CanUse("Outbreak") and DKROT:HasTalent("Necrotic Plague") then
            if DKROT:isOffCD("Outbreak") and npStacks <= 14 then
               return DKROT.spells["Outbreak"]
            end
         end

         -- Blood Tap if we have more than 10 charges
         if DKROT:CanUse("Blood Tap") and bloodCharges >= 10 then
            return DKROT.spells["Blood Tap"]
         end

         -- Death Coil with Sudden Doom or close to RP cap
         if (doomProc or rp >= 80) and bloodCharges <= 10 then
            return DKROT.spells["Death Coil"]
         end

         -- Scourge Strike
         if DKROT:isOffCD("Scourge Strike") then
            return DKROT.spells["Scourge Strike"]
         end

         -- Festering Strike
         if DKROT:isOffCD("Festering Strike") then
            return DKROT.spells["Festering Strike"]
         end

         -- Death Coil
         if rp >= 30 then
            return DKROT.spells["Death Coil"]
         end

         -- Plague Leech
         if DKROT:CanUse("Plague Leech") and DKROT:isOffCD("Plague Leech") and dFF > 0 and dBP > 0 and DKROT:FullyDepletedRunes() > 0 then
            return DKROT.spells["Plague Leech"]
         end

         -- Empower Rune Weapon
         if DKROT:CanUse("Empower Rune Weapon") and DKROT:isOffCD("Empower Rune Weapon") then
            return DKROT.spells["Empower Rune Weapon"]
         end

         -- Nothing else can be done
         return nil
      end
   }

   DKROT_RegisterRotation(DKROT.SPECS.UNHOLY, icyveins)
   DKROT_RegisterRotation(DKROT.SPECS.UNHOLY, simcraft)
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
      if DKROT:has("Unholy Blight") and DKROT:isOffCD("Unholy Blight") then
         return DKROT.spells["Unholy Blight"]
      end

      -- Defile / DND
      if DKROT:has("Defile") then
         if DKROT:isOffCD("Defile") then
            return DKROT.spells["Defile"], true
         end
      end

      -- Diseases
      local disease = DKROT:GetDisease()
      if disease ~= nil then
         return disease
      end

      -- Breath of Sindragosa
      if DKROT:has("Breath of Sindragosa")
         and UnitPower("player") > 75
         and DKROT:isOffCD("Breath of Sindragosa")
      then
         return DKROT.spells["Breath of Sindragosa"]
      end

      -- Blood Boil
      if DKROT:isOffCD("Blood Boil") then
         return DKROT.spells["Blood Boil"]
      end

      -- Summon Gargoyle
      if DKROT:isOffCD("Summon Gargoyle") then
         return DKROT.spells["Summon Gargoyle"]
      end

      return nil
   end
end
