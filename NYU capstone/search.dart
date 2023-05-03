import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:flutter_theodolite/app_provider.dart';
import 'package:flutter_theodolite/pages/voice/provider/search.dart';
import 'package:flutter_theodolite/pages/voice/voice_router.dart';
import 'package:flutter_theodolite/pages/voice/widgets/voice_item_card.dart';
import 'package:flutter_theodolite/res/resources.dart';
import 'package:flutter_theodolite/router/fluro_navigator.dart';
import 'package:flutter_theodolite/util/toast_utils.dart';
import 'package:flutter_theodolite/widgets/my_app_bar.dart';
import 'package:flutter_theodolite/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:velocity_x/src/extensions/string_ext.dart';
import 'package:flutter_theodolite/widgets/empty.dart';

import '../../../main.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchProvider _vm;
  late SearchProvider vm;

  @override
  void initState() {
    _vm = Provider.of<SearchProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    vm = context.watch<SearchProvider>();
    return Scaffold(
      appBar: MyAppBar(centerTitle: lang!.search),
      body: SmartRefresher(
        enablePullUp: true,
        onRefresh: () => _vm.onRefresh(),
        onLoading: () => _vm.getMore(),
        footer: vm.result.length > 5
            ? ClassicFooter()
            : SliverToBoxAdapter(child: Gaps.empty),
        controller: vm.refreshController,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.sp, 0, 10.sp, 10.sp),
                child: SearchBar(
                  hintText: lang!.voiceRoomTitleHint,
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
            vm.result.length > 0
                ? SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: Dimens.gap_dp12),
                        child: VoiceCard.fromVoiceRoom(vm.result[index], () {
                          NavigatorUtils.push(context,
                              '${VoiceRouter.voiceRoomDetail}?id=${vm.result[index].rooms.toString()}');
                        }));
                  }, childCount: vm.result.length))
                : SliverToBoxAdapter(
                    child: Center(
                      child: Empty(),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
