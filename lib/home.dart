import 'dart:convert';

import 'package:bike_app/teams.dart';
import 'package:bike_app/welcome_guide.dart';
import 'package:flutter_layouts/flutter_layouts.dart';
import 'package:intl/intl.dart';
import 'registration.dart';
import 'route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'main.dart';
import 'functions.dart';
import 'login.dart';
import 'splashscreen.dart';
import 'history.dart';
import 'leaderboard.dart';
import 'achievement.dart';
import 'change_password.dart';
import 'co2.dart';

//Must till publish
//TODO: CO2 Screen of Community
//TODO: Icons

//Optional:
//TODO: Replace AppBar
//TODO: Offline Mode
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
  var yourRank = 0;
  var teamRank;
  var team = false;
  var userID;
  var teamID;
  var history;
  var co2 = 0.0;
  late Future<List> historyFuture;

  @override
  void initState() {
    functions.getYourHistory().then((response) {
      if(response.statusCode != 200) {return;}
      var resp = json.decode(response.body);
      setState(() {
        history = resp;
        print(history);
        //print(DateFormat('dd.MM.yyyy - kk:mm').format(DateTime.parse(history[0][2])));
        //print(DateFormat('dd.MM.yyyy - kk:mm').format(DateTime.parse(history[0][2])));
      });
    });
    historyFuture = createHistory();
    scoreboardFuture = createScoreboardList();
    super.initState();
    functions.readUsernameFromStorage().then((result) {
      setState(() {
        username = result;
      });
    });
    functions.getYourScore().then((response) {
      if(response.statusCode != 200) {return;}
      var resp = json.decode(response.body);
      setState(() {
        score = resp['totalDistance'];
        if (score == null) {score = 0.0;}
        co2 = score*128.1/1000;
      });
      print("Score updated");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("EcoTracker")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(child: Column(children:
              [
                Text("Settings",style: TextStyle(fontSize: 28),),
              ],)),
            ListTile(title: Text("Show Welcome Guide"), onTap: () {functions.showWelcomeGuide(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => WelcomeGuide()));}),
            Divider(),
            ListTile(title: Text("Change your Password"),onTap: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ChangePasswordScreen()));},),            Divider(),
            ListTile(title: Text("Logout"),onTap: () {storage.deleteAll(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => SplashScreen()));},),
            Divider(),
            //ListTile(title: Text("Delete your Account"),onTap: () {deleteAccount();},),
            //Divider()
          ],
        ),
      ),
      //Body
      body: SafeArea(child: Footer(
        body: SingleChildScrollView(child: Stack(children: [
              Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/Images/HomeBackground.png"), fit: BoxFit.fitWidth, alignment: FractionalOffset.bottomCenter)),
                 width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height*0.3,),
              Column( children: [
                //Hello
                //Container(child: IconButton(onPressed: () {}, icon: Icon(Icons.menu)), alignment: Alignment.centerLeft,),
                Container(margin: EdgeInsets.only(top: 20, left: 10, bottom: 10, right: 10), padding: EdgeInsets.all(20), alignment: Alignment.topLeft,
                  child: Text("Welcome Back\n${username}!", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),),),
                Container(height: MediaQuery.of(context).size.height*0.05,),
                //Tiles
                GridView.count(physics: NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 10, shrinkWrap: true, padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    InkWell(onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LeaderBoard()));},
                    child: Container(margin: EdgeInsets.all(5), padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 3, blurRadius: 5, offset: Offset(0,3))]),
                      child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        Text("Your Score:", style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),
                        Spacer(),
                        Text("$score km", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        Spacer(),
                      ],),),),
                    InkWell(onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CO2Screen()));},
                    child: Container(margin: EdgeInsets.all(5), padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 3, blurRadius: 5, offset: Offset(0,3))]),
                      child: Column(children: [
                        Text("You saved:", style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),
                        Spacer(),
                        Text("${co2.toStringAsFixed(3)} kg CO2", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                        Spacer(),
                      ],),),),
                    InkWell(onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LeaderBoard()));},
                    child: Container(margin: EdgeInsets.all(5), padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 3, blurRadius: 5, offset: Offset(0,3))]),
                      child: Column(children: [
                        Text("Your Rank:", style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),
                        Spacer(),
                        Text("#$yourRank", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                        Spacer(),
                      ],),),),
                    InkWell(onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TeamsScreen()));},
                      child: Container(margin: EdgeInsets.all(5), padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 3, blurRadius: 5, offset: Offset(0,3))]),
                        child: Column(children: [
                          Text("Team Rank:", style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),
                          Spacer(),
                          Text(team? "#$teamRank":"No Team", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                          Spacer(),
                        ],),),),
                    InkWell(onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HistoryScreen()));},
                      child: Container(margin: EdgeInsets.all(5), padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 3, blurRadius: 5, offset: Offset(0,3))]),
                        child: Column(children: [
                          Text("History", style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),
                          Spacer(),
                          FutureBuilder(future: historyFuture, builder: (context, snapshot) {
                            if(!snapshot.hasData) {
                              return Center(child: Text("No Data",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),));
                            } else {
                              return Column(children: [Text("${DateFormat('dd.MM.yyyy').format(DateTime.parse(history[0][2]))}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                Text("${history[0][1]} Km", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                ],);
                            }
                          }),

                          //Text("${DateFormat('dd.MM.yyyy - kk:mm').format(DateTime.parse(history[0][1]))} Km", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                          Spacer(),
                      ],),),),
                    InkWell(onTap: () {Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AchievementScreen()));},
                      child: Container(margin: EdgeInsets.all(5), padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 3, blurRadius: 5, offset: Offset(0,3))]),
                        child: Column(children: [
                          Text("", style: TextStyle(fontSize: 18,), textAlign: TextAlign.center,),
                          Spacer(),
                          Text("Achievements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                          Spacer(),
                      ],),),),
                  ],),
                //Leaderboard
                Container(padding: EdgeInsets.all(10), margin: EdgeInsets.all(25),  width: MediaQuery.of(context).size.width*80,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 3, blurRadius: 5, offset: Offset(0,3))]),
                    child: Column(children: [
                      Padding(padding: EdgeInsets.only(top: 10), child: Text("Leaderboard", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),),
                      FutureBuilder(future: scoreboardFuture, builder: (context, AsyncSnapshot snapshot) {
                        if(!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return ListView.builder(physics: NeverScrollableScrollPhysics(), shrinkWrap:true, itemCount: 3, itemBuilder: (BuildContext context, int index)
                          {
                            return ListTile(
                              leading: Text("${index+1}"),
                              title:Text("${scoreboard[index][0]}"),
                              trailing: Text("${scoreboard[index][1]}"),
                            );
                          });
                        }
                      }),
                    ],)
                ),
                //News Channel
                /*Container(padding: EdgeInsets.all(10), margin: EdgeInsets.only(top: 0, left: 25, bottom: 25, right: 25),  width: MediaQuery.of(context).size.width*80,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 3, blurRadius: 5, offset: Offset(0,3))]),
                    child: Column(children: [
                      Padding(padding: EdgeInsets.only(top: 10), child: Text("News", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),),
                      FutureBuilder(future: scoreboardFuture, builder: (context, AsyncSnapshot snapshot) {
                        if(!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return ListView.builder(physics: NeverScrollableScrollPhysics(), shrinkWrap:true, itemCount: 1, itemBuilder: (BuildContext context, int index)
                          {
                            return ListTile(
                              title:Text("Hallo hier was neues"),
                              subtitle: Text("test2 bla bla blub"),
                            );
                          });
                        }
                      }),
                    ],)
                ),*/
              ],),
            ],)
          ,),
        footer: Container(padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 3, blurRadius: 5, offset: Offset(0,-3))]),
          child: ElevatedButton(onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => RouteRecording()));}, child: Text("Start new Route")),),
        ),
      ));
  }

  Future<List> createScoreboardList() async {
    var response = await functions.getScoreBoard();
    var resp = json.decode(response.body);
    setState(() {
      scoreboard = resp;
    });
    var username = await functions.readUsernameFromStorage();
    for(int i = 0; i < scoreboard.length; i++)
      {
        if(scoreboard[i][0] == username)
          {
            setState(() {
              yourRank = i + 1;
              userID = scoreboard[i][2];
              teamID = scoreboard[i][3];
            });
          }
      }
    storage.write(key: "userID", value: userID.toString());
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

}