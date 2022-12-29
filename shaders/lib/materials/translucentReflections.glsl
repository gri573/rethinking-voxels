vec3 pos = vec3(0.0);
float dist = 0.0;
int sr = 0;

vec3 nViewPosR = reflect(nViewPos, normalM);
float RVdotU = dot(normalize(nViewPosR), upVec);
float RVdotS = dot(normalize(nViewPosR), sunVec);

vec3 start = viewPos;
vec3 vector = 0.5 * reflect(normalize(viewPos), normalize(normalM));
vec3 viewPosRT = viewPos + vector;
vec3 tvector = vector;

for(int i = 0; i < 30; i++) {
    pos = nvec3(gbufferProjection * nvec4(viewPosRT)) * 0.5 + 0.5;
    if (pos.x < -0.05 || pos.x > 1.05 || pos.y < -0.05 || pos.y > 1.05) break;

    vec3 rfragpos = vec3(pos.xy, texture2D(depthtex1, pos.xy).r);
    rfragpos = nvec3(gbufferProjectionInverse * nvec4(rfragpos * 2.0 - 1.0));
    dist = length(start - rfragpos);

    float dif = length(rfragpos) - length(viewPosRT);
    float err = min(abs(dif + 2.0), abs(dif));

    float lVector = length(vector) * (1.0 + clamp(0.25 * sqrt(dist), 0.3, 0.8)) * 1.4;
    if (err < lVector) {
            sr++;
            if(sr >= 6) break;
            tvector -= vector;
            vector *= 0.1;
    }
    vector *= 2.0;
    tvector += vector * (dither * 0.1 + 0.9);
    viewPosRT = start + tvector;
}

float border = clamp(1.0 - pow(cdist(pos.xy), 50.0), 0.0, 1.0);

vec4 reflection = vec4(0.0);
if (pos.z < 0.99997) {
    reflection.a = border;
    if (reflection.a > 0.001) {
        reflection.rgb = texture2D(gaux2, pos.xy).rgb;
    }
}

reflection.rgb = pow2(reflection.rgb + 1.0);

if (reflection.a < 1.0) {
    #ifdef OVERWORLD
        float skyLightFactor = pow2(max(lmCoordM.y - 0.7, 0.0) * 3.33333);

        vec3 skyReflection = GetSky(RVdotU, RVdotS, dither, true, true);
             skyReflection = mix(color.rgb * 0.5, skyReflection, skyLightFactor);

        float specularHighlight = GGX(normalM, nViewPos, lightVec, max(dot(normalM, lightVec), 0.0), smoothnessG);
        skyReflection += specularHighlight * highlightColor * shadowMult * highlightMult * invRainFactor;
    #elif defined END
        vec3 skyReflection = endSkyColor * shadowMult;
    #else
        vec3 skyReflection = vec3(0.0);
    #endif

    reflection.rgb = mix(skyReflection, reflection.rgb, reflection.a);
}

color.rgb = mix(color.rgb, reflection.rgb, fresnel * reflectMult);