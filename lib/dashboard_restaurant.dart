import 'dart:async';

import 'package:ente/detail.dart';
import 'package:ente/model/restaurant_model.dart';
import 'package:ente/profile.dart';
import 'package:ente/service/restaurant_service.dart';
import 'package:flutter/material.dart';

class DashBoardRestaurant extends StatefulWidget {
  const DashBoardRestaurant({super.key});

  @override
  State<DashBoardRestaurant> createState() => _DashBoardRestaurantState();
}

class _DashBoardRestaurantState extends State<DashBoardRestaurant> {
  late Future<List<Restaurant>> futureRestaurants;
  String? selectedLocation;
  String? selectedType;
  late PageController _pageController;
  late Timer _timer;
  int _selectedIndex = 0;

  @override
  void initState() {
    futureRestaurants = RestaurantService().fetchRestaurants();
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
      const Center(
          child: const Text('Bookmarks Page')), // Dummy page for bookmarks
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
        FutureBuilder<List<Restaurant>>(
          future: futureRestaurants,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No restaurants found'));
            } else {
              final data = snapshot.data!;
              final filteredData = data
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
                                      onTap: () {
                                        // Handle bookmark action
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.bookmark,
                                              color: Colors.grey),
                                          SizedBox(width: 4),
                                          Text(
                                            "Bookmark",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.grey,
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
