import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

/// Web sign-in uses Google Identity Services prompt.
/// Token lands in localStorage['gid_cred'] via inline JS in index.html.
class GoogleAuth {
  static Future<String?> signIn() async {
    js.context.callMethod('promptGis');
    final deadline = DateTime.now().add(const Duration(seconds: 60));
    String? token;
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 300));
      token = html.window.localStorage['gid_cred'];
      if (token != null && token.isNotEmpty) break;
    }
    if (token != null) html.window.localStorage.remove('gid_cred');
    return token;
  }
}
