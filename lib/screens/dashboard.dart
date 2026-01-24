import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sirana_milka/services/auth_service.dart';
import 'package:sirana_milka/services/bar_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int selectedIndex = 0;
  String data = "--";
  String partners = "--";

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchPartners();
  }

  Future<void> fetchPartners() async {

    final token = AuthService.token;
    if (token == null) {
  print("Token ne postoji, korisnik nije prijavljen!");
  return; // ne šalji request
}

    final url = Uri.parse(
        'https://7cf590e4f8a3.ngrok-free.app/milkaservice/api/partner/total-partners');
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        int broj = int.parse(response.body);
        setState(() {
          partners = broj.toString();
        });
      } else {
        setState(() {
          partners = "Greška: ${response.statusCode}";
        });
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

  Future<void> fetchData() async {
    final token = AuthService.token;
    if (token == null) {
  print("Token ne postoji, korisnik nije prijavljen!");
  return; // ne šalji request
}
    final url = Uri.parse(
        'https://7cf590e4f8a3.ngrok-free.app/milkaservice/api/total-no-of-products');
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        int broj = jsonData['quantityProducts'];
        setState(() {
          data = broj.toString();
        });
      } else {
        setState(() {
          data = "Greška: ${response.statusCode}";
        });
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
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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

  Widget dashboardCard({required String title, required String value}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(25, 15, 25, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Color(0xff646974),
                fontSize: 20,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getStatusColor(String status){
    switch (status) {
      case "Poslano":
        return Color(0xff59C743);
      case "Otkazano":
        return Color(0xffB40E0E);
      case "U obradi":
        return Color(0xffF5CD49);
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
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

          // Glavni dio dashboard-a
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffF9FAFB),
              ),
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 1400),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(80, 65, 65, 65),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Naslov
                          Text(
                            'Pregled poslovanja',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 35),
              
                          // Dashboard kartice
                          GridView.count(
                            crossAxisCount: 4,
                            crossAxisSpacing: 40,
                            mainAxisSpacing: 0,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.6,
                            children: [
                              dashboardCard(title: 'Ukupan broj proizvoda', value: data),
                              dashboardCard(title: 'Broj aktualnih partnera', value: partners),
                              dashboardCard(title: 'Narudžbe na čekanju', value: 'N/A'),
                              dashboardCard(title: 'Bilanca poslovanja [€]', value: 'N/A'),
                            ],
                          ),
                          SizedBox(height: 70),
              
                          // Row s grafovima
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status narudžbi
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Status narudžbi',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text('Pregled statusa u tekućem mjesecu'),
                                      SizedBox(height: 15),
                                      SizedBox(
                                        height: 300,
                                        child: BarChartWidget(),
                                      ),
                                      SizedBox(height: 25),
                                      InkWell(child: Center(child: Text('Više informacija o samim narudžbama'))),
                                    ],
                                  ),
                                ),
                              ),
              
                              SizedBox(width: 45),
              
                              // Financijski graf
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pregled financija',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text('Pregled statusa u tekućem mjesecu'),
                                      SizedBox(height: 15),
                                      SizedBox(
                                        height: 335,
                                        child: Center(child: Text('Grafikon financija - uskoro')),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 70),
              
                          // DataTable
                          Container(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(Color(0xffF9FAFB)),
                                columns: [
                                  DataColumn(label: Text('Narudžba ID')),
                                  DataColumn(label: Text('Kupac')),
                                  DataColumn(label: Text('Datum kreiranja')),
                                  DataColumn(label: Text('Iznos [€]')),
                                  DataColumn(label: Text('Status')),
                                ],
                                rows: [
                                  DataRow(
                                    color: MaterialStateProperty.all(Colors.white),
                                    cells: [
                                      DataCell(Text('/')),
                                      DataCell(Text('/')),
                                      DataCell(Text('/')),
                                      DataCell(Text('/')),
                                      DataCell(
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(""),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Text(
                                            '',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
