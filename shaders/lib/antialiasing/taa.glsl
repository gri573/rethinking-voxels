#include "/lib/util/reprojection.glsl"

ivec2 neighbourhoodOffsets[8] = ivec2[8](
	ivec2(-1, -1),
	ivec2( 0, -1),
	ivec2( 1, -1),
	ivec2(-1,  0),
	ivec2( 1,  0),
	ivec2(-1,  1),
	ivec2( 0,  1),
	ivec2( 1,  1)
);

void NeighbourhoodClamping(vec3 color, inout vec3 tempColor, float depth, inout float edge) {
	vec3 minclr = color, maxclr = color;

	for (int i = 0; i < 8; i++) {
		float depthCheck = texelFetch(depthtex1, texelCoord + neighbourhoodOffsets[i], 0).r;
		if (abs(GetLinearDepth(depthCheck) - GetLinearDepth(depth)) > 0.09) edge = 10.0;
		vec3 clr = texelFetch(colortex3, texelCoord + neighbourhoodOffsets[i], 0).rgb;
		minclr = min(minclr, clr); maxclr = max(maxclr, clr);
	}

	tempColor = clamp(tempColor, minclr, maxclr);
}

void DoTAA(inout vec3 color, inout vec3 temp) {
	if (int(texelFetch(colortex1, texelCoord, 0).g * 255.1) == 4) { // No SSAO, No TAA
		return;
	}

	float depth = texelFetch(depthtex1, texelCoord, 0).r;
	vec3 coord = vec3(texCoord, depth);
	vec3 cameraOffset = cameraPosition - previousCameraPosition;
	vec2 prvCoord = Reprojection(coord, cameraOffset);
	
	vec2 view = vec2(viewWidth, viewHeight);
	vec3 tempColor = texture2D(colortex2, prvCoord).rgb;
	if (tempColor == vec3(0.0)) { // Fixes the first frame
		temp = color;
		return;
	}

	float edge = 0.0;
	NeighbourhoodClamping(color, tempColor, depth, edge);
	
	vec2 velocity = (texCoord - prvCoord.xy) * view;

	float blendFactor = float(prvCoord.x > 0.0 && prvCoord.x < 1.0 &&
	                          prvCoord.y > 0.0 && prvCoord.y < 1.0);
	//float blendMinimum = 0.6;
	//float blendVariable = 0.5;
	//float blendConstant = 0.4;
	float blendMinimum = 0.3;
	float blendVariable = 0.25;
	float blendConstant = 0.65;
	float lengthVelocity = length(velocity) * 100.0;
	blendFactor *= max(exp(-lengthVelocity) * blendVariable + blendConstant - length(cameraOffset) * edge, blendMinimum);
	
	color = mix(color, tempColor, blendFactor);
	temp = color;
	//if (edge > 0.05) color.rgb = vec3(1.0, 0.0, 1.0);
}