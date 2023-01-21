if (cuboid && bounds[0] == ivec3(0) && bounds[1] == ivec3(1)) {
    if ((mat % 10000) / 2000 == 0) {
        switch (mat % 4) {
            case 1:
                bounds[1].y = int(16*fract(pos.y + 0.03125));
                break;
            case 2:
                bounds[0].y = 8;
                break;
            case 3:
                switch (mat) {
                    case 10035:
                    case 10087:
                    case 10091:
                    case 10095:
                    case 10107:
                    case 10111:
                    case 10115:
                    case 10155:
                    case 10243:
                    case 10247:
                    case 10419:
                    case 10423:
                    case 10431:
                    case 10443:
                    case 10483:
                        connectSides = true;
                        bounds[0].xz = ivec2(4);
                        bounds[1].xz = ivec2(12);
                        break;
                    case 10159:
                    case 10167:
                    case 10175:
                    case 10183:
                    case 10191:
                    case 10199:
                    case 10207:
                    case 10215:
                    case 10223:
                        connectSides = true;
                        bounds[0].xz = ivec2(6);
                        bounds[1].xz = ivec2(10);
                        break;
                    default:
                        bounds[0].xz = ivec2(6);
                        bounds[1].xz = ivec2(10);
                        break;
                }
                break;
        }
    } else if ((mat % 10000) / 2000 == 1) {
        if (mat % 4 == 1) bounds[0].y = 13;
    } else if ((mat % 10000) / 2000 == 2) {
        switch(mat % 4) {
            case 0:
                bounds[0].z = 13;
                break;
            case 1:
                bounds[1].z = 3;
                break;
            case 2:
                bounds[1].x = 3;
                break;
            case 3:
                bounds[0].x = 13;
                break;
        }
    }
}