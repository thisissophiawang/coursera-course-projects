import 'package:flutter/material.dart';
import 'package:flutter_theodolite/login/widgets/my_text_field.dart';
import 'package:flutter_theodolite/main.dart';
import 'package:flutter_theodolite/net/net.dart';
import 'package:flutter_theodolite/res/colors.dart';
import 'package:flutter_theodolite/util/toast_utils.dart';
import 'package:flutter_theodolite/widgets/my_app_bar.dart';
import 'package:flutter_theodolite/widgets/text_field_item.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_theodolite/widgets/empty.dart';

class RoomRules extends StatefulWidget {
  String? id;
  String? homeowner;
  RoomRules({Key? key, this.id, this.homeowner}) : super(key: key);

  @override
  _RoomRulesState createState() => _RoomRulesState();
}

class _RoomRulesState extends State<RoomRules> {
  String rules = '';
  late int _id;
  late int _homeowner;
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.homeowner is String) {
      _homeowner = int.parse(widget.homeowner ?? '1');
    }

    if (widget.id is String) {
      _id = int.parse(widget.id ?? '-1');
    }
    if (_id < 0) {
      return;
    }

    getRoomRules();
  }

  getRoomRules() {
    DioUtils.instance.requestNetwork<Map>(
        Method.post, HttpApi.roomsGetRoomsHomeRule, params: {'rooms': _id},
        onSuccess: (data) {
      print(data);

      if (data != null &&
          data['homerule'] != null &&
          data['homerule'].isNotEmpty) {
        if (_homeowner == 2) {
          controller.text = data['homerule'];
        } else {
          setState(() {
            rules = data['homerule'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        centerTitle: lang?.roomRule ?? "",
        actions: TextButton(
            onPressed: () {
              if (controller.text.isEmpty) {
                Toast.show(lang?.roomRuleInputHint ?? '');
                return;
              } else {
                DioUtils.instance.requestNetwork(
                    Method.post, HttpApi.roomsHomeruleRooms,
                    params: {'rooms': _id, 'homerule': controller.text},
                    onSuccess: (data) {
                  Toast.show('${lang?.setting}${lang?.success}');
                  Navigator.pop(context);
                });
              }
            },
            child: Text(lang?.save ?? '').text.color(Colours.app_main).make()),
        isActions: _homeowner == 2 ? true : false,
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: _homeowner == 2
            ? TextFieldItem(
                textInputAction: TextInputAction.unspecified,
                controller: controller,
                hintText: lang?.roomRuleInputHint ?? '',
                maxlength: 1000,
                wordCount: true,
                maxLines: 10,
              )
            : rules.isNotEmpty
                ? Text(rules).text.black.make()
                : Center(
                    child: Empty(),
                  ),
      ),
    );
  }
}
