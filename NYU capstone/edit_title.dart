import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:flutter_theodolite/network/http_api.dart';
import 'package:flutter_theodolite/net/net.dart';
import 'package:flutter_theodolite/res/resources.dart';
import 'package:flutter_theodolite/util/event.dart';
import 'package:flutter_theodolite/util/toast_utils.dart';
import 'package:flutter_theodolite/widgets/empty.dart';
import 'package:flutter_theodolite/widgets/my_app_bar.dart';
import 'package:flutter_theodolite/widgets/text_field_item.dart';
import 'package:velocity_x/src/flutter/text.dart';

import '../../../main.dart';

class EditRoomTitle extends StatefulWidget {
  String? id;
  String? homeowner;
  String? title;
  EditRoomTitle({Key? key, this.id, this.homeowner, this.title})
      : super(key: key);

  @override
  State<EditRoomTitle> createState() => _EditRoomTitleState();
}

class _EditRoomTitleState extends State<EditRoomTitle> {
  String _title = '';
  late int _id;
  late int _homeowner;
  int textLength = 0;
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.homeowner is String) {
      _homeowner = int.parse(widget.homeowner ?? '1');
    }
    if (widget.title is String) {
      _title = widget.title ?? '';
      controller.text = _title;
      textLength = _title.length;
    }

    if (widget.id is String) {
      _id = int.parse(widget.id ?? '-1');
    }
    if (_id < 0) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        centerTitle: lang?.roomTitle ?? "",
        actions: TextButton(
            onPressed: () {
              if (controller.text.isEmpty) {
                Toast.show(lang?.roomTitleInputHint ?? '');
                return;
              } else {
                DioUtils.instance.requestNetwork(
                    Method.post, HttpApi.roomsUpdateRoomsTitle,
                    params: {'rooms': _id, 'title': controller.text},
                    onSuccess: (data) {
                  Toast.show('${lang?.setting}${lang?.success}');
                  eventBus.fire(UpdateRoomTitle());

                  Navigator.pop(context);
                });
              }
            },
            child: Text(lang?.save ?? '').text.color(Colours.app_main).make()),
        isActions: _homeowner == 2 ? true : false,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.sp),
        child: _homeowner == 2
            ? TextFieldItem(
                controller: controller,
                hintText: lang?.roomRuleInputHint ?? '',
                keyboardType: TextInputType.multiline,
                maxlength: 60,
                // maxLines: 4,
                // counterText: '$textLength/60',
                onChange: (text) {
                  setState(() {
                    textLength = controller.text.length;
                  });
                },

                // suffix: Text('$textLength/60')
                //     .text
                //     .maxFontSize(10.sp)
                //     .minFontSize(10.sp)
                //     .color(Colours.text_gray_c)
                //     .make(),
              )
            : _title.isNotEmpty
                ? Text(_title).text.black.make()
                : Center(
                    child: Empty(),
                  ),
      ),
    );
  }
}
