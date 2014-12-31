if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...
   DKROT_VERSION = GetAddOnMetadata("DKRot", "Version")

   DKROT.SPECS = {
      UNKNOWN = 0,
      BLOOD = 1,
      FROST = 2,
      UNHOLY = 3
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

   function DKROT:RegisterRotation(spec, intname, rotname, rotfunc)
      DKROT.Rotations[spec][intname] = {
         name = rotname,
         func = rotfunc
      }
   end
end
