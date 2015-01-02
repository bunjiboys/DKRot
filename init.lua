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
end
