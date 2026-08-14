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
