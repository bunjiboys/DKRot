if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   function DKROT:LoadSpells()
      if DKROT.spells ~= nil then wipe(DKROT.spells) end
      DKROT.spells = {}
      DKROT.spells = {
         ["Anti-Magic Shell"] = GetSpellInfo(48707), -- lvl68
         ["Army of the Dead"] = GetSpellInfo(42650), -- lvl80
         ["Blood Boil"] = GetSpellInfo(50842), -- lvl56
         ["Blood Plague"] = GetSpellInfo(55078),
         ["Dark Simulacrum"] = GetSpellInfo(77606), -- lvl85, Cata
         ["Death and Decay"] = GetSpellInfo(43265), -- lvl60
         ["Death Coil"] = GetSpellInfo(47541),
         ["Death Grip"] = GetSpellInfo(49576),
         ["Death Strike"] = GetSpellInfo(49998),  -- lvl56
         ["Empower Rune Weapon"] = GetSpellInfo(47568), -- lvl76
         ["Frost Fever"] = GetSpellInfo(55095),
         ["Horn of Winter"] = GetSpellInfo(57330),
         ["Icebound Fortitude"] = GetSpellInfo(48792), -- lvl62
         ["Icy Touch"] = GetSpellInfo(45477),
         ["Mind Freeze"] = GetSpellInfo(47528), -- lvl57
         ["Outbreak"] = GetSpellInfo(77575), -- lvl81, Cata
         ["Plague Strike"] = GetSpellInfo(45462),
         ["Raise Ally"] = GetSpellInfo(61999), -- lvl72
         ["Raise Dead"] = GetSpellInfo(46584), -- lvl56
         ["Soul Reaper"] = GetSpellInfo(114866), -- lvl87, MoP
         ["Strangulate"] = GetSpellInfo(47476), -- lvl58
         ["Unholy Strength"] = GetSpellInfo(53365),

         -- Talents
         ["Anti-Magic Zone"] = GetSpellInfo(51052), -- lvl57
         ["Asphyxiate"] = GetSpellInfo(108194), -- lvl58, MoP
         ["Blood Charge"] = GetSpellInfo(114851), -- lvl75
         ["Blood Tap"] = GetSpellInfo(45529), -- lvl75
         ["Breath of Sindragosa"] = GetSpellInfo(152279), -- lvl100, WoD
         ["Chilblains"] = GetSpellInfo(50041), -- lvl58
         ["Conversion"] = GetSpellInfo(119975), -- lvl60, MoP
         ["Death Pact"] = GetSpellInfo(48743), -- lvl60
         ["Death Siphon"] = GetSpellInfo(108196), -- lvl60, MoP
         ["Death's Advance"] = GetSpellInfo(96268), -- lvl58, MoP
         ["Defile"] = GetSpellInfo(152280), -- lvl100, WoD
         ["Desecrated Ground"] = GetSpellInfo(108201), -- lvl90, MoP
         ["Gorefiend's Grasp"] = GetSpellInfo(108199), -- lvl90, MoP
         ["Lichborne"] = GetSpellInfo(49039), -- lvl57
         ["Necrotic Plague"] = GetSpellInfo(152281), -- lvl100, WoD
         ["Plague Leech"] = GetSpellInfo(123693), -- lvl56, MoP
         ["Remorseless Winter"] = GetSpellInfo(108200), -- lvl90, MoP
         ["Runic Corruption"] = GetSpellInfo(51460), -- lvl75
         ["Unholy Blight"] = GetSpellInfo(115989), -- lvl56, MoP

         -- Blood Only
         ["Blood Shield"] = GetSpellInfo(77535),
         ["Bone Shield"] = GetSpellInfo(49222), -- lvl78
         ["Crimson Scourge"] = GetSpellInfo(81136), -- lvl84
         ["Dancing Rune Weapon"] = GetSpellInfo(49028), -- lvl74
         ["Dark Command"] = GetSpellInfo(56222), -- lvl58
         ["Rune Tap"] = GetSpellInfo(48982), -- lvl64
         ["Scent of Blood"] = GetSpellInfo(49509), -- lvl62, MoP
         ["Vampiric Blood"] = GetSpellInfo(55233), -- lvl76
         ["Will of the Necropolis"] = GetSpellInfo(81164), -- lvl70

         -- Frost Only
         ["Freezing Fog"] = GetSpellInfo(59052), -- lvl70
         ["Frost Strike"] = GetSpellInfo(49143),
         ["Howling Blast"] = GetSpellInfo(49184),
         ["Killing Machine"] = GetSpellInfo(51124), -- lvl63
         ["Obliterate"] = GetSpellInfo(49020), -- lvl58
         ["Pillar of Frost"] = GetSpellInfo(51271), -- lvl68

         -- Unholy Only
         ["Dark Transformation"] = GetSpellInfo(63560), -- lvl70
         ["Enhanced Dark Transformation"] = GetSpellInfo(157412), -- lvl92/100, WoD (random)
         ["Festering Strike"] = GetSpellInfo(85948), -- lvl62, Cata
         ["Gnaw"] =  GetSpellInfo(91800),
         ["Improved Soul Reaper"] = GetSpellInfo(157342), -- lvl92/100, WoD (random)
         ["Scourge Strike"] = GetSpellInfo(55090), -- lvl58
         ["Shadow Infusion"] = GetSpellInfo(91342), -- lvl60
         ["Sudden Doom"] = GetSpellInfo(81340), -- lvl64
         ["Summon Gargoyle"] = GetSpellInfo(49206), -- lvl74

         -- Racials
         ["Human"] = GetSpellInfo(59752),-- Every Man for Himself
         ["Dwarf"] = GetSpellInfo(20594),-- Stoneform
         ["NightElf"] = GetSpellInfo(58984),-- Shadowmeld
         ["Gnome"] = GetSpellInfo(20589),-- Escape Artist
         ["Draenei"] = GetSpellInfo(28880),-- Gift of the Naaru
         ["Worgen"] = GetSpellInfo(68992),-- Darkflight

         ["Orc"] = GetSpellInfo(33697),-- Blood Fury
         ["Scourge"] = GetSpellInfo(7744),-- Will of the Forsaken
         ["Tauren"] = GetSpellInfo(20549),-- War Stomp
         ["Troll"] = GetSpellInfo(26297),-- Berserking
         ["BloodElf"] = GetSpellInfo(28730),-- Arcane Torrent
         ["Goblin"] = GetSpellInfo(69070),-- Rocket Jump

         -- Other
         ["Draenic Strength Potion"] = GetSpellInfo(156579),
         ["Bloodlust"] = GetSpellInfo(2825),
         ["Heroism"] = GetSpellInfo(32182),
         ["Time Warp"] = GetSpellInfo(145534),
         ["Ancient Hysteria"] = GetSpellInfo(90355),
         ["Sated"] = GetSpellInfo(57724),
      }

      DKROT.DTspells = { -- ID, Duration, Effected by talent
         [DKROT.spells["Frost Fever"]] = {55095, 30},
         [DKROT.spells["Blood Plague"]] = {55078, 30},
         [DKROT.spells["Death and Decay"]] = {43265, 10},
         [DKROT.spells["Defile"]] = {152280, 10},
         [DKROT.spells["Necrotic Plague"]] = {152281, 30},
         [DKROT.spells["Chilblains"]] = {50435, 10},
      }
      DKROT:Debug("Spells Loaded")
   end

   function DKROT:LoadCooldowns()
      if DKROT.Cooldowns~= nil then wipe(DKROT.Cooldowns) end
      DKROT.Cooldowns = {}
      DKROT.Cooldowns = {
         NormCDs = {-- CDs that all DKs get
            DKROT.spells["Anti-Magic Shell"],
            DKROT.spells["Army of the Dead"],
            DKROT.spells["Blood Charge"],
            DKROT.spells["Chilblains"],
            DKROT.spells["Dark Simulacrum"],
            DKROT.spells["Death and Decay"],
            DKROT.spells["Death Grip"],
            DKROT.spells["Empower Rune Weapon"],
            DKROT.spells["Horn of Winter"],
            DKROT.spells["Icebound Fortitude"],
            DKROT.spells["Mind Freeze"],
            DKROT.spells["Outbreak"],
            DKROT.spells["Raise Ally"],
            DKROT.spells["Raise Dead"],
            DKROT.spells["Strangulate"],
            DKROT.spells["Unholy Blight"],
            DKROT.spells["Unholy Strength"],
         },
         TalentCDs ={
            DKROT.spells["Anti-Magic Zone"],
            DKROT.spells["Asphyxiate"],
            DKROT.spells["Conversion"],
            DKROT.spells["Death's Advance"],
            DKROT.spells["Death Pact"],
            DKROT.spells["Desecrated Ground"],
            DKROT.spells["Gorefiend's Grasp"],
            DKROT.spells["Lichborne"],
            DKROT.spells["Plague Leech"],
            DKROT.spells["Remorseless Winter"],
            DKROT.spells["Runic Corruption"],
         },
         BloodCDs = {
            DKROT.spells["Blood Shield"],
            DKROT.spells["Bone Shield"],
            DKROT.spells["Crimson Scourge"],
            DKROT.spells["Dancing Rune Weapon"],
            DKROT.spells["Dark Command"],
            DKROT.spells["Rune Tap"],
            DKROT.spells["Scent of Blood"],
            DKROT.spells["Vampiric Blood"],
            DKROT.spells["Will of the Necropolis"],
         },
         FrostCDs = {
            DKROT.spells["Freezing Fog"],
            DKROT.spells["Killing Machine"],
            DKROT.spells["Pillar of Frost"],
         },
         UnholyCDs = {
            DKROT.spells["Dark Transformation"],
            DKROT.spells["Gnaw"],
            DKROT.spells["Shadow Infusion"],
            DKROT.spells["Sudden Doom"],
            DKROT.spells["Summon Gargoyle"],
         },
         Buffs = {-- List of Buffs {Who gets buff?, Is it also a CD?}
            -- normal
            [DKROT.spells["Anti-Magic Shell"]] = {"player", true},
            [DKROT.spells["Asphyxiate"]] = {"target", true},
            [DKROT.spells["Blood Charge"]] = {"player", false},
            [DKROT.spells["Chilblains"]] = {"target", false},
            [DKROT.spells["Conversion"]] = {"player", false},
            [DKROT.spells["Dark Simulacrum"]] = {"target", true},
            [DKROT.spells["Death's Advance"]] = {"player", true},
            [DKROT.spells["Horn of Winter"]] = {"player", true},
            [DKROT.spells["Icebound Fortitude"]] = {"player", true},
            [DKROT.spells["Lichborne"]] = {"player", true},
            [DKROT.spells["Remorseless Winter"]] = {"player", true},
            [DKROT.spells["Remorseless Winter"]] = {"target", true},
            [DKROT.spells["Runic Corruption"]] = {"player", false},
            [DKROT.spells["Soul Reaper"]] = {"target", false},
            [DKROT.spells["Strangulate"]] = {"target", true},
            [DKROT.spells["Unholy Blight"]] = {"player", true},
            [DKROT.spells["Unholy Strength"]] = {"player", false},

            -- blood
            [DKROT.spells["Blood Shield"]] = {"player", false},
            [DKROT.spells["Bone Shield"]] = {"player", true},
            [DKROT.spells["Crimson Scourge"]] = {"player", false},
            [DKROT.spells["Dancing Rune Weapon"]] = {"player", true},
            [DKROT.spells["Scent of Blood"]] = {"player", false},
            [DKROT.spells["Vampiric Blood"]] = {"player", true},
            [DKROT.spells["Will of the Necropolis"]] = {"player", false},

            -- frost
            [DKROT.spells["Pillar of Frost"]] = {"player", true},
            [DKROT.spells["Freezing Fog"]] = {"player", false},
            [DKROT.spells["Killing Machine"]] = {"player", false},

            -- unholy
            [DKROT.spells["Dark Transformation"]] = {"pet", false},
            [DKROT.spells["Shadow Infusion"]] = {"pet", false},
            [DKROT.spells["Sudden Doom"]] = {"player", false},
         },
         Moves = {-- List of Moves that can be watched when availible
            DKROT.spells["Blood Boil"],
            DKROT.spells["Death Coil"],
            DKROT.spells["Death Siphon"],
            DKROT.spells["Death Strike"],
            DKROT.spells["Festering Strike"],
            DKROT.spells["Frost Strike"],
            DKROT.spells["Howling Blast"],
            DKROT.spells["Icy Touch"],
            DKROT.spells["Obliterate"],
            DKROT.spells["Plague Strike"],
            DKROT.spells["Scourge Strike"],
            DKROT.spells["Soul Reaper"],
         },
      }
      DKROT:Debug("Cooldowns Loaded")
      return DKROT.Cooldowns
   end

   function DKROT:LoadTrinkets()
      DKROT.Cooldowns.Trinkets = {
         [111232] = { spell = 126679, type = DKROT.TrinketType.OnUse, cooldown = 60 }, -- Primal Gladiator's Badge of Victory (H)
         [111305] = { spell = 42292,  type = DKROT.TrinketType.OnUse, cooldown = 120 }, -- Gladiator's Emblem (H)
         [111306] = { spell = 42292,  type = DKROT.TrinketType.OnUse, cooldown = 120 }, -- Gladiator's Medallion (A)
         [113834] = { spell = 176876, type = DKROT.TrinketType.OnUse, cooldown = 120 }, -- Pol's Blinded Eye
         [113931] = { spell = 176878, type = DKROT.TrinketType.OnUse, cooldown = 120 }, -- Beating Heart of the Mountain
         [113969] = { spell = 176874, type = DKROT.TrinketType.OnUse, cooldown = 120 }, -- Vial of Convulsive Shadows
         [115759] = { spell = 126679, type = DKROT.TrinketType.OnUse, cooldown = 60 }, -- Primal Gladiator's Badge of Victory (A)
         [118882] = { spell = 177189, type = DKROT.TrinketType.OnUse, cooldown = 90 }, -- Scabbard of Kyanos
         [118884] = { spell = 176460, type = DKROT.TrinketType.OnUse, cooldown = 120 }, -- Kyb's Foolish Perseverance
         [113978] = { spell = 177102, type = DKROT.TrinketType.Stacking, duration = 10 }, -- Battering Talisman
         [113983] = { spell = 177096, type = DKROT.TrinketType.Stacking, duration = 10 }, -- Forgemaster's Insignia 
         [112318] = { spell = 162915, type = DKROT.TrinketType.Stacking, duration = 20 }, -- Skull of War
         [112319] = { spell = 162917, type = DKROT.TrinketType.Stacking, duration = 20 }, -- Knight's Badge
         [113645] = { spell = 177040, type = DKROT.TrinketType.RPPM, duration = 10 }, -- Tectus' Beating Heart
         [113861] = { spell = 177053, type = DKROT.TrinketType.RPPM, duration = 10 }, -- Evergaze Arcane Eidolon
         [113893] = { spell = 177056, type = DKROT.TrinketType.RPPM, duration = 10 }, -- Blast Furnace Door
         [116292] = { spell = 176974, type = DKROT.TrinketType.RPPM, duration = 10 }, -- Mote of the Mountain
         [119193] = { spell = 177042, type = DKROT.TrinketType.RPPM, duration = 10 }, -- Horn of Screaming Spirits 
      }

      DKROT:Debug("Trinkets Loaded")
      return true
   end

   -- Cooldown Defaults
   function DKROT:CooldownDefaults()
      if DKROT_Settings.CD ~= nil then
         wipe(DKROT_Settings.CD)
      end

      DKROT_Settings.CD = {
         [DKROT.SPECS.UNHOLY] = {
            ["DKROT_CDRPanel_DD_Priority"] = {DKROT_OPTIONS_CDR_CD_PRIORITY, nil},
            DiseaseOption = DISEASE_BOTH,
            Rotation = DKROT:GetDefaultSpecRotation(DKROT.SPECS.UNHOLY),
            Outbreak = true,
            RP = true,
            UB = false,
            PL = true,
            ERW = false,
            BT = true,
            UseHoW = true,
            BossCD = true,
            PrePull = true,

            [1] = true,
            ["DKROT_CDRPanel_DD_CD1_One"] = {DKROT.spells["Shadow Infusion"], true},
            ["DKROT_CDRPanel_DD_CD1_Two"] = {DKROT.spells["Dark Transformation"], true},

            [2] = true,
            ["DKROT_CDRPanel_DD_CD2_Two"] = {DKROT.spells["Sudden Doom"], true},

            [3] = false,
            ["DKROT_CDRPanel_DD_CD3_One"] = {DKROT.spells["Summon Gargoyle"], nil},

            [4] = false,
            ["DKROT_CDRPanel_DD_CD4_One"] = {DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT1, nil},
            ["DKROT_CDRPanel_DD_CD4_Two"] = {DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT2, nil},
         },

         [DKROT.SPECS.FROST] = {
            ["DKROT_CDRPanel_DD_Priority"] = {DKROT_OPTIONS_CDR_CD_PRIORITY, nil},
            DiseaseOption = DISEASE_BOTH,
            Rotation = DKROT:GetDefaultSpecRotation(DKROT.SPECS.FROST),
            Outbreak = true,
            RP = true,
            UB = true,
            PL = true,
            ERW = false,
            BT = true,
            UseHoW = true,
            BossCD = true,
            PrePull = true,

            [1] = true,
            ["DKROT_CDRPanel_DD_CD1_One"] = {DKROT.spells["Pillar of Frost"], nil},
            ["DKROT_CDRPanel_DD_CD1_Two"] = {DKROT.spells["Pillar of Frost"], true},

            [2] = true,
            ["DKROT_CDRPanel_DD_CD2_One"] = {DKROT.spells["Killing Machine"], true},
            ["DKROT_CDRPanel_DD_CD2_Two"] = {DKROT.spells["Freezing Fog"], true},

            [3] = false,
            ["DKROT_CDRPanel_DD_CD3_Two"] = {DKROT.spells["Plague Leech"], nil},

            [4] = false,
            ["DKROT_CDRPanel_DD_CD4_One"] = {DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT1, nil},
            ["DKROT_CDRPanel_DD_CD4_Two"] = {DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT2, nil},
         },

         [DKROT.SPECS.BLOOD] = {
            ["DKROT_CDRPanel_DD_Priority"] = {DKROT_OPTIONS_CDR_CD_PRIORITY, nil},
            DiseaseOption = DISEASE_BOTH,
            Rotation = DKROT:GetDefaultSpecRotation(DKROT.SPECS.BLOOD),
            Outbreak = true,
            RP = true,
            UB = true,
            PL = false,
            ERW = false,
            BT = true,
            UseHoW = true,
            BossCD = true,
            PrePull = false,

            [1] = true,
            ["DKROT_CDRPanel_DD_CD1_One"] = {DKROT.spells["Bone Shield"], true},
            ["DKROT_CDRPanel_DD_CD1_Two"] = {DKROT.spells["Vampiric Blood"], nil},

            [2] = true,
            ["DKROT_CDRPanel_DD_CD2_One"] = {DKROT.spells["Rune Tap"], nil},
            ["DKROT_CDRPanel_DD_CD2_Two"] = {DKROT.spells["Scent of Blood"], true},

            [3] = false,
            ["DKROT_CDRPanel_DD_CD3_One"] = {DKROT.spells["Blood Shield"], true},
            ["DKROT_CDRPanel_DD_CD3_Two"] = {DKROT.spells["Blood Charge"], true},

            [4] = false,
            ["DKROT_CDRPanel_DD_CD4_One"] = {DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT1, nil},
            ["DKROT_CDRPanel_DD_CD4_Two"] = {DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT2, nil},
         },

         [DKROT.SPECS.UNKNOWN] = {
            ["DKROT_CDRPanel_DD_Priority"] = {DKROT_OPTIONS_CDR_CD_PRIORITY, nil},
            DiseaseOption = DISEASE_BOTH,
            Rotation = DKROT:GetDefaultSpecRotation(DKROT.SPECS.UNKNOWN),
            Outbreak = true,
            RP = true,
            UB = true,
            PL = true,
            ERW = false,
            BT = true,
            UseHoW = true,
            BossCD = true,
            PrePull = true,

            [1] = true,
            ["DKROT_CDRPanel_DD_CD1_Two"] = {DKROT.spells["Blood Charge"], true},

            [2] = true,
            ["DKROT_CDRPanel_DD_CD2_One"] = {DKROT.spells["Raise Dead"], nil},
            ["DKROT_CDRPanel_DD_CD2_Two"] = {DKROT.spells["Army of the Dead"], nil},

            [3] = false,
            ["DKROT_CDRPanel_DD_CD3_Two"] = {DKROT.spells["Blood Tap"], nil},

            [4] = false,
            ["DKROT_CDRPanel_DD_CD4_One"] = {DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT1, nil},
            ["DKROT_CDRPanel_DD_CD4_Two"] = {DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT2, nil},
         },
      }
   end
end
