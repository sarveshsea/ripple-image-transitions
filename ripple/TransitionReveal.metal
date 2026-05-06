#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]]
half4 TransitionReveal(
    float2 position,
    half4 color,
    float2 origin,
    float time,
    float duration,
    float maxRadius,
    float feather
) {
    float safeDuration = max(duration, 0.0001);
    float progress = clamp(time / safeDuration, 0.0, 1.0);
    float radius = progress * maxRadius;
    float d = distance(position, origin);
    float alpha = smoothstep(radius + feather, radius - feather, d);
    half reveal = half(alpha);

    return half4(color.rgb * reveal, color.a * reveal);
}
