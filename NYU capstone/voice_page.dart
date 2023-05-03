import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_theodolite/app_provider.dart';
import 'package:flutter_theodolite/login/login_router.dart';
import 'package:flutter_theodolite/pages/me/me_router.dart';
import 'package:flutter_theodolite/pages/voice/provider/voice_page.dart';
import 'package:flutter_theodolite/pages/voice/voice_router.dart';
import 'package:flutter_theodolite/pages/voice/widgets/voice_item_card.dart';
import 'package:flutter_theodolite/res/constant.dart';
import 'package:flutter_theodolite/router/fluro_navigator.dart';
import 'package:flutter_theodolite/util/device_utils.dart';
import 'package:flutter_theodolite/util/event.dart';
import 'package:flutter_theodolite/widgets/base_dialog.dart';
import 'package:flutter_theodolite/widgets/my_button.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:velocity_x/src/flutter/gesture.dart';
import 'package:velocity_x/src/flutter/text.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../main.dart';
import '../widgets/create_room_bottom_sheet.dart';
import '../../../res/colors.dart';
import '../../../res/gaps.dart';
import '../../../res/resources.dart';
import '../../../util/image_utils.dart';
import '../../../widgets/load_image.dart';
import '../../../widgets/main_app_bar.dart';
import '../../../widgets/my_card.dart';
import '../../../widgets/my_icontext_button.dart';
import '../../../widgets/my_scroll_view.dart';
import 'package:flutter_theodolite/widgets/empty.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({Key? key}) : super(key: key);

  @override
  _VoicePageState createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage>
    with AutomaticKeepAliveClientMixin {
  late VoicePageProvider _vm;
  late VoicePageProvider vm;
  late AppProvider app;
  late AppProvider _app;
  bool isVerify = false;
  late List<String> actions;
  late StreamSubscription _event;
  late StreamSubscription _event2;
  bool _loading = false;
  double voiceBottomIconSize = 32.sp;
  @override
  void initState() {
    super.initState();
    var timeStr = DateTime.now().toUtc().toIso8601String();

    print(timeStr);
    _app = Provider.of<AppProvider>(context, listen: false);
    _vm = Provider.of<VoicePageProvider>(context, listen: false);
    _vm.initContext(context);
    _vm.init(_app);
    _event = eventBus.on<DissmissRoom>().listen((event) {
      _vm.onRefresh();
    });
    _event2 = eventBus.on<ChangeLocale>().listen((event) {
      _vm.onRefresh();
    });

    // _app.updateUser(SpUtil.getObject(Constant.userInfo));
  }

  @override
  void dispose() {
    _event.cancel();
    _event2.cancel();

    super.dispose();
  }

  Widget buildLeft() {
    int _num = (app.room?.mike?.length ?? 0) +
        (app.room?.master?.length ?? 0) +
        (app.room?.user?.length ?? 0);
    print(_num);
    return Stack(
      // fit: StackFit.expand,
      children: [
        Container(
          // width: 100,
          height: 36.sp,
          padding: EdgeInsets.only(right: 50.sp),
          child: Container(
            width: 36.sp,
            height: 36.sp,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9.sp),
                border: Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 2.5.sp)),
                image: DecorationImage(
                    image: ImageUtils.getImageProvider(SpUtil.getString(
                            Constant.userAvatar) ??
                        'http://5b0988e595225.cdn.sohucs.com/images/20200114/7f502e286918439b9793e3dbeb44f692.jpeg'),
                    fit: BoxFit.cover)),
          ),
        ),
        Positioned(
          left: 25.sp,
          child: Container(
            width: 36.sp,
            height: 36.sp,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9.sp),
              border: Border.fromBorderSide(
                  BorderSide(color: Colours.app_main, width: 2.5.sp)),
            ),
            child: Center(
              child: Text('+$_num').text.black.make(),
            ),
          ),
        )
      ],
    );
  }

  Widget buildBottomMenus() {
    return app.room?.homeowner == 2
        ? Row(
            children: [
              Container(
                  width: 72.sp,
                  height: voiceBottomIconSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(voiceBottomIconSize),
                    border: Border.fromBorderSide(
                      BorderSide(color: Colours.app_main, width: 2.sp),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LoadAssetImage('icon/leave-black',
                              width: voiceBottomIconSize,
                              height: voiceBottomIconSize)
                          .onTap(() {
                        // NavigatorUtils.push(context,
                        //     '${VoiceRouter.inviteMembers}?id=${app.channelId.toString()}');
                        // app.leave();

                        app.leaveChannel(context);
                      }),
                      LoadAssetImage('icon/add_slim',
                              width: voiceBottomIconSize,
                              height: voiceBottomIconSize)
                          .onTap(() {
                        NavigatorUtils.push(context,
                            '${VoiceRouter.inviteMembers}?id=${app.channelId.toString()}');
                        // NavigatorUtils.push(context,
                        //     '${VoiceRouter.inviteMembers}?id=${app.channelId.toString()}');
                        // app.leave();
                      }),
                    ],
                  )),
              Gaps.hGap10,
              // LoadAssetImage('icon/leave-black', width: 36, height: 36)
              //     .onTap(() {
              //   // NavigatorUtils.push(context,
              //   //     '${VoiceRouter.inviteMembers}?id=${app.channelId.toString()}');
              //   // app.leave();
              // }),
              LoadAssetImage(app.room?.open == 2 ? 'icon/open' : 'icon/lock',
                      width: voiceBottomIconSize, height: voiceBottomIconSize)
                  .onTap(() {
                // 设置房间是否开放
                app.handleOpenRoom();
              }),

              // Gaps.hGap10,
              // // 邀请
              // LoadAssetImage('icon/voice_add', width: 36, height: 36).onTap(() {
              //   NavigatorUtils.push(context,
              //       '${VoiceRouter.inviteMembers}?id=${app.channelId.toString()}');
              // }),
              Gaps.hGap10,
              Stack(alignment: Alignment.topRight, children: [
                LoadAssetImage('icon/voice_list',
                        width: voiceBottomIconSize, height: voiceBottomIconSize)
                    .onTap(() {
                  // print(app。);
                  NavigatorUtils.push(
                      context, '${VoiceRouter.speakList}?id=${app.channelId}');
                }),
                app.isAskSpeak
                    ? Container(
                        width: 8.sp,
                        height: 8.sp,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8.sp)),
                      )
                    : Gaps.empty
              ]),
              Gaps.hGap10,
              LoadAssetImage(
                      app.isOpenMic ? 'icon/mc_speak' : 'icon/mc_unspeak',
                      width: voiceBottomIconSize,
                      height: voiceBottomIconSize)
                  .onTap(() {
                app.handleMyMic(!app.isOpenMic);
              }),
            ],
          )
        : Row(
            children: [
              Container(
                  width: 72.sp,
                  height: voiceBottomIconSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(voiceBottomIconSize),
                    border: Border.fromBorderSide(
                      BorderSide(color: Colours.app_main, width: 2.sp),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LoadAssetImage('icon/leave-black',
                              width: voiceBottomIconSize,
                              height: voiceBottomIconSize)
                          .onTap(() {
                        // NavigatorUtils.push(context,
                        //     '${VoiceRouter.inviteMembers}?id=${app.channelId.toString()}');
                        // app.leave();
                        if (app.room?.homeowner == 2) {
                          app.dismissRoom();
                        } else {
                          app.leaveChannel(context);
                        }
                      }),
                      LoadAssetImage('icon/add_slim',
                              width: voiceBottomIconSize,
                              height: voiceBottomIconSize)
                          .onTap(() {
                        NavigatorUtils.push(context,
                            '${VoiceRouter.inviteMembers}?id=${app.channelId.toString()}');
                        // NavigatorUtils.push(context,
                        //     '${VoiceRouter.inviteMembers}?id=${app.channelId.toString()}');
                        // app.leave();
                      }),
                    ],
                  )),
              // LoadAssetImage('icon/voice_add', width: 36, height: 36).onTap(() {
              //   NavigatorUtils.push(context,
              //       '${VoiceRouter.inviteMembers}?id=${app.channelId.toString()}');

              // }),
              Gaps.hGap10,

              app.role == ClientRoleType.clientRoleBroadcaster
                  ? LoadAssetImage(
                          app.isOpenMic ? 'icon/mc_speak' : 'icon/mc_unspeak',
                          width: voiceBottomIconSize,
                          height: voiceBottomIconSize)
                      .onTap(() {
                      app.handleMyMic(!app.isOpenMic);
                    })
                  : LoadAssetImage('icon/hand',
                          width: voiceBottomIconSize,
                          height: voiceBottomIconSize)
                      .onTap(() {
                      if (app.user['verification'] != null &&
                          app.user['verification']['email'] == 1) {
                        _app.askSpeak();
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return BaseDialog(
                                hiddenTitle: true,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 13.sp, vertical: 6.sp),
                                  child: Text(
                                    lang!.certificateTitle,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colours.icon_text_button,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                confirmText: lang!.certificateConfirm,
                                onPressed: () {
                                  Navigator.pop(context);
                                  NavigatorUtils.push(context,
                                      '${LoginRouter.emailAuthPage}?from=other');
                                  // Toast.show(
                                  //   lang!.certificateTitle,
                                  // );
                                  // vm.roomsOutRoomsUser(item);
                                },
                              );
                            });
                        // Toast.show(
                        //     lang?.certificateFirst ?? '');
                      }
                    }),
            ],
          );
  }

  Widget buildSchedules() {
    return Container(
        padding: EdgeInsets.only(bottom: 10.sp),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: vm.schedules.asMap().keys.map<Widget>((index) {
            var item = vm.schedules[index];
            return Container(
                margin: EdgeInsets.only(
                  right: index == vm.schedules.length - 1 ? 10.sp : 6.sp,
                  left: index == 0 ? 10.sp : 0,
                ),
                padding: EdgeInsets.fromLTRB(15.sp, 6.sp, 0, 6.sp),
                decoration: BoxDecoration(
                  color: Color(0XFFFFFFF7),
                  borderRadius: BorderRadius.circular(30.sp),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.sp, vertical: 2.sp),
                      margin: EdgeInsets.only(right: 5.sp),
                      decoration: BoxDecoration(
                          color: item['homeowner'] == 2
                              ? Colours.app_main
                              : Colours.gradient_blue,
                          borderRadius: BorderRadius.circular(4.sp)),
                      child: Text(
                              item['homeowner'] == 2
                                  ? lang!.master
                                  : lang!.subscription,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 6.sp))
                          .text
                          .make(),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: 500.sp),
                          child: Text(item["title"],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Text(
                            DateUtil.formatDateMs(item['begintime'] * 1000 ?? 0,
                                isUtc: false, format: 'yyyy-MM-dd HH:mm'),
                            style: TextStyle(
                                color: Colours.text_gray, fontSize: 7.sp))
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20.sp),
                      width: 40.sp,
                      height: 30.sp,
                      child:
                          Icon(Icons.clear, size: 20.sp, color: Colors.black12),
                    ).onTap(() {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return BaseDialog(
                              hiddenTitle: true,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0.sp, vertical: 8.0.sp),
                                child: Text(
                                  item["homeowner"] == 2
                                      ? lang!.confirmSchedule
                                      : lang!.confirmUnFollowRoom,
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Colours.icon_text_button,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              confirmText: lang!.confirm,
                              onPressed: () {
                                Navigator.pop(context);
                                vm.cancelSchedule(item);
                              },
                            );
                          });
                    }, hitTestBehavior: HitTestBehavior.opaque)
                  ],
                )).onTap(() {
              if (item["homeowner"] != 2) {
                return;
              }
              showDialog(
                  context: context,
                  builder: (context) {
                    return BaseDialog(
                      hiddenTitle: true,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0.sp, vertical: 8.0.sp),
                        child: Text(
                          lang!.startRoomNow,
                          style: TextStyle(
                              fontSize: 18.sp,
                              color: Colours.icon_text_button,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      confirmText: lang!.confirm,
                      onPressed: () {
                        Navigator.pop(context);
                        vm.startTheRoom(context, item);
                      },
                    );
                  });
            });
          }).toList()),
        ));
  }

  Widget buildChild(index) {
    if (vm.schedules.length > 0 && index == 0) {
      return buildSchedules();
    } else {
      int _index = index;
      if (vm.schedules.length > 0) {
        _index = index - 1;
      }
      return VoiceCard.fromVoiceRoom(vm.rooms[_index], () async {
        // Utils.throttle(() async {
        if (_loading) {
          return;
        }
        _loading = true;

        vm.chooseRoom(context, vm.rooms[_index].rooms);
        Future.delayed(Duration(milliseconds: 1500), () {
          _loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double appBarActionIcon = 23.sp;
    vm = context.watch<VoicePageProvider>();
    app = context.watch<AppProvider>();
    print(vm.rooms.length);
    print(app.user);
    actions = [
      app.user['verification'] != null && app.user['verification']['email'] == 1
          ? (app.user.isNotEmpty ? app.user['nickname'] : '')
          : lang!.emailAuthentication,
    ];
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
          vm.onRefresh();
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
            appBar: MainAppBar(
              isBorder: false,
              icon: Builder(builder: (context) {
                return Row(
                  children: [
                    InkWell(
                      child: LoadAssetImage(
                        'icon/search_black',
                        width: appBarActionIcon,
                      ),
                      onTap: () {
                        NavigatorUtils.push(context, VoiceRouter.search);
                      },
                    ),
                    Gaps.hGap24,
                    InkWell(
                      child: LoadAssetImage(
                        'icon/schedule',
                        width: appBarActionIcon,
                      ),
                      onTap: () {
                        NavigatorUtils.push(context, VoiceRouter.schedulePage);
                      },
                    )
                  ],
                );
              }),
              actions: [
                app.user['verification'] != null &&
                        app.user['verification']['email'] == 1
                    ? (app.user.isNotEmpty ? app.user['nickname'] : '')
                    : lang!.emailAuthentication,
              ],
              active: 0,
              onActionsPressed: (index) {
                if (app.user['verification'] != null &&
                    app.user['verification']['email'] == 1) {
                  return;
                }
                NavigatorUtils.push(
                    context, '${LoginRouter.emailAuthPage}?from=other');
              },
            ),
            body: Stack(children: [
              Padding(
                padding: app.user['verification'] != null &&
                        app.user['verification']['email'] == 1
                    ? EdgeInsets.only(bottom: Constant.bottomButton)
                    : EdgeInsets.zero,
                child: SmartRefresher(
                  enablePullUp: vm.hasMore ? true : false,
                  controller: vm.refreshController,
                  onRefresh: () => vm.onRefresh(),
                  onLoading: () => vm.getMore(),
                  footer: vm.rooms.length > 5
                      ? ClassicFooter()
                      : SliverToBoxAdapter(child: Gaps.empty),
                  child: CustomScrollView(
                    slivers: [
                      vm.rooms.length > 0 || vm.schedules.length > 0
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                              return buildChild(index);
                            },
                                  childCount: vm.schedules.length > 0
                                      ? vm.rooms.length + 1
                                      : vm.rooms.length))
                          : SliverToBoxAdapter(
                              child: Center(
                                child: Empty(),
                              ),
                            )
                    ],
                  ),
                ),
              ),
              app.channelId.isNotEmpty
                  ? Positioned(
                      bottom: 0,
                      child: Container(
                        width: Device.windowWidth,
                        height: Constant.bottomButton,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFF7),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Color.fromRGBO(241, 239, 227, 0.5),
                                offset: const Offset(0.0, 2.0),
                                blurRadius: 8.0,
                                spreadRadius: 0.0),
                          ],
                          borderRadius: new BorderRadius.only(
                              topLeft: Radius.circular(25.sp),
                              topRight: Radius.circular(25.sp)),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.sp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildLeft().onTap(() {
                                NavigatorUtils.push(context,
                                    '${VoiceRouter.voiceRoomDetail}?id=${app.channelId}');
                              }),
                              buildBottomMenus()
                            ],
                          ),
                        ),
                      ),
                    )
                  : Positioned(
                      bottom: 0,
                      child: Container(
                        width: Device.windowWidth,
                        height: Constant.bottomButton,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFF7),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Color.fromRGBO(241, 239, 227, 0.5),
                                offset: const Offset(0.0, 2.0),
                                blurRadius: 8.0.sp,
                                spreadRadius: 0.0),
                          ],
                          borderRadius: new BorderRadius.only(
                              topLeft: Radius.circular(25.sp),
                              topRight: Radius.circular(25.sp)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyIconTextButton(
                              onTap: () {
                                Map? _user =
                                    SpUtil.getObject(Constant.userInfo);
                                if (!(_user?['verification'] != null &&
                                    _user?['verification']['email'] == 1)) {
                                  showDialog<void>(
                                      context: context,
                                      builder: (_) => BaseDialog(
                                            hiddenTitle: true,
                                            // title: '结束会议',
                                            cancelText: lang?.cancel ?? "",
                                            confirmText:
                                                lang?.certificate ?? "",
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.0.sp,
                                                  vertical: 8.0.sp),
                                              child: Text(
                                                lang?.certificateFirst ?? "",
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colours
                                                        .icon_text_button,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(_);
                                              NavigatorUtils.push(context,
                                                  '${LoginRouter.emailAuthPage}?from=other');
                                            },
                                          ));
                                  return;
                                } else {
                                  _openModalBottomSheet(context);
                                  return;
                                }
                              },
                              image: LoadAssetImage(
                                'icon/add_black',
                                height: 12.0.sp,
                              ),
                              textColor: Colours.icon_text_button,
                              borderColor: Colours.app_main,
                              bgColor: Colors.transparent,
                              title: lang!.creatVoiceRoomTitle,
                            )
                          ],
                        ),
                      ),
                    ),
            ])));
  }

  // 创建语音房弹窗
  void _openModalBottomSheet(_context) {
    showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        //构建弹框中的内容
        return CreateVoiceSheet(
            vm: vm, onSuccess: () => vm.createRoom(_context));
      },
      context: context,
      isDismissible: true, //外部不可以点击
      shape: RoundedRectangleBorder(
        //这里是modal的边框样式
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.sp),
          topRight: Radius.circular(16.sp),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
