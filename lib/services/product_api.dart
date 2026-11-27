import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ProductApiException implements Exception {
  final String message;
  final bool connectionError;

  const ProductApiException(this.message, {this.connectionError = false});

  @override
  String toString() => message;
}

class ProductApi {
  static const String baseUrl = 'http://10.0.2.2:8090';

  static const Duration timeout = Duration(seconds: 12);

  static Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};

    try {
      late http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri).timeout(timeout);
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: jsonEncode(data))
              .timeout(timeout);
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: jsonEncode(data))
              .timeout(timeout);
        case 'DELETE':
          response = await http.delete(uri).timeout(timeout);
        default:
          throw const ProductApiException('Operación no permitida.');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode == 404) {
          throw const ProductApiException('El producto no existe.');
        }

        if (response.statusCode == 400) {
          throw const ProductApiException('Los datos enviados no son válidos.');
        }

        if (response.statusCode == 409) {
          throw const ProductApiException(
            'No se puede completar la operación por un conflicto de datos.',
          );
        }

        throw const ProductApiException(
          'El servidor no pudo completar la operación.',
        );
      }

      if (response.bodyBytes.isEmpty) return null;

      return jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw const ProductApiException(
        'El servidor tardó demasiado en responder.',
        connectionError: true,
      );
    } on http.ClientException {
      throw const ProductApiException(
        'No se pudo conectar con Spring Boot.',
        connectionError: true,
      );
    } on FormatException {
      throw const ProductApiException(
        'El servidor devolvió una respuesta inválida.',
      );
    } on ProductApiException {
      rethrow;
    } catch (_) {
      throw const ProductApiException(
        'No se pudo establecer conexión con el servidor.',
        connectionError: true,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final result = await _request('GET', '/products');

    if (result is! List) {
      throw const ProductApiException('El catálogo tiene un formato inválido.');
    }

    return result
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<void> createProduct(Map<String, dynamic> data) async {
    await _request('POST', '/products', data: data);
  }

  static Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    await _request('PUT', '/products/$id', data: data);
  }

  static Future<void> deleteProduct(int id) async {
    await _request('DELETE', '/products/$id');
  }
}
