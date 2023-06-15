// "id": 33,
// "fromSubmitId": "31",
// "images": "/storage/multiImages16868020741.jpg",
// "created_at": "2023-06-15T04:07:54.000000Z",
// "updated_at": "2023-06-15T04:07:54.000000Z"
class ContactGallery {
  int id;
  String fromSubmitId;
  String images;
  DateTime createdAt;
  DateTime updatedAt;

  ContactGallery({
    required this.id,
    required this.fromSubmitId,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });
  factory ContactGallery.fromJson(Map<String, dynamic> json) {
    return ContactGallery(
      id: json['id'],
      fromSubmitId: json['fromSubmitId'],
      images: json['images'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
