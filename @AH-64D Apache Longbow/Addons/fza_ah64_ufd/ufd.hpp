color[] = {0.74, 0.85, 0, 1};
helmetMountedDisplay = 0;
borderBottom=0;
borderLeft=0;
borderRight=0;
borderTop=0;
font="fza_ticketing";
helmetDown[] = {0,-0.075,0};
helmetPosition[] = {-0.0375,0.0375,0.1};
helmetRight[] = {0.075,0,0};
class material
{
    ambient[]   = { 1, 1, 1, 1 };
    diffuse[]   = { 1, 1, 1, 1 };
    emissive[]  = { 30, 30, 30, 1 };
};
class Bones {};
// HUD-Elements definitions
class Draw
{
    class UFDElements {
        condition = user0;
        #define UFD_CHAR_WIDTH_VEC 0.064
        #define UFD_CHAR_WIDTH (1/35)
        #define UFD_CHAR_HEIGHT 0.1
        class Line0
        {
            type = "text";
            source = "userText";
            sourceIndex = 0;
            scale=1;
            align="right";
            sourceScale = 1;
            pos[] = {{0, 0}, 1};
            right[] = {{UFD_CHAR_WIDTH_VEC, 0}, 1};
            down[] = {{0, 1/10}, 1};
        };
        #define UFD_LINE(N) \
        class Line##N : Line0 \
        { \
            sourceIndex = N; \
            pos[] = {{0, N*UFD_CHAR_HEIGHT}, 1}; \
            right[] = {{UFD_CHAR_WIDTH_VEC, N*UFD_CHAR_HEIGHT}, 1}; \
            down[] = {{0, __EVAL((N +1)*UFD_CHAR_HEIGHT)}, 1}; \
        };
        UFD_LINE(1)
        UFD_LINE(2)
        UFD_LINE(3)
        UFD_LINE(4)
        UFD_LINE(5)
        UFD_LINE(6)
        UFD_LINE(7)
        UFD_LINE(8)
        class Line9 : Line0
        {
            source = "static";
            text = "        XP 1200 B NORM            L";
            pos[] = {{0, 9*UFD_CHAR_HEIGHT}, 1};
            right[] = {{UFD_CHAR_WIDTH_VEC, 9*UFD_CHAR_HEIGHT}, 1};
            down[] = {{0, __EVAL(10*UFD_CHAR_HEIGHT)}, 1};
        };
        class FuelIAFSInstalled {
            condition = "user4";
            class Fuel
            {
                type = "text";
                scale=1;
                align="right";
                source = fuel;
                sourceScale = 3181;
                sourceLength = 4;
                pos[] = {{0, 9*UFD_CHAR_HEIGHT}, 1};
                right[] = {{UFD_CHAR_WIDTH_VEC, 9*UFD_CHAR_HEIGHT}, 1};
                down[] = {{0, __EVAL(10*UFD_CHAR_HEIGHT)}, 1};
            };
        };
        class FuelIAFSNotInstalled : FuelIAFSInstalled {
            condition = "1-user4";
            class Fuel : Fuel
            {
                sourceScale = 2518;
            };
        };
        class Time : Line9
        {
            source = time;
            text = "%H:%M:%S";
            pos[] = {{25*UFD_CHAR_WIDTH, 9*UFD_CHAR_HEIGHT}, 1};
            right[] = {{25*UFD_CHAR_WIDTH + UFD_CHAR_WIDTH_VEC, 9*UFD_CHAR_HEIGHT}, 1};
            down[] = {{25*UFD_CHAR_WIDTH, 10*UFD_CHAR_HEIGHT}, 1};
        };
    };
};