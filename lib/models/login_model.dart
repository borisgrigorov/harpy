import 'package:flutter/widgets.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:harpy/api/twitter/data/user.dart';
import 'package:harpy/api/twitter/services/error_handler.dart';
import 'package:harpy/api/twitter/services/user_service.dart';
import 'package:harpy/core/cache/user_cache.dart';
import 'package:harpy/core/misc/global_snackbar_message.dart';
import 'package:harpy/models/application_model.dart';
import 'package:harpy/models/home_timeline_model.dart';
import 'package:logging/logging.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginModel extends Model {
  LoginModel({
    @required this.applicationModel,
    @required this.homeTimelineModel,
    @required this.userService,
    @required this.userCache,
  })  : assert(applicationModel != null),
        assert(homeTimelineModel != null),
        assert(userService != null),
        assert(userCache != null);

  final ApplicationModel applicationModel;
  final HomeTimelineModel homeTimelineModel;
  final UserService userService;
  final UserCache userCache;

  static LoginModel of(BuildContext context) {
    return ScopedModel.of<LoginModel>(context);
  }

  static final Logger _log = Logger("LoginModel");

  /// Holds a the information for the currently logged in [User].
  ///
  /// If [loggedIn] is `false` this is `null`.
  User loggedInUser;

  /// `true` while logging in and initializing on successful login.
  bool authorizing = false;

  /// A callback that is called when the authorization completes.
  VoidCallback onAuthorized;

  /// Login using the native twitter sdk.
  ///
  /// On successful login the [onAuthorized] callback is called.
  Future<void> login() async {
    _log.fine("logging in");

    authorizing = true;
    notifyListeners();
    TwitterLoginResult result = await applicationModel.twitterLogin.authorize();
    authorizing = false;

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        _log.fine("successfully logged in");
        applicationModel.twitterSession = result.session;

        // init tweet cache logged in user
        applicationModel.initLoggedIn();

        // initialize before navigating
        await initBeforeHome();

        // makes sure we were able to get the logged in user before navigating
        if (onAuthorized != null && loggedInUser != null) {
          onAuthorized();
        }
        break;
      case TwitterLoginStatus.cancelledByUser:
        _log.info("login cancelled by user");
        showSnackbarMessage("Login cancelled.");
        break;
      case TwitterLoginStatus.error:
        _log.warning("error during login");
        showSnackbarMessage("An error occurred during login.");
        break;
    }

    notifyListeners();
  }

  /// Logout using the native twitter sdk.
  Future<void> logout() async {
    _log.fine("logging out");

    await applicationModel.twitterLogin.logOut();

    applicationModel.twitterSession = null;
    loggedInUser = null;
  }

  /// Initializes the logged in user and the home timeline tweets.
  Future<void> initBeforeHome() async {
    await Future.wait([
      homeTimelineModel.initTweets(),
      _initLoggedInUser(),
    ]);
  }

  Future<void> _initLoggedInUser() async {
    _log.fine("initializing logged in user");

    String userId = applicationModel.twitterSession.userId;

    // init theme from shared prefs
    applicationModel.themeSettingsModel.initTheme();

    loggedInUser = userCache.getCachedUser(userId);

    if (loggedInUser == null) {
      _log.fine("user not in cache, waiting to update logged in user");
      await _updateLoggedInUser();
    } else {
      _log.fine("user in cache, immediately returning and updating user");
      _updateLoggedInUser();
    }
  }

  Future<void> _updateLoggedInUser() async {
    _log.fine("updating logged in user");

    String userId = applicationModel.twitterSession.userId;

    User user = await userService.getUserDetails(id: userId).catchError(
      (error) {
        _log.warning("unable to update logged in user");

        twitterClientErrorHandler(
          error,
          "An unexpected error occurred while trying to update logged in user",
        );
      },
    );

    if (user != null) {
      loggedInUser = user;
    }

    notifyListeners();
  }
}