import 'package:em_chat_uikit/provider/chat_uikit_profile.dart';
import 'package:em_chat_uikit/ui/route/chat_uikit_view_observer.dart';
import 'package:em_chat_uikit/ui/route/view_arguments/view_arguments_base.dart';
import 'package:em_chat_uikit/universal/chat_uikit_action_model.dart';
import 'package:flutter/material.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';
import 'package:em_chat_uikit/chat_uikit.dart';
import '../widgets/chat_uikit_app_bar.dart';

class GroupMembersAdmin extends StatefulWidget {
  const GroupMembersAdmin({ required this.members,
    required this.adminMembers,
    required this.groupId,
    super.key,  this.ow});

  GroupMembersAdmin.arguments(GroupAdminMembersViewArguments arguments, {Key? key})
      : members = arguments.members,
        adminMembers = arguments.adminMembers,
        groupId = arguments.groupId,
        ow = arguments.ow,
        super(key: key);

  final  List<ChatUIKitProfile> members;
  final  List<ChatUIKitProfile> adminMembers;
  final  String groupId;
  final  String? ow;

  @override
  State<GroupMembersAdmin> createState() => _GroupMembersAdminState();
}

class _GroupMembersAdminState extends State<GroupMembersAdmin> {
  late List<ChatUIKitProfile> members;
  late List<ChatUIKitProfile> adminMembers;
  late List<ChatUIKitProfile> allMembers;

  @override
  void initState() {
    members = widget.members;
    adminMembers = widget.adminMembers;
    allMembers = [...widget.adminMembers,...widget.members];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final theme = ChatUIKitTheme.of(context);
    return Scaffold(
      appBar: ChatUIKitAppBar(
        showBackButton: true,

        centerTitle: false,
        titleWidget: Text('管理成员',style:TextStyle(
          fontSize: theme.font.titleMedium.fontSize,
          fontWeight: theme.font.titleMedium.fontWeight,
          color: theme.color.isDark
              ? theme.color.neutralColor98
              : theme.color.neutralColor1,
        ),
        ),
      ),
      body: ListView.builder(
          itemCount:allMembers.length ,
          itemBuilder: (context,index){
            final ChatUIKitProfile profile = allMembers[index];
            final admin = adminMembers.any((e)=>e.id==profile.id);
            final groupPre = widget.ow==profile.id;
            return CheckboxListTile(value:admin,
                enabled:!groupPre,
                title: Row(
                  children: [
                    ChatUIKitAvatar(avatarUrl: profile.avatarUrl,),
                    SizedBox(width: 6,),
                    Text(profile.showName)
                  ],
                ),
                onChanged: (v){
                  try{
                    if(admin){
                      EMClient.getInstance.groupManager.removeAdmin(widget.groupId,
                          profile.id);
                      adminMembers.removeWhere((e){
                        return e.id==profile.id;
                      });
                    }else{
                      EMClient.getInstance.groupManager.addAdmin(widget.groupId,
                          profile.id);
                      adminMembers.add(profile);
                    }
                    setState(() {});
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
  final   String? ow;

  GroupAdminMembersViewArguments(

      {required this.groupId,
        required this.adminMembers,
        this.ow,
        required this.members,});

  @override
  String? attributes;

  @override
  ChatUIKitViewObserver? viewObserver;
}
