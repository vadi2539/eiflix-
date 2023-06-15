import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elflix/episodePlayer.dart';
import 'package:elflix/home.dart';
import 'package:elflix/myList.dart';
import 'package:elflix/series.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class episode extends StatefulWidget {
  final String description;
  final String imageUrl;
  final String? videoUrl;
  final String seriesName;
  final List? sequence;
  final dynamic seriesRef;

  episode({
    required this.imageUrl,
    required this.description,
    this.videoUrl,
    required this.seriesName, 
    this.sequence,
    this.seriesRef,
  });

  @override
  State<episode> createState() => _episodeState();
}
class _episodeState extends State<episode> {
  bool isLoading = true;
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? userid;
  String? email;
  List usertier = []; 
  Map<String, dynamic> tierMap = {};
  List seriesSequence=[];
  List seriesMetaDataLists = [];
  List list = [];
  List seriesID = [];
  bool _isMuted = false;
  bool Lists = false;
  bool like = false;
  final double aspectRatio = 16 / 9;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initPlayer();
      //user auth
    setState(() {
      userid = auth.currentUser?.uid;
      email = auth.currentUser?.email;
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
    //series sequence
    for(int i =0; i<widget.sequence!.length;i++){
    var sequence = widget.sequence![i];
      firestore.collection('episodes').doc(sequence.id).get().then((value) {
        setState(() {
          seriesSequence.add(value.data());          
        });
      });    
    }
    //series 
    var uncategorizedserieslist = [];
    firestore.collection('series').get().then((value) async {
        for (int i = 0; i < value.docs.length; i++) {
          var element = value.docs[i].data();
          if (element['category'] != null) {
            var map = {};
            map['seriesData'] = element;
            seriesID.add(map['seriesData']['id']);
            uncategorizedserieslist.add(map);
          }
      }
      setState(() {
        seriesMetaDataLists = uncategorizedserieslist;
      });
    });
    //shimmer backgroud shadow timer
    Timer(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  

  }
  void _initPlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl ?? '')
    ..initialize();
    setState(() {
      _controller.pause();
      _controller.play();
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    _controller.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final videoWidth = screenWidth;
    final videoHeight = videoWidth / aspectRatio;

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
        )
      )
      : SingleChildScrollView(
       child: SafeArea(
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
                width: double.infinity,
                height: videoHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: VisibilityDetector(
                        key: Key('video-player-key'),
                        child: VideoPlayer(_controller),
                         onVisibilityChanged: (VisibilityInfo info) {
                          if (info.visibleFraction == 0) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        }
                      )
                    ),
                    Positioned.fill(
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? null
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      left: 9,
                      bottom: 20,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 13, right: 13, top: 8, bottom: 8),
                          child: Row(
                            children: [
                              Text('Preview',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 9,
                      bottom: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isMuted = !_isMuted;
                                    _controller.setVolume(_isMuted ? 0.0 : 1.0);
                                  });
                                },
                                icon: Icon(
                                  _isMuted
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  size: 20,
                                  color: Colors.white,
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 0),
                width: double.infinity,
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0),
                child: Text(
                  widget.seriesName,
                  style: TextStyle(
                   color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 10),
                width: screenWidth,
                child: SafeArea(
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigator.push(context,
                          //   MaterialPageRoute(builder: (context) =>episodePlayer(videoUrl: widget.videoUrl ? '')
                          //   ),
                          // );
                        },
                        icon: Icon(Icons.play_arrow,size: 20,color: Colors.black,
                        ),
                        label: Text('Play',
                          style: TextStyle(
                           fontSize: 13,color: Colors.black,fontWeight: FontWeight.w600
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(videoWidth, 50),
                          textStyle: TextStyle(fontSize: 30),
                          primary: Colors.white70,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.download,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Download',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(videoWidth, 50),
                          textStyle: TextStyle(fontSize: 30),
                          primary: Colors.grey.shade800,
                          // backgroundColor: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ), 
              Container(
                margin: EdgeInsets.only(top: 0),
                width: double.infinity,
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  widget.description,
                  style: TextStyle(
                    color: Colors.white,fontSize: 10,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (!Lists) {
                                 var list = [];
                                list.add(widget.seriesRef);
                                await firestore.collection('user').doc(userid).update({
                                  'list': FieldValue.arrayUnion(list)
                                });
                              } else {
                                 var list = [];
                                list.add(widget.seriesRef);
                                print(list);
                                await firestore.collection('user').doc(userid).update({
                                  'list': FieldValue.arrayRemove(list)
                                });
                              }
                              setState(() {
                                Lists = !Lists;
                              }); 
                            },
                            child: Lists
                                ? Icon(Icons.done, size: 25, color: Colors.white)
                                : Icon(Icons.add, size: 25, color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'My List',
                            style:TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                like = !like;
                              });
                            },
                            child: !like
                              ? Icon(Icons.thumb_up,size: 20,color: Colors.white,)
                              : Icon(Icons.thumb_up,size: 20,color: Colors.blue,)
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Rate',
                            style:
                                TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.share,
                              size: 20,
                              color: Colors.white,
                            )
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Share',
                            style:
                                TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                // height: 380,
                margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                child: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        child: ListView.builder(
                          itemCount: seriesSequence.length,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            var series = seriesSequence[index];
                            final itemNumber = index + 1;
                            return Row(
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(7.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          if(usertier != null && seriesMetaDataLists[index]['seriesData']['tier'] !=null){
                                            if(usertier.any((tier) =>seriesMetaDataLists[index]['seriesData']['tier'].contains(tierMap[tier]))){
                                              Navigator.push(context,MaterialPageRoute(
                                                  builder: (context) =>episodePlayer(
                                                  videoUrl: series['videoUrl']
                                                  )
                                            ));
                                            }else{
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
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
                                              child: Image.network(
                                                series['imageUrl'],
                                                fit: BoxFit.cover,
                                                height: 90,
                                                width: 150,
                                                loadingBuilder:(BuildContextcontext,Widget child,ImageChunkEvent?loadingProgress) {
                                                  if (loadingProgress ==null)return child;
                                                  return Shimmer.fromColors(
                                                    baseColor: Colors.grey.shade800.withOpacity(0.2),
                                                    highlightColor:Colors.grey.shade900,
                                                    child: Container(
                                                      height: 90,
                                                      width: 150,
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
                                      top: 40,
                                      left: 70,
                                      child: GestureDetector(
                                          onTap: () {
                                          if(usertier != null && seriesMetaDataLists[index]['seriesData']['tier'] !=null){
                                            if(usertier.any((tier) =>seriesMetaDataLists[index]['seriesData']['tier'].contains(tierMap[tier]))){
                                              Navigator.push(context,MaterialPageRoute(
                                                builder: (context) =>episodePlayer(
                                                 videoUrl: series['videoUrl']
                                                )
                                              ));
                                            }else{
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
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
                                        child: Icon(
                                          Icons.play_arrow,
                                          size: 25,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          '${itemNumber}. ${series['title']}',
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
                            );     
                          },
                        )
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ElFlix',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'a Product of Antano & Harini',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.normal),
                        ),
                        Text(
                          'All Right Rerserved',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
