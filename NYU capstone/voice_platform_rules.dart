import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:flutter_theodolite/app_provider.dart';
import 'package:flutter_theodolite/net/net.dart';
import 'package:flutter_theodolite/widgets/my_app_bar.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_theodolite/widgets/empty.dart';

import '../../../main.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VoiceRuleText extends StatefulWidget {
  VoiceRuleText({
    Key? key,
  }) : super(key: key);

  @override
  _VoiceRuleTextState createState() => _VoiceRuleTextState();
}

class _VoiceRuleTextState extends State<VoiceRuleText> {
  String rules = '';

  @override
  void initState() {
    this.getVoiceRule();
    super.initState();
  }

  getVoiceRule() async {
    print('roomsRule');
    DioUtils.instance.requestNetwork(Method.post, HttpApi.ruleText,
        params: {"type": "roomsRule"}, onSuccess: (data) {
      print('roomsRule');
      print('====${data.toString()}===========');
      setState(() {
        rules = data.toString();
      });
      // if()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        centerTitle: lang!.voiceRoomPlatformRules,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.black),
        child: Padding(
          padding: EdgeInsets.all(10.sp),
          child: rules.isEmpty
              ? Center(
                  child: Empty(),
                )
              : rules.isNotEmpty
                  ? Html(
                      data: rules,
                      style: {"p": Style(color: Colors.black)},
                    )
                  : Center(
                      child: Empty(),
                    ),
        ),
      ),
    );
  }
}
