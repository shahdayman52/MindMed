import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Map<String, String>> cardsData = [
    {
      "title": "Meditation",
      "image": "assets/images/homepage_widget.png",
    },
    {
      "title": "ChatBot",
      "image": "assets/images/homepage_widget2.png",
    },
    {
      "title": "Community",
      "image": "assets/images/homepage_widget3.png",
    },
    {
      "title": "Journal",
      "image": "assets/images/homepage_widget4.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/homepage_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 90.0, bottom: 20.0, left: 30),
              child: Text(
                'Hello Friend',
                style: TextStyle(
                    fontSize: 24, color: Colors.white, fontFamily: 'Roboto'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30.0, bottom: 10.0),
              child: Text(
                'How are you feeling \n today?',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            Expanded(
              child: PageView.builder(
                onPageChanged: (int index) {
                  setState(() {});
                },
                itemCount: cardsData.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: SizedBox(
                      width: 350,
                      height: 420,
                      child: Card(
                        color: Colors.white,
                        elevation: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 360,
                              width: double.infinity,
                              child: Image.asset(
                                cardsData[index]['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              cardsData[index]['title']!,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Set background color to white
        items: const [
          BottomNavigationBarItem(
            icon: Iconify(Mdi.home_outline, size: 30.0, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Iconify(Mdi.account_outline, size: 30.0, color: Colors.black),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Iconify(Mdi.chat_outline, size: 30.0, color: Colors.black),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Iconify(Mdi.account_group_outline,
                size: 30.0, color: Colors.black),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon:
                Iconify(Mdi.book_open_outline, size: 30.0, color: Colors.black),
            label: 'Journal',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        iconSize: 35.0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
