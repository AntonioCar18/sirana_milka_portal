import 'package:flutter/material.dart';
import 'package:sirana_milka/services/add_partner.dart';
import 'package:sirana_milka/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sirana_milka/services/edit_partner.dart';

class Partners extends StatefulWidget {
  const Partners({super.key});

  @override
  State<Partners> createState() => _PartnersState();
}

class _PartnersState extends State<Partners> {
  int selectedIndex = 2;
  List<dynamic> partners = [];

  Future<void> fetchPartners() async {
    
    final url = Uri.parse(
      'https://app.sirana-milka:8081/milkaservice/api/partner/all-partners'
    );
    
    try{
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
          "Authorization": "Bearer ${AuthService.token}",
        },
      );

    if (response.statusCode == 200) {
  // 1. Dekodiraj body kao Mapu (jer počinje s { )
  final decodedBody = utf8.decode(response.bodyBytes);
  final Map<String, dynamic> responseData = jsonDecode(decodedBody);

  // 2. Izvuci listu partnera koristeći ključ "partners"
  final List<dynamic> data = responseData['partners'];

  setState(() {
    partners = data.map((partner) => {
      'id': partner['id'],
      'name': partner['partnerName'] ?? '',
      'oib': partner['oib'] ?? '',
      'email': partner['emailAddress'] ?? '',
      'address': partner['address'] ?? '',
      'contact_person': partner['contactPerson'] ?? '',
      'phone': partner['phoneNumber'] ?? '',
    }).toList();
  });
}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Došlo je do pogreške pri dohvaćanju partnera: $e')),
      );
      return;
    }
  }


   @override
  void initState() {
    super.initState();
    fetchPartners();
  }

  Widget sidebarItem({
    required IconData icon,
    required String title,
    required int index,
    required VoidCallback onTap,
  }) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        onTap();
      },
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xffACD6F2) : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: isSelected ? Color(0xff016CB5) : Colors.black),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Color(0xff016CB5) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            padding: EdgeInsets.all(25),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('Login_Logo.png'),
                ),
                SizedBox(height: 10),
                Text(
                  'Bok, ${TokenHelper.getNameFromToken(AuthService.token ?? "") ?? "Korisnik"}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff034C7D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                sidebarItem(
                  icon: Icons.dashboard,
                  title: "Nadzorna ploča",
                  index: 0,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'dashboard');
                  },
                ),
                SizedBox(height: 5),
                sidebarItem(
                  icon: Icons.storage,
                  title: "Skladište",
                  index: 1,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'storage');
                  },
                ),
                SizedBox(height: 5),
                sidebarItem(
                  icon: Icons.people,
                  title: "Partneri",
                  index: 2,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'partners');
                  },
                ),
                SizedBox(height: 5),
                sidebarItem(
                  icon: Icons.list_alt,
                  title: "Narudžbe",
                  index: 3,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/ogin');
                  },
                ),
                SizedBox(height: 5),
                sidebarItem(
                  icon: Icons.money,
                  title: "Financije",
                  index: 4,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/logn');
                  },
                ),
                SizedBox(height: 5),
                sidebarItem(
                  icon: Icons.logout,
                  title: "Odjava",
                  index: 5,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'login');
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xfff7f6f8),
              padding: EdgeInsets.fromLTRB(80, 65, 65, 65),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Poslovni partneri',
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
                          await
                          showDialog(
                            context: context,
                            builder: (context) => newPartner(),
                          );
                          if(mounted)
                          fetchPartners();
                        },
                        child: Text(
                          '+ Dodaj novog partnera',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Expanded(
                    child: partners.isEmpty
                      ? Center(
                        child: Text(
                          'Ovdje će biti prikazani partneri.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      )
                      : SizedBox(
                        width: screenWidth,
                        child: SingleChildScrollView(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Color(0xffF9FAFB)),
                              columns: const [
                                DataColumn(label: Text('Naziv partnera'),),
                                DataColumn(label: Text('OIB')),
                                DataColumn(label: Text('Adresa')),
                                DataColumn(label: Text('Kontakt osoba')),
                                DataColumn(label: Text('Akcija')),
                              ],
                              rows: partners.map((partner) {
                                return DataRow(
                                  color: WidgetStateProperty.all(Colors.white),
                                  cells: [
                                  DataCell(Text(partner['name'])),
                                  DataCell(Text(partner['oib'])),
                                  DataCell(Text(partner['address'])),
                                  DataCell(Row(
                                    children: [
                                      Text(partner['contact_person']),
                                      SizedBox(width: 5),
                                      Text('-'),
                                      SizedBox(width: 5),
                                      Text(partner['phone'] ?? ''),
                                    ],
                                  )),
                                    DataCell(InkWell(
                                    onTap: () async{
                                      final bool? result = await showDialog(context: context, builder: (context) => EditPartner(partner: partner));
                                      if (result == true) {
                                        fetchPartners();
                                      }
                                    },
                                    child: Icon(Icons.edit_road, color: Colors.black),
                                    )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}