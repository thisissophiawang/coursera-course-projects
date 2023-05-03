import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:flutter_theodolite/model/voice_room.dart';
import 'package:flutter_theodolite/net/dio_utils.dart';
import 'package:flutter_theodolite/network/http_api.dart';
import 'package:flutter_theodolite/pages/me/models/user_entity.dart';
import 'package:flutter_theodolite/res/colors.dart';
import 'package:flutter_theodolite/res/gaps.dart';
import 'package:flutter_theodolite/res/resources.dart';
import 'package:flutter_theodolite/util/image_utils.dart';
import 'package:flutter_theodolite/util/toast_utils.dart';
import 'package:flutter_theodolite/widgets/base_dialog.dart';
import 'package:flutter_theodolite/widgets/load_image.dart';
import 'package:flutter_theodolite/widgets/my_card.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../main.dart';

class ScheduleCard extends StatelessWidget {
  String get title => schedule.title ?? ''; //房建标题
  List<RoomUser> get mike => schedule.mike ?? []; //主持人
  List<RoomUser> get user => schedule.user ?? []; //主持人
  String get profile => schedule.profile ?? ''; //介绍
  int get rooms => schedule.rooms ?? 0; //房间号
  int get userCount => schedule.userCount ?? 0; //人数
  int get mikeCount => schedule.mikeCount ?? 0; //主持人数
  int get follow => schedule.follow ?? 1; //是否关注
  int get time => schedule.begintime ?? 0; //开播时间
  int get homeowner => schedule.homeowner ?? 1;

  String get dissolution => schedule.dissolution; // 1语音房未结束  2语音房已结束
  final VoiceRoom schedule;
  final Function()? onFollow; //设置是否关注
  final Function()? onCancel; //设置取消语音房
  final Function(RoomUser)? onClickAvatar; //点击头像

  // factory ScheduleCard.fromSchedule(VoiceRoom schedule,
  //     {Function()? onFollow, Function()? onCancel, Function()? onClickAvatar}) {
  //   return ScheduleCard(
  //
  //     title: schedule.title ?? '',
  //     mike: schedule.mike != null && schedule.mike!.length > 0
  //         ? schedule.mike
  //         : [],
  //     user: schedule.user != null && schedule.user!.length > 0
  //         ? schedule.user
  //         : [],
  //     profile: schedule.profile ?? '',
  //     follow: schedule.follow ?? 1,
  //     rooms: schedule.rooms ?? 0,
  //     userCount: schedule.userCount ?? 0,
  //     mikeCount: schedule.mikeCount ?? 0,
  //     time: schedule.begintime ?? 0,
  //     onFollow: onFollow,
  //     onCancel: onCancel,
  //     onClickAvatar: onClickAvatar,
  //     homeowner: schedule.homeowner ?? 1,
  //     dissolution: schedule.dissolution,
  //   );
  // }
  ScheduleCard({
    required this.schedule,
    this.onFollow,
    this.onCancel,
    this.onClickAvatar,
    Key? key,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimens.gap_dp12),
      margin: EdgeInsetsDirectional.only(bottom: Dimens.gap_dp12),
      child: MyCard(
        child: Padding(
          padding: EdgeInsets.all(13.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: title,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600),
                        children: [
                          TextSpan(
                              text: homeowner == 2
                                  ? '(${DateUtil.formatDateMs(time * 1000, isUtc: false, format: "HH:mm")})'
                                  : '',
                              style: TextStyle(
                                  color: Colours.text_gray_c,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.normal))
                        ],
                      ),
                    ),
                  ),
                  // 语音房已结束
                  dissolution.contains("2")
                      ? Container(
                          height: 20,
                          child: Text(
                            lang!.havOver,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : homeowner == 2 //语音房未结束 房主
                          ? Text(lang!.cancel,
                                  style: TextStyle(
                                    color: Colours.app_main,
                                  ))
                              .text
                              .make()
                              .pLTRB(8.sp, 3.sp, 0, 8.sp)
                              .onTap(() {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return BaseDialog(
                                      hiddenTitle: true,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14.sp, vertical: 6.sp),
                                        child: Text(
                                          lang!.confirmCancelSchedule,
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colours.icon_text_button,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      confirmText: lang!.confirm,
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        onCancel!();
                                      },
                                    );
                                  });
                            })
                          : VxCapsule(
                              //语音房未结束 非房主
                              border: Border.fromBorderSide(BorderSide(
                                  color: follow == 1
                                      ? Colours.text_gray_c
                                      : Colours.app_main,
                                  width: 2.sp)),
                              backgroundColor: follow == 1
                                  ? Colours.text_gray_c
                                  : Colours.app_main,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(DateUtil.formatDateMs(
                                            time * 1000,
                                            isUtc: false,
                                            format: 'HH:mm'))
                                        .text
                                        .center
                                        .white
                                        .make(),
                                  ),
                                  LoadAssetImage(
                                      follow == 1
                                          ? 'icon/alter_off'
                                          : 'icon/alter_on',
                                      width: 22.sp,
                                      height: 22.sp)
                                ],
                              ),
                            ).w(78.sp).h(28.sp).onTap(onFollow ?? () {})
                ],
              ),
              Gaps.vGap12,
              mike.length > 0
                  ? Padding(
                      padding: EdgeInsets.only(bottom: Dimens.gap_dp12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children: mike.map((item) {
                          return GestureDetector(
                            child: Container(
                              width: 46.sp,
                              height: 46.sp,
                              margin: EdgeInsets.only(right: Dimens.gap_dp10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.sp),
                                  image: DecorationImage(
                                      image: ImageUtils.getImageProvider(
                                          item.avatar),
                                      fit: BoxFit.cover)),
                            ),
                            onTap: (() {
                              if (onClickAvatar != null) {
                                onClickAvatar!(item);
                              }
                            }),
                          );
                        }).toList()),
                      ),
                    )
                  : Container(),
              profile.isNotEmpty
                  ? Text(profile).text.color(Colours.text_gray).make()
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
