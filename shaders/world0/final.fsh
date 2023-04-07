#version 430 compatibility

#ifndef IS_IRIS
#include "/lib/iris_required.glsl"
#else
#define FRAGMENT_SHADER
#define OVERWORLD
#define FINAL

#include "/program/final.glsl"
#endif
