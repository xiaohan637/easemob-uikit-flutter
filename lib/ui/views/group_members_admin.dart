import 'package:em_chat_uikit/provider/chat_uikit_profile.dart';
import 'package:em_chat_uikit/ui/route/chat_uikit_view_observer.dart';
import 'package:em_chat_uikit/ui/route/view_arguments/view_arguments_base.dart';
import 'package:em_chat_uikit/universal/chat_uikit_action_model.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../widgets/chat_uikit_app_bar.dart';

class GroupMembersAdmin extends StatefulWidget {
  const GroupMembersAdmin({ required this.members,
    required this.adminMembers,
    required this.groupId,
    super.key});

  GroupMembersAdmin.arguments(GroupAdminMembersViewArguments arguments, {Key? key})
      : members = arguments.members,
        adminMembers = arguments.adminMembers,
        groupId = arguments.groupId,
        super(key: key);

  final  List<ChatUIKitProfile> members;
  final  List<ChatUIKitProfile> adminMembers;
  final  String groupId;

  @override
  State<GroupMembersAdmin> createState() => _GroupMembersAdminState();
}

class _GroupMembersAdminState extends State<GroupMembersAdmin> {
  late List<ChatUIKitProfile> members;
  late List<ChatUIKitProfile> adminMembers;
  @override
  void initState() {
    members = widget.members;
    adminMembers = widget.adminMembers;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:const ChatUIKitAppBar(
        showBackButton: true,

        centerTitle: false,
        titleWidget: Text('管理成员'),
      ),
      body: ListView.builder(
          itemCount:members.length ,
          itemBuilder: (context,index){
            final ChatUIKitProfile profile = members[index];
            final admin = adminMembers.any((e)=>e.id==profile.id);
          return CheckboxListTile(value:admin ,
              title: Text(profile.nickname),
              onChanged: (v){
            try{
              if(v!){
                EMClient.getInstance.groupManager.removeAdmin(widget.groupId,
                    profile.id);
              }else{
                EMClient.getInstance.groupManager.addAdmin(widget.groupId,
                    profile.id);

              }
            }catch(e,s){
              debugPrintStack(stackTrace: s,label: '$e');
            }

              });
      }),
    );
  }





}

class GroupAdminMembersViewArguments implements ChatUIKitViewArguments{
  final String groupId;
  final   List<ChatUIKitProfile> members;
  final   List<ChatUIKitProfile> adminMembers;

  GroupAdminMembersViewArguments(

      {required this.groupId,
        required this.adminMembers,
        required this.members,});

  @override
  String? attributes;

  @override
  ChatUIKitViewObserver? viewObserver;
}
