import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:soundpool/soundpool.dart';
import 'package:usage_track/main-screen/providers/firebase_data.dart';
import 'package:usage_track/providers/work_data.dart';

class AddDialog extends StatefulWidget {
  const AddDialog({super.key});

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  var _isloading = false;
  int _initItem = 0;
  int _initItem2 = 0;

  final pool = Soundpool.fromOptions(
      options: const SoundpoolOptions(
    streamType: StreamType.music,
    maxStreams: 25,
  ));
  int poolId = 0;

  final _textController = TextEditingController();
  late var scrollController =
      FixedExtentScrollController(initialItem: _initItem);
  late var scrollController2 =
      FixedExtentScrollController(initialItem: _initItem2);
  final _theme = WorkData.currenTheme;
  late final _workData = Provider.of<WorkData>(context);
  late ItemType? favoriteType;
  late final _firebase = Provider.of<FirebaseData>(context, listen: false);

  late final _values = {
    'quantity': 0,
    'amountSpent': 0,
    'itemType': favoriteType ?? _workData.itemTypes[0],
  };

  Future<void> _submit() async {
    if (_workData.paidNotification != null) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: FittedBox(
              child: Text('please confirm or reject payment first'.tr),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.pop(context), child: Text('ok'.tr))
            ]),
      );
      return;
    }
    final contin = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('do you want to add:'.tr),
        content: Text(
            '${'work quantity'.tr}: ${_values['quantity']!}\n${'amount taken'.tr}: ${_values['amountSpent']!}\n${'type'.tr}: ${(_values['itemType']! as ItemType).name}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('ok'.tr)),
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancle'.tr)),
        ],
      ),
    );

    if (contin != true) return;

    _values['quantity'] = _initItem;
    if (_textController.text.isNotEmpty) {
      _values['amountSpent'] = int.parse(_textController.value.text.trim());
    }
    setState(() {
      _isloading = true;
    });
    await _firebase
        .addOneWorkToFirebase(
            amountSpent: _values['amountSpent'] as int,
            quantity: _values['quantity'] as int,
            typeName: (_values['itemType'] as ItemType).name)
        .catchError((e) {
// throw e;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('can\'t upload right now, please try again later'.tr)));
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    favoriteType = _workData.favoriteType;
  }

  @override
  void initState() {
    super.initState();
    rootBundle
        .load('assets/images/tick.ogg')
        .then((value) => pool.load(value))
        .then((value) => poolId = value);

    Future.delayed(Duration.zero).then(
      (value) {
        if (favoriteType == null) {
          final list = _workData.itemTypes;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('please select your default type'.tr),
              content: SizedBox(
                height: 300,
                child: ListWheelScrollView.useDelegate(
                  childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 2),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: _theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(15)),
                              child: InkWell(
                                onTap: () async {
                                  await _workData
                                      .setFavoriteType(list[index]!.id);
                                  setState(() {
                                    _values['itemType'] = list[index];
                                  });
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                        flex: 3,
                                        fit: FlexFit.tight,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            list[index]!.name,
                                            style: TextStyle(
                                                fontSize: 40,
                                                color: _theme.disabledColor),
                                          ),
                                        )),
                                    Flexible(
                                        flex: 1,
                                        child: Icon(
                                          Icons.touch_app_outlined,
                                          color: _theme.disabledColor,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      childCount: list.length),
                  itemExtent: 90,
                  onSelectedItemChanged: (value) {
                    pool.play(poolId);
//                       AudioPlayer player = AudioPlayer();

//                     //  final player = AudioPlayer();
// await                    player.play(AssetSource('images/tick.ogg'));
//                     await player.dispose();
                  },
                  diameterRatio: 5,
                  useMagnifier: false,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    scrollController.dispose();
    scrollController2.dispose();
    scrollController = FixedExtentScrollController(initialItem: _initItem);
    scrollController2 = FixedExtentScrollController(initialItem: _initItem2);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    scrollController2.dispose();
    _textController.dispose();
    pool.release();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        flex: 2,
                        child: Text(
                          'work quantity'.tr,
                          style: TextStyle(
                              color: _theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 20),
                        )),
                    Flexible(
                      flex: 1,
                      child: IconButton(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('pick a number'.tr),
                                  content: SizedBox(
                                    height: 200,
                                    child: ListWheelScrollView.useDelegate(
                                      childDelegate:
                                          ListWheelChildBuilderDelegate(
                                              builder: (context, index) => Text(
                                                    (_workData.formatNumbers
                                                        .format(index)),
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        color: _theme
                                                            .colorScheme
                                                            .primary),
                                                  ),
                                              childCount: 51),
                                      onSelectedItemChanged: (value) {
                                        pool.play(poolId);
//                                           AudioPlayer player = AudioPlayer();

//                                         //  final player = AudioPlayer();
// await                                        player.play(
//                                             AssetSource('images/tick.ogg'));

//                                       await  player.dispose();
                                      },
                                      controller: scrollController,
                                      itemExtent: 50,
                                      // children: numbers(),
                                      magnification: 1.4,
                                      // clipBehavior: Clip.none,
                                      // perspective: 0.009,
                                      overAndUnderCenterOpacity: 0.5,
                                      physics: const FixedExtentScrollPhysics(),
                                      // squeeze: 1.2,
                                      diameterRatio: 5,
                                    ),
                                  ),
                                  actionsAlignment:
                                      MainAxisAlignment.spaceAround,
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('cancle'.tr)),
                                    TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _values['quantity'] =
                                                scrollController.selectedItem;
                                            _initItem =
                                                scrollController.selectedItem;
                                          });

                                          Navigator.pop(context);
                                        },
                                        child: Text('ok'.tr)),
                                  ],
                                ),
                            barrierDismissible: false),
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _theme.colorScheme.onPrimary)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (_workData.formatNumbers
                                    .format(_values['quantity'] as int)),
                                style: TextStyle(
                                    color: _theme.colorScheme.secondary),
                              ),
                              Icon(
                                Icons.add,
                                color: _theme.colorScheme.onPrimary,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        flex: 2,
                        child: Text(
                          'amount taken'.tr,
                          style: TextStyle(
                              color: _theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 20),
                        )),
                    Flexible(
                      flex: 1,
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (value) => setState(() {
                          if (!value.isNumericOnly) return;
                          _values['amountSpent'] = int.parse(value);
                        }),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _theme.colorScheme.secondary),
                        cursorColor: _theme.colorScheme.primary,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: _theme.colorScheme.secondary)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: _theme.colorScheme.onPrimary)),
                          // border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                          hintStyle:
                              TextStyle(color: _theme.colorScheme.onPrimary),
                          hintText: _workData.formatNumbers.format(0),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        flex: 2,
                        child: Text(
                          'type'.tr,
                          style: TextStyle(
                              color: _theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 20),
                        )),
                    Flexible(
                        flex: 1,
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('pick a type'.tr),
                                      content: SizedBox(
                                        height: 200,
                                        child: ListWheelScrollView.useDelegate(
                                          childDelegate:
                                              ListWheelChildBuilderDelegate(
                                                  builder: (context, index) =>
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          _workData
                                                              .itemTypes[index]!
                                                              .name,
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color: _theme
                                                                  .colorScheme
                                                                  .primary),
                                                        ),
                                                      ),
                                                  childCount: _workData
                                                          .itemTypes.isEmpty
                                                      ? 0
                                                      : _workData
                                                          .itemTypes.length),
                                          onSelectedItemChanged: (value) async {
                                            pool.play(poolId);
//                                               AudioPlayer player = AudioPlayer();

// await                                            player.play(
//                                                 AssetSource('images/tick.ogg'));
//                                         await        player.dispose();
                                          },
                                          controller: scrollController2,
                                          itemExtent: 50,
                                          // children: numbers(),
                                          magnification: 1.4,
                                          // clipBehavior: Clip.none,
                                          // perspective: 0.005,
                                          overAndUnderCenterOpacity: 0.5,
                                          physics:
                                              const FixedExtentScrollPhysics(),
                                          // squeeze: 1.2,
                                          diameterRatio: 5,
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.spaceAround,
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('cancle'.tr)),
                                        TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _values['itemType'] =
                                                    _workData.itemTypes.isEmpty
                                                        ? null
                                                        : _workData.itemTypes[
                                                            scrollController2
                                                                .selectedItem];

                                                _initItem2 = scrollController2
                                                    .selectedItem;
                                              });

                                              Navigator.pop(context);
                                            },
                                            child: Text('ok'.tr)),
                                      ],
                                    ),
                                barrierDismissible: false);
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _theme.colorScheme.onPrimary)),
                            child: FittedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (_values['itemType'] as ItemType).name,
                                    style: TextStyle(
                                        color: _theme.colorScheme.secondary),
                                  ),
                                  Icon(
                                    Icons.expand_more,
                                    color: _theme.colorScheme.onPrimary,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ))
                  ],
                )
              ],
            ),
          ),
          Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'cancle'.tr,
                      style: TextStyle(color: _theme.colorScheme.onSecondary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isloading
                        ? () {}
                        : (((_textController.text.isEmpty ||
                                        _textController.text == '0') &&
                                    _initItem == 0) ||
                                (!_textController.text.isNumericOnly &&
                                    _textController.text.isNotEmpty))
                            ? null
                            : () => _submit(),
                    child: _isloading
                        ? const CircularProgressIndicator()
                        : Text(
                            'add'.tr,
                            style: TextStyle(
                                color: _theme.colorScheme.onSecondary),
                          ),
                  ),
                ],
              )),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}


// (_workData.formatNumbers.format(_values['amountSpent']as int))