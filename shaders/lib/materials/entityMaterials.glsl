if (entityId < 50064) {
    if (entityId < 50032) {
        if (entityId < 50016) {
            if (entityId < 50008) {
                if (entityId == 50000) { // End Crystal
                    lmCoordM.x *= 0.7;

                    if (color.g * 1.2 < color.r) {
                        emission = 12.0 * color.g;
                        color.r *= 1.1;
                    }
                } else if (entityId == 50004) { // Lightning Bolt
                    #include "/lib/materials/specificMaterials/entities/lightningBolt.glsl"
                }
            } else {
                if (entityId == 50008) { // Item Frame
                    noSmoothLighting = true;
                    if (dot(normal, normal) > 1.1) { // Maps
                        normalM = upVec;
                        shadowMult = vec3(0.0);
                        lmCoordM.x = mix(lmCoordM.x, 1.0, pow2(pow2(lmCoord.y)) * 0.75);
                    }
                } else /*if (entityId == 50012)*/ { // Glow Item Frame
                    noSmoothLighting = true;
                    lmCoordM = vec2(1.0, 0.0);
                    emission = 0.25;
                    if (dot(normal, normal) > 1.1) { // Maps
                        normalM = upVec;
                        shadowMult = vec3(0.0);
                    }
                }
            }
        } else {
            if (entityId < 50024) {
                if (entityId == 50016) { // Player
                    if (entityColor.a < 0.001) {
                        vec3 identification = texelFetch(tex, ivec2(63, 0), 0).rgb;
                        
                        /*if (CheckForColor(identification, vec3(193, 91, 241))) {

                        } else*/ if (CheckForColor(identification, vec3(50, 20, 54))) {
                            if (GetLuminance(color.rgb) >= 0.99999) {
                                emission = 2.0;
                            }
                        }
                    }
                } else /*if (entityId == 50020)*/ { // Blaze
                    lmCoordM = vec2(0.9, 0.0);
                    emission = min(color.r, 0.7) * 0.5;

                    float dotColor = dot(color.rgb, color.rgb);
                    if (abs(dotColor - 1.5) > 1.4) {
                        emission = 5.0;
                    }
                }
            } else {
                if (entityId == 50024) { // Creeper
                    emission = max0(color.b - color.g - color.r) * 5.0;
                } else /*if (entityId == 50028)*/ { // Drowned
                    if (atlasSize.x < 900) {
                        if (CheckForColor(color.rgb, vec3(143, 241, 215)) ||
                            CheckForColor(color.rgb, vec3( 49, 173, 183)) ||
                            CheckForColor(color.rgb, vec3(101, 224, 221))) emission = 3.0;
                    }
                }
            }
        }
    } else {
        if (entityId < 50048) {
            if (entityId < 50040) {
                if (entityId == 50032) { // Guardian        
                    vec3 absDif = abs(vec3(color.r - color.g, color.g - color.b, color.r - color.b));
                    float maxDif = max(absDif.r, max(absDif.g, absDif.b));
                    if (maxDif < 0.1 && color.b > 0.5) {
                        emission = pow2(pow2(color.b)) * 7.0;
                        color.rgb *= color.rgb;
                    }
                } else /*if (entityId == 50036)*/ { // Elder Guardian
                    if (CheckForColor(color.rgb, vec3(203, 177, 165)) ||
                        CheckForColor(color.rgb, vec3(214, 155, 126))) {
                        emission = pow2(pow2(color.b)) * 16.0;
                        color.r *= 1.2;
                    }
                }
            } else {
                if (entityId == 50040) { // Endermite
                    if (CheckForColor(color.rgb, vec3(87, 23, 50))) {
                        emission = 8.0;
                        color.rgb *= color.rgb;
                    }
                } else /*if (entityId == 50044)*/ { // Ghast
                    if (entityColor.a < 0.001)
                        emission = max0(color.r - color.g - color.b) * 6.0;
                }
            }
        } else {
            if (entityId < 50056) {
                if (entityId == 50048) { // Glow Squid
                    lmCoordM.x = 0.0;
                    float dotColor = dot(color.rgb, color.rgb);
                    emission = pow2(pow2(min(dotColor * 0.65, 1.5))) + 0.35;
                } else /*if (entityId == 50052)*/ { // Magma Cube
                    emission = color.g * 5.0;
                }
            } else {
                if (entityId == 50056) { // Stray
                    if (CheckForColor(color.rgb, vec3(230, 242, 246)) && texCoord.y > 0.35)
                        emission = 3.5;
                } else /*if (entityId == 50060)*/ { // Vex
                    lmCoordM = vec2(0.0);
                    emission = pow2(pow2(color.r)) * 3.5 + 0.5;
                    color.a *= color.a;
                }
            }
        }
    }
} else {
    if (entityId < 50096) {
        if (entityId < 50080) {
            if (entityId < 50072) {
                if (entityId == 50064) { // Witch
                    emission = 3.0 * color.g * color.g * float(color.g * 1.5 > color.b + color.r);
                } else /*if (entityId == 50068)*/ { // Wither, Wither Skull
                    lmCoordM.x = 0.9;
                    emission = 3.0 * float(dot(color.rgb, color.rgb) > 1.0);
                }
            } else {
                if (entityId == 50072) { // Experience Orb
                    emission = 6.5;

                    color.rgb *= color.rgb;
                } else /*if (entityId == 50076)*/ { // Boat
                    //playerPos.y += 0.18; // to avoid water shadow
                    playerPos.y += 0.38; // to also avoid the black inner shadow bug
                }
            }
        } else {
            if (entityId < 50088) {
                if (entityId == 50080) { // Allay
                    if (atlasSize.x < 900) {
                        lmCoordM = vec2(0.0);
                        emission = float(color.r > 0.9) * 5.0 + color.g;
                    } else {
                        lmCoordM.x = 0.8;
                    }
                } else /*if (entityId == 50084)*/ { //

                }
            } else {
                if (entityId == 50088) { // 
                
                } else /*if (entityId == 50092)*/ { //

                }
            }
        }
    } else {
        if (entityId < 50112) {
            if (entityId < 50104) {
                if (entityId == 50096) { // 
                
                } else /*if (entityId == 50100)*/ { //

                }
            } else {
                if (entityId == 50104) { // 
                
                } else /*if (entityId == 50108)*/ { //

                }
            }
        } else {
            if (entityId < 50120) {
                if (entityId == 50112) { // 
                
                } else /*if (entityId == 50116)*/ { //

                }
            } else {
                if (entityId == 50120) { // 
                
                } else if (entityId == 50124) { //

                }
            }
        }
    }
}