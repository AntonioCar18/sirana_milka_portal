import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sirana_milka/services/auth_service.dart';
import 'dart:convert';

class PopupSirovina extends StatefulWidget {
  final Map<String, dynamic> sirovinaData;
  const PopupSirovina({super.key, required this.sirovinaData});

  @override
  State<PopupSirovina> createState() => _PopupSirovinaState();
}

class _PopupSirovinaState extends State<PopupSirovina> {
  final TextEditingController idProizvodaController = TextEditingController();
  final TextEditingController nazivProizvodaController = TextEditingController();
  final TextEditingController aktualnoStanjeController = TextEditingController();
  final TextEditingController novaKolicinaController = TextEditingController();
  List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    idProizvodaController.text = widget.sirovinaData['itemId']?.toString() ?? '';
    nazivProizvodaController.text = widget.sirovinaData['itemName'] ?? '';
    aktualnoStanjeController.text = widget.sirovinaData['quantity']?.toString() ?? '';
  }

  Future<void> deleteItem(int? id, String? type) async {
    final url = Uri.parse('https://678175e457ab.ngrok-free.app/milkaservice/api/delete');

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
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uspješno ste obrisali sirovinu'),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Neuspješno brisanje sirovine'),
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Greška u povezivanju sa poslužiteljom."),
          backgroundColor: Color(0xff136DED),
        ),
      );
    }
  }

  Future<bool> updateStatus() async{
    final url = Uri.parse('https://678175e457ab.ngrok-free.app/milkaservice/api/add-resource-quantity');
    final novaKolicina = int.tryParse(novaKolicinaController.text) ?? 0;
    final aktualnaKolicina = int.tryParse(aktualnoStanjeController.text) ?? 0;

    if(novaKolicina<=0){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unesite količinu koja je veća od 0!'),
        ),
      );
      return false;
    }

    final Map<String, dynamic> payload ={
      "itemId": widget.sirovinaData['itemId'],
      "additionalQuantity": novaKolicina,
      "quantity": aktualnaKolicina,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
          "Authorization": "Bearer ${AuthService.token}",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        novaKolicinaController.clear();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uspješno ste ažurirali stanje sirovine'),
          ),
        );
        return true;
      }
      return false;
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Greška u povezivanju sa poslužiteljom."),
          backgroundColor: Color(0xff136DED),
        ),
      );
      return false;
    }
  }

  @override
  void dispose() {
    idProizvodaController.dispose();
    nazivProizvodaController.dispose();
    aktualnoStanjeController.dispose();
    novaKolicinaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
  title: Padding(
    padding: const EdgeInsets.only(top: 20.0, left: 20.0),
    child: Text('Ažuriranje zalihe - ${widget.sirovinaData['itemName']}', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
  ),
  content: SizedBox(
    height: 500,
    width: 900,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Naziv artikla', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),),
          SizedBox(height: 10,),
          TextField(
            controller: nazivProizvodaController,
            enabled: false,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xffF3F4F6),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelText: 'Naziv proizvoda',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Color(0xffF3F4F6)),
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
                      readOnly: isSelected[1],
                      enabled: isSelected[0],
                      decoration: InputDecoration(
                        hoverColor: isSelected[0] ? Colors.white : Color(0xffF3F4F6),
                        filled: true,
                        fillColor: isSelected[0] ? Colors.white : const Color(0xffF3F4F6),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Trenutno stanje',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xffF3F4F6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black)
                        )
                      ),
                      style: const TextStyle(color: Colors.black, fontFamily: 'Inter'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nova količina', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
                    SizedBox(height: 10,),
                    TextField(
                      readOnly: isSelected[0] ? true : false,
                      enabled: isSelected[1],
                      controller: novaKolicinaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hoverColor: isSelected[1] ? Colors.white : Color(0xffF3F4F6),
                        filled: true,
                        fillColor: isSelected[1] ? Colors.white : const Color(0xffF3F4F6),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Dodaj novu količinu',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xffF3F4F6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.black)
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 30.0,),
          Text('Želite li urediti aktualno stanje proizvoda?', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter',),),
          SizedBox(height: 20,),
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
                      child: Center(child: Text('DA', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),)),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                      child: Center(child: Text('NE', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),)),
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
      onPressed: (){
        showDialog(
          context: context, 
          builder: (context) => AlertDialog(
          title: Text('Potvrda brisanja'),
          content: Text('Jeste li sigurni da želite obrisati ovu sirovinu? Ova akcija se ne može poništiti.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Otkaži', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            ),
            ElevatedButton(
              onPressed: () async {
                await deleteItem(widget.sirovinaData['itemId'], widget.sirovinaData['type']);
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                Navigator.pop(context); // zatvori confirmation dialog
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                Navigator.pop(context, true); // zatvori glavni popup
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 229, 132, 132)),
              ),
              child: Text('Obriši', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        );
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 229, 132, 132)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 40, vertical: 20),),
      ), 
    child: const Text('Obriši proizvod', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
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
        bool uspjeh = await updateStatus();
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
