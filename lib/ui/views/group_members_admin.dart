import 'package:em_chat_uikit/provider/chat_uikit_profile.dart';
import 'package:em_chat_uikit/universal/chat_uikit_action_model.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

import '../widgets/chat_uikit_app_bar.dart';

class GroupMembersAdmin extends StatefulWidget {
  const GroupMembersAdmin({super.key, required this.members, required this.adminMembers, required this.groupId});

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

class GroupAdminMembersViewArguments {
  final String groupId;
  final   List<ChatUIKitProfile> profiles;
  final   List<ChatUIKitProfile> adminProfiles;

  GroupAdminMembersViewArguments(

      {required this.groupId,
        required this.adminProfiles,
        required this.profiles,});
}
