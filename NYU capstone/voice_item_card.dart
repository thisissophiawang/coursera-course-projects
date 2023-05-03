import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_theodolite/model/voice_room.dart';
import 'package:flutter_theodolite/res/resources.dart';
import 'package:flutter_theodolite/res/service/models/city_entity.dart';
import 'package:flutter_theodolite/util/image_utils.dart';
import 'package:flutter_theodolite/widgets/load_image.dart';
import 'package:flutter_theodolite/widgets/my_card.dart';
import 'package:getwidget/getwidget.dart';
import 'package:velocity_x/velocity_x.dart';

class VoiceCard extends StatelessWidget {
  String title;
  int peopleNum;
  int commentNum;
  List<RoomUser>? mike;
  Function()? onTap;
  double bottomIconSize = 12.sp;
  double avatarSize = 50.sp;
  double avatarRadius = 10.sp;
  VoiceCard(
      {Key? key,
      this.title = '',
      this.peopleNum = 0,
      this.commentNum = 0,
      this.onTap,
      this.mike})
      : super(key: key);

  factory VoiceCard.fromVoiceRoom(VoiceRoom room, Function()? onTap) {
    return VoiceCard(
      title: room.title ?? '',
      peopleNum: room.userCount ?? 0,
      commentNum: room.mikeCount ?? 0,
      mike: room.mike,
      onTap: onTap,
    );
  }
// 主持人名字
  Widget buildMikeTitle(RoomUser? item, {bool ellipsis = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(ellipsis ? '…' : (item?.nickname ?? ''),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colours.icon_text_button,
                      height: 1.4,
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w600)),
            ),
            Gaps.hGap10,
            LoadAssetImage(
              'icon/speaking',
              height: 13.sp,
            )
          ],
        ),
        Gaps.vGap4,
      ],
    );
  }

// 主持人头像
  Widget buildMikeItem(RoomUser? item) {
    return item != null ? Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.sp),
                image: DecorationImage(
                    image: ImageUtils.getImageProvider(item?.avatar ??
                        'http://5b0988e595225.cdn.sohucs.com/images/20200114/7f602e286918439b9793e3dbeb44f692.jpeg'),
                    fit: BoxFit.cover)),
          ) : Container(
            width: avatarSize,
            height: avatarSize,
            child: GFBorder(
              color: Colours.app_main,
              dashedLine: [2, 1],
              type: GFBorderType.rRect,
              radius: Radius.circular(avatarRadius),
              child: Center(
                  child: LoadAssetImage('icon/smile',
                      width: avatarSize, height: avatarSize)),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          bottom: Dimens.gap_dp12,
          right: Dimens.gap_dp12,
          left: Dimens.gap_dp12),
      child: GestureDetector(
          onTap: onTap,
          child: MyCard(
            child: Padding(
              padding: EdgeInsets.all(13.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    // softWrap: false,
                    // overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colours.icon_text_button,
                        height: 1.4,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600),
                  ),
                  Gaps.vGap15,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      mike != null && mike!.length > 0
                          ? Container(
                              width: 120.sp,
                              child: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  children: List.generate(
                                      mike!.length < 4 ? mike!.length + 1 : 4,
                                      (index) {
                                    return buildMikeItem(
                                        index <= mike!.length - 1
                                            ? mike![index]
                                            : null);
                                  }).toList()))
                          : Container(
                              width: 100.sp,
                              height: 100.sp,
                              child: GFBorder(
                                color: Colours.app_main,
                                dashedLine: [2, 1],
                                type: GFBorderType.rRect,
                                child: Center(
                                    child: LoadAssetImage('icon/smile',
                                        width: 50.sp, height: 50.sp)),
                              ),
                            ),
                      Gaps.hGap15,
                      mike != null && mike!.length > 0
                          ? Expanded(
                              child: Column(
                              children: List.generate(
                                  mike!.length <= 4 ? mike!.length : 5,
                                  (index) {
                                return buildMikeTitle(
                                    index <= mike!.length - 1
                                        ? mike![index]
                                        : null,
                                    ellipsis: index == 4);
                              }, growable: true),
                            ))
                          : Container()
                    ],
                  ),
                  Gaps.vGap12,
                  Row(
                    children: [
                      // 评论数量？
                      [
                        LoadAssetImage(
                          'icon/speaksmall',
                          width: bottomIconSize,
                          height: bottomIconSize,
                        ),
                        Gaps.hGap8,
                        Text(commentNum.toString())
                            .text
                            .color(Colours.app_main)
                            .fontWeight(FontWeight.w500)
                            .size(bottomIconSize)
                            .make()
                      ].hStack(crossAlignment: CrossAxisAlignment.center),

                      Gaps.hGap15,
                      // 人数?
                      [
                        LoadAssetImage(
                          'icon/people',
                          width: bottomIconSize,
                          height: bottomIconSize,
                        ),
                        Gaps.hGap8,
                        Text(peopleNum.toString())
                            .text
                            .color(Colours.app_main)
                            .fontWeight(FontWeight.w500)
                            .size(bottomIconSize)
                            .make()
                      ].hStack(crossAlignment: CrossAxisAlignment.center)
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }
}
