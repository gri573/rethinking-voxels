bool isEmissive(int mat) {
	return (
		mat == 1234  || // generic light source
		mat == 1235  || // generic light source (fallback colour)
		mat == 10836 || // brewing stand
		mat == 10056 || // lava cauldron
		mat == 10068 || // lava
		mat == 10072 || // fire
		mat == 10076 || // soul fire
		mat == 10216 || // crimson wood
		mat == 10224 || // warped wood
#if GLOWING_ORE_MASTER == 2 || (GLOWING_ORE_MASTER == 1 && SHADER_STYLE == 4)
		mat == 10272 || // iron ore
		mat == 10276 ||
		mat == 10284 || // copper ore
		mat == 10288 ||
		mat == 10300 || // gold ore
		mat == 10304 ||
		mat == 10320 || // diamond ore
		mat == 10324 ||
		mat == 10340 || // emerald ore
		mat == 10344 ||
		mat == 10356 || // lapis ore
		mat == 10360 ||
		mat == 10612 || // redstone ore
		mat == 10620 ||
#endif
		mat == 10616 || // lit redstone ore
		mat == 10624 ||
#ifdef EMISSIVE_EMERALD_BLOCK
		mat == 10336 || // emerald block
#endif
#ifdef EMISSIVE_LAPIS_BLOCK
		mat == 10352 || // lapis block
#endif
#ifdef EMISSIVE_REDSTONE_BLOCK
		mat == 10608 || // redstone block
#endif
		mat == 10332 || // amethyst buds
		//mat == 10388 || // blue ice
		mat == 10396 || // jack o'lantern
		mat == 10400 || // 1-2 waterlogged sea pickles
		mat == 10401 || // 3-4 waterlogged sea pickles
		mat == 10412 || // glowstone
		mat == 10448 || // sea lantern
		mat == 10452 || // magma block
		mat == 10476 || // crying obsidian
		mat == 10496 || // torch
		mat == 10500 || // end rod
		mat == 10508 || // chorus flower
		mat == 10516 || // lit furnace
		mat == 10528 || // soul torch
		mat == 10544 || // glow lichen
		mat == 10548 || // enchanting table
		mat == 10556 || // end portal frame with eye
		mat == 10560 || // lantern
		mat == 10564 || // soul lantern
		mat == 10572 || // dragon egg
		mat == 10576 || // lit smoker
		mat == 10580 || // lit blast furnace
		mat == 10584 || // lit candles
		mat == 10592 || // respawn anchor
		mat == 10596 || // redstone wire
		mat == 10604 || // lit redstone torch
		mat == 10632 || // glow berries
		mat == 10640 || // lit redstone lamp
		mat == 10648 || // shroomlight
		mat == 10652 || // lit campfire
		mat == 10656 || // lit soul campfire
		mat == 10680 || // ochre       froglight
		mat == 10684 || // verdant     froglight
		mat == 10688 || // pearlescent froglight
		mat == 10705 || // active sculk sensor
		mat == 10708 || // spawner
		mat == 10996 || // light block
		//mat == 12740 || // lit candle cake
		mat == 30020 || // nether portal
		mat == 31016 || // beacon
		mat == 60000 || // end portal
		mat == 60012 || // ender chest
		mat == 60020 || // conduit
		mat == 50000 || // end crystal
		mat == 50004 || // lightning bolt
		mat == 50012 || // glow item frame
		mat == 50020 || // blaze
		mat == 50048 || // glow squid
		mat == 50052 || // magma cube
		mat == 50080 || // allay
		mat == 50116    // TNT and TNT minecart
	);
}

#include "/lib/materials/lightColorSettings.glsl"

vec3 getLightCol(int mat) {
	vec3 lightcol = vec3(0);
		switch (mat) {
		case 1235: // fallback with hardcoded colour
		case 10999:
			lightcol = blocklightCol;
		case 10056: // lava cauldron
			#ifdef CAULDRON_HARDCODED_LAVA_COL
			lightcol = vec3(LAVA_COL_R, LAVA_COL_G, LAVA_COL_B);
			#endif
			break;
		case 10068: // lava
			#ifdef HARDCODED_LAVA_COL
			lightcol = vec3(LAVA_COL_R, LAVA_COL_G, LAVA_COL_B);
			#endif
			break;
		case 10072: // fire
			#ifdef HARDCODED_FIRE_COL
			lightcol = vec3(FIRE_COL_R, FIRE_COL_G, FIRE_COL_B);
			#endif
			break;
		case 10652: // lit campfire
			#ifdef CAMPFIRE_HARDCODED_FIRE_COL
			lightcol = vec3(FIRE_COL_R, FIRE_COL_G, FIRE_COL_B);
			#endif
			break;
		case 10656: // lit soul campfire
			#ifdef CAMPFIRE_HARDCODED_SOULFIRE_COL
			lightcol = vec3(SOULFIRE_COL_R, SOULFIRE_COL_G, SOULFIRE_COL_B);
			#endif
			break;
		case 10076: // soul fire
			#ifdef HARDCODED_SOULFIRE_COL
			lightcol = vec3(SOULFIRE_COL_R, SOULFIRE_COL_G, SOULFIRE_COL_B);
			#endif
			break;
		case 10216: // crimson wood
		case 10224: // warped wood
			break;
	#if GLOWING_ORES > 0
		case 10272: // iron ore
		case 10276:
			#ifdef ORE_HARDCODED_IRON_COL
			lightcol = vec3(IRON_COL_R, IRON_COL_G, IRON_COL_B);
			#endif
			break;
		case 10284: // copper ore
		case 10288:
			#ifdef ORE_HARDCODED_COPPER_COL
			lightcol = vec3(COPPER_COL_R, COPPER_COL_G, COPPER_COL_B);
			#endif
			break;
		case 10300: // gold ore
		case 10304:
			#ifdef ORE_HARDCODED_GOLD_COL
			lightcol = vec3(GOLD_COL_R, GOLD_COL_G, GOLD_COL_B);
			#endif
			break;
		case 10320: // diamond ore
		case 10324:
			#ifdef ORE_HARDCODED_DIAMOND_COL
			lightcol = vec3(DIAMOND_COL_R, DIAMOND_COL_G, DIAMOND_COL_B);
			#endif
			break;
		case 10340: // emerald ore
		case 10344:
			#ifdef ORE_HARDCODED_EMERALD_COL
			lightcol = vec3(EMERALD_COL_R, EMERALD_COL_G, EMERALD_COL_B);
			#endif
			break;
		case 10356: // lapis ore
		case 10360:
			#ifdef ORE_HARDCODED_LAPIS_COL
			lightcol = vec3(LAPIS_COL_R, LAPIS_COL_G, LAPIS_COL_B);
			#endif
			break;
		case 10612: // redstone ore
		case 10620:
	#endif
	case 10616: // lit redstone ore
	case 10624:
		#ifdef ORE_HARDCODED_REDSTONE_COL
		lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
		#endif
		break;
	#ifdef GLOWING_MINERAL_BLOCKS
		case 10336: // emerald block
			#ifdef BLOCK_HARDCODED_EMERALD_COL
			lightcol = vec3(EMERALD_COL_R, EMERALD_COL_G, EMERALD_COL_B);
			#endif
			break;
		case 10352: // lapis block
			#ifdef BLOCK_HARDCODED_LAPIS_COL
			lightcol = vec3(LAPIS_COL_R, LAPIS_COL_G, LAPIS_COL_B);
			#endif
			break;
		case 10608: // redstone block
			#ifdef BLOCK_HARDCODED_REDSTONE_COL
			lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
			#endif
			break;
	#endif
		case 10332: // amethyst buds
			#ifdef HARDCODED_AMETHYST_COL
			lightcol = vec3(AMETHYST_COL_R, AMETHYST_COL_G, AMETHYST_COL_B);
			#endif
			break;
		case 10388: // blue ice
			#ifdef HARDCODED_ICE_COL
			lightcol = vec3(ICE_COL_R, ICE_COL_G, ICE_COL_B);
			#endif
			break;
		case 10396: // jack o'lantern
			#ifdef HARDCODED_PUMPKIN_COL
			lightcol = vec3(PUMPKIN_COL_R, PUMPKIN_COL_G, PUMPKIN_COL_B);
			#endif
			break;
		case 10400: // 1-2 waterlogged sea pickles
		case 10401: // 3-4 waterlogged sea pickles
			#ifdef HARDCODED_PICKLE_COL
			lightcol = vec3(PICKLE_COL_R, PICKLE_COL_G, PICKLE_COL_B);
			#endif
			break;
		case 10412: // glowstone
			#ifdef HARDCODED_GLOWSTONE_COL
			lightcol = vec3(GLOWSTONE_COL_R, GLOWSTONE_COL_G, GLOWSTONE_COL_B);
			#endif
			break;
		case 10448: // sea lantern
			#ifdef HARDCODED_SEALANTERN_COL
			lightcol = vec3(SEALANTERN_COL_R, SEALANTERN_COL_G, SEALANTERN_COL_B);
			#endif
			break;
		case 10452: // magma block
		case 50052: // magma cube
			#ifdef HARDCODED_MAGMA_COL
			lightcol = vec3(MAGMA_COL_R, MAGMA_COL_G, MAGMA_COL_B);
			#endif
			break;
		case 10476: // crying obsidian
			#ifdef HARDCODED_CRYING_COL
			lightcol = vec3(CRYING_COL_R, CRYING_COL_G, CRYING_COL_B);
			#endif
			break;
		case 10496: // torch
		case 10497:
			#ifdef HARDCODED_TORCH_COL
			lightcol = vec3(TORCH_COL_R, TORCH_COL_G, TORCH_COL_B);
			#endif
			break;
		case 10500: // end rod
		case 10501:
		case 10502:
			#ifdef HARDCODED_ENDROD_COL
			lightcol = vec3(ENDROD_COL_R, ENDROD_COL_G, ENDROD_COL_B);
			#endif
			break;
		case 10508: // chorus flower
			#ifdef HARDCODED_CHORUS_COL
			lightcol = vec3(CHORUS_COL_R, CHORUS_COL_G, CHORUS_COL_B);
			#endif
			break;
		case 10516: // lit furnace
			#ifdef HARDCODED_FURNACE_COL
			lightcol = vec3(FURNACE_COL_R, FURNACE_COL_G, FURNACE_COL_B);
			#endif
			break;
		case 10528: // soul torch
		case 10529:
			#ifdef HARDCODED_SOULTORCH_COL
			lightcol = vec3(SOULTORCH_COL_R, SOULTORCH_COL_G, SOULTORCH_COL_B);
			#endif
			break;
		case 10544: // glow lichen
			#ifdef HARDCODED_LICHEN_COL
			lightcol = vec3(LICHEN_COL_R, LICHEN_COL_G, LICHEN_COL_B);
			#endif
			break;
		case 10548: // enchanting table
			#ifdef HARDCODED_TABLE_COL
			lightcol = vec3(TABLE_COL_R, TABLE_COL_G, TABLE_COL_B);
			#endif
			break;
		case 10556: // end portal frame with eye
			#ifdef HARDCODED_END_COL
			lightcol = vec3(END_COL_R, END_COL_G, END_COL_B);
			#endif
			break;
		case 10560: // lantern
			#ifdef LANTERN_HARDCODED_TORCH_COL
			lightcol = vec3(TORCH_COL_R, TORCH_COL_G, TORCH_COL_B);
			#endif
			break;
		case 10564: // soul lantern
			#ifdef LANTERN_HARDCODED_SOULTORCH_COL
			lightcol = vec3(SOULTORCH_COL_R, SOULTORCH_COL_G, SOULTORCH_COL_B);
			#endif
			break;
		case 10572: // dragon egg
			#ifdef HARDCODED_DRAGON_COL
			lightcol = vec3(DRAGON_COL_R, DRAGON_COL_G, DRAGON_COL_B);
			#endif
			break;
		case 10576: // lit smoker
			#ifdef HARDCODED_FURNACE_COL
			lightcol = vec3(FURNACE_COL_R, FURNACE_COL_G, FURNACE_COL_B);
			#endif
			break;
		case 10580: // lit blast furnace
			#ifdef HARDCODED_FURNACE_COL
			lightcol = vec3(FURNACE_COL_R, FURNACE_COL_G, FURNACE_COL_B);
			#endif
			break;
		case 10584: // lit candles
			#ifdef HARDCODED_CANDLE_COL
			lightcol = vec3(CANDLE_COL_R, CANDLE_COL_G, CANDLE_COL_B);
			#endif
			break;
		case 10592: // respawn anchor
			#ifdef ANCHOR_HARDCODED_PORTAL_COL
			lightcol = vec3(PORTAL_COL_R, PORTAL_COL_G, PORTAL_COL_B);
			#endif
			break;
		case 10596: // redstone wire
		case 10597:
		case 10598:
		case 10599:
			#ifdef WIRE_HARDCODED_REDSTONE_COL
			lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
			#endif
			break;
		case 12604: // lit redstone torch
		case 12605:
			#ifdef TORCH_HARDCODED_REDSTONE_COL
			lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
			#endif
			break;
		case 10632: // glow berries
			#ifdef HARDCODED_BERRY_COL
			lightcol = vec3(BERRY_COL_R, BERRY_COL_G, BERRY_COL_B);
			#endif
			break;
		case 10640: // lit redstone lamp
			#ifdef HARDCODED_REDSTONELAMP_COL
			lightcol = vec3(REDSTONELAMP_COL_R, REDSTONELAMP_COL_G, REDSTONELAMP_COL_B);
			#endif
			break;
		case 10648: // shroomlight
			#ifdef HARDCODED_SHROOMLIGHT_COL
			lightcol = vec3(SHROOMLIGHT_COL_R, SHROOMLIGHT_COL_G, SHROOMLIGHT_COL_B);
			#endif
			break;
		case 10680: // ochre froglight
			#ifdef HARDCODED_YELLOWFROG_COL
			lightcol = vec3(YELLOWFROG_COL_R, YELLOWFROG_COL_G, YELLOWFROG_COL_B);
			#endif
			break;
		case 10684: // verdant froglight
			#ifdef HARDCODED_GREENFROG_COL
			lightcol = vec3(GREENFROG_COL_R, GREENFROG_COL_G, GREENFROG_COL_B);
			#endif
			break;
		case 10688: // pearlescent froglight
			#ifdef HARDCODED_PINKFROG_COL
			lightcol = vec3(PINKFROG_COL_R, PINKFROG_COL_G, PINKFROG_COL_B);
			#endif
			break;
		case 10705: // active sculk sensor
			#ifdef HARDCODED_SCULK_COL
			lightcol = vec3(SCULK_COL_R, SCULK_COL_G, SCULK_COL_B);
			#endif
			break;
		case 10708: // spawner
			#ifdef HARDCODED_SPAWNER_COL
			lightcol = vec3(SPAWNER_COL_R, SPAWNER_COL_G, SPAWNER_COL_B);
			#endif
			break;
		case 10836: // brewing stand
			#ifdef HARDCODED_BREWINGSTAND_COL
			lightcol = vec3(BREWINGSTAND_COL_R, BREWINGSTAND_COL_G, BREWINGSTAND_COL_B);
			#endif
			break;
		case 12740: // lit candle cake
			#ifdef CAKE_HARDCODED_CANDLE_COL
			lightcol = vec3(CANDLE_COL_R, CANDLE_COL_G, CANDLE_COL_B);
			#endif
			break;
		case 30020: // nether portal
			#ifdef HARDCODED_PORTAL_COL
			lightcol = vec3(PORTAL_COL_R, PORTAL_COL_G, PORTAL_COL_B);
			#endif
			break;
		case 31016: // beacon
			#ifdef HARDCODED_BEACON_COL
			lightcol = vec3(BEACON_COL_R, BEACON_COL_G, BEACON_COL_B);
			#endif
			break;
		case 60000: // end portal
			#ifdef PORTAL_HARDCODED_END_COL
			lightcol = vec3(END_COL_R, END_COL_G, END_COL_B);
			#endif
			break;
		case 60012: // ender chest
			#ifdef CHEST_HARDCODED_END_COL
			lightcol = vec3(END_COL_R, END_COL_G, END_COL_B);
			#endif
			break;
		case 60020: // conduit
			#ifdef HARDCODED_CONDUIT_COL
			lightcol = vec3(CONDUIT_COL_R, CONDUIT_COL_G, CONDUIT_COL_B);
			#endif
			break;
		case 50000: // end crystal
			#ifdef HARDCODED_ENDCRYSTAL_COL
			lightcol = vec3(ENDCRYSTAL_COL_R, ENDCRYSTAL_COL_G, ENDCRYSTAL_COL_B);
			#endif
			break;
		case 50004: // lightning bolt
			#ifdef HARDCODED_LIGHTNING_COL
			lightcol = vec3(LIGHTNING_COL_R, LIGHTNING_COL_G, LIGHTNING_COL_B);
			#endif
			break;
		case 50012: // glow item frame
			#ifdef HARDCODED_ITEMFRAME_COL
			lightcol = vec3(ITEMFRAME_COL_R, ITEMFRAME_COL_G, ITEMFRAME_COL_B);
			#endif
			break;
		case 50020: // blaze
			#ifdef HARDCODED_BLAZE_COL
			lightcol = vec3(BLAZE_COL_R, BLAZE_COL_G, BLAZE_COL_B);
			#endif
			break;
		case 50048: // glow squid
			#ifdef HARDCODED_SQUID_COL
			lightcol = vec3(SQUID_COL_R, SQUID_COL_G, SQUID_COL_B);
			#endif
			break;
		case 50080: // allay
			#ifdef HARDCODED_ALLAY_COL
			lightcol = vec3(ALLAY_COL_R, ALLAY_COL_G, ALLAY_COL_B);
			#endif
			break;
		case 50116: // TNT
			#ifdef HARDCODED_TNT_COL
			lightcol = vec3(TNT_COL_R, TNT_COL_G, TNT_COL_B);
			#endif
			break;
	}
	return lightcol;
}

bool badPixel(vec4 color, vec4 glColor, int mat) {
	switch(mat) {
		case 4431:
		case 4432:
			if (color.g > max(color.r, color.b) + 0.05 && length(glColor.rgb - vec3(1)) < 0.1) {
				return true;
			}
			break;
	}
	return false;
}