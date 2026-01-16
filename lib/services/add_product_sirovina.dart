import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart'; // Add this import - adjust the path if your AuthService is in a different location

class AddProductSirovina extends StatefulWidget {
  const AddProductSirovina({super.key});

  @override
  State<AddProductSirovina> createState() => _AddProductSirovinaState();
}

class _AddProductSirovinaState extends State<AddProductSirovina> {

  final TextEditingController IDProizvodaController = TextEditingController();
  final TextEditingController nazivProizvodaController = TextEditingController();
  final TextEditingController aktualnoStanjeController = TextEditingController();
  String? selectedMjernaJedinica;
  List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
  }

  Future<void> addProduct() async {
    final url = Uri.parse(
    'https://678175e457ab.ngrok-free.app/milkaservice/api/add-item'
  );

  final ID = int.tryParse(IDProizvodaController.text) ?? 0;
  final title = nazivProizvodaController.text.trim();
  final actualstate = int.tryParse(aktualnoStanjeController.text) ?? 0;

  if(actualstate<0){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unesite količinu koja je veća ili jednaka 0!'),
        ),
      );
    }

  final Map<String, dynamic> payload ={
      "productId": ID,
      "productName": title,
      "quantity": actualstate,
      "measureUnit": selectedMjernaJedinica,
      "type": isSelected[0] ? "proizvod" : "sirovina/ambalaza",
    };

    try{
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
          "Authorization": "Bearer ${AuthService.token}",
        },
        body: jsonEncode(payload),
      );

      if(response.statusCode == 200){
        IDProizvodaController.clear();
        nazivProizvodaController.clear();
        aktualnoStanjeController.clear();
        selectedMjernaJedinica = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uspješno ste ažurirali stanje sirovine'),
          ),
        );
      }

  } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    IDProizvodaController.dispose();
    nazivProizvodaController.dispose();
    aktualnoStanjeController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0),
        child: const Text('Dodavanje novog proizvoda', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
      ),
      content: SizedBox(
        width: 900,
        height: 500,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID artikla', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),),
          SizedBox(height: 10,),
          TextField(
            controller: IDProizvodaController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: 'Unesite ID proizvoda',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          const SizedBox(height: 30),
          Text('Naziv artikla', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),),
          SizedBox(height: 10,),
          TextField(
            controller: nazivProizvodaController,
            decoration: InputDecoration(
              labelText: 'Naziv proizvoda',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trenutačna količina', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
                    SizedBox(height: 10,),
                    TextField(
                      controller: aktualnoStanjeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Trenutno stanje',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        focusedBorder: OutlineInputBorder(
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mjerna jedinica', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
                    SizedBox(height: 10,),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('Kilogram (kg)')),
                        DropdownMenuItem(value: 'g', child: Text('Gram (g)')),
                        DropdownMenuItem(value: 'L', child: Text('Litara (L)')),
                        DropdownMenuItem(value: 'ml', child: Text('Mililitar (ml)')),
                        DropdownMenuItem(value: 'kom', child: Text('Komad (kom)')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedMjernaJedinica = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text('Vrsta artikala:', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
          SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: ToggleButtons(
                  selectedColor: Colors.white,
                  selectedBorderColor: Color(0xff016CB5),
                  borderRadius: BorderRadius.circular(15),
                  borderColor: Colors.grey,
                  fillColor: Color(0xff016CB5),
                  isSelected: isSelected,
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = i == index;
                      }
                    });
                  },
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                      child: Center(child: Text('Proizvod', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),)),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                      child: Center(child: Text('Sirovina/Ambalaža', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),)),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    ),
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 200, 200, 200)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 40, vertical: 20),),
      ),
      child: const Text('Zatvori', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
      ),
    ElevatedButton(
      onPressed: () async {
        await addProduct();
        if(mounted){
        Navigator.pop(context);
      }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color(0xff016CB5)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 40, vertical: 20),),
      ),
      child: Text('Dodaj proizvod', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
    ),
  ],
);
  }
}
