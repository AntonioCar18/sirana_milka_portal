import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart'; // Add this import - adjust the path if your AuthService is in a different location

class EditPartner extends StatefulWidget {
  final Map<String, dynamic>? partner;
   const EditPartner({super.key, required this.partner});

  @override
  State<EditPartner> createState() => _EditPartnerState();
}

class _EditPartnerState extends State<EditPartner> {

  late TextEditingController nameController = TextEditingController();
  late TextEditingController addressController = TextEditingController();
  late TextEditingController oibController = TextEditingController();
  late TextEditingController contactPersonController = TextEditingController();
  late TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.partner?['name'] ?? '');
    addressController = TextEditingController(text: widget.partner?['address'] ?? '');
    oibController = TextEditingController(text: widget.partner?['oib'] ?? '');
    contactPersonController = TextEditingController(text: widget.partner?['contact_person'] ?? '');
    phoneController = TextEditingController(text: widget.partner?['phone'] ?? '');
  }

  Future<bool> updatePartner() async {

    final partnerId = widget.partner?['id'];

    final url = Uri.parse(
    'http://app.sirana-milka.hr:8081/milkaservice/api/partner/update-partner'
  ).replace(queryParameters: {
    'id': partnerId.toString(), 
  });

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

    if (partnerName.isEmpty ||
        partnerPhone.isEmpty ||
        partnerOIB.isEmpty ||
        partnerContactPerson.isEmpty ||
        partnerPhone.isEmpty) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Molimo ispunite sva polja prije ažuriranja partnera.'),
          ),
        );
      }
      return false;
    }

    try{
      final response = await http.put(
        url,
        headers: {
          "Accept": "*/*", // Dodaj ovo
          "Access-Control-Allow-Origin": "*",
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
              content: Text('Uspješno ste ažurirali informacije o partneru'),
            ),
          );
        }
        return true;
      }

  } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Došlo je do pogreške: $e')),  
        );
      }
    }
    return false;
  }

  Future<bool> deletePartner(int? id) async {
    if (id == null) return false;
    final url = Uri.parse(
    'http://app.sirana-milka.hr:8081/milkaservice/api/partner/delete-partner'
  ).replace(queryParameters: {
    'id': id.toString(),});

    try{
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
          "Authorization": "Bearer ${AuthService.token}",
        },
      );
      if(response.statusCode == 200){
        nameController.clear();
        addressController.clear();
        oibController.clear();
        contactPersonController.clear();
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Uspješno ste obrisali partnera'),
            ),
          );
        }
        return true;
      }
      return false;

  } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Došlo je do pogreške prilikom brisanja partnera: $e')),  
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
        child: const Text('Uredi informacije o partneru', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
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
              labelText: 'Unesite punu adresu partnera (ulica i kućni broj, grad, poštanski broj)',
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
      onPressed: () async {
        // Prikazujemo dijalog za potvrdu
        bool? uspjeh = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Potvrda'),
            content: const Text('Jeste li sigurni da želite obrisati ovog partnera?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Odustani')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Obriši', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (uspjeh == true) {
          await deletePartner(widget.partner?['id']);
          if(mounted) {
            Navigator.pop(context, true);
          }
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 229, 132, 132)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 40, vertical: 20),),
      ),
      child: const Text('Obriši partnera', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
    ),
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
        bool uspjeh = await updatePartner();
        if(uspjeh && mounted) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context, true);
        }
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