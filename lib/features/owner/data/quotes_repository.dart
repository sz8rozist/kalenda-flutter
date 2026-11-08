import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/date_param.dart';
import '../../../core/providers.dart';
import '../model/quote_models.dart';

/// Az árajánlatok végpontjai (`/businesses/{id}/quotes`).
class QuotesRepository {
  QuotesRepository(this._api);

  final ApiClient _api;

  Future<List<Quote>> quotes(int businessId, {String? status}) async {
    final response = await _api.call((d) => d.get('/businesses/$businessId/quotes', queryParameters: {'status': ?status, 'size': 50}));
    final content = (response.data as Map<String, dynamic>)['content'] as List;
    return content.map((e) => Quote.fromJson(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> _body({
    required String customerName,
    String? customerEmail,
    required List<({String name, double qty, int unitPriceHuf})> items,
    DateTime? validUntil,
  }) => {
    'customer_name': customerName.trim(),
    'customer_email': customerEmail == null || customerEmail.trim().isEmpty ? null : customerEmail.trim(),
    'items': [
      for (final i in items) {'name': i.name, 'qty': i.qty, 'unit_price_huf': i.unitPriceHuf},
    ],
    'valid_until': validUntil == null ? null : dateParam(validUntil),
  };

  Future<void> create(
    int businessId, {
    required String customerName,
    String? customerEmail,
    required List<({String name, double qty, int unitPriceHuf})> items,
    DateTime? validUntil,
  }) => _api.call(
    (d) => d.post(
      '/businesses/$businessId/quotes',
      data: _body(customerName: customerName, customerEmail: customerEmail, items: items, validUntil: validUntil),
    ),
  );

  Future<void> update(
    int businessId,
    int quoteId, {
    required String customerName,
    String? customerEmail,
    required List<({String name, double qty, int unitPriceHuf})> items,
    DateTime? validUntil,
  }) => _api.call(
    (d) => d.put(
      '/businesses/$businessId/quotes/$quoteId',
      data: _body(customerName: customerName, customerEmail: customerEmail, items: items, validUntil: validUntil),
    ),
  );

  Future<void> setStatus(int businessId, int quoteId, String status) =>
      _api.call((d) => d.patch('/businesses/$businessId/quotes/$quoteId/status', data: {'status': status}));

  Future<void> convert(int businessId, int quoteId) => _api.call((d) => d.post('/businesses/$businessId/quotes/$quoteId/convert'));

  Future<void> delete(int businessId, int quoteId) => _api.call((d) => d.delete('/businesses/$businessId/quotes/$quoteId'));
}

final quotesRepositoryProvider = Provider<QuotesRepository>((ref) => QuotesRepository(ref.watch(apiClientProvider)));
