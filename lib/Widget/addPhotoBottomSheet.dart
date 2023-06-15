import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:shared_preferences/shared_preferences.dart';
import 'multipleImageSelector.dart';

class AddPhotoBottomSheet extends StatefulWidget {
  int contactId;
  AddPhotoBottomSheet({Key? key, required this.contactId}) : super(key: key);

  @override
  State<AddPhotoBottomSheet> createState() => _AddPhotoBottomSheetState();
}

class _AddPhotoBottomSheetState extends State<AddPhotoBottomSheet> {
  List<File> selectedImages = [];
  bool _searchCircularIndicator = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back(); // Close the bottom sheet when tapping outside
      },
      child: Container(
        height: 400,
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MultipleImageSelector(
                selectedImages: selectedImages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "  Cancel  ",
                    style: TextStyle(color: Color(0xFF926AD3)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xFF926AD3)),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () => {
                    print('tapped save'),
                    setState(() {
                      _searchCircularIndicator = true;
                    }),
                    addPhotoSubmit(),
                  },
                  child: (_searchCircularIndicator)
                      ? Row(
                    children: [
                      SizedBox(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          backgroundColor: Colors.white,
                        ),
                        height: 12,
                        width: 12,
                      ),
                      Text(" Saving"),
                    ],
                  )
                      : Text("    Save    "),
                ),
              ],
            ),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
    );
  }
  addPhotoSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    int id = widget.contactId;
    Map<String, String> headers = {
      "Accept": 'application/json',
      'Authorization': 'Bearer ${prefs.getString('token')}'
    };
    ///submitted_multi_img/{id}/update
    String uri = 'https://scm.womenindigital.net/api/submitted_multi_img/$id/update';
    Map<String, String> body = {
      'fromSubmitId': id.toString(),
    };
    var request = http.MultipartRequest('POST', Uri.parse(uri));

    if (selectedImages.isNotEmpty) {
      List<http.MultipartFile> imageFiles = [];
      for (var image in selectedImages) {
        String fileName = image.path.split('/').last;
        imageFiles.add(await http.MultipartFile.fromPath('multiImage[]', image.path, filename: fileName));
      }
      request.headers.addAll(headers);
      request.fields.addAll(body);
      request.files.addAll(imageFiles);
    }
    http.StreamedResponse response = await request.send();
    if (kDebugMode) {
      print(response.statusCode);
    }
    if(response.statusCode == 200) {
      setState(() {
        _searchCircularIndicator = false;
      });
      Get.back();
    }
  }
}
