import 'dart:io';

void main() {
  Product_Manager mn = Product_Manager();
  while (true) {
    print("");
    print("1.add product");
    print("2.edit product");
    print("3.remove product");
    print("4.view a product");
    print("5.view all product");
    var input = stdin.readLineSync()?.trim();
    var choice;
    if (input != null && input.isNotEmpty) {
      try {
        choice = int.parse(input);
      } catch (e) {
        print("Invalid input , Please enter a number.");
        continue;
      }
    }
    if (choice == 1) mn.addProduct();
    if (choice == 2) mn.edit_product();
    if (choice == 3) mn.delete_product();
    if (choice == 4) mn.show_one_product();
    if (choice == 5) mn.show_all_products();
    print("");
  }
}

class Product {
  String? Name, Description;
  int? Price;
  Product(this.Name, this.Description, this.Price);
  void show_product() {
    print(Name);
    print(Description);
    print("The Price is $Price \$");
    print("--------------------");
  }

  String? edit_one_product() {
    String? new_name, new_description;
    int? new_price;
    print("leave empty if no change wanted");
    print("New Name");
    new_name = stdin.readLineSync();
    print("New Description");
    new_description = stdin.readLineSync();
    print("New Price");
    var input = stdin.readLineSync()?.trim();
    new_price = (input != null && input.isNotEmpty)
        ? int.tryParse(input)
        : null;

    this.Name = new_name?.isNotEmpty == true ? new_name : Name;
    this.Description = new_description?.isNotEmpty == true
        ? new_description
        : Description;
    this.Price = new_price ?? Price;

    return Name;
  }
}

class Product_Manager {
  var Products = {};
  bool check_if_product_exist(name) {
    if (Products.containsKey(name)) {
      return true;
    } else {
      print("Product not listed");
      return false;
    }
  }

  void addProduct() {
    String? name, description;
    int? price;

    print("Name");
    name = stdin.readLineSync();
    print("Description");
    description = stdin.readLineSync();
    print("Price");
    var priceInput = stdin.readLineSync();
    if (priceInput != null && priceInput.isNotEmpty) {
      try {
        price = int.parse(priceInput);
      } catch (e) {
        print("Invalid price. Please enter a valid number.");
        return;
      }
    }

    if (name != null && name.isNotEmpty) {
      Product temp = Product(name, description, price);
      Products[name] = temp;
      print("Product added successfully.");
    } else {
      print("Product name cannot be empty.");
    }
  }

  void show_all_products() {
    for (var product in Products.entries) {
      print("---------------");
      product.value.show_product();
    }
  }

  void show_one_product() {
    var name = stdin.readLineSync();
    if (!check_if_product_exist(name)) {
      return;
    }
    Product product = Products[name];
    product.show_product();
  }

  void edit_product() {
    var name = stdin.readLineSync();
    if (!check_if_product_exist(name)) {
      return;
    }
    Product product = Products[name];
    var new_name = product.edit_one_product();
    Products[new_name] = product;
    Products.remove(name);
  }

  void delete_product() {
    var name = stdin.readLineSync();
    if (!check_if_product_exist(name)) {
      return;
    }
    Products.remove(name);
  }
}
