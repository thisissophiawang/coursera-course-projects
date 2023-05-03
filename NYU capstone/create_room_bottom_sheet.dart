import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:flutter_theodolite/pages/voice/provider/voice_page.dart';
import 'package:flutter_theodolite/util/toast_utils.dart';

import 'package:provider/provider.dart';
import 'package:velocity_x/src/flutter/text.dart';
import '../../../main.dart';
import '../../../res/colors.dart';
import '../../../res/gaps.dart';
import '../../../widgets/load_image.dart';
import '../../../widgets/text_field_item.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// 创建语音房弹窗Widget

class CreateVoiceSheet extends StatefulWidget {
  VoicePageProvider vm;
  Function onSuccess;
  CreateVoiceSheet({Key? key, required this.vm, required this.onSuccess})
      : super(key: key);

  @override
  _CreateVoiceSheetState createState() => _CreateVoiceSheetState();
}

class _CreateVoiceSheetState extends State<CreateVoiceSheet> {
  late VoicePageProvider _vm;

  late int _open;
  int countText = 0;

  @override
  void initState() {
    super.initState();
    _vm = widget.vm;
    _open = _vm.open;
    countText = _vm.controller.text.length;
  }

  Widget buildVoiceSheet(
    BuildContext context,
  ) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 18.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: LoadAssetImage(
                  'icon/close',
                  width: 14.sp,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Gaps.vGap32,
              Expanded(
                  child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      lang!.creatVoiceRoomTitle,
                      style: TextStyle(
                          color: Colours.icon_text_button,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Gaps.vGap10,
                  TextFieldItem(
                    hintText: lang!.voiceRoomTitleHint,
                    maxlength: 60,
                    controller: _vm.controller,
                    onChange: (text) {
                      setState(() {
                        countText = text.length;
                      });
                    },

                    // suffix: Text('$countText/60')
                    //     .text
                    //     .maxFontSize(12)
                    //     .minFontSize(12)
                    //     .color(Colours.text_gray_c)
                    //     .make(),
                    // onEditingComplete: () {
                    //   Navigator.pop(context);
                    // },
                  ),
                  Gaps.vGap15,
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: new BoxDecoration(
                                color: Color(0xFFF8F6EC),
                                border: new Border.all(
                                    color: _open == 2
                                        ? Colours.app_main
                                        : Colors.transparent,
                                    width: 1.5.sp),
                                borderRadius:
                                    new BorderRadius.circular((28.sp))),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 28.sp),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LoadAssetImage(
                                    'icon/publicity',
                                    width: 78.sp,
                                  ),
                                  Gaps.vGap10,
                                  Container(
                                    child: Text(
                                      lang!.public,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colours.icon_text_button,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            _vm.chooseOpen(2);
                            setState(() {
                              _open = 2;
                            });
                          },
                        ),
                      ),
                      Gaps.hGap24,
                      Expanded(
                        child: InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: new BoxDecoration(
                                color: Color(0xFFF8F6EC),
                                border: new Border.all(
                                    color: _open == 1
                                        ? Colours.app_main
                                        : Colors.transparent,
                                    width: 1.5.sp),
                                borderRadius: new BorderRadius.circular((28.sp))),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 28.sp),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LoadAssetImage(
                                    'icon/privacy',
                                    width: 78.sp,
                                  ),
                                  Gaps.vGap10,
                                  Container(
                                    child: Text(
                                      lang!.private,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colours.icon_text_button,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            _vm.chooseOpen(1);
                            setState(() {
                              _open = 1;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  Gaps.vGap15,
                  Text(
                    lang!.voiceRoomTips,
                    style: TextStyle(color: Color(0xFFBDBDBD), fontSize: 10.sp),
                  )
                ],
              )),
              InkWell(
                child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      color: Colours.app_main,
                      borderRadius: new BorderRadius.circular((28.sp))),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.sp, vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Text(
                            lang!.release,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () async {
                  if (_vm.controller.text.isEmpty) {
                    Toast.show(
                      lang!.voiceRoomTitleHint,
                    );
                    return;
                  }
                  Navigator.pop(context);

                  widget.onSuccess.call();
                },
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return buildVoiceSheet(context);
  }
}
