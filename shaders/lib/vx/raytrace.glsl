#ifndef RAYTRACE
#define RAYTRACE
#include "/lib/vx/voxelMapping.glsl"
#include "/lib/vx/voxelReading.glsl"
#ifdef DISTANCE_FIELD
#ifndef COLORTEX11
#define COLORTEX11
uniform sampler2D colortex11;
#endif
#endif

const mat3 eye = mat3(
    1, 0, 0,
    0, 1, 0,
    0, 0, 1
);
// cuboid intersection algorithm
float aabbIntersect(vxData data, vec3 pos, vec3 dir, inout int n) {
    // offset to work around floating point errors
    vec3 offset = 0.001 * eye[n] * sign(dir[n]);
	// for connected blocks like walls, fences etc, figure out connection sides
	bool renderMainCuboid = true;
	bvec2 renderConnectCuboids = bvec2(false);
	vec3[4] connectCuboids = vec3[4](
		vec3(min(data.lower + 0.0625, 0.4375)),
		vec3(max(data.upper - 0.0625, 0.5625)),
		vec3(min(data.lower + 0.0625, 0.4375)),
		vec3(max(data.upper - 0.0625, 0.5625)));
	if (data.connectsides) {
		for (int k = 0; k < 4; k++) {
			connectCuboids[k].y = (k % 2 == 0) ? (abs(data.lower.x - 0.375) < 0.01 ? 0.375 : 0.0) : (abs(data.lower.x - 0.25) < 0.01 ? 0.875 : (abs(data.lower.x - 0.375) < 0.01 ? 0.9375 : 1.0));
			vec3 blockOffset = vec3(k % 2 * 2 - 1) * vec3(1 - (k >> 1), 0, k >> 1);
			vec3 thisOffsetPos = pos + offset + blockOffset;
			if (isInRange(thisOffsetPos)) {
				vxData offsetData = readVxMap(thisOffsetPos);
				if ((offsetData.connectsides && !(abs(offsetData.lower.x - 0.375) < 0.01 ^^ abs(data.lower.x - 0.375) < 0.01)) || (offsetData.full && !offsetData.alphatest)) {
					connectCuboids[k][2 * (k >> 1)] = k % 2;
					renderConnectCuboids[k >> 1] = true;
				}
			}
		}
		if (abs(data.lower.x - 0.25) < 0.01 && ((renderConnectCuboids == bvec2(true, false) && connectCuboids[0].x < 0.01 && connectCuboids[1].x > 0.99) || (renderConnectCuboids == bvec2(false, true) && connectCuboids[2].z < 0.01 && connectCuboids[3].z > 0.99))) renderMainCuboid = false;
	}
    // don't need to know global position, only relative to current block
    pos = fract(pos + offset) - offset;
    float w = 10000;
	for (int k = 0; k < 2; k++) {
		if (renderConnectCuboids[k]) {
			for (int i = 0; i < 3; i++) {
				if (dir[i] == 0) continue;
				for (int l = 0; l < 2; l++) {
					float w0 = (connectCuboids[2 * k + l][i] - pos[i]) / dir[i];
					// ray-plane intersection position needs to be closer than the previous best one and further than approximately 0
					bool valid = (w0 > -0.00005 / length(dir) && w0 < w);
					if (!valid) break;
					vec3 newPos = pos + w0 * dir;
					for (int j = 1; j < 3; j++) {
						int ij = (i + j) % 3;
						// intersection position also needs to be within other bounds
						if (newPos[ij] < connectCuboids[2 * k][ij] || newPos[ij] > connectCuboids[2 * k + 1][ij]) {
							valid = false;
							break;
						}
					}
					// update normal and ray position
					if (valid) {
						w = w0;
						n = i;
					}					
				}
			}
		}
	}
	if (renderMainCuboid) {
	vec3[2] bounds = vec3[2](data.lower, data.upper);
		for (int i = 0; i < 3; i++) {
			if (dir[i] == 0) continue;
			float relevantBound = bounds[dir[i] < 0 ? 1 : 0][i];
			float w0 = (relevantBound - pos[i]) / dir[i];
			if (w0 < -0.00005 / length(dir)) {
				relevantBound = bounds[dir[i] < 0 ? 0 : 1][i];
				w0 = (relevantBound - pos[i]) / dir[i];
			}
			vec3 newPos = pos + w0 * dir;
			// ray-plane intersection position needs to be closer than the previous best one and further than approximately 0
			bool valid = (w0 > -0.00005 / length(dir) && w0 < w);
			for (int j = 1; j < 3; j++) {
				int ij = (i + j) % 3;
				// intersection position also needs to be within other bounds
				if (newPos[ij] < bounds[0][ij] || newPos[ij] > bounds[1][ij]) {
					valid = false;
					break;
				}
			}
			// update normal and ray position
			if (valid) {
				w = w0;
				n = i;
			}
		}
	}
    return w;
}
// returns color data of the block at pos, when hit by ray in direction dir
vec4 handledata(vxData data, sampler2D atlas, inout vec3 pos, vec3 dir, int n) {
    if (!data.crossmodel) {
        if (data.cuboid) {
            float w = aabbIntersect(data, pos, dir, n);
            if (w > 9999) return vec4(0);
            pos += w * dir;
        }
        vec2 spritecoord = vec2(n != 0 ? fract(pos.x) : fract(pos.z), n != 1 ? fract(-pos.y) : fract(pos.z)) * 2 - 1;
        ivec2 texcoord = ivec2(data.texcoord * atlasSize + (data.spritesize - 0.5) * spritecoord);
        vec4 color = texelFetch(atlas, texcoord, 0);
        if (!data.alphatest) color.a = 1;
        else if (color.a > 0.1 && color.a < 0.9) color.a = pow(color.a, TRANSLUCENT_LIGHT_TINT);
        // multiply by vertex color for foliage, water etc
        color.rgb *= data.emissive ? vec3(1) : data.lightcol;
        return color;
    }
    // get around floating point errors using an offset
    vec3 offset = 0.001 * eye[n] * sign(dir[n]);
    vec3 blockInnerPos0 = fract(pos + offset) - offset;
    vec3 blockInnerPos = blockInnerPos0 - vec3(data.midcoord.x, 0, data.midcoord.z);;
    // ray-plane intersections
    float w0 = (-blockInnerPos.x - blockInnerPos.z) / (dir.x + dir.z);
    float w1 = (blockInnerPos.x - blockInnerPos.z) / (dir.z - dir.x);
    vec3 p0 = blockInnerPos + w0 * dir + vec3(0.5, 0, 0.5);
    vec3 p1 = blockInnerPos + w1 * dir + vec3(0.5, 0, 0.5);
    bool valid0 = (max(max(abs(p0.x - 0.5), 0.8 * abs(p0.y - 0.5)), abs(p0.z - 0.5)) < 0.4) && w0 > -0.0001;
    bool valid1 = (max(max(abs(p1.x - 0.5), 0.8 * abs(p1.y - 0.5)), abs(p1.z - 0.5)) < 0.4) && w1 > -0.0001;
    vec4 color0 = valid0 ? texelFetch(atlas, ivec2(data.texcoord * atlasSize + (data.spritesize - 0.5) * (1 - p0.xy * 2)), 0) : vec4(0);
    vec4 color1 = valid1 ? texelFetch(atlas, ivec2(data.texcoord * atlasSize + (data.spritesize - 0.5) * (1 - p1.xy * 2)), 0) : vec4(0);
    color0.xyz *= data.emissive ? vec3(1) : data.lightcol;
    color1.xyz *= data.emissive ? vec3(1) : data.lightcol;
    pos += (valid0 ? w0 : (valid1 ? w1 : 0)) * dir;
    // the more distant intersection position only contributes by the amount of light coming through the closer one
    return (w0 < w1) ? (vec4(color0.xyz * color0.a, color0.a) + (1 - color0.a) * vec4(color1.xyz * color1.a, color1.a)) : (vec4(color1.xyz * color1.a, color1.a) + (1 - color1.a) * vec4(color0.xyz * color0.a, color0.a));
}
// voxel ray tracer
vec4 raytrace(bool lowDetail, inout vec3 pos0, bool doScattering, vec3 dir, inout vec3 translucentHit, sampler2D atlas, bool translucentData) {
    ivec3 dcamPos = ivec3(1.001 * (floor(cameraPosition) - floor(previousCameraPosition)));
    vec3 progress;
    for (int i = 0; i < 3; i++) {
        //set starting position in each direction
        progress[i] = -(dir[i] < 0 ? fract(pos0[i]) : fract(pos0[i]) - 1) / dir[i];
    }
    int i = 0;
    // get closest starting position
    float w = progress[0];
    for (int i0 = 1; i0 < 3; i0++) {
        if (progress[i0] < w) {
            i = i0;
            w = progress[i];
        }
    }
    // step size in each direction (to keep to the voxel grid)
    vec3 stp = abs(1 / dir);
    float dirlen = length(dir);
    float invDirLenScaled = 0.001 / dirlen;
    vec3 dirsgn = sign(dir);
    vec3[3] eyeOffsets;
    for (int k = 0; k < 3; k++) {
        eyeOffsets[k] = 0.0001 * eye[k] * dirsgn[k];
    }
    vec3 pos = pos0 + invDirLenScaled * dir;
    vec3 scatterPos = pos0;
    vec4 raycolor = vec4(0);
    vec4 oldRayColor = vec4(0);
    const float scatteringMaxAlpha = 0.1;
    // check if stuff already needs to be done at starting position
    vxData voxeldata = readVxMap(getVxPixelCoords(pos));
    bool isScattering = false;
    if (lowDetail && voxeldata.full && !voxeldata.alphatest) return vec4(0, 0, 0, translucentData ? 0 : 1);
    if (isInRange(pos) && voxeldata.trace && !lowDetail) {
        raycolor = handledata(voxeldata, atlas, pos, dir, i);
        if (doScattering && raycolor.a > 0.1) isScattering = (voxeldata.mat == 10004 || voxeldata.mat == 10008 || voxeldata.mat == 10016);
        if (doScattering && isScattering) {
            scatterPos = pos;
            raycolor.a = min(scatteringMaxAlpha, raycolor.a);
        }
        raycolor.rgb *= raycolor.a;
    }
    if (raycolor.a > 0.01 && raycolor.a < 0.9) translucentHit = pos;
    int k = 0; // k is a safety iterator
    int mat = raycolor.a > 0.1 ? voxeldata.mat : 0; // for inner face culling
    vec3 oldPos = pos;
    bool oldFull = voxeldata.full;
    bool wasInRange = false;
    // main loop
    while (w < 1 && k < 2000 && raycolor.a < 0.99) {
        oldRayColor = raycolor;
        pos = pos0 + (min(w, 1.0)) * dir + eyeOffsets[i];
        #ifdef DISTANCE_FIELD
        ivec4 dfdata;
        #endif
        // read voxel data at new position and update ray colour accordingly
        if (isInRange(pos)) {
            wasInRange = true;
            ivec2 vxCoords = getVxPixelCoords(pos);
            voxeldata = readVxMap(vxCoords);
            #ifdef DISTANCE_FIELD
            ivec2 oldCoords = getVxPixelCoords(pos + dcamPos);
            dfdata = ivec4(texelFetch(colortex11, oldCoords, 0) * 65525 + 0.5);
            #endif
            pos -= eyeOffsets[i];
            if (lowDetail) {
                if (voxeldata.trace && voxeldata.full && !voxeldata.alphatest) {
                    pos0 = pos + eyeOffsets[i];
                    return vec4(0, 0, 0, translucentData ? 0 : 1);
                }
            } else {
                bool newScattering = false;
                if (voxeldata.trace) {
                    vec4 newcolor = handledata(voxeldata, atlas, pos, dir, i);
                    if (dot(pos - pos0, dir) < 0.0) newcolor.a = 0;
                    bool samemat = voxeldata.mat == mat;
                    mat = (newcolor.a > 0.1) ? voxeldata.mat : 0;
                    if (doScattering) newScattering = (mat == 10004 || mat == 10008 || mat == 10016);
                    if (newScattering) newcolor.a = min(newcolor.a, scatteringMaxAlpha);
                    if (samemat) newcolor.a = clamp(10.0 * newcolor.a - 9.0, 0.0, 1.0);
                    raycolor.rgb += (1 - raycolor.a) * newcolor.a * newcolor.rgb;
                    raycolor.a += (1 - raycolor.a) * newcolor.a;
                    if (oldRayColor.a < 0.01 && raycolor.a > 0.01 && raycolor.a < 0.9) translucentHit = pos;
                }
                if (doScattering) {
                    if (isScattering) {
                        scatterPos = pos;
                    }
                    oldFull = voxeldata.full;
                    oldPos = pos;
                    isScattering = newScattering;
                }
            }
            #if CAVE_SUNLIGHT_FIX > 0
            if (!isInRange(pos, 2)) {
                int height = int(texelFetch(colortex10, ivec2(pos.xz + floor(cameraPosition.xz) - floor(previousCameraPosition.xz) + vxRange / 2), 0).w * 65535 + 0.5) % 256 - VXHEIGHT * VXHEIGHT / 2;
                if (pos.y + floor(cameraPosition.y) - floor(previousCameraPosition.y) < height) {
                    raycolor.a = 1;
                }
            }
            #endif
            pos += eyeOffsets[i];
        }
        else {
            #ifdef DISTANCE_FIELD
            dfdata.x = int(max(max(abs(pos.x), abs(pos.z)) - vxRange / 2, abs(pos.y) - VXHEIGHT * VXHEIGHT / 2) + 0.5);
            #endif
            if (wasInRange) break;
        }
        // update position
        #ifdef DISTANCE_FIELD
        if (dfdata.x % 256 == 0) dfdata.x++;
        for (int j = 0; j < dfdata.x % 256; j++) {
        #endif
            progress[i] += stp[i];
            w = progress[0];
            i = 0;
            for (int i0 = 1; i0 < 3; i0++) {
                if (progress[i0] < w) {
                    i = i0;
                    w = progress[i];
                }
            }
        #ifdef DISTANCE_FIELD
        }
        #endif
        k++;
    }
    float oldAlpha = raycolor.a;
    raycolor.a = 1 - exp(-4*length(scatterPos - pos0)) * (1 - raycolor.a);
    raycolor.rgb += raycolor.a - oldAlpha; 
    pos0 = pos;
    if (k == 2000) {
        oldRayColor = vec4(1, 0, 0, 1);
        raycolor = vec4(1, 0, 0, 1);
    }
    return translucentData ? oldRayColor : raycolor;
}

vec4 raytrace(inout vec3 pos0, bool doScattering, vec3 dir, sampler2D atlas, bool translucentData) {
    vec3 translucentHit = vec3(0);
    return raytrace(false, pos0, doScattering, dir, translucentHit, atlas, translucentData);
}

vec4 raytrace(bool lowDetail, inout vec3 pos0, vec3 dir, inout vec3 translucentHit, sampler2D atlas, bool translucentData) {
    return raytrace(lowDetail, pos0, false, dir, translucentHit, atlas, translucentData);
}
vec4 raytrace(inout vec3 pos0, bool doScattering, vec3 dir, sampler2D atlas) {
    vec3 translucentHit = vec3(0);
    return raytrace(false, pos0, doScattering, dir, translucentHit, atlas, false);
}
vec4 raytrace(inout vec3 pos0, vec3 dir, inout vec3 translucentHit, sampler2D atlas, bool translucentData) {
    return raytrace(false, pos0, dir, translucentHit, atlas, translucentData);
}
vec4 raytrace(bool lowDetail, inout vec3 pos0, vec3 dir, sampler2D atlas) {
    vec3 translucentHit = vec3(0);
    return raytrace(lowDetail, pos0, dir, translucentHit, atlas, false);
}
vec4 raytrace(bool lowDetail, inout vec3 pos0, vec3 dir, sampler2D atlas, bool translucentData) {
    vec3 translucentHit = vec3(0);
    return raytrace(lowDetail, pos0, dir, translucentHit, atlas, translucentData);
}
vec4 raytrace(inout vec3 pos0, vec3 dir, sampler2D atlas, bool translucentData) {
    vec3 translucentHit = vec3(0);
    return raytrace(pos0, dir, translucentHit, atlas, translucentData);
}
vec4 raytrace(inout vec3 pos0, vec3 dir, sampler2D atlas) {
    return raytrace(pos0, dir, atlas, false);
}
#endif