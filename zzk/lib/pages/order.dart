import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zzk/logic/csvReader.dart';

import '../classes/FoodSectionClass.dart';
import 'sub/body.dart';

class OrderPage extends StatefulWidget {
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  ScrollController _scrollController = ScrollController();
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrollPosition = _scrollController.offset;
    final maxScroll = 200.0; // Adjust this value to control how quickly opacity changes

    setState(() {
      _opacity = 1.0 - (scrollPosition / maxScroll).clamp(0.0, 1.0);
    });
  }

  Future<List<FoodSection>> menuData = read();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: menuData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 240.0,
                  floating: false,
                  titleSpacing: 30,
                  centerTitle: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    /* Title */
                    title: Container(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: -8 * 2,
                            right: -8 * 2,
                            top: -4 * 2,
                            bottom: -4 * 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(sqrt(_opacity)),
                                borderRadius: BorderRadius.circular(0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5 * _opacity * _opacity),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            'Our Menu',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    /* Top Image */
                    background: Image.network(
                      'https://www.eatright.org/-/media/images/eatright-landing-pages/foodgroupslp_804x482.jpg?as=0&w=967&rev=d0d1ce321d944bbe82024fff81c938e7&hash=E6474C8EFC5BE5F0DA9C32D4A797D10D',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (snapshot.hasError)
                  SliverFillRemaining(
                    child: Center(
                      child: Text('An error occurred while loading the menu.'),
                    ),
                  ),
                if (snapshot.hasData)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      /**
                       * !SECTION 
                       * This is where the menu is shown
                       */
                      (BuildContext context, int index) {
                        if (index >= snapshot.data.length) return null;
                        // return _buildFoodSection(snapshot.data[index]);
                        return OrderPageBody(
                          key: ValueKey(snapshot.data[index].name),
                          section: snapshot.data[index],
                        );
                      },
                      childCount: snapshot.data.length,
                    ),
                  ),
              ],
            ),
          );
        });
  }
}