import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:flutter_theodolite/app_provider.dart';
import 'package:flutter_theodolite/pages/voice/provider/speak_list.dart';
import 'package:flutter_theodolite/res/resources.dart';
import 'package:flutter_theodolite/util/event.dart';
import 'package:flutter_theodolite/util/image_utils.dart';
import 'package:flutter_theodolite/util/toast_utils.dart';
import 'package:flutter_theodolite/widgets/load_image.dart';
import 'package:flutter_theodolite/widgets/my_app_bar.dart';
import 'package:flutter_theodolite/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_theodolite/widgets/empty.dart';

import '../../../main.dart';

class SpeakList extends StatefulWidget {
  SpeakList({Key? key}) : super(key: key);

  @override
  _SpeakListState createState() => _SpeakListState();
}

class _SpeakListState extends State<SpeakList> {
  late SpeakListProvider _vm;
  late SpeakListProvider vm;

  @override
  void initState() {
    super.initState();
    _vm = Provider.of<SpeakListProvider>(context, listen: false);

    _vm.init();
    super.initState();
  }

  buildMember(index, user) {
    return Container(
        padding: EdgeInsets.fromLTRB(10.sp, index == 0 ? 10.sp : 6, 10.sp,
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
            Expanded(
              child: Row(
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
                  Expanded(
                      child: Text(user['nickname'])
                          .text
                          .size(14.sp)
                          .black
                          .overflow(TextOverflow.ellipsis)
                          .make()),
                ],
              ),
            ),
            Row(
              children: [
                LoadAssetImage(
                  'icon/refuse',
                  width: 31.sp,
                  height: 31.sp,
                ).onTap(() {
                  // eventBus.fire(SetUserMike(user['mike']));
                  vm.roomsExamineUserMike(context, user, 3);
                }),
                Gaps.hGap16,
                LoadAssetImage(
                  'icon/accept',
                  width: 31.sp,
                  height: 31.sp,
                ).onTap(() {
                  vm.roomsExamineUserMike(context, user, 2);
                })
              ],
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    vm = context.watch<SpeakListProvider>();

    return Scaffold(
        appBar: MyAppBar(centerTitle: lang!.askSpeaks),
        body: SmartRefresher(
          enablePullUp: true,
          controller: vm.refreshController,
          onLoading: () => _vm.getMore(),
          onRefresh: () => _vm.onRefresh(),
          footer: vm.users.length > 5
              ? ClassicFooter()
              : SliverToBoxAdapter(child: Gaps.empty),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.sp, 0, 10.sp, 10.sp),
                  child: SearchBar(
                    hintText: lang!.search,
                    onPressed: (value) {
                      if (value.isEmpty) {
                        Toast.show(lang!.searchHint);
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
