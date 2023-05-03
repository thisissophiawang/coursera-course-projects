import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:flutter_theodolite/app_provider.dart';
import 'package:flutter_theodolite/pages/voice/provider/schedule.dart';
import 'package:flutter_theodolite/pages/voice/widgets/schedule_card.dart';
import 'package:flutter_theodolite/res/resources.dart';
import 'package:flutter_theodolite/util/other_utils.dart';
import 'package:flutter_theodolite/util/toast_utils.dart';
import 'package:flutter_theodolite/widgets/action_sheet.dart';
import 'package:flutter_theodolite/widgets/base_dialog.dart';
import 'package:flutter_theodolite/widgets/load_image.dart';
import 'package:flutter_theodolite/widgets/my_button.dart';
import 'package:flutter_theodolite/widgets/refresh.dart';
import 'package:flutter_theodolite/widgets/text_field_item.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:table_calendar/table_calendar.dart';

// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter_theodolite/widgets/empty.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../../../main.dart';
import '../../../router/fluro_navigator.dart';
import '../../user/user_router.dart';

class CustomPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomPicker({DateTime? currentTime, LocaleType? locale})
      : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this._fillLeft();
    this._fillMiddle();
    this.setLeftIndex(this.currentTime.hour);
    this.setMiddleIndex(this.currentTime.minute);
    this.setRightIndex(this.currentTime.second);
  }

  _fillLeft() {
    int year = this.currentTime.year;
    this.leftList = List.generate(80, (index) => (year - 1).toString());
  }

  int _maxMonthOfCurrentYear() {
    return currentTime.year.toString() == this.leftList[0].toString()
        ? int.parse(this.leftList[0])
        : 12;
  }

  int _minMonthOfCurrentYear() {
    return currentTime.year.toString() ==
            this.leftList[this.leftList.length - 1].toString()
        ? int.parse(this.leftList[0])
        : 12;
  }

  _fillMiddle() {
    int minMonth = _minMonthOfCurrentYear();
    int maxMonth = _maxMonthOfCurrentYear();
    int month = this.currentTime.month;
  }
}

// 所有语音房
class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late SchedulePageProvider _vm;
  late AppProvider _app;
  final _formKey = GlobalKey<FormState>();

  // 日历第一天显示星期几（匹配今日的周几）
  List<StartingDayOfWeek> _weeks = [
    StartingDayOfWeek.monday,
    StartingDayOfWeek.tuesday,
    StartingDayOfWeek.wednesday,
    StartingDayOfWeek.thursday,
    StartingDayOfWeek.friday,
    StartingDayOfWeek.saturday,
    StartingDayOfWeek.sunday,
  ];

  @override
  void initState() {
    _app = Provider.of<AppProvider>(context, listen: false);
    _vm = Provider.of<SchedulePageProvider>(context, listen: false);
    _vm.init(_app);

    print(DateTime.now().weekday);
    super.initState();
  }

// 创建语音房（含有时间）
  void _openCreateModal(_context) {
    //用于在底部打开弹框的效果
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // backgroundColor: Colours.bg_color,
      builder: (BuildContext context) {
        return AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            // height: 800,
            duration: Duration(milliseconds: 100),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 18.sp, vertical: 18.sp),
                child: Form(
                  key:
                      _formKey, //需要key 在提交的时候判断_formKey.currentState.validator()
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            child: LoadAssetImage(
                              'icon/close',
                              width: 18.sp,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          Gaps.vGap24,
                          Text(
                            lang!.creatVoiceRoomTitle,
                            style: TextStyle(
                                fontSize: 22.sp,
                                color: Colours.icon_text_button,
                                fontWeight: FontWeight.w600,
                                height: 1.4),
                          ),
                          Gaps.vGap24,
                          TextFieldItem(
                            validator: RequiredValidator(
                                errorText: lang!.voiceRoomErrorTip),
                            controller: _vm.titleController,

                            hintText: lang!.voiceRoomTitleHint,
                            // maxLines: 5,
                          ),
                          Gaps.vGap16,
                          Row(
                            children: [
                              Expanded(
                                child: TextFieldItem(
                                    readOnly: true,
                                    validator: RequiredValidator(
                                        errorText: lang!.voiceRoomDateErrorTip),
                                    onTap: () {
                                      DatePicker.showDatePicker(
                                        context,
                                        // showTitleActions: true,
                                        minTime: DateTime.now()
                                            .add(Duration(minutes: 5)),
                                        maxTime: DateTime.now()
                                            .add(Duration(days: 365)),
                                        onChanged: (date) {
                                          print('change $date');
                                          _vm.dateController.text =
                                              DateUtil.formatDateMs(
                                                  date.millisecondsSinceEpoch,
                                                  format: 'yyyy/MM/dd');
                                          _vm.saveDate(date);
                                        },
                                        onConfirm: (date) {
                                          print('change $date');
                                          _vm.dateController.text =
                                              DateUtil.formatDateMs(
                                                  date.millisecondsSinceEpoch,
                                                  format: 'yyyy/MM/dd');
                                          _vm.saveDate(date);
                                        },
                                        currentTime: DateTime.now()
                                            .add(Duration(minutes: 5)),
                                        locale: Utils.getCurrLocale() == 'zh'
                                            ? LocaleType.zh
                                            : LocaleType.en,
                                      );
                                    },
                                    controller: _vm.dateController,
                                    prefix: Icon(
                                      Icons.calendar_today,
                                      color: Colours.app_main,
                                    ),
                                    hintText: DateUtil.formatDate(
                                        DateTime.now()
                                            .add(Duration(minutes: 5)),
                                        format: 'yyyy/MM/dd')
                                    // maxLines: 5,
                                    ),
                              ),
                            ],
                          ),
                          Gaps.vGap16,
                          Row(
                            children: [
                              Expanded(
                                child: TextFieldItem(
                                  readOnly: true,
                                  validator: RequiredValidator(
                                      errorText:
                                          lang?.voiceRoomTimeErrorTip ?? ""),
                                  onTap: () {
                                    DatePicker.showTimePicker(
                                      context,
                                      showSecondsColumn: false,
                                      // showTitleActions: true,
                                      currentTime: DateTime.now()
                                          .add(Duration(minutes: 6)),

                                      onChanged: (date) {
                                        print('change $date');
                                        _vm.saveTime(date);
                                      },
                                      onConfirm: (date) {
                                        print('confirm $date');

                                        _vm.timeController.text =
                                            '${DateUtil.formatDate(date, format: 'HH:mm')}';
                                        _vm.saveTime(date);
                                      },

                                      locale: Utils.getCurrLocale() == 'zh'
                                          ? LocaleType.zh
                                          : LocaleType.en,
                                    );
                                  },
                                  controller: _vm.timeController,
                                  prefix: Icon(
                                    Icons.access_alarm,
                                    color: Colours.app_main,
                                  ),
                                  hintText:
                                      ' ${DateUtil.formatDate(DateTime.now().add(Duration(minutes: 6)), format: 'HH:mm')}',
                                  // maxLines: 5,
                                ),
                              ),
                            ],
                          ),
                          Gaps.vGap16,
                          TextFieldItem(
                            validator: RequiredValidator(
                                errorText:
                                    lang?.voiceRoomProfileErrorTip ?? ""),
                            controller: _vm.profileController,
                            hintText: lang?.voiceRoomProfile ?? '',
                            maxlength: 200,
                            maxLines: 5,
                          ),
                        ],
                      ),
                      InkWell(
                        child: Container(
                          height: 43.sp,
                          alignment: Alignment.center,
                          decoration: new BoxDecoration(
                              color: Colours.app_main,
                              borderRadius: new BorderRadius.circular((28.sp))),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.sp, vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: MyButton(
                                  text: lang?.save ?? "",
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      DateTime choosed = DateTime(
                                          _vm.createDate!.year,
                                          _vm.createDate!.month,
                                          _vm.createDate!.day,
                                          _vm.createTime!.hour,
                                          _vm.createTime!.minute,
                                          _vm.createTime!.second);
                                      if (choosed.isBefore(DateTime.now()
                                          .add(Duration(minutes: 5)))) {
                                        Toast.show(lang?.scheduleHint ?? '');
                                        return;
                                      }
                                      _formKey.currentState
                                          ?.save(); //会触发各个field的onSave 这里没写 因为在各自的controller.text取值了
                                      _vm.save(context);
                                    }
                                  },
                                ))
                                // InkWell(
                                // onTap: () {
                                //   if (_formKey.currentState!.validate()) {
                                //     _formKey.currentState?.save();
                                //     _vm.save();
                                //   }
                                // },
                                //   child: Container(
                                //     child: Text(
                                //       '保存',
                                //       style: TextStyle(
                                //         fontSize: 17,
                                //         fontWeight: FontWeight.w600,
                                //         color: Colors.white,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            )

            // Container(
            //   padding: EdgeInsets.all(Dimens.gap_dp24),
            //   height: MediaQuery.of(context).size.height * 3 / 4,
            //   child: Form(
            //     key: _formKey, //需要key 在提交的时候判断_formKey.currentState.validator()
            //     child: Column(
            //       mainAxisSize: MainAxisSize.max,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             InkWell(
            //               child: LoadAssetImage(
            //                 'icon/close',
            //                 width: 20,
            //               ),
            //               onTap: () {
            //                 Navigator.pop(context);
            //               },
            //             ),
            //             Gaps.vGap24,
            //             Text(
            //               lang!.creatVoiceRoomTitle,
            //               style: TextStyle(
            //                   fontSize: 24,
            //                   color: Colours.icon_text_button,
            //                   fontWeight: FontWeight.w600,
            //                   height: 1.4),
            //             ),
            //             Gaps.vGap24,
            //             TextFieldItem(
            //               validator: RequiredValidator(
            //                   errorText: lang!.voiceRoomErrorTip),
            //               controller: _vm.titleController,

            //               hintText: lang!.voiceRoomTitleHint,
            //               // maxLines: 5,
            //             ),
            //             Gaps.vGap16,
            //             Row(
            //               children: [
            //                 Expanded(
            //                   child: TextFieldItem(
            //                       readOnly: true,
            //                       validator: RequiredValidator(
            //                           errorText: lang!.voiceRoomDateErrorTip),
            //                       onTap: () {
            //                         DatePicker.showDatePicker(
            //                           context,
            //                           // showTitleActions: true,
            //                           minTime: DateTime.now()
            //                               .add(Duration(minutes: 5)),
            //                           maxTime:
            //                               DateTime.now().add(Duration(days: 365)),
            //                           onChanged: (date) {
            //                             print('change $date');
            //                           },
            //                           onConfirm: (date) {
            //                             _vm.dateController.text =
            //                                 DateUtil.formatDateMs(
            //                                     date.millisecondsSinceEpoch,
            //                                     format: 'yyyy/MM/dd');
            //                             _vm.saveDate(date);
            //                           },
            //                           currentTime: DateTime.now()
            //                               .add(Duration(minutes: 5)),
            //                           locale: Utils.getCurrLocale() == 'zh'
            //                               ? LocaleType.zh
            //                               : LocaleType.en,
            //                         );
            //                       },
            //                       controller: _vm.dateController,
            //                       prefix: Icon(
            //                         Icons.access_alarm,
            //                         color: Colours.app_main,
            //                       ),
            //                       hintText: DateUtil.formatDate(
            //                           DateTime.now().add(Duration(minutes: 5)),
            //                           format: 'yyyy/MM/dd')
            //                       // maxLines: 5,
            //                       ),
            //                 ),
            //               ],
            //             ),
            //             Gaps.vGap16,
            //             Row(
            //               children: [
            //                 Expanded(
            //                   child: TextFieldItem(
            //                     readOnly: true,
            //                     validator: RequiredValidator(
            //                         errorText: lang?.voiceRoomTimeErrorTip ?? ""),
            //                     onTap: () {
            //                       DatePicker.showTimePicker(
            //                         context,
            //                         showSecondsColumn: false,
            //                         // showTitleActions: true,
            //                         currentTime:
            //                             DateTime.now().add(Duration(minutes: 5)),

            //                         onChanged: (date) {
            //                           print('change $date');
            //                         },
            //                         onConfirm: (date) {
            //                           print('confirm $date');

            //                           _vm.timeController.text =
            //                               '${DateUtil.formatDate(date, format: 'HH:mm')}';

            //                           _vm.saveTime(date);
            //                         },

            //                         locale: Utils.getCurrLocale() == 'zh'
            //                             ? LocaleType.zh
            //                             : LocaleType.en,
            //                       );
            //                     },
            //                     controller: _vm.timeController,
            //                     prefix: Icon(
            //                       Icons.calendar_today,
            //                       color: Colours.app_main,
            //                     ),
            //                     hintText:
            //                         ' ${DateUtil.formatDate(DateTime.now().add(Duration(minutes: 5)), format: 'HH:mm')}',
            //                     // maxLines: 5,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             Gaps.vGap16,
            //             TextFieldItem(
            //               validator: RequiredValidator(
            //                   errorText: lang?.voiceRoomProfileErrorTip ?? ""),
            //               controller: _vm.profileController,
            //               hintText: lang?.voiceRoomProfile ?? '',
            //               maxlength: 200,
            //               maxLines: 5,
            //             ),
            //           ],
            //         ),
            //         InkWell(
            //           child: Container(
            //             height: 43.sp,
            //             alignment: Alignment.center,
            //             decoration: new BoxDecoration(
            //                 color: Colours.app_main,
            //                 borderRadius: new BorderRadius.circular((28.sp))),
            //             child: Padding(
            //               padding:
            //                   EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            //               child: Row(
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: [
            //                   Expanded(
            //                       child: MyButton(
            //                     text: lang?.save ?? "",
            //                     onPressed: () {
            //                       if (_formKey.currentState!.validate()) {
            //                         DateTime choosed = DateTime(
            //                             _vm.createDate!.year,
            //                             _vm.createDate!.month,
            //                             _vm.createDate!.day,
            //                             _vm.createTime!.hour,
            //                             _vm.createTime!.minute,
            //                             _vm.createTime!.second);
            //                         if (choosed.isBefore(DateTime.now()
            //                             .add(Duration(minutes: 5)))) {
            //                           Toast.show(lang?.scheduleHint ?? '');
            //                           return;
            //                         }
            //                         _formKey.currentState
            //                             ?.save(); //会触发各个field的onSave 这里没写 因为在各自的controller.text取值了
            //                         _vm.save(context);
            //                       }
            //                     },
            //                   ))
            //                   // InkWell(
            //                   // onTap: () {
            //                   //   if (_formKey.currentState!.validate()) {
            //                   //     _formKey.currentState?.save();
            //                   //     _vm.save();
            //                   //   }
            //                   // },
            //                   //   child: Container(
            //                   //     child: Text(
            //                   //       '保存',
            //                   //       style: TextStyle(
            //                   //         fontSize: 17,
            //                   //         fontWeight: FontWeight.w600,
            //                   //         color: Colors.white,
            //                   //       ),
            //                   //     ),
            //                   //   ),
            //                   // ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           onTap: () {},
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            );
      },

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
    // return false
  }

// 选择模式
  void _openModalBottomSheet() {
    //用于在底部打开弹框的效果
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        List<ActionSheetItem> actions = [
          ActionSheetItem(
            isBorder: true,
            title: lang?.allVoiceRoom ?? "",
            onTap: () {
              _vm.chooseMode(0);
              Navigator.pop(context);
            },
          ),
          ActionSheetItem(
            isBorder: true,
            title: lang?.friendVoiceRoom ?? "",
            onTap: () {
              _vm.chooseMode(1);
              Navigator.pop(context);
            },
          ),
          ActionSheetItem(
            isBorder: false,
            title: lang?.cancel ?? "",
            textColor: Colours.text_gray,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ];
        //构建弹框中的内容
        return BottomActionSheet(
          context: context,
          actions: actions,
        );
      },

      isDismissible: true, //外部不可以点击
      shape: RoundedRectangleBorder(
        //这里是modal的边框样式
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14.sp),
          topRight: Radius.circular(14.sp),
        ),
      ),
    );
    // return false
  }

  @override
  Widget build(BuildContext context) {
    var vm = context.watch<SchedulePageProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: InkWell(
          onTap: () => _openModalBottomSheet(),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(vm.modes[vm.choosedMode])
                    .text
                    .fontWeight(FontWeight.w600)
                    .make(),
                LoadAssetImage('icon/drop-down', width: 9.sp, height: 3.sp)
              ]),
        ),
        actions: [
          InkWell(
              child: Padding(
                padding: EdgeInsets.only(right: Dimens.gap_dp12),
                child: LoadAssetImage(
                  'icon/create_voice',
                  width: 23.sp,
                ),
              ),
              onTap: () => _openCreateModal(context))
        ],
      ),
      body: SmartRefresher(
        enablePullUp: true,
        onRefresh: () => vm.onRefresh(),
        onLoading: () => vm.getMore(),
        controller: vm.refreshController,
        footer: vm.getVoiceList.length > 5
            ? ClassicFooter()
            : SliverToBoxAdapter(child: Gaps.empty),
        child: CustomScrollView(
          slivers: [
            MultiSliver(
              children: [
                SliverPinnedHeader(
                  child: Column(
                    children: [
                      Container(
                        color: Colours.bg_color,
                        padding: EdgeInsets.symmetric(vertical: Dimens.gap_dp5),
                        child: TableCalendar(
                          headerVisible: false,
                          //是否显示周几
                          daysOfWeekVisible: false,
                          //是否显示年份
                          locale:
                              Utils.getCurrLocale() == 'zh' ? 'zh_CN' : 'en_US',
                          firstDay: DateTime.now(),
                          currentDay: DateTime.now(),
                          // rangeStartDay: DateTime.now(),
                          lastDay: DateTime.now().add(Duration(days: 365)),
                          focusedDay: vm.choosedDate,
                          selectedDayPredicate: (DateTime date) {
                            return isSameDay(date, vm.getChoosedDate);
                          },
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            canMarkersOverflow: false,
                            isTodayHighlighted: false,
                            defaultTextStyle: TextStyle(
                              color: Vx.gray700,
                            ),
                            holidayTextStyle: TextStyle(
                              color: Vx.gray700,
                            ),
                            weekendTextStyle: TextStyle(
                              color: Vx.gray700,
                            ),
                            selectedDecoration: BoxDecoration(
                                color: Colours.app_main,
                                shape: BoxShape.circle),
                            todayDecoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            todayTextStyle: TextStyle(
                              color: Vx.gray700,
                            ),
                            outsideTextStyle: TextStyle(
                              color: Vx.gray700,
                            ),
                            selectedTextStyle: TextStyle(color: Colors.white),
                          ),
                          calendarFormat: CalendarFormat.week,
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: Vx.gray400,
                            ),
                            weekendStyle: TextStyle(
                              color: Vx.gray400,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            // formatButtonShowsNext: false,
                            // headerPadding: ,
                            headerPadding: EdgeInsets.symmetric(
                                horizontal: 18.sp, vertical: 8.sp),
                            leftChevronVisible: false,
                            rightChevronVisible: false,
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(
                              color: Vx.gray500,
                            ),
                          ),
                          onDaySelected: (time, time2) {
                            vm.chooseDate(time);
                          },
                          availableGestures: AvailableGestures.horizontalSwipe,
                          startingDayOfWeek: _weeks[DateTime.now().weekday - 1],
                        ),
                      ),
                    ],
                  ),
                ),
                vm.getVoiceList.length > 0
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                        return ScheduleCard(
                            schedule: vm.getVoiceList[index],
                            onFollow: () async {
                              // var res = await showOkCancelAlertDialog(context: context,title:'提示',)
                              vm.changeFollow(vm.getVoiceList[index]);
                            },
                            onCancel: () async {
                              vm.cancelRoom(vm.getVoiceList[index]);
                            },
                            onClickAvatar: ((user) {
                              NavigatorUtils.push(context,
                                  '${UserRouter.userPage}?userID=${user.userId.toString()}');
                            })).onTap(() {
                          if (vm.getVoiceList[index].homeowner != 2) {
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
                                    vm.startTheRoom(
                                        context, vm.getVoiceList[index]);
                                  },
                                );
                              });
                        });
                      }, childCount: vm.getVoiceList.length))
                    : SliverToBoxAdapter(
                        child: Center(child: Empty()),
                      )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
