#include "/lib/common.glsl"
#ifdef FSH
noperspective in vec2 lrTexCoord;
flat in mat4 unProjectionMatrix;
flat in mat4 prevProjectionMatrix;
#ifdef ACCUMULATION
	uniform int frameCounter;

    uniform float viewWidth;
    uniform float viewHeight;
    vec2 view = vec2(viewWidth, viewHeight);

    uniform float near;
    uniform float far;
    float farPlusNear = far + near;
    float farMinusNear = far - near;

    uniform vec3 cameraPosition;
    uniform vec3 previousCameraPosition;

    uniform sampler2D colortex2;
	uniform sampler2D colortex4;
    uniform sampler2D colortex8;
    const bool colortex10MipmapEnabled = true;
    uniform sampler2D colortex12;
    uniform sampler2D colortex13;
    float GetLinearDepth(float depth) {
        return (2.0 * near) / (farPlusNear - depth * (farMinusNear));
    }
	#define DENOISE_DATA
	#define WRITE_TO_SSBOS
	#include "/lib/vx/SSBOs.glsl"
#endif
uniform sampler2D colortex10;

#define FALLOFF_SPEED 0.1
#define MAX_OLDWEIGHT 0.9
void main() {
    vec4 newColor = texture(colortex10, lrTexCoord);
    #ifdef ACCUMULATION
	    newColor.a = texelFetch(colortex10, ivec2(lrTexCoord * view), 0).a;
        vec4 normalDepthData = texelFetch(colortex8, ivec2(gl_FragCoord.xy), 0);
        vec4 playerPos = unProjectionMatrix * vec4(gl_FragCoord.xy / view * 2 - 1, 1 - 2 * normalDepthData.w, 1);
        vec4 prevPlayerPos = vec4(playerPos.xyz / playerPos.w + cameraPosition - previousCameraPosition, 1);
        vec4 prevPos = prevProjectionMatrix * prevPlayerPos;
        float ndotv = -dot(normalize(playerPos.xyz), normalDepthData.xyz);
        float normalWeight = clamp(-dot(normalize(prevPlayerPos.xyz), normalDepthData.xyz) / ndotv, 1 - ndotv, 1);
        normalWeight *= normalWeight;
        if (normalDepthData.a < 0.44) {
            prevPos.xyz = 0.5 * prevPos.xyz / prevPos.w + 0.5;
            prevPos.xy *= view;
        } else {
            prevPos = vec4(gl_FragCoord.xy, 1 - normalDepthData.a, 1);
        }
        vec4 prevColor = vec4(0);
		float prevMoment = 0;
        float prevLightCount = 0;
        vec4 tex13Data = vec4(0);
        float weight = FALLOFF_SPEED * max(0, 1 - 1.5 * length(fract(view * lrTexCoord) - 0.5));
        float prevCompareDepth = GetLinearDepth(prevPos.z);
        if (prevPos.xy == clamp(prevPos.xy, vec2(1), view - 1)) {
            ivec2 prevCoords = ivec2(prevPos.xy);
			ivec2 lowLeftCornerPrevCoords = ivec2(prevPos.xy - 0.5);
			float totalWeight = 0;
			prevColor = texture(colortex12, prevPos.xy / view);
			prevMoment = denoiseSecondMoment[
				prevCoords.x + 
				int(view.x + 0.5) * (prevCoords.y + 
				(frameCounter-1) % 2 * int(view.y + 0.5))
			];
			prevColor.a *= normalWeight;
			prevColor.a = clamp(
				MAX_OLDWEIGHT * (
					1 - 2 * (1 - GetLinearDepth(1 - normalDepthData.a)) * 
					length(cameraPosition - previousCameraPosition)
				), 0.8 * prevColor.a, prevColor.a
			);

			float prevDepth = 1 - texelFetch(colortex2, prevCoords, 0).a;

			float prevLinDepth = prevDepth < 0.99999 && prevDepth > 0 ? GetLinearDepth(prevDepth) : 20;
			float validMult = float(
				(max(abs(prevDepth - prevPos.z),
				abs(prevLinDepth - prevCompareDepth) / (prevLinDepth + prevCompareDepth)) * ndotv < 0.01) &&
				normalDepthData.a < 1.5 &&
				length(normalDepthData.rgb) > 0.1
			);

			prevColor.a *= validMult;
        }

		if (prevColor.a < 5.1 * FALLOFF_SPEED && prevMoment == 0) {
			for (int k = 0; k < 9; k++) {
				if (k == 4) continue;
				ivec2 offset = ivec2(k%3, k/3);
				ivec2 offsetCoord = ivec2(gl_FragCoord.xy) + offset * 2;
				vec4 aroundLight = texelFetch(colortex10, ivec2(lrTexCoord * view + offset), 0);

				if (any(lessThan(offsetCoord, ivec2(0))) || any(greaterThanEqual(offsetCoord, ivec2(view + 0.5)))) continue;
				prevMoment = max(prevMoment, max(denoiseSecondMoment[
					offsetCoord.x +
					int(view.x + 0.5) * (offsetCoord.y +
					(frameCounter-1) % 2 * int(view.y + 0.5))
				], pow2(dot(aroundLight.rgb, vec3(1)))));
			}
		}

		float mixFactor = prevColor.a / max(prevColor.a + weight, 0.001);
		float momentMixAddition = 0;// (1 - mixFactor) * (1 - prevColor.a / (5.1 * FALLOFF_SPEED));

		denoiseSecondMoment[
			int(gl_FragCoord.x) + 
			int(view.x + 0.5) * (int(gl_FragCoord.y) + 
			(frameCounter) % 2 * int(view.y + 0.5))
		] = mix(pow2(dot(newColor.rgb, vec3(1))), prevMoment, mixFactor + momentMixAddition);

        /*RENDERTARGETS:12,13*/
        gl_FragData[0] = vec4(
            mix(newColor.rgb, prevColor.rgb, mixFactor),
            min(prevColor.a + weight, MAX_OLDWEIGHT)
        );
        //gl_FragData[0].rgb = vec3(ndotv);
        gl_FragData[1] = tex13Data;
    #else
        /*RENDERTARGETS:12*/
        gl_FragData[0] = vec4(newColor.rgb, 0);
    #endif
}
#endif
#ifdef VSH

noperspective out vec2 lrTexCoord;
flat out mat4 unProjectionMatrix;
flat out mat4 prevProjectionMatrix;

uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;
vec2 view = vec2(viewWidth, viewHeight);

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

void main() {
    unProjectionMatrix = gbufferModelViewInverse
                       * gbufferProjectionInverse;
    prevProjectionMatrix = gbufferPreviousProjection
                         * gbufferPreviousModelView;
    gl_Position = ftransform();
    lrTexCoord = gl_Position.xy / gl_Position.w * 0.5 + 0.5;
    lrTexCoord = 0.5 * (lrTexCoord - vec2(frameCounter % 2, frameCounter / 2 % 2) / view);
}
#endif