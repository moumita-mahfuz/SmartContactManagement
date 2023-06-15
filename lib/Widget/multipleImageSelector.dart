import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MultipleImageSelector extends StatefulWidget {
  List<File> selectedImages = [];
  MultipleImageSelector({Key? key, required this.selectedImages}) : super(key: key);

  @override
  State<MultipleImageSelector> createState() => _MultipleImageSelectorState();
}

class _MultipleImageSelectorState extends State<MultipleImageSelector> {
 // List<File> selectedImages = [];
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // Display images selected from the gallery
    return Container(
      height: 300,
      //color: Colors.amber,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFF926AD3)),
            ),
            child: const Text('Select Image from Gallery'),
            onPressed: () {
              getImages();
            },
          ),
          SizedBox(width: 10,),
          Container(
            height: 200,
            color: Colors.grey,
            child: (widget.selectedImages.isEmpty) ? Center(child: Text('Nothing is selected yet'))
                :SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int index = 0; index < widget.selectedImages.length; index++)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Color(0xFF926AD3))),
                        child: Stack(
                          children: [
                            Center(
                              child: kIsWeb
                                  ? Image.network(widget.selectedImages[index].path)
                                  : Image.file(widget.selectedImages[index]),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {
                                  removeImage(index);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    shape: BoxShape.circle,
                                    color: Color(0xFF926AD3),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Center(
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Multiple Images Select'),
    //     backgroundColor: Colors.green,
    //     actions: [],
    //   ),
    //   body: Container(
    //     height: 300,
    //     //color: Colors.amber,
    //     child: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           ElevatedButton(
    //             style: ButtonStyle(
    //               backgroundColor: MaterialStateProperty.all(Colors.green),
    //             ),
    //             child: const Text('Select Image from Gallery'),
    //             onPressed: () {
    //               getImages();
    //             },
    //           ),
    //           Container(
    //             height: 200,
    //             //color: Colors.blue,
    //             child: SingleChildScrollView(
    //               scrollDirection: Axis.horizontal,
    //               child: Row(
    //                 children: [
    //                   for (int index = 0; index < selectedImages.length; index++)
    //                     Padding(
    //                       padding: const EdgeInsets.all(10),
    //                       child: Stack(
    //                         children: [
    //                           Center(
    //                             child: kIsWeb
    //                                 ? Image.network(selectedImages[index].path)
    //                                 : Image.file(selectedImages[index]),
    //                           ),
    //                           Positioned(
    //                             top: 5,
    //                             right: 5,
    //                             child: GestureDetector(
    //                               onTap: () {
    //                                 removeImage(index);
    //                               },
    //                               child: Container(
    //                                 decoration: BoxDecoration(
    //                                   shape: BoxShape.circle,
    //                                   color: Colors.white,
    //                                 ),
    //                                 padding: const EdgeInsets.all(2),
    //                                 child: const Icon(
    //                                   Icons.minimize,
    //                                   size: 16,
    //                                   color: Colors.red,
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  Future getImages() async {
    final pickedFile = await picker.pickMultiImage(
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );
    List<XFile> xfilePick = pickedFile;

    setState(() {
      if (xfilePick.isNotEmpty) {
        for (var i = 0; i < xfilePick.length; i++) {
          widget.selectedImages.add(File(xfilePick[i].path));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nothing is selected')),
        );
      }
    });
  }

  void removeImage(int index) {
    setState(() {
      widget.selectedImages.removeAt(index);
    });
  }
}
