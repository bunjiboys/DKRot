if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...
   DKROT:Debug("Starting")

   -- --- Create Main Frame-- ---
   DKROT.MainFrame = CreateFrame("Button", "DKROT", UIParent)
   DKROT.MainFrame:RegisterEvent("ADDON_LOADED")
   DKROT.MainFrame:SetWidth(94)
   DKROT.MainFrame:SetHeight(68)
   DKROT.MainFrame:SetFrameStrata("BACKGROUND")

   -- --- Locals-- ---
   -- Constants
   local PLAYER_NAME, PLAYER_RACE, PLAYER_PRESENCE = UnitName("player"), select(2, UnitRace("player")), 0
   local BBUUFF, BBFFUU, UUBBFF, UUFFBB, FFUUBB, FFBBUU = 1, 2, 3, 4, 5, 6
   local DISEASE_BOTH, DISEASE_ONE, DISEASE_NONE = 2, 1, 0
   local THREAT_OFF, THREAT_HEALTH, THREAT_ANALOG, THREAT_DIGITAL = 0, 0.1, 1, 99
   local PRESENCE_BLOOD, PRESENCE_FROST, PRESENCE_UNHOLY = 1, 2, 3
   local IS_BUFF = 2
   local ITEM_LOAD_THRESHOLD = .5
   local RUNE_COLOUR = {{1, 0, 0},{0, 0.95, 0},{0, 1, 1},{0.8, 0.1, 1}} -- Blood,  Unholy,  Frost,  Death
   local RuneTexture = {
      "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood",
      "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy",
      "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost",
      "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death",
   }

   -- Variables
   local loaded, mutex = false, false
   local mousex, mousey
   local font = 'Interface\\AddOns\\DKRot\\Font.ttf'
   local GetTime = GetTime
   local darksim = {0, 0}
   local simtime = 0
   local bsamount = 0
   local GCD, curtime, launchtime = 0, 0, 0
   local updatetimer = 0

   DKROT:Debug("Locals Done")

   -- If User has Button Facade, then set up skinning function
   local LBF = LibStub("LibButtonFacade", true)
   local MSQ = LibStub("Masque", true)
   if LBF or MSQ then
      function DKROT:OnSkin(skin, gloss, backdrop, _, _, colours)
         DKROT_Settings.lbf[1] = skin
         DKROT_Settings.lbf[2] = gloss
         DKROT_Settings.lbf[3] = backdrop
         DKROT_Settings.lbf[4] = colours
      end
   end

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
      local loaded = true

      local function AddTrinket(name, info) -- BuffID, Is on use?, (ItemID or ICD), start, cd flag, alternative buff
         if name == nil then
            loaded = false
            DKROT:Debug("Trinket Not Found - Buff: " .. info[1])
         else
            DKROT.Cooldowns.Trinkets[name] = info
         end
      end
      DKROT.Cooldowns.Trinkets = {}

      -- Test trinket that doesn't exist
      -- AddTrinket(select(1, GetItemInfo(1)), {"Test Trinket"})

      -- On-Use
      -- Impatience of Youth
      DKROT.spells["Thrill of Victory"] = GetSpellInfo(91828)
      AddTrinket(select(1, GetItemInfo(62469)), {DKROT.spells["Thrill of Victory"], true, 62469})

      -- Vial of Stolen Memories
      DKROT.spells["Memory of Invincibility"] = GetSpellInfo(92213)
      AddTrinket(select(1, GetItemInfo(59515)), {DKROT.spells["Memory of Invincibility"], true, 59515})

      -- Figurine - King of Boars
      DKROT.spells["King of Boars"] = GetSpellInfo(73522)
      AddTrinket(select(1, GetItemInfo(52351)), {DKROT.spells["King of Boars"], true, 52351})

      -- Figurine - Earthen Guardian
      DKROT.spells["Earthen Guardian"] = GetSpellInfo(73550)
      AddTrinket(select(1, GetItemInfo(52352)), {DKROT.spells["Earthen Guardian"], true, 52352})

      -- Might of the Ocean
      DKROT.spells["Typhoon"] = GetSpellInfo(91340)
      AddTrinket(select(1, GetItemInfo(56285)), {DKROT.spells["Typhoon"], true, 56285})

      -- Magnetite Mirror
      DKROT.spells["Polarization"] = GetSpellInfo(91351)
      AddTrinket(select(1, GetItemInfo(55814)), {DKROT.spells["Polarization"], true, 55814})

      -- Mirror of Broken Images
      DKROT.spells["Image of Immortality"] = GetSpellInfo(92222)
      AddTrinket(select(1, GetItemInfo(62466)), {DKROT.spells["Image of Immortality"], true, 62466})

      -- Essence of the Eternal Flame
      DKROT.spells["Essence of the Eternal Flame"] = GetSpellInfo(97010)
      AddTrinket(select(1, GetItemInfo(69002)), {DKROT.spells["Essence of the Eternal Flame"], true, 69002})

      -- Moonwell Phial
      DKROT.spells["Summon Splashing Waters"] = GetSpellInfo(101492)
      AddTrinket(select(1, GetItemInfo(70143)), {DKROT.spells["Summon Splashing Waters"], true, 70143})

      -- Scales of Life
      DKROT.spells["Weight of a Feather"] = GetSpellInfo(97117)
      AddTrinket(select(1, GetItemInfo(69109)), {DKROT.spells["Weight of a Feather"], true, 69109})

      -- Fire of the Deep
      DKROT.spells["Elusive"] = GetSpellInfo(109779)
      AddTrinket(select(1, GetItemInfo(78008)), {DKROT.spells["Elusive"], true, 78008})

      -- Rotting Skull
      DKROT.spells["Titanic Strength"] = GetSpellInfo(109746)
      AddTrinket(select(1, GetItemInfo(77116)), {DKROT.spells["Titanic Strength"], true, 77116})

      -- Soul Barrier
      DKROT.spells["Soul Barrier"] = GetSpellInfo(138979)
      AddTrinket(select(1, GetItemInfo(94528)), {DKROT.spells["Soul Barrier"], true, 94528})

      -- Badge of Victory
      DKROT.spells["Call of Victory"] = GetSpellInfo(92224)
      AddTrinket(select(1, GetItemInfo(64689)), {DKROT.spells["Call of Victory"], true, 64689})-- Bloodthirsty Gladiator's
      AddTrinket(select(1, GetItemInfo(61034)), {DKROT.spells["Call of Victory"], true, 61034})-- Vicious Gladiator's s9
      AddTrinket(select(1, GetItemInfo(70519)), {DKROT.spells["Call of Victory"], true, 70519})-- Vicious Gladiator's s10
      AddTrinket(select(1, GetItemInfo(70400)), {DKROT.spells["Call of Victory"], true, 70400})-- Ruthless Gladiator's s10
      AddTrinket(select(1, GetItemInfo(72450)), {DKROT.spells["Call of Victory"], true, 72450})-- Ruthless Gladiator's s11
      AddTrinket(select(1, GetItemInfo(73496)), {DKROT.spells["Call of Victory"], true, 73496})-- Cataclysmic Gladiator's s11
      AddTrinket(select(1, GetItemInfo(91410)), {DKROT.spells["Call of Victory"], true, 126679})-- Tyrannical Gladiator's s13
      AddTrinket(select(1, GetItemInfo(94349)), {DKROT.spells["Call of Victory"], true, 126679})-- Tyrannical Gladiator's s13

      -- PvP Trinkets
      DKROT.spells["PvP Trinket"] = GetSpellInfo(42292)
      AddTrinket(select(1, GetItemInfo(64794)), {DKROT.spells["PvP Trinket"], true, 64794})-- Bloodthirsty
      AddTrinket(select(1, GetItemInfo(60807)), {DKROT.spells["PvP Trinket"], true, 60807})-- Vicious s9
      AddTrinket(select(1, GetItemInfo(70607)), {DKROT.spells["PvP Trinket"], true, 70607})-- Vicious s10
      AddTrinket(select(1, GetItemInfo(70395)), {DKROT.spells["PvP Trinket"], true, 70395})-- Ruthless s10
      AddTrinket(select(1, GetItemInfo(72413)), {DKROT.spells["PvP Trinket"], true, 72413})-- Ruthless s11
      AddTrinket(select(1, GetItemInfo(73537)), {DKROT.spells["PvP Trinket"], true, 73537})-- Cataclysmic s11

      AddTrinket(select(1, GetItemInfo(91329)), {DKROT.spells["PvP Trinket"], true, 91329})-- Tyrannical s13
      AddTrinket(select(1, GetItemInfo(91330)), {DKROT.spells["PvP Trinket"], true, 91330})
      AddTrinket(select(1, GetItemInfo(91331)), {DKROT.spells["PvP Trinket"], true, 91331})
      AddTrinket(select(1, GetItemInfo(91332)), {DKROT.spells["PvP Trinket"], true, 91332})

      AddTrinket(select(1, GetItemInfo(91683)), {DKROT.spells["PvP Trinket"], true, 91683})-- Malev s13

      AddTrinket(select(1, GetItemInfo(51378)), {DKROT.spells["PvP Trinket"], true, 51378})
      AddTrinket(select(1, GetItemInfo(51377)), {DKROT.spells["PvP Trinket"], true, 51377})

      -- Stacking Buff
      -- License to Slay
      DKROT.spells["Slayer"] = GetSpellInfo(91810)
      AddTrinket(select(1, GetItemInfo(58180)), {DKROT.spells["Slayer"], false, 0, 0, false})

      -- Fury of Angerforge
      DKROT.spells["Forged Fury"] = GetSpellInfo(91836)
      DKROT.spells["Raw Fury"] = GetSpellInfo(91832)
      AddTrinket(select(1, GetItemInfo(59461)), {DKROT.spells["Forged Fury"], false, 120, 0, false, DKROT.spells["Raw Fury"]})

      -- Apparatus of Khaz'goroth
      DKROT.spells["Titanic Power"] = GetSpellInfo(96923)
      DKROT.spells["Blessing of Khaz'goroth"] = GetSpellInfo(97127)
      AddTrinket(select(1, GetItemInfo(69113)), {DKROT.spells["Blessing of Khaz'goroth"], false, 120, 0, false, DKROT.spells["Titanic Power"]})

      -- Vessel of Acceleration
      DKROT.spells["Accelerated"] = GetSpellInfo(96980)
      AddTrinket(select(1, GetItemInfo(68995)), {DKROT.spells["Accelerated"], false, 0, 0, false})

      -- Eye of Unmaking
      DKROT.spells["Titanic Strength"] = GetSpellInfo(107966)
      AddTrinket(select(1, GetItemInfo(77200)), {DKROT.spells["Titanic Strength"], false, 0, 0, false})

      -- Resolve of Undying
      DKROT.spells["Preternatural Evasion"] = GetSpellInfo(109782)
      AddTrinket(select(1, GetItemInfo(77998)), {DKROT.spells["Preternatural Evasion"], false, 0, 0, false})

      -- Spark of Zandalar
      DKROT.spells["Spark of Zandalar"] = GetSpellInfo(138958)
      AddTrinket(select(1, GetItemInfo(94526)), {DKROT.spells["Spark of Zandalar"], false, 0, 0, false})

      -- Gaze of the Twins
      DKROT.spells["Eye of Brutality"] = GetSpellInfo(139170)
      AddTrinket(select(1, GetItemInfo(94529)), {DKROT.spells["Eye of Brutality"], false, 0, 0, false})

      -- ICD
      -- Heart of Rage
      DKROT.spells["Rageheart"] = GetSpellInfo(92345)
      AddTrinket(select(1, GetItemInfo(65072)), {DKROT.spells["Rageheart"], false, 20*5, 0, false})

      -- Heart of Solace
      DKROT.spells["Heartened"] = GetSpellInfo(91363)
      AddTrinket(select(1, GetItemInfo(55868)), {DKROT.spells["Heartened"], false, 20*5, 0, false})

      -- Crushing Weight
      DKROT.spells["Race Against Death"] = GetSpellInfo(92342)
      AddTrinket(select(1, GetItemInfo(59506)), {DKROT.spells["Race Against Death"], false, 15*5, 0, false})

      -- Symbiotic Worm
      DKROT.spells["Turn of the Worm"] = GetSpellInfo(92235)
      AddTrinket(select(1, GetItemInfo(59332)), {DKROT.spells["Turn of the Worm"], false, 30, 0, false})

      -- Bedrock Talisman
      DKROT.spells["Tectonic Shift"] = GetSpellInfo(92233)
      AddTrinket(select(1, GetItemInfo(58182)), {DKROT.spells["Tectonic Shift"], false, 30, 0, false})

      -- Porcelain Crab
      DKROT.spells["Hardened Shell"] = GetSpellInfo(92174)
      AddTrinket(select(1, GetItemInfo(56280)), {DKROT.spells["Hardened Shell"], false, 20*5, 0, false})

      -- Right Eye of Rajh
      DKROT.spells["Eye of Doom"] = GetSpellInfo(91368)
      AddTrinket(select(1, GetItemInfo(56431)), {DKROT.spells["Eye of Doom"], false, 10*5, 0, false})

      -- Rosary of Light
      DKROT.spells["Rosary of Light"] = GetSpellInfo(102660)
      AddTrinket(select(1, GetItemInfo(72901)), {DKROT.spells["Rosary of Light"], false, 20*5, 0, false})

      -- Creche of the Final Dragon
      DKROT.spells["Find Weakness"] = GetSpellInfo(109744)
      AddTrinket(select(1, GetItemInfo(77992)), {DKROT.spells["Find Weakness"], false, 20*5, 0, false})

      -- Indomitable Pride
      DKROT.spells["Indomitable"] = GetSpellInfo(109786)
      AddTrinket(select(1, GetItemInfo(78003)), {DKROT.spells["Indomitable"], false, 60, 0, false})

      -- Soulshifter Vortex
      DKROT.spells["Haste"] = GetSpellInfo(109777)
      AddTrinket(select(1, GetItemInfo(77990)), {DKROT.spells["Haste"], false, 20*5, 0, false})

      -- Veil of Lies
      DKROT.spells["Veil of Lies"] = GetSpellInfo(102666)
      AddTrinket(select(1, GetItemInfo(72900)), {DKROT.spells["Veil of Lies"], false, 20*5, 0, false})

      -- Spidersilk Spindle
      DKROT.spells["Loom of Fate"] = GetSpellInfo(97130)
      AddTrinket(select(1, GetItemInfo(69138)), {DKROT.spells["Loom of Fate"], false, 60, 0, false})

      -- Master Pit Fighter
      DKROT.spells["Master Pit Fighter"] = GetSpellInfo(109996)
      AddTrinket(select(1, GetItemInfo(74035)), {DKROT.spells["Master Pit Fighter"], false, 20*5, 0, false})

       -- Varo'then's Brooch
       DKROT.spells["Varo'then's Brooch"] = GetSpellInfo(102664)
       AddTrinket(select(1, GetItemInfo(72899)), {DKROT.spells["Varo'then's Brooch"], false, 20*5, 0, false})

      -- Luckydo Coin
      DKROT.spells["Luckydo Coin"] = GetSpellInfo(120175)
      AddTrinket(select(1, GetItemInfo(82578)), {DKROT.spells["Luckydo Coin"], false, 20*5, 0, false})

      -- Brutal Talisman of the Shado-Pan Assault
      DKROT.spells["Surge of Strength"] = GetSpellInfo(138702)
      AddTrinket(select(1, GetItemInfo(94508)), {DKROT.spells["Surge of Strength"], false, 20*5, 0, false})

      -- Fabled Feather of Ji-Kun
      DKROT.spells["Feathers of Fury"] = GetSpellInfo(138759)
      AddTrinket(select(1, GetItemInfo(94515)), {DKROT.spells["Feathers of Fury"], false, 20*5, 0, false})

      DKROT:Debug("Trinkets Loaded")
      return loaded
   end

   -- In: timeleft - seconds
   -- Out: formated string of hours, minutes and seconds
   local function formatTime(timeleft)
      if timeleft > 3600 then
         return format("%dh:%dm", timeleft/3600, ((timeleft%3600)/60))
      elseif timeleft > 600 then
         return format("%dm", timeleft/60)
      elseif timeleft > 60 then
         return format("%d:%2.2d", timeleft/60, timeleft%60)
      end
      return timeleft
   end

   -- In: start- when the spell cd started  dur- duration of the cd
   -- Out: returns if the spell is or will be off cd in the next GCD
   function DKROT:isOffCD(spell)
      local start, dur = GetSpellCooldown(spell)
      return (dur + start - curtime - GCD <= 0)
   end

   local function isRuneOffCD(rune)
      local start, dur, cool = GetRuneCooldown(rune)
      return cool or (dur + start - curtime - GCD <= 0)
   end

   -- In:tabl - table to check if key is in it  key- key you are looking for
   -- Out: returns true if key is in table
   local function inTable(tabl, key)
      for i = 1, #tabl do
         if tabl[i] == key then return true end
      end
      return false
   end

   local resize = nil
   -- Sets up required information for each element that can be moved
   function DKROT:SetupMoveFunction(frame)
      --[[
      frame.Drag = CreateFrame("Button", "ResizeGrip", frame) -- Grip Buttons from Omen2
      frame.Drag:SetFrameLevel(frame:GetFrameLevel() + 100)
      frame.Drag:SetNormalTexture("Interface\\AddOns\\DKRot\\ResizeGrip")
      frame.Drag:SetHighlightTexture("Interface\\AddOns\\DKRot\\ResizeGrip")
      frame.Drag:SetWidth(26)
      frame.Drag:SetHeight(26)
      frame.Drag:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 7, -7)
      frame.Drag:EnableMouse(true)
      frame.Drag:Show()
      frame.Drag:SetScript("OnMouseDown", function(self,button)
         if (not DKROT_Settings.Locked) and button == "LeftButton" then
            mousex, mousey = GetCursorPosition()
            resize = self:GetParent()
         end
      end)

      frame.Drag:SetScript("OnMouseUp", function(self,button)
         if (not DKROT_Settings.Locked) and button == "LeftButton" then
            self:StopMovingOrSizing()
            DKROT_Settings.Location[(self:GetParent()):GetName()].Scale = (self:GetParent()):GetScale()
            resize, mousex, mousey = nil, nil, nil
         end
      end)
      ]]--

      frame:EnableMouse(false)
      frame:SetMovable(true)

      -- When mouse held, move
      frame:SetScript("OnMouseDown", function(self, button)
         DKROT:Debug("Mouse Down " .. self:GetName())
         CloseDropDownMenus()
         self:StartMoving()
      end)

      -- When mouse released, save position
      frame:SetScript("OnMouseUp", function(self, button)
         DKROT:Debug("Mouse Up " .. self:GetName())
         self:StopMovingOrSizing()
         DKROT_Settings.Location[self:GetName()].Point, _, DKROT_Settings.Location[self:GetName()].RelPoint, DKROT_Settings.Location[self:GetName()].X, DKROT_Settings.Location[self:GetName()].Y = self:GetPoint()
         DKROT_PositionPanel_Element_Select(DKROT_PositionPanel_Element, DKROT:GetFrame(self:GetName(), true))
      end)
   end

   -- Icon template
   -- In: name: the name of the icon frame   parent: the icons parent   spellname: the spell the icon will first display   size:height and width in pixels
   -- Out: returns the icon create by parameters
   function DKROT:CreateIcon(name, parent, spellname, size)
      frame = CreateFrame('Button', name, parent)
      frame:SetWidth(size)
      frame:SetHeight(size)
      frame:SetFrameStrata("BACKGROUND")
      frame.Spell = spellname
      frame.c = CreateFrame('Cooldown', nil, frame, "CooldownFrameTemplate")
      frame.c:SetDrawEdge(DKROT_Settings.CDEDGE)
      frame.c:SetAllPoints(frame)
      frame.Icon = frame:CreateTexture("$parentIcon", "DIALOG")
      frame.Icon:SetAllPoints()
      frame.Icon:SetTexture(GetSpellTexture(spellname))
      frame.Time = frame:CreateFontString(nil, 'OVERLAY')
      frame.Time:SetPoint("CENTER",frame, 1, 0)
      frame.Time:SetJustifyH("CENTER")
      frame.Time:SetFont(font, 13, "OUTLINE")
      frame.Stack = frame:CreateFontString(nil, 'OVERLAY')
      frame.Stack:SetPoint("BOTTOMRIGHT",frame, 3, 1)
      frame.Stack:SetJustifyH("CENTER")
      frame.Stack:SetFont(font, 10, "OUTLINE")
      frame:EnableMouse(false)
      return frame
   end

   function DKROT:CreateCDs()
      DKROT.CD = {}

      -- Create two frames in which 2 icons will placed in each
      for i = 1, 4 do
         DKROT.CD[i] = CreateFrame("Button", "DKROT.CD"..i, DKROT.MainFrame)
         DKROT.CD[i]:SetWidth(34)
         DKROT.CD[i]:SetHeight(68)
         DKROT.CD[i]:SetFrameStrata("BACKGROUND")
         DKROT.CD[i]:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = -1, right = -1, top = -1, bottom = -1},}
         DKROT.CD[i]:SetBackdropColor(0, 0, 0, 0.5)
         DKROT:SetupMoveFunction(DKROT.CD[i])
      end

      -- List of CD frame names, using the name of dropdown menu to allow easy saving and fetching
      CDDisplayList = {
         "DKROT_CDRPanel_DD_CD1_One",
         "DKROT_CDRPanel_DD_CD1_Two",
         "DKROT_CDRPanel_DD_CD2_One",
         "DKROT_CDRPanel_DD_CD2_Two",
         "DKROT_CDRPanel_DD_CD3_One",
         "DKROT_CDRPanel_DD_CD3_Two",
         "DKROT_CDRPanel_DD_CD4_One",
         "DKROT_CDRPanel_DD_CD4_Two",
      }

      -- Create the Icons with desired paramaters
      for i = 1, #CDDisplayList do
         DKROT.CD[CDDisplayList[i]] = DKROT:CreateIcon(CDDisplayList[i].."Butt", DKROT.MainFrame, DKROT.spells["Army of the Dead"], 32)
         DKROT.CD[CDDisplayList[i]].Time:SetFont(font, 11, "OUTLINE")
         DKROT.CD[CDDisplayList[i]]:SetParent(DKROT.CD[ceil(i/2)])
         DKROT.CD[CDDisplayList[i]]:EnableMouse(false)
      end

      -- Give Icons their position based on parent
      DKROT.CD[CDDisplayList[1]]:SetPoint("TOPLEFT", DKROT.CD[1], "TOPLEFT", 1, -1)
      DKROT.CD[CDDisplayList[2]]:SetPoint("TOPLEFT", DKROT.CD[CDDisplayList[1]], "BOTTOMLEFT", 0, -2)
      DKROT.CD[CDDisplayList[3]]:SetPoint("TOPRIGHT", DKROT.CD[2], "TOPRIGHT", -1, -1)
      DKROT.CD[CDDisplayList[4]]:SetPoint("TOPLEFT", DKROT.CD[CDDisplayList[3]], "BOTTOMLEFT", 0, -2)
      DKROT.CD[CDDisplayList[5]]:SetPoint("TOPRIGHT", DKROT.CD[3], "TOPRIGHT", -1, -1)
      DKROT.CD[CDDisplayList[6]]:SetPoint("TOPLEFT", DKROT.CD[CDDisplayList[5]], "BOTTOMLEFT", 0, -2)
      DKROT.CD[CDDisplayList[7]]:SetPoint("TOPRIGHT", DKROT.CD[4], "TOPRIGHT", -1, -1)
      DKROT.CD[CDDisplayList[8]]:SetPoint("TOPLEFT", DKROT.CD[CDDisplayList[7]], "BOTTOMLEFT", 0, -2)
      DKROT:Debug("Cooldowns Created")
   end

   function DKROT:CreateUI()
      DKROT:SetupMoveFunction(DKROT.MainFrame)

      -- Create Rune bar frame
      DKROT.RuneBar = CreateFrame("Button", "DKROT.RuneBar", DKROT.MainFrame)
      DKROT.RuneBar:SetHeight(23)
      DKROT.RuneBar:SetWidth(94)
      DKROT.RuneBar:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
      DKROT.RuneBar:SetBackdropColor(0, 0, 0, 0.5)
      DKROT.RuneBar.Text = DKROT.RuneBar:CreateFontString(nil, 'OVERLAY')
      DKROT.RuneBar.Text:SetPoint("TOP", DKROT.RuneBar, "TOP", 0, -2)
      DKROT.RuneBar.Text:SetJustifyH("CENTER")
      DKROT.RuneBar.Text:SetFont(font, 18, "OUTLINE")
      DKROT:SetupMoveFunction(DKROT.RuneBar)

      local function CreateRuneBar()
         frame = CreateFrame('StatusBar', nil, DKROT.RuneBarHolder)
         frame:SetHeight(80)
         frame:SetWidth(8)
         frame:SetOrientation("VERTICAL")
         frame:SetStatusBarTexture('Interface\\Tooltips\\UI-Tooltip-Background', 'OVERLAY')
         frame:SetStatusBarColor(1, 0.2, 0.2, 1)
         frame:GetStatusBarTexture():SetBlendMode("DISABLE")
         frame:Raise()

         frame.back = frame:CreateTexture(nil, 'BACKGROUND', frame)
         frame.back:SetAllPoints(frame)
         frame.back:SetBlendMode("DISABLE")

         frame.Spark = frame:CreateTexture(nil, 'OVERLAY')
         frame.Spark:SetHeight(16)
         frame.Spark:SetWidth(16)
         frame.Spark.c = CreateFrame('Cooldown', nil, frame, "CooldownFrameTemplate")
         frame.Spark.c:SetDrawEdge(DKROT_Settings.CDEDGE)
         frame.Spark.c:SetAllPoints(frame)
         frame.Spark.c.lock = false
         return frame
      end
      DKROT.RuneBarHolder = CreateFrame("Button", "DKROT.RuneBarHolder", DKROT.MainFrame)
      DKROT.RuneBarHolder:SetHeight(100)
      DKROT.RuneBarHolder:SetWidth(110)
      DKROT.RuneBarHolder:SetFrameStrata("BACKGROUND")
      DKROT.RuneBarHolder:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
      DKROT.RuneBarHolder:SetBackdropColor(0, 0, 0, 0.5)
      DKROT.RuneBars = {}
      DKROT.RuneBars[1] = CreateRuneBar()
      DKROT.RuneBars[1]:SetPoint("BottomLeft", DKROT.RuneBarHolder, "BottomLeft", 6, 10)
      for i = 2, 6 do
         DKROT.RuneBars[i] = CreateRuneBar()
         DKROT.RuneBars[i]:SetPoint("BottomLeft",DKROT.RuneBars[i-1],"BottomRight", 10, 0)
      end
      DKROT:SetupMoveFunction(DKROT.RuneBarHolder)

      -- Create Runic Power frame
      DKROT.RunicPower = CreateFrame("Button", "DKROT.RunicPower", DKROT.MainFrame)
      DKROT.RunicPower:SetHeight(23)
      DKROT.RunicPower:SetWidth(47)
      DKROT.RunicPower:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
      DKROT.RunicPower:SetBackdropColor(0, 0, 0, 0.5)
      DKROT.RunicPower.Text = DKROT.RunicPower:CreateFontString(nil, 'OVERLAY')
      DKROT.RunicPower.Text:SetPoint("TOP", DKROT.RunicPower, "TOP", 0, -2)
      DKROT.RunicPower.Text:SetJustifyH("CENTER")
      DKROT.RunicPower.Text:SetFont(font, 18, "OUTLINE")
      DKROT:SetupMoveFunction(DKROT.RunicPower)

      -- Create frame for Diseases with 2 icons for their respective disease
      DKROT.Diseases = CreateFrame("Button", "DKROT.Diseases", DKROT.MainFrame)
      DKROT.Diseases:SetHeight(24)
      DKROT.Diseases:SetWidth(47)
      DKROT.Diseases:SetFrameStrata("BACKGROUND")
      DKROT.Diseases:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
      DKROT.Diseases:SetBackdropColor(0, 0, 0, 0.5)
      DKROT.Diseases.BP = DKROT:CreateIcon("DKROT.Diseases.BP", DKROT.Diseases, 55078, 21)
      DKROT.Diseases.BP:SetParent(DKROT.Diseases)
      DKROT.Diseases.BP:SetPoint("TOPRIGHT", DKROT.Diseases, "TOPRIGHT", -1, -1)
      DKROT.Diseases.BP:SetBackdropColor(0, 0, 0, 0)
      DKROT.Diseases.FF = DKROT:CreateIcon("DKROT.Diseases.FF", DKROT.Diseases, 55095, 21)
      DKROT.Diseases.FF:SetParent(DKROT.Diseases)
      DKROT.Diseases.FF:SetPoint("RIGHT", DKROT.Diseases.BP, "LEFT", -3, 0)
      DKROT.Diseases.FF:SetBackdropColor(0, 0, 0, 0)
      DKROT:SetupMoveFunction(DKROT.Diseases)

      -- Create the Frame and Icon for the large main Priority Icon
      DKROT.Move = DKROT:CreateIcon('DKROT.Move', DKROT.MainFrame, DKROT.spells["Death Coil"], 47)
      DKROT.Move.Time:SetFont(font, 16, "OUTLINE")
      DKROT.Move.Stack:SetFont(font, 15, "OUTLINE")
      DKROT:SetupMoveFunction(DKROT.Move)

      -- Create backdrop for move
      DKROT.MoveBackdrop = CreateFrame('Frame', nil, DKROT.MainFrame)
      DKROT.MoveBackdrop:SetHeight(47)
      DKROT.MoveBackdrop:SetWidth(47)
      DKROT.MoveBackdrop:SetFrameStrata("BACKGROUND")
      DKROT.MoveBackdrop:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
      DKROT.MoveBackdrop:SetBackdropColor(0, 0, 0, 0.5)
      DKROT.MoveBackdrop:SetAllPoints(DKROT.Move)

      -- Mini AOE icon to be placed in the Priority Icon
      DKROT.Move.AOE = DKROT:CreateIcon('DKROT.AOE', DKROT.Move, DKROT.spells["Death Coil"], 18)
      DKROT.Move.AOE:SetPoint("BOTTOMLEFT", DKROT.Move, "BOTTOMLEFT", 2, 2)

      -- Mini Interrupt icon to be placed in the Priority Icon
      DKROT.Move.Interrupt = DKROT:CreateIcon('DKROT.Interrupt', DKROT.Move, DKROT.spells["Mind Freeze"], 18)
      DKROT.Move.Interrupt:SetPoint("TOPRIGHT", DKROT.Move, "TOPRIGHT", -2, -2)
      DKROT:Debug("UI Created")

      DKROT.DT = CreateFrame("Frame", "DKROT.DT", UIPARENT)
      DKROT.DT:SetHeight(5*25)
      DKROT.DT:SetWidth(180)
      DKROT.DT:SetFrameStrata("BACKGROUND")
      DKROT.DT:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
      DKROT.DT:SetBackdropColor(0, 0, 0, 0)
      DKROT.DT:SetScale(0.7)
      DKROT:SetupMoveFunction(DKROT.DT)
      DKROT.DT.Unit = {}

      CreateFrame( "GameTooltip", "BloodShieldTooltip", nil, "GameTooltipTemplate" );
      BloodShieldTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
      BloodShieldTooltip:AddFontStrings(
      BloodShieldTooltip:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" ),
      BloodShieldTooltip:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" ))
   end

   -- --- -Update Frames-- --- -
   -- In:location - name or location of the settings for specific CD   frame- frame in which to set the icon for
   -- Out:: N/A (does not return but does set icon settings
   function DKROT:UpdateCD(location, frame)
      -- Reset Icon
      frame.Time:SetText("")
      frame.Stack:SetText("")

      -- If the option is not set to nothing
      if DKROT_Settings.CD[DKROT.Current_Spec][location] ~= nil and DKROT_Settings.CD[DKROT.Current_Spec][location][1] ~= nil and
         DKROT_Settings.CD[DKROT.Current_Spec][location][1] ~= DKROT_OPTIONS_FRAME_VIEW_NONE then
         frame:SetAlpha(1)
         frame.Icon:SetVertexColor(1, 1, 1, 1)
         if DKROT_Settings.CD[DKROT.Current_Spec][location][1] == DKROT_OPTIONS_CDR_CD_PRIORITY then -- Priority
            -- If targeting something that you can attack and is not dead
            if (UnitCanAttack("player", "target") and (not UnitIsDead("target"))) then
               -- Get Icon from Priority Rotation
               frame.Icon:SetTexture(DKROT:GetNextMove(frame.Icon))
            else
               frame.Icon:SetTexture(nil)
            end
         elseif DKROT_Settings.CD[DKROT.Current_Spec][location][1] == DKROT_OPTIONS_CDR_CD_PRESENCE then -- Presence
            frame.Icon:SetTexture(nil)
            if PLAYER_PRESENCE > 0 then
               frame.Icon:SetTexture(select(1, GetShapeshiftFormInfo(PLAYER_PRESENCE)))
            end
         elseif DKROT_Settings.CD[DKROT.Current_Spec][location][IS_BUFF] then -- Buff/DeBuff
            local icon, count, dur, expirationTime

            if DKROT_Settings.CD[DKROT.Current_Spec][location][1] == DKROT.spells["Dark Simulacrum"] then
               local id
               if (curtime - simtime) >= 5 then
                  simtime = curtime
                  for i = 1, 120 do
                     _, id = GetActionInfo(i)
                     if id == 77606 then
                        darksim[1] = i
                        darksim[2] = 0
                        DKROT:Debug("Dark Simulacrum Action Slot " .. i)
                        break
                     end
                  end
               end
               _, id = GetActionInfo(darksim[1])
               if id ~= nil and id ~= 77606 then
                  if DKROT_Settings.Range and IsSpellInRange(GetSpellInfo(id), "target") == 0 then frame.Icon:SetVertexColor(0.8, 0.05, 0.05, 1) end
                  frame.Icon:SetTexture(GetSpellTexture(id))
                  if darksim[2] == 0 or darksim[2] < curtime then   darksim[2] = curtime + 20 end
                  frame.Time:SetText(floor(darksim[2] - curtime))
                  return
               end
            end

            -- if its on a target then its a debuff, otherwise its a buff
            if DKROT.Cooldowns.Buffs[DKROT_Settings.CD[DKROT.Current_Spec][location][1]][1] == "target" then
               _, _, icon, count, _, dur, expirationTime = UnitDebuff("target", DKROT_Settings.CD[DKROT.Current_Spec][location][1])
            else
               _, _, icon, count, _, dur, expirationTime = UnitBuff(DKROT.Cooldowns.Buffs[DKROT_Settings.CD[DKROT.Current_Spec][location][1]][1], DKROT_Settings.CD[DKROT.Current_Spec][location][1])
            end
            frame.Icon:SetTexture(icon)

            -- If not an aura, set time
            if icon ~= nil and ceil(expirationTime - curtime) > 0 then
               frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
               frame.Time:SetText(formatTime(ceil(expirationTime - curtime)))
               if DKROT_Settings.CD[DKROT.Current_Spec][location][1] == DKROT.spells["Blood Shield"] then count = bsamount end
               if count > 1 then frame.Stack:SetText(count) end
            end



         elseif inTable(DKROT.Cooldowns.Moves, DKROT_Settings.CD[DKROT.Current_Spec][location][1]) then -- Move
            icon = GetSpellTexture(DKROT_Settings.CD[DKROT.Current_Spec][location][1])
            if icon ~= nil then
               -- Check if move is off CD
               if DKROT:isOffCD(DKROT_Settings.CD[DKROT.Current_Spec][location][1]) and IsUsableSpell(DKROT_Settings.CD[DKROT.Current_Spec][location][1]) then
                  icon = DKROT:GetRangeandIcon(frame.Icon, DKROT_Settings.CD[DKROT.Current_Spec][location][1])
               else
                  icon = nil
               end
            end
            frame.Icon:SetTexture(icon)
         elseif DKROT_Settings.CD[DKROT.Current_Spec][location][1] == DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT1 or
            DKROT_Settings.CD[DKROT.Current_Spec][location][1] == DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT2 then -- Trinkets

            local id
            if DKROT_Settings.CD[DKROT.Current_Spec][location][1] == DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT1 then
               id = GetInventoryItemID("player", 13)
            else
               id = GetInventoryItemID("player", 14)
            end
            local trink
            if id ~= nil then
               trink = DKROT.Cooldowns.Trinkets[select(1,GetItemInfo(id))]
            end

            if trink ~= nil then
               local altbuff = false

               -- Buff
               _, _, icon, count, _, dur, expirationTime = UnitBuff("player",trink[1])
               if icon == nil and trink[6] ~= nil then
                  _, _, icon, count, _, dur, expirationTime = UnitBuff("player",trink[6])
                  altbuff = true
               end
               if icon ~= nil then
                  frame.Icon:SetTexture(icon)
                  frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
                  frame.Time:SetText(formatTime(ceil(expirationTime - curtime)))
                  if count > 1 then frame.Stack:SetText(count) end
                  if (not altbuff) and (not trink[5]) then trink[5] = true; trink[4] = curtime end

               -- ICD or Use CD
               else
                  local start, dur, active
                  frame.Icon:SetTexture(GetItemIcon(id))
                  if trink[2] then -- On-Use
                     start, dur, active = GetItemCooldown(trink[3])
                  else -- ICD
                     trink[5] = false
                     dur, start = trink[3], trink[4]
                     active = 1
                  end
                  t = ceil(start + dur - curtime)
                  if t > 0 and active == 1 and dur > 7 then
                     frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
                     if DKROT_Settings.CDS then frame.c:SetCooldown(start, dur) end
                     frame.Time:SetText(formatTime(t))
                  end
               end
            else
               frame.Icon:SetTexture(nil)
            end
         elseif  DKROT_Settings.CD[DKROT.Current_Spec][location][1] == DKROT_OPTIONS_CDR_RACIAL then
            icon = DKROT:GetRangeandIcon(frame.Icon, DKROT.spells[PLAYER_RACE])
            frame.Icon:SetTexture(icon)
            if icon ~= nil then
               start, dur, active =  GetSpellCooldown(DKROT.spells[PLAYER_RACE])
               t = ceil(start + dur - curtime)
               if active == 1 and dur > 7 then
                  frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
                  if DKROT_Settings.CDS then frame.c:SetCooldown(start, dur) end
                  frame.Time:SetText(formatTime(t))
               end
            end

         else -- Cooldown
            icon = DKROT:GetRangeandIcon(frame.Icon, DKROT_Settings.CD[DKROT.Current_Spec][location][1])
            frame.Icon:SetTexture(icon)
            if icon ~= nil then
               start, dur, active =  GetSpellCooldown(DKROT_Settings.CD[DKROT.Current_Spec][location][1])
               t = ceil(start + dur - curtime)
               if active == 1 and dur > 7 then
                  frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
                  if DKROT_Settings.CDS then frame.c:SetCooldown(start, dur) end
                  frame.Time:SetText(formatTime(t))
               end
            end
         end
         -- if the icon is nil, then just hide the frame
         if frame.Icon:GetTexture() == nil then
            frame:SetAlpha(0)
         end
      else
         DKROT_Settings.CD[DKROT.Current_Spec][location][1] = DKROT_OPTIONS_FRAME_VIEW_NONE
         frame:SetAlpha(0)
      end
   end

   -- Used to move individual frames where they are suppose to be displayed, also enables and disables mouse depending on settings
   function DKROT:MoveFrame(self)
      self:ClearAllPoints()
      self:SetPoint(DKROT_Settings.Location[self:GetName()].Point, DKROT_Settings.Location[self:GetName()].Rel, DKROT_Settings.Location[self:GetName()].RelPoint, DKROT_Settings.Location[self:GetName()].X, DKROT_Settings.Location[self:GetName()].Y)
      self:SetBackdropColor(0, 0, 0, DKROT_Settings.Trans)
      self:EnableMouse(not DKROT_Settings.Locked)

      if DKROT_Settings.Location[self:GetName()].Scale ~= nil then
         self:SetScale(DKROT_Settings.Location[self:GetName()].Scale)
      else
         DKROT_Settings.Location[self:GetName()].Scale = 1
      end
   end

   -- Called to update all the frames positions and scales
   function DKROT:UpdatePosition()
      -- DKROT:MoveFrame(DKROT.MainFrame)
      DKROT:MoveFrame(DKROT.CD[1])
      DKROT:MoveFrame(DKROT.CD[2])
      DKROT:MoveFrame(DKROT.CD[3])
      DKROT:MoveFrame(DKROT.CD[4])
      DKROT:MoveFrame(DKROT.DT)
      DKROT:MoveFrame(DKROT.RuneBar)
      DKROT:MoveFrame(DKROT.RuneBarHolder)
      DKROT:MoveFrame(DKROT.RunicPower)
      DKROT:MoveFrame(DKROT.Move)
      DKROT.MoveBackdrop:SetBackdropColor(0, 0, 0, DKROT_Settings.Trans)
      DKROT:MoveFrame(DKROT.Diseases)

      DKROT.DT:SetHeight(DKROT_Settings.DT.Numframes*25)
      if DKROT_Settings.Locked then
         DKROT.DT:SetBackdropColor(0, 0, 0, 0)
         DKROT.DT:EnableMouse(false)
      else
         DKROT.DT:SetBackdropColor(0, 0, 0, 0.35)
         DKROT.DT:EnableMouse(true)
      end

      DKROT:Debug("UpdatePosition")
   end

   -- Return the duration and start/duration of the GCD or 0,nil,nil if GCD is ready
   function DKROT:GetGCD()
      local start, dur = GetSpellCooldown(61304)
      if dur ~= 0 and start ~= nil then
         return dur - (curtime - start), start, dur
      else
         return 0, nil, nil
      end
   end

   -- Main function for updating all information
   function DKROT:UpdateUI()
      if (UnitCanAttack("player", "target") and (not UnitIsDead("target"))) then
         DKROT.MainFrame:SetAlpha(DKROT_Settings.NormTrans)
      else
         DKROT.MainFrame:SetAlpha(DKROT_Settings.CombatTrans)
      end

      if DKROT_Settings.Locked == false and (DKROT.LockDialog == nil or DKROT.LockDialog == false) then
         DKROT.LockDialog = true
         StaticPopup_Show("DKROT_FRAME_UNLOCKED")
      end

      -- GCD
      local gcdStart, gcdDur
      GCD, gcdStart, gcdDur = DKROT:GetGCD()
      if DKROT_Settings.GCD and GCD ~= 0 then
         DKROT.Move.c:SetCooldown(gcdStart, gcdDur)
      end

      -- Runes
      DKROT.RuneBar:SetAlpha((DKROT_Settings.Rune and 1) or 0)
      DKROT.RuneBarHolder:SetAlpha((DKROT_Settings.RuneBars and 1) or 0)
      if DKROT_Settings.Rune or DKROT_Settings.RuneBars then
         local RuneBar = ""
         local place = 1
         local function runetext(i)
            local start, cooldown = GetRuneCooldown(i)
            local r, g, b = unpack(RUNE_COLOUR[GetRuneType(i)])
            local cdtime = start + cooldown - curtime

            if DKROT_Settings.RuneBars then
               DKROT.RuneBars[place]:SetMinMaxValues(0, cooldown)
               DKROT.RuneBars[place]:SetValue(cdtime)
               DKROT.RuneBars[place].back:SetTexture(r, g, b, 0.2)
               DKROT.RuneBars[place].Spark:SetTexture(RuneTexture[GetRuneType(i)])
               DKROT.RuneBars[place].Spark:SetPoint("CENTER", DKROT.RuneBars[place], "BOTTOM", 0, (cdtime <= 0 and 0) or (cdtime < cooldown and (80*cdtime)/cooldown) or 80)

               if cdtime > 0 then
                  DKROT.RuneBars[place].Spark.c.lock = false
                  DKROT.RuneBars[place]:SetAlpha(0.75)
               end

               if (cdtime <= 0) and (not DKROT.RuneBars[place].Spark.c.lock) then
                  DKROT.RuneBars[place].Spark.c:SetCooldown(0,0)
                  DKROT.RuneBars[place].Spark.c.lock = true
                  DKROT.RuneBars[place]:SetAlpha(1)
               end

               place = place + 1
            end

            cdtime = math.ceil(cdtime)
            if cdtime >= cooldown or cdtime >= 10 then
               cdtime = "X"
            elseif cdtime <= 0 then
               cdtime = "*"
            end
            return string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, cdtime)
         end

         local b1, b2, u1, u2, f1, f2 = 1, 2, 3, 4, 5, 6

         if DKROT_Settings.RuneOrder == BBUUFF then
            RuneBar = runetext(b1)..runetext(b2)..runetext(u1)..runetext(u2)..runetext(f1)..runetext(f2)
         elseif DKROT_Settings.RuneOrder == BBFFUU then
            RuneBar = runetext(b1)..runetext(b2)..runetext(f1)..runetext(f2)..runetext(u1)..runetext(u2)
         elseif DKROT_Settings.RuneOrder == UUBBFF then
            RuneBar = runetext(u1)..runetext(u2)..runetext(b1)..runetext(b2)..runetext(f1)..runetext(f2)
         elseif DKROT_Settings.RuneOrder == UUFFBB then
            RuneBar = runetext(u1)..runetext(u2)..runetext(f1)..runetext(f2)..runetext(b1)..runetext(b2)
         elseif DKROT_Settings.RuneOrder == FFUUBB then
            RuneBar = runetext(f1)..runetext(f2)..runetext(u1)..runetext(u2)..runetext(b1)..runetext(b2)
         elseif DKROT_Settings.RuneOrder == FFBBUU then
            RuneBar = runetext(f1)..runetext(f2)..runetext(b1)..runetext(b2)..runetext(u1)..runetext(u2)
         end

         DKROT.RuneBar.Text:SetText(RuneBar)
      end

      -- RunicPower
      if DKROT_Settings.RP then
         DKROT.RunicPower:SetAlpha(1)
         r, g, b = unpack(RUNE_COLOUR[3])
         DKROT.RunicPower.Text:SetText(string.format("|cff%02x%02x%02x%.3d|r",r*255, g*255, b*255, UnitPower("player")))
      else
         DKROT.RunicPower:SetAlpha(0)
      end

      -- Diseases
      if DKROT_Settings.Disease then
         DKROT.Diseases:SetAlpha(1)
         DKROT.Diseases.FF.Icon:SetVertexColor(1, 1, 1, 1)
         DKROT.Diseases.BP.Icon:SetVertexColor(1, 1, 1, 1)
         DKROT.Diseases.FF.Time:SetText("")
         DKROT.Diseases.BP.Time:SetText("")
         if UnitCanAttack("player", "target") and (not UnitIsDead("target")) then
            local expires = select(7,UnitDebuff("TARGET", DKROT.spells["Frost Fever"], nil, "PLAYER"))
            if  expires ~= nil and (expires - curtime) > 0 then
               DKROT.Diseases.FF.Icon:SetVertexColor(.5, .5, .5, 1)
               DKROT.Diseases.FF.Time:SetText(string.format("|cffffffff%.2d|r", expires - curtime))
            end

            expires = select(7,UnitDebuff("TARGET", DKROT.spells["Blood Plague"], nil, "PLAYER"))
            if expires ~= nil and (expires - curtime) > 0 then
               DKROT.Diseases.BP.Icon:SetVertexColor(.5, .5, .5, 1)
               DKROT.Diseases.BP.Time:SetText(string.format("|cffffffff%.2d|r", expires - curtime))
            end
         end
      else
         DKROT.Diseases:SetAlpha(0)
      end

      -- Priority Icon
      DKROT.Move.AOE:SetAlpha(0)
      DKROT.Move.Interrupt:SetAlpha(0)
      if DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][1] ~= DKROT_OPTIONS_FRAME_VIEW_NONE then
         DKROT.Move:SetAlpha(1)
         DKROT.MoveBackdrop:SetAlpha(1)
         DKROT:UpdateCD("DKROT_CDRPanel_DD_Priority", DKROT.Move)

         -- If Priority on Main Icon
         if DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][1] == DKROT_OPTIONS_CDR_CD_PRIORITY then
            if DKROT_Settings.MoveAltInterrupt then -- Show Interrupt
               local spell, notint = select(1, UnitCastingInfo("target")), select(9, UnitCastingInfo("target"))
               if spell == nil then spell, notint = select(1, UnitChannelInfo("target")), select(8, UnitChannelInfo("target")) end
               if spell ~= nil and not notint then
                  if DKROT:isOffCD(DKROT.spells["Mind Freeze"]) then
                     DKROT.Move.Interrupt:SetAlpha(1)
                  end
               end
            end
         end
      else
         DKROT.Move:SetAlpha(0)
         DKROT.MoveBackdrop:SetAlpha(0)
      end

      -- CDs
      for i = 1, #CDDisplayList do
         if DKROT_Settings.CD[DKROT.Current_Spec][ceil(i/2)] then
            DKROT.CD[ceil(i/2)]:SetAlpha(1)
            DKROT:UpdateCD(CDDisplayList[i], DKROT.CD[CDDisplayList[i]])
         else
            DKROT.CD[ceil(i/2)]:SetAlpha(0)
         end
      end

      local temp
      for i = 1, 40 do
         if select(1, UnitBuff("player", i)) ~= nil then
            if UnitBuff("player", i) == DKROT.spells["Blood Shield"] then
               BloodShieldTooltip:SetUnitBuff("player", i)
               temp = string.gsub(_G["BloodShieldTooltipTextLeft"..2]:GetText(), "[^%d]", "")

               temp = tonumber(temp)
               if temp ~= nil and type(temp) == "number" then
                  bsamount = temp
               end
            end
         end
      end
   end

   do -- Disease Tracker
      -- Create a DT Frame
      function DKROT:DTCreateFrame()
         frame = CreateFrame('StatusBar', nil, DKROT.DT)
         frame:SetHeight(24)
         frame:SetWidth(DKROT.DT:GetWidth()-2)
         frame:SetStatusBarTexture([[Interface\Tooltips\UI-Tooltip-Background]])
         frame:SetStatusBarColor(1, 0, 0);
         frame:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = -1, right = -1, top = -1, bottom = -1},}
         frame:SetBackdropColor(0, 0, 0, 0.5)

         frame.Name = frame:CreateFontString(nil, 'OVERLAY')
         frame.Name:SetPoint("LEFT", frame, 3, 0)
         frame.Name:SetFont(DKROT_NAMEFONT, 13, "OUTLINE")
         return frame
      end

      -- Gather the info and apply them to it's frame
      function DKROT:DTUpdateInfo(guid, info)
         if (not DKROT_Settings.DT.Target) and UnitGUID("target") == guid then return end

         -- Create Frame
         if info.Frame == nil then info.Frame = DKROT:DTCreateFrame() end
         info.Frame:SetAlpha(DKROT_Settings.DTTrans)

         -- Set Settings
         if info.spot == nil or info.spot ~= DKROT.DT.spot then
            info.spot = DKROT.DT.spot
            info.Frame:ClearAllPoints()
            if DKROT_Settings.DT.GrowDown then info.Frame:SetPoint("TOP", 0, -(DKROT.DT.spot*27)-1)
            else info.Frame:SetPoint("BOTTOM", 0, (DKROT.DT.spot*27)+1) end
         end

         -- Change Colour
         if DKROT_Settings.DT.TColours then
            if (UnitGUID("target") == guid) then info.Frame:SetBackdropColor(0.1, 0.75, 0.1, 0.9)
            elseif (UnitGUID("focus") == guid) then info.Frame:SetBackdropColor(0.2, 0.2, 0.75, 0.9)
            else info.Frame:SetBackdropColor(0, 0, 0, 0.5) end
         end

         -- Threat
         info.Frame:SetMinMaxValues(DKROT_Settings.DT.Threat, 100)
         if DKROT_Settings.DT.Threat ~= THREAT_OFF and info.Threat ~= nil then info.Frame:SetValue(info.Threat)
         else info.Frame:SetValue(0)   end

         -- Name
         local name = info.Name
         local color
         if DKROT_Settings.DT.CColours then color = RAID_CLASS_COLORS[select(2, GetPlayerInfoByGUID(guid))] end
         if color == nil then color = {}; color.r, color.g, color.b = 1, 1, 1; end
         name = (string.len(name) > 9 and string.gsub(name, '%s?(.)%S+%s', '%1. ') or name)
         info.Frame.Name:SetText(string.format("|cff%02x%02x%02x%.9s|r", color.r*255, color.g*255, color.b*255, name))

         -- Dots
         if info.Frame.Icons == nil or info.OldDots ~= info.NumDots then
            local count = 0
            local texture
            if info.Frame.Icons ~= nil then
               for j, v in pairs(info.Frame.Icons) do
                  info.Frame.Icons[j]:SetAlpha(0)
               end
               info.Frame.Icons = nil
            end
            info.Frame.Icons = {}
            info.OldDots = info.NumDots
            for j, v in pairs(info.Spells) do
               info.Frame.Icons[j] = DKROT:CreateIcon("DKROT.DT."..j, info.Frame, j, 20)
               info.Frame.Icons[j].Time:SetFont(font, 11, "OUTLINE")
               info.Frame.Icons[j]:SetPoint("RIGHT", -(count*22)-1, 0)
               info.Frame.Icons[j].Icon:SetTexture(GetSpellTexture(DKROT.DTspells[j][1]))
               count = count + 1
            end
         end

         -- Update Dots
         if info.Frame.Icons ~= nil and next(info.Spells) ~= nil then
            for j, v in pairs(info.Spells) do
               if v ~= nil and info.Frame.Icons[j]~= nil then
                  t = floor(v - curtime)
                  if t >= 0 then
                     info.Frame.Icons[j]:SetAlpha(1)
                     info.Frame.Icons[j].Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
                     if t > DKROT_Settings.DT.Warning then info.Frame.Icons[j].Time:SetText(formatTime(t))
                     else info.Frame.Icons[j].Time:SetText(format("|cffff2222%s|r",formatTime(t))) end
                  else
                     info.NumDots = info.NumDots - 1
                     info.Frame.Icons[j]:SetAlpha(0)
                     info.Spells[j] = nil
                  end
               else
                  info.NumDots = info.NumDots - 1
                  if info.Frame.Icons[j]~= nil then info.Frame.Icons[j]:SetAlpha(0) end
                  info.Spells[j] = nil
               end
            end
         else
            return
         end

         info.Updated = true
         DKROT.DT.spot = DKROT.DT.spot + 1
      end

      -- Update the frames
      function DKROT:DTUpdateFrames()
         local function updateGUIDFrame(guid)
            if DKROT.DT.Unit[guid] ~= nil then
               DKROT.DT.Unit[guid].Updated = false
               if DKROT.DT.spot < DKROT_Settings.DT.Numframes then DKROT:DTUpdateInfo(guid, DKROT.DT.Unit[guid]) end
               if DKROT.DT.Unit[guid].Updated == false and DKROT.DT.Unit[guid]~= nil and DKROT.DT.Unit[guid].Frame ~= nil then
                  DKROT.DT.Unit[guid].Frame:SetAlpha(0)
                  if next(DKROT.DT.Unit[guid].Spells) == nil then DKROT.DT.Unit[guid] = nil end
               end
            end
         end

         DKROT.DT.spot = 0

         local targetguid, focusguid

         if DKROT_Settings.DT.TPriority then
            targetguid, focusguid = UnitGUID("target"), UnitGUID("focus")
            updateGUIDFrame(targetguid)
            if targetguid ~= focusguid then updateGUIDFrame(focusguid) end
         end

         for k, v in pairs(DKROT.DT.Unit) do
            if k ~= targetguid and k ~= focusguid then updateGUIDFrame(k) end
         end
      end

      -- Update Threat and Dots from checking target infos
      local updatedGUIDs = {}
      function DKROT:DTCheckTargets()
         local function updateGUIDInfo(unit)
            local guid = UnitGUID(unit)
            if guid ~= nil and updatedGUIDs[guid] == nil then
               if UnitIsDead(unit) and DKROT.DT.Unit[guid] ~= nil and DKROT.DT.Unit[guid].Frame ~= nil then
                  DKROT.DT.Unit[guid].Frame:SetAlpha(0)
                  DKROT.DT.Unit[guid].Frame = nil
                  DKROT.DT.Unit[guid] = nil
               end

               if select(1, UnitDebuff(unit, 1, "PLAYER")) ~= nil then
                  local name, expt
                  for j= 1, 10 do
                     name, _, _, _, _, _, expt = UnitDebuff(unit, j, "PLAYER")
                     if name == nil then break end
                     if DKROT_Settings.DT.Dots[name] then
                        if DKROT.DT.Unit[guid] == nil then
                           local targetName = UnitName(unit)
                           DKROT.DT.Unit[guid] = {}
                           DKROT.DT.Unit[guid].Spells = {}
                           DKROT.DT.Unit[guid].NumDots = 0
                           DKROT.DT.Unit[guid].Name = select(3, string.find(targetName, "(.-)-")) or targetName
                        end

                        updatedGUIDs[guid] = true

                        if DKROT.DT.Unit[guid].Spells[name] == nil then
                           DKROT.DT.Unit[guid].NumDots = DKROT.DT.Unit[guid].NumDots + 1
                        end
                        if name == DKROT.spells["Death and Decay"] then
                           DKROT.DT.Unit[guid].Spells[name] = select(1, GetSpellCooldown(name)) + 10
                        else
                           DKROT.DT.Unit[guid].Spells[name] = expt
                        end

                        if DKROT_Settings.DT.Threat ~= THREAT_OFF then
                           DKROT.DT.Unit[guid].Threat = select(3, UnitDetailedThreatSituation("player", unit))
                           if DKROT_Settings.DT.Threat == THREAT_HEALTH then
                              DKROT.DT.Unit[guid].Threat = (UnitHealth(unit)/UnitHealthMax(unit))*100
                           end
                        end
                     end
                  end
               end
            end
         end

         updatedGUIDs = {}
         updateGUIDInfo("target")
         updateGUIDInfo("focus")
         updateGUIDInfo("pettarget")
         for i = 1, MAX_BOSS_FRAMES do updateGUIDInfo("boss"..i)   end
      end
   end

   -- Priority System
   do
      -- Called to update a priority icon with next move
      function DKROT:GetNextMove(icon)
         -- Call correct function based on spec
         if DKROT_Settings.MoveAltAOE then
            if (DKROT.Current_Spec == DKROT.SPECS.UNHOLY) then
               DKROT.Move.AOE:SetAlpha(1)
               DKROT.Move.AOE.Icon:SetTexture(DKROT:UnholyAOEMove(DKROT.Move.AOE.Icon))

            elseif (DKROT.Current_Spec == DKROT.SPECS.FROST) then
               DKROT.Move.AOE:SetAlpha(1)
               DKROT.Move.AOE.Icon:SetTexture(DKROT:FrostAOEMove(DKROT.Move.AOE.Icon))

            elseif (DKROT.Current_Spec == DKROT.SPECS.BLOOD) then
               DKROT.Move.AOE:SetAlpha(1)
               DKROT.Move.AOE.Icon:SetTexture(DKROT:BloodAOEMove(DKROT.Move.AOE.Icon))
            end
         end

         -- return DKROT.Rotations[DKROT.Current_Spec][DKROT_Settings.CD[DKROT.Current_Spec].Rotation].func(icon)
         local nextCast, noCheckRange = DKROT.Rotations[DKROT.Current_Spec][DKROT_Settings.CD[DKROT.Current_Spec].Rotation].func()
         if noCheckRange ~= nil and noCheckRange == true then
            return GetSpellTexture(nextCast)
         else
            return DKROT:GetRangeandIcon(icon, nextCast)
         end
      end

      -- Determines if player is in range with spell and sets colour and icon accordingly
      -- In: icon: icon in which to change the vertex colour of   move: spellID of spell to be cast next
      -- Out: returns the texture of the icon (probably unessesary since icon is now being passed in, will look into it more)
      function DKROT:GetRangeandIcon(icon, move)
         if move ~= nil then
            if DKROT_Settings.Range and IsSpellInRange(move, "target") == 0 then
               icon:SetVertexColor(0.8, 0.05, 0.05, 1)
            else
               icon:SetVertexColor(1, 1, 1, 1)
            end
            return GetSpellTexture(move)
         end

         return nil
      end

      -- Gives CD of rune type specified
      -- In: r: type of rune set to be queried
      -- Out:  time1: the lowest cd of the 2 runes being queried  time2: the higher of the cds  RT1: returns true if lowest cd rune is a death rune, RT2: same as RT1 except higher CD rune
      function DKROT:RuneCDs(r)
         -- Get individual rune numbers
         local a, b
         if r == DKROT.SPECS.UNHOLY then a, b = 3, 4
         elseif r == DKROT.SPECS.FROST then a, b = 5, 6
         elseif r == DKROT.SPECS.BLOOD then a, b = 1, 2
         end

         -- Get CD of first rune
         local start, dur, cool = GetRuneCooldown(a)
         time1 = (cool and 0) or (dur - (curtime - start + GCD))

         -- Get CD of second rune
         local start, dur, cool = GetRuneCooldown(b)
         time2 = (cool and 0) or (dur - (curtime - start + GCD))

         -- if second rune will be off CD before first, then return second then first rune, else vice versa
         if time1 > time2 then
            return time2, time1, GetRuneType(b) == 4, GetRuneType(a) == 4
         else
            return time1, time2, GetRuneType(a) == 4, GetRuneType(b) == 4
         end
      end

      -- Returns the number of available runes of a specific type
      -- in: runeType: The type of rune to fetch information for, allowDeathRunes: Whether or not to count deathrunes
      -- out: availableRunes: number of available runes
      function DKROT:RuneIsAvailable(runeType, allowDeathRunes)
         allowDeathRunes = allowDeathRunes or false

         local availableRunes = 0
         for i = 1,6 do
            local rt = GetRuneType(i)
            if rt == runeType or (allowDeathRunes == true and rt == 4) then
               availableRunes = availableRunes + 1
            end
         end

         return availableRunes
      end

      -- Returns the total number of Death runes off CD
      function DKROT:DeathRunes()
         local count = 0
         local start, dur, cool
         for i = 1, 6 do
            if GetRuneType(i) == 4 then
               if isRuneOffCD(i) then
                  count = count + 1
               end
            end
         end
         return count
      end

      -- Returns the number of depleted runes (runes on CD)
      function DKROT:DepletedRunes()
         local count = 6
         for i = 1, 6 do
            if isRuneOffCD(i) then
               count = count - 1
            end
         end
         return count
      end

      function DKROT:HasFullyDepletedRunes()
         if isRuneOffCD(1) ~= true and isRuneOffCD(2) ~= true then
            return true
         elseif isRuneOffCD(3) ~= true and isRuneOffCD(4) ~= true then
            return true
         elseif isRuneOffCD(5) ~= true and isRuneOffCD(6) ~= true then
            return true
         end

         return false
      end

      -- Returns if move is off cooldown or not
      function DKROT:QuickAOESpellCheck(move)
         if DKROT_Settings.MoveAltAOE and GetSpellTexture(move) ~= nil then
            if DKROT:isOffCD(move) then
               return true
            end
         end
         return false
      end

      function DKROT:GetDiseaseTime()
         local ff, bp

         local expires = select(7,UnitDebuff("TARGET", DKROT.spells["Frost Fever"], nil, "PLAYER"))
         if expires ~= nil then
            ff = expires - curtime
         end

         expires = select(7,UnitDebuff("TARGET", DKROT.spells["Blood Plague"], nil, "PLAYER"))
         if expires ~= nil then
            bp = expires - curtime
         end

         expires = select(7, UnitDebuff("TARGET", DKROT.spells["Necrotic Plague"], nil, "PLAYER"))
         if expires ~= nil then
            local np = expires - curtime
            ff = np
            bp = np
         end

         return ff, bp
      end

      -- Determines if Diseases need to be refreshed or applied
      function DKROT:GetDisease()
         -- If settings not to worry about diseases, then break
         if DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption == DISEASE_NONE then
            return nil
         end

         -- Get Duration left on diseases
         local FFexpires, BPexpires, NPexpires
         local expires = select(7,UnitDebuff("TARGET", DKROT.spells["Frost Fever"], nil, "PLAYER"))
         if expires ~= nil then
            FFexpires = expires - curtime
         end

         expires = select(7,UnitDebuff("TARGET", DKROT.spells["Blood Plague"], nil, "PLAYER"))
         if expires ~= nil then
            BPexpires = expires - curtime
         end

         expires = select(7, UnitDebuff("TARGET", DKROT.spells["Necrotic Plague"], nil, "PLAYER"))
         if expires ~= nil then
            NPexpires = expires - curtime
         end

         -- Check if Outbreak is off CD, is known and Player wants to use it in rotation
         local outbreak = DKROT_Settings.CD[DKROT.Current_Spec].Outbreak and
            IsSpellKnown(77575) and
            DKROT:isOffCD(DKROT.spells["Outbreak"])

         -- Check if Unholy Blight is up, is known and Player wants to use it in rotation
         local unholyblight = DKROT_Settings.CD[DKROT.Current_Spec].UB and
            IsSpellKnown(115989) and
            DKROT:isOffCD(DKROT.spells["Unholy Blight"])

         -- Check if Plague Leech is up, is known and Player wants to use it in rotation
         local plagueleech = DKROT_Settings.CD[DKROT.Current_Spec].PL and
            IsSpellKnown(123693) and
            DKROT:isOffCD(DKROT.spells["Plague Leech"])


         -- Apply Frost Fever
         if (FFexpires == nil or FFexpires < 2) and NPexpires == nil then
            if outbreak then -- if can use outbreak, then do it
               return DKROT.spells["Outbreak"]

            elseif unholyblight then -- if can use Unholy Blight, then do it
               return DKROT.spells["Unholy Blight"]

            elseif (DKROT.Current_Spec == DKROT.SPECS.UNHOLY) and ((DKROT:RuneCDs(DKROT.SPECS.UNHOLY) <= 0) or DKROT:DeathRunes() >= 1) then -- Unholy: Plague Strike
               return DKROT.spells["Plague Strike"]

            elseif (DKROT.Current_Spec == DKROT.SPECS.FROST) and ((DKROT:RuneCDs(DKROT.SPECS.FROST) <= 0) or DKROT:DeathRunes() >= 1) then -- Frost: Howling Blast
               return DKROT.spells["Howling Blast"]
               
            elseif ((DKROT:RuneCDs(DKROT.SPECS.FROST) <= 0) or DKROT:DeathRunes() >= 1) then -- Other: Icy Touch
               return DKROT.spells["Icy Touch"]
            end
         end

         -- Apply Blood Plague
         if (DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption ~= DISEASE_ONE or outbreak) then
            if (BPexpires == nil or BPexpires < 3) then
               -- Necrotic plague acts as both frost fever and blood plague
               if NPexpires ~= nil and NPexpires > 3 then
                  return nil
               end

               -- Add Death Grip as first priority until PS is in range
               if DKROT_Settings.DG and (IsSpellInRange(DKROT.spells["Plague Strike"], "target")) == 0 and IsUsableSpell(DKROT.spells["Death Grip"]) then
                  return DKROT.spells["Death Grip"]
               end

               if plagueleech and (BPexpires ~= nil or NPexpires ~= nil) and DKROT:DepletedRunes() > 0 then
                  return DKROT.spells["Plague Leech"]

               elseif outbreak then -- if can use outbreak, then do it
                  return DKROT.spells["Outbreak"]

               elseif unholyblight then -- if can use Unholy Blight, then do it
                  return DKROT.spells["Unholy Blight"]

               elseif ((DKROT:RuneCDs(DKROT.SPECS.UNHOLY) <= 0) or DKROT:DeathRunes() >= 1) then -- if rune availible, then use Plague Strike
                  return DKROT.spells["Plague Strike"]
               end
            end
         end

         return nil
      end


      -- Function to determine AOE rotation for Unholy Spec
      function DKROT:UnholyAOEMove(icon)
         -- Diseases > Dark Transformation > Death and Decay > SS if both Unholy and/or all Death runes are up >
         -- BB + IT if both pairs of Blood and Frost runes are up >   DC
         -- > SS > BB + IT

         -- Rune Info
         local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood, bd, lbd = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()

         -- AOE:Death and Decay
         if DKROT:QuickAOESpellCheck(DKROT.spells["Death and Decay"]) and (unholy <= 0 or death >= 1) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Death and Decay"])
         end

         -- AOE:Blood Boil
         if DKROT:QuickAOESpellCheck(DKROT.spells["Blood Boil"]) and (blood <= 0 or death >= 1) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Blood Boil"])
         end

         -- Scourge Strike
         if (lunholy <= 0) then
            return DKROT:GetRangeandIcon(icon, nil)
         end

         -- AOE:Death Coil
         if DKROT_Settings.CD[DKROT.Current_Spec].RP
         and (UnitPower("player") >= 40
            or select(7, UnitBuff("PLAYER",DKROT.spells["Sudden Doom"])) ~= nil) then
            return DKROT:GetRangeandIcon(icon, nil)
         end

         return nil
      end

      -- Function to determine AOE rotation for Frost Spec
      function DKROT:FrostAOEMove(icon)

         -- Rune Info
         local frost, lfrost, fd, lfd = DKROT:RuneCDs(DKROT.SPECS.FROST)
         local unholy, lunholy, ud, lud = DKROT:RuneCDs(DKROT.SPECS.UNHOLY)
         local blood, lblood = DKROT:RuneCDs(DKROT.SPECS.BLOOD)
         local death = DKROT:DeathRunes()

         -- AOE:Howling Blast if both Frost runes and/or both Death runes are up
         if DKROT:QuickAOESpellCheck(DKROT.spells["Howling Blast"]) and ((lfrost <= 0) or (lblood <= 0) or (lunholy <= 0 and lud)) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Howling Blast"])
         end

         -- AOE:DnD if both Unholy Runes are up
         if DKROT:QuickAOESpellCheck(DKROT.spells["Death and Decay"]) and (lunholy <= 0) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Death and Decay"])
         end

         -- AOE:Frost Strike if RP capped
         if DKROT:QuickAOESpellCheck(DKROT.spells["Frost Strike"]) and (UnitPower("player") > 88) then
            return DKROT:GetRangeandIcon(icon, nil)
         end

         -- AOE:Howling Blast
         if DKROT:QuickAOESpellCheck(DKROT.spells["Howling Blast"]) and (frost <= 0 or death >= 1) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Howling Blast"])
         end

         -- AOE:DnD
         if DKROT:QuickAOESpellCheck(DKROT.spells["Death and Decay"]) and (unholy <= 0) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Death and Decay"])
         end

         -- AOE:Frost Strike
         if DKROT:QuickAOESpellCheck(DKROT.spells["Frost Strike"]) and UnitPower("player") >= 20 then
            return DKROT:GetRangeandIcon(icon, nil)
         end

         -- AOE:PS
         if DKROT:QuickAOESpellCheck(DKROT.spells["Plague Strike"]) and (unholy <= 0) then
            return DKROT:GetRangeandIcon(icon, DKROT.spells["Plague Strike"])
         end

         return nil
      end

      -- Function to determine AOE rotation for Blood Spec
      function DKROT:BloodAOEMove(icon)
         return nil
      end

   end

   -- Function to check spec and presence
   function DKROT:CheckSpec()
      -- Set all settings to default
      DKROT.Current_Spec = DKROT.SPECS.UNKNOWN
      if GetSpecialization() == 1 then DKROT.Current_Spec = DKROT.SPECS.BLOOD
      elseif GetSpecialization() == 2 then DKROT.Current_Spec = DKROT.SPECS.FROST
      elseif GetSpecialization() == 3 then DKROT.Current_Spec = DKROT.SPECS.UNHOLY
      end

      -- Presence
      PLAYER_PRESENCE = 0
      for i = 1, GetNumShapeshiftForms() do
         local icon, _, active = GetShapeshiftFormInfo(i)
         if active then
            PLAYER_PRESENCE = i
         end
      end

      DKROT:Debug("Check Spec - " .. DKROT.Current_Spec)
      DKROT:OptionsRefresh()
   end

   local delayedInit = false
   function DKROT:Initialize()
      DKROT:Debug("Initialize")
      if InCombatLockdown() then
         if delayedInit == false then
            delayedInit = true
            DKROT:Log("Delaying initialization due to combat lockdown")
         end

         return
      end
      mutex = true

      DKROT:LoadSpells()
      DKROT:LoadCooldowns()

      if not DKROT:LoadTrinkets() and (curtime - launchtime < ITEM_LOAD_THRESHOLD) then
         DKROT:Debug("Initialize Failed")
         mutex = false
         return
      end

      if (curtime - launchtime >= ITEM_LOAD_THRESHOLD) then
         DKROT:Debug("Launch Threshold Met")
      end

      if DKROT.debug then
         DKROT:Debug("~~Spell Difference Start~~")
         for k, v in pairs(DKROT.spells) do
            if v == nil or k ~= v then
               DKROT:Debug(k.." =/= ".. v)
            end
         end
         DKROT:Debug("~~Spell Difference End~~")
      end

      -- DKROT:SetDefaults()
      -- Check Settings
      DKROT:CheckSettings()
      DKROT:Debug("Initialize - Version " .. DKROT_Settings.Version)

      if DKROT_Settings.DT.Combat or not DKROT_Settings.DT.Enable then
         DKROT.MainFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
      else
         DKROT.MainFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
      end

      DKROT.MainFrame:SetAlpha(0)
      DKROT:CreateCDs()
      DKROT:CreateUI()

      -- Setup Button Facade if enabled
      if LBF then
         LBF:Group("DKROT"):Skin(unpack(DKROT_Settings.lbf))
         LBF:Group("DKROT"):AddButton(DKROT.Diseases.FF)
         LBF:Group("DKROT"):AddButton(DKROT.Diseases.BP)
         LBF:Group("DKROT"):AddButton(DKROT.Move)
         LBF:Group("DKROT"):AddButton(DKROT.Move.AOE)
         LBF:Group("DKROT"):AddButton(DKROT.Move.Interrupt)
         for i = 1, #CDDisplayList do
            LBF:Group("DKROT"):AddButton(DKROT.CD[CDDisplayList[i]])
         end
         LBF:RegisterSkinCallback('DKROT', self.OnSkin, self)
      end

      -- Setup Masque if enabled
      if MSQ then
         local mgrp = MSQ:Group("DKROT", "DKRot")
         mgrp:AddButton(DKROT.Diseases.FF)
         mgrp:AddButton(DKROT.Diseases.BP)
         mgrp:AddButton(DKROT.Move)
         mgrp:AddButton(DKROT.Move.AOE)
         mgrp:AddButton(DKROT.Move.Interrupt)
         for i = 1, #CDDisplayList do
            mgrp:AddButton(DKROT.CD[CDDisplayList[i]])
         end
      end
      
      local PosPanel = DKROT:SetupPositionPanel(function() DKROT:PositionUpdate() end)

      InterfaceOptions_AddCategory(DKROT_Options)
      InterfaceOptions_AddCategory(DKROT_FramePanel)
      InterfaceOptions_AddCategory(DKROT_CDRPanel)
      InterfaceOptions_AddCategory(DKROT_CDPanel)
      InterfaceOptions_AddCategory(DKROT_DTPanel)
      InterfaceOptions_AddCategory(DKROT_PositionPanel)
      -- InterfaceOptions_AddCategory(PosPanel)
      InterfaceOptions_AddCategory(DKROT_ABOUTPanel)

      DKROT_CDRPanel_DG_Text:SetText(DKROT.spells["Death Grip"])
      DKROT:CheckSpec()

      -- Initialize all dropdowns
      UIDropDownMenu_Initialize(DKROT_FramePanel_Rune_DD, DKROT_Rune_DD_OnLoad)
      UIDropDownMenu_Initialize(DKROT_CDRPanel_Diseases_DD, DKROT_Diseases_OnLoad)
      UIDropDownMenu_Initialize(DKROT_CDRPanel_DD_Priority, DKROT_CDRPanel_DD_OnLoad)
      UIDropDownMenu_Initialize(DKROT_CDRPanel_Rotation, DKROT_Rotations_OnLoad)
      for i = 1, #CDDisplayList do
         UIDropDownMenu_Initialize(_G[CDDisplayList[i]], DKROT_CDRPanel_DD_OnLoad)
      end
      UIDropDownMenu_Initialize(DKROT_FramePanel_ViewDD, DKROT_FramePanel_ViewDD_OnLoad)
      UIDropDownMenu_Initialize(DKROT_DTPanel_DD_Threat, DKROT_DTPanel_Threat_OnLoad)
      DKROT:Debug("Initialize - Dropdowns Done")

      mutex = nil
      loaded = true

      collectgarbage()
   end

   DKROT:Debug("Functions Done")

   -- --- Events-- ---
   -- Register Events
   DKROT.MainFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
   DKROT.MainFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
   DKROT.MainFrame:RegisterEvent("ADDON_LOADED")
   -- DKROT:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
   -- DKROT:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

   -- Function to be called when events triggered
   local slottimer = 0
   DKROT.MainFrame:SetScript("OnEvent", function(_, e, ...)
      if e == "ADDON_LOADED" then
         local addonName = ...
         if addonName == "DKRot" then
            DKROT.MainFrame:UnregisterEvent("ADDON_LOADED")
            if DKROT_Settings ~= nil and DKROT_Settings.UpdateWarning ~= true then
               StaticPopup_Show("DKROT_UPDATE_WARNING")
               DKROT_Settings.UpdateWarning = true
            end
         end
      end

      -- Delayed addon initialization due to combat lockdown
      if loaded then
         if e == "COMBAT_LOG_EVENT_UNFILTERED" then
            local _, event, _, _, casterName, _, _,targetguid, targetName, _, _, _, spellName = ...
            if (event == "UNIT_DIED" or event == "UNIT_DESTROYED") and DKROT.DT.Unit[targetguid] ~= nil then
               if DKROT.DT.Unit[targetguid].Frame ~= nil then
                  DKROT.DT.Unit[targetguid].Frame:SetAlpha(0)
                  DKROT.DT.Unit[targetguid].Frame = nil
               end
               DKROT.DT.Unit[targetguid] = nil
            end

            if (casterName == PLAYER_NAME) and DKROT_Settings.DT.Dots[spellName] and targetName ~= PLAYER_NAME then
               curtime = GetTime()
               if (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
                  if DKROT.DT.Unit[targetguid] == nil then
                     DKROT.DT.Unit[targetguid] = {}
                     DKROT.DT.Unit[targetguid].Spells = {}
                     DKROT.DT.Unit[targetguid].NumDots = 0
                     DKROT.DT.Unit[targetguid].Name = select(3, string.find(targetName, "(.-)-")) or targetName
                  end

                  if DKROT.DT.Unit[targetguid].Spells[spellName] == nil then
                     DKROT.DT.Unit[targetguid].NumDots = DKROT.DT.Unit[targetguid].NumDots + 1
                  end

                  if spellName == DKROT.spells["Death and Decay"] then
                     DKROT.DT.Unit[targetguid].Spells[spellName] = select(1, GetSpellCooldown(spellName)) + 10
                  else
                     DKROT.DT.Unit[targetguid].Spells[spellName] = DKROT.DTspells[spellName][2] + curtime
                  end

               elseif (event == "SPELL_AURA_REMOVED") then
                  if DKROT.DT.Unit[targetguid] ~= nil and  DKROT.DT.Unit[targetguid][spellName] ~= nil then
                      DKROT.DT.Unit[targetguid].Spells[spellName] = nil
                      DKROT.DT.Unit[targetguid].NumDots = DKROT.DT.Unit[targetguid].NumDots - 1
                  end
               end
            end
         else
            DKROT:CheckSpec()
         end
      end
   end)

   -- Main function to run addon
   local DTupdatetimer = 0
   local DTchecktimer = 0
   local scheduledInit = false
   DKROT.MainFrame:SetScript("OnUpdate", function()
      curtime = GetTime()
      -- Make sure it only updates at max, once every 0.15 sec
      if (curtime - updatetimer >= 0.08) then
         updatetimer = curtime

         if (not loaded) and (not mutex) then
            if launchtime == 0 then launchtime = curtime;DKROT:Debug("Launchtime Set") end
            DKROT:Initialize()
         elseif loaded then
            -- Check if visibility conditions are met, if so update the information in the addon
            if not UnitHasVehicleUI("player") 
               and (
                  (InCombatLockdown() and DKROT_Settings.VScheme == DKROT_OPTIONS_FRAME_VIEW_NORM)
                  or (DKROT_Settings.VScheme == DKROT_OPTIONS_FRAME_VIEW_SHOW)
                  or not DKROT_Settings.Locked
                  or (
                     DKROT_Settings.VScheme ~= DKROT_OPTIONS_FRAME_VIEW_HIDE 
                     and UnitCanAttack("player", "target") 
                     and not UnitIsDead("target")
                  )
               )
            then
               DKROT:UpdateUI()
            else
               DKROT.MainFrame:SetAlpha(0)
            end

            if resize ~= nil then
               x, y = GetCursorPosition()
               sizex = (x - mousex + resize:GetWidth())/resize:GetWidth()
               sizey = (mousey - y + resize:GetHeight())/resize:GetHeight()
               if sizex < sizey then
                  if sizex > 1 then
                     resize:SetScale(sizex)
                  end
               else
                  if sizey > 1 then
                     resize:SetScale(sizey)
                  end
               end
            end
         end
      end
      if loaded and DKROT_Settings.DT.Enable then
         if (curtime - DTchecktimer >= DKROT_Settings.DT.Update) then
            DTchecktimer = curtime
            DKROT:DTCheckTargets()
         end
         if (curtime - DTupdatetimer >= 0.5) then
            DTupdatetimer = curtime
            DKROT:DTUpdateFrames()
         end
      end
   end)

   -- --- Options-- ---
   -- Setup slash command
   SLASH_DKROT1 = '/dkrot'
   SlashCmdList["DKROT"] = function()
      InterfaceOptionsFrame_OpenToCategory(DKROT_FramePanel)
      InterfaceOptionsFrame_OpenToCategory(DKROT_FramePanel)
      DKROT:Debug("Slash Command Used")
   end

   -- Update the Blizzard interface Options with settings
   function DKROT:OptionsRefresh()
      if DKROT_Settings ~= nil and DKROT_Settings.Version ~= nil and DKROT_Settings.Version == DKROT_VERSION then
         -- Frame
         DKROT_FramePanel_GCD:SetChecked(DKROT_Settings.GCD)
         DKROT_FramePanel_CDS:SetChecked(DKROT_Settings.CDS)
         DKROT_FramePanel_CDEDGE:SetChecked(DKROT_Settings.CDEDGE)
         DKROT_FramePanel_Range:SetChecked(DKROT_Settings.Range)
         DKROT_FramePanel_Rune:SetChecked(DKROT_Settings.Rune)
         DKROT_FramePanel_RuneBars:SetChecked(DKROT_Settings.RuneBars)
         DKROT_FramePanel_RP:SetChecked(DKROT_Settings.RP)
         DKROT_FramePanel_Disease:SetChecked(DKROT_Settings.Disease)
         DKROT_FramePanel_Locked:SetChecked(DKROT_Settings.Locked)
         DKROT_FramePanel_Trans:SetNumber(DKROT_Settings.Trans)
         DKROT_FramePanel_Trans:SetCursorPosition(0)
         DKROT_FramePanel_CombatTrans:SetNumber(DKROT_Settings.CombatTrans)
         DKROT_FramePanel_CombatTrans:SetCursorPosition(0)
         DKROT_FramePanel_NormalTrans:SetNumber(DKROT_Settings.NormTrans)
         DKROT_FramePanel_NormalTrans:SetCursorPosition(0)

         -- View Dropdown
         UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme)
         UIDropDownMenu_SetText(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme)

         UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder)
         UIDropDownMenu_SetText(DKROT_FramePanel_Rune_DD, DKROT_OPTIONS_FRAME_RUNE_ORDER[DKROT_Settings.RuneOrder])


         -- CD/R
         DKROT_CDRPanel_Outbreak_Text:SetText(DKROT.spells["Outbreak"])
         DKROT_CDRPanel_UB_Text:SetText(DKROT.spells["Unholy Blight"])
         DKROT_CDRPanel_PL_Text:SetText(DKROT.spells["Plague Leech"])
         DKROT_CDRPanel_ERW_Text:SetText(DKROT.spells["Empower Rune Weapon"])
         DKROT_CDRPanel_BT_Text:SetText(DKROT.spells["Blood Tap"])
         DKROT_CDRPanel_DP_Text:SetText(DKROT.spells["Death Pact"])
         if (DKROT.Current_Spec == DKROT.SPECS.UNHOLY) then
            DKROT_CDRPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_UNHOLY)
            DKROT_CDPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_UNHOLY)
         elseif (DKROT.Current_Spec == DKROT.SPECS.FROST) then
            DKROT_CDRPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_FROST)
            DKROT_CDPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_FROST)
         elseif (DKROT.Current_Spec == DKROT.SPECS.BLOOD) then
            DKROT_CDRPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_BLOOD)
            DKROT_CDPanel_Title_Spec:SetText(DKROT_OPTIONS_SPEC_BLOOD)
         else
            DKROT_CDRPanel_Title_Spec:SetText(DKROT_OPTIONS_DKROT_SPEC_None)
            DKROT_CDPanel_Title_Spec:SetText(DKROT_OPTIONS_DKROT_SPEC_None)
         end

         -- Disease Dropdown
         UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Diseases_DD, DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption)

         local text
         if DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption == DISEASE_BOTH then
            text = DKROT_OPTIONS_CDR_DISEASES_DD_BOTH
         elseif DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption == DISEASE_ONE then
            text = DKROT_OPTIONS_CDR_DISEASES_DD_ONE
         else
            text = DKROT_OPTIONS_CDR_DISEASES_DD_NONE
         end
         UIDropDownMenu_SetText(DKROT_CDRPanel_Diseases_DD, text)

         -- Rotation
         local current_rotation = DKROT_Settings.CD[DKROT.Current_Spec].Rotation
         if current_rotation == nil then
            if DKROT.Current_Spec ~= DKROT.SPECS.UNKNOWN then
               for rotName, rotInfo in pairs(DKROT.Rotations[DKROT.Current_Spec]) do
                  if rotInfo.default == true then
                     current_rotation = rotName
                     break
                  end
               end
               UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Rotation, current_rotation)
               UIDropDownMenu_SetText(DKROT_CDRPanel_Rotation, DKROT.Rotations[DKROT.Current_Spec][current_rotation].name)
            end
         end

         DKROT_CDRPanel_Outbreak:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].Outbreak)
         DKROT_CDRPanel_UB:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].UB)
         DKROT_CDRPanel_PL:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].PL)
         DKROT_CDRPanel_ERW:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].ERW)
         DKROT_CDRPanel_BT:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].BT)
         DKROT_CDRPanel_DP:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].DP)
         DKROT_CDRPanel_IRP:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].RP)
         DKROT_CDRPanel_MoveAltInterrupt:SetChecked(DKROT_Settings.MoveAltInterrupt)
         DKROT_CDRPanel_MoveAltAOE:SetChecked(DKROT_Settings.MoveAltAOE)
         DKROT_CDRPanel_MoveAltDND:SetChecked(DKROT_Settings.MoveAltDND)
         DKROT_CDRPanel_UseHoW:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec].UseHoW)
         DKROT_CDRPanel_DG:SetChecked(DKROT_Settings.DG)
         DKROT_CDRPanel_DD_CD1:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec][1])
         DKROT_CDRPanel_DD_CD2:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec][2])
         DKROT_CDRPanel_DD_CD3:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec][3])
         DKROT_CDRPanel_DD_CD4:SetChecked(DKROT_Settings.CD[DKROT.Current_Spec][4])

         -- Priority Dropdown
         if DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"] ~= nil and DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][1] ~= nil then
            UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_DD_Priority, DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][1]..((DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][IS_BUFF] and " (Buff)") or ""))
            UIDropDownMenu_SetText(DKROT_CDRPanel_DD_Priority, DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][1]..((DKROT_Settings.CD[DKROT.Current_Spec]["DKROT_CDRPanel_DD_Priority"][IS_BUFF] and " (Buff)") or ""))
         end

         -- Cooldown Dropdown
         for i = 1, #CDDisplayList do
            if _G[CDDisplayList[i]] ~= nil and DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]] ~= nil and DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]][1] ~= nil then
               UIDropDownMenu_SetSelectedValue(_G[CDDisplayList[i]], DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]][1]..((DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]][IS_BUFF] and " (Buff)") or ""))
               UIDropDownMenu_SetText(_G[CDDisplayList[i]], DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]][1]..((DKROT_Settings.CD[DKROT.Current_Spec][CDDisplayList[i]][IS_BUFF] and " (Buff)") or ""))
            end
         end

         -- Disease Tracker
         DKROT_DTPanel_Enable:SetChecked(DKROT_Settings.DT.Enable)
         DKROT_DTPanel_CColours:SetChecked(DKROT_Settings.DT.CColours)
         DKROT_DTPanel_TColours:SetChecked(DKROT_Settings.DT.TColours)
         DKROT_DTPanel_Target:SetChecked(DKROT_Settings.DT.Target)
         DKROT_DTPanel_TPriority:SetChecked(DKROT_Settings.DT.TPriority)
         DKROT_DTPanel_GrowDown:SetChecked(DKROT_Settings.DT.GrowDown)
         DKROT_DTPanel_CombatLog:SetChecked(DKROT_Settings.DT.Combat)
         DKROT_DTPanel_Update:SetNumber(DKROT_Settings.DT.Update)
         DKROT_DTPanel_Update:SetCursorPosition(0)
         DKROT_DTPanel_NumFrames:SetNumber(DKROT_Settings.DT.Numframes)
         DKROT_DTPanel_NumFrames:SetCursorPosition(0)
         DKROT_DTPanel_Warning:SetNumber(DKROT_Settings.DT.Warning)
         DKROT_DTPanel_Warning:SetCursorPosition(0)
         DKROT_DTPanel_Trans:SetNumber(DKROT_Settings.DTTrans)
         DKROT_DTPanel_Trans:SetCursorPosition(0)
         UIDropDownMenu_SetSelectedValue(DKROT_DTPanel_DD_Threat, DKROT_Settings.DT.Threat)
         if DKROT_Settings.DT.Threat == THREAT_OFF then text = DKROT_OPTIONS_DT_THREAT_OFF
         elseif DKROT_Settings.DT.Threat == THREAT_HEALTH then text = DKROT_OPTIONS_DT_THREAT_HEALTH
         elseif DKROT_Settings.DT.Threat == THREAT_ANALOG then text = DKROT_OPTIONS_DT_THREAT_ANALOG
         elseif DKROT_Settings.DT.Threat == THREAT_DIGITAL then text = DKROT_OPTIONS_DT_THREAT_DIGITAL
         end
         UIDropDownMenu_SetText(DKROT_DTPanel_DD_Threat, text)

         DKROT_DTPanel_DOTS_FF_Text:SetText(DKROT.spells["Frost Fever"])
         DKROT_DTPanel_DOTS_FF:SetChecked(DKROT_Settings.DT.Dots[DKROT.spells["Frost Fever"]])
         DKROT_DTPanel_DOTS_BP_Text:SetText(DKROT.spells["Blood Plague"])
         DKROT_DTPanel_DOTS_BP:SetChecked(DKROT_Settings.DT.Dots[DKROT.spells["Blood Plague"]])
         DKROT_DTPanel_DOTS_DD_Text:SetText(DKROT.spells["Death and Decay"])
         DKROT_DTPanel_DOTS_DD:SetChecked(DKROT_Settings.DT.Dots[DKROT.spells["Death and Decay"]])
         DKROT_DTPanel_DOTS_DF_Text:SetText(DKROT.spells["Defile"])
         DKROT_DTPanel_DOTS_DF:SetChecked(DKROT_Settings.DT.Dots[DKROT.spells["Defile"]])
         DKROT_DTPanel_DOTS_NP_Text:SetText(DKROT.spells["Necrotic Plague"])
         DKROT_DTPanel_DOTS_NP:SetChecked(DKROT_Settings.DT.Dots[DKROT.spells["Necrotic Plague"]])

         -- About Options
         local expText = "<html><body>"
               .."<p>"..DKROT_ABOUT_BODY.."</p>"
               .."<p><br/>"
               .."|cffaaaaaa"..DKROT_ABOUT_GER.."<br/>"
               .."|cffaaaaaa"..DKROT_ABOUT_BR.."<br/>"
               .."|cffaaaaaa"..DKROT_ABOUT_CT.."<br/>"
               .."|cffaaaaaa"..DKROT_ABOUT_CC.."<br/>"
               .."</p>"
               .."</body></html>";
         DKROT_ABOUTHTML:SetText (expText);
         DKROT_ABOUTHTML:SetSpacing (2);

         DKROT:Debug("OptionsRefresh")
         DKROT:UpdatePosition()

         if DKROT.LockDialog == true and DKROT_Settings.Locked == true then
            StaticPopup_Hide("DKROT_FRAME_UNLOCKED")
            DKROT.LockDialog = false
         end
      else
         DKROT:Debug("ERROR OptionsRefresh - " .. (DKROT_Settings == nil and "Settings are nil") or (DKROT_Settings.Version == nil and "Version is nil") or ("Invalid Version" .. DKROT_Settings.Version))
      end
   end

   -- Check if options are valid and save them to settings if so
   function DKROT_OptionsOkay()
      if DKROT_Settings ~= nil and (DKROT_Settings.Version ~= nil and DKROT_Settings.Version == DKROT_VERSION) then
         -- Frame
         DKROT_Settings.GCD = DKROT_FramePanel_GCD:GetChecked()
         DKROT_Settings.CDEDGE = DKROT_FramePanel_CDEDGE:GetChecked()
         DKROT_Settings.CDS = DKROT_FramePanel_CDS:GetChecked()
         DKROT_Settings.CDEDGE = DKROT_FramePanel_CDEDGE:GetChecked()
         DKROT_Settings.Range = DKROT_FramePanel_Range:GetChecked()
         DKROT_Settings.Rune = DKROT_FramePanel_Rune:GetChecked()
         DKROT_Settings.RuneBars = DKROT_FramePanel_RuneBars:GetChecked()
         DKROT_Settings.RP = DKROT_FramePanel_RP:GetChecked()
         DKROT_Settings.Disease = DKROT_FramePanel_Disease:GetChecked()
         DKROT_Settings.Locked = DKROT_FramePanel_Locked:GetChecked()

         -- Transparency
         if DKROT_FramePanel_Trans:GetNumber() >= 0 and DKROT_FramePanel_Trans:GetNumber() <= 1 then
            DKROT_Settings.Trans = DKROT_FramePanel_Trans:GetNumber()
         else
            DKROT_FramePanel_Trans:SetNumber(DKROT_Settings.Trans)
         end
         if DKROT_FramePanel_CombatTrans:GetNumber() >= 0 and DKROT_FramePanel_CombatTrans:GetNumber() <= 1 then
            DKROT_Settings.CombatTrans = DKROT_FramePanel_CombatTrans:GetNumber()
         else
            DKROT_FramePanel_CombatTrans:SetNumber(DKROT_Settings.CombatTrans)
         end
         if DKROT_FramePanel_NormalTrans:GetNumber() >= 0 and DKROT_FramePanel_NormalTrans:GetNumber() <= 1 then
            DKROT_Settings.NormTrans = DKROT_FramePanel_NormalTrans:GetNumber()
         else
            DKROT_FramePanel_NormalTrans:SetNumber(DKROT_Settings.NormTrans)
         end

         -- CD/R
         DKROT_Settings.MoveAltInterrupt = DKROT_CDRPanel_MoveAltInterrupt:GetChecked()
         DKROT_Settings.MoveAltAOE = DKROT_CDRPanel_MoveAltAOE:GetChecked()
         DKROT_Settings.MoveAltDND = DKROT_CDRPanel_MoveAltDND:GetChecked()
         DKROT_Settings.DG = DKROT_CDRPanel_DG:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].UseHoW = DKROT_CDRPanel_UseHoW:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].Outbreak = DKROT_CDRPanel_Outbreak:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].UB = DKROT_CDRPanel_UB:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].PL = DKROT_CDRPanel_PL:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].ERW = DKROT_CDRPanel_ERW:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].BT = DKROT_CDRPanel_BT:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].DP = DKROT_CDRPanel_DP:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec].RP = DKROT_CDRPanel_IRP:GetChecked()
         DKROT_Settings.CD[DKROT.Current_Spec][1] = (DKROT_CDRPanel_DD_CD1:GetChecked())
         DKROT_Settings.CD[DKROT.Current_Spec][2] = (DKROT_CDRPanel_DD_CD2:GetChecked())
         DKROT_Settings.CD[DKROT.Current_Spec][3] = (DKROT_CDRPanel_DD_CD3:GetChecked())
         DKROT_Settings.CD[DKROT.Current_Spec][4] = (DKROT_CDRPanel_DD_CD4:GetChecked())

         -- Disease Timers
         DKROT_Settings.DT.Enable = DKROT_DTPanel_Enable:GetChecked()
         if not DKROT_Settings.DT.Enable then
            for k, v in pairs(DKROT.DT.Unit) do
               DKROT.DT.Unit[k].Frame:SetAlpha(0)
               DKROT.DT.Unit[k].Frame = nil
            end
            collectgarbage()
         end
         DKROT_Settings.DT.CColours = DKROT_DTPanel_CColours:GetChecked()
         DKROT_Settings.DT.TColours = DKROT_DTPanel_TColours:GetChecked()
         DKROT_Settings.DT.Target = DKROT_DTPanel_Target:GetChecked()
         DKROT_Settings.DT.TPriority = DKROT_DTPanel_TPriority:GetChecked()
         DKROT_Settings.DT.GrowDown = DKROT_DTPanel_GrowDown:GetChecked()
         DKROT_Settings.DT.Combat = DKROT_DTPanel_CombatLog:GetChecked()
         if DKROT_DTPanel_Update:GetNumber() >= 0.1 and DKROT_DTPanel_Update:GetNumber() <= 10 then
            DKROT_Settings.DT.Update = DKROT_DTPanel_Update:GetNumber()
         else
            DKROT_DTPanel_Update:SetNumber(DKROT_Settings.DT.Update)
         end
         if DKROT_DTPanel_NumFrames:GetNumber() >= 1 and DKROT_DTPanel_NumFrames:GetNumber() <= 10 then
            DKROT_Settings.DT.Numframes = DKROT_DTPanel_NumFrames:GetNumber()
         else
            DKROT_DTPanel_NumFrames:SetNumber(DKROT_Settings.DT.Numframes)
         end
         if DKROT_DTPanel_Warning:GetNumber() >= 0 and DKROT_DTPanel_Warning:GetNumber() <= 10 then
            DKROT_Settings.DT.Warning = DKROT_DTPanel_Warning:GetNumber()
         else
            DKROT_DTPanel_Warning:SetNumber(DKROT_Settings.DT.Warning)
         end
         if DKROT_DTPanel_Trans:GetNumber() >= 0 and DKROT_DTPanel_Trans:GetNumber() <= 1 then
            DKROT_Settings.DTTrans = DKROT_DTPanel_Trans:GetNumber()
         else
            DKROT_DTPanel_Trans:SetNumber(DKROT_Settings.DTTrans)
         end
         DKROT_Settings.DT.Dots[DKROT.spells["Frost Fever"]] = DKROT_DTPanel_DOTS_FF:GetChecked()
         DKROT_Settings.DT.Dots[DKROT.spells["Blood Plague"]] = DKROT_DTPanel_DOTS_BP:GetChecked()
         DKROT_Settings.DT.Dots[DKROT.spells["Death and Decay"]] = DKROT_DTPanel_DOTS_DD:GetChecked()
         DKROT_Settings.DT.Dots[DKROT.spells["Defile"]] = DKROT_DTPanel_DOTS_DF:GetChecked()
         DKROT_Settings.DT.Dots[DKROT.spells["Necrotic Plague"]] = DKROT_DTPanel_DOTS_NP:GetChecked()

         if DKROT_Settings.DT.Combat or not DKROT_Settings.DT.Enable then
            DKROT.MainFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
         else
            DKROT.MainFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
         end

         -- Change the cooldown spiral edge settings
         DKROT.Move.c:SetDrawEdge(DKROT_Settings.CDEDGE)

         DKROT:Debug("OptionsOkay")
         DKROT:OptionsRefresh()
      else
         DKROT:Debug("ERROR OptionsOkay - " .. (DKROT_Settings == nil and "Settings are nil") or (DKROT_Settings.Version == nil and "Version is nil") or ("Invalid Version" .. DKROT_Settings.Version))
      end
   end

   -- Cooldown Defaults
   function DKROT:CooldownDefaults()
      if DKROT_Settings.CD ~= nil then wipe(DKROT_Settings.CD) end
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

   -- Checks to make sure that none of the settings are nil, which will lead to the addon not working properly
   function DKROT:CheckSettings()
      DKROT:Debug("Check Settings Start")

      local specs = {DKROT.SPECS.UNKNOWN, DKROT.SPECS.BLOOD, DKROT.SPECS.FROST, DKROT.SPECS.UNHOLY}
      local spots = {"Priority", "CD1_One", "CD1_Two", "CD2_One", "CD2_Two", "CD3_One", "CD3_Two", "CD4_One", "CD4_Two"}

      -- Defaults
      if DKROT_Settings == nil then
         DKROT_Settings = {}
         DKROT_Settings.Locked = true
         DKROT_Settings.Range = true
         DKROT_Settings.GCD = true
         DKROT_Settings.Rune = true
         DKROT_Settings.RuneOrder = BBFFUU
         DKROT_Settings.RP = true
         DKROT_Settings.Disease = true
         DKROT_Settings.CD = {}
         DKROT_Settings.UpdateWarning = true
         DKROT:CooldownDefaults()
      end

      -- General Settings
      if DKROT_Settings.lbf == nil then DKROT_Settings.lbf = { 'Blizzard', 0, nil }end
      if DKROT_Settings.RuneOrder == nil then  DKROT_Settings.RuneOrder = BBUUFF end
      if DKROT_Settings.Trans == nil then DKROT_Settings.Trans = 0.5 end
      if DKROT_Settings.CombatTrans == nil then DKROT_Settings.CombatTrans = 1.0 end
      if DKROT_Settings.NormTrans == nil then DKROT_Settings.NormTrans = 1.0 end
      if DKROT_Settings.DTTrans == nil then DKROT_Settings.DTTrans = 1.0 end
      if DKROT_Settings.VScheme == nil then DKROT_Settings.VScheme = DKROT_OPTIONS_FRAME_VIEW_NORM end

      -- CDs
      if DKROT_Settings.CD == nil then
         DKROT_Settings.CD = {}
         DKROT:CooldownDefaults()
      end
      for i=1,#specs do
         if DKROT_Settings.CD[specs[i]] == nil then DKROT_Settings.CD[specs[i]] = {}   end
         if DKROT_Settings.CD[specs[i]].DiseaseOption == nil then DKROT_Settings.CD[specs[i]].DiseaseOption = DISEASE_BOTH end
         for j=1,#spots do
            if DKROT_Settings.CD[specs[i]]["DKROT_CDRPanel_DD_"..spots[j]] == nil or
               DKROT_Settings.CD[specs[i]]["DKROT_CDRPanel_DD_"..spots[j]][1] == nil then
               DKROT_Settings.CD[specs[i]]["DKROT_CDRPanel_DD_"..spots[j]] = {DKROT_OPTIONS_FRAME_VIEW_NONE, nil}
            end
         end
      end

      -- DT
      if DKROT_Settings.DT == nil then
         DKROT_Settings.DT = {}
         DKROT_Settings.DT.Enable = true
         DKROT_Settings.DT.Target = true
         DKROT_Settings.DT.TPriority = true
         DKROT_Settings.DT.CColours = true
         DKROT_Settings.DT.TColours = true
      end
      if DKROT_Settings.DT.Update == nil then DKROT_Settings.DT.Update = 2.5 end
      if DKROT_Settings.DT.Numframes == nil then DKROT_Settings.DT.Numframes = 5 end
      if DKROT_Settings.DT.Warning == nil then DKROT_Settings.DT.Warning = 3 end
      if DKROT_Settings.DT.Threat == nil then DKROT_Settings.DT.Threat = THREAT_ANALOG end
      if DKROT_Settings.DT.Dots == nil then
         DKROT_Settings.DT.Dots = {}
         DKROT_Settings.DT.Dots[DKROT.spells["Frost Fever"]] = true
         DKROT_Settings.DT.Dots[DKROT.spells["Blood Plague"]] = true
         DKROT_Settings.DT.Dots[DKROT.spells["Death and Decay"]] = true
      end

      -- Frame Location
      if DKROT_Settings.Location == nil then DKROT_Settings.Location = {} end
      if DKROT_Settings.Location["DKROT"] == nil then   DKROT_Settings.Location["DKROT"] = {Point = "Center", Rel = nil, RelPoint = "CENTER", X = 0, Y = -175, Scale = 1} end
      for idx, el in pairs(DKROT.MovableFrames) do
         if DKROT_Settings.Location[el.frame] == nil then
            DKROT_Settings.Location[el.frame] = DKROT.DefaultLocations[el.frame]
         end
      end

      DKROT_Settings.Version = DKROT_VERSION

      wipe(specs)
      wipe(spots)
      collectgarbage()
      DKROT:Debug("Check Settings Complete")
   end

   -- Set frame location back to Defaults
   function DKROT_SetLocationDefault()
      DKROT_Settings.Location = {}

      for idx, el in pairs(DKROT.MovableFrames) do
         DKROT_Settings.Location[el.frame] = DKROT:deepcopy(DKROT.DefaultLocations[el.frame])
      end

      -- DKROT:OptionsRefresh()
      DKROT:UpdatePosition()
      DKROT:Debug("SetLocationDefault Done")
   end

   -- Set all settings back to default
   function DKROT_SetDefaults()
      if DKROT_Settings ~= nil then wipe(DKROT_Settings); DKROT_Settings = nil end
      DKROT:CheckSettings()

      DKROT:OptionsRefresh()
      DKROT:Debug("SetDefaults Done")
   end

   function DKROT_Rune_DD_OnLoad()
      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[BBUUFF]
      info.value      = BBUUFF
      info.func       = function() DKROT_Settings.RuneOrder = BBUUFF; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[BBFFUU]
      info.value      = BBFFUU
      info.func       = function() DKROT_Settings.RuneOrder = BBFFUU; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[UUBBFF]
      info.value      = UUBBFF
      info.func       = function() DKROT_Settings.RuneOrder = UUBBFF; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[UUFFBB]
      info.value      = UUFFBB
      info.func       = function() DKROT_Settings.RuneOrder = UUFFBB; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[FFUUBB]
      info.value      = FFUUBB
      info.func       = function() DKROT_Settings.RuneOrder = FFUUBB; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_RUNE_ORDER[FFBBUU]
      info.value      = FFBBUU
      info.func       = function() DKROT_Settings.RuneOrder = FFBBUU; UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_Rune_DD, DKROT_Settings.RuneOrder); end
      UIDropDownMenu_AddButton(info)
   end

   function DKROT_DTPanel_Threat_OnLoad()
      info            = {}
      info.text       = DKROT_OPTIONS_DT_THREAT_OFF
      info.value      = THREAT_OFF
      info.func       = function() DKROT_Settings.DT.Threat = THREAT_OFF;UIDropDownMenu_SetSelectedValue(DKROT_DTPanel_DD_Threat, DKROT_Settings.DT.Threat); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_DT_THREAT_ANALOG
      info.value      = THREAT_ANALOG
      info.func       = function() DKROT_Settings.DT.Threat = THREAT_ANALOG;UIDropDownMenu_SetSelectedValue(DKROT_DTPanel_DD_Threat, DKROT_Settings.DT.Threat); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_DT_THREAT_DIGITAL
      info.value      = THREAT_DIGITAL
      info.func       = function() DKROT_Settings.DT.Threat = THREAT_DIGITAL;UIDropDownMenu_SetSelectedValue(DKROT_DTPanel_DD_Threat, DKROT_Settings.DT.Threat); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_DT_THREAT_HEALTH
      info.value      = THREAT_HEALTH
      info.func       = function() DKROT_Settings.DT.Threat = THREAT_HEALTH;UIDropDownMenu_SetSelectedValue(DKROT_DTPanel_DD_Threat, DKROT_Settings.DT.Threat); end
      UIDropDownMenu_AddButton(info)
   end

   -- function to handle the View dropdown box
   function DKROT_FramePanel_ViewDD_OnLoad()
      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_VIEW_NORM
      info.value      = DKROT_OPTIONS_FRAME_VIEW_NORM
      info.func       = function() DKROT_Settings.VScheme = DKROT_OPTIONS_FRAME_VIEW_NORM;UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_VIEW_TARGET
      info.value      = DKROT_OPTIONS_FRAME_VIEW_TARGET
      info.func       = function() DKROT_Settings.VScheme = DKROT_OPTIONS_FRAME_VIEW_TARGET;UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_VIEW_SHOW
      info.value      = DKROT_OPTIONS_FRAME_VIEW_SHOW
      info.func       = function() DKROT_Settings.VScheme = DKROT_OPTIONS_FRAME_VIEW_SHOW;UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme); end
      UIDropDownMenu_AddButton(info)

      info            = {}
      info.text       = DKROT_OPTIONS_FRAME_VIEW_HIDE
      info.value      = DKROT_OPTIONS_FRAME_VIEW_HIDE
      info.func       = function() DKROT_Settings.VScheme = DKROT_OPTIONS_FRAME_VIEW_HIDE;UIDropDownMenu_SetSelectedValue(DKROT_FramePanel_ViewDD, DKROT_Settings.VScheme); end
      UIDropDownMenu_AddButton(info)
   end

   -- function to handle the Disease dropdown box
   function DKROT_Diseases_OnLoad(self)
      info = {}
      info.text = DKROT_OPTIONS_CDR_DISEASES_DD_BOTH
      info.value = DISEASE_BOTH
      info.func = function() DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption = DISEASE_BOTH;UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Diseases_DD,  DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption); end
      UIDropDownMenu_AddButton(info)

      info = {}
      info.text = DKROT_OPTIONS_CDR_DISEASES_DD_ONE
      info.value = DISEASE_ONE
      info.func = function() DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption = DISEASE_ONE;UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Diseases_DD,  DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption); end
      UIDropDownMenu_AddButton(info)

      info = {}
      info.text = DKROT_OPTIONS_CDR_DISEASES_DD_NONE
      info.value = DISEASE_NONE
      info.func = function() DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption = DISEASE_NONE;UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Diseases_DD,  DKROT_Settings.CD[DKROT.Current_Spec].DiseaseOption); end
      UIDropDownMenu_AddButton(info)
   end

   -- Initialize the rotation list
   function DKROT_Rotations_OnLoad(self)
      for key, rotation in pairs(DKROT.Rotations[DKROT.Current_Spec]) do
         info = {}
         info.text = rotation.name
         info.value = key
         info.func = function()
            DKROT_Settings.CD[DKROT.Current_Spec].Rotation = key
            UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Rotation, DKROT_Settings.CD[DKROT.Current_Spec].Rotation)
         end
         UIDropDownMenu_AddButton(info)
      end

      -- Select rotation
      local current_rotation = DKROT_Settings.CD[DKROT.Current_Spec].Rotation
      if current_rotation == nil then
         if DKROT.Current_Spec ~= DKROT.SPECS.UNKNOWN then
            for rotName, rotInfo in pairs(DKROT.Rotations[DKROT.Current_Spec]) do
               if rotInfo.default == true then
                  current_rotation = rotName
                  break
               end
            end
            UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Rotation, current_rotation)
            UIDropDownMenu_SetText(DKROT_CDRPanel_Rotation, DKROT.Rotations[DKROT.Current_Spec][current_rotation].name)
         end
      end

      UIDropDownMenu_SetSelectedValue(DKROT_CDRPanel_Rotation, current_rotation)
      UIDropDownMenu_SetText(DKROT_CDRPanel_Rotation, DKROT.Rotations[DKROT.Current_Spec][current_rotation].name)
   end

   -- function to handle the CD dropdown boxes
   function DKROT_CDRPanel_DD_OnLoad(self, level)
      -- If specified level, or base
      level = level or 1

      -- Template for an item in the dropdown box
      local function DKROT_CDRPanel_DD_Item (panel, spell, buff)
         info = {}
         info.text = spell .. ((buff and " (Buff)") or "")
         info.value = spell .. ((buff and " (Buff)") or "")
         info.func = function()
            DKROT_Settings.CD[DKROT.Current_Spec][panel:GetName()][1] = spell
            DKROT_Settings.CD[DKROT.Current_Spec][panel:GetName()][2] = buff
            UIDropDownMenu_SetSelectedValue(panel, spell .. ((buff and " (Buff)") or ""))
            CloseDropDownMenus()
         end
         return info
      end

      -- Function to add specs specific CDs
      local function AddSpecCDs(Spec)
         for i = 1, #Spec do
            if (DKROT.Cooldowns.Buffs[Spec[i]] == nil or DKROT.Cooldowns.Buffs[Spec[i]][2]) then
               UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, Spec[i]), 2)
            end
            if DKROT.Cooldowns.Buffs[Spec[i]] ~= nil then
               UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, Spec[i], true), 2)
            end
         end
      end

      -- If base level
      if level == 1 then
         -- Add unique items to dropdown
         UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_CDR_CD_PRIORITY), 1)
         UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_CDR_CD_PRESENCE), 1)
         UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_FRAME_VIEW_NONE), 1)
         UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_CDR_RACIAL), 1)

         -- Setup nested dropdowns
         info.hasArrow = true
         info.notClickable = 1

         -- Spec Specific CDs
         info.text = DKROT_OPTIONS_CDR_CD_SPEC
         info.value = {["Level1_Key"] = "Spec";}
         UIDropDownMenu_AddButton(info)

         -- Normal CDs
         info.text = DKROT_OPTIONS_CDR_CD_NORMAL
         info.value = {["Level1_Key"] = "Normal";}
         UIDropDownMenu_AddButton(info)

         -- Moves
         info.text = DKROT_OPTIONS_CDR_CD_MOVES
         info.value = {["Level1_Key"] = "Moves";}
         UIDropDownMenu_AddButton(info)

         -- Talents
         info.text = DKROT_OPTIONS_CDR_CD_TALENTS
         info.value = {["Level1_Key"] = "Talents";}
         UIDropDownMenu_AddButton(info)

         -- Trinkets
         info.text = DKROT_OPTIONS_CDR_CD_TRINKETS
         info.value = {["Level1_Key"] = "Trinkets";}
         UIDropDownMenu_AddButton(info)

      -- If nested menu
      elseif level == 2 then
         -- Check what the "parent" is
         local key = UIDROPDOWNMENU_MENU_VALUE["Level1_Key"]

         if key == "Spec" then
            if (DKROT.Current_Spec == DKROT.SPECS.UNHOLY) then
               AddSpecCDs(DKROT.Cooldowns.UnholyCDs)
            elseif (DKROT.Current_Spec == DKROT.SPECS.FROST) then
               AddSpecCDs(DKROT.Cooldowns.FrostCDs)
            elseif (DKROT.Current_Spec == DKROT.SPECS.BLOOD) then
               AddSpecCDs(DKROT.Cooldowns.BloodCDs)
            end

         elseif key == "Normal" then
            AddSpecCDs(DKROT.Cooldowns.NormCDs)

         elseif key == "Moves" then
            for i = 1, #DKROT.Cooldowns.Moves do
               if GetSpellTexture(DKROT.Cooldowns.Moves[i]) ~= nil then
                  UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT.Cooldowns.Moves[i]), 2)
               end
            end

         elseif key == "Talents" then
            AddSpecCDs(DKROT.Cooldowns.TalentCDs)

         elseif key == "Trinkets" then
            UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT1), 2)
            UIDropDownMenu_AddButton(DKROT_CDRPanel_DD_Item(self, DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT2), 2)
         end
      end
   end

   function DKROT:PositionUpdate()
      local el = _G[UIDropDownMenu_GetSelectedValue(DKROT_PositionPanel_Element)]
      local name = el:GetName()
      local x = DKROT.PositionPanel_X:GetValue()
      local y = DKROT.PositionPanel_Y:GetValue()
      local scale = DKROT.PositionPanel_Scale:GetValue()
      local point = UIDropDownMenu_GetSelectedValue(DKROT.PositionPanel_Point)
      local relPoint = UIDropDownMenu_GetSelectedValue(DKROT.PositionPanel_RelPoint)
      local relFrame = UIDropDownMenu_GetSelectedValue(DKROT.PositionPanel_RelFrame)

      DKROT_Settings.Location[name].X = x
      DKROT_Settings.Location[name].Y = y
      DKROT_Settings.Location[name].Scale = scale
      DKROT_Settings.Location[name].Point = point
      DKROT_Settings.Location[name].Rel = relFrame
      DKROT_Settings.Location[name].RelPoint = relPoint

      DKROT:MoveFrame(el)
   end
else
   print("DKRot: Not a DK")
   DKROT_Options = nil
   DKROT_FramePanel = nil
   DKROT_CDRPanel = nil
   DKROT_CDPanel = nil
   DKROT_ABOUTPanel = nil
end
