// needs alphatest, bounds, connectSides, crossmodel, cuboid, emissive, entity, full, lightcol, lightlevel, notrace
#include "/lib/materials/lightColorSettings.glsl"
full = false;
alphatest = false;
emissive = false;
notrace = false;
crossmodel = false;
cuboid = false;
connectSides = false;
entity = (mat / 10000 == 5);
if (entity) notrace = true;
if (mat / 10000 == 3 && mat != 31016) alphatest = true;
if (mat > 1000) {
	if (mat < 10501) {
		if (mat < 10214) {
			if (mat < 10112) {
				if (mat < 10084) {
					if (mat < 10045) {
						if (mat < 10024) {
							if (mat < 10008) {
								if (mat < 10000) {
									// 1234: adorn:stone_torch blockus:white_redstone_lamp:lit=true blockus:orange_redstone_lamp:lit=true blockus:magenta_redstone_lamp:lit=true blockus:light_blue_redstone_lamp:lit=true blockus:yellow_redstone_lamp:lit=true blockus:lime_redstone_lamp:lit=true blockus:pink_redstone_lamp:lit=true blockus:gray_redstone_lamp:lit=true blockus:light_gray_redstone_lamp:lit=true blockus:cyan_redstone_lamp:lit=true blockus:purple_redstone_lamp:lit=true blockus:blue_redstone_lamp:lit=true blockus:brown_redstone_lamp:lit=true blockus:green_redstone_lamp:lit=true blockus:red_redstone_lamp:lit=true blockus:white_redstone_lamp_lit blockus:orange_redstone_lamp_lit blockus:magenta_redstone_lamp_lit blockus:light_blue_redstone_lamp_lit blockus:yellow_redstone_lamp_lit blockus:lime_redstone_lamp_lit blockus:pink_redstone_lamp_lit blockus:gray_redstone_lamp_lit blockus:light_gray_redstone_lamp_lit blockus:cyan_redstone_lamp_lit blockus:purple_redstone_lamp_lit blockus:blue_redstone_lamp_lit blockus:brown_redstone_lamp_lit blockus:green_redstone_lamp_lit blockus:red_redstone_lamp_lit
									emissive = true;
									lightlevel = int(24 * lmCoord.x);
								} else {
									if (mat < 10004) {
										// 10000: big_dripleaf_stem big_dripleaf small_dripleaf
										alphatest = true;
										crossmodel = true;
									} else {
										// 10004: grass fern oak_sapling spruce_sapling birch_sapling jungle_sapling acacia_sapling dark_oak_sapling bamboo_sapling dead_bush dandelion poppy blue_orchid allium azure_bluet red_tulip orange_tulip white_tulip pink_tulip oxeye_daisy cornflower lily_of_the_valley wither_rose sweet_berry_bush wheat carrots potatoes beetroots pumpkin_stem melon_stem nether_sprouts warped_roots crimson_roots sunflower:half=lower lilac:half=lower rose_bush:half=lower peony:half=lower tall_grass:half=lower large_fern:half=lower red_mushroom brown_mushroom nether_wart
										alphatest = true;
										crossmodel = true;
									}
								}
							} else {
								if (mat < 10016) {
									if (mat < 10012) {
										// 10008: oak_leaves spruce_leaves birch_leaves jungle_leaves acacia_leaves dark_oak_leaves azalea_leaves flowering_azalea_leaves mangrove_leaves
										alphatest = true;
										full = true;
									} else {
										// 10012: vine
										notrace = true;
									}
								} else {
									if (mat < 10020) {
										// 10016: attached_pumpkin_stem attached_melon_stem mangrove_propagule seagrass tall_seagrass kelp_plant kelp hanging_roots sugar_cane cobweb spore_blossom
										alphatest = true;
										crossmodel = true;
									} else {
										// 10020: sunflower:half=upper lilac:half=upper rose_bush:half=upper peony:half=upper tall_grass:half=upper large_fern:half=upper
										alphatest = true;
										crossmodel = true;
									}
								}
							}
						} else {
							if (mat < 10033) {
								if (mat < 10028) {
									// 10024: brewing_stand
									emissive = true;
									#ifdef HARDCODED_BREWINGSTAND_COL
									lightcol = vec3(BREWINGSTAND_COL_R, BREWINGSTAND_COL_G, BREWINGSTAND_COL_B);
									#endif
									lightlevel = BRIGHTNESS_BREWINGSTAND;
								} else {
									if (mat < 10032) {
										// 10028: hay_block target tnt
										full = true;
									} else {
										// 10032: stone_bricks mossy_stone_bricks cracked_stone_bricks chiseled_stone_bricks mossy_stone_brick_slab:type=double infested_chiseled_stone_bricks infested_cracked_stone_bricks infested_mossy_stone_bricks infested_stone_bricks stone_brick_slab:type=double
										full = true;
									}
								}
							} else {
								if (mat < 10035) {
									if (mat < 10034) {
										// 10033: stone_brick_stairs:half=bottom mossy_stone_brick_stairs:half=bottom mossy_stone_brick_slab:type=bottom stone_brick_slab:type=bottom
										cuboid = true;
									} else {
										// 10034: stone_brick_stairs:half=top mossy_stone_brick_stairs:half=top mossy_stone_brick_slab:type=top stone_brick_slab:type=top
										cuboid = true;
									}
								} else {
									if (mat < 10041) {
										// 10035: mossy_stone_brick_wall stone_brick_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									} else {
										// 10041: powered_rail detector_rail rail activator_rail
										notrace = true;
										alphatest = true;
									}
								}
							}
						}
					} else {
						if (mat < 10068) {
							if (mat < 10052) {
								if (mat < 10046) {
									// 10045: cauldron
									cuboid = true;
									bounds[1].y = 15;
								} else {
									if (mat < 10048) {
										// 10046: hopper
										cuboid = true;
									} else {
										// 10048: water_cauldron
										bounds[1].y = 15;
									}
								}
							} else {
								if (mat < 10060) {
									if (mat < 10056) {
										// 10052: powder_snow_cauldron
										bounds[1].y = 15;
									} else {
										// 10056: lava_cauldron
										emissive = true;
										#ifdef CAULDRON_HARDCODED_LAVA_COL
										lightcol = vec3(LAVA_COL_R, LAVA_COL_G, LAVA_COL_B);
										#endif
										lightlevel = CAULDRON_BRIGHTNESS_LAVA;
										bounds[1].y = 15;
									}
								} else {
									if (mat < 10064) {
										// 10060: bamboo
										cuboid = true;
										bounds[0] = ivec3(7, 0, 7);
										bounds[1] = ivec3(9, 16, 9);
									} else {
										// 10064: lectern
										cuboid = true;
										bounds[0] = ivec3(4, 0, 4);
										bounds[1] = ivec3(12, 14, 12);
									}
								}
							}
						} else {
							if (mat < 10080) {
								if (mat < 10072) {
									// 10068: lava flowing_lava
									emissive = true;
									cuboid = true;
									#ifdef HARDCODED_LAVA_COL
									lightcol = vec3(LAVA_COL_R, LAVA_COL_G, LAVA_COL_B);
									#endif
									lightlevel = BRIGHTNESS_LAVA;
									bounds[1].y = int(16*fract(pos.y + 0.03125));
								} else {
									if (mat < 10076) {
										// 10072: fire
										notrace = true;
										alphatest = true;
										emissive = true;
										crossmodel = true;
										#ifdef HARDCODED_FIRE_COL
										lightcol = vec3(FIRE_COL_R, FIRE_COL_G, FIRE_COL_B);
										#endif
										lightlevel = BRIGHTNESS_FIRE;
									} else {
										// 10076: soul_fire
										notrace = true;
										alphatest = true;
										emissive = true;
										crossmodel = true;
										#ifdef HARDCODED_SOULFIRE_COL
										lightcol = vec3(SOULFIRE_COL_R, SOULFIRE_COL_G, SOULFIRE_COL_B);
										#endif
										lightlevel = BRIGHTNESS_SOULFIRE;
									}
								}
							} else {
								if (mat < 10082) {
									if (mat < 10081) {
										// 10080: stone stone_slab:type=double infested_stone coal_ore smooth_stone smooth_stone_slab:type=double
										full = true;
									} else {
										// 10081: stone_slab:type=bottom smooth_stone_slab:type=bottom stone_stairs:half=bottom stonecutter
										cuboid = true;
									}
								} else {
									if (mat < 10083) {
										// 10082: stone_slab:type=top smooth_stone_slab:type=top stone_stairs:half=top
										cuboid = true;
									} else {
										// 10083: stone_pressure_plate stone_button grindstone
										notrace = true;
										cuboid = true;
									}
								}
							}
						}
					}
				} else {
					if (mat < 10098) {
						if (mat < 10091) {
							if (mat < 10087) {
								if (mat < 10085) {
									// 10084: granite granite_slab:type=double
									full = true;
								} else {
									if (mat < 10086) {
										// 10085: granite_stairs:half=bottom granite_slab:type=bottom
										cuboid = true;
									} else {
										// 10086: granite_stairs:half=top granite_slab:type=top
										cuboid = true;
									}
								}
							} else {
								if (mat < 10089) {
									if (mat < 10088) {
										// 10087: granite_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									} else {
										// 10088: diorite diorite_slab:type=double
										full = true;
									}
								} else {
									if (mat < 10090) {
										// 10089: diorite_stairs:half=bottom diorite_slab:type=bottom
										cuboid = true;
									} else {
										// 10090: diorite_stairs:half=top diorite_slab:type=top
										cuboid = true;
									}
								}
							}
						} else {
							if (mat < 10094) {
								if (mat < 10092) {
									// 10091: diorite_wall
									cuboid = true;
									connectSides = true;
									bounds[0].xz = ivec2(4);
									bounds[1].xz = ivec2(12);
								} else {
									if (mat < 10093) {
										// 10092: andesite andesite_slab:type=double
										full = true;
									} else {
										// 10093: andesite_stairs:half=bottom andesite_slab:type=bottom
										cuboid = true;
									}
								}
							} else {
								if (mat < 10096) {
									if (mat < 10095) {
										// 10094: andesite_stairs:half=top andesite_slab:type=top
										cuboid = true;
									} else {
										// 10095: andesite_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									}
								} else {
									if (mat < 10097) {
										// 10096: polished_granite polished_granite_slab:type=double
										full = true;
									} else {
										// 10097: polished_granite_stairs:half=bottom polished_granite_slab:type=bottom
										cuboid = true;
									}
								}
							}
						}
					} else {
						if (mat < 10105) {
							if (mat < 10101) {
								if (mat < 10099) {
									// 10098: polished_granite_stairs:half=top polished_granite_slab:type=top
									cuboid = true;
								} else {
									if (mat < 10100) {
										// 10099: This case is probably superfluous (not in block.properties)
										cuboid = true;
									} else {
										// 10100: polished_diorite polished_diorite_slab:type=double
										full = true;
									}
								}
							} else {
								if (mat < 10103) {
									if (mat < 10102) {
										// 10101: polished_diorite_stairs:half=bottom polished_diorite_slab:type=bottom
										cuboid = true;
									} else {
										// 10102: polished_diorite_stairs:half=top polished_diorite_slab:type=top
										cuboid = true;
									}
								} else {
									if (mat < 10104) {
										// 10103: This case is probably superfluous (not in block.properties)
										cuboid = true;
									} else {
										// 10104: polished_andesite polished_andesite_slab:type=double packed_mud mud_bricks mud_brick_slab:type=double bricks brick_slab:type=double
										full = true;
									}
								}
							}
						} else {
							if (mat < 10108) {
								if (mat < 10106) {
									// 10105: polished_andesite_stairs:half=bottom polished_andesite_slab:type=bottom mud_brick_stairs:half=bottom mud_brick_slab:type=bottom brick_slab:type=bottom brick_stairs:half=bottom
									cuboid = true;
								} else {
									if (mat < 10107) {
										// 10106: polished_andesite_stairs:half=top polished_andesite_slab:type=top mud_brick_stairs:half=top mud_brick_slab:type=top brick_slab:type=top brick_stairs:half=top
										cuboid = true;
									} else {
										// 10107: mud_brick_wall brick_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									}
								}
							} else {
								if (mat < 10110) {
									if (mat < 10109) {
										// 10108: deepslate cobbled_deepslate infested_deepslate cobbled_deepslate_slab:type=double deepslate_coal_ore
										full = true;
									} else {
										// 10109: cobbled_deepslate_stairs:half=bottom cobbled_deepslate_slab:type=bottom
										cuboid = true;
									}
								} else {
									if (mat < 10111) {
										// 10110: cobbled_deepslate_stairs:half=top cobbled_deepslate_slab:type=top
										cuboid = true;
									} else {
										// 10111: cobbled_deepslate_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									}
								}
							}
						}
					}
				}
			} else {
				if (mat < 10167) {
					if (mat < 10144) {
						if (mat < 10123) {
							if (mat < 10115) {
								if (mat < 10113) {
									// 10112: polished_deepslate deepslate_bricks cracked_deepslate_bricks deepslate_tiles cracked_deepslate_tiles chiseled_deepslate polished_deepslate_slab:type=double deepslate_brick_slab:type=double deepslate_tile_slab:type=double mud muddy_mangrove_roots
									full = true;
								} else {
									if (mat < 10114) {
										// 10113: polished_deepslate_stairs:half=bottom deepslate_brick_stairs:half=bottom deepslate_tile_stairs:half=bottom polished_deepslate_slab:type=bottom deepslate_brick_slab:type=bottom deepslate_tile_slab:type=bottom
										cuboid = true;
									} else {
										// 10114: polished_deepslate_stairs:half=top deepslate_brick_stairs:half=top deepslate_tile_stairs:half=top polished_deepslate_slab:type=top deepslate_brick_slab:type=top deepslate_tile_slab:type=top
										cuboid = true;
									}
								}
							} else {
								if (mat < 10120) {
									if (mat < 10116) {
										// 10115: polished_deepslate_wall deepslate_brick_wall deepslate_tile_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									} else {
										// 10116: calcite
										full = true;
									}
								} else {
									if (mat < 10121) {
										// 10120: dripstone_block
										full = true;
									} else {
										// 10121: daylight_detector
										cuboid = true;
									}
								}
							}
						} else {
							if (mat < 10129) {
								if (mat < 10124) {
									// 10123: pointed_dripstone 
									crossmodel = true;
								} else {
									if (mat < 10128) {
										// 10124: grass_block:snowy=true podzol:snowy=false mycelium:snowy=false
										full = true;
									} else {
										// 10128: dirt coarse_dirt rooted_dirt podzol:snowy=false mycelium:snowy=false 
										full = true;
									}
								}
							} else {
								if (mat < 10137) {
									if (mat < 10132) {
										// 10129: dirt_path farmland:moisture=0 farmland:moisture=1 farmland:moisture=2 farmland:moisture=3 farmland:moisture=4 farmland:moisture=5 farmland:moisture=6
										cuboid = true;
										bounds[1].y = 15;
									} else {
										// 10132: grass_block:snowy=false
										full = true;
									}
								} else {
									if (mat < 10140) {
										// 10137: farmland:moisture=7
										cuboid = true;
									} else {
										// 10140: netherrack
										full = true;
									}
								}
							}
						}
					} else {
						if (mat < 10157) {
							if (mat < 10153) {
								if (mat < 10148) {
									// 10144: warped_nylium warped_wart_block
									full = true;
								} else {
									if (mat < 10152) {
										// 10148: crimson_nylium nether_wart_block
										full = true;
									} else {
										// 10152: cobblestone cobblestone_slab:type=double mossy_cobblestone infested_cobblestone mossy_cobblestone_slab:type=double moss_block furnace:lit=false smoker:lit=false blast_furnace:lit=false lodestone piston:extended=false sticky_piston:extended=false dispenser dropper
										full = true;
									}
								}
							} else {
								if (mat < 10155) {
									if (mat < 10154) {
										// 10153: cobblestone_stairs:half=bottom mossy_cobblestone_stairs:half=bottom cobblestone_slab:type=bottom mossy_cobblestone_slab:type=bottom piston_head:facing=down piston:extended=true:facing=up sticky_piston:extended=true:facing=up
										cuboid = true;
									} else {
										// 10154: cobblestone_stairs:half=top mossy_cobblestone_stairs:half=top cobblestone_slab:type=top mossy_cobblestone_slab:type=top
										cuboid = true;
									}
								} else {
									if (mat < 10156) {
										// 10155: cobblestone_wall mossy_cobblestone_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									} else {
										// 10156: oak_planks stripped_oak_log stripped_oak_wood oak_slab:type=double petrified_oak_slab:type=double bookshelf crafting_table
										full = true;
									}
								}
							}
						} else {
							if (mat < 10160) {
								if (mat < 10158) {
									// 10157: oak_slab:type=bottom petrified_oak_slab:type=bottom oak_stairs:half=bottom oak_trapdoor:half=bottom:open=false
									alphatest = true;
									cuboid = true;
								} else {
									if (mat < 10159) {
										// 10158: oak_slab:type=top petrified_oak_slab:type=top oak_stairs:half=top
										cuboid = true;
									} else {
										// 10159: oak_fence
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(6);
										bounds[1].xz = ivec2(10);
									}
								}
							} else {
								if (mat < 10165) {
									if (mat < 10164) {
										// 10160: oak_log oak_wood
										full = true;
									} else {
										// 10164: spruce_planks stripped_spruce_log stripped_spruce_wood spruce_slab:type=double
										full = true;
									}
								} else {
									if (mat < 10166) {
										// 10165: spruce_slab:type=bottom spruce_stairs:half=bottom spruce_trapdoor:half=bottom:open=false
										alphatest = true;
										cuboid = true;
									} else {
										// 10166: spruce_slab:type=top spruce_stairs:half=top
										cuboid = true;
									}
								}
							}
						}
					}
				} else {
					if (mat < 10190) {
						if (mat < 10180) {
							if (mat < 10173) {
								if (mat < 10168) {
									// 10167: spruce_fence
									cuboid = true;
									connectSides = true;
									bounds[0].xz = ivec2(6);
									bounds[1].xz = ivec2(10);
								} else {
									if (mat < 10172) {
										// 10168: spruce_log spruce_wood
										full = true;
									} else {
										// 10172: birch_planks stripped_birch_log stripped_birch_wood birch_slab:type=double loom fletching_table
										full = true;
									}
								}
							} else {
								if (mat < 10175) {
									if (mat < 10174) {
										// 10173: birch_slab:type=bottom birch_stairs:half=bottom birch_trapdoor:half=bottom:open=false
										alphatest = true;
										cuboid = true;
									} else {
										// 10174: birch_slab:type=top birch_stairs:half=top
										cuboid = true;
									}
								} else {
									if (mat < 10176) {
										// 10175: birch_fence
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(6);
										bounds[1].xz = ivec2(10);
									} else {
										// 10176: birch_log birch_wood
										full = true;
									}
								}
							}
						} else {
							if (mat < 10183) {
								if (mat < 10181) {
									// 10180: jungle_planks stripped_jungle_log stripped_jungle_wood jungle_slab:type=double composter
									full = true;
								} else {
									if (mat < 10182) {
										// 10181: jungle_slab:type=bottom jungle_stairs:half=bottom jungle_trapdoor:half=bottom:open=false
										alphatest = true;
										cuboid = true;
									} else {
										// 10182: jungle_slab:type=top jungle_stairs:half=top
										cuboid = true;
									}
								}
							} else {
								if (mat < 10188) {
									if (mat < 10184) {
										// 10183: jungle_fence
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(6);
										bounds[1].xz = ivec2(10);
									} else {
										// 10184: jungle_log jungle_wood
										full = true;
									}
								} else {
									if (mat < 10189) {
										// 10188: acacia_planks stripped_acacia_log stripped_acacia_wood acacia_slab:type=double
										full = true;
									} else {
										// 10189: acacia_slab:type=bottom acacia_stairs:half=bottom acacia_trapdoor:half=bottom:open=false
										alphatest = true;
										cuboid = true;
									}
								}
							}
						}
					} else {
						if (mat < 10200) {
							if (mat < 10196) {
								if (mat < 10191) {
									// 10190: acacia_slab:type=top acacia_stairs:half=top
									cuboid = true;
								} else {
									if (mat < 10192) {
										// 10191: acacia_fence
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(6);
										bounds[1].xz = ivec2(10);
									} else {
										// 10192: acacia_log acacia_wood
										full = true;
									}
								}
							} else {
								if (mat < 10198) {
									if (mat < 10197) {
										// 10196: dark_oak_planks stripped_dark_oak_log stripped_dark_oak_wood dark_oak_slab:type=double cartography_table
										full = true;
									} else {
										// 10197: dark_oak_slab:type=bottom dark_oak_stairs:half=bottom dark_oak_trapdoor:half=bottom:open=false
										alphatest = true;
										cuboid = true;
									}
								} else {
									if (mat < 10199) {
										// 10198: dark_oak_slab:type=top dark_oak_stairs:half=top
										cuboid = true;
									} else {
										// 10199: dark_oak_fence
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(6);
										bounds[1].xz = ivec2(10);
									}
								}
							}
						} else {
							if (mat < 10207) {
								if (mat < 10205) {
									if (mat < 10204) {
										// 10200: dark_oak_log dark_oak_wood
										full = true;
									} else {
										// 10204: mangrove_planks stripped_mangrove_log stripped_mangrove_wood mangrove_slab:type=double
										full = true;
									}
								} else {
									if (mat < 10206) {
										// 10205: mangrove_slab:type=bottom mangrove_stairs:half=bottom mangrove_trapdoor:half=bottom:open=false
										alphatest = true;
										cuboid = true;
									} else {
										// 10206: mangrove_slab:type=top mangrove_stairs:half=top
										cuboid = true;
									}
								}
							} else {
								if (mat < 10212) {
									if (mat < 10208) {
										// 10207: mangrove_fence
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(6);
										bounds[1].xz = ivec2(10);
									} else {
										// 10208: mangrove_log mangrove_wood
										full = true;
									}
								} else {
									if (mat < 10213) {
										// 10212: crimson_planks stripped_crimson_stem stripped_crimson_hyphae crimson_slab:type=double
										full = true;
									} else {
										// 10213: crimson_slab:type=bottom crimson_stairs:half=bottom crimson_trapdoor:half=bottom:open=false
										alphatest = true;
										cuboid = true;
									}
								}
							}
						}
					}
				}
			}
		} else {
			if (mat < 10376) {
				if (mat < 10284) {
					if (mat < 10243) {
						if (mat < 10224) {
							if (mat < 10220) {
								if (mat < 10215) {
									// 10214: crimson_slab:type=top crimson_stairs:half=top
									cuboid = true;
								} else {
									if (mat < 10216) {
										// 10215: crimson_fence
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(6);
										bounds[1].xz = ivec2(10);
									} else {
										// 10216: crimson_stem crimson_hyphae
										emissive = true;
										full = true;
										lightlevel = BRIGHTNESS_CRIMSON;
									}
								}
							} else {
								if (mat < 10222) {
									if (mat < 10221) {
										// 10220: warped_planks stripped_warped_stem stripped_warped_hyphae warped_slab:type=double
										full = true;
									} else {
										// 10221: warped_slab:type=bottom warped_stairs:half=bottom warped_trapdoor:half=bottom:open=false
										alphatest = true;
										cuboid = true;
									}
								} else {
									if (mat < 10223) {
										// 10222: warped_slab:type=top warped_stairs:half=top
										cuboid = true;
									} else {
										// 10223: warped_fence
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(6);
										bounds[1].xz = ivec2(10);
									}
								}
							}
						} else {
							if (mat < 10236) {
								if (mat < 10228) {
									// 10224: warped_stem warped_hyphae
									emissive = true;
									full = true;
									lightlevel = BRIGHTNESS_WARPED;
								} else {
									if (mat < 10232) {
										// 10228: bedrock
										full = true;
									} else {
										// 10232: sand
										full = true;
									}
								}
							} else {
								if (mat < 10241) {
									if (mat < 10240) {
										// 10236: red_sand
										full = true;
									} else {
										// 10240: sandstone chiseled_sandstone cut_sandstone sandstone_slab:type=double cut_sandstone_slab:type=double smooth_sandstone smooth_sandstone_slab:type=double
										full = true;
									}
								} else {
									if (mat < 10242) {
										// 10241: sandstone_slab:type=bottom cut_sandstone_slab:type=bottom sandstone_stairs:half=bottom smooth_sandstone_stairs:half=bottom smooth_sandstone_slab:type=bottom
										cuboid = true;
									} else {
										// 10242: sandstone_slab:type=top cut_sandstone_slab:type=top sandstone_stairs:half=top smooth_sandstone_stairs:half=top smooth_sandstone_slab:type=top
										cuboid = true;
									}
								}
							}
						}
					} else {
						if (mat < 10256) {
							if (mat < 10246) {
								if (mat < 10244) {
									// 10243: sandstone_wall
									cuboid = true;
									connectSides = true;
									bounds[0].xz = ivec2(4);
									bounds[1].xz = ivec2(12);
								} else {
									if (mat < 10245) {
										// 10244: red_sandstone chiseled_red_sandstone cut_red_sandstone red_sandstone_slab:type=double cut_red_sandstone_slab:type=double smooth_red_sandstone smooth_red_sandstone_slab:type=double
										full = true;
									} else {
										// 10245: red_sandstone_slab:type=bottom cut_red_sandstone_slab:type=bottom red_sandstone_stairs:half=bottom smooth_red_sandstone_stairs:half=bottom smooth_red_sandstone_slab:type=bottom
										cuboid = true;
									}
								}
							} else {
								if (mat < 10248) {
									if (mat < 10247) {
										// 10246: red_sandstone_slab:type=top cut_red_sandstone_slab:type=top red_sandstone_stairs:half=top smooth_red_sandstone_stairs:half=top smooth_red_sandstone_slab:type=top
										cuboid = true;
									} else {
										// 10247: red_sandstone_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									}
								} else {
									if (mat < 10252) {
										// 10248: netherite_block
										full = true;
									} else {
										// 10252: ancient_debris
										full = true;
									}
								}
							}
						} else {
							if (mat < 10268) {
								if (mat < 10264) {
									// 10256: iron_bars
									alphatest = true;
									cuboid = true;
									connectSides = true;
									bounds[0] = ivec3(7, 0, 7);
									bounds[1] = ivec3(9, 16, 9);
								} else {
									if (mat < 10265) {
										// 10264: iron_block
										full = true;
									} else {
										// 10265: iron_trapdoor:half=bottom:open=false
										alphatest = true;
										cuboid = true;
									}
								}
							} else {
								if (mat < 10276) {
									if (mat < 10272) {
										// 10268: raw_iron_block
										full = true;
									} else {
										// 10272: iron_ore
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_IRON_COL
										lightcol = vec3(IRON_COL_R, IRON_COL_G, IRON_COL_B);
										#endif
										lightlevel = ORE_BRIGHTNESS_IRON;
									}
								} else {
									if (mat < 10280) {
										// 10276: deepslate_iron_ore
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_IRON_COL
										lightcol = vec3(IRON_COL_R, IRON_COL_G, IRON_COL_B);
										#endif
										lightlevel = ORE_BRIGHTNESS_IRON;
									} else {
										// 10280: raw_copper_block
										full = true;
									}
								}
							}
						}
					}
				} else {
					if (mat < 10328) {
						if (mat < 10300) {
							if (mat < 10293) {
								if (mat < 10288) {
									// 10284: copper_ore
									#if (GLOWING_ORES > 0)
										emissive = true;
									#endif
									full = true;
									#ifdef ORE_HARDCODED_COPPER_COL
									lightcol = vec3(COPPER_COL_R, COPPER_COL_G, COPPER_COL_B);
									#endif
									lightlevel = ORE_BRIGHTNESS_COPPER;
								} else {
									if (mat < 10292) {
										// 10288: deepslate_copper_ore
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_COPPER_COL
										lightcol = vec3(COPPER_COL_R, COPPER_COL_G, COPPER_COL_B);
										#endif
										lightlevel = ORE_BRIGHTNESS_COPPER;
									} else {
										// 10292: copper_block exposed_copper weathered_copper oxidized_copper cut_copper exposed_cut_copper weathered_cut_copper oxidized_cut_copper cut_copper_slab:type=double exposed_cut_copper_slab:type=double weathered_cut_copper_slab:type=double oxidized_cut_copper_slab:type=double waxed_copper_block waxed_exposed_copper waxed_weathered_copper waxed_oxidized_copper waxed_cut_copper waxed_exposed_cut_copper waxed_weathered_cut_copper waxed_oxidized_cut_copper waxed_cut_copper_slab:type=double waxed_exposed_cut_copper_slab:type=double waxed_weathered_cut_copper_slab:type=double waxed_oxidized_cut_copper_slab:type=double
										full = true;
									}
								}
							} else {
								if (mat < 10295) {
									if (mat < 10294) {
										// 10293: oxidized_cut_copper cut_copper_stairs:half=bottom exposed_cut_copper_stairs:half=bottom weathered_cut_copper_stairs:half=bottom oxidized_cut_copper_stairs:half=bottom cut_copper_slab:type=bottom exposed_cut_copper_slab:type=bottom weathered_cut_copper_slab:type=bottom oxidized_cut_copper_slab:type=bottom waxed_cut_copper_stairs:half=bottom waxed_exposed_cut_copper_stairs:half=bottom waxed_weathered_cut_copper_stairs:half=bottom waxed_oxidized_cut_copper_stairs:half=bottom waxed_cut_copper_slab:type=bottom waxed_exposed_cut_copper_slab:type=bottom waxed_weathered_cut_copper_slab:type=bottom waxed_oxidized_cut_copper_slab:type=bottom
										cuboid = true;
									} else {
										// 10294: oxidized_cut_copper cut_copper_stairs:half=top exposed_cut_copper_stairs:half=top weathered_cut_copper_stairs:half=top oxidized_cut_copper_stairs:half=top cut_copper_slab:type=top exposed_cut_copper_slab:type=top weathered_cut_copper_slab:type=top oxidized_cut_copper_slab:type=top waxed_cut_copper_stairs:half=top waxed_exposed_cut_copper_stairs:half=top waxed_weathered_cut_copper_stairs:half=top waxed_oxidized_cut_copper_stairs:half=top waxed_cut_copper_slab:type=top waxed_exposed_cut_copper_slab:type=top waxed_weathered_cut_copper_slab:type=top waxed_oxidized_cut_copper_slab:type=top
										cuboid = true;
									}
								} else {
									if (mat < 10296) {
										// 10295: This case is probably superfluous (not in block.properties)
										cuboid = true;
									} else {
										// 10296: raw_gold_block
										full = true;
									}
								}
							}
						} else {
							if (mat < 10313) {
								if (mat < 10304) {
									// 10300: gold_ore
									#if (GLOWING_ORES > 0)
										emissive = true;
									#endif
									full = true;
									#ifdef ORE_HARDCODED_GOLD_COL
									lightcol = vec3(GOLD_COL_R, GOLD_COL_G, GOLD_COL_B);
									#endif
									lightlevel = ORE_BRIGHTNESS_GOLD;
								} else {
									if (mat < 10308) {
										// 10304: deepslate_gold_ore
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_GOLD_COL
										lightcol = vec3(GOLD_COL_R, GOLD_COL_G, GOLD_COL_B);
										#endif
										lightlevel = ORE_BRIGHTNESS_GOLD;
									} else {
										// 10308: nether_gold_ore
										full = true;
									}
								}
							} else {
								if (mat < 10320) {
									if (mat < 10316) {
										// 10313: bell
										cuboid = true;
										bounds[0] = ivec3(5, 3, 5);
										bounds[1] = ivec3(11, 13, 11);
									} else {
										// 10316: diamond_block
										full = true;
									}
								} else {
									if (mat < 10324) {
										// 10320: diamond_ore
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_DIAMOND_COL
										lightcol = vec3(DIAMOND_COL_R, DIAMOND_COL_G, DIAMOND_COL_B);
										#endif
										lightlevel = ORE_BRIGHTNESS_DIAMOND;
									} else {
										// 10324: deepslate_diamond_ore
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_DIAMOND_COL
										lightcol = vec3(DIAMOND_COL_R, DIAMOND_COL_G, DIAMOND_COL_B);
										#endif
										lightlevel = ORE_BRIGHTNESS_DIAMOND;
									}
								}
							}
						}
					} else {
						if (mat < 10356) {
							if (mat < 10340) {
								if (mat < 10332) {
									// 10328: amethyst_block budding_amethyst
									full = true;
								} else {
									if (mat < 10336) {
										// 10332: small_amethyst_bud medium_amethyst_bud large_amethyst_bud amethyst_cluster
										emissive = true;
										crossmodel = true;
										#ifdef HARDCODED_AMETHYST_COL
										lightcol = vec3(AMETHYST_COL_R, AMETHYST_COL_G, AMETHYST_COL_B);
										#endif
										lightlevel = BRIGHTNESS_AMETHYST;
									} else {
										// 10336: emerald_block
										#if (defined GLOWING_MINERAL_BLOCKS)
											emissive = true;
										#endif
										full = true;
										#ifdef BLOCK_HARDCODED_EMERALD_COL
										lightcol = vec3(EMERALD_COL_R, EMERALD_COL_G, EMERALD_COL_B);
										#endif
										lightlevel = BLOCK_BRIGHTNESS_EMERALD;
									}
								}
							} else {
								if (mat < 10350) {
									if (mat < 10344) {
										// 10340: emerald_ore
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_EMERALD_COL
										lightcol = vec3(EMERALD_COL_R, EMERALD_COL_G, EMERALD_COL_B);
										#endif
										lightlevel = ORE_BRIGHTNESS_EMERALD;
									} else {
										// 10344: deepslate_emerald_ore
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_EMERALD_COL
										lightcol = vec3(EMERALD_COL_R, EMERALD_COL_G, EMERALD_COL_B);
										#endif
										lightlevel = ORE_BRIGHTNESS_EMERALD;
									}
								} else {
									if (mat < 10352) {
										// 10350: azalea flowering_azalea
										cuboid = true;
									} else {
										// 10352: lapis_block 
										#if (defined GLOWING_MINERAL_BLOCKS)
											emissive = true;
										#endif
										full = true;
										#ifdef BLOCK_HARDCODED_LAPIS_COL
										lightcol = vec3(LAPIS_COL_R, LAPIS_COL_G, LAPIS_COL_B);
										#endif
										lightlevel = BLOCK_BRIGHTNESS_LAPIS;
									}
								}
							}
						} else {
							if (mat < 10366) {
								if (mat < 10364) {
									if (mat < 10360) {
										// 10356: lapis_ore
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_LAPIS_COL
										lightcol = vec3(LAPIS_COL_R, LAPIS_COL_G, LAPIS_COL_B);
										#endif
										lightlevel = ORE_BRIGHTNESS_LAPIS;
									} else {
										// 10360: deepslate_lapis_ore
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_LAPIS_COL
										lightcol = vec3(LAPIS_COL_R, LAPIS_COL_G, LAPIS_COL_B);
										#endif
										lightlevel = ORE_BRIGHTNESS_LAPIS;
									}
								} else {
									if (mat < 10365) {
										// 10364: quartz_block chiseled_quartz_block smooth_quartz quartz_slab:type=double quartz_bricks quartz_pillar smooth_quartz_slab:type=double
										full = true;
									} else {
										// 10365: quartz_stairs:half=bottom smooth_quartz_stairs:half=bottom smooth_quartz_slab:type=bottom quartz_slab:type=bottom
										cuboid = true;
									}
								}
							} else {
								if (mat < 10368) {
									if (mat < 10367) {
										// 10366: quartz_stairs:half=top smooth_quartz_stairs:half=top smooth_quartz_slab:type=top quartz_slab:type=top
										cuboid = true;
									} else {
										// 10367: This case is probably superfluous (not in block.properties)
										cuboid = true;
									}
								} else {
									if (mat < 10372) {
										// 10368: nether_quartz_ore
										full = true;
									} else {
										// 10372: obsidian
										full = true;
									}
								}
							}
						}
					}
				}
			} else {
				if (mat < 10430) {
					if (mat < 10404) {
						if (mat < 10388) {
							if (mat < 10379) {
								if (mat < 10377) {
									// 10376: purpur_block purpur_pillar purpur_slab:type=double
									full = true;
								} else {
									if (mat < 10378) {
										// 10377: purpur_stairs:half=bottom purpur_slab:type=bottom
										cuboid = true;
									} else {
										// 10378: purpur_stairs:half=top purpur_slab:type=top
										cuboid = true;
									}
								}
							} else {
								if (mat < 10381) {
									if (mat < 10380) {
										// 10379: This case is probably superfluous (not in block.properties)
										cuboid = true;
									} else {
										// 10380: snow_block
										full = true;
									}
								} else {
									if (mat < 10384) {
										// 10381: snow
										cuboid = true;
									} else {
										// 10384: packed_ice
										full = true;
									}
								}
							}
						} else {
							if (mat < 10400) {
								if (mat < 10392) {
									// 10388: blue_ice
									emissive = true;
									full = true;
									#ifdef HARDCODED_ICE_COL
									lightcol = vec3(ICE_COL_R, ICE_COL_G, ICE_COL_B);
									#endif
									lightlevel = BRIGHTNESS_ICE;
								} else {
									if (mat < 10396) {
										// 10392: pumpkin carved_pumpkin
										full = true;
									} else {
										// 10396: jack_o_lantern
										emissive = true;
										full = true;
										#ifdef HARDCODED_PUMPKIN_COL
										lightcol = vec3(PUMPKIN_COL_R, PUMPKIN_COL_G, PUMPKIN_COL_B);
										#endif
										lightlevel = BRIGHTNESS_PUMPKIN;
									}
								}
							} else {
								if (mat < 10402) {
									if (mat < 10401) {
										// 10400: sea_pickle:waterlogged=true:pickles=1 sea_pickle:waterlogged=true:pickles=2
										emissive = true;
										cuboid = true;
										#ifdef HARDCODED_PICKLE_COL
										lightcol = vec3(PICKLE_COL_R, PICKLE_COL_G, PICKLE_COL_B);
										#endif
										lightlevel = LOW_BRIGHTNESS_PICKLE;
										bounds[0] = ivec3(6, 0, 6);
										bounds[1] = ivec3(10, 6, 10);
									} else {
										// 10401: sea_pickle:waterlogged=true:pickles=3 sea_pickle:waterlogged=true:pickles=4
										emissive = true;
										cuboid = true;
										#ifdef HARDCODED_PICKLE_COL
										lightcol = vec3(PICKLE_COL_R, PICKLE_COL_G, PICKLE_COL_B);
										#endif
										lightlevel = HIGH_BRIGHTNESS_PICKLE;
										bounds[0] = ivec3(3, 0, 3);
										bounds[1] = ivec3(13, 6, 13);
									}
								} else {
									if (mat < 10403) {
										// 10402: sea_pickle:waterlogged=false:pickles=1 sea_pickle:waterlogged=false:pickles=2
										cuboid = true;
										bounds[0] = ivec3(6, 0, 6);
										bounds[1] = ivec3(10, 6, 10);
									} else {
										// 10403: sea_pickle:waterlogged=false:pickles=3 sea_pickle:waterlogged=false:pickles=4
										cuboid = true;
										bounds[0] = ivec3(3, 0, 3);
										bounds[1] = ivec3(13, 6, 13);
									}
								}
							}
						}
					} else {
						if (mat < 10420) {
							if (mat < 10416) {
								if (mat < 10408) {
									// 10404: soul_sand soul_soil
									full = true;
								} else {
									if (mat < 10412) {
										// 10408: basalt polished_basalt smooth_basalt
										full = true;
									} else {
										// 10412: glowstone
										emissive = true;
										full = true;
										#ifdef HARDCODED_GLOWSTONE_COL
										lightcol = vec3(GLOWSTONE_COL_R, GLOWSTONE_COL_G, GLOWSTONE_COL_B);
										#endif
										lightlevel = BRIGHTNESS_GLOWSTONE;
									}
								}
							} else {
								if (mat < 10418) {
									if (mat < 10417) {
										// 10416: nether_bricks nether_brick_slab:type=double cracked_nether_bricks chiseled_nether_bricks
										full = true;
									} else {
										// 10417: nether_brick_slab:type=bottom nether_brick_stairs:half=bottom
										cuboid = true;
									}
								} else {
									if (mat < 10419) {
										// 10418: nether_brick_slab:type=top nether_brick_stairs:half=top
										cuboid = true;
									} else {
										// 10419: nether_brick_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									}
								}
							}
						} else {
							if (mat < 10423) {
								if (mat < 10421) {
									// 10420: red_nether_bricks red_nether_brick_slab:type=double
									full = true;
								} else {
									if (mat < 10422) {
										// 10421: red_nether_brick_slab:type=bottom red_nether_brick_stairs:half=bottom
										cuboid = true;
									} else {
										// 10422: red_nether_brick_slab:type=top red_nether_brick_stairs:half=top
										cuboid = true;
									}
								}
							} else {
								if (mat < 10428) {
									if (mat < 10424) {
										// 10423: red_nether_brick_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									} else {
										// 10424: melon
										full = true;
									}
								} else {
									if (mat < 10429) {
										// 10428: end_stone end_stone_bricks end_stone_brick_slab:type=double
										full = true;
									} else {
										// 10429: end_stone_brick_stairs:half=bottom end_stone_brick_slab:type=bottom
										cuboid = true;
									}
								}
							}
						}
					}
				} else {
					if (mat < 10456) {
						if (mat < 10443) {
							if (mat < 10436) {
								if (mat < 10431) {
									// 10430: end_stone_brick_stairs:half=top end_stone_brick_slab:type=top
									cuboid = true;
								} else {
									if (mat < 10432) {
										// 10431: end_stone_brick_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									} else {
										// 10432: terracotta white_terracotta orange_terracotta magenta_terracotta light_blue_terracotta yellow_terracotta lime_terracotta pink_terracotta gray_terracotta light_gray_terracotta cyan_terracotta purple_terracotta blue_terracotta brown_terracotta green_terracotta red_terracotta black_terracotta
										full = true;
									}
								}
							} else {
								if (mat < 10441) {
									if (mat < 10440) {
										// 10436: white_glazed_terracotta orange_glazed_terracotta magenta_glazed_terracotta light_blue_glazed_terracotta yellow_glazed_terracotta lime_glazed_terracotta pink_glazed_terracotta gray_glazed_terracotta light_gray_glazed_terracotta cyan_glazed_terracotta purple_glazed_terracotta blue_glazed_terracotta brown_glazed_terracotta green_glazed_terracotta red_glazed_terracotta black_glazed_terracotta
										full = true;
									} else {
										// 10440: prismarine prismarine_slab:type=double prismarine_bricks prismarine_brick_slab:type=double
										full = true;
									}
								} else {
									if (mat < 10442) {
										// 10441: prismarine_slab:type=bottom prismarine_stairs:half=bottom prismarine_brick_slab:type=bottom prismarine_brick_stairs:half=bottom
										cuboid = true;
									} else {
										// 10442: prismarine_slab:type=top prismarine_stairs:half=top prismarine_brick_slab:type=top prismarine_brick_stairs:half=top
										cuboid = true;
									}
								}
							}
						} else {
							if (mat < 10446) {
								if (mat < 10444) {
									// 10443: prismarine_wall
									cuboid = true;
									connectSides = true;
									bounds[0].xz = ivec2(4);
									bounds[1].xz = ivec2(12);
								} else {
									if (mat < 10445) {
										// 10444: dark_prismarine dark_prismarine_slab:type=double
										full = true;
									} else {
										// 10445: dark_prismarine_stairs:half=bottom dark_prismarine_slab:type=bottom
										cuboid = true;
									}
								}
							} else {
								if (mat < 10448) {
									if (mat < 10447) {
										// 10446: dark_prismarine_stairs:half=top dark_prismarine_slab:type=top
										cuboid = true;
									} else {
										// 10447: This case is probably superfluous (not in block.properties)
										cuboid = true;
									}
								} else {
									if (mat < 10452) {
										// 10448: sea_lantern
										emissive = true;
										full = true;
										#ifdef HARDCODED_SEALANTERN_COL
										lightcol = vec3(SEALANTERN_COL_R, SEALANTERN_COL_G, SEALANTERN_COL_B);
										#endif
										lightlevel = BRIGHTNESS_SEALANTERN;
									} else {
										// 10452: magma_block
										emissive = true;
										full = true;
										#ifdef HARDCODED_MAGMA_COL
										lightcol = vec3(MAGMA_COL_R, MAGMA_COL_G, MAGMA_COL_B);
										#endif
										lightlevel = BRIGHTNESS_MAGMA;
									}
								}
							}
						}
					} else {
						if (mat < 10482) {
							if (mat < 10468) {
								if (mat < 10460) {
									// 10456: command_block chain_command_block repeating_command_block
									full = true;
								} else {
									if (mat < 10464) {
										// 10460: white_concrete orange_concrete magenta_concrete light_blue_concrete yellow_concrete lime_concrete pink_concrete gray_concrete light_gray_concrete cyan_concrete purple_concrete blue_concrete brown_concrete green_concrete red_concrete black_concrete
										full = true;
									} else {
										// 10464: white_concrete_powder orange_concrete_powder magenta_concrete_powder light_blue_concrete_powder yellow_concrete_powder lime_concrete_powder pink_concrete_powder gray_concrete_powder light_gray_concrete_powder cyan_concrete_powder purple_concrete_powder blue_concrete_powder brown_concrete_powder green_concrete_powder red_concrete_powder black_concrete_powder
										full = true;
									}
								}
							} else {
								if (mat < 10480) {
									if (mat < 10476) {
										// 10468: tube_coral_block brain_coral_block bubble_coral_block fire_coral_block horn_coral_block dead_tube_coral_block dead_brain_coral_block dead_bubble_coral_block dead_fire_coral_block dead_horn_coral_block
										full = true;
									} else {
										// 10476: crying_obsidian
										emissive = true;
										full = true;
										#ifdef HARDCODED_CRYING_COL
										lightcol = vec3(CRYING_COL_R, CRYING_COL_G, CRYING_COL_B);
										#endif
										lightlevel = BRIGHTNESS_CRYING;
									}
								} else {
									if (mat < 10481) {
										// 10480: blackstone blackstone_slab:type=double polished_blackstone polished_blackstone_slab:type=double chiseled_polished_blackstone polished_blackstone_bricks polished_blackstone_brick_slab:type=double cracked_polished_blackstone_bricks coal_block
										full = true;
									} else {
										// 10481: blackstone_stairs:half=bottom polished_blackstone_stairs:half=bottom polished_blackstone_brick_stairs:half=bottom blackstone_slab:type=bottom polished_blackstone_slab:type=bottom polished_blackstone_brick_slab:type=bottom
										cuboid = true;
									}
								}
							}
						} else {
							if (mat < 10492) {
								if (mat < 10484) {
									if (mat < 10483) {
										// 10482: blackstone_stairs:half=top polished_blackstone_stairs:half=top polished_blackstone_brick_stairs:half=top blackstone_slab:type=top polished_blackstone_slab:type=top polished_blackstone_brick_slab:type=top
										cuboid = true;
									} else {
										// 10483: polished_blackstone_brick_wall polished_blackstone_wall blackstone_wall
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(4);
										bounds[1].xz = ivec2(12);
									}
								} else {
									if (mat < 10488) {
										// 10484: gilded_blackstone
										full = true;
									} else {
										// 10488: lily_pad
										cuboid = true;
										bounds[0] = ivec3(3, 0, 3);
										bounds[1] = ivec3(13, 1, 13);
									}
								}
							} else {
								if (mat < 10497) {
									if (mat < 10496) {
										// 10492: twisting_vines_plant twisting_vines weeping_vines weeping_vines_plant warped_fungus crimson_fungus
										crossmodel = true;
									} else {
										// 10496: torch
										emissive = true;
										cuboid = true;
										#ifdef HARDCODED_TORCH_COL
										lightcol = vec3(TORCH_COL_R, TORCH_COL_G, TORCH_COL_B);
										#endif
										lightlevel = BRIGHTNESS_TORCH;
										bounds[0] = ivec3(7, 0, 7);
										bounds[1] = ivec3(9, 10, 9);
									}
								} else {
									if (mat < 10500) {
										// 10497: wall_torch
										notrace = true;
										emissive = true;
										#ifdef HARDCODED_TORCH_COL
										lightcol = vec3(TORCH_COL_R, TORCH_COL_G, TORCH_COL_B);
										#endif
										lightlevel = BRIGHTNESS_TORCH;
									} else {
										// 10500: end_rod:facing=up end_rod:facing=down
										emissive = true;
										cuboid = true;
										#ifdef HARDCODED_ENDROD_COL
										lightcol = vec3(ENDROD_COL_R, ENDROD_COL_G, ENDROD_COL_B);
										#endif
										lightlevel = BRIGHTNESS_ENDROD;
										bounds[0].xz = ivec2(7);
										bounds[1].xz = ivec2(9);
									}
								}
							}
						}
					}
				}
			}
		}
	} else {
		if (mat < 12380) {
			if (mat < 10684) {
				if (mat < 10588) {
					if (mat < 10548) {
						if (mat < 10524) {
							if (mat < 10508) {
								if (mat < 10502) {
									// 10501: end_rod:facing=east end_rod:facing=west
									emissive = true;
									cuboid = true;
									#ifdef HARDCODED_ENDROD_COL
									lightcol = vec3(ENDROD_COL_R, ENDROD_COL_G, ENDROD_COL_B);
									#endif
									lightlevel = BRIGHTNESS_ENDROD;
									bounds[0].yz = ivec2(7);
									bounds[1].yz = ivec2(9);
								} else {
									if (mat < 10504) {
										// 10502: end_rod:facing=north end_rod:facing=south
										emissive = true;
										cuboid = true;
										#ifdef HARDCODED_ENDROD_COL
										lightcol = vec3(ENDROD_COL_R, ENDROD_COL_G, ENDROD_COL_B);
										#endif
										lightlevel = BRIGHTNESS_ENDROD;
										bounds[0].xy = ivec2(7);
										bounds[1].xy = ivec2(9);
									} else {
										// 10504: chorus_plant
										cuboid = true;
										bounds[0] = ivec3(4);
										bounds[1] = ivec3(12);
									}
								}
							} else {
								if (mat < 10516) {
									if (mat < 10512) {
										// 10508: chorus_flower:age=0 chorus_flower:age=1 chorus_flower:age=2 chorus_flower:age=3 chorus_flower:age=4
										emissive = true;
										cuboid = true;
										#ifdef HARDCODED_CHORUS_COL
										lightcol = vec3(CHORUS_COL_R, CHORUS_COL_G, CHORUS_COL_B);
										#endif
										lightlevel = BRIGHTNESS_CHORUS;
										bounds[0] = ivec3(1);
										bounds[1] = ivec3(15);
									} else {
										// 10512: chorus_flower:age=5
										cuboid = true;
										bounds[0] = ivec3(1);
										bounds[1] = ivec3(15);
									}
								} else {
									if (mat < 10520) {
										// 10516: furnace:lit=true
										emissive = true;
										full = true;
										#ifdef HARDCODED_FURNACE_COL
										lightcol = vec3(FURNACE_COL_R, FURNACE_COL_G, FURNACE_COL_B);
										#endif
										lightlevel = BRIGHTNESS_FURNACE;
									} else {
										// 10520: cactus
										cuboid = true;
										bounds[0].xz = ivec2(1);
										bounds[1].xz = ivec2(15);
									}
								}
							}
						} else {
							if (mat < 10532) {
								if (mat < 10528) {
									// 10524: note_block jukebox
									full = true;
								} else {
									if (mat < 10529) {
										// 10528: soul_torch
										emissive = true;
										cuboid = true;
										#ifdef HARDCODED_SOULTORCH_COL
										lightcol = vec3(SOULTORCH_COL_R, SOULTORCH_COL_G, SOULTORCH_COL_B);
										#endif
										lightlevel = BRIGHTNESS_SOULTORCH;
										bounds[0] = ivec3(7, 0, 7);
										bounds[1] = ivec3(9, 10, 9);
									} else {
										// 10529: soul_wall_torch
										notrace = true;
										emissive = true;
										#ifdef HARDCODED_SOULTORCH_COL
										lightcol = vec3(SOULTORCH_COL_R, SOULTORCH_COL_G, SOULTORCH_COL_B);
										#endif
										lightlevel = BRIGHTNESS_SOULTORCH;
									}
								}
							} else {
								if (mat < 10540) {
									if (mat < 10536) {
										// 10532: brown_mushroom_block
										full = true;
									} else {
										// 10536: red_mushroom_block
										full = true;
									}
								} else {
									if (mat < 10544) {
										// 10540: mushroom_stem
										full = true;
									} else {
										// 10544: glow_lichen
										notrace = true;
										alphatest = true;
										emissive = true;
										#ifdef HARDCODED_LICHEN_COL
										lightcol = vec3(LICHEN_COL_R, LICHEN_COL_G, LICHEN_COL_B);
										#endif
										lightlevel = BRIGHTNESS_LICHEN;
									}
								}
							}
						}
					} else {
						if (mat < 10567) {
							if (mat < 10560) {
								if (mat < 10552) {
									// 10548: enchanting_table
									emissive = true;
									cuboid = true;
									#ifdef HARDCODED_TABLE_COL
									lightcol = vec3(TABLE_COL_R, TABLE_COL_G, TABLE_COL_B);
									#endif
									lightlevel = BRIGHTNESS_TABLE;
									bounds[1].y = int(16*fract(pos.y + 0.03125));
								} else {
									if (mat < 10556) {
										// 10552: end_portal_frame:eye=false
										cuboid = true;
										bounds[1].y = int(16*fract(pos.y + 0.03125));
									} else {
										// 10556: end_portal_frame:eye=true
										emissive = true;
										cuboid = true;
										#ifdef HARDCODED_END_COL
										lightcol = vec3(END_COL_R, END_COL_G, END_COL_B);
										#endif
										lightlevel = FRAME_BRIGHTNESS_END;
										bounds[1].y = int(16*fract(pos.y + 0.03125));
									}
								}
							} else {
								if (mat < 10565) {
									if (mat < 10564) {
										// 10560: lantern
										emissive = true;
										cuboid = true;
										#ifdef LANTERN_HARDCODED_TORCH_COL
										lightcol = vec3(TORCH_COL_R, TORCH_COL_G, TORCH_COL_B);
										#endif
										lightlevel = LANTERN_BRIGHTNESS_TORCH;
										bounds[0] = ivec3(5, 1, 5);
										bounds[1] = ivec3(11, 7, 11);
									} else {
										// 10564: soul_lantern
										emissive = true;
										cuboid = true;
										#ifdef LANTERN_HARDCODED_SOULTORCH_COL
										lightcol = vec3(SOULTORCH_COL_R, SOULTORCH_COL_G, SOULTORCH_COL_B);
										#endif
										lightlevel = LANTERN_BRIGHTNESS_SOULTORCH;
										bounds[0] = ivec3(5, 1, 5);
										bounds[1] = ivec3(11, 7, 11);
									}
								} else {
									if (mat < 10566) {
										// 10565: chain:axis=x
										cuboid = true;
										bounds[0].yz = ivec2(7);
										bounds[1].yz = ivec2(9);
									} else {
										// 10566: chain:axis=y
										cuboid = true;
										bounds[0].xz = ivec2(7);
										bounds[1].xz = ivec2(9);
									}
								}
							}
						} else {
							if (mat < 10572) {
								if (mat < 10568) {
									// 10567: chain:axis=z
									cuboid = true;
									bounds[0].xy = ivec2(7);
									bounds[1].xy = ivec2(9);
								} else {
									if (mat < 10569) {
										// 10568: turtle_egg:eggs=1 turtle_egg:eggs=2
										cuboid = true;
										bounds[0] = ivec3(6, 0, 6);
										bounds[1] = ivec3(10, 6, 10);
									} else {
										// 10569: turtle_egg:eggs=3 turtle_egg:eggs=4
										cuboid = true;
										bounds[0] = ivec3(3, 0, 3);
										bounds[1] = ivec3(13, 6, 13);
									}
								}
							} else {
								if (mat < 10580) {
									if (mat < 10576) {
										// 10572: dragon_egg
										emissive = true;
										#ifdef HARDCODED_DRAGON_COL
										lightcol = vec3(DRAGON_COL_R, DRAGON_COL_G, DRAGON_COL_B);
										#endif
										lightlevel = BRIGHTNESS_DRAGON;
									} else {
										// 10576: smoker:lit=true
										emissive = true;
										full = true;
										#ifdef HARDCODED_FURNACE_COL
										lightcol = vec3(FURNACE_COL_R, FURNACE_COL_G, FURNACE_COL_B);
										#endif
										lightlevel = BRIGHTNESS_FURNACE;
									}
								} else {
									if (mat < 10584) {
										// 10580: blast_furnace:lit=true
										emissive = true;
										full = true;
										#ifdef HARDCODED_FURNACE_COL
										lightcol = vec3(FURNACE_COL_R, FURNACE_COL_G, FURNACE_COL_B);
										#endif
										lightlevel = BRIGHTNESS_FURNACE;
									} else {
										// 10584: candle:lit=true white_candle:lit=true orange_candle:lit=true magenta_candle:lit=true light_blue_candle:lit=true yellow_candle:lit=true lime_candle:lit=true pink_candle:lit=true gray_candle:lit=true light_gray_candle:lit=true cyan_candle:lit=true purple_candle:lit=true blue_candle:lit=true brown_candle:lit=true green_candle:lit=true red_candle:lit=true black_candle:lit=true
										emissive = true;
										cuboid = true;
										#ifdef HARDCODED_CANDLE_COL
										lightcol = vec3(CANDLE_COL_R, CANDLE_COL_G, CANDLE_COL_B);
										#endif
										lightlevel = BRIGHTNESS_CANDLE;
										bounds[0] = ivec3(6, 0, 6);
										bounds[1] = ivec3(10, 6, 10);
									}
								}
							}
						}
					}
				} else {
					if (mat < 10628) {
						if (mat < 10604) {
							if (mat < 10597) {
								if (mat < 10592) {
									// 10588: respawn_anchor:charges=0
									full = true;
								} else {
									if (mat < 10596) {
										// 10592: respawn_anchor:charges=1 respawn_anchor:charges=2 respawn_anchor:charges=3 respawn_anchor:charges=4
										emissive = true;
										full = true;
										#ifdef ANCHOR_HARDCODED_PORTAL_COL
										lightcol = vec3(PORTAL_COL_R, PORTAL_COL_G, PORTAL_COL_B);
										#endif
										lightlevel = ANCHOR_BRIGHTNESS_PORTAL;
									} else {
										// 10596: redstone_wire:power=1 redstone_wire:power=2 redstone_wire:power=3 redstone_wire:power=4 redstone_wire:power=5
										notrace = true;
										alphatest = true;
										emissive = true;
										cuboid = true;
										#ifdef WIRE_HARDCODED_REDSTONE_COL
										lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
										#endif
										lightlevel = WIRE0_BRIGHTNESS_REDSTONE;
										bounds[1].y = 2;
									}
								}
							} else {
								if (mat < 10599) {
									if (mat < 10598) {
										// 10597: redstone_wire:power=6 redstone_wire:power=7 redstone_wire:power=8 redstone_wire:power=9 redstone_wire:power=10
										notrace = true;
										emissive = true;
										#ifdef WIRE_HARDCODED_REDSTONE_COL
										lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
										#endif
										lightlevel = WIRE1_BRIGHTNESS_REDSTONE;
									} else {
										// 10598: redstone_wire:power=11 redstone_wire:power=12 redstone_wire:power=13 redstone_wire:power=14
										notrace = true;
										emissive = true;
										#ifdef WIRE_HARDCODED_REDSTONE_COL
										lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
										#endif
										lightlevel = WIRE2_BRIGHTNESS_REDSTONE;
									}
								} else {
									if (mat < 10600) {
										// 10599: redstone_wire:power=15
										notrace = true;
										emissive = true;
										#ifdef WIRE_HARDCODED_REDSTONE_COL
										lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
										#endif
										lightlevel = WIRE3_BRIGHTNESS_REDSTONE;
									} else {
										// 10600: redstone_wire:power=0
										notrace = true;
										alphatest = true;
										cuboid = true;
										bounds[1].y = 2;
									}
								}
							}
						} else {
							if (mat < 10612) {
								if (mat < 10605) {
									// 10604: redstone_torch:lit=false
									cuboid = true;
									bounds[0] = ivec3(7, 0, 7);
									bounds[1] = ivec3(9, 10, 9);
								} else {
									if (mat < 10608) {
										// 10605: redstone_wall_torch:lit=false
										notrace = true;
									} else {
										// 10608: redstone_block
										#if (defined GLOWING_MINERAL_BLOCKS)
											emissive = true;
										#endif
										full = true;
										#ifdef BLOCK_HARDCODED_REDSTONE_COL
										lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
										#endif
										lightlevel = BLOCK_BRIGHTNESS_REDSTONE;
									}
								}
							} else {
								if (mat < 10620) {
									if (mat < 10616) {
										// 10612: redstone_ore:lit=false
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_REDSTONE_COL
										lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
										#endif
										lightlevel = OREUNLIT_BRIGHTNESS_REDSTONE;
									} else {
										// 10616: redstone_ore:lit=true
										emissive = true;
										full = true;
										#ifdef ORE_HARDCODED_REDSTONE_COL
										lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
										#endif
										lightlevel = ORELIT_BRIGHTNESS_REDSTONE;
									}
								} else {
									if (mat < 10624) {
										// 10620: deepslate_redstone_ore:lit=false
										#if (GLOWING_ORES > 0)
											emissive = true;
										#endif
										full = true;
										#ifdef ORE_HARDCODED_REDSTONE_COL
										lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
										#endif
										lightlevel = OREUNLIT_BRIGHTNESS_REDSTONE;
									} else {
										// 10624: deepslate_redstone_ore:lit=true
										emissive = true;
										full = true;
										#ifdef ORE_HARDCODED_REDSTONE_COL
										lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
										#endif
										lightlevel = ORELIT_BRIGHTNESS_REDSTONE;
									}
								}
							}
						}
					} else {
						if (mat < 10656) {
							if (mat < 10640) {
								if (mat < 10632) {
									// 10628: cave_vines_plant:berries=false cave_vines:berries=false
									crossmodel = true;
								} else {
									if (mat < 10636) {
										// 10632: cave_vines_plant:berries=true cave_vines:berries=true
										emissive = true;
										crossmodel = true;
										#ifdef HARDCODED_BERRY_COL
										lightcol = vec3(BERRY_COL_R, BERRY_COL_G, BERRY_COL_B);
										#endif
										lightlevel = BRIGHTNESS_BERRY;
									} else {
										// 10636: redstone_lamp:lit=false
										full = true;
									}
								}
							} else {
								if (mat < 10648) {
									if (mat < 10644) {
										// 10640: redstone_lamp:lit=true
										emissive = true;
										full = true;
										#ifdef HARDCODED_REDSTONELAMP_COL
										lightcol = vec3(REDSTONELAMP_COL_R, REDSTONELAMP_COL_G, REDSTONELAMP_COL_B);
										#endif
										lightlevel = BRIGHTNESS_REDSTONELAMP;
									} else {
										// 10644: repeater comparator
										cuboid = true;
										bounds[1].y = 3;
									}
								} else {
									if (mat < 10652) {
										// 10648: shroomlight
										emissive = true;
										full = true;
										#ifdef HARDCODED_SHROOMLIGHT_COL
										lightcol = vec3(SHROOMLIGHT_COL_R, SHROOMLIGHT_COL_G, SHROOMLIGHT_COL_B);
										#endif
										lightlevel = BRIGHTNESS_SHROOMLIGHT;
									} else {
										// 10652: campfire:lit=true
										emissive = true;
										#ifdef CAMPFIRE_HARDCODED_FIRE_COL
										lightcol = vec3(FIRE_COL_R, FIRE_COL_G, FIRE_COL_B);
										#endif
										lightlevel = CAMPFIRE_BRIGHTNESS_FIRE;
									}
								}
							}
						} else {
							if (mat < 10669) {
								if (mat < 10664) {
									if (mat < 10660) {
										// 10656: soul_campfire:lit=true
										emissive = true;
										cuboid = true;
										#ifdef CAMPFIRE_HARDCODED_SOULFIRE_COL
										lightcol = vec3(SOULFIRE_COL_R, SOULFIRE_COL_G, SOULFIRE_COL_B);
										#endif
										lightlevel = CAMPFIRE_BRIGHTNESS_SOULFIRE;
										bounds[1].y = 8;
									} else {
										// 10660: campfire:lit=false soul_campfire:lit=false
										cuboid = true;
										bounds[1].y = 8;
									}
								} else {
									if (mat < 10668) {
										// 10664: observer
										full = true;
									} else {
										// 10668: white_wool orange_wool magenta_wool light_blue_wool yellow_wool lime_wool pink_wool gray_wool light_gray_wool cyan_wool purple_wool blue_wool brown_wool green_wool red_wool black_wool
										full = true;
									}
								}
							} else {
								if (mat < 10676) {
									if (mat < 10672) {
										// 10669: white_carpet orange_carpet magenta_carpet light_blue_carpet yellow_carpet lime_carpet pink_carpet gray_carpet light_gray_carpet cyan_carpet purple_carpet blue_carpet brown_carpet green_carpet red_carpet black_carpet
										cuboid = true;
										bounds[1].y = 1;
									} else {
										// 10672: bone_block
										full = true;
									}
								} else {
									if (mat < 10680) {
										// 10676: barrel beehive bee_nest honeycomb_block
										full = true;
									} else {
										// 10680: ochre_froglight
										emissive = true;
										full = true;
										#ifdef HARDCODED_YELLOWFROG_COL
										lightcol = vec3(YELLOWFROG_COL_R, YELLOWFROG_COL_G, YELLOWFROG_COL_B);
										#endif
										lightlevel = BRIGHTNESS_YELLOWFROG;
									}
								}
							}
						}
					}
				}
			} else {
				if (mat < 12152) {
					if (mat < 10724) {
						if (mat < 10708) {
							if (mat < 10696) {
								if (mat < 10688) {
									// 10684: verdant_froglight
									emissive = true;
									full = true;
									#ifdef HARDCODED_GREENFROG_COL
									lightcol = vec3(GREENFROG_COL_R, GREENFROG_COL_G, GREENFROG_COL_B);
									#endif
									lightlevel = BRIGHTNESS_GREENFROG;
								} else {
									if (mat < 10692) {
										// 10688: pearlescent_froglight
										emissive = true;
										full = true;
										#ifdef HARDCODED_PINKFROG_COL
										lightcol = vec3(PINKFROG_COL_R, PINKFROG_COL_G, PINKFROG_COL_B);
										#endif
										lightlevel = BRIGHTNESS_PINKFROG;
									} else {
										// 10692: reinforced_deepslate
										full = true;
									}
								}
							} else {
								if (mat < 10700) {
									if (mat < 10697) {
										// 10696: sculk sculk_catalyst
										full = true;
									} else {
										// 10697: sculk_sensor:sculk_sensor_phase=inactive sculk_sensor:sculk_sensor_phase=cooldown
										cuboid = true;
									}
								} else {
									if (mat < 10705) {
										// 10700: sculk_shrieker
										full = true;
									} else {
										// 10705: sculk_sensor:sculk_sensor_phase=active
										emissive = true;
										cuboid = true;
										#ifdef HARDCODED_SCULK_COL
										lightcol = vec3(SCULK_COL_R, SCULK_COL_G, SCULK_COL_B);
										#endif
										lightlevel = SENSOR_BRIGHTNESS_SCULK;
									}
								}
							}
						} else {
							if (mat < 10720) {
								if (mat < 10712) {
									// 10708: spawner
									alphatest = true;
									emissive = true;
									full = true;
									#ifdef HARDCODED_SPAWNER_COL
									lightcol = vec3(SPAWNER_COL_R, SPAWNER_COL_G, SPAWNER_COL_B);
									#endif
									lightlevel = BRIGHTNESS_SPAWNER;
								} else {
									if (mat < 10716) {
										// 10712: tuff
										full = true;
									} else {
										// 10716: clay
										full = true;
									}
								}
							} else {
								if (mat < 10722) {
									if (mat < 10721) {
										// 10720: ladder:facing=north
										alphatest = true;
										cuboid = true;
										bounds[0].z = 12;
									} else {
										// 10721: ladder:facing=south
										alphatest = true;
										cuboid = true;
										bounds[1].z = 4;
									}
								} else {
									if (mat < 10723) {
										// 10722: ladder:facing=east
										alphatest = true;
										cuboid = true;
										bounds[1].x = 4;
									} else {
										// 10723: ladder:facing=west
										alphatest = true;
										cuboid = true;
										bounds[0].x = 12;
									}
								}
							}
						}
					} else {
						if (mat < 10744) {
							if (mat < 10740) {
								if (mat < 10728) {
									// 10724: gravel
									full = true;
								} else {
									if (mat < 10732) {
										// 10728: flower_pot potted_dandelion potted_poppy potted_blue_orchid potted_allium potted_azure_bluet potted_red_tulip potted_orange_tulip potted_white_tulip potted_pink_tulip potted_oxeye_daisy potted_cornflower potted_lily_of_the_valley potted_wither_rose potted_oak_sapling potted_spruce_sapling potted_birch_sapling potted_jungle_sapling potted_acacia_sapling potted_dark_oak_sapling potted_mangrove_propagule potted_red_mushroom potted_brown_mushroom potted_fern potted_dead_bush potted_cactus potted_bamboo potted_crimson_fungus potted_warped_fungus potted_crimson_roots potted_warped_roots potted_flowering_azalea_bush potted_azalea_bush
										cuboid = true;
										bounds[0] = ivec3(5, 0, 5);
										bounds[1] = ivec3(11, 6, 11);
									} else {
										// 10732: lever
										notrace = true;
									}
								}
							} else {
								if (mat < 10742) {
									if (mat < 10741) {
										// 10740: cake:bites=0 candle_cake:lit=false white_candle_cake:lit=false orange_candle_cake:lit=false magenta_candle_cake:lit=false light_blue_candle_cake:lit=false yellow_candle_cake:lit=false lime_candle_cake:lit=false pink_candle_cake:lit=false gray_candle_cake:lit=false light_gray_candle_cake:lit=false cyan_candle_cake:lit=false purple_candle_cake:lit=false blue_candle_cake:lit=false brown_candle_cake:lit=false green_candle_cake:lit=false red_candle_cake:lit=false black_candle_cake:lit=false
										cuboid = true;
										bounds[0] = ivec3(1, 0, 1);
										bounds[1] = ivec3(15, 8, 15);
									} else {
										// 10741: cake:bites=1
										cuboid = true;
										bounds[0] = ivec3(3, 0, 1);
										bounds[1] = ivec3(15, 8, 15);
									}
								} else {
									if (mat < 10743) {
										// 10742: cake:bites=2
										cuboid = true;
										bounds[0] = ivec3(5, 0, 1);
										bounds[1] = ivec3(15, 8, 15);
									} else {
										// 10743: cake:bites=3
										cuboid = true;
										bounds[0] = ivec3(7, 0, 1);
										bounds[1] = ivec3(15, 8, 15);
									}
								}
							}
						} else {
							if (mat < 10747) {
								if (mat < 10745) {
									// 10744: cake:bites=4
									cuboid = true;
									bounds[0] = ivec3(9, 0, 1);
									bounds[1] = ivec3(15, 8, 15);
								} else {
									if (mat < 10746) {
										// 10745: cake:bites=5
										cuboid = true;
										bounds[0] = ivec3(11, 0, 1);
										bounds[1] = ivec3(15, 8, 15);
									} else {
										// 10746: cake:bites=6
										cuboid = true;
										bounds[0] = ivec3(13, 0, 1);
										bounds[1] = ivec3(15, 8, 15);
									}
								}
							} else {
								if (mat < 11584) {
									if (mat < 10748) {
										// 10747: This case is probably superfluous (not in block.properties)
										cuboid = true;
									} else {
										// 10748: This case is probably superfluous (not in block.properties)
										cuboid = true;
									}
								} else {
									if (mat < 12112) {
										// 11584: candle:lit=false white_candle:lit=false orange_candle:lit=false magenta_candle:lit=false light_blue_candle:lit=false yellow_candle:lit=false lime_candle:lit=false pink_candle:lit=false gray_candle:lit=false light_gray_candle:lit=false cyan_candle:lit=false purple_candle:lit=false blue_candle:lit=false brown_candle:lit=false green_candle:lit=false red_candle:lit=false black_candle:lit=false
										cuboid = true;
										bounds[0] = ivec3(6, 0, 6);
										bounds[1] = ivec3(10, 6, 10);
									} else {
										// 12112: mangrove_roots
										alphatest = true;
										full = true;
									}
								}
							}
						}
					}
				} else {
					if (mat < 12196) {
						if (mat < 12165) {
							if (mat < 12155) {
								if (mat < 12153) {
									// 12152: piston_head:facing=up
									cuboid = true;
									bounds[0].y = 12;
								} else {
									if (mat < 12154) {
										// 12153: moss_carpet
										cuboid = true;
										bounds[1].y = 1;
									} else {
										// 12154: sticky_piston:extended=true:facing=down piston:extended=true:facing=down
										cuboid = true;
										bounds[0].y = 4;
									}
								}
							} else {
								if (mat < 12157) {
									if (mat < 12156) {
										// 12155: This case is probably superfluous (not in block.properties)
										cuboid = true;
									} else {
										// 12156: oak_button oak_pressure_plate oak_fence_gate tripwire_hook
										notrace = true;
									}
								} else {
									if (mat < 12164) {
										// 12157: oak_trapdoor:half=top:open=false
										alphatest = true;
										cuboid = true;
									} else {
										// 12164: spruce_button spruce_pressure_plate spruce_fence_gate
										notrace = true;
									}
								}
							}
						} else {
							if (mat < 12180) {
								if (mat < 12172) {
									// 12165: spruce_trapdoor:half=top:open=false
									alphatest = true;
									cuboid = true;
								} else {
									if (mat < 12173) {
										// 12172: birch_button birch_pressure_plate birch_fence_gate
										notrace = true;
									} else {
										// 12173: birch_trapdoor:half=top:open=false scaffolding
										alphatest = true;
										cuboid = true;
									}
								}
							} else {
								if (mat < 12188) {
									if (mat < 12181) {
										// 12180: jungle_button jungle_pressure_plate jungle_fence_gate
										notrace = true;
									} else {
										// 12181: jungle_trapdoor:half=top:open=false
										alphatest = true;
										cuboid = true;
									}
								} else {
									if (mat < 12189) {
										// 12188: acacia_button acacia_pressure_plate acacia_fence_gate
										notrace = true;
									} else {
										// 12189: acacia_trapdoor:half=top:open=false
										alphatest = true;
										cuboid = true;
									}
								}
							}
						}
					} else {
						if (mat < 12221) {
							if (mat < 12205) {
								if (mat < 12197) {
									// 12196: dark_oak_button dark_oak_pressure_plate dark_oak_fence_gate
									notrace = true;
								} else {
									if (mat < 12204) {
										// 12197: dark_oak_trapdoor:half=top:open=false
										alphatest = true;
										cuboid = true;
									} else {
										// 12204: mangrove_button mangrove_pressure_plate mangrove_fence_gate
										notrace = true;
									}
								}
							} else {
								if (mat < 12213) {
									if (mat < 12212) {
										// 12205: mangrove_trapdoor:half=top:open=false
										alphatest = true;
										cuboid = true;
									} else {
										// 12212: crimson_button crimson_pressure_plate crimson_fence_gate
										notrace = true;
									}
								} else {
									if (mat < 12220) {
										// 12213: crimson_trapdoor:half=top:open=false
										alphatest = true;
										cuboid = true;
									} else {
										// 12220: warped_button warped_pressure_plate warped_fence_gate
										notrace = true;
									}
								}
							}
						} else {
							if (mat < 12293) {
								if (mat < 12265) {
									if (mat < 12264) {
										// 12221: warped_trapdoor:half=top:open=false
										alphatest = true;
										cuboid = true;
									} else {
										// 12264: heavy_weighted_pressure_plate
										notrace = true;
									}
								} else {
									if (mat < 12292) {
										// 12265: iron_trapdoor:half=top:open=false
										alphatest = true;
										cuboid = true;
									} else {
										// 12292: lightning_rod:facing=up lightning_rod:facing=down
										cuboid = true;
										bounds[0].xz = ivec2(7);
										bounds[1].xz = ivec2(9);
									}
								}
							} else {
								if (mat < 12295) {
									if (mat < 12294) {
										// 12293: lightning_rod:facing=east lightning_rod:facing=west
										cuboid = true;
										bounds[0].yz = ivec2(7);
										bounds[1].yz = ivec2(9);
									} else {
										// 12294: lightning_rod:facing=north lightning_rod:facing=south
										cuboid = true;
										bounds[0].xy = ivec2(7);
										bounds[1].xy = ivec2(9);
									}
								} else {
									if (mat < 12312) {
										// 12295: This case is probably superfluous (not in block.properties)
										cuboid = true;
									} else {
										// 12312: light_weighted_pressure_plate
										notrace = true;
									}
								}
							}
						}
					}
				}
			}
		} else {
			if (mat < 14202) {
				if (mat < 14173) {
					if (mat < 14159) {
						if (mat < 14152) {
							if (mat < 12604) {
								if (mat < 12416) {
									// 12380: powder_snow
									full = true;
								} else {
									if (mat < 12480) {
										// 12416: nether_brick_fence
										cuboid = true;
										connectSides = true;
										bounds[0].xz = ivec2(6);
										bounds[1].xz = ivec2(10);
										bounds[0] = ivec3(3, 0, 3);
										bounds[1] = ivec3(13, 1, 13);
									} else {
										// 12480: polished_blackstone_pressure_plate polished_blackstone_button
										notrace = true;
									}
								}
							} else {
								if (mat < 12696) {
									if (mat < 12605) {
										// 12604: redstone_torch:lit=true
										emissive = true;
										cuboid = true;
										#ifdef TORCH_HARDCODED_REDSTONE_COL
										lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
										#endif
										lightlevel = TORCH_BRIGHTNESS_REDSTONE;
										bounds[0] = ivec3(7, 0, 7);
										bounds[1] = ivec3(9, 10, 9);
									} else {
										// 12605: redstone_wall_torch:lit=true
										notrace = true;
										emissive = true;
										#ifdef TORCH_HARDCODED_REDSTONE_COL
										lightcol = vec3(REDSTONE_COL_R, REDSTONE_COL_G, REDSTONE_COL_B);
										#endif
										lightlevel = TORCH_BRIGHTNESS_REDSTONE;
									}
								} else {
									if (mat < 12740) {
										// 12696: sculk_vein
										notrace = true;
									} else {
										// 12740: candle_cake:lit=true white_candle_cake:lit=true orange_candle_cake:lit=true magenta_candle_cake:lit=true light_blue_candle_cake:lit=true yellow_candle_cake:lit=true lime_candle_cake:lit=true pink_candle_cake:lit=true gray_candle_cake:lit=true light_gray_candle_cake:lit=true cyan_candle_cake:lit=true purple_candle_cake:lit=true blue_candle_cake:lit=true brown_candle_cake:lit=true green_candle_cake:lit=true red_candle_cake:lit=true black_candle_cake:lit=true
										emissive = true;
										#ifdef CAKE_HARDCODED_CANDLE_COL
										lightcol = vec3(CANDLE_COL_R, CANDLE_COL_G, CANDLE_COL_B);
										#endif
										lightlevel = CAKE_BRIGHTNESS_CANDLE;
										bounds[0] = ivec3(1, 0, 1);
										bounds[1] = ivec3(15, 8, 15);
									}
								}
							}
						} else {
							if (mat < 14155) {
								if (mat < 14153) {
									// 14152: piston_head:facing=south
									cuboid = true;
									bounds[0].z = 12;
								} else {
									if (mat < 14154) {
										// 14153: piston_head:facing=north
										cuboid = true;
										bounds[1].z = 4;
									} else {
										// 14154: piston_head:facing=west
										cuboid = true;
										bounds[1].x = 4;
									}
								}
							} else {
								if (mat < 14157) {
									if (mat < 14156) {
										// 14155: piston_head:facing=east
										cuboid = true;
										bounds[0].x = 12;
									} else {
										// 14156: oak_trapdoor:open=true:facing=north oak_door:open=false:facing=north oak_door:open=true:facing=west:hinge=left oak_door:open=true:facing=east:hinge=right
										alphatest = true;
										cuboid = true;
									}
								} else {
									if (mat < 14158) {
										// 14157: oak_trapdoor:open=true:facing=south oak_door:open=false:facing=south oak_door:open=true:facing=east:hinge=left oak_door:open=true:facing=west:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14158: oak_trapdoor:open=true:facing=east oak_door:open=false:facing=east oak_door:open=true:facing=north:hinge=left oak_door:open=true:facing=south:hinge=right
										alphatest = true;
										cuboid = true;
									}
								}
							}
						}
					} else {
						if (mat < 14166) {
							if (mat < 14162) {
								if (mat < 14160) {
									// 14159: oak_trapdoor:open=true:facing=west oak_door:open=false:facing=west oak_door:open=true:facing=south:hinge=left oak_door:open=true:facing=north:hinge=right
									alphatest = true;
									cuboid = true;
								} else {
									if (mat < 14161) {
										// 14160: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14161: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								}
							} else {
								if (mat < 14164) {
									if (mat < 14163) {
										// 14162: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14163: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								} else {
									if (mat < 14165) {
										// 14164: spruce_trapdoor:open=true:facing=north spruce_door:open=false:facing=north spruce_door:open=true:facing=west:hinge=left spruce_door:open=true:facing=east:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14165: spruce_trapdoor:open=true:facing=south spruce_door:open=false:facing=south spruce_door:open=true:facing=east:hinge=left spruce_door:open=true:facing=west:hinge=right
										alphatest = true;
										cuboid = true;
									}
								}
							}
						} else {
							if (mat < 14169) {
								if (mat < 14167) {
									// 14166: spruce_trapdoor:open=true:facing=east spruce_door:open=false:facing=east spruce_door:open=true:facing=north:hinge=left spruce_door:open=true:facing=south:hinge=right
									alphatest = true;
									cuboid = true;
								} else {
									if (mat < 14168) {
										// 14167: spruce_trapdoor:open=true:facing=west spruce_door:open=false:facing=west spruce_door:open=true:facing=south:hinge=left spruce_door:open=true:facing=north:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14168: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								}
							} else {
								if (mat < 14171) {
									if (mat < 14170) {
										// 14169: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14170: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								} else {
									if (mat < 14172) {
										// 14171: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14172: birch_trapdoor:open=true:facing=north birch_door:open=false:facing=north birch_door:open=true:facing=west:hinge=left birch_door:open=true:facing=east:hinge=right
										alphatest = true;
										cuboid = true;
									}
								}
							}
						}
					}
				} else {
					if (mat < 14187) {
						if (mat < 14180) {
							if (mat < 14176) {
								if (mat < 14174) {
									// 14173: birch_trapdoor:open=true:facing=south birch_door:open=false:facing=south birch_door:open=true:facing=east:hinge=left birch_door:open=true:facing=west:hinge=right
									alphatest = true;
									cuboid = true;
								} else {
									if (mat < 14175) {
										// 14174: birch_trapdoor:open=true:facing=east birch_door:open=false:facing=east birch_door:open=true:facing=north:hinge=left birch_door:open=true:facing=south:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14175: birch_trapdoor:open=true:facing=west birch_door:open=false:facing=west birch_door:open=true:facing=south:hinge=left birch_door:open=true:facing=north:hinge=right
										alphatest = true;
										cuboid = true;
									}
								}
							} else {
								if (mat < 14178) {
									if (mat < 14177) {
										// 14176: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14177: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								} else {
									if (mat < 14179) {
										// 14178: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14179: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								}
							}
						} else {
							if (mat < 14183) {
								if (mat < 14181) {
									// 14180: jungle_trapdoor:open=true:facing=north jungle_door:open=false:facing=north jungle_door:open=true:facing=west:hinge=left jungle_door:open=true:facing=east:hinge=right
									alphatest = true;
									cuboid = true;
								} else {
									if (mat < 14182) {
										// 14181: jungle_trapdoor:open=true:facing=south jungle_door:open=false:facing=south jungle_door:open=true:facing=east:hinge=left jungle_door:open=true:facing=west:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14182: jungle_trapdoor:open=true:facing=east jungle_door:open=false:facing=east jungle_door:open=true:facing=north:hinge=left jungle_door:open=true:facing=south:hinge=right
										alphatest = true;
										cuboid = true;
									}
								}
							} else {
								if (mat < 14185) {
									if (mat < 14184) {
										// 14183: jungle_trapdoor:open=true:facing=west jungle_door:open=false:facing=west jungle_door:open=true:facing=south:hinge=left jungle_door:open=true:facing=north:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14184: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								} else {
									if (mat < 14186) {
										// 14185: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14186: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								}
							}
						}
					} else {
						if (mat < 14194) {
							if (mat < 14190) {
								if (mat < 14188) {
									// 14187: This case is probably superfluous (not in block.properties)
									alphatest = true;
								} else {
									if (mat < 14189) {
										// 14188: acacia_trapdoor:open=true:facing=north acacia_door:open=false:facing=north acacia_door:open=true:facing=west:hinge=left acacia_door:open=true:facing=east:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14189: acacia_trapdoor:open=true:facing=south acacia_door:open=false:facing=south acacia_door:open=true:facing=east:hinge=left acacia_door:open=true:facing=west:hinge=right
										alphatest = true;
										cuboid = true;
									}
								}
							} else {
								if (mat < 14192) {
									if (mat < 14191) {
										// 14190: acacia_trapdoor:open=true:facing=east acacia_door:open=false:facing=east acacia_door:open=true:facing=north:hinge=left acacia_door:open=true:facing=south:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14191: acacia_trapdoor:open=true:facing=west acacia_door:open=false:facing=west acacia_door:open=true:facing=south:hinge=left acacia_door:open=true:facing=north:hinge=right
										alphatest = true;
										cuboid = true;
									}
								} else {
									if (mat < 14193) {
										// 14192: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14193: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								}
							}
						} else {
							if (mat < 14198) {
								if (mat < 14196) {
									if (mat < 14195) {
										// 14194: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14195: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								} else {
									if (mat < 14197) {
										// 14196: dark_oak_trapdoor:open=true:facing=north dark_oak_door:open=false:facing=north dark_oak_door:open=true:facing=west:hinge=left dark_oak_door:open=true:facing=east:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14197: dark_oak_trapdoor:open=true:facing=south dark_oak_door:open=false:facing=south dark_oak_door:open=true:facing=east:hinge=left dark_oak_door:open=true:facing=west:hinge=right
										alphatest = true;
										cuboid = true;
									}
								}
							} else {
								if (mat < 14200) {
									if (mat < 14199) {
										// 14198: dark_oak_trapdoor:open=true:facing=east dark_oak_door:open=false:facing=east dark_oak_door:open=true:facing=north:hinge=left dark_oak_door:open=true:facing=south:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14199: dark_oak_trapdoor:open=true:facing=west dark_oak_door:open=false:facing=west dark_oak_door:open=true:facing=south:hinge=left dark_oak_door:open=true:facing=north:hinge=right
										alphatest = true;
										cuboid = true;
									}
								} else {
									if (mat < 14201) {
										// 14200: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14201: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								}
							}
						}
					}
				}
			} else {
				if (mat < 14266) {
					if (mat < 14216) {
						if (mat < 14209) {
							if (mat < 14205) {
								if (mat < 14203) {
									// 14202: This case is probably superfluous (not in block.properties)
									alphatest = true;
								} else {
									if (mat < 14204) {
										// 14203: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14204: mangrove_trapdoor:open=true:facing=north mangrove_door:open=false:facing=north mangrove_door:open=true:facing=west:hinge=left mangrove_door:open=true:facing=east:hinge=right
										alphatest = true;
										cuboid = true;
									}
								}
							} else {
								if (mat < 14207) {
									if (mat < 14206) {
										// 14205: mangrove_trapdoor:open=true:facing=south mangrove_door:open=false:facing=south mangrove_door:open=true:facing=east:hinge=left mangrove_door:open=true:facing=west:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14206: mangrove_trapdoor:open=true:facing=east mangrove_door:open=false:facing=east mangrove_door:open=true:facing=north:hinge=left mangrove_door:open=true:facing=south:hinge=right
										alphatest = true;
										cuboid = true;
									}
								} else {
									if (mat < 14208) {
										// 14207: mangrove_trapdoor:open=true:facing=west mangrove_door:open=false:facing=west mangrove_door:open=true:facing=south:hinge=left mangrove_door:open=true:facing=north:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14208: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								}
							}
						} else {
							if (mat < 14212) {
								if (mat < 14210) {
									// 14209: This case is probably superfluous (not in block.properties)
									alphatest = true;
								} else {
									if (mat < 14211) {
										// 14210: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14211: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								}
							} else {
								if (mat < 14214) {
									if (mat < 14213) {
										// 14212: crimson_trapdoor:open=true:facing=north crimson_door:open=false:facing=north crimson_door:open=true:facing=west:hinge=left crimson_door:open=true:facing=east:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14213: crimson_trapdoor:open=true:facing=south crimson_door:open=false:facing=south crimson_door:open=true:facing=east:hinge=left crimson_door:open=true:facing=west:hinge=right
										alphatest = true;
										cuboid = true;
									}
								} else {
									if (mat < 14215) {
										// 14214: crimson_trapdoor:open=true:facing=east crimson_door:open=false:facing=east crimson_door:open=true:facing=north:hinge=left crimson_door:open=true:facing=south:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14215: crimson_trapdoor:open=true:facing=west crimson_door:open=false:facing=west crimson_door:open=true:facing=south:hinge=left crimson_door:open=true:facing=north:hinge=right
										alphatest = true;
										cuboid = true;
									}
								}
							}
						}
					} else {
						if (mat < 14223) {
							if (mat < 14219) {
								if (mat < 14217) {
									// 14216: This case is probably superfluous (not in block.properties)
									alphatest = true;
								} else {
									if (mat < 14218) {
										// 14217: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14218: This case is probably superfluous (not in block.properties)
										alphatest = true;
									}
								}
							} else {
								if (mat < 14221) {
									if (mat < 14220) {
										// 14219: This case is probably superfluous (not in block.properties)
										alphatest = true;
									} else {
										// 14220: warped_trapdoor:open=true:facing=north warped_door:open=false:facing=north warped_door:open=true:facing=west:hinge=left warped_door:open=true:facing=east:hinge=right
										alphatest = true;
									}
								} else {
									if (mat < 14222) {
										// 14221: warped_trapdoor:open=true:facing=south warped_door:open=false:facing=south warped_door:open=true:facing=east:hinge=left warped_door:open=true:facing=west:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14222: warped_trapdoor:open=true:facing=east warped_door:open=false:facing=east warped_door:open=true:facing=north:hinge=left warped_door:open=true:facing=south:hinge=right
										alphatest = true;
										cuboid = true;
									}
								}
							}
						} else {
							if (mat < 14262) {
								if (mat < 14260) {
									// 14223: warped_trapdoor:open=true:facing=west warped_door:open=false:facing=west warped_door:open=true:facing=south:hinge=left warped_door:open=true:facing=north:hinge=right
									alphatest = true;
									cuboid = true;
								} else {
									if (mat < 14261) {
										// 14260: iron_door:open=false:facing=north iron_door:open=true:facing=west:hinge=left iron_door:open=true:facing=east:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14261: iron_door:open=false:facing=south iron_door:open=true:facing=east:hinge=left iron_door:open=true:facing=west:hinge=right
										alphatest = true;
										cuboid = true;
									}
								}
							} else {
								if (mat < 14264) {
									if (mat < 14263) {
										// 14262: iron_door:open=false:facing=east iron_door:open=true:facing=north:hinge=left iron_door:open=true:facing=south:hinge=right
										alphatest = true;
										cuboid = true;
									} else {
										// 14263: iron_door:open=false:facing=west iron_door:open=true:facing=south:hinge=left iron_door:open=true:facing=north:hinge=right
										alphatest = true;
										cuboid = true;
									}
								} else {
									if (mat < 14265) {
										// 14264: iron_trapdoor:open=true:facing=north
										alphatest = true;
										cuboid = true;
									} else {
										// 14265: iron_trapdoor:open=true:facing=south
										alphatest = true;
										cuboid = true;
									}
								}
							}
						}
					}
				} else {
					if (mat < 31008) {
						if (mat < 30004) {
							if (mat < 16153) {
								if (mat < 14267) {
									// 14266: iron_trapdoor:open=true:facing=east
									alphatest = true;
									cuboid = true;
								} else {
									if (mat < 16152) {
										// 14267: iron_trapdoor:open=true:facing=west
										alphatest = true;
										cuboid = true;
									} else {
										// 16152: piston:extended=true:facing=north sticky_piston:extended=true:facing=north
										cuboid = true;
										bounds[0].z = 4;
									}
								}
							} else {
								if (mat < 16155) {
									if (mat < 16154) {
										// 16153: piston:extended=true:facing=south sticky_piston:extended=true:facing=south
										cuboid = true;
										bounds[1].z = 12;
									} else {
										// 16154: piston:extended=true:facing=east sticky_piston:extended=true:facing=east
										cuboid = true;
										bounds[1].x = 12;
									}
								} else {
									if (mat < 30000) {
										// 16155: piston:extended=true:facing=west sticky_piston:extended=true:facing=west
										cuboid = true;
										bounds[0].x = 4;
									} else {
										// 30000: white_stained_glass orange_stained_glass magenta_stained_glass light_blue_stained_glass yellow_stained_glass lime_stained_glass pink_stained_glass gray_stained_glass light_gray_stained_glass cyan_stained_glass purple_stained_glass blue_stained_glass brown_stained_glass green_stained_glass red_stained_glass black_stained_glass
										full = true;
									}
								}
							}
						} else {
							if (mat < 30016) {
								if (mat < 30008) {
									// 30004: white_stained_glass_pane orange_stained_glass_pane magenta_stained_glass_pane light_blue_stained_glass_pane yellow_stained_glass_pane lime_stained_glass_pane pink_stained_glass_pane gray_stained_glass_pane light_gray_stained_glass_pane cyan_stained_glass_pane purple_stained_glass_pane blue_stained_glass_pane brown_stained_glass_pane green_stained_glass_pane red_stained_glass_pane black_stained_glass_pane
									cuboid = true;
									connectSides = true;
									bounds[0] = ivec3(7, 0, 7);
									bounds[1] = ivec3(9, 16, 9);
								} else {
									if (mat < 30012) {
										// 30008: tinted_glass
										full = true;
									} else {
										// 30012: slime_block
										full = true;
									}
								}
							} else {
								if (mat < 31000) {
									if (mat < 30020) {
										// 30016: honey_block
										full = true;
									} else {
										// 30020: nether_portal
										emissive = true;
										#ifdef HARDCODED_PORTAL_COL
										lightcol = vec3(PORTAL_COL_R, PORTAL_COL_G, PORTAL_COL_B);
										#endif
										lightlevel = BRIGHTNESS_PORTAL;
									}
								} else {
									if (mat < 31004) {
										// 31000: water flowing_water
										cuboid = true;
										bounds[1].y = int(16*fract(pos.y + 0.03125));
									} else {
										// 31004: ice frosted_ice
										full = true;
									}
								}
							}
						}
					} else {
						if (mat < 50048) {
							if (mat < 50000) {
								if (mat < 31012) {
									// 31008: glass
									full = true;
								} else {
									if (mat < 31016) {
										// 31012: glass_pane
										cuboid = true;
										connectSides = true;
										bounds[0] = ivec3(7, 0, 7);
										bounds[1] = ivec3(9, 16, 9);
									} else {
										// 31016: beacon
										emissive = true;
										cuboid = true;
										#ifdef HARDCODED_BEACON_COL
										lightcol = vec3(BEACON_COL_R, BEACON_COL_G, BEACON_COL_B);
										#endif
										lightlevel = BRIGHTNESS_BEACON;
										bounds[0] = ivec3(2, 0, 2);
										bounds[1] = ivec3(14, 14, 14);
									}
								}
							} else {
								if (mat < 50012) {
									if (mat < 50004) {
										// 50000: end_crystal
										emissive = true;
										#ifdef HARDCODED_ENDCRYSTAL_COL
										lightcol = vec3(ENDCRYSTAL_COL_R, ENDCRYSTAL_COL_G, ENDCRYSTAL_COL_B);
										#endif
										lightlevel = BRIGHTNESS_ENDCRYSTAL;
									} else {
										// 50004: lightning_bolt
										emissive = true;
										#ifdef HARDCODED_LIGHTNING_COL
										lightcol = vec3(LIGHTNING_COL_R, LIGHTNING_COL_G, LIGHTNING_COL_B);
										#endif
										lightlevel = BRIGHTNESS_LIGHTNING;
									}
								} else {
									if (mat < 50020) {
										// 50012: glow_item_frame
										emissive = true;
										#ifdef HARDCODED_ITEMFRAME_COL
										lightcol = vec3(ITEMFRAME_COL_R, ITEMFRAME_COL_G, ITEMFRAME_COL_B);
										#endif
										lightlevel = BRIGHTNESS_ITEMFRAME;
									} else {
										// 50020: blaze
										emissive = true;
										#ifdef HARDCODED_BLAZE_COL
										lightcol = vec3(BLAZE_COL_R, BLAZE_COL_G, BLAZE_COL_B);
										#endif
										lightlevel = BRIGHTNESS_BLAZE;
									}
								}
							}
						} else {
							if (mat < 60012) {
								if (mat < 60000) {
									if (mat < 50080) {
										// 50048: glow_squid
										emissive = true;
										#ifdef HARDCODED_SQUID_COL
										lightcol = vec3(SQUID_COL_R, SQUID_COL_G, SQUID_COL_B);
										#endif
										lightlevel = BRIGHTNESS_SQUID;
									} else {
										// 50080: allay
										emissive = true;
										#ifdef HARDCODED_ALLAY_COL
										lightcol = vec3(ALLAY_COL_R, ALLAY_COL_G, ALLAY_COL_B);
										#endif
										lightlevel = BRIGHTNESS_ALLAY;
									}
								} else {
									if (mat < 60008) {
										// 60000: end_portal end_gateway
										emissive = true;
										full = true;
										#ifdef PORTAL_HARDCODED_END_COL
										lightcol = vec3(END_COL_R, END_COL_G, END_COL_B);
										#endif
										lightlevel = PORTAL_BRIGHTNESS_END;
									} else {
										// 60008: chest trapped_chest
										cuboid = true;
										bounds[0] = ivec3(1, 0, 1);
										bounds[1] = ivec3(15, 14, 15);
									}
								}
							} else {
								if (mat < 60017) {
									if (mat < 60016) {
										// 60012: ender_chest
										emissive = true;
										cuboid = true;
										#ifdef CHEST_HARDCODED_END_COL
										lightcol = vec3(END_COL_R, END_COL_G, END_COL_B);
										#endif
										lightlevel = CHEST_BRIGHTNESS_END;
										bounds[0] = ivec3(1, 0, 1);
										bounds[1] = ivec3(15, 14, 15);
									} else {
										// 60016: shulker_box white_shulker_box orange_shulker_box magenta_shulker_box light_blue_shulker_box yellow_shulker_box lime_shulker_box pink_shulker_box gray_shulker_box light_gray_shulker_box cyan_shulker_box purple_shulker_box blue_shulker_box brown_shulker_box green_shulker_box red_shulker_box black_shulker_box
										full = true;
									}
								} else {
									if (mat < 60020) {
										// 60017: white_bed orange_bed magenta_bed light_blue_bed yellow_bed lime_bed pink_bed gray_bed light_gray_bed cyan_bed purple_bed blue_bed brown_bed green_bed red_bed black_bed
										cuboid = true;
										bounds[0].y = 3;
										bounds[1].y = 9;
									} else {
										// 60020: conduit
										emissive = true;
										#ifdef HARDCODED_CONDUIT_COL
										lightcol = vec3(CONDUIT_COL_R, CONDUIT_COL_G, CONDUIT_COL_B);
										#endif
										lightlevel = BRIGHTNESS_CONDUIT;
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

// Manual Additions
if (cuboid && bounds[0] == ivec3(0) && bounds[1] == ivec3(1)) {
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
