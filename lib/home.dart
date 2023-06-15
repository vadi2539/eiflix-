import 'dart:async';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:elflix/myList.dart';
import 'package:elflix/search.dart';
import 'package:elflix/series.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elflix/episode.dart';
import 'package:elflix/episodePlayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class home extends StatefulWidget {
  
  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController textController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool isLoading = true;
  late bool hasWatchedVideo = false;
  late List<String> tabData;
  String? userid;
  String? email;
  String? gmailId;
  String? collectiondata;
  String? data;
  List usertier = [];
  List categoryList = [];
  List seriesMetaDataLists = [];
  List popularvideo = [];
  List recentlyAdded = [];
  List categoryseriesLists = [];
  Map<String, dynamic> seriesName = {};
  List<String> seriesname = [];
  Map<String, dynamic> tierMap = {};
  List episodesList = [];
  List<String> tierNames=[];
  List<Map<String, dynamic>> continueWatchEpisodes = [];
  List searchList=[];
  // String seriesName;

  @override
  void initState() {
    super.initState(); 
    //user auth
    setState(() {
        userid = auth.currentUser?.uid;
        email = auth.currentUser?.email;
        gmailId = email?.split('@').first;
      });
    //tier
    firestore.collection('user').doc(userid).get().then((value) {
        if(value.data()?['tier'] != null){
          setState(() {
            usertier = value.data()?['tier']; 
          });
        }
      }).then((_)async{
    //tier mapping
      await firestore.collection('tier').get().then((value) async {
        Map<String, dynamic> map = {};
        for(int i =0; i<value.docs.length;i++){
          var tireData= value.docs[i];
          map[tireData.data()['tier']] = tireData.reference;  
        }
        setState(() {
          tierMap = map;
          isLoading = false;
        });

      });
    });
    //episode docs
    firestore.collection('episodes').get().then((value) {
      if (value.docs.length != 0) {
        var episodeslist = [];
        for (int i = 0; i < value.docs.length; i++) {
          episodeslist.add(value.docs[i]);
        }
        setState(() {
          episodesList = episodeslist;
        });
      }
    });
    //spilt null category and display sequnence episode
    var uncategorizedserieslist = [];
    firestore.collection('series').get().then((value) async {
      if (value.docs.isNotEmpty) {
        for (int i = 0; i < value.docs.length; i++) {
          var element = value.docs[i].data();
          if (element['category'] == null) {
            var map = {};
            map['episodes'] = [];
            map['seriesData'] = element;
            map['sequence'] = element['sequence'];
            map['episodes'] = [];
            for (int j = 0; j < element['sequence'].length; j++) {
              var sequence = element['sequence'][j];
              await firestore.collection('episodes').doc(sequence.id).get().then((episode) {
                map['episodes'].add(episode.data());
              });
            }
            uncategorizedserieslist.add(map);
          }
        }
      }
      setState(() {
        seriesMetaDataLists = uncategorizedserieslist;
      });
    });
    // series collection docs
    firestore.collection('series').get().then((value)async {
      for (int i = 0; i < value.docs.length; i++) {
        categoryseriesLists.add(value.docs[i]);
      }
    });
    //catagory data
    firestore.collection('category').get().then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        categoryList.add(value.docs[i].data());
      }
    });
    //continue watching  
    firestore.collection('user').doc(userid).collection('watchedVideos').get().then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        continueWatchEpisodes.add(value.docs[i].data());
      }
      continueWatchEpisodes = continueWatchEpisodes.where((video) => video['playbackTime'] < video['duration']).toList();
    }); 
    //popular videos 
    firestore.collection('episodes').orderBy('views',descending: true).limit(10).get().then((value) {
      for(int i =0 ; i<value.docs.length;i++){
        popularvideo.add(value.docs[i].data());
      }
    });
    //Recently Added
    firestore.collection('series').orderBy('date',descending:true).limit(5).get().then((value){
      for (int i = 0; i < value.docs.length; i++) {
        recentlyAdded.add(value.docs[i].data());
      }
    });
    //shimmer backgroud shadow timer
    Timer(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.black,
    body: isLoading
      ? SingleChildScrollView(
          child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 290,
              child: Shimmer.fromColors(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                ),
                baseColor: Colors.grey.shade900,
                highlightColor: Colors.grey.shade700,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              margin: EdgeInsets.only(
                top: 30,
              ),
              child: Shimmer.fromColors(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                ),
                baseColor: Colors.grey.shade900,
                highlightColor: Colors.grey.shade700,
              ),
            ),
            Container(
              height: 180,
              margin: EdgeInsets.only(top: 20, left: 10),
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: 7,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, index) {
                  return Container(
                      padding: EdgeInsets.all(8.0),
                      height: 140,
                      width: 250,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade900,
                        highlightColor: Colors.grey.shade700,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                        ),
                      ));
                },
              ),
            ),
            Container(
                height: 10,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 5),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade900,
                  highlightColor: Colors.grey.shade700,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                  ),
                )),
            Container(
              height: 180,
              margin: EdgeInsets.only(top: 0, left: 10),
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: 7,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, index) {
                  return Container(
                      padding: EdgeInsets.all(8.0),
                      height: 140,
                      width: 250,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade900,
                        highlightColor: Colors.grey.shade700,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                        ),
                      ));
                },
              ),
            ),
            Container(
              height: 10,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 5),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade900,
                highlightColor: Colors.grey.shade700,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                ),
              )
            ),
             Container(
              height: 180,
              margin: EdgeInsets.only(top: 0, left: 10),
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: 7,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, index) {
                  return Container(
                      padding: EdgeInsets.all(8.0),
                      height: 140,
                      width: 250,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade900,
                        highlightColor: Colors.grey.shade700,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                        ),
                      ));
                },
              ),
            ),
          ],
        ))
      :SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [      
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Image.network(
                            height: 290,
                            // width: double.infinity,
                            'https://firebasestorage.googleapis.com/v0/b/eiflix.appspot.com/o/images%2F1685608542983_Hero%20Test%20850.png?alt=media&token=41e70d3a-cbe6-4df9-943d-e134262707a2',
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade800.withOpacity(0.2),
                                highlightColor:Colors.grey.shade900,
                                child: Container(
                                  height: 290,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.99),
                                Colors.black.withOpacity(0)
                              ],
                              // end: Alignment.topLeft,
                              //  begin: Alignment.bottomRight
                            )),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 200, left: 35),
                            child: Row(
                              children: [
                                Container(
                                  height: 30,
                                  child: Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.play_circle,
                                          size: 18,
                                          color: Colors.black,
                                        ),
                                        label: Text(
                                          'WATCH',
                                          style: TextStyle(
                                              fontSize: 10, color: Colors.black),
                                        ),
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.grey),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.add,
                                          size: 18,
                                          color: Colors.black,
                                        ),
                                        label: Text('ADD LIST',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black)),
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                          ),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                'ElFlix',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            Row(
                              children: [
                                // AnimSearchBar(
                                //   width: 200,
                                //    textController: textController, 
                                //    onSuffixTap: (){
                                //     setState(() {
                                //      textController.clear();
                                //     });
                                //    }, onSubmitted: (query ) { 
                                   
                                //     }, 
                                //    color: Colors.transparent,
                                //    helpText: 'Search Here...' ,
                                //    closeSearchOnSuffixTap: true,
                                //    autoFocus: true,
                                //    rtl: true,
                                //    ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(context,MaterialPageRoute(builder: (context) =>searchbar()));  
                                  },
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  )
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(   
                                    Icons.notifications,
                                    color: Colors.white,
                                  )
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: PopupMenuButton<String>(
                                    color: Colors.grey.shade900,
                                    itemBuilder: (context) => [
                                      PopupMenuItem<String>(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.account_circle,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              gmailId ?? 'N/A',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                          child: FlatButton(
                                        onPressed: () {
                                          FirebaseAuth.instance.signOut();
                                        },
                                        color: Colors.white60,
                                        child: Row(
                                          children: [
                                            Icon(Icons.exit_to_app),
                                            SizedBox(width: 8),
                                            Text('Sign Out'),
                                          ],
                                        ),
                                      )),
                                    ],
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.transparent,
                                      child: Icon(Icons.person),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                'Home',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    backgroundColor: Colors.transparent,
                                    fontSize: 13),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                'Playlists',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    backgroundColor: Colors.transparent,
                                    fontSize: 13),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context,MaterialPageRoute(builder: (context) =>series()));
                              },
                              child: Text(
                                'Series',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    backgroundColor: Colors.transparent,
                                    fontSize: 13),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
                              ),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                Navigator.push(context,MaterialPageRoute(builder: (context) =>myList()));
                              },
                              child: Text(
                                'Mylist',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 13),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),          
              ],
            ), 
            SizedBox(
              height: 0,
            ),
            //TabBar 
            Container(
              height: 270,
              child: Visibility(
                child: DefaultTabController(
                  length: continueWatchEpisodes.isEmpty ? 3 :4,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: TabBar(
                          indicatorColor: Colors.white38,
                          tabs: continueWatchEpisodes.isEmpty ? [
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star_border_outlined,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('Popular',
                                        style: TextStyle(fontSize: 8,color: Colors.white)
                                    ),
                                  ],
                                ),
                              )
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star_border_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('Premium',
                                        style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.white)
                                    ),
                                  ],
                                ),
                              )
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('Recently Added',
                                      style: TextStyle(fontSize: 8,color: Colors.white)
                                    ),
                                  ],
                                ),
                              )
                            ),
                          ]
                          : [                    
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.timelapse_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('Continue Watching',
                                      style: TextStyle(fontSize: 8,color: Colors.white
                                      )
                                    ),
                                  ],
                                ),
                              )
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star_border_outlined,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('Popular',
                                        style: TextStyle(fontSize: 8,color: Colors.white)
                                    ),
                                  ],
                                ),
                              )
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star_border_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('Premium',
                                        style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.white)
                                    ),
                                  ],
                                ),
                              )
                            ),
                            Tab(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('Recently Added',
                                      style: TextStyle(fontSize: 8,color: Colors.white)
                                    ),
                                  ],
                                ),
                              )
                            ),
                          ],   
                        ),
                      ),
                      Expanded(   
                        child:TabBarView(
                          children: continueWatchEpisodes.isEmpty? [
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 10, left: 10),
                                child: ListView.builder(
                                  itemCount: popularvideo.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    var popularVideoList =popularvideo[index];
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            // Navigator.push(context,
                                                            //   MaterialPageRoute(builder: (context) =>
                                                            //     episodePlayer(
                                                            //       videoUrl: watchHistory['videoUrl'],
                                                            //     )
                                                            //   ),
                                                            // );
                                                          },
                                                          child: Wrap(
                                                            alignment:
                                                                WrapAlignment.center,
                                                            children: [
                                                              Container(
                                                                height: 140,
                                                                width: 250,
                                                                child: Image.network(
                                                                  popularVideoList['imageUrl'],
                                                                  fit: BoxFit.cover,
                                                                    loadingBuilder:(BuildContextcontext,Widget child,ImageChunkEvent?loadingProgress) {
                                                                    if (loadingProgress ==null)
                                                                      return child;
                                                                    return Shimmer.fromColors(
                                                                      baseColor: Colors.grey.shade800.withOpacity(0.2),
                                                                      highlightColor:Colors.grey.shade900,
                                                                      child: Container(
                                                                        height: 140,
                                                                        width: 250,
                                                                        color:Colors.grey,
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:EdgeInsets.only(bottom: 40),
                                          child: GestureDetector(
                                            onTap: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //       builder: (context) =>
                                              //       episodePlayer(
                                              //         videoUrl: video['videoUrl'],
                                              //       )
                                              //   ),
                                              // );
                                            },
                                            child: Icon(
                                              Icons.play_arrow,
                                              size: 40,
                                              color: Colors.white,
                                            )
                                          ),
                                        ),
                                        Positioned(
                                          top: 155,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              popularVideoList['title'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          )
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            Center(
                              child:Container(
                                // color: Colors.red,
                                padding: EdgeInsets.only(bottom: 0),
                                margin: EdgeInsets.only(top: 10, left: 10),
                                child: ListView.builder(
                                  itemCount: seriesMetaDataLists.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    var series = seriesMetaDataLists[index];
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 180,
                                          child: ListView.builder(
                                            itemCount: series['episodes'].length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (BuildContext context, int i) {
                                              dynamic episodes = series['episodes'][i];
                                              return Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if(usertier.any((tier) => !series['seriesData']['tier'].contains(tierMap[tier]))){
                                                          Navigator.push(context,MaterialPageRoute(
                                                              builder: (context) =>episodePlayer(
                                                              videoUrl: episodes['videoUrl']
                                                              )
                                                          ));
                                                        }else{
                                                          showDialog(
                                                            context: context,builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: Text('Alert'),
                                                                content: Text('You need to upgrade tier'),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.pop(context); 
                                                                    },
                                                                    child: Text('OK'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      },
                                                      child: Wrap(
                                                        alignment:WrapAlignment.center,
                                                        children: [
                                                          Container(
                                                            height: 140,
                                                            width: 250,
                                                            child: Image.network(
                                                              episodes['imageUrl'],
                                                              fit: BoxFit.cover,
                                                              loadingBuilder:(BuildContextcontext,Widget child,ImageChunkEvent?loadingProgress) {
                                                                if (loadingProgress ==null)
                                                                  return child;
                                                                return Shimmer.fromColors(
                                                                  baseColor: Colors.grey.shade800.withOpacity(0.2),
                                                                  highlightColor:Colors.grey.shade900,
                                                                  child: Container(
                                                                    height: 140,
                                                                    width: 250,
                                                                    color:Colors.grey,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ),
                                                  Positioned(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        // Navigator.push(
                                                        //   context,
                                                        //   MaterialPageRoute(
                                                        //     builder:(context) =>episode(
                                                        //       category:categoryData['category'],
                                                        //       imageUrl:categoryData['imageUrl'],
                                                        //       description:categoryData['description'],
                                                        //       seriesName:categoryData['seriesName'],
                                                        //     )
                                                        //   ),
                                                        // );
                                                      },
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        size: 40,
                                                        color: Colors.white,
                                                      )
                                                    ),
                                                  ),
                                                  // Positioned(
                                                  //  top: 155,
                                                  //  left: 0,
                                                  //  right: 0,
                                                  //   child: Container(
                                                  //     padding: EdgeInsets.all(8),
                                                  //     child: Text(
                                                  //       series['seriesData']['description'],
                                                  //       style: TextStyle(
                                                  //         color: Colors.white,
                                                  //         fontSize: 10,
                                                  //       ),
                                                  //     ),
                                                  //   )
                                                  // ),
                                                ],
                                              );
                                            }
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              ),
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 10, left: 10),
                                child: ListView.builder(
                                  itemCount: recentlyAdded.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    var recentlyAddedData =recentlyAdded[index];
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            // Navigator.push(context,
                                                            //   MaterialPageRoute(builder: (context) =>
                                                            //     episodePlayer(
                                                            //       videoUrl: watchHistory['videoUrl'],
                                                            //     )
                                                            //   ),
                                                            // );
                                                          },
                                                          child: Wrap(
                                                            alignment:WrapAlignment.center,
                                                            children: [
                                                              Container(
                                                                height: 140,
                                                                width: 250,
                                                                child: Image.network(
                                                                  recentlyAddedData['imageUrl'],
                                                                  fit: BoxFit.cover,
                                                                    loadingBuilder:(BuildContextcontext,Widget child,ImageChunkEvent?loadingProgress) {
                                                                    if (loadingProgress ==null)
                                                                      return child;
                                                                    return Shimmer.fromColors(
                                                                      baseColor: Colors.grey.shade800.withOpacity(0.2),
                                                                      highlightColor:Colors.grey.shade900,
                                                                      child: Container(
                                                                        height: 140,
                                                                        width: 250,
                                                                        color:Colors.grey,
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:EdgeInsets.only(bottom: 40),
                                          child: GestureDetector(
                                            onTap: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //       builder: (context) =>
                                              //       episodePlayer(
                                              //         videoUrl: video['videoUrl'],
                                              //       )
                                              //   ),
                                              // );
                                            },
                                            child: Icon(
                                              Icons.play_arrow,
                                              size: 40,
                                              color: Colors.white,
                                            )
                                          ),
                                        ),
                                        Positioned(
                                          top: 155,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              recentlyAddedData['seriesName'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          )
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                           ]
                          :[
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 10, left: 10),
                                child: ListView.builder(
                                  itemCount: continueWatchEpisodes.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    var watchHistory =continueWatchEpisodes[index];
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            // Navigator.push(context,
                                                            //   MaterialPageRoute(builder: (context) =>
                                                            //     episodePlayer(
                                                            //       videoUrl: watchHistory['videoUrl'],
                                                            //     )
                                                            //   ),
                                                            // );
                                                          },
                                                          child: Wrap(
                                                            alignment:
                                                                WrapAlignment.center,
                                                            children: [
                                                              Container(
                                                                height: 140,
                                                                width: 250,
                                                                child: Image.network(
                                                                  watchHistory['imageUrl'],
                                                                  fit: BoxFit.cover,
                                                                    loadingBuilder:(BuildContextcontext,Widget child,ImageChunkEvent?loadingProgress) {
                                                                    if (loadingProgress ==null)
                                                                      return child;
                                                                    return Shimmer.fromColors(
                                                                      baseColor: Colors.grey.shade800.withOpacity(0.2),
                                                                      highlightColor:Colors.grey.shade900,
                                                                      child: Container(
                                                                        height: 140,
                                                                        width: 250,
                                                                        color:Colors.grey,
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:EdgeInsets.only(bottom: 40),
                                          child: GestureDetector(
                                            onTap: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //       builder: (context) =>
                                              //       episodePlayer(
                                              //         videoUrl: video['videoUrl'],
                                              //       )
                                              //   ),
                                              // );
                                            },
                                            child: Icon(
                                              Icons.play_arrow,
                                              size: 40,
                                              color: Colors.white,
                                            )
                                          ),
                                        ),
                                        Positioned(
                                          top: 155,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              watchHistory['title'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          )
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            Center(
                                child: Container(
                                margin: EdgeInsets.only(top: 10, left: 10),
                                child: ListView.builder(
                                  itemCount: popularvideo.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    var popularVideoList =popularvideo[index];
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            // Navigator.push(context,
                                                            //   MaterialPageRoute(builder: (context) =>
                                                            //     episodePlayer(
                                                            //       videoUrl: watchHistory['videoUrl'],
                                                            //     )
                                                            //   ),
                                                            // );
                                                          },
                                                          child: Wrap(
                                                            alignment:
                                                                WrapAlignment.center,
                                                            children: [
                                                              Container(
                                                                height: 140,
                                                                width: 250,
                                                                child: Image.network(
                                                                  popularVideoList['imageUrl'],
                                                                  fit: BoxFit.cover,
                                                                    loadingBuilder:(BuildContextcontext,Widget child,ImageChunkEvent?loadingProgress) {
                                                                    if (loadingProgress ==null)
                                                                      return child;
                                                                    return Shimmer.fromColors(
                                                                      baseColor: Colors.grey.shade800.withOpacity(0.2),
                                                                      highlightColor:Colors.grey.shade900,
                                                                      child: Container(
                                                                        height: 140,
                                                                        width: 250,
                                                                        color:Colors.grey,
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:EdgeInsets.only(bottom: 40),
                                          child: GestureDetector(
                                            onTap: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //       builder: (context) =>
                                              //       episodePlayer(
                                              //         videoUrl: video['videoUrl'],
                                              //       )
                                              //   ),
                                              // );
                                            },
                                            child: Icon(
                                              Icons.play_arrow,
                                              size: 40,
                                              color: Colors.white,
                                            )
                                          ),
                                        ),
                                        Positioned(
                                          top: 155,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              popularVideoList['title'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          )
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            Center(
                              child:   Container(
                                // color: Colors.red,
                                padding: EdgeInsets.only(bottom: 0),
                                margin: EdgeInsets.only(top: 10, left: 10),
                                child: ListView.builder(
                                  itemCount: seriesMetaDataLists.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    var series = seriesMetaDataLists[index];
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 180,
                                          child: ListView.builder(
                                            itemCount: series['episodes'].length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (BuildContext context, int i) {
                                              dynamic episodes = series['episodes'][i];
                                              return Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if(usertier.any((tier) => !series['seriesData']['tier'].contains(tierMap[tier]))){
                                                          Navigator.push(context,MaterialPageRoute(
                                                              builder: (context) =>episodePlayer(
                                                              videoUrl: episodes['videoUrl']
                                                              )
                                                          ));
                                                        }else{
                                                          showDialog(
                                                            context: context,builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: Text('Alert'),
                                                                content: Text('You need to upgrade tier'),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.pop(context); 
                                                                    },
                                                                    child: Text('OK'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      },
                                                      child: Wrap(
                                                        alignment:WrapAlignment.center,
                                                        children: [
                                                          Container(
                                                            height: 140,
                                                            width: 250,
                                                            child: Image.network(
                                                              episodes['imageUrl'],
                                                              fit: BoxFit.cover,
                                                              loadingBuilder:(BuildContextcontext,Widget child,ImageChunkEvent?loadingProgress) {
                                                                if (loadingProgress ==null)
                                                                  return child;
                                                                return Shimmer.fromColors(
                                                                  baseColor: Colors.grey.shade800.withOpacity(0.2),
                                                                  highlightColor:Colors.grey.shade900,
                                                                  child: Container(
                                                                    height: 140,
                                                                    width: 250,
                                                                    color:Colors.grey,
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ),
                                                  Positioned(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        // Navigator.push(
                                                        //   context,
                                                        //   MaterialPageRoute(
                                                        //     builder:(context) =>episode(
                                                        //       category:categoryData['category'],
                                                        //       imageUrl:categoryData['imageUrl'],
                                                        //       description:categoryData['description'],
                                                        //       seriesName:categoryData['seriesName'],
                                                        //     )
                                                        //   ),
                                                        // );
                                                      },
                                                      child: Icon(
                                                        Icons.play_arrow,
                                                        size: 40,
                                                        color: Colors.white,
                                                      )
                                                    ),
                                                  ),
                                                  // Positioned(
                                                  //  top: 155,
                                                  //  left: 0,
                                                  //  right: 0,
                                                  //   child: Container(
                                                  //     padding: EdgeInsets.all(8),
                                                  //     child: Text(
                                                  //       series['seriesData']['description'],
                                                  //       style: TextStyle(
                                                  //         color: Colors.white,
                                                  //         fontSize: 10,
                                                  //       ),
                                                  //     ),
                                                  //   )
                                                  // ),
                                                ],
                                              );
                                            }
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              ),
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 10, left: 10),
                                child: ListView.builder(
                                  itemCount: recentlyAdded.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    var recentlyAddedData =recentlyAdded[index];
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            // Navigator.push(context,
                                                            //   MaterialPageRoute(builder: (context) =>
                                                            //     episodePlayer(
                                                            //       videoUrl: watchHistory['videoUrl'],
                                                            //     )
                                                            //   ),
                                                            // );
                                                          },
                                                          child: Wrap(
                                                            alignment:WrapAlignment.center,
                                                            children: [
                                                              Container(
                                                                height: 140,
                                                                width: 250,
                                                                child: Image.network(
                                                                  recentlyAddedData['imageUrl'],
                                                                  fit: BoxFit.cover,
                                                                    loadingBuilder:(BuildContextcontext,Widget child,ImageChunkEvent?loadingProgress) {
                                                                    if (loadingProgress ==null)
                                                                      return child;
                                                                    return Shimmer.fromColors(
                                                                      baseColor: Colors.grey.shade800.withOpacity(0.2),
                                                                      highlightColor:Colors.grey.shade900,
                                                                      child: Container(
                                                                        height: 140,
                                                                        width: 250,
                                                                        color:Colors.grey,
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:EdgeInsets.only(bottom: 40),
                                          child: GestureDetector(
                                            onTap: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //       builder: (context) =>
                                              //       episodePlayer(
                                              //         videoUrl: video['videoUrl'],
                                              //       )
                                              //   ),
                                              // );
                                            },
                                            child: Icon(
                                              Icons.play_arrow,
                                              size: 40,
                                              color: Colors.white,
                                            )
                                          ),
                                        ),
                                        Positioned(
                                          top: 155,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              recentlyAddedData['seriesName'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          )
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),                        
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ),
            ),
            SizedBox(
              height: 2,
            ),
            //Episodes
            Container(
              // color: Colors.red,
              padding: EdgeInsets.only(bottom: 0),
              margin: EdgeInsets.only(left: 10),
              child: ListView.builder(
                itemCount: seriesMetaDataLists.length,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  var series = seriesMetaDataLists[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          series['seriesData']['seriesName'],
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 14),
                        ),
                      ),
                      // Container(
                      //   child: SafeArea(
                      //     child: Container(
                      //       margin: EdgeInsets.only(
                      //           left: 20, bottom: 3, right: 20),
                      //       height: 0.1,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                      Container(
                        height: 180,  
                        child: ListView.builder(
                          itemCount: series['episodes'].length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int i) {
                            dynamic episodes = series['episodes'][i];
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      if(usertier != null && series['seriesData']['tier'] !=null){
                                        if(usertier.any((tier) => series['seriesData']['tier'].contains(tierMap[tier]))){
                                          Navigator.push(context,MaterialPageRoute(
                                            builder: (context) =>episodePlayer(
                                            videoUrl: episodes['videoUrl'],
                                            episode: episodes,  
                                            ),   
                                          ));
                                          
                                          // firestore.collection('episodes').doc(series['id']).update({
                                          //   'views': FieldValue.increment(1),
                                          // }).catchError((error) {

                                          //   // print('Failed to increment views: $error');
                                          // });
                                        }else{
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context){
                                              return AlertDialog(
                                                title: Text('Alert'),
                                                content: Text('You need to upgrade tier'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context); 
                                                    },
                                                    child: Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      }
                                    },
                                    child: Wrap(
                                      alignment:WrapAlignment.center,
                                      children: [
                                        Container(
                                          height: 140,
                                          width: 250,
                                          child: ClipRRect(
                                            borderRadius:BorderRadius.circular(7),
                                            child:Image.network(
                                              episodes['imageUrl'],
                                              fit: BoxFit.cover,
                                              loadingBuilder:(BuildContextcontext,Widget child,ImageChunkEvent?loadingProgress) {
                                                if (loadingProgress ==null)return child;
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.grey.shade800.withOpacity(0.2),
                                                  highlightColor:Colors.grey.shade900,
                                                  child: Container(
                                                    height: 140,
                                                    width: 250,
                                                    color:Colors.grey,
                                                  ),
                                                );
                                              },
                                            )  
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ),
                                Positioned(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder:(context) =>episode(
                                      //       category:categoryData['category'],
                                      //       imageUrl:categoryData['imageUrl'],
                                      //       description:categoryData['description'],
                                      //       seriesName:categoryData['seriesName'],
                                      //     )
                                      //   ),
                                      // );
                                    },
                                    child: Icon(
                                      Icons.play_arrow,
                                      size: 40,
                                      color: Colors.white,
                                    )
                                  ),
                                ),
                              ],
                            );
                          }
                        ),
                      ),
                    ],
                  );
                },
              )
            ),
            //category series
            Container(
              padding: EdgeInsets.only(bottom: 10),
              margin: EdgeInsets.only(left: 10),
              child: ListView.builder(
                itemCount: categoryList.length,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  var categoryData = categoryList[index];
                  if (categoryData['category'] != 'premium') {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            categoryData['category'],
                            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 14),
                          ),
                        ),
                        Container(
                          child: SafeArea(
                            child: Container(
                              margin: EdgeInsets.only(
                                  left: 10, bottom: 3, right: 20),
                              height: 0.1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          height: 300,
                          child: ListView.builder(
                            itemCount: categoryseriesLists.length,
                            scrollDirection: Axis.horizontal,
                            // physics: NeverScrollableScrollPhysics(),
                            itemBuilder:(BuildContext context, int index) {
                              dynamic categorySeriesDocument =categoryseriesLists[index];
                              dynamic categorySeriesData =categoryseriesLists[index].data();
                              if (categorySeriesData['category'] !=null) {
                                if (categoryData['id'] ==categorySeriesData['category'].id) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Padding(padding:EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                              MaterialPageRoute(
                                                builder:(context) =>episode(
                                                  seriesName:categorySeriesData['seriesName'],
                                                  imageUrl:categorySeriesData['imageUrl'],
                                                  description:categorySeriesData['description'],
                                                  videoUrl:categorySeriesData['videoUrl'],
                                                  sequence:categorySeriesData['sequence'], 
                                                  seriesRef:categorySeriesDocument.reference,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            children: [
                                              Container(
                                                height: 250,
                                                width: 170,
                                                // decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0),image: DecorationImage(image: )),
                                                child: ClipRRect(
                                                  borderRadius:BorderRadius.circular(7),
                                                  child:Image.network(categorySeriesData['imageUrl'],
                                                    fit: BoxFit.cover,
                                                      loadingBuilder:(BuildContextcontext,Widget child,ImageChunkEvent?loadingProgress) {
                                                      if (loadingProgress ==null)
                                                        return child;
                                                      return Shimmer.fromColors(
                                                        baseColor: Colors.grey.shade800.withOpacity(0.2),
                                                        highlightColor:Colors.grey.shade900,
                                                        child: Container(
                                                          height: 140,
                                                          width: 250,
                                                          color:Colors.grey,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ),
                                      Positioned(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:(context) =>episode(
                                                  imageUrl:categoryData['imageUrl'],
                                                  description:categoryData['description'],
                                                  seriesName:categoryData['seriesName'],
                                                )
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            Icons.play_arrow,
                                            size: 40,
                                            color: Colors.white,
                                          )
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return SizedBox();
                                }
                              } else {
                                return SizedBox();
                              }
                            }
                          ),
                        )
                      ],
                    );
                  } else {
                    return SizedBox();
                  }
                },
              )
            ),
          ],
        ),
      ),
    );
  }
 
}
