import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:posture_detector_app/common/widgets/custom_toast.dart';
import 'package:posture_detector_app/utils/l10n.dart';

/// Cached instance to avoid re-creating on every check.
final Connectivity _connectivity = Connectivity();

Future<bool> has_internet({bool show_error = false}) async {
  try {
    final List<ConnectivityResult> connectivityResult = await _connectivity
        .checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (show_error) {
        showCustomToast(text: l10n.genCheckInternetConnection);
      }
      return false;
    }
    return true;
  } catch (e) {
    // If the connectivity check itself fails, assume no internet.
    if (show_error) {
      showCustomToast(text: l10n.genNetworkStatusUnavailable);
    }
    return false;
  }
}
