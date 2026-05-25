import 'package:url_launcher/url_launcher.dart';

class CallService {
  static Future<bool> callPhone(String phoneNumber) async {
    final cleanedPhone = phoneNumber.trim();

    if (cleanedPhone.isEmpty) {
      return false;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: cleanedPhone);

    if (!await canLaunchUrl(phoneUri)) {
      return false;
    }

    return launchUrl(phoneUri, mode: LaunchMode.externalApplication);
  }
}
