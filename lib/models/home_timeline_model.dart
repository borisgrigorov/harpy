import 'package:flutter/material.dart';
import 'package:harpy/api/twitter/data/tweet.dart';
import 'package:harpy/api/twitter/services/tweet_service.dart';
import 'package:harpy/core/cache/home_timeline_cache.dart';
import 'package:harpy/models/timeline_model.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeTimelineModel extends TimelineModel {
  HomeTimelineModel({
    @required TweetService tweetService,
    @required HomeTimelineCache homeTimelineCache,
  }) : super(tweetService: tweetService, tweetCache: homeTimelineCache);

  static final Logger _log = Logger("HomeTimelineModel");

  static HomeTimelineModel of(BuildContext context) {
    return ScopedModel.of<HomeTimelineModel>(context);
  }

  @override
  Future<void> updateTweets() async {
    _log.fine("updating tweets");
    tweets = await tweetService.getHomeTimeline();
    notifyListeners();
  }

  @override
  Future<void> requestMore() async {
    await super.requestMore();

    String id = "${tweets.last.id - 1}";
    // todo: bug: clears cached tweets where id > than id
    tweets.addAll(await tweetService.getHomeTimeline(
      params: {"max_id": id},
    ));

    requestingMore = false;
    notifyListeners();
  }

  void updateTweet(Tweet tweet) {
    int index = tweets.indexOf(tweet);
    if (index != -1) {
      _log.fine("updating home timeline tweet");
      tweets[index] = tweet;
    }
  }
}
