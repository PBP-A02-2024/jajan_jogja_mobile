import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:jajan_jogja_mobile/nabeel/screens/search_page.dart';
import 'package:jajan_jogja_mobile/screens/profile.dart';
import 'package:jajan_jogja_mobile/zoya/screens/landing_page.dart';
import 'package:jajan_jogja_mobile/farrel/screens/food_plan_list.dart';

Container navbar(context, page) {
  return Container(
    height: 75,
    width: MediaQuery.sizeOf(context).width,
    alignment: Alignment.bottomCenter,
    color: Color(0xFFEBE9E1),
    padding: EdgeInsets.only(top: 7),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
            child: Column(children: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedHome11,
              color: page != "home" ? Color(0XFF7A7A7A) : Color(0xFFc98809),
              size: 24.0,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LandingPage()),
              );
            },
          ),
          Text(
            "Home",
            style: TextStyle(
                color: page != "home" ? Color(0XFF7A7A7A) : Color(0xFFc98809)),
          )
        ])),
        Center(
            child: Column(
          children: [
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: page != "search" ? Color(0XFF7A7A7A) : Color(0xFFc98809),
                size: 24.0,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
            ),
            Text(
              "Search",
              style: TextStyle(
                  color:
                      page != "search" ? Color(0XFF7A7A7A) : Color(0xFFc98809)),
            )
          ],
        )),
        Center(
            child: Column(
          children: [
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedVegetarianFood,
                color: page != "food plans"
                    ? Color(0XFF7A7A7A)
                    : Color(0xFFc98809),
                size: 24.0,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FoodPlanList()),
                );
              },
            ),
            Text(
              "Food Plans",
              style: TextStyle(
                  color: page != "food plans"
                      ? Color(0XFF7A7A7A)
                      : Color(0xFFc98809)),
            )
          ],
        )),
        Center(
            child: Column(
          children: [
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color:
                    page != "profile" ? Color(0XFF7A7A7A) : Color(0xFFc98809),
                size: 24.0,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            Text(
              "Profile",
              style: TextStyle(
                  color: page != "profile"
                      ? Color(0XFF7A7A7A)
                      : Color(0xFFc98809)),
            )
          ],
        )),
      ],
    ),
  );
}
