import 'package:azlistview/azlistview.dart';
import 'package:community_app/Model/contact_model.dart';
import 'package:community_app/Screens/contactListPage.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart'  hide Response, FormData, MultipartFile;
import '../Model/contact.dart';
import 'Contact/singleContactDetailsPage.dart';

class AlphabeticScrollView extends StatefulWidget {
  final List<Contact> items;
  AlphabeticScrollView({Key? key, required this.items}) : super(key: key);

  @override
  State<AlphabeticScrollView> createState() => _AlphabeticScrollViewState();
}

class _AlphabeticScrollViewState extends State<AlphabeticScrollView> {
  String image = 'https://scm.womenindigital.net/storage/uploads/';
  List<ContactModel> items = [];
  bool _hasCallSupport = false;
  Future<void>? _launched;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
    widget.items!.sort((a, b) {
      return a.name
          .toString()
          .toLowerCase()
          .compareTo(
          b.name.toString().toLowerCase());
    });
    initList(_getNameList(widget.items));
    SuspensionUtil.sortListBySuspensionTag(this.items);
    SuspensionUtil.setShowSuspensionStatus(this.items);

  }

  void initList(List<String> items) {
    this.items = items
        .map((item) => ContactModel(title: item, tag: item[0].toUpperCase()))
        .toList();
  }

  List<String> _getNameList(List<Contact> list) {
    List<String> nameList = [];
    for (Contact x in list) {
      nameList.add(x.name.toString());
    }
    return nameList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: AzListView(
          data: items,
          itemCount: widget.items.length,
          indexHintBuilder: (context, hint) => Container(
                alignment: Alignment.center,
                width: 60,
                height: 60,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text(
                  hint,
                  style: TextStyle(
                      color: Color(0xFF926AD3),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
          indexBarOptions: IndexBarOptions(
              needRebuild: true,
              // indexHintHeight: MediaQuery.of(context).size.height  * (75/100),
              // downColor: Colors.amber,
              indexHintAlignment: Alignment.centerRight,
              indexHintOffset: Offset(-10, 0),
              textStyle: TextStyle(color: Colors.white, fontSize: 11),
              selectTextStyle: TextStyle(color: Color(0xFF926AD3),
                  fontWeight: FontWeight.bold

                  ),
              selectItemDecoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white)
              //color: Colors.white,
              ),
          itemBuilder: (context, index) {
            final item = items[index];
            final tag = item.getSuspensionTag();
            final offStage = !item.isShowSuspension;
            return Column(
              children: [
                Offstage(
                  offstage: offStage,
                  child: buildHeader(tag),
                ),
                Container(
                  margin: EdgeInsets.only(right: 30),
                  child: ExpansionTile(

                    //tilePadding: EdgeInsets.only(right: 35),
                    leading: InkWell(
                      onTap: () {
                        Get.to(SingleContactDetailsPage(
                          contactID: widget.items[index].id!,
                          contact: widget.items[index],
                          token: ContactListPage.barerToken,
                          isChanged: false,
                        ));
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => SingleContactDetailsPage(
                        //               contact: widget.items[index],
                        //               token: ContactListPage.barerToken,
                        //               isChanged: false,
                        //             )));
                      },
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(
                            image + widget.items[index].photo.toString(),
                          ),
                        ),
                      ),
                    ),
                    // leading: Container(
                    //   color: Colors.transparent,
                    //   padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    //   decoration: BoxDecoration(
                    //     borderRadius:
                    //   ),
                    //   child: Image.network(
                    //     image + snapshot.data![index].photo.toString(),
                    //     width: 56,
                    //     height: 56,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),

                    title: InkWell(
                        onTap: () {
                          Get.to(SingleContactDetailsPage(
                            contactID: widget.items[index].id!,
                            contact: widget.items[index],
                            token: ContactListPage.barerToken,
                            isChanged: false,
                          ));
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => SingleContactDetailsPage(
                          //               contact: widget.items[index],
                          //               token: ContactListPage.barerToken,
                          //               isChanged: false,
                          //             )));
                        },
                        child: Text(
                          widget.items[index].name.toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                    //trailing: _favourite(_getBoolStatus(snapshot.data![index].favourite.toString())),
                    subtitle:
                        _designationText(widget.items[index].phone_no.toString().replaceAll(RegExp('[^0-9+]'), '')),
                    children: <Widget>[
                      Column(
                        children: [
                          Container(
                              alignment: Alignment.bottomLeft,
                              child: _moreButton(widget.items[index])),
                        ],
                      ),
                      // ListTile(
                      //   title: Text('This is tile number 1'),
                      //   subtitle: InkWell(
                      //     onTap: () {
                      //       Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (context) => SingleContactDetailsPage()));
                      //     },
                      //       child: Text('see details'),
                      //
                      //   ),
                      //   //trailing: Icon(Icons.more_vert),
                      // ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  Widget buildHeader(String tag) => Container(
        height: 30,
        alignment: Alignment.centerLeft,
        child: Text(
          '$tag',
          softWrap: false,
          style: TextStyle(
              //fontSize: 20,
              //fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      );

  Widget? _designationText(String des) {
    if (des == 'null') {
      return null;
    } else {
      return InkWell(
        child: Text(
          des,
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Widget _moreButton(Contact contact) {
    String favourite = contact.favourite.toString();
    bool status = false;
    if (favourite == 'true') {
      status = true;
    } else {
      status = false;
    }
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 30),
      child: Column(
        children: [
          Divider(color: Colors.white),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //menus
              Row(
                children: [
                  //FAVOURITE
                  // InkWell(
                  //     onTap: () {
                  //       setState(() {
                  //         print("BEFORE "+ status.toString());
                  //         status = !status;
                  //         print("AFTER "+ status.toString());
                  //         _updateStatusApi(contact.id.toString(), status.toString());
                  //       });
                  //       print("Favorite Tapped !");
                  //     },
                  //     child: (status) ? (Icon(Icons.star_rate_rounded, color: Colors.white)) : (Icon(Icons.star_border_rounded, color: Colors.white)),
                  //     ),
//CALL
                  InkWell(
                    onTap: (_hasCallSupport &&
                            (contact.phone_no?.isNotEmpty ?? false))
                        ? () => setState(() {
                              _launched = _makePhoneCall(contact.phone_no!.toString().replaceAll(RegExp('[^0-9+]'), ''));
                            })
                        : () => setState(() {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                backgroundColor: Color(0xFF926AD3),
                                content: Text(
                                  "Phone number is not saved!",
                                  style: TextStyle(fontSize: 14),
                                ),
                                duration: Duration(milliseconds: 1000),
                              ));
                            }),
                    child: Icon(
                      Icons.call,
                      color: Colors.white,
                    ),
                  ),
                  // ElevatedButton(
                  //   onPressed: _hasCallSupport
                  //       ? () => setState(() {
                  //             _launched = _makePhoneCall(widget.contact.phone_no!);
                  //           })
                  //       : null,
                  //   child: _hasCallSupport
                  //       ? const Text('Make phone call')
                  //       : const Text('Calling not supported'),
                  // ),
                  const SizedBox(
                    width: 15,
                  ),
                  //MASSAGE
                  InkWell(
                    onTap: () {
                      if (contact.phone_no?.isEmpty ?? true) {
                        setState(() {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            backgroundColor: Color(0xFF926AD3),
                            content: Text(
                              "Phone number is not saved!",
                              style: TextStyle(fontSize: 14),
                            ),
                            duration: Duration(milliseconds: 1000),
                          ));
                        });
                      } else {
                        _sendingSMS(contact.phone_no!.toString().replaceAll(RegExp('[^0-9+]'), ''));
                      }
                    },
                    child: const Icon(
                      Icons.message,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  //EMAIL
                  InkWell(
                    onTap: () {
                      if (contact.email?.isEmpty ?? true) {
                        setState(() {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            backgroundColor: Color(0xFF926AD3),
                            content: Text(
                              "eMail address is not saved!",
                              style: TextStyle(fontSize: 14),
                            ),
                            duration: Duration(milliseconds: 1000),
                          ));
                        });
                      } else {
                        final mailtoLink = Mailto(
                          to: [contact.email!],
                          //cc: ['cc1@example.com', 'cc2@example.com'],
                          //subject: 'mailto example subject',
                          //body: 'mailto example body',
                        );
                        // Convert the Mailto instance into a string.
                        // Use either Dart's string interpolation
                        // or the toString() method.
                        launch('$mailtoLink');
                      }
                    },
                    child: const Icon(
                      Icons.email_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () {
                  Get.to(SingleContactDetailsPage(
                    contactID: contact.id!,
                    contact: contact,
                    token: ContactListPage.barerToken,
                    isChanged: false,
                  ));
                },
                child: Text("View Details"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _sendingSMS(String phone) async {
    Uri url = Uri.parse('sms:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}
