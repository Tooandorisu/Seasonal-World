local gateRoof={128,96,96,30}

return {
  roofs={gateRoof}, details={gateRoof}, warmRoofs=true, finishRoofs={gateRoof},
  protect={{128,96,96,64}},
  preserveSurfaceBlock=0x55,
  lights={{132,126,88}}, fences={},
  tintTrim={{624,144,16,16}}, -- Route sign
  -- The west gate warps are bare ground. The east warps are paving
  -- and are handled by the surface recolour so the texture survives.
  entranceSnow={{112,128,16,32}},
  ledgeSnow={},
}
