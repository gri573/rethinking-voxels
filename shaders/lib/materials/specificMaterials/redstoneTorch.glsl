noSmoothLighting = true; noDirectionalShading = true;
lmCoordM.x = min(lmCoordM.x * 0.9, 0.77);

if (color.r > 0.65) {
    emission = (3.5 - 2.25 * color.g) * 0.85;
    color.rgb *= color.rgb;
} else if (color.r > color.g * 2.0) {
    materialMask = OSIEBCA * 5.0; // Redstone Fresnel

    float factor = pow2(color.r);
    smoothnessG = 0.4;
    highlightMult = factor + 0.4;

    smoothnessD = factor * 0.7 + 0.3;
}