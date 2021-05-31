class Category {
  String id;
  String name;
  String description;
  String category_logo;

  Category({this.id, this.name, this.description, this.category_logo});

  static Category fromJson(Map<String, dynamic> map) {
    return Category(
      id: map["id"],
      name: map["name"],
      description: map["description"],
      category_logo: map["category_logo"],
    );
  }
}

class ProductBasic {
  String id;
  String name;
  String price;
  String image;

  ProductBasic({this.id, this.name, this.price, this.image});

  static ProductBasic fromJson(Map<String, dynamic> map) {
    return ProductBasic(
      id: map["id"],
      name: map["name"],
      price: map["price"],
      image: map["image"],
    );
  }
}

class Product {
  String id;
  String name;
  String price;
  int quantity;
  String description;
  String category;
  String image;

  Product(
      {this.id,
      this.name,
      this.price,
      this.quantity,
      this.description,
      this.category,
      this.image});

  static Product fromJson(Map<String, dynamic> map) {
    return Product(
        id: map["id"],
        name: map["name"],
        price: map["price"],
        quantity: map["quantity"],
        description: map["description"],
        category: map["category"],
        image: map["image"]);
  }
}
