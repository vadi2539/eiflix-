import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elflix/episode.dart';
import 'package:elflix/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class myList extends StatefulWidget {

  @override
  State<myList> createState() => _myListState();
}

class _myListState extends State<myList> {
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? userid;
  List seriesList=[];
  bool isLoading = true;
  @override
  //seriesList
  void initState(){
   super.initState();
    //user auth
    setState(() {
      userid = auth.currentUser?.uid;
    });
    firestore.collection('user').doc(userid).get().then((value) {
      var serieslistRef= value.data()?['list'];
      for(int i=0;i<serieslistRef!.length;i++){
        var series= serieslistRef[i];
        firestore.collection('series').doc(series.id).get().then((value) {
          setState(() {
          seriesList.add(value.data());   
          print(seriesList);     
        });
        });
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
              margin: EdgeInsets.only(top: 10, left: 10),
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: 7,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, index) {
                  return Container(
                    padding: EdgeInsets.all(8.0),
                    height: 250,
                    width: 170,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade900,
                      highlightColor: Colors.grey.shade700,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.white,
                      ),
                    )
                  );
                },
              ),
            ),
          ],
        )
      )
      :SingleChildScrollView(
        child: Column(
          children: [
             Container(
                margin: EdgeInsets.only(top: 10),
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
                              // IconButton(
                              //     onPressed: () {
                              //     },
                              //     icon: Icon(
                              //       Icons.search,
                              //       color: Colors.white,
                              //     )),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                )
                              ),
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
              Container(
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: SafeArea(
                child: Column(
                  children: seriesList.isNotEmpty ?  [
                    Container(
                      child: ListView.builder(
                        itemCount: seriesList.length,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          var series = seriesList[index];
                          return Dismissible(
                            key: Key(series['seriesName']),
                            direction: DismissDirection.endToStart, 
                            background: Container(
                              color: Colors.red,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onDismissed: (direction) {
                              var list = [];
                              list.add(series);
                              firestore.collection('user').doc(userid).update({
                                'list': FieldValue.arrayUnion(list)
                              });
                              setState(() {
                               seriesList.remove(series);
                              });
                              // FirebaseFirestore.instance.collection('user').doc(userid).update({
                              //   'list': FieldValue.arrayRemove([series])
                              // }).then((value) {
                              //   print('Item removed from user list in Firestore');
                              //   setState(() {
                              //     seriesList.remove(series);
                              //   });
                              // }).catchError((error) {
                              //   print('Error removing item from user list: $error');
                              // });
                            },
                            child:Row(
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(7.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                            MaterialPageRoute(
                                              builder:(context) =>episode(
                                                seriesName:series['seriesName'],
                                                imageUrl:series['imageUrl'],
                                                description:series['description'],
                                                videoUrl:series['videoUrl'],
                                                sequence:series['sequence'],    
                                              ),
                                            ),
                                          );
                                        },
                                        child: Wrap(
                                          alignment:WrapAlignment.center,
                                          children: [
                                            Container( 
                                              child: Image.network(
                                                series['imageUrl'],
                                                fit: BoxFit.cover,
                                                height: 250,
                                                width: 170,
                                                loadingBuilder:(BuildContextcontext,Widget child,ImageChunkEvent?loadingProgress) {
                                                  if (loadingProgress ==null)return child;
                                                  return Shimmer.fromColors(
                                                    baseColor: Colors.grey.shade800.withOpacity(0.2),
                                                    highlightColor:Colors.grey.shade900,
                                                    child: Container(
                                                      height: 250,
                                                      width: 170,
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
                                      top: 120,
                                      left: 80,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                            MaterialPageRoute(
                                              builder:(context) =>episode(
                                                seriesName:series['seriesName'],
                                                imageUrl:series['imageUrl'],
                                                description:series['description'],
                                                videoUrl:series['videoUrl'],
                                                sequence:series['sequence'],    
                                              ),
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          Icons.play_arrow,
                                          size: 35,
                                          color: Colors.white,
                                        )
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Text(
                                          series['seriesName'],
                                          style: TextStyle(color: Colors.white, fontSize: 13,fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.start, 
                                        ),
                                      ),
                                        Container(
                                        margin: EdgeInsets.only(top: 10),
                                        child: Text(
                                          series['description'],
                                          style: TextStyle(color: Colors.white, fontSize: 8),
                                          textAlign: TextAlign.start, 
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],   
                            ) 
                          );
                        },
                      )
                    ),
                  ]:[
                    Center(
                      child: Text('No List',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
                    )
                  ]
                ),
              ),
            ), 
          ],
        ),
      ),
    ); 
  }
}