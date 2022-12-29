subsurfaceMode = 2;

#ifdef IPBR
    float factor = min1(pow2(color.g) * 2.0);
    smoothnessG = factor * 0.5;
    highlightMult = factor * 2.0;

    //smoothnessG = min1(pow2(color.g) * 2.0) * 0.5;
    //highlightMult = color.g * 3.0;
#endif

#ifdef SNOWY_WORLD
    snowMinNdotU = min(pow2(pow2(color.g)), 0.1);
    color.rgb = color.rgb * 0.5 + 0.5 * (color.rgb / glColor.rgb);
#endif