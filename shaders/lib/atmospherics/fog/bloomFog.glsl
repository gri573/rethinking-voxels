#ifdef CAVE_FOG
    #include "/lib/atmospherics/fog/caveFactor.glsl"
#endif

const float rainBloomAdd   = 8.0;
const float nightBloomAdd  = 3.0;
const float caveBloomAdd   = 10.0;
const float waterBloomAdd  = 14.0;
const float netherBloomAdd = 3.0;
//const float endBloomAdd    = 0.0;

float GetBloomFog(float lViewPos) {
    float bloomFog = pow2(pow2(1.0 - exp(- lViewPos * (0.02 + 0.04 * float(isEyeInWater == 1)))));
    
    #ifdef OVERWORLD
        float bloomFogMult; 
        if (isEyeInWater != 1) {
            bloomFogMult = (rainFactor2 * rainBloomAdd + nightBloomAdd * (1.0 - sunFactor)) * eyeBrightnessM;
            #ifdef CAVE_FOG
                bloomFogMult += GetCaveFactor() * caveBloomAdd;
            #endif
        } else {
            bloomFogMult = waterBloomAdd;
        }
    #elif defined NETHER
        float bloomFogMult = netherBloomAdd;
    #else
        //float bloomFogMult = endBloomAdd;
    #endif

    return 1.0 + bloomFog * bloomFogMult;
}