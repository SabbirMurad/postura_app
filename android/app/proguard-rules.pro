# ── TensorFlow Lite + GPU delegate ──────────────────────────────────────────
# The TFLite runtime references the optional GPU delegate reflectively, so R8
# both warns about the classes it can't see and (worse) would strip the ones it
# can. Keep the whole tflite surface and silence the GPU-delegate warnings.
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options$GpuBackend
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options

# ── MediaPipe tasks-vision (PostureEngine) ──────────────────────────────────
# tasks-vision loads models and calls into native/JNI + reflection; keep it all
# so release minification doesn't remove classes the engine resolves at runtime.
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# ── Flogger (bundled by MediaPipe) ──────────────────────────────────────────
# MediaPipe logs via Google Flogger. On first use, com.google.mediapipe.framework
# .Graph's static initializer asks Flogger for a logger, and Flogger WALKS THE
# CALL STACK to identify the calling class. R8's release optimization inlines /
# removes those frames, so the walk fails with
#   IllegalStateException: no caller found on the stack for: <obfuscated>
# crashing PoseLandmarker.createFromOptions the moment the pose phase starts
# (right after the monitor is detected). Keeping Flogger whole stops R8 from
# inlining the frames it needs. Debug builds skip R8, which is why this is
# release-only.
-keep class com.google.common.flogger.** { *; }
-keep class com.google.common.flogger.backend.** { *; }
-dontwarn com.google.common.flogger.**

# ── Protocol Buffers (protobuf-lite, used by MediaPipe graph config) ─────────
# MediaPipe builds its graph via protobuf-lite, which resolves message fields by
# their exact source names (e.g. `typeUrl_` on com.google.protobuf.Any) through
# reflection at runtime. R8 renames those fields (typeUrl_ -> i), so protobuf
# throws:
#   RuntimeException: Field typeUrl_ for com.google.protobuf.Any not found
# during Graph.loadBinaryGraph, again inside PoseLandmarker.createFromOptions.
# Keep the protobuf runtime classes AND every generated message's fields intact
# so the reflective lookups resolve. Release-only (no R8 in debug).
-keep class com.google.protobuf.** { *; }
-keepclassmembers class com.google.protobuf.** { *; }
-keepclassmembers class * extends com.google.protobuf.GeneratedMessageLite {
    <fields>;
}
-dontwarn com.google.protobuf.**
