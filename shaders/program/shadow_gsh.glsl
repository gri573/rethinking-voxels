#include "/lib/common.glsl"

in vec2[3] texCoordV;
in vec2[3] lmCoordV;
in vec4[3] vertexColV;
in vec3[3] posV;
flat in int[3] vertexID;
flat in int[3] spriteSizeV;
flat in int[3] matV;

out vec2 texCoord;
out vec2 lmCoord;
out vec3 normal;
out vec4 vertexCol;
out vec3 pos;
flat out int spriteSize;
flat out int mat;
const int maxVerticesOut = 3;

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform ivec2 atlasSize;

#include "/lib/vx/voxelMapping.glsl"

const vec2[4] offsets = vec2[4](vec2(-1.0, -1.0), vec2(1.0, -1.0), vec2(1.0, 1.0), vec2(-1.0, 1.0));

void main() {
    vec3 avgPos = 0.5 * (max(max(posV[0], posV[1]), posV[2]) + min(min(posV[0], posV[1]), posV[2]));//(posV[0] + posV[1] + posV[2]) / 3.0;
    vec3 cnormal = cross(posV[0] - posV[1], posV[0] - posV[2]);
    float area = length(cnormal);
    cnormal = normalize(cnormal);
    avgPos += fract(cameraPosition);
    vec3 avgPos0 = avgPos;
    bool tracemat = true;
    bool doCuboidTexCoordCorrection = true;
    float zpos = 0.5 - sqrt(area) - 0.02 * fract(avgPos.y + 0.01) - 0.01 * fract(avgPos.x + 0.01)- 0.015 * fract(avgPos.z + 0.01) - 0.2 * cnormal.y;
    vec2 coord;
    switch(matV[0]) {
        case 50004:
            coord = vec2(0.5 / shadowMapResolution);
            zpos = -avgPos.z / (VXHEIGHT * VXHEIGHT);
            break;
        default:
            coord = getVxCoords(avgPos);
            if (coord.x < 1.0 / shadowMapResolution) return;
    }
    #include "/lib/materials/shadowchecks_gsh.glsl"
    if (max(abs(avgPos.x), abs(avgPos.z)) < vxRange / 2 && abs(avgPos.y) < VXHEIGHT * VXHEIGHT / 2 && tracemat) {
        vec2 outTexCoord = 0.5 * (max(max(texCoordV[0], texCoordV[1]), texCoordV[2]) + min(min(texCoordV[0], texCoordV[1]), texCoordV[2]));
        if (max(max(abs(cnormal.x), abs(cnormal.y)), abs(cnormal.z)) > 0.99 && doCuboidTexCoordCorrection) {
            int j = abs(cnormal.x) > abs(cnormal.y) ? (abs(cnormal.z) > abs(cnormal.x) ? 0 : 1) : (abs(cnormal.z) > abs(cnormal.y) ? 0 : 2);
            int k = (j + 1) % 3;
            vec3[3] blockRelVertPos0 = vec3[3](posV[0] + fract(cameraPosition) - floor(avgPos) - 0.5, posV[1] + fract(cameraPosition) - floor(avgPos) - 0.5, posV[2] + fract(cameraPosition) - floor(avgPos) - 0.5);
            vec2[3] rPos = vec2[3](vec2(blockRelVertPos0[0][j], blockRelVertPos0[0][k]), vec2(blockRelVertPos0[1][j], blockRelVertPos0[1][k]), vec2(blockRelVertPos0[2][j], blockRelVertPos0[2][k]));
            vec2 dTexCoorddj = vec2(0);
            vec2 dTexCoorddk = vec2(0);
            for (int i = 0; i < 3; i++) {
                vec2 dPos = rPos[(i + 1) % 3] - rPos[i];
                if (abs(dPos[0]) > 10 * abs(dPos[1])) dTexCoorddj = (texCoordV[(i + 1) % 3] - texCoordV[i]) / dPos[0];
                if (abs(dPos[1]) > 10 * abs(dPos[0])) dTexCoorddk = (texCoordV[(i + 1) % 3] - texCoordV[i]) / dPos[1];
            }
            vec3 avgRelPos = avgPos - floor(avgPos) - 0.5;
            outTexCoord -= dTexCoorddj * avgRelPos[j] + dTexCoorddk * avgRelPos[k];
        }
        for (int i = 0; i < 3; i++) {
            texCoord = outTexCoord;
            lmCoord = lmCoordV[i];
            normal = cnormal;
            vertexCol = vertexColV[i];
            vertexCol.a = area;
            pos = avgPos0;
            mat = matV[i];
            spriteSize = spriteSizeV[i];
            // using vertexID for the offset fixes translucent rendering on optifine, thanks to GeforceLegend for telling me that
            gl_Position = vec4(coord * 2 - vec2(1) + offsets[vertexID[i]%4] / shadowMapResolution, zpos, 1);
            EmitVertex();
        }
        EndPrimitive();
    }
}
