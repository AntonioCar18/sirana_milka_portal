import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart'; // Add this import - adjust the path if your AuthService is in a different location

class newPartner extends StatefulWidget {
  const newPartner({super.key});

  @override
  State<newPartner> createState() => _NewPartnerState();
}

class _NewPartnerState extends State<newPartner> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController oibController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

Future<bool> newPartner() async {
  final url = Uri.parse(
  'http://app.sirana-milka.hr:8081/milkaservice/api/partner/add-partner'
);

final partnerName = nameController.text.trim();
final partnerAddress = addressController.text.trim();
final partnerOIB = oibController.text.trim();
final partnerContactPerson = contactPersonController.text.trim();
final partnerPhone = phoneController.text.replaceAll(' ', '');

final Map<String, dynamic> payload ={
  "partnerName": partnerName,
  "address": partnerAddress,
  "oib": partnerOIB,
  "contactPerson": partnerContactPerson,
  "phoneNumber": partnerPhone,
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
      nameController.clear();
      addressController.clear();
      oibController.clear();
      contactPersonController.clear();
      phoneController.clear();
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uspješno ste dodali novog partnera'),
          ),
        );
      }
      return true;
    }
    return false;

} catch (e) {
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Došlo je do pogreške: $e')),
);
    }
    return false;
  }
}

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    addressController.dispose();
    oibController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0),
        child: const Text('Dodavanje novog partnera', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
      ),
      content: SizedBox(
        width: 900,
        height: 500,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Naziv partnera', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),),
          SizedBox(height: 10,),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Unesite službeno ime partnera',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          const SizedBox(height: 30),
          Text('Adresa partnera', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),),
          SizedBox(height: 10,),
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: 'Unesite punu adresu partnera (ulica broj, grad, poštanski broj)',
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
                    Text('Osobni identifikacijski broj', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
                    SizedBox(height: 10,),
                    TextField(
                      controller: oibController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Unesite osobni identifikacijski broj partnera',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kontakt osoba', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
                        SizedBox(height: 10,),
                        TextField(
                          controller: contactPersonController,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: 'Unesite ime i prezime kontakt osobe',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 30,),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Telefon', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
                        SizedBox(height: 10,),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: 'Unesite broj telefona kontakt osobe',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
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
      onPressed: () async{
        bool uspjeh = await newPartner();
        if(uspjeh && mounted) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context, true);
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color(0xff016CB5)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 40, vertical: 20),),
      ),
      child: Text('Dodaj partnera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
    ),
  ],
);
  }
}
