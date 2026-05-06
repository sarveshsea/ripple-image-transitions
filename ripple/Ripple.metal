// Ripple shader for the sample transition effect.

#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]]
half4 Ripple(
    float2 position,
    SwiftUI::Layer layer,
    float2 origin,
    float time,
    float amplitude,
    float frequency,
    float decay,
    float speed
) {
    float2 delta = position - origin;
    float distance = length(delta);
    float safeSpeed = max(fabs(speed), 0.0001);
    float delay = distance / safeSpeed;

    time -= delay;
    time = max(0.0, time);

    float rippleAmount = amplitude * sin(frequency * time) * exp(-decay * time);
    float2 direction = distance > 0.0001 ? (delta / distance) : float2(0.0);
    float2 newPosition = position + rippleAmount * direction;

    half4 color = layer.sample(newPosition);
    float safeAmplitude = max(fabs(amplitude), 0.0001);
    color.rgb += 0.3 * (rippleAmount / safeAmplitude) * color.a;

    return color;
}
