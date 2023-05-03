import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:flutter_theodolite/pages/voice/provider/invite_member.dart';
import 'package:flutter_theodolite/pages/voice/provider/speak_list.dart';
import 'package:flutter_theodolite/res/resources.dart';
import 'package:flutter_theodolite/util/event.dart';
import 'package:flutter_theodolite/util/image_utils.dart';
import 'package:flutter_theodolite/util/navigation.dart';
import 'package:flutter_theodolite/util/toast_utils.dart';
import 'package:flutter_theodolite/widgets/empty.dart';
import 'package:flutter_theodolite/widgets/load_image.dart';
import 'package:flutter_theodolite/widgets/my_app_bar.dart';
import 'package:flutter_theodolite/widgets/my_icontext_button.dart';
import 'package:flutter_theodolite/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../main.dart';

class InviteMember extends StatefulWidget {
  InviteMember({Key? key}) : super(key: key);

  @override
  _InviteMemberState createState() => _InviteMemberState();
}

class _InviteMemberState extends State<InviteMember> {
  late InviteMemberProvider _vm;
  late InviteMemberProvider vm;

  @override
  void initState() {
    _vm = Provider.of<InviteMemberProvider>(context, listen: false);
    _vm.init();
    print(nav.currentContext.widget.toString());
    print(nav.currentContext.widget.toString().contains('voiceRoomDetail'));
    super.initState();
  }

  buildMember(index, user) {
    return Container(
        padding: EdgeInsets.fromLTRB(10.sp, index == 0 ? 10.sp : 4.sp, 10.sp,
            index == vm.users.length - 1 ? 10.sp : 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(index == 0 ? 13.sp : 0),
            topRight: Radius.circular(index == 0 ? 13.sp : 0),
            bottomLeft:
                Radius.circular(index == vm.users.length - 1 ? 13.sp : 0),
            bottomRight:
                Radius.circular(index == vm.users.length - 1 ? 13.sp : 0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48.sp,
                  height: 48.sp,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.sp),
                    image: DecorationImage(
                        image: ImageUtils.getImageProvider(user['avatar']),
                        fit: BoxFit.cover),
                  ),
                ),
                Gaps.hGap10,
                Text(user['nickname'])
                    .text
                    .size(14.sp)
                    .overflow(TextOverflow.ellipsis)
                    .black
                    .make()
                    .expand(),
              ],
            ).expand(),
            Row(
              children: [
                user['invitation'] == 1
                    ? MyIconTextButton(
                        onTap: () {
                          vm.invite(user, index);
                        },
                        image: LoadAssetImage(
                          'icon/add_black',
                          height: 10.sp,
                        ),
                        title: lang?.invite,
                      )
                    : MyIconTextButton(
                        onTap: () {},
                        image: LoadAssetImage(
                          'icon/add_white',
                          height: 10.sp,
                        ),
                        textColor: Colors.white,
                        borderColor: Color(0xFFBDBDBD),
                        bgColor: Color(0xFFBDBDBD),
                        title: lang?.havinvite ?? '',
                      ),
              ],
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    vm = context.watch<InviteMemberProvider>();
    return Scaffold(
        appBar: MyAppBar(centerTitle: lang?.inviteFriend ?? ""),
        body: SmartRefresher(
          enablePullUp: true,
          controller: vm.refreshController,
          onLoading: () => _vm.getMore(),
          onRefresh: () => _vm.onRefresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.sp, 0, 10.sp, 10.sp),
                  child: SearchBar(
                    hintText: lang?.search ?? '',
                    onPressed: (value) {
                      if (value.isEmpty) {
                        Toast.show(lang?.searchHint ?? '');
                        return;
                      }
                      vm.onSearch(value);
                    },
                  ),
                ),
              ),
              vm.users.length > 0
                  ? SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 10.sp),
                      sliver: SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                        return buildMember(index, vm.users[index]);
                      }, childCount: vm.users.length)))
                  : Center(child: Empty()).sliverToBoxAdapter()
            ],
          ),
        ));
  }
}
