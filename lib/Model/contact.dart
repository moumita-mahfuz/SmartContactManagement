
// "name","designation","organization","connected_id","phone_no","email",
// // "date_of_birth","gender","address","social_media","note","photo","created_by",
// "id": 20,
// "created_at": null,
// "updated_at": null,
// "name": "name",
// "designation": "designation",
// "organization": "organization",
// "connected_id": "[1, 2, 3]",
// "phone_no": "01705371191",
// "email": "womenindigital.net@gmail.com",
// "date_of_birth": "2023-02-01",
// "gender": "Female",
// "address": "address",
// "social_media": "social media",
// "note": "note",
// "created_by": "6"
// 'name',
// 'designation',
// 'organization',
// 'phone_no',
// 'email',
// 'date_of_birth',
// 'gender',
// 'address',
// 'social_media',
// 'profile_photo',
// 'note',
// 'password',

class Contact {
  Contact ({
    int? id,
    String? name,
    String? designation,
    String? organization,
    String? connected_id,
    String? phone_no,
    String? email,
    String? date_of_birth,
    String? gender,
    String? address,
    String? social_media,
    String? note,
    String? photo,
    int? created_by,
    String? status,
    String? created_at,
    String? updated_at,}) {
    _id = id;
    _name = name;
    _designation = designation;
    _organization = organization;
    _connected_id = connected_id;
    _phone_no = phone_no;
    _email = email;
    _date_of_birth = date_of_birth;
    _gender = gender;
    _address = address;
    _social_media = social_media;
    _note = note;
    _photo = photo;
    _created_by = created_by;
    _favourite = favourite;
    _created_at = created_at;
    _updated_at = updated_at;
  }


  Contact.fromJson (dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _designation = json['designation'];
    _organization = json['organization'];
    _connected_id = json['connected_id'];
    _phone_no = json['phone_no'];
    _email = json['email'];
    _date_of_birth = json['date_of_birth'];
    _gender = json['gender'];
    _address = json['address'];
    _social_media = json['social_media'];
    _note = json['note'];
    _photo = json['photo'];
    _created_by = json['created_by'];
    _favourite = json['favourite'];
    // _created_at = json['created_at'];
    // _updated_at = json['updated_at'];
  }
  int? _id;
  String? _name;
  String? _designation;
  String? _organization;
  String? _connected_id;
  String? _phone_no;
  String? _email;
  String? _date_of_birth;
  String? _gender;
  String? _address;
  String? _social_media;
  String? _note;
  int? _created_by;
  String? _favourite;
  String? _photo;
  String? _created_at;
  String? _updated_at;

  int? get id => _id;
  String? get name => _name;
  String? get designation => _designation;
  String? get organization => _organization;
  String? get connected_id => _connected_id;
  String? get phone_no => _phone_no;
  String? get email => _email;
  String? get date_of_birth => _date_of_birth;
  String? get gender => _gender;
  String? get address => _address;
  String? get social_media => _social_media;
  String? get note => _note;
  String? get photo => _photo;
  int? get created_by => _created_by;
  String? get favourite => _favourite;
  String? get created_at => _created_at;
  String? get updated_at => _updated_at;

  Map <String, dynamic> toJson() {
    final map = <String, dynamic> {};
    map['id'] = _id;
    map['name'] = _name;
    map['designation'] = _designation;
    map['organization'] = _organization;
    map['connected_id'] = _connected_id;
    map['phone_no'] = _phone_no;
    map['email'] = _email;
    map['date_of_birth'] = _date_of_birth;
    map['gender'] = _gender;
    map['address'] = _address;
    map['social_media'] = _social_media;
    map['note'] = _note;
    map['photo'] = _photo;
    map['created_by'] = _created_by;
    map['favourite'] = _favourite;
    map['updated_at'] = _updated_at;
    map['created_at'] = _created_at;
    return map;
  }

}
