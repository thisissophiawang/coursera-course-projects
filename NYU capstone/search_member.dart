import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:flutter_theodolite/pages/voice/provider/search_member.dart';
import 'package:flutter_theodolite/res/colors.dart';
import 'package:flutter_theodolite/res/constant.dart';
import 'package:flutter_theodolite/res/gaps.dart';
import 'package:flutter_theodolite/util/image_utils.dart';
import 'package:flutter_theodolite/util/toast_utils.dart';
import 'package:flutter_theodolite/widgets/load_image.dart';
import 'package:flutter_theodolite/widgets/my_app_bar.dart';
import 'package:flutter_theodolite/widgets/my_card.dart';
import 'package:flutter_theodolite/widgets/my_icontext_button.dart';
import 'package:flutter_theodolite/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_theodolite/widgets/empty.dart';

import '../../../main.dart';

class SearchMembers extends StatefulWidget {
  SearchMembers({Key? key}) : super(key: key);

  @override
  _SearchMembersState createState() => _SearchMembersState();
}

class _SearchMembersState extends State<SearchMembers> {
  late SearchMemberProvider _vm;
  late SearchMemberProvider vm;

  int? myId = SpUtil.getInt(Constant.userId) ?? 0;
  @override
  void initState() {
    super.initState();
    _vm = Provider.of<SearchMemberProvider>(context, listen: false);
    _vm.init();
    super.initState();
  }

  Widget buildMemberItem(item) {
    return MyCard(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
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
                        image: ImageUtils.getImageProvider(item['avatar']),
                        fit: BoxFit.cover),
                  ),
                ),
                Gaps.hGap10,
                Text(item['nickname']).text.size(14.sp).black.make()
              ],
            ),
            item['user_id'] == myId
                ? Gaps.empty
                : item['focus'] == 2
                    ? Container(
                        child: MyIconTextButton(
                          onTap: () {
                            _vm.handleFollow(item);
                          },
                          image: LoadAssetImage(
                            'icon/add_white',
                            height: 10.sp,
                          ),
                          textColor: Colors.white,
                          borderColor: Color(0xFFBDBDBD),
                          bgColor: Color(0xFFBDBDBD),
                          title: lang?.havFollow ?? "",
                        ),
                      )
                    : Container(
                        child: MyIconTextButton(
                          onTap: () {
                            _vm.handleFollow(item);
                          },
                          borderColor: Colours.app_main,
                          image: LoadAssetImage(
                            'icon/add_black',
                            height: 10.sp,
                          ),
                          textColor: Colors.black,
                          bgColor: Color(0xFFFFFFFF),
                          title: lang?.follow ?? "",
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget buildMasterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lang?.master ?? '').text.size(12.sp).black.make(),
        Gaps.vGap10,
        buildMemberItem(vm.users['master'])
      ],
    );
  }

  Widget buildUserSection() {
    return vm.users['user'] != null &&
            vm.users['user'] is List &&
            vm.users['user'].length > 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang?.voiceUser ?? "").text.size(12.sp).black.make(),
              Gaps.vGap10,
              Column(
                children: vm.users['user'].map<Widget>(
                  (item) {
                    return buildMemberItem(item);
                  },
                ).toList(),
              ),
            ],
          )
        : Container();
  }

  Widget buildFriendSecton() {
    return vm.users['user'] != null &&
            vm.users['friend'] is List &&
            vm.users['friend'].length > 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang?.myAttention ?? '').text.size(12.sp).black.make(),
              Gaps.vGap10,
              Column(
                children: vm.users['friend'].map<Widget>(
                  (item) {
                    return buildMemberItem(item);
                  },
                ).toList(),
              ),
            ],
          )
        : Container();
  }

  Widget buildByIndex(int index) {
    switch (index) {
      case 0:
        return buildFriendSecton();
        break;
      case 1:
        return buildMasterSection();
        break;
      default:
        return buildUserSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    vm = context.watch<SearchMemberProvider>();
    return Scaffold(
      appBar: MyAppBar(
        centerTitle: lang?.search ?? '',
      ),
      body: SmartRefresher(
        enablePullUp: true,
        onLoading: () => _vm.getMore(),
        onRefresh: () => _vm.onRefresh(),
        controller: _vm.refreshController,
        footer: vm.users.length > 5
            ? ClassicFooter()
            : SliverToBoxAdapter(child: Gaps.empty),
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
                  onDeleted: () => vm.onSearch(''),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 10.sp),
              sliver: vm.hasRes
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return buildByIndex(index).pOnly(bottom: 18.sp);
                      }, childCount: 3),
                    )
                  : SliverToBoxAdapter(
                      child: Center(
                        child: Empty(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
