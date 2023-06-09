import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.blue,
    statusBarColor: Colors.pink,
  ));
  runApp(const MyApp());
}

class CustomRefresh {
  static Widget buildRefreshIndicator(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    final double percentageComplete =
        clampDouble(pulledExtent / refreshTriggerPullDistance, 0.0, 1.0);

    // Place the indicator at the top of the sliver that opens up. We're using a
    // Stack/Positioned widget because the CupertinoActivityIndicator does some
    // internal translations based on the current size (which grows as the user drags)
    // that makes Padding calculations difficult. Rather than be reliant on the
    // internal implementation of the activity indicator, the Positioned widget allows
    // us to be explicit where the widget gets placed. The indicator should appear
    // over the top of the dragged widget, hence the use of Clip.none.
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            top: 16,
            left: 0.0,
            right: 0.0,
            child: _buildIndicatorForRefreshState(
                refreshState, 14, percentageComplete),
          ),
        ],
      ),
    );
  }

  static Widget _buildIndicatorForRefreshState(
      RefreshIndicatorMode refreshState,
      double radius,
      double percentageComplete) {
    switch (refreshState) {
      case RefreshIndicatorMode.drag:
        // While we're dragging, we draw individual ticks of the spinner while simultaneously
        // easing the opacity in. Note that the opacity curve values here were derived using
        // Xcode through inspecting a native app running on iOS 13.5.
        const Curve opacityCurve = Interval(0.0, 0.35, curve: Curves.easeInOut);
        return Opacity(
          opacity: opacityCurve.transform(percentageComplete),
          child: CupertinoActivityIndicator.partiallyRevealed(
              color: Colors.white,
              radius: radius,
              progress: percentageComplete),
        );
      case RefreshIndicatorMode.armed:
      case RefreshIndicatorMode.refresh:
        // Once we're armed or performing the refresh, we just show the normal spinner.
        return CupertinoActivityIndicator(
          radius: radius,
          color: Colors.white,
        );
      case RefreshIndicatorMode.done:
        // When the user lets go, the standard transition is to shrink the spinner.
        return CupertinoActivityIndicator(
          radius: radius * percentageComplete,
          color: Colors.white,
        );
      case RefreshIndicatorMode.inactive:
        // Anything else doesn't show anything.
        return const SizedBox.shrink();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.white),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class User {
  final String nama;
  final int nomor;

  User(this.nama, this.nomor);
}

class _MyHomePageState extends State<MyHomePage> {
  final listData = <User>[];
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 0.1);
  static const kExpandedHeight = 420.00;
  bool showValue = false;
  ScrollPhysics _physics = const BouncingScrollPhysics();
  @override
  void initState() {
    // _scrollController = ScrollController(initialScrollOffset: 0.1);
    _scrollController.addListener(() {
      setState(() {
        _isSliverAppBarExpanded;
      });
      if (_scrollController.position.pixels >= 56) {
        setState(() => _physics = const ClampingScrollPhysics());
      } else {
        setState(() => _physics = const BouncingScrollPhysics());
      }
    });
    listData
      ..add(User('User 1', 10))
      ..add(User('User 2', 15))
      ..add(User('User 3', 19));

    super.initState();
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset > kExpandedHeight - kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Color(0xff36B4D4)));
    const primaryColor = Color(0xff36B4D4);

    return CupertinoPageScaffold(
      // backgroundColor: Colors.red,
      // backgroundColor: C,

      // extendBodyBehindAppBar: false,
      // backgroundColor: primaryColor,
      child: CustomScrollView(
        // physics: _physics,
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            for (var index = 0; index < 30; index++) {
              var nama = 'User ${index + 1}';
              var nomor = Random().nextInt(100);
              listData.add(User(nama, nomor));
            }

            setState(() {});
          }, builder: (context, refreshState, pulledExtent,
              refreshTriggerPullDistance, refreshIndicatorExtent) {
            return Container(
              color: primaryColor,
              child: SafeArea(
                child: CustomRefresh.buildRefreshIndicator(
                    context,
                    refreshState,
                    pulledExtent,
                    refreshTriggerPullDistance,
                    refreshIndicatorExtent),
              ),
            );
          }),

          SliverAppBar(
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            backgroundColor: primaryColor,
            elevation: 0.0,
            excludeHeaderSemantics: true,
            // foregroundColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.grey[400]!, blurRadius: 2),
                    ],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                width: double.maxFinite,
                // padding: const EdgeInsets.only(top: 25, bottom: 35),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(8)),
                            height: 4,
                            width: 40,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "All Transactions",
                            style: TextStyle(
                                color: Colors.black.withOpacity(.7),
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          Icon(
                            Icons.archive_outlined,
                            size: 30,
                            color: Colors.black.withOpacity(.7),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            flexibleSpace: _isSliverAppBarExpanded
                ? null
                : FlexibleSpaceBar(
                    centerTitle: true,
                    // collapseMode: CollapseMode.pin,
                    // collapseMode: CollapseMode.pin,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 150,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(
                                  left: 20,
                                ),
                                child: Text(
                                  "Main Balance",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                ),
                                child: Row(
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Text(
                                        "551 805 091 | Main",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    Icon(
                                      Icons.copy,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 15, bottom: 5, left: 20),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        showValue ? "1,000,000" : "*** *** ***",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: showValue ? 30 : 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        "ZPOIN",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 23,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showValue = !showValue;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                            color: Colors.transparent,
                                            shape: BoxShape.circle),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.blueGrey
                                                  .withOpacity(.2),
                                              borderRadius:
                                                  BorderRadius.circular(60)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 5),
                                          child: const Icon(
                                            Icons.remove_red_eye_outlined,
                                            color: Colors.white,
                                            size: 13,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                  left: 20,
                                ),
                                child: Text(
                                  "Available Balance",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Stack(
                            children: [
                              Container(
                                height: 195,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              Container(
                                height: 120,
                                width: double.maxFinite,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)),
                                ),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            child: Icon(
                                              Icons.qr_code,
                                              color: primaryColor,
                                              size: 40,
                                            ),
                                          ),
                                          Text(
                                            "My QR",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            child: Icon(
                                              Icons.compare_arrows,
                                              color: primaryColor,
                                              size: 40,
                                            ),
                                          ),
                                          Text(
                                            "Transfer",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 10),
                                            child: Icon(
                                              Icons.savings,
                                              color: primaryColor,
                                              size: 40,
                                            ),
                                          ),
                                          Text(
                                            "Staking",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // title: const Text(
                    //   '_SliverAppBar',
                    //   style: TextStyle(color: Colors.red),
                    // ),
                    // expandedTitleScale: 1,
                    // titlePadding: EdgeInsets.zero,
                  ),
            title: _isSliverAppBarExpanded
                ? const Text(
                    'Main Balance',
                    style: TextStyle(color: Colors.white),
                  )
                : null,
            // stretch: false,
            floating: false,
            pinned: true,
            expandedHeight: kExpandedHeight,
            leading: const Icon(Icons.arrow_back_ios),
            // backgroundColor: Colors.white,
          ),

          // const SliverPadding(padding: EdgeInsets.only(top: 20)),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              var user = listData[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Card(
                  shadowColor: Colors.transparent,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                              "${((listData.length - index)).toString().padLeft(2, '0')} Mar 2023"),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Icon(
                                    (index + 1) % 2 == 0
                                        ? Icons.arrow_outward
                                        : Icons.arrow_downward_sharp,
                                    color: (index + 1) % 2 == 0
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  // child: Text("-${(index + 1) * 100}"),
                                  child: Text(
                                    user.nama,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              (index + 1) % 2 == 0
                                  ? "-${(index + 1) * 100} ZPOIN"
                                  : "${(index + 1) * 100} ZPOIN",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: (index + 1) % 2 == 0
                                      ? Colors.red
                                      : Colors.green),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: listData.length),
          ),
        ],
      ),
    );
  }
}
