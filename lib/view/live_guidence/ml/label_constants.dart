// COCO class IDs used by EfficientDet-Lite0.
// These must match the label map embedded in the .tflite model metadata.
// Run [ModelHandler.loadModel] and inspect printed output tensor shapes
// and detection labels to verify these values on first integration.

/// COCO class index for "person" (0-indexed, background class excluded).
const int cocoPersonClassId = 0;

/// COCO class index for "tv" (monitors, screens).
/// YOLOv8n uses standard 0-indexed COCO IDs (no offset).
const int cocoTvClassId = 62;

/// COCO class index for "laptop".
/// YOLOv8n often classifies desktop monitors as "laptop", so we accept both.
const int cocoLaptopClassId = 63;

/// All class IDs that count as a "screen/monitor" detection.
const Set<int> monitorClassIds = {cocoTvClassId, cocoLaptopClassId};

/// Confidence threshold for person detections.
const double confidenceThreshold = 0.40;

/// Lower threshold for monitor/tv/laptop — YOLOv8n scores these lower.
const double monitorConfidenceThreshold = 0.25;
