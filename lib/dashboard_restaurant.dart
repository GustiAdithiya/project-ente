import 'dart:async';

import 'package:ente/detail.dart';
import 'package:ente/model/bookmark_model.dart';
import 'package:ente/model/restaurant_model.dart';
import 'package:ente/profile.dart';
import 'package:ente/service/bookmark_service.dart';
import 'package:ente/service/restaurant_service.dart';
import 'package:flutter/material.dart';

class DashBoardRestaurant extends StatefulWidget {
  const DashBoardRestaurant({super.key});

  @override
  State<DashBoardRestaurant> createState() => _DashBoardRestaurantState();
}

class _DashBoardRestaurantState extends State<DashBoardRestaurant> {
  String? selectedLocation;
  String? selectedType;
  late PageController _pageController;
  late Timer _timer;
  int _selectedIndex = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
        if (_pageController.page == 2) {
          _pageController.animateToPage(0,
              duration: const Duration(seconds: 10), curve: Curves.easeIn);
        } else {
          _pageController.nextPage(
              duration: const Duration(seconds: 10), curve: Curves.easeIn);
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      _buildHomePage(),
      _buildBookmarkPage(),
      ProfilePage(), // Profile page
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  FutureBuilder<List<dynamic>> _buildBookmarkPage() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        RestaurantService().fetchRestaurants(),
        BookmarkService().fetchBookmarks("4"),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          List<dynamic> data = snapshot.data!;
          List<Restaurant> restaurants = data[0];
          List<Bookmark> bookmarks = data[1];

          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              Bookmark bookmark = bookmarks[index];
              // Find the corresponding restaurant for the current bookmark
              Restaurant? restaurant = restaurants.firstWhere(
                (restaurant) =>
                    restaurant.id == int.parse(bookmark.warungmakanId),
              );
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.network(
                          restaurant.urlPhoto,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(restaurant.type),
                            SizedBox(height: 20),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on),
                                    SizedBox(width: 10),
                                    Text(restaurant.location),
                                  ],
                                ),
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      BookmarkService().deleteBookmark(
                                          bookmark.id.toString());
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.remove, color: Colors.red),
                                    label: Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      side: BorderSide(
                                          color: Colors.red, width: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  ListView _buildHomePage() {
    return ListView(
      children: [
        SizedBox(
          height: 200,
          child: PageView(
            controller: _pageController,
            children: [
              Image.network(
                'https://t3.ftcdn.net/jpg/03/24/73/92/360_F_324739203_keeq8udvv0P2h1MLYJ0GLSlTBagoXS48.jpg',
                fit: BoxFit.cover,
              ),
              Image.network(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLYVZ9gomEgd5qrt-iA4-oJoNPzpn033360g&s',
                fit: BoxFit.cover,
              ),
              Image.network(
                'https://img.freepik.com/free-photo/restaurant-interior_1127-3394.jpg',
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedLocation = null;
                    selectedType = null;
                  });
                },
                icon: const Icon(Icons.refresh),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: DropdownButton<String>(
                  value: selectedLocation,
                  onChanged: (newValue) {
                    setState(() {
                      selectedLocation = newValue;
                    });
                  },
                  items: ['Sukapura', 'Sukabirus', 'Gapura', 'Other']
                      .map<DropdownMenuItem<String>>(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  hint: const Text('Select Location'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: DropdownButton<String>(
                  value: selectedType,
                  onChanged: (newValue) {
                    setState(() {
                      selectedType = newValue;
                    });
                  },
                  items: ['Main Course', 'Beverage']
                      .map<DropdownMenuItem<String>>(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  hint: const Text('Select Type'),
                ),
              ),
            ],
          ),
        ),
        FutureBuilder<List<dynamic>>(
          future: Future.wait([
            RestaurantService().fetchRestaurants(),
            BookmarkService().fetchBookmarks("4")
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No restaurants found'));
            } else {
              final restaurants = snapshot.data![0] as List<Restaurant>;
              final bookmarks = snapshot.data![1] as List<Bookmark>;
              final bookmarkedWarungmakanIds =
                  bookmarks.map((bookmark) => bookmark.warungmakanId).toSet();

              final filteredData = restaurants
                  .where((resto) =>
                      selectedLocation == null ||
                      resto.location == selectedLocation)
                  .where((resto) =>
                      selectedType == null || resto.type == selectedType)
                  .toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredData.length,
                itemBuilder: (BuildContext context, int index) {
                  final restaurant = filteredData[index];
                  final isBookmarked = bookmarkedWarungmakanIds
                      .contains(restaurant.id.toString());
                  final bookmarkId = isBookmarked
                      ? bookmarks
                          .firstWhere((bookmark) =>
                              bookmark.warungmakanId ==
                              restaurant.id.toString())
                          .id
                      : null;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            title: restaurant.name,
                            image: restaurant.urlPhoto,
                            location: restaurant.location,
                            type: restaurant.type,
                            userId: '1',
                            warungmakanId: restaurant.id.toString(),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: Image.network(
                              restaurant.urlPhoto,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      restaurant.name,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          restaurant.location,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      restaurant.type,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        if (isBookmarked) {
                                          await BookmarkService()
                                              .deleteBookmark(
                                                  bookmarkId.toString());
                                        } else {
                                          await BookmarkService().storeBookmark(
                                              "4", restaurant.id.toString());
                                        }
                                        setState(() {});
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.bookmark,
                                            color: isBookmarked
                                                ? Colors.indigo
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Bookmark",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: isBookmarked
                                                  ? Colors.indigo
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }
}
