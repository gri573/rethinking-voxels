// Made by Balint for Iris 1.6.
// You are free to include this in any pack, as long as this notice is not removed.

uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;

const vec3 SPACE_COLOR = vec3(0.07, 0.27, 0.46);
const vec2 SPACE_SPEED = vec2(0.5, 0.0);
const vec2 STAR_CELL_SIZE = vec2(0.1);
const float STAR_PERCENTAGE = 0.1;
const float STAR_SHINE_SPEED = 4.0; // State changes per second
const int STAR_STATES = 6;
const int[] STARS = int[](1, 18, 278, 4365, 5128, 4104);

const float PIXEL_SIZE = 0.007;
const float RAINBOW_WAVE_SPEED = 2.0;
const float WAVE_PIXEL_LENGTH = 10.0;
const vec3[] RAINBOW = vec3[](
    vec3(0.47, 0.27, 1),
    vec3(0.07, 0.67, 1),
    vec3(0.25, 1, 0.05),
    vec3(1, 1, 0.02),
    vec3(1, 0.65, 0.05),
    vec3(1, 0.07, 0.07)
);

const float LOGO_SIZE = 0.35;
const vec3[] LOGO_COLORS = vec3[](
    vec3(0.9, 0.23, 0.23),
    vec3(0.97, 0.41, 0.11),
    vec3(0.95, 0.48, 0.29),
    vec3(0.96, 0.75, 0.16),
    vec3(0.97, 0.71, 0.33),
    vec3(0.56, 0.85, 0.4),
    vec3(0.11, 0.73, 0.44),
    vec3(0.05, 0.68, 0.6),
    vec3(0.18, 0.87, 0.71),
    vec3(0.55, 0.96, 0.87),
    vec3(0.3, 0.39, 0.69),
    vec3(0.3, 0.6, 0.89),
    vec3(0.55, 0.82, 0.98),
    vec3(0.65, 0.51, 0.94),
    vec3(0.91, 0.67, 0.92),
    vec3(0.92, 0.49, 0.59)
);

const float PI = 3.141592654;

// Characters

const uint _A     = 0x747f18c4u;
const uint _B     = 0xf47d18f8u;
const uint _C     = 0x746108b8u;
const uint _D     = 0xf46318f8u;
const uint _E     = 0xfc39087cu;
const uint _F     = 0xfc390840u;
const uint _G     = 0x7c2718b8u;
const uint _H     = 0x8c7f18c4u;
const uint _I     = 0x71084238u;
const uint _J     = 0x084218b8u;
const uint _K     = 0x8cb928c4u;
const uint _L     = 0x8421087cu;
const uint _M     = 0x8eeb18c4u;
const uint _N     = 0x8e6b38c4u;
const uint _O     = 0x746318b8u;
const uint _P     = 0xf47d0840u;
const uint _Q     = 0x74631934u;
const uint _R     = 0xf47d18c4u;
const uint _S     = 0x7c1c18b8u;
const uint _T     = 0xf9084210u;
const uint _U     = 0x8c6318b8u;
const uint _V     = 0x8c62a510u;
const uint _W     = 0x8c635dc4u;
const uint _X     = 0x8a88a8c4u;
const uint _Y     = 0x8a884210u;
const uint _Z     = 0xf844447cu;
const uint _a     = 0x0382f8bcu;
const uint _b     = 0x85b318f8u;
const uint _c     = 0x03a308b8u;
const uint _d     = 0x0b6718bcu;
const uint _e     = 0x03a3f83cu;
const uint _f     = 0x323c8420u;
const uint _g     = 0x03e2f0f8u;
const uint _h     = 0x842d98c4u;
const uint _i     = 0x40308418u;
const uint _j     = 0x080218b8u;
const uint _k     = 0x4254c524u;
const uint _l     = 0x6108420cu;
const uint _m     = 0x06ab5ac4u;
const uint _n     = 0x07a318c4u;
const uint _o     = 0x03a318b8u;
const uint _p     = 0x05b31f40u;
const uint _q     = 0x03671784u;
const uint _r     = 0x05b30840u;
const uint _s     = 0x03e0e0f8u;
const uint _t     = 0x211c420cu;
const uint _u     = 0x046318bcu;
const uint _v     = 0x04631510u;
const uint _w     = 0x04635abcu;
const uint _x     = 0x04544544u;
const uint _y     = 0x0462f0f8u;
const uint _z     = 0x07c4447cu;
const uint _0     = 0x746b58b8u;
const uint _1     = 0x23084238u;
const uint _2     = 0x744c88fcu;
const uint _3     = 0x744c18b8u;
const uint _4     = 0x19531f84u;
const uint _5     = 0xfc3c18b8u;
const uint _6     = 0x3221e8b8u;
const uint _7     = 0xfc422210u;
const uint _8     = 0x745d18b8u;
const uint _9     = 0x745e1130u;
const uint _space = 0x0000000u;
const uint _dot   = 0x000010u;
const uint _minus = 0x0000e000u;
const uint _comma = 0x00000220u;
const uint _colon = 0x02000020u;

const int charWidth   = 5;
const int charHeight  = 6;
const int charSpacing = 1;
const int lineSpacing = 1;

const ivec2 charSize  = ivec2(charWidth, charHeight);
const ivec2 spaceSize = charSize + ivec2(charSpacing, lineSpacing);

// Text renderer

struct Text {
    vec4 result;     // Output color from the text renderer
    vec4 fgCol;      // Text foreground color
    vec4 bgCol;      // Text background color
    ivec2 fragPos;   // The position of the fragment (can be scaled to adjust the size of the text)
    ivec2 textPos;   // The position of the top-left corner of the text
    ivec2 charPos;   // The position of the next character in the text
    int base;        // Number base
    int fpPrecision; // Number of decimal places to print
} text;

// Fills the global text object with default values
void beginText(ivec2 fragPos, ivec2 textPos) {
    text.result      = vec4(0.0);
    text.fgCol       = vec4(1.0);
    text.bgCol       = vec4(0.0, 0.0, 0.0, 0.6);
    text.fragPos     = fragPos;
    text.textPos     = textPos;
    text.charPos     = ivec2(0);
    text.base        = 10;
    text.fpPrecision = 2;
}

// Applies the rendered text to the fragment
void endText(inout vec3 fragColor) {
    fragColor = mix(fragColor.rgb, text.result.rgb, text.result.a);
}

void printChar(uint character) {
    ivec2 pos = text.fragPos - text.textPos - spaceSize * text.charPos * ivec2(1, -1) + ivec2(0, spaceSize.y);

    uint index = uint(charWidth - pos.x + pos.y * charWidth + 1);

    // Draw background
    if (clamp(pos, ivec2(0), spaceSize - 1) == pos)
    text.result = mix(text.result, text.bgCol, text.bgCol.a);

    // Draw character
    if (clamp(pos, ivec2(0), charSize - 1) == pos)
    text.result = mix(text.result, text.fgCol, text.fgCol.a * float(character >> index & 1u));

    // Advance to next character
    text.charPos.x++;
}

#define printString(string) {                                               \
uint[] characters = uint[] string;                                     \
for (int i = 0; i < characters.length(); ++i) printChar(characters[i]); \
}



// https://www.shadertoy.com/view/4tXyWN
uint hash(uvec2 x) {
uvec2 q = 1103515245U * ((x >> 1U) ^ x.yx);
uint n = 1103515245U * (q.x ^ (q.y >> 3U));
return n;
}

// https://github.com/riccardoscalco/glsl-pcg-prng
uint pcg(inout uint state) {
uint newState = state * uint(747796405) + uint(2891336453);
uint word = ((newState >> ((newState >> uint(28)) + uint(4))) ^ newState) * uint(277803737);
state = (word >> uint(22)) ^ word;
return state;
}

float rand(inout uint state) {
return float(pcg(state)) / float(uint(0xffffffff));
}

void drawStars(ivec2 cellIndex, vec2 cellUV, inout vec3 color) {
uint state = hash(uvec2(cellIndex));
if (rand(state) > STAR_PERCENTAGE) {
// Not a star
return;
}

cellUV = (cellUV - 0.5) * 1.5 + 0.5;
if (clamp(cellUV, 0.0, 1.0) != cellUV)
return;

float direction = rand(state) < 0.5 ? -1.0 : 1.0;
float offset = rand(state) * float(STAR_STATES);
int starState = (int(floor(offset + frameTimeCounter * STAR_SHINE_SPEED * direction)) % STAR_STATES + STAR_STATES) % STAR_STATES;

ivec2 pixel = abs(ivec2(cellUV * 7.0) - ivec2(3));
int pixelIndex = pixel.y * 4 + pixel.x;
int on = (STARS[starState] >> pixelIndex) & 1;
if (on == 0)
return;

color = vec3(0.4, 0.6, 0.9);
}

void drawRainbow(vec2 uv, inout vec3 color) {
if (uv.x > 0.5)
return;

uv.y -= viewHeight / viewWidth / 2.0; // Center
uv = floor(uv / PIXEL_SIZE);
float timeOffset = floor(frameTimeCounter * RAINBOW_WAVE_SPEED * 2.0);
uv.y += floor(mod(timeOffset + uv.x / WAVE_PIXEL_LENGTH, 2.0)) + 9.0; // Wave
if (clamp(uv.y, 0.0, 18.0) != uv.y)
return;

int colorIndex = int(floor(uv.y / 3.0));

color = RAINBOW[colorIndex];
}

void drawLogo(vec2 uv, inout vec3 color) {
vec2 aspect = vec2(viewWidth, viewHeight) / viewWidth;
uv = (uv - aspect / 2.0) / LOGO_SIZE + 0.5;
uv.x -= 0.3;
if (clamp(uv, 0.0, 1.0) != uv)
return;

uv = floor(uv / PIXEL_SIZE / 3.0) * PIXEL_SIZE * 3.0;

uv -= 0.5;
float len = length(uv);
float angle = atan(uv.y, uv.x) - PI + frameTimeCounter;
float leafIndex = angle / 2.0 / PI * 16.0;
float func = abs(fract(leafIndex) - 0.5);

float outerRadius = (1.0 - pow(func, 0.8)) * 0.15 + 0.35;
if (len > outerRadius)
return;

float innerRadius = pow(func, 1.2) * 0.08 + 0.18;
if (len < innerRadius)
return;

int colorIndex = int(floor(fract(angle / 2.0 / PI - pow((len - 0.35) / 0.5, 2.0) * 0.3) * 16.0));

color = LOGO_COLORS[colorIndex];
if (len > outerRadius - 0.05)
color *= 0.8;
}

void main() {
vec2 uv = gl_FragCoord.xy / viewWidth;

vec2 starUV = (uv + frameTimeCounter * SPACE_SPEED) / STAR_CELL_SIZE;
ivec2 cellIndex = ivec2(floor(starUV));
vec2 cellUV = fract(starUV);

vec3 color = SPACE_COLOR;
float pixelSize = viewWidth / 200.0;
vec2 coord = gl_FragCoord.xy / pixelSize;
drawStars(cellIndex, cellUV, color);
drawRainbow(uv, color);
drawLogo(uv, color);

#if MC_VERSION < 11802
    beginText(ivec2(coord), ivec2(viewWidth / pixelSize / 2.0 - 13.0 * 7.0, 24.0));
text.bgCol = vec4(0.0);
text.fgCol = vec4(LOGO_COLORS[int(coord.x / 6.0 + frameTimeCounter * 4.0) % 16], 1.0);
printString((_U, _p, _g, _r, _a, _d, _e, _space, _M, _i, _n, _e, _c, _r, _a, _f, _t));
endText(color);

// trick: use if defined instead of ifdef to not make it a shader option
#elif defined OLD
            beginText(ivec2(coord), ivec2(viewWidth / pixelSize / 2.0 - 13.0 * 7.0, 24.0));
text.bgCol = vec4(0.0);
text.fgCol = vec4(LOGO_COLORS[int(coord.x / 6.0 + frameTimeCounter * 4.0) % 16], 1.0);
printString((_U, _p, _g, _r, _a, _d, _e, _space, _I, _r, _i, _s, _space, _t, _o, _space, _u, _s, _e, _space, _t, _h, _i, _s, _space, _s, _h, _a, _d, _e, _r));
endText(color);
#else
        beginText(ivec2(coord), ivec2(viewWidth / pixelSize / 2.0 - 13.0 * 6.0, 110.0));
text.bgCol = vec4(0.0);
text.fgCol = vec4(LOGO_COLORS[int(coord.x / 6.0 + frameTimeCounter * 4.0) % 16], 1.0);
printString((_T, _h, _i, _s, _space, _s, _h, _a, _d, _e, _r, _space, _r, _e, _q, _u, _i, _r, _e, _s, _space, _I, _r, _i, _s, _colon))
endText(color);
beginText(ivec2(coord), ivec2(viewWidth / pixelSize / 2.0 - 7.5 * 6.0, 20.0));
text.bgCol = vec4(0.0);
text.fgCol = vec4(LOGO_COLORS[int(coord.x / 6.0 + frameTimeCounter * 4.0) % 16], 1.0);
printString((_i, _r, _i, _s, _s, _h, _a, _d, _e, _r, _s, _dot, _n, _e, _t));
endText(color);

#endif

    gl_FragData[0] = vec4(color, 1.0);
}
