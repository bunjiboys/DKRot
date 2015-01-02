DKRot
=====
This addon is based on a fork of CLC DK, but has been updated to support the current Warlords of Draenor changes to both spells and rotations.
### Notable differences
#### Multiple rotations
DKRot now supports having more than just two different rotations for a given specialization. As of version 0.1.0-beta, the addon now have rotations based on both Icy Veins information as well as SimCraft.
#### External rotation registration
It is now possible for anyone to add new rotations to the addon, by creating a stub addon by themselves. DKRot exposes a function called DKROT_RegisterRotation:
```lua
DKROT_RegisterRotation(spec, intname, rotname, rotfunc, defaultRotation)
```
This function lets anyone register a function as being a rotation for a given specialization. Currently, developers wanting to hook into this functionality should take a look at the existing rotations for DKRot to get an idea of how to generate rotations, but I will be adding some more documentation and support in coming versions of the addon
