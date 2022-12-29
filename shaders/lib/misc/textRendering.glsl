/*
--------------------------------------------------------------------------------

  GLSL Debug Text Renderer by SixthSurge

  Character set based on Monocraft by IdreesInc
  https://github.com/IdreesInc/Monocraft

  Usage:

  // Call beginText to initialize the text renderer. You can scale the fragment position to adjust the size of the text
  beginText(ivec2(gl_FragCoord.xy), ivec2(0, viewHeight));
            ^ fragment position     ^ text box position (upper left corner)

  // You can print various data types
  printBool(false);
  printFloat(sqrt(-1.0)); // Prints "NaN"
  printInt(42);
  printVec3(skyColor);

  // ...or arbitrarily long strings
  printString((_H, _e, _l, _l, _o, _comma, _space, _w, _o, _r, _l, _d));

  // To start a new line, use
  newLine();

  // You can also configure the text color on the fly
  text.fgCol = vec4(1.0, 0.0, 0.0, 1.0);
  text.bgCol = vec4(0.0, 0.0, 0.0, 1.0);

  // ...as well as the number base and number of decimal places to print
  text.base = 16;
  text.fpPrecision = 4;

  // Finally, call endText to blend the current fragment color with the text
  endText(fragColor);

  Important: any variables you display must be the same for all fragments, or
  at least all of the fragments that the text covers. Otherwise, different
  fragments will try to print different values, resulting in, well, a mess

--------------------------------------------------------------------------------
*/

#if !defined UTILITY_TEXTRENDERING_INCLUDED
#define UTILITY_TEXTRENDERING_INCLUDED

// Characters

const uint _A     = uint(0x747f18c4);
const uint _B     = uint(0xf47d18f8);
const uint _C     = uint(0x746108b8);
const uint _D     = uint(0xf46318f8);
const uint _E     = uint(0xfc39087c);
const uint _F     = uint(0xfc390840);
const uint _G     = uint(0x7c2718b8);
const uint _H     = uint(0x8c7f18c4);
const uint _I     = uint(0x71084238);
const uint _J     = uint(0x084218b8);
const uint _K     = uint(0x8cb928c4);
const uint _L     = uint(0x8421087c);
const uint _M     = uint(0x8eeb18c4);
const uint _N     = uint(0x8e6b38c4);
const uint _O     = uint(0x746318b8);
const uint _P     = uint(0xf47d0840);
const uint _Q     = uint(0x74631934);
const uint _R     = uint(0xf47d18c4);
const uint _S     = uint(0x7c1c18b8);
const uint _T     = uint(0xf9084210);
const uint _U     = uint(0x8c6318b8);
const uint _V     = uint(0x8c62a510);
const uint _W     = uint(0x8c635dc4);
const uint _X     = uint(0x8a88a8c4);
const uint _Y     = uint(0x8a884210);
const uint _Z     = uint(0xf844447c);
const uint _a     = uint(0x0382f8bc);
const uint _b     = uint(0x85b318f8);
const uint _c     = uint(0x03a308b8);
const uint _d     = uint(0x0b6718bc);
const uint _e     = uint(0x03a3f83c);
const uint _f     = uint(0x323c8420);
const uint _g     = uint(0x03e2f0f8);
const uint _h     = uint(0x842d98c4);
const uint _i     = uint(0x40308418);
const uint _j     = uint(0x080218b8);
const uint _k     = uint(0x4254c524);
const uint _l     = uint(0x6108420c);
const uint _m     = uint(0x06ab5ac4);
const uint _n     = uint(0x07a318c4);
const uint _o     = uint(0x03a318b8);
const uint _p     = uint(0x05b31f40);
const uint _q     = uint(0x03671784);
const uint _r     = uint(0x05b30840);
const uint _s     = uint(0x03e0e0f8);
const uint _t     = uint(0x211c420c);
const uint _u     = uint(0x046318bc);
const uint _v     = uint(0x04631510);
const uint _w     = uint(0x04635abc);
const uint _x     = uint(0x04544544);
const uint _y     = uint(0x0462f0f8);
const uint _z     = uint(0x07c4447c);
const uint _0     = uint(0x746b58b8);
const uint _1     = uint(0x23084238);
const uint _2     = uint(0x744c88fc);
const uint _3     = uint(0x744c18b8);
const uint _4     = uint(0x19531f84);
const uint _5     = uint(0xfc3c18b8);
const uint _6     = uint(0x3221e8b8);
const uint _7     = uint(0xfc422210);
const uint _8     = uint(0x745d18b8);
const uint _9     = uint(0x745e1130);
const uint _space = uint(0x0000000);
const uint _dot   = uint(0x000010);
const uint _minus = uint(0x0000e000);
const uint _comma = uint(0x00000220);
const uint _colon = uint(0x02000020);

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

	uint index = uint(charWidth - pos.x + pos.y * charWidth) + 1u;

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

void printUnsignedInt(uint value, int len) {
	const uint[36] digits = uint[](
		_0, _1, _2, _3, _4, _5, _6, _7, _8, _9,
		_a, _b, _c, _d, _e, _f, _g, _h, _i, _j,
		_k, _l, _m, _n, _o, _p, _q, _r, _s, _t,
		_u, _v, _w, _x, _y, _z
	);

	// Advance to end of the number
	text.charPos.x += len - 1;

	// Write number backwards
	for (int i = 0; i < len; ++i) {
		printChar(digits[value % uint(text.base)]);
		value /= uint(text.base);
		text.charPos.x -= 2;
	}

	// Return to end of the number
	text.charPos.x += len + 1;
}

void printUnsignedInt(uint value) {
	float logValue = log(float(value));
	float logBase  = log(float(text.base));

	int len = int(ceil(logValue / logBase));
	    len = max(len, 1);

	printUnsignedInt(value, len);
}

void printInt(int value) {
	if (value < 0) printChar(_minus);
	printUnsignedInt(uint(abs(value)));
}

void printFloat(float value) {
	if (value < 0.0) printChar(_minus);

	if (isnan(value)) {
		printString((_N, _a, _N));
	} else if (isinf(value)) {
		printString((_i, _n, _f));
	} else {
		float i, f = modf(abs(value), i);

		uint integralPart   = uint(i);
		uint fractionalPart = uint(f * pow(float(text.base), float(text.fpPrecision)) + 0.5);

		printUnsignedInt(integralPart);
		printChar(_dot);
		printUnsignedInt(fractionalPart, text.fpPrecision);
	}
}

void printBool(bool value) {
	if (value) {
		printString((_t, _r, _u, _e));
	} else {
		printString((_f, _a, _l, _s, _e));
	}
}

void printVec2(vec2 value) {
	printFloat(value.x);
	printString((_comma, _space));
	printFloat(value.y);
}
void printVec3(vec3 value) {
	printFloat(value.x);
	printString((_comma, _space));
	printFloat(value.y);
	printString((_comma, _space));
	printFloat(value.z);
}
void printVec4(vec4 value) {
	printFloat(value.x);
	printString((_comma, _space));
	printFloat(value.y);
	printString((_comma, _space));
	printFloat(value.z);
	printString((_comma, _space));
	printFloat(value.w);
}

void printIvec2(ivec2 value) {
	printInt(value.x);
	printString((_comma, _space));
	printInt(value.y);
}
void printIvec3(ivec3 value) {
	printInt(value.x);
	printString((_comma, _space));
	printInt(value.y);
	printString((_comma, _space));
	printInt(value.z);
}
void printIvec4(ivec4 value) {
	printInt(value.x);
	printString((_comma, _space));
	printInt(value.y);
	printString((_comma, _space));
	printInt(value.z);
	printString((_comma, _space));
	printInt(value.w);
}

void printUvec2(uvec2 value) {
	printUnsignedInt(value.x);
	printString((_comma, _space));
	printUnsignedInt(value.y);
}
void printUvec3(uvec3 value) {
	printUnsignedInt(value.x);
	printString((_comma, _space));
	printUnsignedInt(value.y);
	printString((_comma, _space));
	printUnsignedInt(value.z);
}
void printUvec4(uvec4 value) {
	printUnsignedInt(value.x);
	printString((_comma, _space));
	printUnsignedInt(value.y);
	printString((_comma, _space));
	printUnsignedInt(value.z);
	printString((_comma, _space));
	printUnsignedInt(value.w);
}

void printLine() {
	text.charPos.x = 0;
	++text.charPos.y;
}

#endif // UTILITY_TEXTRENDERING_INCLUDED
