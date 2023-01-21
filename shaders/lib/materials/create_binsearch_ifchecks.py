import numpy as np
import sys
import os
wd = os.getcwd()
with open("shadowchecks_fsh.glsl") as file:
    data = file.readlines()
rootpath = "/".join(wd.split("/")[:-2])
with open(rootpath + "/block.properties") as bpfile:
    blockprops0 = bpfile.readlines()
with open(rootpath + "/entity.properties") as epfile:
    entityprops0 = epfile.readlines()
nums = []
bools = {}
boolnames = []
inbool = ""
switches = {}
inswitches = []
inmatswitch = []
compilerifs = []
cbd = 0
rbd = 0
variables = []
declaredvariables = []
globallines = []
includes = []
for i, a in enumerate(data):
    #print(rbd, inbool)
    unknown = True
    ocbd = cbd
    orbd = rbd
    for c in a:
        if c == "{": cbd += 1
        if c == "}": cbd -= 1
        if c == "(": rbd += 1
        if c == ")": rbd -= 1
    a = a.strip().split(" ")
    if a == [] or a[0][:2] == "//" or len(a) == 1 and a[0] == "": continue
    if len(a) >= 2 and a[1] == "=":
        variables.append(a[0].split(".")[0].split("[")[0])
    if (a[0].split("[")[0] in ["int, float, bool, ivec2, ivec3, ivec4, vec2, vec3, vec4"]):
        print(a, file=sys.stderr)
        declaredvariables.append(a[1].strip(";"))
    if a[0] == "#include":
        includes.append(" ".join(a))
        unknown = False
    if len(a[-1]) > 0 and a[-1][-1] == ";" and cbd == 0 and rbd == 0 and ocbd == 0 and orbd == 0:
        globallines.append(" ".join(a))
        unknown = False
    if a[0] == "switch" and a[1] == "(mat)":
        inmatswitch.append(cbd)
        unknown = False
    if len(inmatswitch) > 0:
        unknown = False
        if cbd >= inmatswitch[-1]:
            if cbd == inmatswitch[-1] and a[0] == "break;":
                inswitches = []
            if a[0] == "case":
                num = int(a[1].split(":")[0])
                inswitches.append(num)
                nums.append(num)
            else:
                for num in inswitches:
                    try:
                        switches[num].append(" ".join(a))
                    except KeyError:
                        switches[num] = [" ".join(a)]
        if cbd < inmatswitch[-1]: inmatswitch.pop(-1)
    if len(a) == 3 and a[1] == "=" and a[2] == "(":
        inbool = a[0]
        boolnames.append(a[0])
        unknown = False
    if inbool != "":
        if (a[0] == "#ifdef"):
            compilerifs.append("defined " + a[1])
            unknown = False
        if (a[0] == "#ifndef"):
            compilerifs.append("!defined " + a[1])
            unknown = False
        if (a[0] == "#if"):
            compilerifs += " ".join(a[1:]).split(" && ")
            unknown = False
        if (a[0] == "#endif"):
            compilerifs.pop(-1)
            unknown = False
        if rbd == 0:
            inbool = ""
            unknown = False
        else:
            if a[0] == "mat":
                num = int(a[2])
                try:
                    bools[num].append((inbool, compilerifs.copy()))
                except KeyError:
                    bools[num] = [(inbool, compilerifs.copy())]
                nums.append(num)
                unknown = False
            if a[0] == "(mat":
                if a[1] == ">=": num0 = int(a[2])
                elif a[1] == ">": num0 = int(a[2]) + 1
                else:
                    print(f"Unknown line ({i}): \"" + " ".join(a) + "\"", file=sys.stderr)
                    continue
                if a[5] == "<=": num1 = int(a[6][:-1]) + 1
                elif a[5] == "<": num1 = int(a[6][:-1])
                else:
                    print(f"Unknown line ({i}): \"" + " ".join(a) + "\"", file=sys.stderr)
                    continue
                for num in range(num0, num1):
                    try:
                        bools[num].append((inbool, compilerifs.copy()))
                    except KeyError:
                        bools[num] = [(inbool, compilerifs.copy())]
                    nums.append(num)
                    unknown = False
    if unknown:
        print(f"Unknown line ({i}): \"" + " ".join(a) + "\"", file=sys.stderr)
for b in set(boolnames):
    globallines = [b + " = false;"] + globallines
nums = sorted(set(nums))
while nums[0] < 1000: nums.pop(0)
variables = set(variables)
variables -= set(declaredvariables)
print("// needs " + ", ".join(sorted(variables)))
print("\n".join(includes))
print("\n".join(globallines))
blockprops = {}
for b in blockprops0 + entityprops0:
    b = b.split("=")
    #print(b, file=sys.stderr)
    if b[0][0] in "be":
        blockprops[int(b[0].split(".")[1])] = "=".join(b[1:])
#print(blockprops, file=sys.stderr)
def printrecursiveifstatements(nums, depth=0):
    l = len(nums)
    string = ""
    if l > 1:
        for k in range(depth): string += "\t"
        string += f"if (mat < {nums[l//2]}) " + "{\n"
        string += printrecursiveifstatements(nums[:l//2], depth + 1)
        for k in range(depth): string += "\t"
        string += "} else {\n"
        string += printrecursiveifstatements(nums[l//2:], depth + 1)
        for k in range(depth): string += "\t"
        string += "}\n"
    elif l == 1:
        try:
            for k in range(depth): string += "\t"
            string += f"// {nums[0]}: {blockprops[nums[0]]}"
            if (blockprops[nums[0]][-1] != "\n"): string += "\n"
        except:
            string += f"// {nums[0]}: This case is probably superfluous (not in block.properties)\n"
        try:
            for b in bools[nums[0]]:
                for k in range(depth): string += "\t"
                if len(b[1]) > 0:
                    string += "#if (" + ") && (".join(b[1]) + ")\n"
                    for k in range(depth + 1): string += "\t"
                string += b[0] + " = true;\n"
                if len(b[1]) > 0:
                    for k in range(depth): string += "\t"
                    string += "#endif\n"
        except KeyError:
            True
        try:
            for line in switches[nums[0]]:
                for k in range(depth): string += "\t"
                string += line + "\n"
        except KeyError:
            True
        
    return string
print("if (mat >= 1000) {\n" + printrecursiveifstatements(nums, 1) + "}\n\n// Manual Additions")
with open("shadowchecks_fsh_manual.glsl") as manualfile:
    mdata = manualfile.read()
print(mdata)