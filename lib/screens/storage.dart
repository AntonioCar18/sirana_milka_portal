import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sirana_milka/services/add_product_sirovina.dart';
import 'package:sirana_milka/services/auth_service.dart';
import 'package:sirana_milka/services/popup_sirovina.dart';
import 'package:sirana_milka/services/popup_product.dart';
import 'package:sirana_milka/services/sidebar.dart';

class Storage extends StatefulWidget {
  const Storage({super.key});

  @override
  State<Storage> createState() => _StorageState();
}

class _StorageState extends State<Storage> {
  int selectedIndex = 1;
  final TextEditingController search = TextEditingController();
  String searchQuery = "";
  List<dynamic> products = [];

  List<dynamic> get _filteredProducts {
    if (searchQuery.isEmpty) return products;
    return products.where((product) {
      final nazivProizvoda = (product['itemName'] ?? '').toString().toLowerCase();
      return nazivProizvoda.contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> searchProducts() async {

    try {
      final Map<String, String> queryParams = {
        'searchQuery': searchQuery
      };

      final url = Uri.http(
        'app.sirana-milka.hr:8081',
        '/milkaservice/api/search-items',
        queryParams,
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
          "Authorization": "Bearer ${AuthService.token}",
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);

        setState(() {
          if (data is Map<String, dynamic> && data.containsKey('items')) {
            products = data['items'] ?? [];
          } else if (data is List) {
            products = data;
          } else {
            products = [];
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška prilikom dohvaćanja podataka."),
            backgroundColor: Color(0xff136DED),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška u povezivanju sa poslužiteljom."),
          backgroundColor: Color(0xff136DED),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    searchProducts();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Na zalihi":
        return Color(0xff59C743);
      case "Nema na zalihi":
        return Color(0xffB40E0E);
      case "Niske zalihe":
        return Color(0xffF5CD49);
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          SidebarMenu(selectedIndex: selectedIndex),
          Expanded(
            child: Container(
              color: Color(0xfff7f6f8),
              padding: EdgeInsets.fromLTRB(80, 65, 65, 65),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Naslov i button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upravljanje zalihama i inventarom',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: screenWidth > 1200 ? 32 : 24,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Color(0xff016CB5)),
                          padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 25)),
                        ),
                        onPressed: () async{
                          final result = await showDialog(
                          context: context,
                          builder: (context) => AddProductSirovina(),
                        );
                        if(result == true && mounted){
                          searchProducts();
                        }
                        },
                        child: Text(
                          '+ Dodaj novi proizvod',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  // Search field
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                            searchProducts();
                          },
                          controller: search,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 20),
                            hintText: 'Unesite traženi proizvod ili njegov ID',
                            prefixIcon: Icon(Icons.search),
                            fillColor: Colors.white,
                            filled: true,
                            focusColor: Colors.white,
                            hoverColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  // DataTable
                  Expanded(
                    child: products.isEmpty
                        ? Center(
                            child: Text(
                              'Nema rezultata',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade600),
                            ),
                          )
                        : SizedBox(
                            width: screenWidth,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor:
                                      WidgetStateProperty.all(Color(0xffF9FAFB)),
                                  columns: const [
                                    DataColumn(
                                        label: Text(
                                      'ID Proizvoda',
                                      textAlign: TextAlign.center,
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Naziv proizvoda',
                                      textAlign: TextAlign.center,
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Količina',
                                      textAlign: TextAlign.center,
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Status',
                                      textAlign: TextAlign.center,
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Akcija',
                                      textAlign: TextAlign.center,
                                    )),
                                  ],
                                  rows: _filteredProducts.map((product) {
                                    return DataRow(
                                      color:
                                          WidgetStateProperty.all(Colors.white),
                                      cells: [
                                        DataCell(Text(product['itemId'].toString())),
                                        DataCell(Text(product['itemName'].toString())),
                                        DataCell(Row(
                                          children: [
                                            Text(product['quantity'].toString()),
                                            SizedBox(width: 5),
                                            Text(product['measureUnit'] ?? ''),
                                          ],
                                        )),
                                        DataCell(Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(
                                                product['status'] ?? ''),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Text(
                                            product['status'] ?? '',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                        DataCell(InkWell(
                                          onTap: () async {
                                            final String type = product['type'] ?? '';
                                            if (type == 'resurs') {
                                              final bool? result = await showDialog(
                                                context: context,
                                                builder: (context) => PopupSirovina(
                                                  sirovinaData: product,
                                                ),
                                              );
                                              if (result == true) {
                                                setState(() {
                                                  searchProducts();
                                                });
                                              }
                                            } else if (type == 'proizvod') {
                                              final bool? result = await showDialog(
                                                context: context,
                                                builder: (context) => PopupProduct(
                                                  product: product,
                                                ),
                                              );
                                              if (result == true) {
                                                setState(() {
                                                  searchProducts();
                                                });
                                              }
                                            }
                                          },
                                          child: Text(
                                            'Uredi',
                                            style: TextStyle(
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        )),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
