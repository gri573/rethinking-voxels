#ifndef MAPPING
#define MAPPING
//// needs uniform vec3 cameraPosition, previousCameraPosition

// voxel volume diameter
const int vxRange = 2 * (shadowMapResolution / (2 * VXHEIGHT));

// convert 3D position in voxel space to 2D position on the voxel map
ivec2 getVxPixelCoords(vec3 voxelPos) {
    voxelPos.y += VXHEIGHT * VXHEIGHT / 2;
    ivec2 coords = ivec2(voxelPos.xz + vxRange / 2);
    coords.x += int(voxelPos.y) % VXHEIGHT * vxRange;
    coords.y += int(voxelPos.y) / VXHEIGHT * vxRange;
    return clamp(coords, ivec2(1, 0), ivec2(shadowMapResolution - 1));
}

vec2 getVxCoords(vec3 voxelPos, vec2 size) {
    return (getVxPixelCoords(voxelPos) + vec2(0.5)) / size;
}

vec2 getVxCoords(vec3 voxelPos, float size) {
    return (getVxPixelCoords(voxelPos) + vec2(0.5)) / size;
}

vec2 getVxCoords(vec3 voxelPos) {
    return getVxCoords(voxelPos, shadowMapResolution);
}

// inverse function to getVxCoords
vec3 getVxPos(vec2 vxCoords) {
    vxCoords *= shadowMapResolution;
    vec3 pos;
    pos.xz = mod(vxCoords, vec2(vxRange)) - vxRange / 2;
    pos.y = floor(vxCoords.y / vxRange) * VXHEIGHT + floor(vxCoords.x / vxRange) - VXHEIGHT * VXHEIGHT / 2 + 0.5;
    return pos;
}

vec3 getVxPos(ivec2 vxCoords) {
    //vec2 vxCoords = vxCoords0;
    vec3 pos;
    pos.xz = mod(vxCoords, vec2(vxRange)) - vxRange / 2 + 0.5;
    pos.y = floor(float(vxCoords.y) / vxRange) * VXHEIGHT + floor(float(vxCoords.x) / vxRange) - VXHEIGHT * VXHEIGHT / 2 + 0.5;
    return pos;
}

// get voxel space position from world position
vec3 getVxPos(vec3 worldPos) {
    return worldPos + fract(cameraPosition);
}

// get previous voxel space position from world position
vec3 getPreviousVxPos(vec3 worldPos) {
    return getVxPos(worldPos) + (floor(cameraPosition) - floor(previousCameraPosition));
}

// determine if a position is within the voxelisation range
bool isInRange(vec3 pos, float margin) {
    return (max(abs(pos.x), abs(pos.z)) < vxRange / 2 - margin && abs(pos.y) < VXHEIGHT * VXHEIGHT / 2 - margin);
}
bool isInRange(vec3 pos) {
    return isInRange(pos, 0);
}

mat3 getRotMat(vec3 dir) {
    mat3 rotmat;
    rotmat[0] = normalize(cross(dir, vec3(0.000023, 1, -0.000064)));
    rotmat[1] = normalize(cross(dir, rotmat[0]));
    rotmat[2] = cross(rotmat[0], rotmat[1]);
    return rotmat;
}

vec4 getSunRayStartPos(vec3 pos0, vec3 sunDir) {
    vec3 borderPos = vec3(vxRange, VXHEIGHT * VXHEIGHT, vxRange) / 2.0 - 0.5;
    vec3 pos = getRotMat(sunDir) * pos0;
    float w = INF;
    float otherW = -INF;
    for (int k = 0; k < 3; k++) {
        float w0 = (borderPos[k] - pos[k]) / sunDir[k];
        float w1 = (-borderPos[k] - pos[k]) / sunDir[k];
        if (w0 > w1) {
            w = min(w0, w);
            otherW = max(w1, otherW);
        } else {
            w = min(w1, w);
            otherW = max(w0, otherW);
        }
    }
    return vec4(pos + (w) * sunDir, otherW - w);
}

float distortShadow(float shadowLength) {
    return sqrt(0.0030864197530864196 + shadowLength * 1.1111111111) - 0.0555555555;
}
float distortShadowDeriv(float shadowLength) {
    return 0.555555555 / sqrt(0.0030864197530864196 + shadowLength * 1.1111111111);
}
float undistortShadow(float distortedLength) {
    return 0.1 * distortedLength + 0.9 * distortedLength * distortedLength;
}

vec3 getShadowPos(vec3 vxPos, vec3 sunDir) {
    //vxPos -= vxPos.y / sunDir.y * sunDir;
    return transpose(getRotMat(sunDir)) * vxPos / vec2(0.75 * vxRange, 1).xxy;// + vec2(0.5, 0).xxy;
}
vec3 getShadowPos(vec3 vxPos, mat3 sunRotMat) {
    //vxPos -= vxPos.y / sunDir.y * sunDir;
    return transpose(sunRotMat) * vxPos / vec2(0.75 * vxRange, 1).xxy;// + vec2(0.5, 0).xxy;
}
#endif