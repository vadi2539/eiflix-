import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elflix/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'episode.dart';
import 'home.dart';

class series extends StatefulWidget {
  const series({Key? key}) : super(key: key);

  @override
  State<series> createState() => _seriesState();
}

class _seriesState extends State<series> {
 FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  late bool hasWatchedVideo = false;
  late List<String> tabData;
  String? userid;
  String? collectiondata;
  String? data;
  List usertier = [];
  List categoryList = [];
  List seriesMetaDataLists = [];
  List categoryseriesLists = [];
  Map<String, dynamic> tierMap = {};
  List episodesList = [];
  List<String> tierNames=[];


  @override
  void initState() {
    super.initState();
    //user auth
      setState(() {
        userid = auth.currentUser?.uid;
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
     // shimmer backgroud shadow timer
    Timer(Duration(seconds: 3), () {
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
              margin: EdgeInsets.only(left: 10),
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
          ],
        )
      )
      :SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: SafeArea(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(context,MaterialPageRoute(
                                        builder: (context) => home()),
                                      );
                                    },
                                    icon: Icon(
                                        Icons.arrow_back,
                                      color: Colors.white,
                                    )
                                  ),
                                ),
                                Row(
                                  children: [
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
                                        )),
                                    // IconButton(
                                    //     onPressed: () {},
                                    //     icon: Image.network(
                                    //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQeJoUpGxhlot7sH1-Qh_SCgFWnMUlZXuHKlG82WLCJD-aq5hYrKK4ICgmrbuE_dypcKxA&usqp=CAU')
                                    // ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
           //category series
            Container(
              padding: EdgeInsets.only(bottom: 10),
              margin: EdgeInsets.only(top: 5, left: 10),
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
                            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),
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
                                                ),
                                              ),
                                            );
                                          },
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            children: [
                                              Container(
                                                height: 220,
                                                width: 150,
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
                                          ),
                                          
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

