import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../Model/contactGallery.dart';

class GalleryBottomSheet extends StatefulWidget {
  int contactId;
  GalleryBottomSheet({Key? key, required this.contactId}) : super(key: key);
  @override
  State<GalleryBottomSheet> createState() => _GalleryBottomSheetState();
}

class _GalleryBottomSheetState extends State<GalleryBottomSheet> {
  String image = 'https://scm.womenindigital.net';
  List<ContactGallery> galleryList = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back(); // Close the bottom sheet when tapping outside
      },
      child: DraggableScrollableSheet(
        initialChildSize: .6,
        expand: true,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Gallery',
                      style: TextStyle(
                        color: Color(0xFF926AD3),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: fetchContactGallery(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ContactGallery>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF926AD3),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Center(
                          child: Text(
                            "No photo add to this contact!\nto Add photo, image+ icon above.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF926AD3),
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Center(
                          child: Text(
                            "No photo add to this contact!\nto Add photo, image+ icon above.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF926AD3),
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      galleryList = snapshot.data!; // Update galleryList
                      return Expanded(
                        child: GridView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.all(16.0),
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 8.0,
                          ),
                          itemCount: snapshot.data!.length,
                          // Replace with your actual item count
                          itemBuilder: (BuildContext context, int index) {
                            final item = snapshot.data![index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                border: Border.all(color: Color(0xFF926AD3)),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Image.network(
                                        image + item.images.toString()),
                                  ),
                                  Positioned(
                                    top: 8.0,
                                    right: 8.0,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Handle delete functionality here
                                        deleteImage(item.id);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white),
                                          shape: BoxShape.circle,
                                          color: Color(0xFF926AD3),
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: Center(
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text(
                          "Something went wrong",
                          style: TextStyle(color: Color(0xFF926AD3)),
                        ),
                      );
                    }
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<http.Response> deleteImage(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final http.Response response = await http.delete(
      Uri.parse(
          'https://scm.womenindigital.net/api/submitted_multi_img/$id/delete'),
      headers: {'Authorization': 'Bearer ${prefs.getString('token')}'},
    );
    if (response.statusCode == 200) {
      print('Successfully deleted image: $id');
      setState(() {
        galleryList.removeWhere((item) => item.id == id); // Remove deleted image from the list
      });
    }
    return response;
  }

  Future<List<ContactGallery>> fetchContactGallery() async {
    final prefs = await SharedPreferences.getInstance();
    int contactID = widget.contactId;

    ///submitted_multi_img/{id}/show
    String url =
        'https://scm.womenindigital.net/api/submitted_multi_img/${contactID}/show';
    final response = await http.get(Uri.parse(url), headers: {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    });

    if (response.statusCode == 200) {
      // print(response.body.toString());
      final jsonBody = jsonDecode(response.body);
      final data = jsonBody['data'] as List<dynamic>;
      if (data.isEmpty) {
        print("Empty");
      }
      return data.map((jsonData) => ContactGallery.fromJson(jsonData)).toList();
    } else {
      throw Exception('Failed to fetch groups');
    }
  }
}
