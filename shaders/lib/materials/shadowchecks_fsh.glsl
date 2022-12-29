#include "/lib/materials/lightColorSettings.glsl"

// needs bool emissive, alphatest, crossmodel, cuboid, full, entity; vec3 lightcol; ivec3[2] bounds (in 1/16 blocks); int mat

connectSides = false;
//entities
entity = (mat / 10000 == 5);
//exclude from ray tracing
notrace = (
    entity ||
    mat == 10072 ||
    mat == 10076 ||
    mat == 10012 ||
    mat == 10041 ||
    mat == 10083 ||
    mat == 12156 ||
    mat == 12164 ||
    mat == 12172 ||
    mat == 12180 ||
    mat == 12188 ||
    mat == 12196 ||
    mat == 12204 ||
    mat == 12212 ||
    mat == 12220 ||
    mat == 12264 ||
    mat == 12312 ||
    mat == 12480 ||
    (mat >= 10596 && mat <= 10600) ||
    mat == 10544 ||
    mat == 12696 ||
    mat == 10732
);
//translucent / alpha cutout blocks:
alphatest = (
    mat == 10000 ||
    mat == 10004 ||
    mat == 10008 ||
    mat == 10016 ||
    mat == 10020 ||
    mat == 10041 ||
    mat == 10072 ||
    mat == 10076 ||
    mat == 12112 ||
    mat == 10157 ||
    mat == 12157 ||
    mat == 10165 ||
    mat == 12165 ||
    mat == 10173 ||
    mat == 12173 ||
    mat == 10181 ||
    mat == 12181 ||
    mat == 10189 ||
    mat == 12189 ||
    mat == 10197 ||
    mat == 12197 ||
    mat == 10205 ||
    mat == 12205 ||
    mat == 10213 ||
    mat == 12213 ||
    mat == 10221 ||
    mat == 12221 ||
    (mat >= 14156 && mat < 14224) ||
    mat == 10256 ||
    (mat >= 14260 && mat < 14264) ||
    mat == 10265 ||
    mat == 12265 ||
    (mat >= 14264 && mat < 14268) ||
    mat == 10544 ||
    mat == 10596 ||
    mat == 10600 ||
    mat == 10708 ||
    (mat >= 10720 && mat < 10724) ||
    (mat / 10000 == 3 && mat != 31016)
);
//light sources
emissive = (
    mat == 1234  || // generic light source
    mat == 10024 || // brewing stand
    mat == 10056 || // lava cauldron
    mat == 10068 || // lava
    mat == 10072 || // fire
    mat == 10076 || // soul fire
    mat == 10216 || // crimson wood
    mat == 10224 || // warped wood
#if GLOWING_ORES > 0
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
#ifdef GLOWING_MINERAL_BLOCKS
    mat == 10336 || // emerald block
    mat == 10352 || // lapis block
    mat == 10608 || // redstone block
#endif
    mat == 10332 || // amethyst buds
    mat == 10388 || // blue ice
    mat == 10396 || // jack o'lantern
    mat == 10400 || // 1-2 waterlogged sea pickles
    mat == 10401 || // 3-4 waterlogged sea pickles
    mat == 10412 || // glowstone
    mat == 10448 || // sea lantern
    mat == 10452 || // magma block
    mat == 10476 || // crying obsidian
    mat == 10496 || // torch
    mat == 10500 || // end rod
    mat == 10501 ||
    mat == 10502 ||
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
    mat == 10597 ||
    mat == 10598 ||
    mat == 10599 ||
    mat == 12604 || // lit redstone torch
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
    mat == 12740 || // lit candle cake
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
    mat == 50080    // allay
);
if (emissive) {
    switch (mat) {
        case 10024: // brewing stand
            #ifdef HARDCODED_BREWINGSTAND_COL
            lightcol = vec3(BREWINGSTAND_COL_R, BREWINGSTAND_COL_G, BREWINGSTAND_COL_B);
            #endif
            break;
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
        case 10616:
        case 10620:
        case 10624:
            #ifdef ORE_HARDCODED_REDSTONE_COL
            lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
            #endif
            break;
    #endif
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
    }
    switch (mat) {
        case 1234:
            lightlevel = int(24 * lmCoord.x);
            break;
        case 10024: // brewing stand
            lightlevel = BRIGHTNESS_BREWINGSTAND;
            break;
        case 10056: // lava cauldron
            lightlevel = CAULDRON_BRIGHTNESS_LAVA;
            break;
        case 10068: // lava
            lightlevel = BRIGHTNESS_LAVA;
            break;
        case 10072: // fire
            lightlevel = BRIGHTNESS_FIRE;
            break;
        case 10076: // soul fire
            lightlevel = BRIGHTNESS_SOULFIRE;
            break;
        case 10216: // crimson wood
            lightlevel = BRIGHTNESS_CRIMSON;
            break;
        case 10224: // warped wood
            lightlevel = BRIGHTNESS_WARPED;
            break;
    #if GLOWING_ORES > 0
        case 10272: // iron ore
        case 10276:
            lightlevel = ORE_BRIGHTNESS_IRON;
            break;
        case 10284: // copper ore
        case 10288:
            lightlevel = ORE_BRIGHTNESS_COPPER;
            break;
        case 10300: // gold ore
        case 10304:
            lightlevel = ORE_BRIGHTNESS_GOLD;
            break;
        case 10320: // diamond ore
        case 10324:
            lightlevel = ORE_BRIGHTNESS_DIAMOND;
            break;
        case 10340: // emerald ore
        case 10344:
            lightlevel = ORE_BRIGHTNESS_EMERALD;
            break;
        case 10356: // lapis ore
        case 10360:
            lightlevel = ORE_BRIGHTNESS_LAPIS;
            break;
        case 10612: // unlit redstone ore
        case 10620:
            lightlevel = OREUNLIT_BRIGHTNESS_REDSTONE;
            break;
        case 10616:
        case 10624:
            lightlevel = ORELIT_BRIGHTNESS_REDSTONE;
            break;
    #endif
    #ifdef GLOWING_MINERAL_BLOCKS
        case 10336: // emerald block
            lightlevel = BLOCK_BRIGHTNESS_EMERALD;
            break;
        case 10352: // lapis block
            lightlevel = BLOCK_BRIGHTNESS_LAPIS;
            break;
        case 10608: // redstone block
            lightlevel = BLOCK_BRIGHTNESS_REDSTONE;
            break;
    #endif
        case 10332: // amethyst buds
            lightlevel = BRIGHTNESS_AMETHYST;
            break;
        case 10388: // blue ice
            lightlevel = BRIGHTNESS_ICE;
            break;
        case 10396: // jack o'lantern
            lightlevel = BRIGHTNESS_PUMPKIN;
            break;
        case 10400: // 1-2 waterlogged sea pickles
            lightlevel = LOW_BRIGHTNESS_PICKLE;
            break;
        case 10401: // 3-4 waterlogged sea pickles
            lightlevel = HIGH_BRIGHTNESS_PICKLE;
            break;
        case 10412: // glowstone
            lightlevel = BRIGHTNESS_GLOWSTONE;
            break;
        case 10448: // sea lantern
            lightlevel = BRIGHTNESS_SEALANTERN;
            break;
        case 10452: // magma block
            lightlevel = BRIGHTNESS_MAGMA;
            break;
        case 10476: // crying obsidian
            lightlevel = BRIGHTNESS_CRYING;
            break;
        case 10496: // torch
            lightlevel = BRIGHTNESS_TORCH;
            break;
        case 10500: // end rod
        case 10501:
        case 10502:
            lightlevel = BRIGHTNESS_ENDROD;
            break;
        case 10508: // chorus flower
            lightlevel = BRIGHTNESS_CHORUS;
            break;
        case 10516: // lit furnace
            lightlevel = BRIGHTNESS_FURNACE;
            break;
        case 10528: // soul torch
            lightlevel = BRIGHTNESS_SOULTORCH;
            break;
        case 10544: // glow lichen
            lightlevel = BRIGHTNESS_LICHEN;
            break;
        case 10548: // enchanting table
            lightlevel = BRIGHTNESS_TABLE;
            break;
        case 10556: // end portal frame with eye
            lightlevel = FRAME_BRIGHTNESS_END;
            break;
        case 10560: // lantern
            lightlevel = LANTERN_BRIGHTNESS_TORCH;
            break;
        case 10564: // soul lantern
            lightlevel = LANTERN_BRIGHTNESS_SOULTORCH;
            break;
        case 10572: // dragon egg
            lightlevel = BRIGHTNESS_DRAGON;
            break;
        case 10576: // lit smoker
            lightlevel = BRIGHTNESS_FURNACE;
            break;
        case 10580: // lit blast furnace
            lightlevel = BRIGHTNESS_FURNACE;
            break;
        case 10584: // lit candles
            lightlevel = BRIGHTNESS_CANDLE;
            break;
        case 10592: // respawn anchor
            lightlevel = ANCHOR_BRIGHTNESS_PORTAL;
            break;
        case 10596: // redstone wire
            lightlevel = WIRE0_BRIGHTNESS_REDSTONE;
            break;
        case 10597:
            lightlevel = WIRE1_BRIGHTNESS_REDSTONE;
            break;
        case 10598:
            lightlevel = WIRE2_BRIGHTNESS_REDSTONE;
            break;
        case 10599:
            lightlevel = WIRE3_BRIGHTNESS_REDSTONE;
            break;
        case 12604: // lit redstone torch
            lightlevel = TORCH_BRIGHTNESS_REDSTONE;
            break;
        case 10632: // glow berries
            lightlevel = BRIGHTNESS_BERRY;
            break;
        case 10640: // lit redstone lamp
            lightlevel = BRIGHTNESS_REDSTONELAMP;
            break;
        case 10648: // shroomlight
            lightlevel = BRIGHTNESS_SHROOMLIGHT;
            break;
        case 10652: // lit campfire
            lightlevel = CAMPFIRE_BRIGHTNESS_FIRE;
            break;
        case 10656: // lit soul campfire
            lightlevel = CAMPFIRE_BRIGHTNESS_SOULFIRE;
            break;
        case 10680: // ochre froglight
            lightlevel = BRIGHTNESS_YELLOWFROG;
            break;
        case 10684: // verdant froglight
            lightlevel = BRIGHTNESS_GREENFROG;
            break;
        case 10688: // pearlescent froglight
            lightlevel = BRIGHTNESS_PINKFROG;
            break;
        case 10705: // active sculk sensor
            lightlevel = SENSOR_BRIGHTNESS_SCULK;
            break;
        case 10708: // spawner
            lightlevel = BRIGHTNESS_SPAWNER;
            break;
        case 12740: // lit candle cake
            lightlevel = CAKE_BRIGHTNESS_CANDLE;
            break;
        case 30020: // nether portal
            lightlevel = BRIGHTNESS_PORTAL;
            break;
        case 31016: // beacon
            lightlevel = BRIGHTNESS_BEACON;
            break;
        case 60000: // end portal
            lightlevel = PORTAL_BRIGHTNESS_END;
            break;
        case 60012: // ender chest
            lightlevel = CHEST_BRIGHTNESS_END;
            break;
        case 60020: // conduit
            lightlevel = BRIGHTNESS_CONDUIT;
            break;
        case 50000: // end crystal
            lightlevel = BRIGHTNESS_ENDCRYSTAL;
            break;
        case 50004: // lightning bolt
            lightlevel = BRIGHTNESS_LIGHTNING;
            break;
        case 50012: // glow item frame
            lightlevel = BRIGHTNESS_ITEMFRAME;
            break;
        case 50020: // blaze
            lightlevel = BRIGHTNESS_BLAZE;
            break;
        case 50048: // glow squid
            lightlevel = BRIGHTNESS_SQUID;
            break;
        case 50080: // allay
            lightlevel = BRIGHTNESS_ALLAY;
            break;
    }
}
//full cubes
full = (
    mat == 10008 ||
    mat == 10028 ||
    mat == 10032 ||
    mat == 10080 ||
    mat == 10084 ||
    mat == 10088 ||
    mat == 10092 ||
    mat == 10096 ||
    mat == 10100 ||
    mat == 10104 ||
    mat == 10108 ||
    mat == 10112 ||
    mat == 12112 ||
    mat == 10116 ||
    mat == 10120 ||
    mat == 10124 ||
    mat == 10128 ||
    mat == 10132 ||
    mat == 10140 ||
    mat == 10144 ||
    mat == 10148 ||
    mat == 10152 ||
    mat == 10156 ||
    mat == 10160 ||
    mat == 10164 ||
    mat == 10168 ||
    mat == 10172 ||
    mat == 10176 ||
    mat == 10180 ||
    mat == 10184 ||
    mat == 10188 ||
    mat == 10192 ||
    mat == 10196 ||
    mat == 10200 ||
    mat == 10204 ||
    mat == 10208 ||
    mat == 10212 ||
    mat == 10216 ||
    mat == 10220 ||
    (mat > 10223 && mat < 10240) ||
    mat == 10240 ||
    mat == 10244 ||
    mat == 10248 ||
    mat == 10252 ||
    mat == 10264 ||
    (mat > 10267 && mat < 10292) ||
    mat == 10292 ||
    (mat > 10295 && mat < 10312) ||
    (mat > 10315 && mat < 10332) ||
    mat == 10336 ||
    mat == 10340 ||
    mat == 10344 ||
    mat == 10352 ||
    mat == 10356 ||
    mat == 10360 ||
    mat == 10364 ||
    mat == 10368 ||
    mat == 10372 ||
    mat == 10376 ||
    mat == 10380 ||
    mat == 12380 ||
    mat == 10384 ||
    mat == 10388 ||
    mat == 10392 ||
    mat == 10396 ||
    mat == 10404 ||
    mat == 10408 ||
    mat == 10412 ||
    mat == 10416 ||
    mat == 10420 ||
    mat == 10424 ||
    mat == 10428 ||
    mat == 10432 ||
    mat == 10436 ||
    mat == 10440 ||
    mat == 10444 ||
    mat == 10448 ||
    mat == 10452 ||
    mat == 10456 ||
    mat == 10460 ||
    mat == 10464 ||
    mat == 10468 ||
    mat == 10476 ||
    mat == 10480 ||
    mat == 10484 ||
    mat == 10516 ||
    mat == 10524 ||
    mat == 10532 ||
    mat == 10536 ||
    mat == 10540 ||
    mat == 10576 ||
    mat == 10580 ||
    mat == 10588 ||
    mat == 10592 ||
    (mat > 10607 && mat < 10628) ||
    mat == 10636 ||
    mat == 10640 ||
    mat == 10648 ||
    mat == 10664 ||
    mat == 10668 ||
    (mat >= 10672 && mat < 10697) ||
    mat == 10700 ||
    mat == 10708 ||
    mat == 10712 ||
    mat == 10716 ||
    mat == 10724 ||
    mat == 30000 ||
    mat == 30008 ||
    mat == 30012 ||
    mat == 30016 ||
    mat == 31004 ||
    mat == 31008 ||
    mat == 60000 ||
    mat == 60016
);
crossmodel = (
    mat == 10000 ||
    mat == 10004 ||
    mat == 10016 ||
    mat == 10020 ||
    mat == 10072 ||
    mat == 10076 ||
    mat == 10123 ||
    mat == 10332 ||
    mat == 10492 ||
    mat == 10628 ||
    mat == 10632
);
cuboid = (
    (mat > 10032 && mat < 10036) ||
    mat == 10045 ||
    mat == 10046 ||
    mat == 10060 ||
    mat == 10064 ||
    mat == 10068 ||
    (mat > 10080 && mat < 10084) ||
    (mat > 10084 && mat < 10088) ||
    (mat > 10088 && mat < 10092) ||
    (mat > 10092 && mat < 10096) ||
    (mat > 10096 && mat < 10100) ||
    (mat > 10100 && mat < 10104) ||
    (mat > 10104 && mat < 10108) ||
    (mat > 10108 && mat < 10112) ||
    (mat > 10112 && mat < 10116) ||
    mat == 10121 ||
    mat == 10129 ||
    mat == 10137 ||
    (mat > 10152 && mat < 10156) ||
    (mat >= 12152 && mat < 12156) ||
    (mat >= 14152 && mat < 14156) ||
    (mat >= 16152 && mat < 16156) ||
    (mat > 10156 || mat < 10160) ||
    mat == 12157 ||
    (mat >= 14156 && mat < 14160) ||
    (mat > 10164 || mat < 10168) ||
    mat == 12165 ||
    (mat >= 14164 && mat < 14168) ||
    (mat > 10172 || mat < 10176) ||
    mat == 12173 ||
    (mat >= 14172 && mat < 14176) ||
    (mat > 10180 || mat < 10184) ||
    mat == 12181 ||
    (mat >= 14180 && mat < 14184) ||
    (mat > 10188 || mat < 10192) ||
    mat == 12189 ||
    (mat >= 14188 && mat < 14192) ||
    (mat > 10196 || mat < 10200) ||
    mat == 12197 ||
    (mat >= 14196 && mat < 14200) ||
    (mat > 10204 || mat < 10208) ||
    mat == 12205 ||
    (mat >= 14204 && mat < 14208) ||
    (mat > 10212 || mat < 10216) ||
    mat == 12213 ||
    (mat >= 14212 && mat < 14216) ||
    (mat > 10220 || mat < 10224) ||
    mat == 12221 ||
    (mat > 14220 && mat < 14224) ||
    (mat > 10240 || mat < 10244) ||
    (mat > 10244 || mat < 10248) ||
    mat == 10256 ||
    (mat >= 14260 && mat < 14264) ||
    mat == 10265 ||
    mat == 12265 ||
    (mat >= 14264 && mat < 14268) ||
    (mat > 10292 && mat < 10296) ||
    (mat >= 12292 && mat < 12296) ||
    mat == 10313 ||
    mat == 10350 ||
    (mat > 10364 && mat < 10368) ||
    (mat > 10376 && mat < 10380) ||
    mat == 10381 ||
    mat == 10400 ||
    mat == 10401 ||
    mat == 10402 ||
    mat == 10403 ||
    (mat > 10416 && mat < 10420) ||
	mat == 12416 ||
    (mat > 10420 && mat < 10424) ||
    (mat > 10428 && mat < 10432) ||
    (mat > 10440 && mat < 10444) ||
    (mat > 10444 && mat < 10448) ||
    (mat > 10480 && mat < 10484) ||
    mat == 10488 ||
    mat == 10496 ||
    mat == 10500 ||
    mat == 10501 ||
    mat == 10502 ||
    mat == 10504 ||
    mat == 10508 ||
    mat == 10512 ||
    mat == 10520 ||
    mat == 10528 ||
    mat == 10548 ||
    mat == 10552 ||
    mat == 10556 ||
    mat == 10560 ||
    mat == 10564 ||
    (mat > 10564 && mat < 10568) ||
    mat == 10568 ||
    mat == 10569 ||
    mat == 10584 ||
    mat == 11584 ||
    mat == 10596 ||
    mat == 10600 ||
    mat == 10604 ||
    mat == 12604 ||
    mat == 10644 ||
    mat == 10656 ||
    mat == 10660 ||
    mat == 10669 ||
    mat == 10697 ||
    mat == 10705 ||
    (mat >= 10720 && mat < 10724) ||
    mat == 10728 ||
    (mat >= 10740 && mat < 10749) ||
	mat == 30004 ||
    mat == 31012 ||
    mat == 31000 ||
    mat == 31016 ||
    mat == 60008 ||
    mat == 60012 ||
    mat == 60017 
);
if (cuboid) {
    switch (mat) {
        case 10045:
        case 10048:
        case 10052:
        case 10056:
            bounds[1].y = 15;
            break;
        case 10596:
        case 10600:
            bounds[1].y = 2;
            break;
        case 10060:
            bounds[0] = ivec3(7, 0, 7);
            bounds[1] = ivec3(9, 16, 9);
            break;
        case 10064:
            bounds[0] = ivec3(4, 0, 4);
            bounds[1] = ivec3(12, 14, 12);
            break;
        case 10068:
        case 10548:
        case 10552:
        case 10556:
        case 31000:
            bounds[1].y = int(16*fract(pos.y + 0.03125));
            break;
        case 10129:
            bounds[1].y = 15;
            break;
        case 10256:
		case 30004:
        case 31012:
			connectSides = true;
            bounds[0] = ivec3(7, 0, 7);
            bounds[1] = ivec3(9, 16, 9);
            break;
        case 10313:
            bounds[0] = ivec3(5, 3, 5);
            bounds[1] = ivec3(11, 13, 11);
            break;
        case 10400:
        case 10402:
        case 10568:
            bounds[0] = ivec3(6, 0, 6);
            bounds[1] = ivec3(10, 6, 10);
            break;
        case 10401:
        case 10403:
        case 10569:
            bounds[0] = ivec3(3, 0, 3);
            bounds[1] = ivec3(13, 6, 13);
            break;
		case 12416:
			connectSides = true;
			bounds[0].xz = ivec2(6);
			bounds[1].xz = ivec2(10);
        case 10488:
            bounds[0] = ivec3(3, 0, 3);
            bounds[1] = ivec3(13, 1, 13);
            break;
        case 10500:
        case 12292:
            bounds[0].xz = ivec2(7);
            bounds[1].xz = ivec2(9);
            break;
        case 10501:
        case 12293:
            bounds[0].yz = ivec2(7);
            bounds[1].yz = ivec2(9);
            break;
        case 10502:
        case 12294:
            bounds[0].xy = ivec2(7);
            bounds[1].xy = ivec2(9);
            break;
        case 10504:
            bounds[0] = ivec3(4);
            bounds[1] = ivec3(12);
            break;
        case 10508:
        case 10512:
            bounds[0] = ivec3(1);
            bounds[1] = ivec3(15);
            break;
        case 10520:
            bounds[0].xz = ivec2(1);
            bounds[1].xz = ivec2(15);
            break;
        case 10560:
        case 10564:
            bounds[0] = ivec3(5, 1, 5);
            bounds[1] = ivec3(11, 7, 11);
            break;
        case 10565:
            bounds[0].yz = ivec2(7);
            bounds[1].yz = ivec2(9);
            break;
        case 10566:
            bounds[0].xz = ivec2(7);
            bounds[1].xz = ivec2(9);
            break;
        case 10567:
            bounds[0].xy = ivec2(7);
            bounds[1].xy = ivec2(9);
            break;
        case 10656:
        case 10660:
            bounds[1].y = 8;
            break;
        case 10584:
        case 11584:
            bounds[0] = ivec3(6, 0, 6);
            bounds[1] = ivec3(10, 6, 10);
            break;
        case 12152:
            bounds[0].y = 12;
            break;
        case 12154:
            bounds[0].y = 4;
            break;
        case 14152:
            bounds[0].z = 12;
            break;
        case 14153:
            bounds[1].z = 4;
            break;
        case 14154:
            bounds[1].x = 4;
            break;
        case 14155:
            bounds[0].x = 12;
            break;
        case 16152:
            bounds[0].z = 4;
            break;
        case 16153:
            bounds[1].z = 12;
            break;
        case 16154:
            bounds[1].x = 12;
            break;
        case 16155:
            bounds[0].x = 4;
            break;
        case 10496:
        case 10528:
        case 10604:
        case 12604:
            bounds[0] = ivec3(7, 0, 7);
            bounds[1] = ivec3(9, 10, 9);
            break;
        case 10644:
            bounds[1].y = 3;
            break;
        case 12153:
        case 10669:
            bounds[1].y = 1;
            break;
        case 10720:
            bounds[0].z = 12;
            break;
        case 10721:
            bounds[1].z = 4;
            break;
        case 10722:
            bounds[1].x = 4;
            break;
        case 10723:
            bounds[0].x = 12;
            break;
        case 10728:
            bounds[0] = ivec3(5, 0, 5);
            bounds[1] = ivec3(11, 6, 11);
            break;
        case 10740:
        case 12740:
            bounds[0] = ivec3(1, 0, 1);
            bounds[1] = ivec3(15, 8, 15);
            break;
        case 10741:
            bounds[0] = ivec3(3, 0, 1);
            bounds[1] = ivec3(15, 8, 15);
            break;
        case 10742:
            bounds[0] = ivec3(5, 0, 1);
            bounds[1] = ivec3(15, 8, 15);
            break;
        case 10743:
            bounds[0] = ivec3(7, 0, 1);
            bounds[1] = ivec3(15, 8, 15);
            break;
        case 10744:
            bounds[0] = ivec3(9, 0, 1);
            bounds[1] = ivec3(15, 8, 15);
            break;
        case 10745:
            bounds[0] = ivec3(11, 0, 1);
            bounds[1] = ivec3(15, 8, 15);
            break;
        case 10746:
            bounds[0] = ivec3(13, 0, 1);
            bounds[1] = ivec3(15, 8, 15);
            break;
        case 31016:
            bounds[0] = ivec3(2, 0, 2);
            bounds[1] = ivec3(14, 14, 14);
            break;
        case 60008:
        case 60012:
            bounds[0] = ivec3(1, 0, 1);
            bounds[1] = ivec3(15, 14, 15);
            break;
        case 60017:
            bounds[0].y = 3;
            bounds[1].y = 9;
            break;
        default:
            if ((mat % 10000) / 2000 == 0) {
                switch (mat % 4) {
                    case 1:
                        bounds[1].y = int(16*fract(pos.y + 0.03125));
                        break;
                    case 2:
                        bounds[0].y = 8;
                        break;
                    case 3:
						switch (mat) {
							case 10035:
							case 10087:
							case 10091:
							case 10095:
							case 10107:
							case 10111:
							case 10115:
							case 10155:
							case 10243:
							case 10247:
							case 10419:
							case 10423:
							case 10431:
							case 10443:
							case 10483:
								connectSides = true;
								bounds[0].xz = ivec2(4);
								bounds[1].xz = ivec2(12);
								break;
							case 10159:
							case 10167:
							case 10175:
							case 10183:
							case 10191:
							case 10199:
							case 10207:
							case 10215:
							case 10223:
								connectSides = true;
								bounds[0].xz = ivec2(6);
								bounds[1].xz = ivec2(10);
								break;
							default:
								bounds[0].xz = ivec2(6);
								bounds[1].xz = ivec2(10);
								break;
						}
						break;
                }
            } else if ((mat % 10000) / 2000 == 1) {
                if (mat % 4 == 1) bounds[0].y = 13;
            } else if ((mat % 10000) / 2000 == 2) {
                switch(mat % 4) {
                    case 0:
                        bounds[0].z = 13;
                        break;
                    case 1:
                        bounds[1].z = 3;
                        break;
                    case 2:
                        bounds[1].x = 3;
                        break;
                    case 3:
                        bounds[0].x = 13;
                        break;
                }
            }
    }
}