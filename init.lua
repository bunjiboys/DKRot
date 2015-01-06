if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...
   DKROT.debug = false
   DKROT_VERSION = GetAddOnMetadata("DKRot", "Version")

   DKROT.SPECS = {
      BLOOD = 1,
      FROST = 2,
      UNHOLY = 3,
      UNKNOWN = 4
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

   DKROT.MovableFrames = {
      { name = "Priority Icon", frame = "DKROT.Move" },
      { name = "Cooldown #1", frame = "DKROT.CD1" },
      { name = "Cooldown #2", frame = "DKROT.CD2" },
      { name = "Cooldown #3", frame = "DKROT.CD3" },
      { name = "Cooldown #4", frame = "DKROT.CD4" },
      { name = "Diseases", frame = "DKROT.Diseases" },
      { name = "Disease Tracker", frame = "DKROT.DT" },
      { name = "Rune Bar - Text", frame = "DKROT.RuneBar" },
      { name = "Rune Bar - Graphical", frame = "DKROT.RuneBarHolder" },
      { name = "Runic Power", frame = "DKROT.RunicPower" },
   }

   DKROT.FrameAnchors = {
      { name = "Screen", frame = "UIParent" },
      { name = "Priority Icon", frame = "DKROT.Move" },
      { name = "Runic Power", frame = "DKROT.RunicPower" },
      { name = "Disease Tracker", frame = "DKROT.DT" },
      { name = "Graphical Rune Bar", frame = "DKROT.RuneBarHolder" },
      { name = "Cooldown #1", frame = "DKROT.CD1" },
      { name = "Cooldown #2", frame = "DKROT.CD2" },
      { name = "Cooldown #3", frame = "DKROT.CD3" },
      { name = "Cooldown #4", frame = "DKROT.CD4" },
      { name = "Rune Bar", frame = "DKROT.RuneBar" },
      { name = "Diseases", frame = "DKROT.Diseases" },
   }

   DKROT.DefaultLocations = {
      ["DKROT"] = {
         Point = "CENTER",
         Rel = "UIParent",
         RelPoint = "CENTER", 
         X = 0,
         Y = -175,
         Scale = 1
      },
      ["DKROT.Move"] = {
         Point = "CENTER",
         Rel = "UIParent",
         RelPoint = "CENTER",
         X = 0,
         Y = -150,
         Scale = 1
      },
      ["DKROT.CD1"] = {
         Point = "TOPRIGHT",
         Rel = "DKROT.Move",
         RelPoint = "TOPLEFT",
         X = -1,
         Y = -3,
         Scale = 1
      },
      ["DKROT.CD2"] = {
         Point = "TOPLEFT",
         Rel = "DKROT.Move",
         RelPoint = "TOPRIGHT",
         X = 1,
         Y = -3,
         Scale = 1
      },
      ["DKROT.CD3"] = {
         Point = "TOPRIGHT",
         Rel = "DKROT.CD1",
         RelPoint = "TOPLEFT",
         X = -2,
         Y = 0,
         Scale = 1
      },
      ["DKROT.CD4"] = {
         Point = "TOPLEFT",
         Rel = "DKROT.CD2",
         RelPoint = "TOPRIGHT",
         X = 2,
         Y = 0,
         Scale = 1
      },
      ["DKROT.RuneBar"] = {
         Point = "BOTTOM",
         Rel = "DKROT.Move",
         RelPoint = "TOP",
         X = 0,
         Y = -2,
         Scale = 1
      },
      ["DKROT.RuneBarHolder"] = {
         Point = "BOTTOMLEFT",
         Rel = "DKROT.CD4",
         RelPoint = "BOTTOMRIGHT",
         X = 1,
         Y = -1,
         Scale = 0.86
      },
      ["DKROT.RunicPower"] = {
         Point = "TOP",
         Rel = "DKROT.Move",
         RelPoint = "BOTTOM",
         X = 0,
         Y = 0,
         Scale = 1
      },
      ["DKROT.Diseases"]= {
         Point = "TOP",
         Rel = "DKROT.RunicPower",
         RelPoint = "BOTTOM",
         X = 0,
         Y = 0,
         Scale = 1
      },
      ["DKROT.DT"] = {
         Point = "BOTTOMRIGHT",
         Rel = "DKROT.CD3",
         RelPoint = "BOTTOMLEFT",
         X = -2,
         Y = 0,
         Scale = 0.7
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
         DKROT:OptionsRefresh()
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = false,
      preferredIndex = 3,
   }
end
