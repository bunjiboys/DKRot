if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   DKROT_ADDONNAME = "DKRot"
   DKROT_NAMEFONT = 'Interface\\AddOns\\DKRot\\Font.ttf'

   DKROT_OPTIONS_SPEC_NONE = "Current Spec: None"
   DKROT_OPTIONS_SPEC_UNHOLY = "Current Spec: Unholy"
   DKROT_OPTIONS_SPEC_FROST = "Current Spec: Frost"
   DKROT_OPTIONS_SPEC_BLOOD = "Current Spec: Blood"
   DKROT_OPTIONS_RESET = "Reset to Default"
   DKROT_OPTIONS_RESETLOCATION  = "Reset Frame"

   DKROT_OPTIONS_FRAME = "Frame Options"
   DKROT_OPTIONS_FRAME_GCD = "Show GCD Spiral"
   DKROT_OPTIONS_FRAME_CDEDGE = "Show spark/edge on GCD spiral"
   DKROT_OPTIONS_FRAME_CDS = "Show CD Spirals"
   DKROT_OPTIONS_FRAME_RANGE = "Show Range Colour"
   DKROT_OPTIONS_FRAME_RUNE = "Show Rune Bar"
   DKROT_OPTIONS_FRAME_RUNEBARS = "Show Graphical Runes"
   DKROT_OPTIONS_FRAME_RUNE_O = "Rune Ordering"
   DKROT_OPTIONS_FRAME_RUNE_ORDER = {
      "|cFFFF0000BB|r|cFF00FF00UU|r|cFF00FFFFFF|r",
      "|cFFFF0000BB|r|cFF00FFFFFF|r|cFF00FF00UU|r",
      "|cFF00FF00UU|r|cFFFF0000BB|r|cFF00FFFFFF|r",
      "|cFF00FF00UU|r|cFF00FFFFFF|r|cFFFF0000BB|r",
      "|cFF00FFFFFF|r|cFF00FF00UU|r|cFFFF0000BB|r",
      "|cFF00FFFFFF|r|cFFFF0000BB|r|cFF00FF00UU|r"
   }
   DKROT_OPTIONS_FRAME_RP = "Show Runic Power"
   DKROT_OPTIONS_FRAME_DISEASE = "Show Disease Timers"
   DKROT_OPTIONS_FRAME_LOCKED = "Lock DKRot"
   DKROT_OPTIONS_FRAME_LOCKEDPIECES = "Lock Pieces Together"
   DKROT_OPTIONS_FRAME_VIEW = "Change View of DKRot"
   DKROT_OPTIONS_FRAME_VIEW_NORM = "Normal"
   DKROT_OPTIONS_FRAME_VIEW_TARGET = "Only When Targeting"
   DKROT_OPTIONS_FRAME_VIEW_HIDE = "Always Hide"
   DKROT_OPTIONS_FRAME_VIEW_SHOW = "Always Show"
   DKROT_OPTIONS_FRAME_VIEW_NONE = "None"
   DKROT_OPTIONS_FRAME_SCALE = "Scale (0.5-5)"
   DKROT_OPTIONS_FRAME_NORMALTRANS = "Trans. (0-1)"
   DKROT_OPTIONS_FRAME_TRANS = "Backdrop Trans. (0-1)"
   DKROT_OPTIONS_FRAME_COMBATTRANS = "In-Combat Trans. (0-1)"

   DKROT_OPTIONS_CD = "Cooldown Options"
   DKROT_OPTIONS_CDR = "Rotation Options"
   DKROT_OPTIONS_CDR_DISEASES_DD = "Disease Options"
   DKROT_OPTIONS_CDR_DISEASES_DD_BOTH = "Both Diseases (FF+BP)"
   DKROT_OPTIONS_CDR_DISEASES_DD_ONE = "One Disease (FF)"
   DKROT_OPTIONS_CDR_DISEASES_DD_NONE = "Diseaseless"
   DKROT_OPTIONS_CDR_ROTATION = "Use in Rotation"
   DKROT_OPTIONS_CDR_RP = "Runic Power"
   DKROT_OPTIONS_CDR_MOVEALT_INTERRUPT = "Show Interrupt Icon"
   DKROT_OPTIONS_CDR_MOVEALT_AOE = "Show AOE Icon"
   DKROT_OPTIONS_CDR_MOVEALT_DND = "Show DnD Icon"
   DKROT_OPTIONS_CDR_ALT_ROT = "Use Alternative Rotation"
   DKROT_OPTIONS_CDR_ALT_ROT_UNHOLY = "Festerblight"
   DKROT_OPTIONS_CDR_ALT_ROT_FROST = "Dual-weild"
   DKROT_OPTIONS_CDR_ALT_ROT_BLOOD = "None"
   DKROT_OPTIONS_CDR_SetBon = "Adjust Soul Reaper for Tier 15 Set Bonus"
   DKROT_OPTIONS_CDR_PRIORITY = "Priority Icon"
   DKROT_OPTIONS_CDR_CD1 = "Show Left Cooldowns"
   DKROT_OPTIONS_CDR_CD2 = "Show Right Cooldowns"
   DKROT_OPTIONS_CDR_CD3 = "Show Far Left Cooldowns"
   DKROT_OPTIONS_CDR_CD4 = "Show Far Right Cooldowns"
   DKROT_OPTIONS_CDR_CD_ONE = "Cooldown #1 to Watch"
   DKROT_OPTIONS_CDR_CD_TWO = "Cooldown #2 to Watch"
   DKROT_OPTIONS_CDR_CD_PRIORITY = "Priority"
   DKROT_OPTIONS_CDR_CD_PRESENCE = "Presence"
   DKROT_OPTIONS_CDR_CD_SPEC = "Spec CDs/Buffs"
   DKROT_OPTIONS_CDR_CD_NORMAL = "Normal CDs/Buffs"
   DKROT_OPTIONS_CDR_CD_MOVES = "Moves"
   DKROT_OPTIONS_CDR_CD_TALENTS = "Talent CDs/Buffs"
   DKROT_OPTIONS_CDR_CD_TIER = "Tier CDs/Buffs"
   DKROT_OPTIONS_CDR_CD_TRINKETS = "Trinkets"
   DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT1 = "Trinket Slot 1"
   DKROT_OPTIONS_CDR_CD_TRINKETS_SLOT2 = "Trinket Slot 2"
   DKROT_OPTIONS_CDR_RACIAL = "Racial"

   DKROT_OPTIONS_DT = "Disease Tracker Options"
   DKROT_OPTIONS_DT_ENABLE = "Enable"
   DKROT_OPTIONS_DT_CCOLOURS = "Show Class Colours"
   DKROT_OPTIONS_DT_TARGET = "Include Target"
   DKROT_OPTIONS_DT_TCOLOURS = "Highlight Target & Focus"
   DKROT_OPTIONS_DT_TPRIORITY = "Prioritize Target & Focus"
   DKROT_OPTIONS_DT_GROWDOWN = "Grow Downwords"
   DKROT_OPTIONS_DT_COMBAT = "Disable Combat Log Watch"
   DKROT_OPTIONS_DT_UPDATE = "Watch Delay (0.1-10)"
   DKROT_OPTIONS_DT_NUMFRAMES = "Units to Track (1-10)"
   DKROT_OPTIONS_DT_WARNING = "DOT Warning (0-10sec)"
   DKROT_OPTIONS_DT_THREAT = "Threat Information"
   DKROT_OPTIONS_DT_THREAT_OFF = "Off"
   DKROT_OPTIONS_DT_THREAT_ANALOG = "Bars"
   DKROT_OPTIONS_DT_THREAT_DIGITAL = "Only when hated"
   DKROT_OPTIONS_DT_THREAT_HEALTH = "Show Health Bars"
   DKROT_OPTIONS_DT_DOTS = "Track DOTs"
   DKROT_OPTIONS_DT_TRANS = "Trans. (0-1)"

   DKROT_ABOUT = "About"
   DKROT_ABOUT_BODY = "Have Questions? Suggestions? or just want more information?<br/>Leave a comment on Curse.com"
   DKROT_ABOUT_GER = "German translation courtesy of Baine"
   DKROT_ABOUT_BR = "Brazilian Portuguese translation courtesy of Ansatsukenn - Gurubashi US"
   DKROT_ABOUT_CT = "Chinese/Taiwan translation courtesy of yeah-chen"
   DKROT_ABOUT_CC = "Code contributions by Jerec EU-Anub'Arak, and Commstrike"
   DKROT_ABOUT_AUTHOR = "Author: Aerendil <Revelations>, US-Hyjal, Jardo US-Hyjal (WoD)"
   DKROT_ABOUT_VERSION = "Version: ".. GetAddOnMetadata("DKRot", "Version")
end
