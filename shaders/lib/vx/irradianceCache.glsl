#ifndef IRRADIANCECACHE
#define IRRADIANCECACHE
bool isInRange(vec3 vxPos) {
    return all(greaterThan(vxPos, -0.5*voxelVolumeSize)) && all(lessThan(vxPos, 0.5*voxelVolumeSize));
}

uniform sampler3D irradianceCache;

vec3 readIrradianceCache(vec3 vxPos, vec3 normal) {
    if (!isInRange(vxPos)) return vec3(0);
    vxPos = ((vxPos + 0.5 * normal) / voxelVolumeSize + 0.5) * vec3(1.0, 0.5, 1.0);
    vec4 color = textureLod(irradianceCache, vxPos, 0);
    return color.rgb / max(color.a, 0.0001);
}

vec3 readSurfaceVoxelBlocklight(vec3 vxPos, vec3 normal) {
    if (!isInRange(vxPos)) return vec3(0);
    vxPos = ((vxPos + 0.5 * normal) / voxelVolumeSize + vec3(0.5, 1.5, 0.5)) * vec3(1.0, 0.5, 1.0);
    vec4 color = textureLod(irradianceCache, vxPos, 0);
    float lColor = length(color.rgb);
    if (lColor > 0.01) color.rgb *= log(lColor + 1) / lColor;
    return color.rgb;// / max(color.a, 0.0001);
}

vec3 readVolumetricBlocklight(vec3 vxPos) {
    if (!isInRange(vxPos)) return vec3(0);
    vxPos = (vxPos / voxelVolumeSize + vec3(0.5, 1.5, 0.5)) * vec3(1.0, 0.5, 1.0);
    vec4 color = textureLod(irradianceCache, vxPos, 0);
    return color.rgb / max(color.a, 0.0001);
}
#endif