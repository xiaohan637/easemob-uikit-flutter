import 'package:em_chat_uikit/chat_uikit.dart';
import 'package:em_chat_uikit/ui/views/group_members_admin.dart';

import 'package:flutter/material.dart';

class GroupMembersView extends StatefulWidget {
  GroupMembersView.arguments(GroupMembersViewArguments arguments, {Key? key})
      : profile = arguments.profile,
        listViewItemBuilder = arguments.listViewItemBuilder,
        onSearchTap = arguments.onSearchTap,
        searchBarHideText = arguments.searchBarHideText,
        listViewBackground = arguments.listViewBackground,
        onTap = arguments.onTap,
        onLongPress = arguments.onLongPress,
        appBar = arguments.appBar,
        controller = arguments.controller,
        loadErrorMessage = arguments.loadErrorMessage,
        enableAppBar = arguments.enableAppBar,
        title = arguments.title,
        appBarTrailingActionsBuilder = arguments.appBarTrailingActionsBuilder,
        attributes = arguments.attributes,
        viewObserver = arguments.viewObserver,
        super(key: key);

  const GroupMembersView({
    required this.profile,
    this.listViewItemBuilder,
    this.onSearchTap,
    this.searchBarHideText,
    this.listViewBackground,
    this.onTap,
    this.onLongPress,
    this.appBar,
    this.controller,
    this.loadErrorMessage,
    this.enableAppBar = true,
    this.title,
    this.attributes,
    this.viewObserver,
    this.appBarTrailingActionsBuilder,
    super.key,
  });

  final ChatUIKitProfile profile;

  final GroupMemberListViewController? controller;
  final ChatUIKitAppBar? appBar;
  final void Function(List<ContactItemModel> data)? onSearchTap;

  final ChatUIKitContactItemBuilder? listViewItemBuilder;
  final void Function(BuildContext context, ContactItemModel model)? onTap;
  final void Function(BuildContext context, ContactItemModel model)?
      onLongPress;
  final String? searchBarHideText;
  final Widget? listViewBackground;
  final String? loadErrorMessage;
  final bool enableAppBar;
  final String? title;
  final String? attributes;

  /// 用于刷新页面的Observer
  final ChatUIKitViewObserver? viewObserver;
  final ChatUIKitAppBarTrailingActionsBuilder? appBarTrailingActionsBuilder;

  @override
  State<GroupMembersView> createState() => _GroupMembersViewState();
}

class _GroupMembersViewState extends State<GroupMembersView>
    with GroupObserver {
  late final GroupMemberListViewController controller;
  List<ContactItemModel>? addedBuffers;
  List<ContactItemModel>? deleteBuffer;
  ValueNotifier<int> memberCount = ValueNotifier<int>(0);
  Group? group;

  @override
  void initState() {
    super.initState();
    ChatUIKit.instance.addObserver(this);
    controller = widget.controller ??
        GroupMemberListViewController(groupId: widget.profile.id);
    widget.viewObserver?.addListener(() {
      setState(() {});
    });
    fetchGroup();
  }

  @override
  void dispose() {
    widget.viewObserver?.dispose();
    ChatUIKit.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onMemberJoinedFromGroup(String groupId, String member) {
    memberCount.value = memberCount.value + 1;
  }

  @override
  void onMemberExitedFromGroup(String groupId, String member) {
    memberCount.value = memberCount.value - 1;
  }

  void fetchGroup() async {
    try {
      group = await ChatUIKit.instance.getGroup(groupId: widget.profile.id);
      group ??=
          await ChatUIKit.instance.fetchGroupInfo(groupId: widget.profile.id);
      memberCount.value = group?.memberCount ?? 0;
      setState(() {});
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatUIKitTheme.of(context);
    Widget content = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.color.isDark
          ? theme.color.neutralColor1
          : theme.color.neutralColor98,
      appBar: !widget.enableAppBar
          ? null
          : widget.appBar ??
              ChatUIKitAppBar(
                showBackButton: true,
                trailingActions: () {
                  List<ChatUIKitAppBarTrailingAction> actions = [];
                  if (group?.permissionType == GroupPermissionType.Owner) {
                    actions.add(
                      ChatUIKitAppBarTrailingAction(
                        actionType: ChatUIKitActionType.custom,
                        onTap: (context) {
                          pushToAdminMember();
                        },
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: theme.color.isDark
                              ? theme.color.neutralColor9
                              : theme.color.neutralColor3,
                          size: 24,
                        ),
                      ),
                    );
                  }

                  if (group?.permissionType == GroupPermissionType.Owner ||
                      group?.permissionType == GroupPermissionType.Admin) {
                    actions.add(
                      ChatUIKitAppBarTrailingAction(
                        actionType: ChatUIKitActionType.add,
                        onTap: (context) {
                          pushToAddMember();
                        },
                        child: Icon(
                          Icons.person_add_alt_1_outlined,
                          color: theme.color.isDark
                              ? theme.color.neutralColor9
                              : theme.color.neutralColor3,
                          size: 24,
                        ),
                      ),
                    );
                    actions.add(ChatUIKitAppBarTrailingAction(
                      actionType: ChatUIKitActionType.remove,
                      onTap: (context) {
                        pushToRemoveMember();
                      },
                      child: Icon(
                        Icons.person_remove_alt_1_outlined,
                        color: theme.color.isDark
                            ? theme.color.neutralColor9
                            : theme.color.neutralColor3,
                        size: 24,
                      ),
                    ));
                    actions = widget.appBarTrailingActionsBuilder
                            ?.call(context, actions) ??
                        actions;
                  }
                  return actions;
                }(),
                centerTitle: false,
                titleWidget: ValueListenableBuilder(
                  valueListenable: memberCount,
                  builder: (context, value, child) {
                    if (memberCount.value == 0) {
                      return Text(
                        widget.title ??
                            ChatUIKitLocal.groupMembersViewTitle
                                .localString(context),
                        textScaler: TextScaler.noScaling,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.color.isDark
                              ? theme.color.neutralColor98
                              : theme.color.neutralColor1,
                          fontWeight: theme.font.titleMedium.fontWeight,
                          fontSize: theme.font.titleMedium.fontSize,
                        ),
                      );
                    } else {
                      return Text(
                        '${ChatUIKitLocal.groupMembersViewTitle.localString(context)}(${memberCount.value})',
                        textScaler: TextScaler.noScaling,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.color.isDark
                              ? theme.color.neutralColor98
                              : theme.color.neutralColor1,
                          fontWeight: theme.font.titleMedium.fontWeight,
                          fontSize: theme.font.titleMedium.fontSize,
                        ),
                      );
                    }
                  },
                ),
              ),
      body: SafeArea(
        child: GroupMemberListView(
          groupId: widget.profile.id,
          controller: controller,
          itemBuilder: widget.listViewItemBuilder,
          searchHideText: widget.searchBarHideText,
          background: widget.listViewBackground,
          onTap: widget.onTap ??
              (context, model) {
                onMemberTap(context, model.profile);
              },
          onSearchTap: widget.onSearchTap ?? onSearchTap,
        ),
      ),
    );

    return content;
  }

  Widget actionsWidget() {
    final theme = ChatUIKitTheme.of(context);
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: pushToAddMember,
          child: Icon(
            Icons.person_add_alt_1_outlined,
            color: theme.color.isDark
                ? theme.color.neutralColor9
                : theme.color.neutralColor3,
            size: 24,
          ),
        ),
        InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: pushToRemoveMember,
          child: Icon(
            Icons.person_remove_alt_1_outlined,
            color: theme.color.isDark
                ? theme.color.neutralColor9
                : theme.color.neutralColor3,
            size: 24,
          ),
        )
      ],
    );

    content = Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      width: 74,
      height: 36,
      child: content,
    );
    return content;
  }

  void onMemberTap(BuildContext context, ChatUIKitProfile profile) async {
    // 如果是自己
    if (profile.id == ChatUIKit.instance.currentUserId) {
      pushToCurrentUser(profile);
      return;
    }

    List<String> contacts = await ChatUIKit.instance.getAllContactIds();
    if (contacts.contains(profile.id)) {
      pushContactDetails(profile);
    } else {
      pushNewRequestDetails(profile);
    }
  }

  // 处理点击自己头像和点击自己名片
  void pushToCurrentUser(ChatUIKitProfile profile) {
    ChatUIKitRoute.pushOrPushNamed(
      context,
      ChatUIKitRouteNames.currentUserInfoView,
      CurrentUserInfoViewArguments(
        profile: profile,
        attributes: widget.attributes,
      ),
    );
  }

  void pushContactDetails(ChatUIKitProfile profile) {
    ChatUIKitRoute.pushOrPushNamed(
      context,
      ChatUIKitRouteNames.contactDetailsView,
      ContactDetailsViewArguments(
        profile: profile,
        attributes: widget.attributes,
      ),
    );
  }

  void pushNewRequestDetails(ChatUIKitProfile profile) {
    Navigator.of(context).pushNamed(
      ChatUIKitRouteNames.newRequestDetailsView,
      arguments: NewRequestDetailsViewArguments(
        profile: profile,
        attributes: widget.attributes,
      ),
    );
  }

  void pushToAddMember() async {
    List<ChatUIKitProfile> members = [];
    List list = controller.list;
    for (var element in list) {
      if (element is ContactItemModel) {
        members.add(element.profile);
      }
    }

    ChatUIKitRoute.pushOrPushNamed(
      context,
      ChatUIKitRouteNames.groupAddMembersView,
      GroupAddMembersViewArguments(
        groupId: widget.profile.id,
        inGroupMembers: members,
        attributes: widget.attributes,
      ),
    ).then((value) {
      if (value != null && value is List<ChatUIKitProfile>) {
        List<ContactItemModel> models = [];
        List<String> userIds = [];
        for (var item in value) {
          userIds.add(item.id);
          models.add(ContactItemModel(profile: item));
        }
        ChatUIKit.instance.addGroupMembers(
          groupId: widget.profile.id,
          members: userIds,
        );

        controller.list.addAll(models);
        controller.refresh();
      }
    }).catchError((e) {});
  }

  void pushToAdminMember() async {
    Group? group =
        await ChatUIKit.instance.getGroup(groupId: widget.profile.id);
    List<ChatUIKitProfile> adminMembers = [];
    List<ChatUIKitProfile> members = [];
    print("===${group?.memberList}");
    print("===${group?.adminList}");

    if (group != null) {
      if (group.adminList != null) {
        List<ContactItemModel> tmp = controller.mappers(group.adminList!);
        for (var element in tmp) {
          adminMembers.add(element.profile);
        }
      }
      if (group.memberList != null) {
        List<ContactItemModel> tmp = controller.mappers(group.memberList!);
        for (var element in tmp) {
          members.add(element.profile);
        }
      }
    }
    ChatUIKitRoute.pushOrPushNamed(
      context,
      ChatUIKitRouteNames.groupAdminMembersView,
      GroupAdminMembersViewArguments(
          groupId: widget.profile.id,
          ow: group?.owner,
          adminMembers: adminMembers,
          members: members),
    ).then((value) {
      controller.refresh();
    }).catchError((e) {});
  }

  void pushToRemoveMember() {
    ChatUIKitRoute.pushOrPushNamed(
      context,
      ChatUIKitRouteNames.groupDeleteMembersView,
      GroupDeleteMembersViewArguments(
        groupId: widget.profile.id,
        attributes: widget.attributes,
      ),
    ).then((value) {
      if (value != null && value is List<ChatUIKitProfile>) {
        List<String> userIds = [];
        for (var item in value) {
          userIds.add(item.id);
        }
        ChatUIKit.instance.deleteGroupMembers(
          groupId: widget.profile.id,
          members: userIds,
        );

        for (var userId in userIds) {
          controller.list.removeWhere((element) {
            return (element is ContactItemModel &&
                element.profile.id == userId);
          });
        }
        controller.refresh();
      }
    }).catchError((e) {});
  }

  void onSearchTap(List<ContactItemModel> data) async {
    List<NeedSearch> list = [];
    for (var item in data) {
      list.add(item);
    }

    ChatUIKitRoute.pushOrPushNamed(
      context,
      ChatUIKitRouteNames.searchGroupMembersView,
      SearchGroupMembersViewArguments(
        attributes: widget.attributes,
        itemBuilder: (context, profile, searchKeyword) {
          return InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              onMemberTap(context, profile);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 19.5, right: 15.5),
              child: ChatUIKitSearchListViewItem(
                profile: profile,
                highlightWord: searchKeyword,
              ),
            ),
          );
        },
        searchHideText: ChatUIKitLocal.groupMembersSearch.localString(context),
        searchData: list,
      ),
    );
  }
}
