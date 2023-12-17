#include "/lib/common.glsl"

//////Fragment Shader//////Fragment Shader//////
#ifdef FSH
in vec3 dir;

uniform sampler2D colortex8;
uniform float viewWidth;
uniform float viewHeight;
vec2 view = vec2(viewWidth, viewHeight);
uniform vec3 cameraPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelView;

const ivec2 offsets[8] = ivec2[8](
    ivec2( 1, 0),
    ivec2( 1, 1),
    ivec2( 0, 1),
    ivec2(-1, 1),
    ivec2(-1, 0),
    ivec2(-1,-1),
    ivec2( 0,-1),
    ivec2( 1,-1));

#undef RT_ENTITIES
#include "/lib/vx/SSBOs.glsl"
#include "/lib/vx/raytrace.glsl"

void main() {
    ivec2 texelCoord = ivec2(gl_FragCoord.xy);
    vec4 writeData = texelFetch(colortex8, texelCoord, 0);
    if (writeData.a > 1.5) {
        vec4 avgAroundData = vec4(0);
        int validAroundCount = 0;
        bool extendable = true;
        for (int k = 0, invalidInARow = 0; k < 10; k++) {
            vec4 aroundData = texelFetch(colortex8, texelCoord + offsets[k%8], 0);
            if (aroundData.a > 1.5) {
                invalidInARow++;
                if (invalidInARow >= 4) {
                    extendable = false;
                    break;
                }
                continue;
            }
            invalidInARow = 0;
            if (k < 8) {
                avgAroundData += aroundData;
                validAroundCount++;
            }
        }
        if (extendable) {
            writeData = avgAroundData / validAroundCount;
        } else {
            // fuck view bobbing!
            ray_hit_t rayHit = raytrace(fract(cameraPosition) - gbufferModelView[3].xyz, dir);
            if (rayHit.mat >= 0) {
                writeData.rgb = rayHit.normal;
                vec4 clipHitPos = gbufferProjection * (gbufferModelView * vec4(rayHit.pos - fract(cameraPosition), 1));
                clipHitPos = 0.5 / clipHitPos.w * clipHitPos + 0.5;
                writeData.a = 1 - clipHitPos.z;
            }
        }
    }
    /*RENDERTARGETS:8*/
    gl_FragData[0] = writeData;
}
#endif

//////Vertex Shader//////Vertex Shader//////
#ifdef VSH

out vec3 dir;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#define DECLARE_CAMPOS
#include "/lib/vx/SSBOs.glsl"

void main() {
    gl_Position = ftransform();
    dir = normalize((gbufferModelViewInverse * (gbufferProjectionInverse * vec4(gl_Position.xy / gl_Position.w, 0.9999, 1))).xyz) * (voxelVolumeSize.x * 0.4);
}
#endif