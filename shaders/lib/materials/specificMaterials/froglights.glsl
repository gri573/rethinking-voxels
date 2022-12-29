noSmoothLighting = true; noDirectionalShading = true;
lmCoordM = vec2(0.9, 0.0);

vec2 signMidCoordPosM = abs((floor((signMidCoordPos + 1.0) * 8.0) + 0.5) * 0.125 - 1.0);
float value = 1.0 - max(signMidCoordPosM.x, signMidCoordPosM.y);
emission = 0.3 + value + pow(dot(color.rgb, color.rgb) * 0.33, frogPow);

color.rgb = pow2(color.rgb);