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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;    
    uv.y = 1. - uv.y; // let's make y to start from the top
    
    vec3 col = Color( uv );

    if(InRect( uv, 0 ))
    {
        uv = ToRect( uv, 0 );
        
        // no change to color
        col = Reduce( col, 8., 8., 8. );
    }    
    else if(InRect( uv, 1 ))
    {
        uv = ToRect( uv, 1 );

        //col = Reduce( col, 7., 7., 7. ); // this has banding!
        col = Reduce( col, 5., 6., 5. ); // 16bit
    }
    else if(InRect( uv, 2 ))
    {
        uv = ToRect( uv, 2 );
    
        col = Reduce( col, 5., 7., 4. );
    }
    else // 3
    {
        uv = ToRect( uv, 3 );

        // col = Reduce( col, 2., 4., 2. );
        col = Reduce( col, .5, .6, .5 );   // 1.6bit :D not bad tbh
        // col = Reduce( col, .05, .06, .05 );   // .16bit :D has black bars
    }
    
    fragColor = vec4(col,1.0);
}