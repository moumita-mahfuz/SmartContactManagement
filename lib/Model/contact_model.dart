import 'package:azlistview/azlistview.dart';

import 'contact.dart';

class ContactModel extends ISuspensionBean {
  final String title;
  final String tag;
  ContactModel({
    required this.title,
    required this.tag,
  });

  @override
  String getSuspensionTag() => tag;
}