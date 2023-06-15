import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shimmer/shimmer.dart';

import 'episode.dart';
import 'home.dart';

class searchbar extends StatefulWidget {
  const searchbar({Key? key}) : super(key: key);

  @override
  State<searchbar> createState() => _searchbarState();
}

class _searchbarState extends State<searchbar> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List searchResult = [];
  //searchBar
  Future<void> searchFromFirebase(String query) async {
    final result =await firestore.collection('series').where('seriesName',isGreaterThanOrEqualTo:query).get();
    setState(() {
      searchResult = result.docs.map((e) => e.data()).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:Column(
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
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              decoration: InputDecoration(
                focusedBorder:UnderlineInputBorder(
                   borderSide:BorderSide(color: Colors.grey.shade900),
                ),
                border: OutlineInputBorder(),
                hintText: "Search Here",
                hintStyle: TextStyle(color: Colors.white24),
                fillColor: Colors.grey.shade900,
                filled: true,
              ),style: TextStyle(color: Colors.white),
              onChanged: (query) {
                searchFromFirebase(query);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResult.length,
              itemBuilder: (context, index) {
                var search =searchResult[index];
                return Row(
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
                                    seriesName:search['seriesName'],
                                    imageUrl:search['imageUrl'],
                                    description:search['description'],
                                    videoUrl:search['videoUrl'],
                                    sequence:search['sequence'],    
                                  ),
                                ),
                              );
                            },
                            child: Wrap(
                              alignment:WrapAlignment.center,
                              children: [
                                Container( 
                                  child: Image.network(
                                    search['imageUrl'],
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
                                    seriesName:search['seriesName'],
                                    imageUrl:search['imageUrl'],
                                    description:search['description'],
                                    videoUrl:search['videoUrl'],
                                    sequence:search['sequence'],    
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
                              search['seriesName'],
                              style: TextStyle(color: Colors.white, fontSize: 13,fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start, 
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Text(
                              search['description'],
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
            ),
          ),
        ],
      ),
    );   
  }
}