if (color.g < 0.05 && color.b > 0.3) {
    smoothnessG = 0.4;
    highlightMult = 1.5;
    smoothnessD = 0.3;

    float factor = pow2(color.b);
    emission = 0.9 + pow2(pow2(factor)) * 7.5;
    color.r *= 1.15;

    maRecolor = vec3(min(max0(factor * 0.7 - 0.1) * 1.3, 0.5));
} else {
    #include "/lib/materials/specificMaterials/obsidian.glsl"
}