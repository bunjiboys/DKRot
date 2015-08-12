if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...
   DKROT_VERSION = GetAddOnMetadata("DKRot", "Version")

   DKROT.debug = false
   DKROT.font = "Interface\\AddOns\\DKRot\\resources\\font.ttf"

   DKROT.curtime = 0
   DKROT.GCD = 0
   DKROT.PullTimer = 0

   DKROT.ThreatMode = {
      Off = 0,
      Health = 0.1,
      Bars = 1,
      Hated = 99
   }

   DKROT.DiseaseOptions = {
      Both = 2,
      Single = 1,
      None = 0
   }

   DKROT.RuneOrder = {
      BBUUFF = 1,
      BBFFUU = 2,
      UUBBFF = 3,
      UUFFBB = 4,
      FFUUBB = 5,
      FFBBUU = 6
   }

   DKROT.SPECS = {
      BLOOD = 1,
      FROST = 2,
      UNHOLY = 3,
      UNKNOWN = 4
   }

   DKROT.TrinketType = {
      OnUse = 1,
      Stacking = 2,
      ICD = 3,
      RPPM = 4,
      Debuff = 5
   }

   DKROT.Tiers = {
       NO_TIER = 0x0000,
       TIER17_2p = 0x0001,
       TIER17_4p = 0x0002,
       TIER18_2p = 0x0004,
       TIER18_4p = 0x0008
   }

   DKROT.TierItems = {
       TIER17 = { 115535, 115536, 115537, 115539, 115539 },
       TIER18 = { 124317, 124327, 124332, 124338, 124344 }
   }

   DKROT.Talents = {
      ["Plaguebearer"] = 19165,
      ["Plague Leech"] = 19166,
      ["Unholy Blight"] = 19217,
      ["Lichborne"] = 19218,
      ["Anti-Magic Zone"] = 19219,
      ["Purgatory"] = 19220,
      ["Death's Advance"] = 19221,
      ["Chilblains"] = 19222,
      ["Asphyxiate"] = 19223,
      ["Blood Tap"] = 19224,
      ["Runic Empowerment"] = 19225,
      ["Runic Corruption"] = 19229,
      ["Death Pact"] = 19226,
      ["Death Siphon"] = 19227,
      ["Conversion"] = 19228,
      ["Gorefiend's Grasp"] = 19230,
      ["Remorseless Winter"] = 19231,
      ["Desecrated Ground"] = 19232,
      ["Necrotic Plague"] = 21207,
      ["Defile"] = 21208,
      ["Breath of Sindragosa"] = 21209
   }

   DKROT.DTspells = {}
   DKROT.Current_Spec = DKROT.SPECS.UNKNOWN
   DKROT.spells = {}
   DKROT.Cooldowns = {}
   DKROT.Rotations = {
      {},
      {},
      {},
      {},
   }

   DKROT.TimeToDie = {
      Sweep = 0,
      Targets = {},
      LastUpdate = 0
   }

   DKROT.MovableFrames = {
      { name = "Priority Icon", frame = "DKROT.Move" },
      { name = "AOE Icon", frame = "DKROT.AOE" },
      { name = "Cooldown #1", frame = "DKROT.CD1" },
      { name = "Cooldown #2", frame = "DKROT.CD2" },
      { name = "Cooldown #3", frame = "DKROT.CD3" },
      { name = "Cooldown #4", frame = "DKROT.CD4" },
      { name = "Diseases", frame = "DKROT.Diseases" },
      { name = "Disease Tracker", frame = "DKROT.DT" },
      { name = "Interrupt", frame = "DKROT.Interrupt" },
      { name = "Rune Bar - Text", frame = "DKROT.RuneBar" },
      { name = "Rune Bar - Graphical", frame = "DKROT.RuneBarHolder" },
      { name = "Runic Power", frame = "DKROT.RunicPower" },
      { name = "Time to Die", frame = "DKROT.TTD" },
   }

   DKROT.FrameAnchors = {
      { name = "Screen", frame = "UIParent" },
      { name = "AOE Icon", frame = "DKROT.AOE" },
      { name = "Cooldown #1", frame = "DKROT.CD1" },
      { name = "Cooldown #2", frame = "DKROT.CD2" },
      { name = "Cooldown #3", frame = "DKROT.CD3" },
      { name = "Cooldown #4", frame = "DKROT.CD4" },
      { name = "Disease Tracker", frame = "DKROT.DT" },
      { name = "Diseases", frame = "DKROT.Diseases" },
      { name = "Interrupt", frame = "DKROT.Interrupt" },
      { name = "Priority Icon", frame = "DKROT.Move" },
      { name = "Rune Bar - Graphical", frame = "DKROT.RuneBarHolder" },
      { name = "Rune Bar - Text", frame = "DKROT.RuneBar" },
      { name = "Runic Power", frame = "DKROT.RunicPower" },
      { name = "Time to Die", frame = "DKROT.TTD" },
   }

   DKROT.DefaultLocations = {
      ["DKROT"] = {
         Point = "CENTER",
         Rel = "UIParent",
         RelPoint = "CENTER", 
         X = 0,
         Y = -175,
         Scale = 1,
         Opacity = 0.8
      },
      ["DKROT.Move"] = {
         Point = "CENTER",
         Rel = "UIParent",
         RelPoint = "CENTER",
         X = 0,
         Y = -150,
         Scale = 1,
         Opacity = 0.8
      },
      ["DKROT.AOE"] = {
         Point = "BOTTOMLEFT",
         Rel = "DKROT.Move",
         RelPoint = "BOTTOMLEFT",
         X = 0,
         Y = 0,
         Scale = 0.5,
         Opacity = 0.8
      },
      ["DKROT.Interrupt"] = {
         Point = "TOPRIGHT",
         Rel = "DKROT.Move",
         RelPoint = "TOPRIGHT",
         X = 0,
         Y = 0,
         Scale = 0.5,
         Opacity = 0.8
      },
      ["DKROT.CD1"] = {
         Point = "TOPRIGHT",
         Rel = "DKROT.Move",
         RelPoint = "TOPLEFT",
         X = -4,
         Y = 1,
         Scale = 1,
         Opacity = 0.8
      },
      ["DKROT.CD2"] = {
         Point = "TOPLEFT",
         Rel = "DKROT.Move",
         RelPoint = "TOPRIGHT",
         X = 4,
         Y = 1,
         Scale = 1,
         Opacity = 0.8
      },
      ["DKROT.CD3"] = {
         Point = "TOPRIGHT",
         Rel = "DKROT.CD1",
         RelPoint = "TOPLEFT",
         X = -2,
         Y = 0,
         Scale = 1,
         Opacity = 0.8
      },
      ["DKROT.CD4"] = {
         Point = "TOPLEFT",
         Rel = "DKROT.CD2",
         RelPoint = "TOPRIGHT",
         X = 2,
         Y = 0,
         Scale = 1,
         Opacity = 0.8
      },
      ["DKROT.RuneBar"] = {
         Point = "BOTTOM",
         Rel = "DKROT.Move",
         RelPoint = "TOP",
         X = 0,
         Y = -2,
         Scale = 1,
         Opacity = 0.8
      },
      ["DKROT.RuneBarHolder"] = {
         Point = "BOTTOMLEFT",
         Rel = "DKROT.CD4",
         RelPoint = "BOTTOMRIGHT",
         X = 1,
         Y = -1,
         Scale = 0.86,
         Opacity = 0.8
      },
      ["DKROT.RunicPower"] = {
         Point = "TOP",
         Rel = "DKROT.Move",
         RelPoint = "BOTTOM",
         X = 0,
         Y = -2,
         Scale = 1,
         Opacity = 0.8
      },
      ["DKROT.Diseases"]= {
         Point = "TOP",
         Rel = "DKROT.RunicPower",
         RelPoint = "BOTTOM",
         X = 0,
         Y = 0,
         Scale = 1,
         Opacity = 0.8
      },
      ["DKROT.DT"] = {
         Point = "BOTTOMRIGHT",
         Rel = "DKROT.CD3",
         RelPoint = "BOTTOMLEFT",
         X = -2,
         Y = 0,
         Scale = 1,
         Opacity = 0.8
      },
      ["DKROT.TTD"] = {
         Point = "BOTTOM",
         Rel = "DKROT.RuneBar",
         RelPoint = "TOP",
         X = 0,
         Y = 0,
         Scale = 1,
         Opacity = 0.8
      },
   }

   StaticPopupDialogs["DKROT_ERROR_DEPENDENCY_VIOLATION"] = {
      text = "You cannot anchor this frame to %s as it has a dependency on the source frame.\n\nDependency violated:\n%s\n",
      button1 = "OK",
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
      showAlert = true,
      preferredIndex = 3,
   }

   StaticPopupDialogs["DKROT_UPDATE_WARNING"] = {
      text = "DKRot has been updated to support more than just 2 rotations per spec\n\nIf you want to change the rotation to use, open the settings and select the rotation from the dropdown menu\n\nThis warning should only be displayed once\n",
      button1 = "OK",
      button3 = "Open settings",
      OnAlt = function()
         InterfaceOptionsFrame_OpenToCategory(DKROT_CDRPanel)
         InterfaceOptionsFrame_OpenToCategory(DKROT_CDRPanel)
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
      showAlert = true,
      preferredIndex = 3,
   }

   StaticPopupDialogs["DKROT_FRAME_UNLOCKED"] = {
      text = "DKRot is unlocked. You can move them by dragging the frames around and when you are done click on the Lock button below",
      button3 = "Lock",
      OnAlt = function()
         DKROT_Settings.Locked = true
         DKROT.LockDialog = false
         DKROT_LockUI()
         DKROT:OptionsRefresh()
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = false,
      preferredIndex = 3,
   }
end
