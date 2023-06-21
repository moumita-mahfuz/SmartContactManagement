// 'name',
// 'email',
// 'password',
// 'phone_no',
// 'gender',
// 'address',
// 'designation',
// 'date_of_birth',
// 'organization',
// 'social_media',
// 'photo',
// 'note',
// "id": 3,
// "name": "ghg",
// "email": null,
// "is_verified": "",
// "email_verified_at": null,
// "created_at": "2023-02-13T10:45:52.000000Z",
// "updated_at": "2023-02-20T08:11:10.000000Z",
// "phone_no": null,
// "gender": null,
// "address": null,
// "designation": null,
// "date_of_birth": null,
// "organization": null,
// "social_media": null,
// "photo": "202302200811-Vector.png",
// "note": null

class User {
  User({
    int? id,
    String? name,
    String? email,
    String? is_verified,
    String? email_verified_at,
    String? created_at,
    String? updated_at,
    String? phone_no,
    String? gender,
    String? address,
    String? designation,
    String? date_of_birth,
    String? organization,
    String? social_media,
    String? photo,
    String? note,
  }) {
    _id = id;
    _name = name;
    _email = email;
    _is_verified = is_verified;
    _email_verified_at = email_verified_at;
    _created_at = created_at;
    _updated_at = updated_at;
    _phone_no = phone_no;
    _gender = gender;
    _address = address;
    _designation = designation;
    _date_of_birth = date_of_birth;
    _organization = organization;
    _social_media = social_media;
    _photo = photo;
    _note = note;
  }

  User.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _email = json['email'];
    _is_verified = json['is_verified'];
    _email_verified_at = json['email_verified_at'];
    _created_at = json['created_at'];
    _updated_at = json['updated_at'];
    _phone_no = json['phone_no'];
    _gender = json['gender'];
    _address = json['address'];
    _designation = json['designation'];
    _date_of_birth = json['date_of_birth'];
    _organization = json['organization'];
    _social_media = json['social_media'];
    _photo = json['photo'];
    _note = json['note'];
  }

  int? _id;
  String? _name;
  String? _email;
  String? _is_verified;
  String? _email_verified_at;
  String? _created_at;
  String? _updated_at;
  String? _phone_no;
  String? _gender;
  String? _address;
  String? _designation;
  String? _date_of_birth;
  String? _organization;
  String? _social_media;
  String? _photo;
  String? _note;

  int? get id => _id;
  String? get name => _name;
  String? get email => _email;
  String? get is_verified => _is_verified;
  String? get email_verified_at => _email_verified_at;
  String? get created_at => _created_at;
  String? get updated_at => _updated_at;
  String? get phone_no => _phone_no;
  String? get gender => _gender;
  String? get address => _address;
  String? get designation => _designation;
  String? get date_of_birth => _date_of_birth;
  String? get organization => _organization;
  String? get social_media => _social_media;
  String? get photo => _photo;
  String? get note => _note;

  Map <dynamic, dynamic> toJson () {
    final map = <dynamic , dynamic> {};
    map['id'] = _id;
    map['name'] = _name;
    map['email'] = _email;
    map['is_verified'] = _is_verified;
    map['email_verified_at'] = _email_verified_at;
    map['created_at'] = _created_at;
    map['updated_at'] = _updated_at;
    map['phone_no'] = _phone_no;
    map['gender'] = _gender;
    map['address'] = _address;
    map['designation'] = _designation;
    map['date_of_birth'] = _date_of_birth;
    map['organization'] = _organization;
    map['social_media'] = _social_media;
    map['photo'] = _photo;
    map['note'] = _note;
    return map;
  }


}
