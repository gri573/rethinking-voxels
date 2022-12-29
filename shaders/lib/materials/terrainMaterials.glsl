if (mat < 10512) {
    if (mat < 10256) {
        if (mat < 10128) {
            if (mat < 10064) {
                if (mat < 10032) {
                    if (mat < 10016) {
                        if (mat < 10008) {
                            if (mat == 10000) { // No directional shading
                                noDirectionalShading = true;
                            } 
                            else if (mat == 10004) { // Grounded Waving Foliage
                                subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;

                                DoFoliageColorTweaks(color.rgb, shadowMult, snowMinNdotU, lViewPos);
                            }
                        } else {
                            if (mat == 10008) { // Leaves
                                #include "/lib/materials/specificMaterials/leaves.glsl"

                                #if SHADOW_QUALITY < 3
                                    shadowMult = vec3(sqrt1(max0(max(lmCoordM.y, min1(lmCoordM.x * 2.0)) - 0.95) * 20.0)); //dup5823
                                #endif
                            }
                            else /*if (mat == 10012)*/ { // Vine
                                #include "/lib/materials/specificMaterials/leaves.glsl"
                                
                                subsurfaceMode = 3;
                            }
                        }
                    } else {
                        if (mat < 10024) {
                            if (mat == 10016) { // Non-waving Foliage
                                subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
                            }
                            else /*if (mat == 10020)*/ { // Upper Waving Foliage
                                subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;

                                DoFoliageColorTweaks(color.rgb, shadowMult, snowMinNdotU, lViewPos);
                            }
                        } else {
                            if (mat == 10024) { // Brewing Stand
                                vec3 worldPos = playerPos + cameraPosition;
                                vec3 fractPos = fract(worldPos.xyz);
                                vec3 coordM = abs(fractPos.xyz - 0.5);
                                float cLength = dot(coordM, coordM) * 1.3333333;
                                cLength = pow2(1.0 - cLength);

                                if (color.r + color.g > color.b * 3.0 && max(coordM.x, coordM.z) < 0.07) {
                                    emission = 2.2 * pow2(cLength);
                                } else {
                                    lmCoordM.x = max(lmCoordM.x * 0.9, cLength);
                                    
                                    #include "/lib/materials/specificMaterials/cobblestone.glsl"
                                }
                            }
                            else /*if (mat == 10028)*/ { // Hay Block
                                smoothnessG = pow2(color.r) * 0.5;
                                highlightMult *= 1.5;
                                smoothnessD = float(color.r > color.g * 2.0) * 0.3;
                            }
                        }
                    }
                } else {
                    if (mat < 10048) {
                        if (mat < 10040) {
                            if (mat == 10032) { // Stone Bricks++
                                smoothnessG = pow2(pow2(color.g)) * 2.0;
                                smoothnessG = min1(smoothnessG);
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.66;
                                #endif
                            }
                            else /*if (mat == 10036)*/ { // Anvil+
                                #include "/lib/materials/specificMaterials/anvil.glsl"
                            }
                        } else {
                            if (mat == 10040) { // Rails
                                noSmoothLighting = true;
                                if (color.r > 0.1 && color.g + color.b < 0.1) { // Redstone Parts
                                    noSmoothLighting = true; noDirectionalShading = true;
                                    lmCoordM.x = min(lmCoordM.x * 0.9, 0.77);

                                    if (color.r > 0.5) {
                                        color.rgb *= color.rgb;
                                        emission = 8.0 * color.r;
                                    } else if (color.r > color.g * 2.0) {
                                        materialMask = OSIEBCA * 5.0; // Redstone Fresnel

                                        float factor = pow2(color.r);
                                        smoothnessG = 0.4;
                                        highlightMult = factor + 0.4;

                                        smoothnessD = factor * 0.7 + 0.3;
                                    }
                                } else if (abs(color.r - color.b) < 0.15) { // Iron Parts
                                    #include "/lib/materials/specificMaterials/ironBlock.glsl"
                                } else if (color.g > color.b * 2.0) { // Gold Parts
                                    #include "/lib/materials/specificMaterials/goldBlock.glsl"
                                } else { // Wood Parts
                                    #include "/lib/materials/specificMaterials/planks/oakPlanks.glsl"
                                }
                            }
                            else /*if (mat == 10044)*/ { // Empty Cauldron, Hopper
                                noSmoothLighting = true;
                                lmCoordM.x = min(lmCoordM.x, 0.9333);
                                
                                #include "/lib/materials/specificMaterials/anvil.glsl"
                            }
                        }
                    } else {
                        if (mat < 10056) {
                            if (mat == 10048) { // Water Cauldron
                                noSmoothLighting = true;
                                lmCoordM.x = min(lmCoordM.x, 0.9333);
                                
                                vec3 worldPos = playerPos + cameraPosition;
                                vec3 fractPos = fract(worldPos.xyz);
                                vec2 coordM = abs(fractPos.xz - 0.5);
                                if (max(coordM.x, coordM.y) < 0.375 &&
                                    fractPos.y > 0.3 &&
                                    NdotU > 0.9) {
                                    
                                    vec3 colorP = color.rgb / glColor.rgb;
                                    smoothnessG = min(pow2(pow2(dot(colorP.rgb, colorP.rgb) * 0.4)), 1.0);
                                    highlightMult = 3.25;
                                    smoothnessD = 0.8;

                                    #include "/lib/materials/specificMaterials/translucents/water.glsl"

                                    #ifdef COATED_TEXTURES
                                        noiseFactor = 0.0;
                                    #endif
                                } else {
                                    #include "/lib/materials/specificMaterials/anvil.glsl"
                                }
                            }
                            else /*if (mat == 10052)*/ { // Powder Snow Cauldron
                                noSmoothLighting = true;
                                lmCoordM.x = min(lmCoordM.x, 0.9333);
                                
                                vec3 worldPos = playerPos + cameraPosition;
                                vec3 fractPos = fract(worldPos.xyz);
                                vec2 coordM = abs(fractPos.xz - 0.5);
                                if (max(coordM.x, coordM.y) < 0.375 &&
                                    fractPos.y > 0.3 &&
                                    NdotU > 0.9) {

                                    #include "/lib/materials/specificMaterials/snow.glsl"
                                } else {
                                    #include "/lib/materials/specificMaterials/anvil.glsl"
                                }
                            }
                        } else {
                            if (mat == 10056) { // Lava Cauldron
                                noSmoothLighting = true;
                                lmCoordM.x = min(lmCoordM.x, 0.9333);

                                vec3 worldPos = playerPos + cameraPosition;
                                vec3 fractPos = fract(worldPos.xyz);
                                vec2 coordM = abs(fractPos.xz - 0.5);
                                if (max(coordM.x, coordM.y) < 0.375 &&
                                    fractPos.y > 0.3 &&
                                    NdotU > 0.9) {

                                    #include "/lib/materials/specificMaterials/lava.glsl"
                                } else {
                                    #include "/lib/materials/specificMaterials/anvil.glsl"
                                }
                            }
                            else /*if (mat == 10060)*/ { // Bamboo
                                if (absMidCoordPos.x > 0.005)
                                    subsurfaceMode = 1, noSmoothLighting = true, noDirectionalShading = true;
                            }
                        }
                    }
                }
            } else {
                if (mat < 10096) {
                    if (mat < 10080) {
                        if (mat < 10072) {
                            if (mat == 10064) { // Lectern
                                #include "/lib/materials/specificMaterials/planks/oakPlanks.glsl"
                            }
                            else /*if (mat == 10068)*/ { // Lava
                                #include "/lib/materials/specificMaterials/lava.glsl"
                            }
                        } else {
                            if (mat == 10072) { // Fire
                                noSmoothLighting = true, noDirectionalShading = true;
                                emission = 1.5;
                                color.rgb *= sqrt1(GetLuminance(color.rgb));
                            }
                            else /*if (mat == 10076)*/ { // Soul Fire
                                noSmoothLighting = true, noDirectionalShading = true;
                                emission = 1.0;
                                color.rgb = pow1_5(color.rgb);
                            }
                        }
                    } else {
                        if (mat < 10088) {
                            if (mat == 10080) { // Stone+, Coal Ore, Smooth Stone+, Grindstone, Stonecutter
                                #include "/lib/materials/specificMaterials/stone.glsl"
                            }
                            else /*if (mat == 10084)*/ { // Granite+
                                smoothnessG = pow2(pow2(color.r)) * 0.5;
                                smoothnessD = smoothnessG;
                            }
                        } else {
                            if (mat == 10088) { // Diorite+
                                smoothnessG = pow2(color.g) * 0.5;
                                smoothnessD = smoothnessG;

                                DoBrightBlockTweaks(shadowMult, highlightMult);
                            }
                            else /*if (mat == 10092)*/ { // Andesite+
                                smoothnessG = pow2(pow2(color.g));
                                smoothnessD = smoothnessG;
                            }
                        }
                    }
                } else {
                    if (mat < 10112) {
                        if (mat < 10104) {
                            if (mat == 10096) { // Polished Granite+
                                smoothnessG = 0.1 + color.r * 0.4;
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.77;
                                #endif
                            }
                            else /*if (mat == 10100)*/ { // Polished Diorite+
                                smoothnessG = pow2(color.g) * 0.7;
                                smoothnessD = smoothnessG;
                                
                                DoBrightBlockTweaks(shadowMult, highlightMult);

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.77;
                                #endif
                            }
                        } else {
                            if (mat == 10104) { // Polished Andesite+, Packed Mud, Mud Bricks+, Bricks+
                                smoothnessG = pow2(color.g);
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.77;
                                #endif
                            }
                            else /*if (mat == 10108)*/ { // Deepslate:Non-polished Variants, Deepslate Coal Ore
                                #include "/lib/materials/specificMaterials/deepslate.glsl"
                            }
                        }
                    } else {
                        if (mat < 10120) {
                            if (mat == 10112) { // Deepslate:Polished Variants, Mud, Mangrove Roots, Muddy Mangrove Roots
                                smoothnessG = pow2(color.g) * 2.0;
                                smoothnessG = min1(smoothnessG);
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.77;
                                #endif
                            }
                            else /*if (mat == 10116)*/ { // Calcite
                                highlightMult = pow2(color.g) + 1.0;
                                smoothnessG = 1.0 - color.g * 0.5;
                                smoothnessD = smoothnessG;
                            }
                        } else {
                            if (mat == 10120) { // Dripstone+, Daylight Detector
                                smoothnessG = color.r * 0.35 + 0.2;
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.66;
                                #endif
                            }
                            else /*if (mat == 10124)*/ { // Snowy Variants of Grass Block, Podzol, Mycelium
                                float dotColor = dot(color.rgb, color.rgb);
                                if (dotColor > 1.5) { // Snowy Variants:Snowy Part
                                    #include "/lib/materials/specificMaterials/snow.glsl"
                                } else { // Snowy Variants:Dirt Part
                                    #include "/lib/materials/specificMaterials/dirt.glsl"
                                }
                            }
                        }
                    }
                }
            }
        } else {
            if (mat < 10192) {
                if (mat < 10160) {
                    if (mat < 10144) {
                        if (mat < 10136) {
                            if (mat == 10128) { // Dirt, Coarse Dirt, Rooted Dirt, Podzol:Normal, Mycelium:Normal, Dirt Path, Farmland:Dry
                                #include "/lib/materials/specificMaterials/dirt.glsl"
                            }
                            else /*if (mat == 10132)*/ { // Grass Block:Normal
                                if (glColor.b < 0.999) { // Grass Block:Normal:Grass Part
                                    smoothnessG = pow2(color.g);

		                            #ifdef SNOWY_WORLD
                                        snowMinNdotU = min(pow2(pow2(color.g)) * 1.9, 0.1);
                                        color.rgb = color.rgb * 0.5 + 0.5 * (color.rgb / glColor.rgb);
                                    #endif
                                } else { //Grass Block:Normal:Dirt Part
                                    #include "/lib/materials/specificMaterials/dirt.glsl"
                                }
                            }
                        } else {
                            if (mat == 10136) { // Farmland:Wet
                                if (NdotU > 0.99) { // Farmland:Wet:Top Part
                                    smoothnessG = clamp(pow2(pow2(1.0 - color.r)) * 2.5, 0.5, 1.0);
                                    highlightMult = 0.5 + smoothnessG * smoothnessG * 2.0;
                                    smoothnessD = smoothnessG * 0.75;
                                } else { // Farmland:Wet:Dirt Part
                                    #include "/lib/materials/specificMaterials/dirt.glsl"
                                }
                            }
                            else /*if (mat == 10140)*/ { // Netherrack
                                #include "/lib/materials/specificMaterials/netherrack.glsl"
                            }
                        }
                    } else {
                        if (mat < 10152) {
                            if (mat == 10144) { // Warped Nylium, Warped Wart Block
                                if (color.g == color.b && color.g > 0.0001) { // Warped Nylium:Netherrack Part
                                    #include "/lib/materials/specificMaterials/netherrack.glsl"
                                } else { // Warped Nylium:Nylium Part, Warped Wart Block
                                    smoothnessG = color.g * 0.5;
                                    smoothnessD = smoothnessG;

                                    #ifdef COATED_TEXTURES
                                        noiseFactor = 0.77;
                                    #endif
                                }
                            }
                            else /*if (mat == 10148)*/ { // Crimson Nylium, Nether Wart Block
                                if (color.g == color.b && color.g > 0.0001 && color.r < 0.522) { // Crimson Nylium:Netherrack Part
                                    #include "/lib/materials/specificMaterials/netherrack.glsl"
                                } else { // Crimson Nylium:Nylium Part, Nether Wart Block
                                    smoothnessG = color.r * 0.5;
                                    smoothnessD = smoothnessG;

                                    #ifdef COATED_TEXTURES
                                        noiseFactor = 0.77;
                                    #endif
                                }
                            }
                        } else {
                            if (mat == 10152) { // Cobblestone+, Mossy Cobblestone+, Furnace:Unlit, Smoker:Unlit, Blast Furnace:Unlit, Moss Block+, Lodestone, Lever, Piston, Sticky Piston, Dispenser, Dropper
                                #include "/lib/materials/specificMaterials/cobblestone.glsl"
                            }
                            else /*if (mat == 10156)*/ { // Oak Planks++:Clean Variants, Bookshelf, Crafting Table, Tripwire Hook
                                #include "/lib/materials/specificMaterials/planks/oakPlanks.glsl"
                            }
                        }
                    }
                } else {
                    if (mat < 10176) {
                        if (mat < 10168) {
                            if (mat == 10160) { // Oak Log, Oak Wood
                                if (color.g > 0.48 ||
                                    CheckForColor(color.rgb, vec3(126, 98, 55)) ||
                                    CheckForColor(color.rgb, vec3(150, 116, 65))) { // Oak Log:Clean Part
                                    #include "/lib/materials/specificMaterials/planks/oakPlanks.glsl"
                                } else { // Oak Log:Wood Part, Oak Wood
                                    #include "/lib/materials/specificMaterials/oakWood.glsl"
                                }
                            }
                            else /*if (mat == 10164)*/ { // Spruce Planks++:Clean Variants
                                #include "/lib/materials/specificMaterials/planks/sprucePlanks.glsl"
                            }
                        } else {
                            if (mat == 10168) { // Spruce Log, Spruce Wood
                                if (color.g > 0.25) { // Spruce Log:Clean Part
                                    #include "/lib/materials/specificMaterials/planks/sprucePlanks.glsl"
                                } else { // Spruce Log:Wood Part, Spruce Wood
                                    smoothnessG = pow2(color.g) * 2.5;
                                    smoothnessG = min1(smoothnessG);
                                    smoothnessD = smoothnessG;
                                }
                            }
                            else /*if (mat == 10172)*/ { // Birch Planks++:Clean Variants, Scaffolding, Loom
                                #include "/lib/materials/specificMaterials/planks/birchPlanks.glsl"
                            }
                        }
                    } else {
                        if (mat < 10184) {
                            if (mat == 10176) { // Birch Log, Birch Wood
                                if (color.r - color.b > 0.15) { // Birch Log:Clean Part
                                    #include "/lib/materials/specificMaterials/planks/birchPlanks.glsl"
                                } else { // Birch Log:Wood Part, Birch Wood
                                    smoothnessG = pow2(color.g) * 0.25;
                                    smoothnessD = smoothnessG;

                                    #ifdef COATED_TEXTURES
                                        noiseFactor = 1.25;
                                    #endif
                                }
                            }
                            else /*if (mat == 10180)*/ { // Jungle Planks++:Clean Variants, Composter
                                #include "/lib/materials/specificMaterials/planks/junglePlanks.glsl"
                            }
                        } else {
                            if (mat == 10184) { // Jungle Log, Jungle Wood
                                if (color.g > 0.405) { // Jungle Log:Clean Part
                                    #include "/lib/materials/specificMaterials/planks/junglePlanks.glsl"
                                } else { // Jungle Log:Wood Part, Jungle Wood
                                    smoothnessG = pow2(pow2(color.g)) * 5.0;
                                    smoothnessG = min1(smoothnessG);
                                    smoothnessD = smoothnessG;

                                    #ifdef COATED_TEXTURES
                                        noiseFactor = 0.77;
                                    #endif
                                }
                            }
                            else /*if (mat == 10188)*/ { // Acacia Planks++:Clean Variants
                                #include "/lib/materials/specificMaterials/planks/acaciaPlanks.glsl"
                            }
                        }
                    }
                }
            } else {
                if (mat < 10224) {
                    if (mat < 10208) {
                        if (mat < 10200) {
                            if (mat == 10192) { // Acacia Log, Acacia Wood
                                if (color.r - color.b > 0.2) { // Acacia Log:Clean Part
                                    #include "/lib/materials/specificMaterials/planks/acaciaPlanks.glsl"
                                } else { // Acacia Log:Wood Part, Acacia Wood
                                    smoothnessG = pow2(color.b) * 1.3;
                                    smoothnessG = min1(smoothnessG);
                                    smoothnessD = smoothnessG;

                                    #ifdef COATED_TEXTURES
                                        noiseFactor = 0.66;
                                    #endif
                                }
                            }
                            else /*if (mat == 10196)*/ { // Dark Oak Planks++:Clean Variants
                                #include "/lib/materials/specificMaterials/planks/darkOakPlanks.glsl"
                            }
                        } else {
                            if (mat == 10200) { // Dark Oak Log, Dark Oak Wood
                                if (color.r - color.g > 0.08 ||
                                    CheckForColor(color.rgb, vec3(48, 30, 14))) { // Dark Oak Log:Clean Part
                                    #include "/lib/materials/specificMaterials/planks/darkOakPlanks.glsl"
                                } else { // Dark Oak Log:Wood Part, Dark Oak Wood
                                    smoothnessG = color.r * 0.4;
                                    smoothnessD = smoothnessG;
                                }
                            }
                            else /*if (mat == 10204)*/ { // Mangrove Planks++:Clean Variants
                                #include "/lib/materials/specificMaterials/planks/mangrovePlanks.glsl"
                            }
                        }
                    } else {
                        if (mat < 10216) {
                            if (mat == 10208) { // Mangrove Log, Mangrove Wood
                                if (color.r - color.g > 0.2) { // Mangrove Log:Clean Part
                                    #include "/lib/materials/specificMaterials/planks/mangrovePlanks.glsl"
                                } else { // Mangrove Log:Wood Part, Mangrove Wood
                                    smoothnessG = pow2(color.r) * 0.6;
                                    smoothnessD = smoothnessG;
                                }
                            }
                            else /*if (mat == 10212)*/ { // Crimson Planks++:Clean Variants
                                #include "/lib/materials/specificMaterials/planks/crimsonPlanks.glsl"
                            }
                        } else {
                            if (mat == 10216) { // Crimson Stem, Crimson Hyphae
                                if (color.r / color.b < 3.0) { // Crimson Stem:Flat Part, Crimson Hyphae:Flat Part
                                    #include "/lib/materials/specificMaterials/planks/crimsonPlanks.glsl"
                                } else { // Crimson Stem:Emissive Part, Crimson Hyphae:Emissive Part
                                    emission = pow2(color.r) * 6.5;
                                }
                            }
                            else /*if (mat == 10220)*/ { // Warped Planks++:Clean Variants
                                #include "/lib/materials/specificMaterials/planks/warpedPlanks.glsl"
                            }
                        }
                    }
                } else {
                    if (mat < 10240) {
                        if (mat < 10232) {
                            if (mat == 10224) { // Warped Stem, Warped Hyphae
                                if (color.r > 0.12 &&
                                    !CheckForColor(color.rgb, vec3(69, 45, 92))) { // Warped Stem:Flat Part, Warped Hyphae:Flat Part
                                    #include "/lib/materials/specificMaterials/planks/warpedPlanks.glsl"
                                } else { // Warped Stem:Emissive Part, Warped Hyphae:Emissive Part
                                    emission = pow2(color.g + 0.2 * color.b) * 4.5 + 0.15;
                                }
                            }
                            else /*if (mat == 10228)*/ { // Bedrock
                                smoothnessG = color.b * 0.2 + 0.1;
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 1.5;
                                #endif
                            }
                        } else {
                            if (mat == 10232) { // Sand
                                highlightMult = 2.0;
                                smoothnessG = pow(color.g, 16.0) * 2.0;
                                smoothnessG = min1(smoothnessG);
                                smoothnessD = smoothnessG * 0.7;

                                DoBrightBlockTweaks(shadowMult, highlightMult);

                                #if RAIN_PUDDLES >= 1
                                    noPuddles = 1.0;
                                #endif
                            }
                            else /*if (mat == 10236)*/ { // Red Sand
                                highlightMult = 2.0;
                                smoothnessG = pow(color.r * 1.05, 16.0) * 2.0;
                                smoothnessG = min1(smoothnessG);
                                smoothnessD = smoothnessG * 0.7;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.77;
                                #endif

                                #if RAIN_PUDDLES >= 1
                                    noPuddles = 1.0;
                                #endif
                            }
                        }
                    } else {
                        if (mat < 10248) {
                            if (mat == 10240) { // Sandstone+
                                highlightMult = 2.0;
                                smoothnessG = pow2(pow2(color.g)) * 0.5;
                                smoothnessG = min1(smoothnessG);
                                smoothnessD = smoothnessG * 0.7;

                                DoBrightBlockTweaks(shadowMult, highlightMult);

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.77;
                                #endif
                            }
                            else /*if (mat == 10244)*/ { // Red Sandstone+
                                highlightMult = 2.0;
                                smoothnessG = pow2(pow2(color.r * 1.05)) * 0.5;
                                smoothnessG = min1(smoothnessG);
                                smoothnessD = smoothnessG * 0.7;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.5;
                                #endif
                            }
                        } else {
                            if (mat == 10248) { // Netherite Block
                                smoothnessG = pow2(color.r * 2.0);
                                smoothnessG = min1(smoothnessG);
                                highlightMult = smoothnessG * 2.0;
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.33;
                                #endif
                            }
                            else /*if (mat == 10252)*/ { // Ancient Debris
                                smoothnessG = pow2(color.r);
                                smoothnessG = min1(smoothnessG);
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 1.5;
                                #endif
                                
                                #if GLOWING_ORES >= 2
                                    emission = min(pow2(color.g * 6.0), 8.0);
                                    color.rgb *= color.rgb;
                                #endif
                            }
                        }
                    }
                }
            }
        }
    } else {
        if (mat < 10384) {
            if (mat < 10320) {
                if (mat < 10288) {
                    if (mat < 10272) {
                        if (mat < 10264) {
                            if (mat == 10256) { // Iron Bars
                                noSmoothLighting = true;
                                #include "/lib/materials/specificMaterials/ironBlock.glsl"
                            }
                            else /*if (mat == 10260)*/ { // Iron Door
                                noSmoothLighting = true;
                                #include "/lib/materials/specificMaterials/ironBlock.glsl"
                                color.rgb *= 0.8;
                            }
                        } else {
                            if (mat == 10264) { // Iron Block, Iron Trapdoor, Heavy Weighted Pressure Plate
                                #include "/lib/materials/specificMaterials/ironBlock.glsl"
                                color.rgb *= max(color.r, 0.85) * 0.9;
                            }
                            else /*if (mat == 10268)*/ { // Raw Iron Block
                                #include "/lib/materials/specificMaterials/rawIronBlock.glsl"
                            }
                        }
                    } else {
                        if (mat < 10280) {
                            if (mat == 10272) { // Iron Ore
                                if (color.r != color.g) { // Iron Ore:Raw Iron Part
                                    #include "/lib/materials/specificMaterials/rawIronBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        if (color.r - color.b > 0.15) {
                                            emission = color.r * 1.5;
                                            color.rgb *= color.rgb;
                                        }
                                    #endif
                                } else { // Iron Ore:Stone Part
                                    #include "/lib/materials/specificMaterials/stone.glsl"
                                }
                            }
                            else /*if (mat == 10276)*/ { // Deepslate Iron Ore
                                if (color.r != color.g) { // Deepslate Iron Ore:Raw Iron Part
                                    #include "/lib/materials/specificMaterials/rawIronBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        if (color.r - color.b > 0.15) {
                                            emission = color.r * 1.5;
                                            color.rgb *= color.rgb;
                                        }
                                    #endif
                                } else { // Deepslate Iron Ore:Deepslate Part
                                    #include "/lib/materials/specificMaterials/deepslate.glsl"
                                }
                            }
                        } else {
                            if (mat == 10280) { // Raw Copper Block
                                #include "/lib/materials/specificMaterials/rawCopperBlock.glsl"
                            }
                            else /*if (mat == 10284)*/ { // Copper Ore
                                if (color.r != color.g) { // Copper Ore:Raw Copper Part
                                    #include "/lib/materials/specificMaterials/rawCopperBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        if (max(color.r * 0.5, color.g) - color.b > 0.05) {
                                            emission = color.r * 2.0 + 0.5;
                                            color.rgb *= color.rgb;
                                        }
                                    #endif
                                } else { // Copper Ore:Stone Part
                                    #include "/lib/materials/specificMaterials/stone.glsl"
                                }
                            }
                        }
                    }
                } else {
                    if (mat < 10304) {
                        if (mat < 10296) {
                            if (mat == 10288) { // Deepslate Copper Ore
                                if (color.r != color.g) { // Deepslate Copper Ore:Raw Copper Part
                                    #include "/lib/materials/specificMaterials/rawCopperBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        if (max(color.r * 0.5, color.g) - color.b > 0.05) {
                                            emission = color.r * 2.0 + 0.5;
                                            color.rgb *= color.rgb;
                                        }
                                    #endif
                                } else { // Deepslate Copper Ore:Deepslate Part
                                    #include "/lib/materials/specificMaterials/deepslate.glsl"
                                }
                            }
                            else /*if (mat == 10292)*/ { // Copper Block++:All Non-raw Variants
                                materialMask = OSIEBCA * 2.0; // Copper Fresnel
                                smoothnessG = pow2(pow2(color.r)) + pow2(max0(color.g - color.r * 0.5)) * 0.3;
                                smoothnessG = min1(smoothnessG);
                                smoothnessD = smoothnessG;
                                color.rgb *= 0.8 + color.r * 0.3;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.5;
                                #endif
                            }
                        } else {
                            if (mat == 10296) { // Raw Gold Block
                                #include "/lib/materials/specificMaterials/rawGoldBlock.glsl"
                            }
                            else /*if (mat == 10300)*/ { // Gold Ore
                                if (color.r != color.g || color.r > 0.99) { // Gold Ore:Raw Gold Part
                                    #include "/lib/materials/specificMaterials/rawGoldBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        if (color.g - color.b > 0.15) {
                                            emission = color.r + 1.0;
                                            color.rgb *= color.rgb;
                                        }
                                    #endif
                                } else { // Gold Ore:Stone Part
                                    #include "/lib/materials/specificMaterials/stone.glsl"
                                }
                            }
                        }
                    } else {
                        if (mat < 10312) {
                            if (mat == 10304) { // Deepslate Gold Ore
                                if (color.r != color.g || color.r > 0.99) { // Deepslate Gold Ore:Raw Gold Part
                                    #include "/lib/materials/specificMaterials/rawGoldBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        if (color.g - color.b > 0.15) {
                                            emission = color.r + 1.0;
                                            color.rgb *= color.rgb;
                                        }
                                    #endif
                                } else { // Deepslate Gold Ore:Deepslate Part
                                    #include "/lib/materials/specificMaterials/deepslate.glsl"
                                }
                            }
                            else /*if (mat == 10308)*/ { // Nether Gold Ore
                                if (color.g != color.b) { // Nether Gold Ore:Raw Gold Part
                                    #include "/lib/materials/specificMaterials/rawGoldBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        emission = color.g * 1.5;
                                    #endif
                                } else { // Nether Gold Ore:Netherrack Part
                                    #include "/lib/materials/specificMaterials/netherrack.glsl"
                                }
                            }
                        } else {
                            if (mat == 10312) { // Gold Block, Light Weighted Pressure Plate
                                #include "/lib/materials/specificMaterials/goldBlock.glsl"
                            }
                            else /*if (mat == 10316)*/ { // Diamond Block
                                #include "/lib/materials/specificMaterials/diamondBlock.glsl"
                            }
                        }
                    }
                }
            } else {
                if (mat < 10352) {
                    if (mat < 10336) {
                        if (mat < 10328) {
                            if (mat == 10320) { // Diamond Ore
                                if (color.r != color.g && (color.b / color.r > 1.5 || color.b > 0.8)) { // Diamond Ore:Diamond Part
                                    #include "/lib/materials/specificMaterials/diamondBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        emission = color.g + 1.5;
                                        color.rgb *= color.rgb;
                                    #endif
                                } else { // Diamond Ore:Stone Part, Diamond Ore:StoneToDiamond part
                                    #include "/lib/materials/specificMaterials/stone.glsl"
                                }
                            }
                            else /*if (mat == 10324)*/ { // Deepslate Diamond Ore
                                if (color.r == color.g) { // Deepslate Diamond Ore:Deepslate Part
                                    #include "/lib/materials/specificMaterials/deepslate.glsl"
                                } else if (color.b / color.r < 1.5 && color.b < 0.8) { // Deepslate Diamond Ore:DeepslateToDiamond Part
                                    #include "/lib/materials/specificMaterials/stone.glsl"
                                } else { // Deepslate Diamond Ore:Diamond Part
                                    #include "/lib/materials/specificMaterials/diamondBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        emission = color.g + 1.5;
                                        color.rgb *= color.rgb;
                                    #endif
                                }
                            }
                        } else {
                            if (mat == 10328) { // Amethyst Block, Budding Amethyst
                                materialMask = OSIEBCA; // Intense Fresnel

                                float factor = pow2(color.r);

                                smoothnessG = 0.8 - factor * 0.3;
                                highlightMult = factor * 3.0;

                                smoothnessD = factor;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.66;
                                #endif
                            }
                            else /*if (mat == 10332)*/ { // Amethyst Cluster, Amethyst Buds
                                noSmoothLighting = true;
                                lmCoordM.x *= 0.85;

                                vec3 worldPos = playerPos.xyz + cameraPosition.xyz;
                                vec3 blockPos = abs(fract(worldPos) - vec3(0.5));
                                float maxBlockPos = max(blockPos.x, max(blockPos.y, blockPos.z));
                                emission = pow2(max0(1.0 - maxBlockPos * 1.85) * color.g) * 7.0;

                                if (CheckForColor(color.rgb, vec3(254, 203, 230)))
                                    emission = pow(emission, max0(1.0 - 0.2 * max0(emission - 1.0)));

                                color.g *= 1.0 - emission * 0.07;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.66;
                                #endif
                            }
                        }
                    } else {
                        if (mat < 10344) {
                            if (mat == 10336) { // Emerald Block
                                #include "/lib/materials/specificMaterials/emeraldBlock.glsl"
                            }
                            else /*if (mat == 10340)*/ { // Emerald Ore
                                float dif = GetMaxColorDif(color.rgb);
                                if (dif > 0.4 || color.b > 0.85) { // Emerald Ore:Emerald Part
                                    #include "/lib/materials/specificMaterials/emeraldBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        emission = 2.0;
                                        color.rgb *= color.rgb;
                                    #endif
                                } else { // Emerald Ore:Stone Part
                                    #include "/lib/materials/specificMaterials/stone.glsl"
                                }
                            }
                        } else {
                            if (mat == 10344) { // Deepslate Emerald Ore
                                float dif = GetMaxColorDif(color.rgb);
                                if (dif > 0.4 || color.b > 0.85) { // Deepslate Emerald Ore:Emerald Part
                                    #include "/lib/materials/specificMaterials/emeraldBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        emission = 2.0;
                                        color.rgb *= color.rgb;
                                    #endif
                                } else { // Deepslate Emerald Ore:Deepslate Part
                                    #include "/lib/materials/specificMaterials/deepslate.glsl"
                                }
                            }
                            else /*if (mat == 10348)*/ { // Azalea, Flowering Azalea
                                subsurfaceMode = 2;
                                shadowMult = vec3(0.85);
                            }
                        }
                    }
                } else {
                    if (mat < 10368) {
                        if (mat < 10360) {
                            if (mat == 10352) { // Lapis Block, Dried Kelp Block
                                #include "/lib/materials/specificMaterials/lapisBlock.glsl"
                            }
                            else /*if (mat == 10356)*/ { // Lapis Ore
                                if (color.r != color.g) { // Lapis Ore:Lapis Part
                                    #include "/lib/materials/specificMaterials/lapisBlock.glsl"
                                    smoothnessG *= 0.5;
                                    smoothnessD *= 0.5;
                                    #if GLOWING_ORES >= 1
                                        if (color.b - color.r > 0.2) {
                                            emission = 2.0;
                                            color.rgb *= color.rgb;
                                        }
                                    #endif
                                } else { // Lapis Ore:Stone Part
                                    #include "/lib/materials/specificMaterials/stone.glsl"
                                }
                            }
                        } else {
                            if (mat == 10360) { // Deepslate Lapis Ore
                                if (color.r != color.g) { // Deepslate Lapis Ore:Lapis Part
                                    #include "/lib/materials/specificMaterials/lapisBlock.glsl"
                                    smoothnessG *= 0.5;
                                    smoothnessD *= 0.5;
                                    #if GLOWING_ORES >= 1
                                        if (color.b - color.r > 0.2) {
                                            emission = 2.0;
                                            color.rgb *= color.rgb;
                                        }
                                    #endif
                                } else { // Deepslate Lapis Ore:Deepslate Part
                                    #include "/lib/materials/specificMaterials/deepslate.glsl"
                                }
                            }
                            else /*if (mat == 10364)*/ { // Quartz Block++
                                #include "/lib/materials/specificMaterials/quartzBlock.glsl"
                            }
                        }
                    } else {
                        if (mat < 10376) {
                            if (mat == 10368) { // Nether Quartz Ore
                                if (color.g != color.b) { // Nether Quartz Ore:Quartz Part
                                    #include "/lib/materials/specificMaterials/quartzBlock.glsl"
                                    #if GLOWING_ORES >= 2
                                        emission = pow2(color.b * 1.5);
                                    #endif
                                } else { // Nether Quartz Ore:Netherrack Part
                                    #include "/lib/materials/specificMaterials/netherrack.glsl"
                                }
                            }
                            else /*if (mat == 10372)*/ { // Obsidian
                                #include "/lib/materials/specificMaterials/obsidian.glsl"
                            }
                        } else {
                            if (mat == 10376) { // Purpur Block+
                                highlightMult = 2.0;
                                smoothnessG = pow2(color.r) * 0.6;
                                smoothnessG = min1(smoothnessG);
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.5;
                                #endif
                            }
                            else /*if (mat == 10380)*/ { // Snow, Snow Block, Powder Snow
                                #include "/lib/materials/specificMaterials/snow.glsl"
                            }
                        }
                    }
                }
            }
        } else {
            if (mat < 10448) {
                if (mat < 10416) {
                    if (mat < 10400) {
                        if (mat < 10392) {
                            if (mat == 10384) { // Packed Ice
                                materialMask = OSIEBCA; // Intense Fresnel
                                float factor = pow2(color.g);
                                float factor2 = pow2(factor);
                                smoothnessG = 1.0 - 0.5 * factor;
                                highlightMult = factor2 * 3.5;
                                smoothnessD = factor;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.33;
                                #endif
                            }
                            else /*if (mat == 10388)*/ { // Blue Ice
                                materialMask = OSIEBCA; // Intense Fresnel
                                float factor = min1(pow2(color.g) * 1.38);
                                float factor2 = pow2(factor);
                                smoothnessG = 1.0 - 0.5 * factor;
                                highlightMult = factor2 * 3.5;
                                smoothnessD = pow1_5(color.g);

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.33;
                                #endif
                            }
                        } else {
                            if (mat == 10392) { // Pumpkin, Carved Pumpkin
                                #include "/lib/materials/specificMaterials/pumpkin.glsl"
                            }
                            else /*if (mat == 10396)*/ { // Jack o'Lantern
                                #include "/lib/materials/specificMaterials/pumpkin.glsl"
                                noSmoothLighting = true, noDirectionalShading = true;
                                lmCoordM.y = 0.0;
                                if (color.b > 0.28 && color.r > 0.9) { // Jack o'Lantern:Emissive Part
                                    emission = pow2(pow2(pow2(color.g))) * 5.0;
                                }
                            }
                        }
                    } else {
                        if (mat < 10408) {
                            if (mat == 10400) { // Sea Pickle
                                noSmoothLighting = true;
                                if (color.b > 0.5) { // Sea Pickle:Emissive Part
                                    color.g *= 1.1;
                                    emission = 7.0;
                                }
                            }
                            else /*if (mat == 10404)*/ { // Soul Sand, Soul Soil
                                smoothnessG = color.r * 0.4;
                                smoothnessD = color.r * 0.25;
                            }
                        } else {
                            if (mat == 10408) { // Basalt+
                                smoothnessG = color.r * 0.35;
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.77;
                                #endif
                            }
                            else /*if (mat == 10412)*/ { // Glowstone
                                noSmoothLighting = true; noDirectionalShading = true;
                                lmCoordM = vec2(0.95, 0.0);

                                emission = max0(color.g - 0.375) * 3.7;
                                //if (CheckForColor(color.rgb, vec3(204, 134, 84))) emission *= 2.1;
                                color.rg += emission * vec2(0.15, 0.05);
                            }
                        }
                    }
                } else {
                    if (mat < 10432) {
                        if (mat < 10424) {
                            if (mat == 10416) { // Nether Bricks+
                                float factor = smoothstep1(min1(color.r * 1.5));
                                factor = factor > 0.12 ? factor : factor * 0.5;
                                smoothnessG = factor;
                                smoothnessD = factor;
                            }
                            else /*if (mat == 10420)*/ { // Red Nether Bricks+
                                float factor = color.r * 0.9;
                                factor = color.r > 0.215 ? factor : factor * 0.25;
                                smoothnessG = factor;
                                smoothnessD = factor;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.77;
                                #endif
                            }
                        } else {
                            if (mat == 10424) { // Melon
                                smoothnessG = color.r * 0.75;
                                smoothnessD = color.r * 0.5;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.66;
                                #endif
                            }
                            else /*if (mat == 10428)*/ { // End Stone++,
                                #include "/lib/materials/specificMaterials/endStone.glsl"
                            }
                        }
                    } else {
                        if (mat < 10440) {
                            if (mat == 10432) { // Terracotta+
                                smoothnessG = 0.25;
                                highlightMult = 1.5;
                                smoothnessD = 0.17;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.33;
                                #endif
                            }
                            else /*if (mat == 10436)*/ { // Glazed Terracotta+
                                smoothnessG = 0.75;
                                smoothnessD = 0.35;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.5;
                                #endif
                            }
                        } else {
                            if (mat == 10440) { // Prismarine+, Prismarine Bricks+
                                smoothnessG = pow2(color.g) * 0.8;
                                highlightMult = 1.5;
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.66;
                                #endif
                            }
                            else /*if (mat == 10444)*/ { // Dark Prismarine+
                                smoothnessG = min1(pow2(color.g) * 2.0);
                                highlightMult = 1.5;
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.77;
                                #endif
                            }
                        }
                    }
                }
            } else {
                if (mat < 10480) {
                    if (mat < 10464) { 
                        if (mat < 10456) {
                            if (mat == 10448) { // Sea Lantern
                                noSmoothLighting = true; noDirectionalShading = true;
                                lmCoordM.x = 0.8;
                                
                                smoothnessD = min1(max0(0.5 - color.r) * 2.0);
                                smoothnessG = color.g;

                                vec2 signMidCoordPosM = (floor((signMidCoordPos + 1.0) * 8.0) + 0.5) * 0.125 - 1.0;
                                float dotsignMidCoordPos = dot(signMidCoordPosM, signMidCoordPosM);
                                float lBlockPosM = pow2(max0(1.0 - 1.7 * pow2(pow2(dotsignMidCoordPos))));
                                emission = pow2(color.b) * 0.8 + 2.2 * lBlockPosM;

                                emission *= 0.4 + max0(0.6 - 0.006 * lViewPos);

                                color.rb *= vec2(1.13, 1.1);

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.5;
                                #endif
                            }
                            else /*if (mat == 10452)*/ { // Magma Block
                                noSmoothLighting = true; noDirectionalShading = true;
                                lmCoordM.x = 0.65;

                                emission = 0.1 + pow2(pow2(color.r)) * 3.0;

                                #if RAIN_PUDDLES >= 1
                                    noPuddles = color.g * 4.0;
                                #endif

                                color.gb *= vec2(1.0 - min(color.g, 0.6));

                                maRecolor = vec3(emission * 0.1);
                            }
                        } else {
                            if (mat == 10456) { // Command Block+
                                vec2 absCoord = abs(signMidCoordPos - 0.0625);
                                float maxCoord = max(absCoord.x, absCoord.y);
                                if (maxCoord < 0.3125 && abs(color.r - color.g) > 0.1) {
                                    emission = 6.0;
                                    color.rgb *= color.rgb;
                                    smoothnessG = 1.0;
                                    smoothnessD = 1.0;
                                    highlightMult = 2.0;
                                    maRecolor = vec3(0.5);
                                } else {
                                    smoothnessG = dot(color.rgb, color.rgb) * 0.33;
                                    smoothnessD = smoothnessG;
                                }
                            }
                            else /*if (mat == 10460)*/ { // Concrete+
                                smoothnessG = 0.4;
                                highlightMult = 1.5;
                                smoothnessD = 0.3;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.2;
                                #endif
                            }
                        }
                    } else {
                        if (mat < 10472) {
                            if (mat == 10464) { // Concrete Powder+
                                smoothnessG = 0.2;
                                smoothnessD = 0.1;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.5;
                                #endif
                            }
                            else /*if (mat == 10468)*/ { // Coral Block+
                                #include "/lib/materials/specificMaterials/coral.glsl"
                            }
                        } else {
                            if (mat == 10472) { // Coral Fan+, Coral+
                                noSmoothLighting = true;
                                #include "/lib/materials/specificMaterials/coral.glsl"
                            }
                            else /*if (mat == 10476)*/ { // Crying Obsidian
                                #include "/lib/materials/specificMaterials/cryingObsidian.glsl"

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                        }
                    }
                } else {
                    if (mat < 10496) {
                        if (mat < 10488) {
                            if (mat == 10480) { // Blackstone++
                                #include "/lib/materials/specificMaterials/blackstone.glsl"
                            }
                            else /*if (mat == 10484)*/ { // Gilded Blackstone
                                if (color.r > color.b * 3.0) { // Gilded Blackstone:Gilded Part
                                    #include "/lib/materials/specificMaterials/rawGoldBlock.glsl"
                                    #if GLOWING_ORES >= 2
                                        emission = color.g * 1.5;
                                    #endif
                                } else { // Gilded Blackstone:Blackstone Part
                                    #include "/lib/materials/specificMaterials/blackstone.glsl"
                                }

                            }
                        } else {
                            if (mat == 10488) { // Lily Pad
                                noSmoothLighting = true;
                                #include "/lib/materials/specificMaterials/leaves.glsl"
                            }
                            else /*if (mat == 10492)*/ { // Weeping Vines, Twisting Vines, Crimson Fungus, Warped Fungus
                                noSmoothLighting = true;
                                if (color.r > 0.91) {
                                    emission = 2.5 * color.g;
                                    color.r *= 1.2;
                                    maRecolor = vec3(0.1);
                                }
                            }
                        }
                    } else {
                        if (mat < 10504) {
                            if (mat == 10496) { // Torch
                                noDirectionalShading = true;
                                
                                if (color.r > 0.95) {
                                    noSmoothLighting = true;
                                    lmCoordM.x = 1.0;
                                    emission = GetLuminance(color.rgb) * 3.0;
                                    color.r *= 1.35;
                                    color.b *= 0.5;
                                } else {
                                    lmCoordM.x = min1(0.7 + 0.3 * pow2(1.0 - signMidCoordPos.y));
                                }
                                emission += 0.0001; // No light reducing during noon
                            }
                            else /*if (mat == 10500)*/ { // End Rod
                                noDirectionalShading = true;
                                vec3 fractPos = abs(fract(playerPos + cameraPosition) - 0.5);
                                float maxCoord = max(fractPos.x, max(fractPos.y, fractPos.z));
                                lmCoordM.x = maxCoord < 0.4376 ? 0.95 : 0.8;

                                float dotColor = dot(color.rgb, color.rgb);
                                if (dotColor > 2.0) {
                                    emission = 1.6;
                                    emission *= 0.4 + max0(0.6 - 0.006 * lViewPos);

                                    color.rgb = pow2(color.rgb);
                                    color.g *= 0.95;
                                } else {
                                    
                                }
                            }
                        } else {
                            if (mat == 10504) { // Chorus Plant

                            }
                            else /*if (mat == 10508)*/ { // Chorus Flower:Alive
                                float dotColor = dot(color.rgb, color.rgb);
                                if (dotColor > 1.0)
                                    emission = pow2(pow2(pow2(dotColor * 0.33))) + 0.2 * dotColor;
                            }
                        }
                    }
                }
            }
        }
    }
} else {
    if (mat < 10768) {
        if (mat < 10640) {
            if (mat < 10576) {
                if (mat < 10544) {
                    if (mat < 10528) {
                        if (mat < 10520) {
                            if (mat == 10512) { // Chorus Flower:Dead
                                if (color.b < color.g) {
                                    emission = 10.7;
                                    color.rgb *= color.rgb * dot(color.rgb, color.rgb) * vec3(0.4, 0.35, 0.4);
                                }
                            }
                            else /*if (mat == 10516)*/ { // Furnace:Lit
                                lmCoordM.x *= 0.95;

                                float dotColor = dot(color.rgb, color.rgb);
                                if (color.r > color.b * 1.5 || dotColor > 2.9) {
                                    emission = 2.0 * dotColor;
                                    color.r *= 1.3;
                                } else {
                                    #include "/lib/materials/specificMaterials/cobblestone.glsl"
                                }
                            }
                        } else {
                            if (mat == 10520) { // Cactus
                                float factor = sqrt1(color.r);
                                smoothnessG = factor * 0.5;
                                highlightMult = factor;
                            }
                            else /*if (mat == 10524)*/ { // Note Block, Jukebox
                                float factor = color.r * 0.5;
                                smoothnessG = factor;
                                smoothnessD = factor;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.66;
                                #endif
                            }
                        }
                    } else {
                        if (mat < 10536) {
                            if (mat == 10528) { // Soul Torch
                                noSmoothLighting = true; noDirectionalShading = true;
                                lmCoordM.x = min(lmCoordM.x * 0.9, 0.77);

                                if (color.b > 0.6) {
                                    emission = 2.3;
                                    color.rgb = pow1_5(color.rgb);
                                    color.r = min1(color.r + 0.1);
                                }
                                emission += 0.0001; // No light reducing during noon

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                            else /*if (mat == 10532)*/ { // Brown Mushroom Block
                                if (color.r > color.g && color.g > color.b && color.b > 0.37) {
                                    #include "/lib/materials/specificMaterials/cobblestone.glsl"
                                } else {
                                    float factor = pow2(color.r) * color.r * 0.8;
                                    highlightMult = 1.5;
                                    smoothnessG = factor;
                                    smoothnessD = factor * 0.9;

                                    #ifdef COATED_TEXTURES
                                        noiseFactor = 0.33;
                                    #endif
                                }
                            }
                        } else {
                            if (mat == 10536) { // Red Mushroom Block
                                if (color.r > color.g && color.g > color.b && color.b > 0.37) {
                                    #include "/lib/materials/specificMaterials/cobblestone.glsl"
                                } else {
                                    float factor = min1(pow2(color.g) + 0.25);
                                    highlightMult = 1.5;
                                    smoothnessG = factor;
                                    smoothnessD = factor * 0.7;

                                    #ifdef COATED_TEXTURES
                                        noiseFactor = 0.33;
                                    #endif
                                }
                            }
                            else /*if (mat == 10540)*/ { // Mushroom Stem,
                                if (color.r > color.g && color.g > color.b && color.b < 0.6) {
                                    #include "/lib/materials/specificMaterials/cobblestone.glsl"
                                } else {
                                    float factor = pow2(pow2(color.g));
                                    highlightMult = 1.5;
                                    smoothnessG = factor;
                                    smoothnessD = factor * 0.5;

                                    #ifdef COATED_TEXTURES
                                        noiseFactor = 0.33;
                                    #endif
                                }
                            }
                        }
                    }
                } else {
                    if (mat < 10560) {
                        if (mat < 10552) {
                            if (mat == 10544) { // Glow Lichen
                                noSmoothLighting = true;

                                float dotColor = dot(color.rgb, color.rgb);
                                float skyLightFactor = pow2(1.0 - min1(lmCoord.y * 2.9));
                                emission = min(pow2(pow2(dotColor) * dotColor) * 1.4 + dotColor * 0.5, 6.0);
                                emission *= skyLightFactor;
                            }
                            else /*if (mat == 10548)*/ { // Enchanting Table:Base
                                float dotColor = dot(color.rgb, color.rgb);
                                if (dotColor < 0.19 && color.r < color.b) {
                                    #include "/lib/materials/specificMaterials/obsidian.glsl"
                                } else if (color.g >= color.r) {
                                    #include "/lib/materials/specificMaterials/diamondBlock.glsl"
                                } else {
                                    smoothnessG = color.r * 0.3 + 0.1;
                                }

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                        } else {
                            if (mat == 10552) { // End Portal Frame:Inactive
                                noSmoothLighting = true;

                                if (abs(color.r - color.g - 0.05) < 0.10) {
                                    #include "/lib/materials/specificMaterials/endStone.glsl"
                                } else {
                                    #include "/lib/materials/specificMaterials/endPortalFrame.glsl"
                                }

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                            else /*if (mat == 10556)*/ { // End Portal Frame:Active
                                noSmoothLighting = true;

                                if (abs(color.r - color.g - 0.05) < 0.10) {
                                    #include "/lib/materials/specificMaterials/endStone.glsl"
                                } else {
                                    #include "/lib/materials/specificMaterials/endPortalFrame.glsl"

                                    vec2 absCoord = abs(fract(playerPos.xz + cameraPosition.xz) - 0.5);
                                    float maxCoord = max(absCoord.x, absCoord.y);
                                    if (maxCoord < 0.2505) { // End Portal Frame:Eye of Ender
                                        smoothnessG = 0.5;
                                        smoothnessD = 0.5;
                                        emission = pow2(min(color.g, 0.25)) * 150.0 * (0.27 - maxCoord);
                                    } else {
                                        float minCoord = min(absCoord.x, absCoord.y);
                                        if (CheckForColor(color.rgb, vec3(153, 198, 147))
                                        && minCoord > 0.25) { // End Portal Frame:Emissive Corner Bits
                                            emission = 1.2;
                                            color.rgb = vec3(0.45, 1.0, 0.6);
                                        }
                                    }
                                }

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                        }
                    } else {
                        if (mat < 10568) {
                            if (mat == 10560) { // Lantern
                                noSmoothLighting = true;
                                lmCoordM.x = 0.77;

                                if (color.r < color.b) { // Lantern:Metal Part
                                    #include "/lib/materials/specificMaterials/lanternMetal.glsl"
                                } else { // Lantern:Emissive Part
                                    emission = pow2(color.g) * 5.0 + 1.0;

                                    color.gb *= vec2(0.8, 0.7);
                                }
                            }
                            else /*if (mat == 10564)*/ { // Soul Lantern, Chain
                                noSmoothLighting = true;
                                lmCoordM.x = min(lmCoordM.x, 0.77);

                                if (min1(color.r * 3.0) >= color.g + 0.25) { // Soul Lantern:Metal Part, Chain
                                    #include "/lib/materials/specificMaterials/lanternMetal.glsl"
                                } else { // Soul Lantern:Emissive Part
                                    emission = color.r * 3.0 + 0.5;
                                }

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                        } else {
                            if (mat == 10568) { // Turtle Egg
                                smoothnessG = color.r * 0.7;
                                smoothnessD = color.r * 0.5;
                            }
                            else /*if (mat == 10572)*/ { // Dragon Egg
                                emission = float(color.b > 0.1) * 10.0 + 0.6;
                            }
                        }
                    }
                }
            } else {
                if (mat < 10608) {
                    if (mat < 10592) {
                        if (mat < 10584) {
                            if (mat == 10576) { // Smoker:Lit
                                lmCoordM.x *= 0.95;

                                float dotColor = dot(color.rgb, color.rgb);
                                if (color.r > color.b * 2.0 && dotColor > 0.7) {
                                    emission = 2.0 * dotColor;
                                    color.r *= 1.5;
                                } else {
                                    #include "/lib/materials/specificMaterials/cobblestone.glsl"
                                }
                            }
                            else /*if (mat == 10580)*/ { // Blast Furnace:Lit
                                lmCoordM.x *= 0.95;

                                float dotColor = dot(color.rgb, color.rgb);
                                if (color.r > color.b * 2.0 && dotColor > 0.7) {
                                    emission = pow2(color.g) * (16.0 - 11.0 * float(color.b > 0.25));
                                    color.r *= 1.5;
                                } else {
                                    #include "/lib/materials/specificMaterials/cobblestone.glsl"
                                }
                            }
                        } else {
                            if (mat == 10584) { // Candle++:Lit
                                noSmoothLighting = true;
                                
                                color.rgb *= 1.0 + pow2(max(-signMidCoordPos.y, float(NdotU > 0.9) * 1.2));

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                            else /*if (mat == 10588)*/ { // Respawn Anchor:Unlit
                                noSmoothLighting = true;

                                #include "/lib/materials/specificMaterials/cryingObsidian.glsl"
                                emission += 0.2;

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                        }
                    } else {
                        if (mat < 10600) {
                            if (mat == 10592) { // Respawn Anchor:Lit
                                noSmoothLighting = true;


                                vec2 absCoord = abs(signMidCoordPos);
                                if (NdotU > 0.9 && max(absCoord.x, absCoord.y) < 0.754) { // Portal
                                    highlightMult = 0.0;
                                    smoothnessD = 0.0;
                                    emission = pow2(color.r) * color.r * 16.0;
                                } else if (color.r + color.g > 1.3) { // Respawn Anchor:Glowstone Part
                                    emission = 4.2;
                                } else {
                                    #include "/lib/materials/specificMaterials/cryingObsidian.glsl"
                                    emission += 0.2;
                                }

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                            else /*if (mat == 10596)*/ { // Redstone Wire:Lit
                                #include "/lib/materials/specificMaterials/redstoneBlock.glsl"

                                emission = pow2(min(color.r, 0.9)) * 3.7;
                                color.gb *= 0.25;
                            }
                        } else {
                            if (mat == 10600) { // Redstone Wire:Unlit
                                #include "/lib/materials/specificMaterials/redstoneBlock.glsl"
                            }
                            else /*if (mat == 10604)*/ { // Redstone Torch
                                #include "/lib/materials/specificMaterials/redstoneTorch.glsl"
                                emission += 0.0001; // No light reducing during noon
                            }
                        }
                    }
                } else {
                    if (mat < 10624) {
                        if (mat < 10616) {
                            if (mat == 10608) { // Redstone Block
                                #include "/lib/materials/specificMaterials/redstoneBlock.glsl"
                                #ifdef EMISSIVE_REDSTONE_BLOCK
                                    emission = 0.5 + 3.0 * pow2(pow2(color.r));
                                    color.gb *= 0.65;

                                    #ifdef SNOWY_WORLD
                                        snowFactor = 0.0;
                                    #endif
                                #endif
                            }
                            else /*if (mat == 10612)*/ { // Redstone Ore:Unlit
                                if (color.r - color.g > 0.2) { // Redstone Ore:Unlit:Redstone Part
                                    #include "/lib/materials/specificMaterials/redstoneBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        emission = pow2(color.r) * color.r * 4.0;
                                        color.gb *= 0.1;
                                    #endif
                                } else { // Redstone Ore:Unlit:Stone Part
                                    #include "/lib/materials/specificMaterials/stone.glsl"
                                }
                            }
                        } else {
                            if (mat == 10616) { // Redstone Ore:Lit
                                if (color.r - color.g > 0.2) { // Redstone Ore:Lit:Redstone Part
                                    #include "/lib/materials/specificMaterials/redstoneBlock.glsl"
                                    emission = pow2(pow2(color.r)) * 5.0;
                                    color.gb *= 0.1;
                                } else { // Redstone Ore:Lit:Stone Part
                                    #include "/lib/materials/specificMaterials/stone.glsl"
                                }
                                noSmoothLighting = true;
                            }
                            else /*if (mat == 10620)*/ { // Deepslate Redstone Ore:Unlit
                                if (color.r - color.g > 0.2) { // Deepslate Redstone Ore:Unlit:Redstone Part
                                    #include "/lib/materials/specificMaterials/redstoneBlock.glsl"
                                    #if GLOWING_ORES >= 1
                                        emission = pow2(color.r) * color.r * 4.0;
                                        color.gb *= 0.1;
                                    #endif
                                } else { // Deepslate Redstone Ore:Unlit:Deepslate Part
                                    #include "/lib/materials/specificMaterials/deepslate.glsl"
                                }
                            }
                        }
                    } else {
                        if (mat < 10632) {
                            if (mat == 10624) { // Deepslate Redstone Ore:Lit
                                if (color.r - color.g > 0.2) { // Deepslate Redstone Ore:Lit:Redstone Part
                                    #include "/lib/materials/specificMaterials/redstoneBlock.glsl"
                                    emission = pow2(pow2(color.r)) * 6.0;
                                    color.gb *= 0.05;
                                } else { // Deepslate Redstone Ore:Lit:Deepslate Part
                                    #include "/lib/materials/specificMaterials/deepslate.glsl"
                                }
                                noSmoothLighting = true;
                            }
                            else /*if (mat == 10628)*/ { // Cave Vines:No Berries
                                subsurfaceMode = 1;
                                lmCoordM.x *= 0.875;
                            }
                        } else {
                            if (mat == 10632) { // Cave Vines:With Berries
                                subsurfaceMode = 1;
                                lmCoordM.x *= 0.875;

                                if (color.r > 0.64) {
                                    emission = color.r < 0.75 ? 2.0 : 7.0;
                                    color.rgb = color.rgb * vec3(1.0, 0.8, 0.6);
                                }
                            }
                            else /*if (mat == 10636)*/ { // Redstone Lamp:Unlit
                                materialMask = OSIEBCA; // Intense Fresnel
                                smoothnessG = color.r * 0.5 + 0.2;
                                float factor = pow2(smoothnessG);
                                highlightMult = factor * 2.0 + 1.0;
                                smoothnessD = min1(factor * 2.0);
                            }
                        }
                    }
                }
            }
        } else {
            if (mat < 10704) {
                if (mat < 10672) {
                    if (mat < 10656) {
                        if (mat < 10648) {
                            if (mat == 10640) { // Redstone Lamp:Lit
                                noDirectionalShading = true;
                                lmCoordM.x = 0.88;

                                materialMask = OSIEBCA; // Intense Fresnel
                                smoothnessG = color.r * 0.35 + 0.2;
                                float factor = pow2(smoothnessG);
                                highlightMult = factor * 2.0 + 1.0;
                                smoothnessD = min1(factor * 2.0);
                            
                                if (color.b > 0.1) {
                                    float dotColor = dot(color.rgb, color.rgb);
                                    emission = pow2(dotColor) * 0.8;
                                    color.rgb = pow1_5(color.rgb);
                                    maRecolor = vec3(emission * 0.2);
                                }
                            }
                            else /*if (mat == 10644)*/ { // Repeater, Comparator
                                vec3 absDif = abs(vec3(color.r - color.g, color.g - color.b, color.r - color.b));
                                float maxDif = max(absDif.r, max(absDif.g, absDif.b));
                                if (maxDif > 0.125 || color.b > 0.99) { // Redstone Parts
                                    if (color.r < 0.999 && color.b > 0.4) color.gb *= 0.5;  // Comparator:Emissive Wire

                                    #include "/lib/materials/specificMaterials/redstoneTorch.glsl"
                                } else { // Quartz Base
                                    float factor = pow2(color.g) * 0.6;

                                    smoothnessG = factor;
                                    highlightMult = 1.0 + 2.5 * factor;
                                    smoothnessD = factor;
                                }
                            }
                        } else {
                            if (mat == 10648) { // Shroomlight
                                noSmoothLighting = true; noDirectionalShading = true;
                                lmCoordM = vec2(1.0, 0.0);

                                float dotColor = dot(color.rgb, color.rgb);
                                emission = min(pow2(pow2(pow2(dotColor * 0.6))), 5.0) * 0.8 + 0.1;
                            }
                            else /*if (mat == 10652)*/ { // Campfire:Lit
                                vec3 fractPos = fract(playerPos + cameraPosition) - 0.5;
                                lmCoordM.x = 1.0 - 0.5 * dot(fractPos.xz, fractPos.xz);

                                float dotColor = dot(color.rgb, color.rgb);
                                if (color.r > color.b && color.r - color.g < 0.15 && dotColor < 1.5) {
                                    #include "/lib/materials/specificMaterials/oakWood.glsl"
                                } else if (color.r > color.b || dotColor > 2.9) {
                                    noDirectionalShading = true;
                                    emission = 1.8;
                                    color.rgb *= sqrt1(GetLuminance(color.rgb));
                                }
                            }
                        }
                    } else {
                        if (mat < 10664) {
                            if (mat == 10656) { // Soul Campfire:Lit
                                noSmoothLighting = true;
                                
                                float dotColor = dot(color.rgb, color.rgb);
                                if (color.r > color.b) {
                                    #include "/lib/materials/specificMaterials/oakWood.glsl"
                                } else if (color.g - color.r > 0.1 || dotColor > 2.9) {
                                    noDirectionalShading = true;
                                    emission = 1.6;
                                    color.rgb *= sqrt1(GetLuminance(color.rgb));
                                }

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                            else /*if (mat == 10660)*/ { // Campfire:Unlit, Soul Campfire:Unlit
                                noSmoothLighting = true;
                                
                                if (color.r > color.b) {
                                    #include "/lib/materials/specificMaterials/oakWood.glsl"
                                }
                            }
                        } else {
                            if (mat == 10664) { // Observer
                                if (color.r > 0.1 && color.g + color.b < 0.1) {
                                    #include "/lib/materials/specificMaterials/redstoneTorch.glsl"
                                } else {
                                    #include "/lib/materials/specificMaterials/cobblestone.glsl"
                                }
                            }
                            else /*if (mat == 10668)*/ { // Wool+, Carpet+
                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.77;
                                #endif
                            }
                        }
                    }
                } else {
                    if (mat < 10688) {
                        if (mat < 10680) {
                            if (mat == 10672) { // Bone Block
                                smoothnessG = color.r * 0.2;
                                smoothnessD = smoothnessG;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.33;
                                #endif
                            }
                            else /*if (mat == 10676)*/ { // Barrel, Beehive, Bee Nest, Honeycomb Block
                                #include "/lib/materials/specificMaterials/cobblestone.glsl"

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.66;
                                #endif
                            }
                        } else {
                            if (mat == 10680) { // Ochre Froglight
                                float frogPow = 8.0;
                                #include "/lib/materials/specificMaterials/froglights.glsl"
                            }
                            else /*if (mat == 10684)*/ { // Verdant Froglight
                                float frogPow = 16.0;
                                #include "/lib/materials/specificMaterials/froglights.glsl"
                            }
                        }
                    } else {
                        if (mat < 10696) {
                            if (mat == 10688) { // Pearlescent Froglight
                                float frogPow = 24.0;
                                #include "/lib/materials/specificMaterials/froglights.glsl"
                            }
                            else /*if (mat == 10692)*/ { // Reinforced Deepslate
                                if (abs(color.r - color.g) < 0.01) { // Reinforced Deepslate:Deepslate Part
                                    #include "/lib/materials/specificMaterials/deepslate.glsl"
                                } else { // Reinforced Deepslate:Sculk
                                    float boneFactor = max0(color.r * 1.25 - color.b);

                                    if (boneFactor < 0.0001) emission = 0.15;

                                    smoothnessG = min1(boneFactor * 1.7);
                                    smoothnessD = smoothnessG;
                                }
                            }
                        } else {
                            if (mat == 10696) { // Sculk, Sculk Catalyst, Sculk Vein, Sculk Sensor:Unlit
                                float boneFactor = max0(color.r * 1.25 - color.b);

                                if (boneFactor < 0.0001) emission = pow2(max0(color.g - color.r));

                                smoothnessG = min1(boneFactor * 1.7);
                                smoothnessD = smoothnessG;

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                            else /*if (mat == 10700)*/ { // Sculk Shrieker
                                float boneFactor = max0(color.r * 1.25 - color.b);

                                if (boneFactor < 0.0001) {
                                    emission = pow2(max0(color.g - color.r)) * 2.0;

                                    vec2 coordFactor = abs(fract(playerPos.xz + cameraPosition.xz) - 0.5);
                                    float coordFactorM = max(coordFactor.x, coordFactor.y);
                                    if (coordFactorM < 0.43) emission += color.g * 7.0;
                                }

                                smoothnessG = min1(boneFactor * 1.7);
                                smoothnessD = smoothnessG;

                                #ifdef SNOWY_WORLD
                                    snowFactor = 0.0;
                                #endif
                            }
                        }
                    }
                }
            } else {
                if (mat < 10736) {
                    if (mat < 10720) {
                        if (mat < 10712) {
                            if (mat == 10704) { // Sculk Sensor:Lit
                                lmCoordM = vec2(0.0, 0.0);
                                emission = pow2(max0(color.g - color.r)) * 7.0 + 0.7;
                            }
                            else /*if (mat == 10708)*/ { // Spawner
                                smoothnessG = color.b + 0.2;
                                smoothnessD = smoothnessG;

                                emission = 7.0 * float(CheckForColor(color.rgb, vec3(110, 4, 83)));
                            }
                        } else {
                            if (mat == 10712) { // Tuff
                                smoothnessG = color.r * 0.2;
                                smoothnessD = smoothnessG;
                            }
                            else /*if (mat == 10716)*/ { // Clay
                                highlightMult = 2.0;
                                smoothnessG = pow2(pow2(color.g)) * 0.5;
                                smoothnessG = min1(smoothnessG);
                                smoothnessD = smoothnessG * 0.7;

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 0.77;
                                #endif
                            }
                        }
                    } else {
                        if (mat < 10728) {
                            if (mat == 10720) { // Ladder
                                noSmoothLighting = true;
                            }
                            else /*if (mat == 10724)*/ { // Gravel
                                #include "/lib/materials/specificMaterials/stone.glsl"

                                #ifdef COATED_TEXTURES
                                    noiseFactor = 1.25;
                                #endif
                            }
                        } else {
                            if (mat == 10728) { // Flower Pot++
                                noSmoothLighting = true;
                            }
                            else /*if (mat == 10732)*/ { // Lever
                                if (color.r > color.g + color.b) {
                                    color.rgb *= color.rgb;
                                    emission = 4.0;
                                } else {
                                    #include "/lib/materials/specificMaterials/cobblestone.glsl"
                                }
                            }
                        }
                    }
                } else {
                    if (mat < 10752) {
                        if (mat < 10744) {
                            if (mat == 10736) { // Structure Block, Jigsaw Block
                                vec2 signMidCoordPosM = (floor((signMidCoordPos + 1.0) * 8.0) + 0.5) * 0.125 - 1.0;
                                float dotsignMidCoordPos = dot(signMidCoordPosM, signMidCoordPosM);
                                float lBlockPosM = pow2(max0(1.0 - 1.125 * pow2(dotsignMidCoordPos)));

                                emission = 4.5 * lBlockPosM;
                                color.rgb = pow2(color.rgb);
                            }
                            else /*if (mat == 10740)*/ { //

                            }
                        } else {
                            if (mat == 10744) { //
                            
                            }
                            else /*if (mat == 10748)*/ { //

                            }
                        }
                    } else {
                        if (mat < 10760) {
                            if (mat == 10752) { //
                            
                            }
                            else /*if (mat == 10756)*/ { //

                            }
                        } else {
                            if (mat == 10760) { //
                            
                            }
                            else /*if (mat == 10764)*/ { //

                            }
                        }
                    }
                }
            }
        }
    } else {
        if (mat < 10896) {
            if (mat < 10832) {
                if (mat < 10800) {
                    if (mat < 10784) {
                        if (mat < 10776) {
                            if (mat == 10768) { //
                            
                            }
                            else /*if (mat == 10772)*/ { //

                            }
                        } else {
                            if (mat == 10776) { //
                            
                            }
                            else /*if (mat == 10780)*/ { //

                            }
                        }
                    } else {
                        if (mat < 10792) {
                            if (mat == 10784) { //
                            
                            }
                            else /*if (mat == 10788)*/ { //

                            }
                        } else {
                            if (mat == 10792) { //
                            
                            }
                            else /*if (mat == 10796)*/ { //

                            }
                        }
                    }
                } else {
                    if (mat < 10816) {
                        if (mat < 10808) {
                            if (mat == 10800) { //
                            
                            }
                            else /*if (mat == 10804)*/ { //

                            }
                        } else {
                            if (mat == 10808) { //
                            
                            }
                            else /*if (mat == 10812)*/ { //

                            }
                        }
                    } else {
                        if (mat < 10824) {
                            if (mat == 10816) { //
                            
                            }
                            else /*if (mat == 10820)*/ { //

                            }
                        } else {
                            if (mat == 10824) { //
                            
                            }
                            else /*if (mat == 10828)*/ { //

                            }
                        }
                    }
                }
            } else {
                if (mat < 10864) {
                    if (mat < 10848) {
                        if (mat < 10840) {
                            if (mat == 10832) { //
                            
                            }
                            else /*if (mat == 10836)*/ { //

                            }
                        } else {
                            if (mat == 10840) { //
                            
                            }
                            else /*if (mat == 10844)*/ { //

                            }
                        }
                    } else {
                        if (mat < 10856) {
                            if (mat == 10848) { //
                            
                            }
                            else /*if (mat == 10852)*/ { //

                            }
                        } else {
                            if (mat == 10856) { //
                            
                            }
                            else /*if (mat == 10860)*/ { //

                            }
                        }
                    }
                } else {
                    if (mat < 10880) {
                        if (mat < 10872) {
                            if (mat == 10864) { //
                            
                            }
                            else /*if (mat == 10868)*/ { //

                            }
                        } else {
                            if (mat == 10872) { //
                            
                            }
                            else /*if (mat == 10876)*/ { //

                            }
                        }
                    } else {
                        if (mat < 10888) {
                            if (mat == 10880) { //
                            
                            }
                            else /*if (mat == 10884)*/ { //

                            }
                        } else {
                            if (mat == 10888) { //
                            
                            }
                            else /*if (mat == 10892)*/ { //

                            }
                        }
                    }
                }
            }
        } else {
            if (mat < 10960) {
                if (mat < 10928) {
                    if (mat < 10912) {
                        if (mat < 10904) {
                            if (mat == 10896) { //
                            
                            }
                            else /*if (mat == 10900)*/ { //

                            }
                        } else {
                            if (mat == 10904) { //
                            
                            }
                            else /*if (mat == 10908)*/ { //

                            }
                        }
                    } else {
                        if (mat < 10920) {
                            if (mat == 10912) { //
                            
                            }
                            else /*if (mat == 10916)*/ { //

                            }
                        } else {
                            if (mat == 10920) { //
                            
                            }
                            else /*if (mat == 10924)*/ { //

                            }
                        }
                    }
                } else {
                    if (mat < 10944) {
                        if (mat < 10936) {
                            if (mat == 10928) { //
                            
                            }
                            else /*if (mat == 10932)*/ { //

                            }
                        } else {
                            if (mat == 10936) { //
                            
                            }
                            else /*if (mat == 10940)*/ { //

                            }
                        }
                    } else {
                        if (mat < 10952) {
                            if (mat == 10944) { //
                            
                            }
                            else /*if (mat == 10948)*/ { //

                            }
                        } else {
                            if (mat == 10952) { //
                            
                            }
                            else /*if (mat == 10956)*/ { //

                            }
                        }
                    }
                }
            } else {
                if (mat < 10992) {
                    if (mat < 10976) {
                        if (mat < 10968) {
                            if (mat == 10960) { //
                            
                            }
                            else /*if (mat == 10964)*/ { //

                            }
                        } else {
                            if (mat == 10968) { //
                            
                            }
                            else /*if (mat == 10972)*/ { //

                            }
                        }
                    } else {
                        if (mat < 10984) {
                            if (mat == 10976) { //
                            
                            }
                            else /*if (mat == 10980)*/ { //

                            }
                        } else {
                            if (mat == 10984) { //
                            
                            }
                            else /*if (mat == 10988)*/ { //

                            }
                        }
                    }
                } else {
                    if (mat < 11008) {
                        if (mat < 11000) {
                            if (mat == 10992) { //
                            
                            }
                            else /*if (mat == 10996)*/ { //

                            }
                        } else {
                            if (mat == 11000) { //
                            
                            }
                            else /*if (mat == 11004)*/ { //

                            }
                        }
                    } else {
                        if (mat < 11016) {
                            if (mat == 11008) { //
                            
                            }
                            else /*if (mat == 11012)*/ { //

                            }
                        } else {
                            if (mat == 11016) { //
                            
                            }
                            else /*if (mat == 11020)*/ { //

                            }
                        }
                    }
                }
            }
        }
    }
}