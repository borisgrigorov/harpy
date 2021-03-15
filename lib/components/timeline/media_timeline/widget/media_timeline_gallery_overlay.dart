import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harpy/components/common/image_gallery/harpy_media_gallery.dart';
import 'package:harpy/components/common/video_player/harpy_video_player_model.dart';
import 'package:harpy/components/timeline/media_timeline/model/media_timeline_model.dart';
import 'package:harpy/components/tweet/bloc/tweet_bloc.dart';
import 'package:harpy/components/tweet/bloc/tweet_state.dart';
import 'package:harpy/components/tweet/widgets/overlay/media_overlay.dart';
import 'package:harpy/core/api/twitter/tweet_data.dart';

import 'media_timeline_gallery_widget.dart';

class MediaTimelineGalleryOverlay extends StatefulWidget {
  const MediaTimelineGalleryOverlay({
    @required this.entries,
    @required this.initialIndex,
    @required this.videoPlayerModel,
  });

  final List<MediaTimelineEntry> entries;
  final int initialIndex;
  final HarpyVideoPlayerModel videoPlayerModel;

  @override
  _MediaTimelineGalleryOverlayState createState() =>
      _MediaTimelineGalleryOverlayState();
}

class _MediaTimelineGalleryOverlayState
    extends State<MediaTimelineGalleryOverlay> {
  int _index;
  TweetData _tweet;
  TweetBloc _bloc;

  String get _mediaUrl {
    if (widget.entries[_index].isImage) {
      return widget.entries[_index].imageData.large;
    } else if (widget.entries[_index].isVideo) {
      return widget.entries[_index].videoData.bestUrl;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _index = widget.initialIndex;
    _tweet = widget.entries[widget.initialIndex].tweet;
    _bloc = TweetBloc(_tweet);
  }

  void _onPageChanged(int newIndex) {
    _index = newIndex;

    final TweetData newTweet = widget.entries[newIndex].tweet;

    if (mounted && newTweet.idStr != _tweet.idStr) {
      setState(() {
        _tweet = newTweet;
        _bloc = TweetBloc(_tweet);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TweetBloc, TweetState>(
      bloc: _bloc,
      builder: (_, __) => MediaOverlay(
        tweet: _tweet,
        tweetBloc: _bloc,
        enableDismissible: false,
        enableImmersiveMode: false,
        overlap: false,
        onOpenExternally: () => onOpenExternally(_mediaUrl),
        onDownload: () => onDownload(_mediaUrl),
        onShare: () => onShare(_mediaUrl),
        child: HarpyMediaGallery.builder(
          itemCount: widget.entries.length,
          initialIndex: widget.initialIndex,
          heroTagBuilder: (int index) => widget.entries[index].isImage
              ? '$index-${widget.entries[index].media.appropriateUrl}'
              : null,
          onPageChanged: _onPageChanged,
          builder: (_, int index) => MediaTimelineGalleryWidget(
            entry: widget.entries[index],
            initialIndex: widget.initialIndex,
            index: index,
            videoPlayerModel: widget.videoPlayerModel,
          ),
        ),
      ),
    );
  }
}
