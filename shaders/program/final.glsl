////////////////////////////////////////
// Complementary Reimagined by EminGT //
////////////////////////////////////////

//Common//
#include "/lib/common.glsl"

//////////Fragment Shader//////////Fragment Shader//////////Fragment Shader//////////
#ifdef FRAGMENT_SHADER

noperspective in vec2 texCoord;

//Uniforms//
uniform float viewWidth, viewHeight;

uniform sampler2D colortex3;

#ifdef UNDERWATER_DISTORTION
	uniform int isEyeInWater;

	uniform float frameTimeCounter;
#endif

//Pipeline Constants//
/*
const int colortex0Format = R11F_G11F_B10F; //main color
const int colortex1Format = RGB8;			//smoothnessD & materialMask & skyLightFactor
const int colortex2Format = RGBA16;		    //taa
const int colortex3Format = RGB8;		    //*cloud texture on deferred* & translucentMult & bloom & final color
const int colortex4Format = R8;				//volumetric cloud linear depth & volumetric light factor
const int colortex5Format = RGB8_SNORM;		//normalM & scene image for water reflections
const int colortex6Format = R8;		        //*cloud texture on gbuffers*
#ifdef TEMPORAL_FILTER
const int colortex7Format = RGBA16F;		//temporal filter
#endif
// voxel data
const int shadowcolor0Format = RGBA16;
const int shadowcolor1Format = RGBA16;
const int colortex8Format = RGBA16;
const int colortex9Format = RGBA16;
const int colortex10Format = RGBA16;
const int colortex11Format = RGBA16;

//colortex7
*/

const bool colortex0Clear = true;
const bool colortex1Clear = true;
const bool colortex2Clear = false;
const bool colortex3Clear = true;
const bool colortex4Clear = false;
const bool colortex5Clear = false;
// temporal voxel data such as flood fill
const bool colortex8Clear = false;
const bool colortex9Clear = false;
const bool colortex10Clear = false;
const bool colortex11Clear = false;
#ifdef TEMPORAL_FILTER
const bool colortex6Clear = false;
const bool colortex7Clear = false;
#endif

const int noiseTextureResolution = 128;

const bool shadowHardwareFiltering = true;
const float shadowDistanceRenderMul = 1.0;
const float entityShadowDistanceMul = 1.0; // Iris devs may bless us with their power

const float drynessHalflife = 300.0;
const float wetnessHalflife = 300.0;

const float ambientOcclusionLevel = 1.0;

//Common Variables//

//Common Functions//

//Includes//

//Program//
//uniform sampler2D colortex11;
void main() {
	vec2 texCoordM = texCoord;

	#ifdef UNDERWATER_DISTORTION
		if (isEyeInWater == 1) texCoordM += 0.0007 * sin((texCoord.x + texCoord.y) * 25.0 + frameTimeCounter * 3.0);
	#endif

	vec3 color = texture2D(colortex3, texCoordM).rgb;
//	ivec2 pixelCoord = ivec2(texCoord * textureSize(colortex3, 0));
//	vec3 vxPos = vec3(getVxPos(pixelCoord));
//	vec4 light = texelFetch(colortex11, pixelCoord, 0);
//	if (max(pixelCoord.x, pixelCoord.y) < shadowMapResolution) color = light.yyz;
	/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0);
}

#endif

//////////Vertex Shader//////////Vertex Shader//////////Vertex Shader//////////
#ifdef VERTEX_SHADER

noperspective out vec2 texCoord;

//Uniforms//

//Attributes//

//Common Variables//

//Common Functions//

//Includes//

//Program//
void main() {
	gl_Position = ftransform();
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
