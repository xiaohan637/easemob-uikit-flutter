import 'package:em_chat_uikit/chat_uikit.dart';
import 'package:flutter/widgets.dart';

class GroupDetailsViewArguments implements ChatUIKitViewArguments {
  GroupDetailsViewArguments({
    required this.profile,
    this.actionsBuilder,
    this.onTap,
    this.appBar,
    this.enableAppBar = true,
    this.onMessageDidClear,
    this.viewObserver,
    this.contentWidgetBuilder,
    this.attributes,
    this.appBarTrailingActionsBuilder,
  });
  final ChatUIKitProfile profile;
  final ChatUIKitModelActionsBuilder? actionsBuilder;
  final ChatUIKitAppBar? appBar;
  final bool enableAppBar;
  final VoidCallback? onMessageDidClear;
  final VoidCallback? onTap;
  final WidgetBuilder? contentWidgetBuilder;

  @override
  String? attributes;
  @override
  ChatUIKitViewObserver? viewObserver;
  final ChatUIKitAppBarTrailingActionsBuilder? appBarTrailingActionsBuilder;
  GroupDetailsViewArguments copyWith(
      {ChatUIKitProfile? profile,
      ChatUIKitModelActionsBuilder? actionsBuilder,
      bool? enableAppBar,
      ChatUIKitAppBar? appBar,
      WidgetBuilder? contentWidgetBuilder,
      ChatUIKitViewObserver? viewObserver,
      VoidCallback? onMessageDidClear,
      String? attributes,
      ChatUIKitAppBarTrailingActionsBuilder? appBarTrailingActionsBuilder}) {
    return GroupDetailsViewArguments(
      profile: profile ?? this.profile,
      actionsBuilder: actionsBuilder ?? this.actionsBuilder,
      enableAppBar: enableAppBar ?? this.enableAppBar,
      appBar: appBar ?? this.appBar,
      onMessageDidClear: onMessageDidClear ?? this.onMessageDidClear,
      viewObserver: viewObserver ?? this.viewObserver,
      contentWidgetBuilder: contentWidgetBuilder ?? this.contentWidgetBuilder,
      attributes: attributes ?? this.attributes,
      appBarTrailingActionsBuilder:
          appBarTrailingActionsBuilder ?? this.appBarTrailingActionsBuilder,
    );
  }
}
