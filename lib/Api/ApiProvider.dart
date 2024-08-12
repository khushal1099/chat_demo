import 'package:chat_demo/Api/ApiClient.dart';
import 'package:chat_demo/models/ProductsModel.dart';

class ApiProvider {
  ApiProvider._();

  static void getProducts(Function(List<Product>? list) onResponse) {
    ApiClient.apiCalling(
      '',
      (body) {
        ProductModel model = ProductModel.fromJson(body);
        onResponse(model.products);
      },
      isDebug: true,
    );
  }

  static void addProducts(
    Function(Product product) onResponse,
    String title,
    String category,
  ) {
    ApiClient.apiCalling(
      ApiClient.addProducts,
      apiMethod: ApiMethods.post,
      params: {'title': title, 'category': category},
      isDebug: true,
      (body) {
        Product model = Product.fromJson(body);
        onResponse(model);
      },
    );
  }

  static void editProducts(
      Function(Product product) onResponse, String pId, String title) {
    ApiClient.apiCalling(
      pId,
      apiMethod: ApiMethods.put,
      params: {'title': title},
      isDebug: true,
      (body) {
        Product model = Product.fromJson(body);
        onResponse(model);
      },
    );
  }

  static void deleteProducts(Function(Product product) onResponse, String pId) {
    ApiClient.apiCalling(
      pId,
      apiMethod: ApiMethods.delete,
      params: {'id': pId},
      isDebug: true,
      (body) {
        Product model = Product.fromJson(body);
        onResponse(model);
      },
    );
  }
}
