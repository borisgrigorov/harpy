import 'package:flutter/material.dart';
import 'package:harpy/models/home_timeline_model.dart';
import 'package:harpy/service_provider.dart';
import 'package:harpy/widgets/shared/cache_provider.dart';
import 'package:harpy/widgets/shared/home_drawer.dart';
import 'package:harpy/widgets/shared/scaffolds.dart';
import 'package:harpy/widgets/shared/tweet/tweet_list.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final serviceProvider = ServiceProvider.of(context);

    return HarpyScaffold(
      appBar: "Harpy",
      body: CacheProvider(
        homeTimelineCache: serviceProvider.data.homeTimelineCache,
        child: TweetList<HomeTimelineModel>(),
      ),
      drawer: HomeDrawer(),
    );
  }
}
