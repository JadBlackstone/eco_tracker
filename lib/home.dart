import 'dart:convert';
import 'package:bike_app/resetpassword.dart';
import 'package:footer/footer.dart';
import 'package:footer/footer_view.dart';
import 'package:bike_app/teams.dart';
import 'package:bike_app/welcome_guide.dart';
import 'package:flutter_layouts/flutter_layouts.dart';
import 'package:intl/intl.dart';
import 'registration.dart';
import 'route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';


import 'main.dart';
import 'functions.dart';
import 'login.dart';
import 'splashscreen.dart';
import 'history.dart';
import 'leaderboard.dart';
import 'achievement.dart';
import 'change_password.dart';
import 'co2.dart';
import 'profile.dart';

//TODO: Cache Clear with Image Upload
//TODO: ForgroundService Icon
//TODO: News Channel
//TODO: Community Goals
//TODO: Route on Map

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State{

  Functions functions = new Functions();

  var username;
  var score = 0.0;
  late Future<List> scoreboardFuture;
  var scoreboard;
  late Future<List> communityRoutesFuture;
  var communityRoutes;
  var yourRank = 0;
  var teamRank;
  var team = false;
  var userID = mainUserID;
  var teamID;
  var history;
  var co2 = 0.0;
  late Future<List> historyFuture;
  var helpSnackBar = SnackBar(content: Text("Tap on the Tiles to get to the other Screens."));
  var achievementNumber = 0;
  var navbarindex = 0;
  
  var pages = <Widget>[
    homeScreen(),
    LeaderBoard(),
    RouteScreen(),
    HistoryScreen(),
    TeamsScreen(),
  ];

  @override
  void initState() {
    /*print(guestLogin);
    communityRoutesFuture = createCommunityList();
    scoreboardFuture = createScoreboardList();
    if (!guestLogin) {
      /*functions.readUserIDFromStorage().then((String result) {
        setState(() {
          userID = result;
          print("set UserID");
        });
      });*/
      functions.getYourHistory().then((response) {
        if (response.statusCode != 200) {
          return;
        }
        var resp = json.decode(response.body);
        setState(() {
          history = resp;
          print(history);
          //print(DateFormat('dd.MM.yyyy - kk:mm').format(DateTime.parse(history[0][2])));
        });
      });
      historyFuture = createHistory();
      functions.readUsernameFromStorage().then((result) {
        setState(() {
          username = result;
        });
      });

      functions.getYourScore(userID).then((response) {
        if (response.statusCode != 200) {
          return;
        }
        var resp = json.decode(response.body);
        setState(() {
          score = resp['totalDistance'];
          if (score == null) {
            score = 0.0;
          }
          co2 = score * 128.1 / 1000;
        });
        print("Score updated");
      });
    }
    else {
      setState(() {
        historyFuture = guestHistory();
        history = [["","0.00", "1970-01-01T00:00:00.000Z"]];
        yourRank = 0;
      });
    }
    functions.getNumberOfAchievments(userID).then((response) {
      var resp = json.decode(response.body);
      setState(() {
        achievementNumber = resp['numberOfAchievements'];
      });
    });
    checkSavedRoutes();
    super.initState();
     */
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
        colors: [
        gradientstart,
        gradientend,
        ],
        //stops: [0.0,1.0],
        //tileMode: TileMode.clamp,
    )
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("EcoTracker"),
              Spacer(),
              //IconButton(onPressed: () {ScaffoldMessenger.of(context).showSnackBar(helpSnackBar);}, icon: Icon(Icons.help_outline)),
              IconButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProfileScreen(userID)));}, icon: Icon(Icons.account_circle_rounded))
            ],
          )
      ),
      drawer: Drawer(
        child: Container(
          color: gradientend,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(child: Column(children:
                [
                  Text("Settings",style: TextStyle(fontSize: 28),),
                ],)),
              ListTile(title: Text("Show Welcome Guide"), onTap: () {functions.showWelcomeGuide(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => WelcomeGuide()));}),
              Divider(),
              ListTile(title: Text("Change your Password"),onTap: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ChangePasswordScreen()));},),
              Divider(),
              ListTile(title: Text("Logout"),onTap: () {storage.deleteAll(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => SplashScreen()));},),
              Divider(),
              //ListTile(title: Text("Debugging (For Development only)"), onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => WelcomeGuide()));}),

              //ListTile(title: Text("Delete your Account"),onTap: () {deleteAccount();},),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        items: <Widget> [
          Icon(Icons.home),
          Icon(Icons.leaderboard_rounded),
          Icon(Icons.add_location_alt_rounded),
          Icon(Icons.calendar_today),
          Icon(Icons.people_rounded)
        ],
        onTap: (index) {
          setState(() {
            navbarindex = index;
          });

        },
      ),
      //Body
      body: pages[navbarindex])
    );
  }

  Future<List> createScoreboardList() async {
    var response = await functions.getScoreBoard();
    var resp = json.decode(response.body);
    setState(() {
      scoreboard = resp;
    });
    if(!guestLogin) {
      var username = await functions.readUsernameFromStorage();
      mainUsername = username;
      for (int i = 0; i < scoreboard.length; i++) {
        if (scoreboard[i][0] == username) {
          setState(() {
            yourRank = i + 1;
            //userID = scoreboard[i][2];
            teamID = scoreboard[i][3];
          });
        }
      }
      storage.write(key: "userID", value: userID.toString());
    }
    response = await functions.getTeamsList();
    resp = json.decode(response.body);
    print(resp);
    for(int i = 0; i < resp.length; i++)
      {
        if(resp[i][0] == teamID)
          {
            setState(() {
              teamRank = i + 1;
              team = true;
            });
          }
      }
    return resp;
  }

  Future<List> createCommunityList() async {
    var response = await functions.getCommunityRoutes();
    var resp = json.decode(response.body);
    setState(() {
      communityRoutes = resp;
    });
    return resp;
  }

  Future<List> createHistory() async {
    var response = await functions.getYourHistory();
    var resp = json.decode(response.body);
    setState(() {
      history = resp;
      print(history[0][1]);
      print(history[0][2]);
    });
    return resp;
  }

  void deleteAccount() async {
    var email = await storage.read(key: "email");
    var password = await storage.read(key: "password");
    var salt = await storage.read(key: "salt");
    var access_token = await storage.read(key: "access_token");
    var refresh_token = await storage.read(key: "refresh_token");
    print(email);
    print(password);
    print(salt);
    var response = await functions.deleteAccount(username, email!, password!, salt!, access_token!, refresh_token!);
    print(response.body);
    if (response.statusCode != 200)
      {
        print("Error while deleting account");
      }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => RegistrationScreen()));
  }

  Future<List> guestHistory() async {
    print("guestHistory()");
    return await new Future(() => [["1970-01-01T00:00:00.000Z","1","2"]]);
  }

  void checkSavedRoutes() async {
    var safedRoute = await storage.read(key: "lastRoute");
    if (safedRoute != null && safedRoute != "")
      {
        var response = await functions.submitRoute(double.parse(safedRoute));
        //print(response.body);
        if(response.statusCode == 200)
        {
          storage.delete(key: "lastRoute");
        }
      }
  }

}

class homeScreen extends StatefulWidget {
  @override
  _homeScreen createState() => _homeScreen();
}

class _homeScreen extends State {
  Functions functions = new Functions();
  var username = mainUserID;
  var userID = mainUserID;
  var score = 0.0;
  var co2 = 0.0;
  var scoreboard;
  var yourRank;
  var team = false;
  var teamID;
  var teamname;
  var teamRank;
  var historyFuture;
  var history;
  var achievementNumber;
  var communityRoutesFuture;
  var communityRoutes;
  var scoreboardFuture;

  @override
  void initState() {
    print(guestLogin);
    communityRoutesFuture = createCommunityList();
    scoreboardFuture = createScoreboardList();
    if (!guestLogin) {
      /*functions.readUserIDFromStorage().then((String result) {
        setState(() {
          userID = result;
          print("set UserID");
        });
      });*/
      functions.getYourHistory().then((response) {
        if (response.statusCode != 200) {
          return;
        }
        var resp = json.decode(response.body);
        setState(() {
          history = resp;
          print(history);
          //print(DateFormat('dd.MM.yyyy - kk:mm').format(DateTime.parse(history[0][2])));
        });
      });
      historyFuture = createHistory();
      functions.readUsernameFromStorage().then((result) {
        setState(() {
          username = result;
        });
      });

      functions.getYourScore(userID).then((response) {
        if (response.statusCode != 200) {
          return;
        }
        var resp = json.decode(response.body);
        setState(() {
          score = resp['totalDistance'];
          if (score == null) {
            score = 0.0;
          }
          co2 = score * 128.1 / 1000;
        });
        print("Score updated");
      });
    }
    else {
      setState(() {
        historyFuture = guestHistory();
        history = [["","0.00", "1970-01-01T00:00:00.000Z"]];
        yourRank = 0;
      });
    }
    functions.getNumberOfAchievments(userID).then((response) {
      print(response.body);
      var resp = json.decode(response.body);

      setState(() {
        achievementNumber = resp['numberOfAchievements'];
      });
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
    SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Stack(children: [
      /*Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/Images/HomeBackground.png"), fit: BoxFit.fitWidth, alignment: FractionalOffset.bottomCenter)),
                 width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height*0.3,),*/
      Column( children: [
        //Hello
        //Container(child: IconButton(onPressed: () {}, icon: Icon(Icons.menu)), alignment: Alignment.centerLeft,),
        Container(margin: EdgeInsets.only(top: 20, left: 10, bottom: 0, right: 10), padding: EdgeInsets.all(20), alignment: Alignment.topLeft,
          child: Text((!guestLogin)?"Welcome Back ${username}!":"Hello Guest\n", style: TextStyle(fontSize: 40),),),
        Container(child: offline?Text("Our Servers are currently down for maintenance. If you record a route it will be submitted, as soon as the Servers are back online."):Text("")),
        Container(child: guestLogin?ElevatedButton(onPressed: (()=>Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LoginScreen()))), child: Text("Go to Login")):Text(""), margin: EdgeInsets.only(bottom: 30),),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
            //color: Color(0xffdbdbdb),
            color: Colors.transparent,
          ),
          width: double.infinity,
          padding: EdgeInsets.all(15),
          child: Column(children: [
            SizedBox(height: 0,),
            Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                width: double.infinity,
                child: Column(children: [
                  Text("Overview", style: TextStyle(color: Colors.black, shadows: [], fontSize: 28),),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Your Score:", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),),
                      Text("$score km", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),)
                    ],
                  ),
                  Divider(color: Colors.grey,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Your Rank:", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),),
                      Text("#$yourRank", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),),
                    ],
                  ),
                  Divider(color: Colors.grey,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Your Team:", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),),
                      Text("$teamname", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),),
                    ],
                  ),
                ],)
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CO2Screen()));},
              child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  width: double.infinity,
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Saved CO2", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),),
                        Row(
                          children: [
                            Text("${co2.toStringAsFixed(2)} Kg", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ],
                    ),
                  ],)
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TeamsScreen()));},
              child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  width: double.infinity,
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Team Rank", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),),
                        Row(
                          children: [
                            Text("#$teamRank", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ],
                    ),
                  ],)
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AchievementScreen(userID)));},
              child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  width: double.infinity,
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Achievements", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),),
                        Row(
                          children: [
                            Text("$achievementNumber", style: TextStyle(color: Colors.black, shadows: [], fontSize: 18),),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ],
                    ),
                  ],)
              ),
            ),
          ],),),

        //Tiles
        /*GridView.count(physics: NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 10, shrinkWrap: true, padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            homeScreenCard(text1: "Your Score:", text2: "$score km", displayIcon: false, icon: Icons.leaderboard),
            InkWell(
                onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CO2Screen()));},
                child: homeScreenCard(text1: "You saved:", text2: "${co2.toStringAsFixed(3)} kg CO2", displayIcon: true, icon: Icons.arrow_forward)
            ),
            homeScreenCard(text1: "Your Rank:", text2: "#$yourRank", displayIcon: false, icon: Icons.leaderboard),
            InkWell(
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TeamsScreen()));},
              child: homeScreenCard(text1: "Team Rank", text2: team? "#$teamRank":"No Team", displayIcon: true, icon: Icons.arrow_forward),
            ),
            // Your History
            InkWell(
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HistoryScreen()));},
              child: Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 3,
                        blurRadius: 20,
                        offset: Offset(0,3))
                    ]
                ),
                child: Column(
                  children: [
                    Text("History", style: TextStyle(fontSize: 20, color: Colors.black, shadows: []), textAlign: TextAlign.center,),
                    Spacer(),
                    FutureBuilder(
                        future: historyFuture,
                        builder: (context, snapshot) {
                          if(!snapshot.hasData) {
                            return Center(child: Text("No Data",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black, shadows: []),));
                          } else {
                            return Column(children: [Text("${DateFormat('dd.MM.yyyy').format(DateTime.parse(history[0][2]))}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black, shadows: []), textAlign: TextAlign.center,),
                              Text("${history[0][1]} Km", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black, shadows: []), textAlign: TextAlign.center,),
                            ],);
                          }
                        }),
                    Spacer(),
                    //Icon(Icons.calendar_today),
                  ],),),),
            InkWell(
                onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AchievementScreen(userID)));},
                child: homeScreenCard(text1:"Achievements", text2: "$achievementNumber", fontsize: 18, displayIcon: true, icon: Icons.arrow_forward)
            ),
          ],),*/

        //Community History
        /*Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(25),
            width: MediaQuery.of(context).size.width*80,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 3,
                    blurRadius: 20,
                    offset: Offset(0,3)
                )]
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text("Last 10 Routes", style: TextStyle(fontSize: 28, color: Colors.black, shadows: []),),),
                FutureBuilder(
                    future: communityRoutesFuture,
                    builder: (context, AsyncSnapshot snapshot) {
                      if(!snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicator());
                      } else {
                        return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap:true,
                            itemCount: 10,
                            itemBuilder: (BuildContext context, int index)
                            {
                              return ListTile(
                                leading:Text("${DateFormat('dd.MM.yyyy - kk:mm').format(DateTime.parse(communityRoutes[index][2]))}", style: TextStyle(color: Colors.black, shadows: []),),
                                title:Text("${communityRoutes[index][0]}", style: TextStyle(color: Colors.black, shadows: [])),
                                trailing: Text("${communityRoutes[index][1]}", style: TextStyle(color: Colors.black, shadows: [])),
                              );
                            });
                      }
                    }
                ),
              ],)
        )*/
        Container(height: 75,),
      ],),
    ],)
      ,),
    );
  }

  Future<List> guestHistory() async {
    print("guestHistory()");
    return await new Future(() => [["1970-01-01T00:00:00.000Z","1","2"]]);
  }

  Future<List> createCommunityList() async {
    var response = await functions.getCommunityRoutes();
    var resp = json.decode(response.body);
    setState(() {
      communityRoutes = resp;
    });
    return resp;
  }

  Future<List> createHistory() async {
    var response = await functions.getYourHistory();
    var resp = json.decode(response.body);
    setState(() {
      history = resp;
      print(history[0][1]);
      print(history[0][2]);
    });
    return resp;
  }

  Future<List> createScoreboardList() async {
    var response = await functions.getScoreBoard();
    var resp = json.decode(response.body);
    setState(() {
      scoreboard = resp;
    });
    if(!guestLogin) {
      var username = await functions.readUsernameFromStorage();
      mainUsername = username;
      for (int i = 0; i < scoreboard.length; i++) {
        if (scoreboard[i][0] == username) {
          setState(() {
            yourRank = i + 1;
            //userID = scoreboard[i][2];
            teamID = scoreboard[i][3];
          });
          var response2 = await functions.getTeamName(teamID.toString());
          var resp2 = json.decode(response2.body);
          teamname = resp2["TeamName"];
        }
      }
      storage.write(key: "userID", value: userID.toString());
    }
    response = await functions.getTeamsList();
    resp = json.decode(response.body);
    print(resp);
    for(int i = 0; i < resp.length; i++)
    {
      if(resp[i][0] == teamID)
      {
        setState(() {
          teamRank = i + 1;
          team = true;
        });
      }
    }
    return resp;
  }

}

class homeScreenCard extends StatelessWidget {
  String text1;
  String text2;
  IconData icon;
  double fontsize;
  bool displayIcon;

  homeScreenCard({required this.text1, required this.text2, this.fontsize:20, required this.icon, required this.displayIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [BoxShadow(
                color: Colors.black12,
                spreadRadius: 3,
                blurRadius: 20,
                offset: Offset(0,3))
            ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(text1, style: TextStyle(fontSize: this.fontsize, shadows: [], color: Colors.black), textAlign: TextAlign.center,),
            Spacer(),
            Text(text2, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, shadows: [], color: Colors.black), textAlign: TextAlign.center),
            Spacer(),
            displayIcon?Icon(icon):Text(""),
            Spacer(),
          ],
        ),
      );
  }
}