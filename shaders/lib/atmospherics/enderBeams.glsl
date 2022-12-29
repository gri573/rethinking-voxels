#include "/lib/colors/lightAndAmbientColors.glsl"

vec3 endOrangeCol = vec3(1.0, 0.3, 0.0);
vec3 beamPurple = normalize(ambientColor * ambientColor * ambientColor) * (2.5 - 1.0 * vlFactor);
vec3 beamOrange = endOrangeCol * (300.0 + 700.0 * vlFactor);

vec2 wind = vec2(syncedTime * 0.0016);

float BeamNoise(vec2 planeCoord, vec2 wind) {
    float noise = texture2D(noisetex, planeCoord * 0.175   - wind * 0.0625).b;
          noise+= texture2D(noisetex, planeCoord * 0.04375 + wind * 0.0375).b * 5.0;

    return noise;
}

vec3 DrawEnderBeams(float VdotU, vec3 playerPos) {
    int sampleCount = 8;
    
    float VdotUM = 1.0 - VdotU * VdotU;
    float VdotUM2 = VdotUM + smoothstep1(pow2(pow2(1.0 - abs(VdotU)))) * 0.2;

    vec4 beams = vec4(0.0);
    float gradientMix = 1.0;
    for(int i = 0; i < sampleCount; i++) {
        vec2 planeCoord = (playerPos.xz + cameraPosition.xz) * (1.0 + i * 6.0 / sampleCount) * 0.0014;

        float noise = BeamNoise(planeCoord, wind);
              noise = max(0.75 - 1.0 / abs(noise - (4.0 + VdotUM * 2.0)), 0.0) * 3.0;

        if (noise > 0.0) {
            noise *= 0.65;
            float fireNoise = texture2D(noisetex, abs(planeCoord * 0.2) - wind).b;
            noise *= 0.5 * fireNoise + 0.75;
            noise = noise * noise * 3.0 / sampleCount;
            noise *= VdotUM2;

            vec3 beamColor = beamPurple;
            beamColor += beamOrange * pow2(pow2(fireNoise - 0.5));
            beamColor *= gradientMix / sampleCount;

            noise *= exp2(-6.0 * i / float(sampleCount));
            beams += vec4(noise * beamColor, noise);
        }
        gradientMix += 1.0;
    }

    beams.rgb *= beams.a * beams.a * beams.a * 3.5;
    beams.rgb = sqrt(beams.rgb);

    return beams.rgb;
}