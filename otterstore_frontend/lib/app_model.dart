class AppModel {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String price;

  AppModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      id: json['_id'],
      imageUrl: json['imageURL'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
    );
  }
}
