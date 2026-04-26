import 'package:flutter/material.dart';
import 'package:gep_point/models/m_point_sale.dart';
import 'package:gep_point/services/s_organisation.dart';

class PointSaleProvider with ChangeNotifier {
  List<PointSaleModel> sales = [];
  final OrganisationService orgServ = OrganisationService();
  int currentPage = 1;
  int lastPage = 1;
  bool isLoading = false;

  Future<void> fetchSales(int organisationId, {bool loadMore = false}) async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    if (loadMore) {
      currentPage++;
    } else {
      currentPage = 1;
      sales.clear();
    }

    final result = await orgServ.getOrganisationSalesHistory(
      organisationId,
      page: currentPage,
    );

    List<PointSaleModel> newSales = List<PointSaleModel>.from(result["sales"]);

    if (loadMore) {
      sales.addAll(newSales);
    } else {
      sales = newSales;
    }

    lastPage = result["last_page"];

    isLoading = false;
    notifyListeners();
  }
}
