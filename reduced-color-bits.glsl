vec3 Color( vec2 uv )
{
    float speed = .2;
    vec3 col = 0.5 + 0.5*cos(iTime*speed + uv.xyx + vec3(0,2,4));
    return col;
}

// x <0,1>
float ReduceValue( float x, float bits )
{
    float pieceCount = pow( 2., bits );
    float pieceHeight = 1. / pieceCount;
    return x - mod( x, pieceHeight ); // `floor` rounding to nearest lower piece value 
}

vec3 Reduce( vec3 color, float rBits, float gBits, float bBits )
{
    color.r = ReduceValue( color.r, rBits );
    color.g = ReduceValue( color.g, gBits );
    color.b = ReduceValue( color.b, bBits );
    
    return color;
}

// 0 1
// 2 3
bool InRect( vec2 uv, int id )
{
    if( id == 0 ) return uv.y <  .5 && uv.x <  .5;
    if( id == 1 ) return uv.y <  .5 && uv.x >= .5;
    if( id == 2 ) return uv.y >= .5 && uv.x <  .5;
    if( id == 3 ) return uv.y >= .5 && uv.x >= .5;

    return false; // should not happen
}
vec2 ToRect( vec2 uv, int id )
{
    if( id == 0 ) return vec2(   uv.x        * .5,   uv.y        * .5 );
    if( id == 1 ) return vec2( ( uv.x - .5 ) * .5,   uv.y        * .5 );
    if( id == 2 ) return vec2(   uv.x        * .5, ( uv.y - .5 ) * .5 );
    if( id == 3 ) return vec2( ( uv.x - .5 ) * .5, ( uv.y - .5 ) * .5 );

    return uv; // shouldn't happen
}

vec3 ColorWindows( vec2 uv, vec3 col, vec3 color0, vec3 color1, vec3 color2, vec3 color3 )
{
    if(InRect( uv, 0 ))
    {
        uv = ToRect( uv, 0 );
        col = Reduce( col, color0.r, color0.g, color0.b );
    }    
    else if(InRect( uv, 1 ))
    {
        uv = ToRect( uv, 1 );
        col = Reduce( col, color1.r, color1.g, color1.b );
    }
    else if(InRect( uv, 2 ))
    {
        uv = ToRect( uv, 2 );
        col = Reduce( col, color2.r, color2.g, color2.b );
    }    
    else // 3
    {
        uv = ToRect( uv, 3 );
        col = Reduce( col, color3.r, color3.g, color3.b );
    }
    
    return col;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;    
    uv.y = 1. - uv.y; // let's make y to start from the top
    

    //
    // Define how many bits should each R G B have for each of 4 windows
    //

    vec3 bits1, bits2, bits3, bits4;

    bits1 = vec3( 8., 8., 8. ); // R G B = 8, 8, 8

    //bits2 = vec3( 7., 7., 7. ); // this has banding!
    bits2 = vec3( 5., 6., 5. ); // R G B = 5 6 5

    bits3 = vec3( 5., 7., 4. );

    //
    // RGB bits based on luminance
    //
    // https://en.wikipedia.org/wiki/Grayscale
    {
        float     BITS = 16.;
        vec3 LUMINANCE = vec3( .2126, .7152, .0722 );

        bits4 = BITS * LUMINANCE;
    }
    //bits4 = vec3( 2., 4., 2. );
    //bits4 = vec3( .5, .6, .5 ); // 1.6bit :D not bad tbh
    //bits4 = vec3( .05, .06, .05 );   // .16bit :D has black bars


    //
    // Draw RGB converted to each of four RGB bit depths
    //

    vec3 color = Color( uv );
    vec3 finalColor = ColorWindows( uv, color, bits1, bits2, bits3, bits4 );
    fragColor = vec4( finalColor, 1.0 );
}
