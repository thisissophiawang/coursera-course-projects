import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_theodolite/app_provider.dart';
import 'package:flutter_theodolite/login/login_router.dart';
import 'package:flutter_theodolite/model/voice_room.dart';
import 'package:flutter_theodolite/pages/me/me_router.dart';
import 'package:flutter_theodolite/pages/user/user_router.dart';
import 'package:flutter_theodolite/pages/voice/provider/voice_room_detail.dart';
import 'package:flutter_theodolite/pages/voice/voice_router.dart';
import 'package:flutter_theodolite/res/constant.dart';
import 'package:flutter_theodolite/res/resources.dart';
import 'package:flutter_theodolite/router/fluro_navigator.dart';
import 'package:flutter_theodolite/util/device_utils.dart';
import 'package:flutter_theodolite/util/event.dart';
import 'package:flutter_theodolite/util/image_utils.dart';
import 'package:flutter_theodolite/util/navigation.dart';
import 'package:flutter_theodolite/util/other_utils.dart';
import 'package:flutter_theodolite/util/toast_utils.dart';
import 'package:flutter_theodolite/util/wxPayUtil.dart';
import 'package:flutter_theodolite/widgets/action_sheet.dart';
import 'package:flutter_theodolite/widgets/base_dialog.dart';
import 'package:flutter_theodolite/widgets/gift_modal.dart';
import 'package:flutter_theodolite/widgets/load_image.dart';
import 'package:flutter_theodolite/widgets/my_app_bar.dart';
import 'package:flutter_theodolite/widgets/report_bottom_sheet.dart';
import 'package:flutter_theodolite/widgets/share_widget.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../../../main.dart';

class VoiceRoomDetail extends StatefulWidget {
  VoiceRoomDetail({
    Key? key,
  }) : super(key: key);

  @override
  _VoiceRoomDetailState createState() => _VoiceRoomDetailState();
}

class _VoiceRoomDetailState extends State<VoiceRoomDetail> {
  late VoiceRoomDetailProvider _vm;
  late VoiceRoomDetailProvider vm;

  late AppProvider app;
  late AppProvider _app;

  late StreamSubscription _event;
  late StreamSubscription _attributeEvent;
  late StreamSubscription _updateEvent;
  double voiceBottomIconSize = 32.sp;

  @override
  void initState() {
    // TODO: implement initState

    _vm = Provider.of<VoiceRoomDetailProvider>(context, listen: false);
    _app = Provider.of<AppProvider>(context, listen: false);

    _vm.init(_app);

    _event = eventBus.on<SetUserMike>().listen((event) {
      vm.setMike(event.mike ?? 0);
    });
    _attributeEvent = eventBus.on<RefreshRewardList>().listen((event) {
      vm.getRewardList(event.attributes);
    });
    _updateEvent = eventBus.on<UpdateRoomTitle>().listen((event) {
      _app.sendChangeTitle();
      vm.getDetail(isInitRTC: false);
    });
    super.initState();
  }

  @override
  void dispose() {
    _event.cancel();
    _updateEvent.cancel();
    _attributeEvent.cancel();
    vm.destory();

    super.dispose();
  }

  void _openModalBottomSheet() {
    //用于在底部打开弹框的效果
    showModalBottomSheet(
      // useRootNavigator: true,
      builder: (BuildContext context) {
        //构建弹框中的内容
        return buildBottomSheetWidget(context);
      },
      routeSettings: RouteSettings(name: 'voiceRoomModal'),
      isScrollControlled: true,
      context: context,
      isDismissible: true,
      //外部不可以点击
      shape: RoundedRectangleBorder(
        //这里是modal的边框样式
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14.sp),
          topRight: Radius.circular(14.sp),
        ),
      ),
    );
  }

  Widget buildBottomSheetWidget(BuildContext context) {
    return Container(
        height: 250.sp,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
          child: Column(
            children: [
              InkWell(
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.sp, vertical: 6.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            lang!.share,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colours.icon_text_button,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                onTap: () {},
              ),
              Gaps.vGap5,
              Gaps.hLine,
              Gaps.vGap24,
              ShareWidget.buildShare(
                onWeChat: () {
                  /// 分享到好友
                  WxPayUtil.weChatShareWebPage({
                    'url': "http://www.jwcirclenet.com" +
                        '/h5/index.html#/?room=${vm.id}&from=room',
                    'description': lang!.userShareDesc,
                    'title': vm.room.title ?? '',
                    'image': ''
                  }, fluwx.WeChatScene.SESSION);
                },
                onTimeLine: () {
                  // 分享到朋友圈
                  print(app.channelId);
                  print(Constant.baseUrl +
                      '/h5/index.html?room=${app.channelId}');
                  WxPayUtil.weChatShareWebPage({
                    'url': Constant.baseUrl +
                        '/h5/index.html?room=${app.channelId}',
                    'description': lang!.voiceShareDesc,
                    'title': app.room?.title ?? '',
                    'image': app.room?.master![0].avatar ?? ''
                  }, fluwx.WeChatScene.TIMELINE);
                },
                onOnSiteFriends: () {
                  String? cover;
                  print(vm.room.rooms);
                  if (vm.master[0].avatar != null) {
                    cover = Uri.encodeComponent(vm.master[0].avatar ?? '');
                  }
                  String title = Uri.encodeComponent(app.room?.title ?? '');

                  final nickname = vm.master.first.nickname ?? '';

                  String subtitle = Uri.encodeComponent(
                      // '来自${_vm.postsDetail.nickname ?? "匿名"}的新鲜事'
                      lang?.voiceRoomFromUser(nickname) ?? '');
                  NavigatorUtils.push(
                    context,
                    '${MeRouter.shareFriendPage}?refPath=room&ref=${vm.id}&cover=$cover&title=$title&subtitle=$subtitle',
                  );
                  // NavigatorUtils.push(context,
                  //     '${VoiceRouter.inviteMembers}?id=${vm.id.toString()}');
                },
                onCopyLink: () {
                  Utils.copyData(Constant.baseUrl +
                      '/h5/index.html#/?room=${vm.id}&from=room');
                },
              ),
              Gaps.vGap32,
              Gaps.vGap12,
              InkWell(
                child: LoadAssetImage(
                  'icon/close',
                  width: 18.sp,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ));
  }

  Widget buildUserItem(
      {required RoomUser item, double? size, bool checkSpeak = false}) {
    int uid = item.userId ?? 0;

    int myId = SpUtil.getInt(Constant.userId) ?? 0;
    if (myId == uid) {
      uid = 0;
    }

    double _size = size ?? 58.sp;
    double _radius = 13.sp;

    return Container(
        constraints: BoxConstraints(
          maxWidth: (Device.windowWidth.sp - 24.sp) / (_size > 60.sp ? 3 : 4),
          // minWidth: (Device.windowWidth - 24) / (_size > 60 ? 3 : 4),
        ),
        // width:
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.5.sp),
                  child: Container(
                      width: _size + 2.sp,
                      height: _size + 2.sp,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: checkSpeak
                                ? Colours.app_main
                                : Colors.transparent,
                            width: 2.sp),
                        borderRadius: BorderRadius.circular(_radius + 2.sp),
                      ),
                      child: Container(
                        width: _size,
                        height: _size,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colours.bg_gray, width: 2.sp),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: ImageUtils.getImageProvider(
                              item.avatar,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(_radius),
                        ),
                      )),
                ),
                Positioned(
                  width: (_size + 2.sp) / 2,
                  height: (_size + 2.sp) / 2,
                  bottom: 0,
                  right: 0,
                  child: checkSpeak
                      ? item.mike != null && item.mike == 2
                          ? LoadAssetImage('icon/speak',
                              width: (_size + 2.sp) / 2,
                              height: (_size + 2.sp) / 2)
                          : LoadAssetImage('icon/unspeak',
                              width: (_size + 2.sp) / 2,
                              height: (_size + 2.sp) / 2)
                      : Container(),
                )
              ],
            ),
            Gaps.vGap5,
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                  child: Text(item.nickname ?? '')
                      .text
                      .size(8.sp)
                      .black
                      .center
                      .overflow(TextOverflow.ellipsis)
                      .fontWeight(FontWeight.w600)
                      .make())
            ])
          ],
        )).onTap(() {
      showModalBottomSheet(
        isScrollControlled: true,
        builder: (BuildContext _context) {
          //构建弹框中的内容
          return KeyboardDismissOnTap(child: buildUserAction(_context, item));
        },

        context: context,
        routeSettings: RouteSettings(name: 'voiceRoomModal'),
        isDismissible: true,
        //外部不可以点击
        useRootNavigator: true,
        shape: RoundedRectangleBorder(
          //这里是modal的边框样式
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_radius + 1),
            topRight: Radius.circular(_radius + 1),
          ),
        ),
      );
    });
  }

  Widget buildUserAction(context, RoomUser item) {
    ActionSheetItem _noSpeaking = ActionSheetItem(
        isBorder: true,
        textColor: Colors.black,
        title: lang!.notalking,
        onTap: () async {
          vm.handleSpeaking(item.userId ?? 0);
          Navigator.pop(context);
        });
    ActionSheetItem _homeowner = ActionSheetItem(
      isBorder: true,
      textColor: Colors.red,
      title: lang!.kick,
      onTap: () async {
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (_context) {
              return BaseDialog(
                hiddenTitle: true,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.sp, vertical: 6.sp),
                  child: Text(
                    lang!.kickHint,
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: Colours.icon_text_button,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                onPressed: () {
                  Toast.show(
                    lang!.kickSuccess,
                  );
                  vm.roomsOutRoomsUser(item);

                  Navigator.pop(_context);
                },
              );
            });
        // var res = await showOkCancelAlertDialog(
        //   context: context,
        //   title: '提示',
        //   message: '是否踢出该听众',
        // );
        // if (res == OkCancelResult.ok) {
        //   vm.roomsOutRoomsUser(item);
        //   Navigator.pop(context);
        // }
      },
    );
    List<ActionSheetItem> actions = [
      ActionSheetItem(
        isBorder: true,
        title: lang!.reward,
        onTap: () {
          Navigator.pop(context);
          showGiftModal(context, item);
        },
      ),
      ActionSheetItem(
        isBorder: true,
        title: lang!.homepage,
        onTap: () {
          // _vm.chooseMode(1);
          Navigator.pop(context);
          NavigatorUtils.push(context,
              '${UserRouter.userPage}?userID=${item.userId.toString()}');
        },
      ),
      ActionSheetItem(
        isBorder: true,
        title: lang!.report,
        onTap: () {
          _openReportModalBottomSheet(context, item.userId);
          // Navigator.pop(context);
        },
      ),
      ActionSheetItem(
        isBorder: false,
        title: lang!.cancel,
        textColor: Colours.text_gray,
        onTap: () {
          Navigator.pop(context);
        },
      ),
    ];
    if (app.room?.homeowner == 2) {
      if (app.room!.mike!.length > 0 &&
          (app.room!.mike!.indexWhere(
                      (element) => element.userId == item.userId) >=
                  0 ||
              app.room!.master!.indexWhere(
                      (element) => element.userId == item.userId) >=
                  0) &&
          item.userId.toString() != app.user['id'].toString()) {
        actions.insert(0, _noSpeaking);
      }
      // 只有房主能踢人 （不包含自己）
      if (app.room?.homeowner == 2 &&
          item.userId.toString() != app.user['id'].toString()) {
        actions.insert(0, _homeowner);
      }
    }
    return BottomActionSheet(
      actions: actions,
      context: context,
    );
  }

  void _openReportModalBottomSheet(context, userId) {
    Navigator.pop(context);
    //用于在底部打开弹框的效果
    showModalBottomSheet(
      isScrollControlled: true,
      builder: (BuildContext context) {
        //构建弹框中的内容
        return ReportBottomSheet(id: userId, type: 'user');
      },
      context: context,
      routeSettings: RouteSettings(name: 'voiceRoomModal'),
      isDismissible: true,
      //外部不可以点击
      shape: RoundedRectangleBorder(
        //这里是modal的边框样式
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14.sp),
          topRight: Radius.circular(14.sp),
        ),
      ),
    );
  }

  showGiftModal(context,RoomUser item) {
    print('roomId===${vm.id}');
    showModalBottomSheet(
      isScrollControlled: true,
      builder: (BuildContext context) {
        //构建弹框中的内容
        return Container(
            height: 490.sp,
            child: KeyboardDismissOnTap(
                child: GiftModal(
              type: 'room',
              user: item,
              id: int.tryParse(vm.id ?? '') ?? 0,
              sendEvent: (val) => vm.sendEvent(val, item),
            )));
      },
      context: context,
      routeSettings: RouteSettings(name: 'voiceRoomModal'),
      isDismissible: true,
      //外部不可以点击
      shape: RoundedRectangleBorder(
        //这里是modal的边框样式
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14.sp),
          topRight: Radius.circular(14.sp),
        ),
      ),
    );
  }

  Widget buildAnimationText() {
    return Container(
      height: 38.sp,
      child: DefaultTextStyle(
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 13.sp,
          ),
          child: vm.rewards.length > 0
              ? AnimatedTextKit(
                  pause: Duration(milliseconds: 0),
                  repeatForever: false,
                  isRepeatingAnimation: false,
                  onFinished: () {
                    vm.clearRewards();
                  },
                  animatedTexts: vm.rewards.map((item) {
                    return RotateAnimatedText("🎉${item['value']}",
                        alignment: Alignment.centerLeft,
                        duration: Duration(milliseconds: 5000));
                  }).toList())
              : Text('${lang!.rewardHint}🎉').text.make()),
    );
  }

  buildEmailDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return BaseDialog(
            hiddenTitle: true,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 6.sp),
              child: Text(
                lang!.certificateTitle,
                style: TextStyle(
                    fontSize: 16.sp,
                    color: Colours.icon_text_button,
                    fontWeight: FontWeight.w600),
              ),
            ),
            confirmText: lang!.certificateConfirm,
            onPressed: () {
              Navigator.pop(context);
              NavigatorUtils.push(
                  context, '${LoginRouter.emailAuthPage}?from=other');
              // Toast.show(
              //   lang!.certificateTitle,
              // );
              // vm.roomsOutRoomsUser(item);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _vm.initContext(context);
    vm = context.watch<VoiceRoomDetailProvider>();
    app = context.watch<AppProvider>();

    return FocusDetector(
      onFocusLost: () {
        app.isInRoomDetailId = 0;
        // 离开页面2
        print(
          'Focus Lost.'
          '\nTriggered when either [onVisibilityLost] or [onForegroundLost] '
          'is called.'
          '\nEquivalent to onPause() on Android or viewDidDisappear() on iOS.',
        );
      },
      onFocusGained: () {
        // 进入页面1
        if (app.channelId.isEmptyOrNull) {
          Navigator.pop(context);
        }
        print(
          'Focus Gained.'
          '\nTriggered when either [onVisibilityGained] or [onForegroundGained] '
          'is called.'
          '\nEquivalent to onResume() on Android or viewDidAppear() on iOS.',
        );
      },
      onVisibilityLost: () {
        // 离开页面1

        print(
          'Visibility Lost.'
          '\nIt means the widget is no longer visible within your app.',
        );
      },
      onVisibilityGained: () {
        // 进入页面2
        print(
          'Visibility Gained.'
          '\nIt means the widget is now visible within your app.',
        );
      },
      onForegroundLost: () {
        print(
          'Foreground Lost.'
          '\nIt means, for example, that the user sent your app to the background by opening '
          'another app or turned off the device\'s screen while your '
          'widget was visible.',
        );
      },
      onForegroundGained: () {
        print(
          'Foreground Gained.'
          '\nIt means, for example, that the user switched back to your app or turned the '
          'device\'s screen back on while your widget was visible.',
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MyAppBar(
          backTitle: lang!.allRooms,
          isActions: true,
          actions: Row(
            children: [
              TextButton(
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(48.sp, 48.sp)),
                    maximumSize: MaterialStateProperty.all(Size(48.sp, 48.sp)),
                    padding: MaterialStateProperty.all(EdgeInsets.all(0))),
                onPressed: () {
                  NavigatorUtils.push(context, VoiceRouter.voicePlatformRule);
                },
                child: LoadAssetImage(
                  'icon/rule',
                  width: 22.sp,
                  height: 22.sp,
                ),
              ),
              TextButton(
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(48.sp, 48.sp)),
                    maximumSize: MaterialStateProperty.all(Size(48.sp, 48.sp)),
                    padding: MaterialStateProperty.all(EdgeInsets.all(0))),
                onPressed: () {
                  _openModalBottomSheet();
                },
                child: LoadAssetImage(
                  'icon/share',
                  width: 22.sp,
                  height: 22.sp,
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(
                    Dimens.gap_dp12, 0, Dimens.gap_dp12, 48.sp),
                child: SmartRefresher(
                  enablePullDown: false,
                  controller: vm.refreshController,
                  child: CustomScrollView(
                    slivers: [
                      app.room != null && app.room!.rooms.toString().isNotEmpty
                          ?
                          // app.room!.rooms.toString().isNotEmpty
                          SliverToBoxAdapter(
                              child: Container(
                                width: double.infinity,
                                padding:
                                    EdgeInsets.fromLTRB(22.sp, 27.sp, 22.sp, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //头部
                                    [
                                      buildAnimationText().expand(),
                                      [
                                        app.room != null &&
                                                app.role ==
                                                    ClientRoleType.clientRoleBroadcaster
                                            ? LoadAssetImage(
                                                    'icon/search_black',
                                                    width: 22.sp,
                                                    height: 22.sp)
                                                .onTap(() {
                                                NavigatorUtils.push(context,
                                                    '${VoiceRouter.searchMembers}?id=${vm.id.toString()}');
                                              })
                                            : Container(),
                                        Gaps.hGap12,
                                        [
                                          lang!.roomRule.text
                                              .size(12.sp)
                                              .fontWeight(FontWeight.w600)
                                              .black
                                              .make(),
                                          LoadAssetImage(
                                            'icon/roomRules',
                                            width: 22.sp,
                                            height: 22.sp,
                                          )
                                        ]
                                            .hStack(axisSize: MainAxisSize.max)
                                            .onTap(() {
                                          NavigatorUtils.push(context,
                                              '${VoiceRouter.roomRules}?id=${vm.id.toString()}&homeowner=${app.room!.homeowner.toString()}');
                                        }),
                                      ].hStack(),
                                    ]
                                        .hStack(
                                            alignment:
                                                MainAxisAlignment.spaceBetween,
                                            axisSize: MainAxisSize.max)
                                        .pLTRB(0, 0, 0, 15.sp)
                                        .box
                                        .withDecoration(BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colours.line))))
                                        .make(),
                                    //头部结束

                                    // 主持人
                                    [
                                      RichText(
                                          text: TextSpan(
                                              text: app.room?.title ?? '',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              children: [
                                            WidgetSpan(
                                                child: app.room != null &&
                                                        app.room!.homeowner == 2
                                                    ? LoadAssetImage(
                                                            'icon/edit_line',
                                                            width: 18.sp,
                                                            height: 18.sp,
                                                            color: Colours
                                                                .text_gray_c)
                                                        .pOnly(left: 3.sp)
                                                        .onTap(() {
                                                        NavigatorUtils.push(
                                                            context,
                                                            '${VoiceRouter.editTitle}?id=${vm.id.toString()}&homeowner=${app.room!.homeowner.toString()}&title=${Uri.encodeComponent(app.room?.title ?? '')}');
                                                      })
                                                    : Gaps.empty)
                                          ])).pOnly(
                                          right: 0,
                                          left: 0,
                                          top: 22.sp,
                                          bottom: 15.sp),
                                      app.masters.length > 0
                                          ? Container(
                                              height: 114,
                                              child: GridView.count(
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  crossAxisCount: 3,
                                                  mainAxisSpacing: 3.sp,
                                                  crossAxisSpacing: 2.sp,
                                                  childAspectRatio: 1.0 / 1.3,
                                                  children:
                                                      app.masters.map((item) {
                                                    return buildUserItem(
                                                        size: 64.sp,
                                                        checkSpeak: true,
                                                        item: item);
                                                  }).toList()),
                                            )
                                          : Container()
                                    ]
                                        .vStack(
                                            crossAlignment:
                                                CrossAxisAlignment.start)
                                        .box
                                        .margin(EdgeInsets.only(
                                            top: 0, bottom: 15.sp))
                                        .make(),
                                    // 主持人结束
                                    // 听众
                                    app.mikes.length > 0
                                        ? [
                                            lang!.audienceSpeakers.text
                                                .size(12.sp)
                                                .color(Colours.text_gray_c)
                                                .make(),
                                            Gaps.vGap5,
                                            Container(
                                              height: 114,
                                              child: GridView.count(
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  crossAxisCount: 3,
                                                  mainAxisSpacing: 3.sp,
                                                  crossAxisSpacing: 2.sp,
                                                  childAspectRatio: 1.0 / 1.3,
                                                  children:
                                                      app.mikes.map((item) {
                                                    return buildUserItem(
                                                        checkSpeak: true,
                                                        // canSpeak: true,
                                                        item: item);
                                                  }).toList()),
                                            )
                                          ]
                                            .vStack(
                                                crossAlignment:
                                                    CrossAxisAlignment.start)
                                            .pOnly(bottom: 15.sp)
                                        : Container(),
                                    // 听众结束
                                    // 吃瓜群众
                                    app.users.length > 0
                                        ? [
                                            lang!.audiences.text
                                                .size(12.sp)
                                                .color(Colours.text_gray_c)
                                                .make(),
                                            Gaps.vGap5,
                                            Container(
                                              height: 114,
                                              child: GridView.count(
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  crossAxisCount: 3,
                                                  mainAxisSpacing: 5.0,
                                                  crossAxisSpacing: 4.0,
                                                  childAspectRatio: 1.0 / 1.3,
                                                  children:
                                                      app.users.map((item) {
                                                    return buildUserItem(
                                                        checkSpeak: false,
                                                        item: item);
                                                  }).toList()),
                                            )
                                          ]
                                            .vStack(
                                                crossAlignment:
                                                    CrossAxisAlignment.start)
                                            .pOnly(bottom: 15.sp)
                                        : Container()
                                    // 群众结束
                                  ],
                                ),
                              ).box.white.roundedLg.make(),
                            )
                          : Container().sliverToBoxAdapter()
                    ],
                  ),
                )),

            // 底部按钮

            Positioned(
              bottom: 0,
              child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFF7),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Color.fromRGBO(241, 239, 227, 0.5),
                          offset: const Offset(0.0, 2.0),
                          blurRadius: 6.sp,
                          spreadRadius: 0.0),
                    ],
                    borderRadius: new BorderRadius.only(
                        topLeft: Radius.circular(22.sp),
                        topRight: Radius.circular(22.sp)),
                  ),
                  padding: EdgeInsets.only(bottom: Device.bottomOffset),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(22.sp, 0, 22.sp, 0),
                    width: Device.windowWidth,
                    height: Constant.bottomButton,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 34.sp,
                          padding: EdgeInsets.symmetric(horizontal: 10.sp),
                          decoration: BoxDecoration(
                            color: Color(0xFFBDBDBD),
                            borderRadius: BorderRadius.circular(16.sp),
                          ),
                          child: Row(
                            children: [
                              LoadAssetImage('icon/leave-white',
                                  width: 28.sp, height: 28.sp),
                              Text(app.room != null && app.room!.homeowner == 2
                                      ? lang!.dismissRoom
                                      : lang!.leaveRoom)
                                  .text
                                  .white
                                  .size(14.sp)
                                  .make()
                            ],
                          ),
                        )
                            .onTap(() {
                              if (app.channelId.isEmpty) {
                                Navigator.pop(nav.currentContext);
                                return;
                              }
                              if (app.room != null &&
                                  app.room!.homeowner == 2) {
                                showDialog(
                                    context: context,
                                    builder: (_context) {
                                      return BaseDialog(
                                        hiddenTitle: true,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 14.sp,
                                              vertical: 6.sp),
                                          child: Text(
                                            lang?.leaveMasterHint ?? "",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colours.icon_text_button,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(_context);
                                          app.dismissRoom();
                                        },
                                      );
                                    });
                              } else {
                                app.leaveChannel(context);
                              }
                            })
                            .box
                            .width(138.sp)
                            .make(),
                        app.role == ClientRoleType.clientRoleBroadcaster &&
                                (app.room?.homeowner == 2)
                            ? Row(
                                children: [
                                  LoadAssetImage(
                                          app.room?.open == 2
                                              ? 'icon/open'
                                              : 'icon/lock',
                                          width: voiceBottomIconSize,
                                          height: voiceBottomIconSize)
                                      .onTap(() {
                                    // 设置房间是否开放
                                    app.handleOpenRoom();
                                  }),
                                  Gaps.hGap10,
                                  // 邀请
                                  LoadAssetImage('icon/voice_add',
                                          width: voiceBottomIconSize,
                                          height: voiceBottomIconSize)
                                      .onTap(() {
                                    NavigatorUtils.push(context,
                                        '${VoiceRouter.inviteMembers}?id=${vm.id.toString()}');
                                  }),
                                  Gaps.hGap10,

                                  Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        LoadAssetImage('icon/voice_list',
                                                width: voiceBottomIconSize,
                                                height: voiceBottomIconSize)
                                            .onTap(() {
                                          NavigatorUtils.push(context,
                                              '${VoiceRouter.speakList}?id=${vm.id.toString()}');
                                        }),
                                        app.isAskSpeak
                                            ? Container(
                                                width: 6.sp,
                                                height: 6.sp,
                                                decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.sp)),
                                              )
                                            : Gaps.empty
                                      ]),

                                  Gaps.hGap10,
                                  LoadAssetImage(
                                          app.isOpenMic
                                              ? 'icon/mc_speak'
                                              : 'icon/mc_unspeak',
                                          width: voiceBottomIconSize,
                                          height: voiceBottomIconSize)
                                      .onTap(() {
                                    if (app.user['verification'] != null &&
                                        app.user['verification']['email'] ==
                                            1) {
                                      app.handleMyMic(!app.isOpenMic);
                                    } else {
                                      buildEmailDialog(context);
                                    }
                                  }),
                                ],
                              )
                            : Row(
                                children: [
                                  LoadAssetImage('icon/voice_add',
                                          width: voiceBottomIconSize,
                                          height: voiceBottomIconSize)
                                      .onTap(() {
                                    NavigatorUtils.push(context,
                                        '${VoiceRouter.inviteMembers}?id=${vm.id.toString()}');

                                    // VxDialog.showConfirmation(context,
                                    //     title: '提示',
                                    //     content: '是否加入该房间', onConfirmPress: () {
                                    //   // Navigator.of(context).pop();
                                    //   Toast.show('加入成功');
                                    // }, onCancelPress: () {});
                                    // var result = await showOkCancelAlertDialog(
                                    //   context: context,
                                    //   // useRootNavigator: true,
                                    //   title: '提示',
                                    //   message: '是否加入该房间',
                                    // );
                                    // if (result == OkCancelResult.ok) {

                                    // Navigator.pop(context);
                                    // }
                                  }),
                                  Gaps.hGap10,
                                  app.role == ClientRoleType.clientRoleBroadcaster
                                      ? LoadAssetImage(
                                              app.isOpenMic
                                                  ? 'icon/mc_speak'
                                                  : 'icon/mc_unspeak',
                                              width: voiceBottomIconSize,
                                              height: voiceBottomIconSize)
                                          .onTap(() {
                                          if (app.user['verification'] !=
                                                  null &&
                                              app.user['verification']
                                                      ['email'] ==
                                                  1) {
                                            app.handleMyMic(!app.isOpenMic);
                                          } else {
                                            buildEmailDialog(context);
                                          }
                                        })
                                      : LoadAssetImage('icon/hand',
                                              width: voiceBottomIconSize,
                                              height: voiceBottomIconSize)
                                          .onTap(() {
                                          if (app.user['verification'] !=
                                                  null &&
                                              app.user['verification']
                                                      ['email'] ==
                                                  1) {
                                            _vm.askSpeak();
                                          } else {
                                            buildEmailDialog(context);
                                            // Toast.show(
                                            //     lang?.certificateFirst ?? '');
                                          }
                                        }),
                                ],
                              )
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
