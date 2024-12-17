shader_type canvas_item;

uniform vec4 color : source_color = vec4(0.3, 0.3, 0.3, 0.75);
uniform float influence: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float offset: hint_range(0.0, 360.0, 1.0);

const float TWO_PI = 6.28318530718;

// --- Functions --- //
mat2 rot2d(float angle) {
    vec2 part1 = vec2(cos(angle), -sin(angle));
    vec2 part2 = vec2(sin(angle), cos(angle));
    return mat2(part1, part2);
}

float r(float a, float b) {
    return fract(sin(dot(vec2(a, b), vec2(12.9898, 78.233))) * 43758.5453);
}

float h(float a) {
    return fract(sin(dot(vec2(a, a), vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 57.0 + 113.0 * p.z;
    return mix(mix(mix(h(n + 0.0), h(n + 1.0), f.x),
                   mix(h(n + 57.0), h(n + 58.0), f.x), f.y),
               mix(mix(h(n + 113.0), h(n + 114.0), f.x),
                   mix(h(n + 170.0), h(n + 171.0), f.x), f.y), f.z);
}

vec3 dnoise2f(vec2 p) {
    float i = floor(p.x), j = floor(p.y);
    float u = p.x - i, v = p.y - j;
    float du = 30.0 * u * u * (u * (u - 2.0) + 1.0);
    float dv = 30.0 * v * v * (v * (v - 2.0) + 1.0);
    u = u * u * u * (u * (u * 6.0 - 15.0) + 10.0);
    v = v * v * v * (v * (v * 6.0 - 15.0) + 10.0);
    float a = r(i, j);
    float b = r(i + 1.0, j);
    float c = r(i, j + 1.0);
    float d = r(i + 1.0, j + 1.0);
    float k0 = a;
    float k1 = b - a;
    float k2 = c - a;
    float k3 = a - b - c + d;
    return vec3(k0 + k1 * u + k2 * v + k3 * u * v,
                du * (k1 + k3 * v),
                dv * (k2 + k3 * u));
}

float fbm(vec2 uv) {
    vec2 p = uv;
    float f = 0.0, dx = 0.0, dz = 0.0, w = 0.5;
    for (int i = 0; i < 28; ++i) {
        vec3 n = dnoise2f(uv);
        dx += n.y;
        dz += n.z;
        f += w * n.x / (1.0 + dx * dx + dz * dz);
        w *= 0.86;
        uv *= vec2(1.16);
        // uv *= rot2d(1.25 * noise(vec3(p * 0.1, 0.12 * TIME)) +
        //             0.75 * noise(vec3(p * 0.1, 0.20 * TIME)));
    }
    return f;
}

float fbmLow(vec2 uv) {
    float f = 0.0, dx = 0.0, dz = 0.0, w = 0.5;
    for (int i = 0; i < 4; ++i) {
        vec3 n = dnoise2f(uv);
        dx += n.y;
        dz += n.z;
        f += w * n.x / (1.0 + dx * dx + dz * dz);
        w *= 0.75;
        uv *= vec2(1.5);
    }
    return f;
}

vec3 hsv2rgb(vec3 _c) {
    vec4 _K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 _p = abs(fract(_c.xxx + _K.xyz) * 6.0 - _K.www);
    return _c.z * mix(_K.xxx, clamp(_p - _K.xxx, 0.0, 1.0), _c.y);
}

void fragment() {
    vec2 uv = 1.0 - 2.0 * (UV.xy / (1.0 / TEXTURE_PIXEL_SIZE).xy);
    uv.y /= (1.0 / TEXTURE_PIXEL_SIZE).x / (1.0 / TEXTURE_PIXEL_SIZE).y;
    float t = TIME * 0.6;

    // vec2 rv = uv / (length(uv * 2.5) * (uv * 30.0));
    // uv *= rot2d(0.3 * t);
    // float val = 0.5 * fbm(uv * 2.0 * fbmLow(length(uv) + rv - t));
    // uv *= rot2d(-0.6 * t);

    COLOR = color;
    COLOR *= 1.6 * vec4(vec3(0.5 * fbm(uv * 8.0) + 0.02 * r(uv.x, uv.y)), 1.0);
    COLOR.rgb *= 3.8;
    COLOR.rgb = COLOR.rgb / (1.0 + COLOR.rgb);
    COLOR.rgb = smoothstep(0.18, 0.88, COLOR.rgb);

    vec2 pos = vec2(0.5) - UV;
    COLOR.rgb *= influence * hsv2rgb(vec3(((atan(pos.y, pos.x) + radians(offset)) / TWO_PI) + 0.5, length(pos) * 2.0, 1.0)) + vec3(1.0, 1.0, 1.0);
    COLOR.a = length(COLOR.rgb);
}