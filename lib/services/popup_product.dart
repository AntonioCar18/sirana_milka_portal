import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sirana_milka/services/auth_service.dart';
import 'dart:convert';

class PopupProduct extends StatefulWidget {
  final Map<String, dynamic>? product;
  const PopupProduct({super.key, required this.product});

  @override
  State<PopupProduct> createState() => _PopupProductState();
}

class _PopupProductState extends State<PopupProduct> {
  final TextEditingController idSirovine = TextEditingController();
  final TextEditingController trenutnaKolicinaController = TextEditingController();
  final TextEditingController novaKolicinaController = TextEditingController();
  final TextEditingController izdanaKolicinaController = TextEditingController();

  List<Map<String, dynamic>> dynamicComponents = [];

  String searchQuery = "";
  List<dynamic> searchResults = [];
  int activeDropdownIndex = -1;


  @override
  void initState() {
    super.initState();
    addDynamicComponent();
    if (widget.product != null) {
      idSirovine.text = widget.product!['itemId'].toString();
      trenutnaKolicinaController.text = widget.product!['quantity'].toString();
    }
    novaKolicinaController.addListener(() {
    setState(() {});
  });
  izdanaKolicinaController.addListener((){
    setState(() {
      
    });
  });
  }

  List<dynamic> get _filteredItems {
    if (searchQuery.isEmpty) return searchResults;
    return searchResults.where((product) {
      final nazivProizvoda = (product['itemName'] ?? '').toString().toLowerCase();
      return nazivProizvoda.contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> searchProducts() async {
    if (searchQuery.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      final Map<String, String> queryParams = {
        'searchQuery': searchQuery
      };

      final url = Uri.https(
        'app.sirana-milka:8081',
        '/milkaservice/api/search-resources',
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
            searchResults = data['items'] ?? [];
          } else if (data is List) {
            searchResults = data;
          } else {
            searchResults = [];
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

  Future<void> updateItemQuantity(int? id, int? newQuantity, int? outQuantity, List<Map<String, dynamic>> components) async {
    final url = Uri.parse('https://app.sirana-milka:8081/milkaservice/api/stock/add-products-to-stock');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
          "Authorization": "Bearer ${AuthService.token}",
        },
        body: jsonEncode({
          "idProizvoda": id,
          "brojDodanihProizvoda": newQuantity,
          "brojIzlaznihProizvoda": outQuantity,
          "sirovine": components,
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Količina proizvoda je uspješno ažurirana.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Došlo je do greške prilikom ažuriranja količine.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Došlo je do greške prilikom ažuriranja količine.'),
        ),
      );
    }
  }

  Future<void> deleteItem(int? id, String? type) async {
    final url = Uri.parse('https://app.sirana-milka:8081/milkaservice/api/delete');

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
          "Authorization": "Bearer ${AuthService.token}",
        },
        body: jsonEncode({
          "id": id,
          "type": type,
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Proizvod je uspješno obrisan.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Došlo je do greške prilikom brisanja proizvoda.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Došlo je do greške prilikom brisanja proizvoda.'),
        ),
      );
    }
  }

  void addDynamicComponent() {
    setState(() {
      dynamicComponents.add({
        'id': null,
        'nameController': TextEditingController(),
        'quantityController': TextEditingController(),
      });
    });
  }

  @override
  void dispose() {
    trenutnaKolicinaController.dispose();
    novaKolicinaController.dispose();
    izdanaKolicinaController.dispose();
    for (var component in dynamicComponents) {
      component['nameController']!.dispose();
      component['quantityController']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0),
        child: Text('Ažuriranje zalihe - ${widget.product!['itemName']}', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
      ),
      content: SizedBox(
        width: 900,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Podaci o proizvodu
                Text(
                  'Podaci o samom proizvodu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trenutačna količina',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: trenutnaKolicinaController,
                            readOnly: true,
                            enabled: false,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xffF3F4F6),
                              labelText: 'Unesite trenutačnu količinu proizvoda',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xffF3F4F6)),
                        ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nova količina',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: novaKolicinaController,
                            enabled: izdanaKolicinaController.text.isEmpty ? true : false,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              hoverColor: Colors.white,
                              filled: true,
                              fillColor: izdanaKolicinaController.text.isNotEmpty ? Color(0xffF3F4F6) : Colors.white,
                              disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xffF3F4F6)),
                        ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.black
                                ),
                              ),
                              labelText: 'Unesite novu količinu proizvoda',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Izdana količina',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: izdanaKolicinaController,
                            enabled: novaKolicinaController.text.isEmpty,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              hoverColor: Colors.white,
                              filled: true,
                              fillColor: novaKolicinaController.text.isNotEmpty ? Color(0xffF3F4F6) : Colors.white,
                              disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xffF3F4F6)),
                        ),
                              enabled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.black
                                ),
                              ),
                              labelText: 'Unesite izdanu količinu proizvoda',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ],
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                // Sirovine i komponente
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sirovine i komponente',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        TextButton(
                          onPressed: addDynamicComponent,
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Color(0xff016CB5)),
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                            ),
                          ),
                          child: Text(
                            'Dodaj sirovinu/komponentu',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Column(
                      children: List.generate(dynamicComponents.length, (index) {
                        final component = dynamicComponents[index];
                        final nameController = component['nameController'];
                        final quantityController = component['quantityController'];

                        if (nameController == null || quantityController == null) return SizedBox();

return Padding(
  padding: const EdgeInsets.only(bottom: 15),
  child: Column(
    children: [
      Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                if(value.isEmpty) {
                  setState(() {
                    searchResults = [];
                    activeDropdownIndex = -1;
                  });
                  return;
                }
                setState(() {
                  searchQuery = value;
                  activeDropdownIndex = index;
                });
                searchProducts();
              },
              controller: nameController,
              readOnly: (novaKolicinaController.text.isEmpty) ? true : false,
              enabled: novaKolicinaController.text.isNotEmpty,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: (novaKolicinaController.text.isEmpty) ? Colors.grey.shade300 : Colors.black,
                  ),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: (novaKolicinaController.text.isEmpty) ? true : false,
                fillColor: Color(0xffF3F4F6),
                labelText: 'Unesite naziv sirovine/komponente',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xffF3F4F6)),
                        ),
              ),
            ),
          ),
          SizedBox(width: 25),
          SizedBox(
            width: 370,
            child: TextField(
              controller: quantityController,
              readOnly: (novaKolicinaController.text.isEmpty) ? true : false,
              enabled: novaKolicinaController.text.isNotEmpty,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: (novaKolicinaController.text.isEmpty) ? Colors.grey.shade300 : Colors.black,
                  ),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: (novaKolicinaController.text.isEmpty) ? true : false,
                fillColor: Color(0xffF3F4F6),
                labelText: 'Unesite količinu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xffF3F4F6)),
                        ),
              ),
            ),
          ),
          SizedBox(width: 5),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black, size: 25),
            onPressed: () {
              setState(() {
                dynamicComponents.removeAt(index);
              });
            },
          ),
        ],
      ),
      SizedBox(height: 0,),
      if (activeDropdownIndex == index && searchResults.isNotEmpty)
        Align(
          alignment: AlignmentGeometry.centerLeft,
          child: Container(
            width: 420,
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredItems.length,
              itemBuilder: (context, i) {
                final item = _filteredItems[i];
          
                return ListTile(
                  title: Text(item['itemName']),
                  onTap: () {
                    setState(() {
                      nameController.text = item['itemName'];
                      component['id'] = item['itemId'];
                      searchResults = [];
                      activeDropdownIndex = -1;
                    });
                  },
                );
              },
            ),
          ),
        ),
    ],
  ),
);
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('Potvrda brisanja'),
              content: Text('Jeste li sigurni da želite obrisati ovaj proizvod? Ova akcija se ne može poništiti.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Otkaži', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await deleteItem(widget.product!['itemId'], widget.product!['type']);
                    if(!mounted) return;
                    Navigator.pop(context); // Zatvori potvrdu brisanja
                    if(!mounted) return;
                    Navigator.pop(context, true); // Zatvori dijalog nakon brisanja
                  },
                  style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 229, 132, 132)),
              ),
              child: Text('Obriši', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          );
        }, style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 229, 132, 132)),
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 40, vertical: 20),),
        ), child: const Text('Obriši proizvod', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),),
    TextButton(
      onPressed: () => Navigator.pop(context),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 200, 200, 200)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 40, vertical: 20),),
      ),
      child: const Text('Zatvori', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
      ),
    ElevatedButton(
      onPressed: () {
        List<Map<String, dynamic>> components = dynamicComponents.map((c) {
          return {
            'idSirovine': c['id'],
            'potrosenaKolicina': int.tryParse(c['quantityController']!.text) ?? 0,
          };
        }).toList();

        int? newQuantity = int.tryParse(novaKolicinaController.text) ?? 0;
        int? outQuantity = int.tryParse(izdanaKolicinaController.text) ?? 0;

        updateItemQuantity(widget.product!['itemId'], newQuantity, outQuantity, components).then((_) {
          if(!mounted) return;
          Navigator.pop(context, true); // Zatvori dijalog nakon ažuriranja
        });
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color(0xff016CB5)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 40, vertical: 20),),
      ),
      child: Text('Spremi promjene', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
    ),
  ],
    );
  }
}
