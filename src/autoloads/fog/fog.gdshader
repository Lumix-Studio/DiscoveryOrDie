shader_type canvas_item;

// ESTE SHADER É TEMPORÁRIO
// Este shader foi feito com I.A generqatíva, logo, será mudado 

uniform vec4 smoke_color : source_color = vec4(0.8,0.8,0.8,1.0);

uniform float speed = 0.05;
uniform float scale = 4.0;
uniform float density = 0.5;

float random(vec2 st){
    return fract(sin(dot(st.xy,
    vec2(12.9898,78.233)))*43758.5453123);
}

float noise(vec2 st){

    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0,0.0));
    float c = random(i + vec2(0.0,1.0));
    float d = random(i + vec2(1.0,1.0));

    vec2 u = f*f*(3.0-2.0*f);

    return mix(a,b,u.x) +
        (c-a)*u.y*(1.0-u.x) +
        (d-b)*u.x*u.y;
}

void fragment(){

    vec2 uv = UV;

    uv.y -= TIME * speed;

    float n = noise(uv * scale);

    n += noise(uv * scale * 2.0) * 0.5;
    n += noise(uv * scale * 4.0) * 0.25;

    n /= 1.75;

    float alpha = smoothstep(density,1.0,n);

    COLOR = vec4(smoke_color.rgb,
                 alpha * smoke_color.a);
}