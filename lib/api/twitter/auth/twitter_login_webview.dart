import 'package:flutter/material.dart';
import 'package:harpy/api/twitter/auth/twitter_auth.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Builds a [WebView] for the twitter authentication.
///
/// Upon successful authentication or user cancel, [Navigator.pop] will be
/// called with the callback url as a [Uri] instance.
/// The callback url contains the token and secret as query params on
/// success, or a denied query param on user cancel.
class TwitterLoginWebview extends StatelessWidget {
  const TwitterLoginWebview({
    @required this.token,
  });

  final String token;

  NavigationDecision _navigationDelegate(
    BuildContext context,
    NavigationRequest navigation,
  ) {
    if (navigation.url.startsWith(TwitterAuth.callbackUrl)) {
      Navigator.of(context).pop(Uri.dataFromString(navigation.url));
    }

    return NavigationDecision.prevent;
  }

  @override
  Widget build(BuildContext context) {
    final Uri initialUrl = Uri.https(
      'api.twitter.com',
      'oauth/authorize',
      <String, String>{
        'oauth_token': token,
      },
    );

    return WebView(
      initialUrl: initialUrl.toString(),
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (NavigationRequest navigation) =>
          _navigationDelegate(context, navigation),
    );
  }
}
