import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sirana_milka/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obsecureText = true;


  Future <void> login() async{
    final url = Uri.parse(
      'https://96783e481af4.ngrok-free.app/auth/api/login'
    );

    final username = emailController.text.trim();
    final password = passwordController.text.trim();

    if(username.isEmpty || password.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Molimo Vas da ispunite sva polja."))
      );
      return;
    }

    final Map<String, dynamic> payload = {
      "username": username,
      "password": password,
    };

    try{
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
          body: jsonEncode(payload),
      );

      if(response.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vaša prijava je uspješna.')),
        );

      final token = jsonDecode(response.body)["token"];
      AuthService.setToken(token);
      Navigator.pushNamed(context, "dashboard");

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vaša prijava nije uspješna, molimo pokušajte ponovo.')),
        );
      }

    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška u povezivanju sa poslužiteljom."),
        backgroundColor: Color(0xff136DED),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xfff7f6f8),
        ),
        child: Center(
          child: Container(
            width: 450.0,
            height: 550.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  // Logo
                  CircleAvatar(
                    radius: 35.0,
                    backgroundImage: AssetImage('Login_Logo.png'),
                  ),
                  SizedBox(height: 15.0),

                  // Naslov
                  Text(
                    'Prijava u sustav',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15.0),

                  // Podnaslov
                  Text(
                    'Dobrodošli! Molimo unesite svoje podatke',
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),

                  // Forma
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Korisničko ime
                        Text(
                          'Korisničko ime',
                          style: TextStyle(fontSize: 12.0),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 15.0),
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8FAFD),
                            border: Border.all(
                              width: 1.2,
                              color: Color(0xFFF8FAFD),
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontSize: 12.0),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Unesite Vaše korisničko ime',
                              hintStyle: TextStyle(fontSize: 12.0),
                            ),
                          ),
                        ),

                        SizedBox(height: 15.0),

                        // Lozinka
                        Text(
                          'Lozinka',
                          style: TextStyle(fontSize: 12.0),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 15.0),
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8FAFD),
                            border: Border.all(
                              width: 1.2,
                              color: Color(0xFFF8FAFD),
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: TextField(
                            controller: passwordController,
                            obscureText: _obsecureText,
                            style: TextStyle(fontSize: 12.0),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                              suffixIcon: IconButton(
                                icon: Icon(_obsecureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                                  size: 14,
                                ),
                                tooltip: _obsecureText ? 'Prikaži lozinku' : 'Sakrij lozinku',
                                onPressed: () {
                                setState(() {
                                  _obsecureText = !_obsecureText;
                                });
                               },
                              ),
                              border: InputBorder.none,
                              hintText: 'Unesite Vašu lozinku',
                              hintStyle: TextStyle(fontSize: 12.0),
                            ),
                          ),
                        ),

                        SizedBox(height: 10.0),

                        // Gumb za prijavu i zaboravljena lozinka
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                login();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 145.0),
                                backgroundColor: Color(0xff136DED),
                                textStyle: TextStyle(color: Colors.white),
                              ),
                              child: Text(
                                'Prijavi se',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Center(
                              child: InkWell(
                                onTap: (){
                                  showDialog(
                                    context: context, 
                                    builder: (context) => AlertDialog(
                                      title: Center(child: Text('Zaboravili ste svoju lozinku?')),
                                      content: Text('Trenutačno nije moguće resetirati lozinku bez asistencije 4Solutionsa. Molimo kontaktirajte nas na info@4solutions.hr uz napomenu “HITNO”.'),
                                      actions: [
                                        TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ButtonStyle(
                                          backgroundColor: WidgetStatePropertyAll(Colors.blue),
                                         ),
                                         child: Text(
                                          'Zatvori',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text(
                                'Zaboravio sam lozinku?',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Color(0xff8DB6F5),
                                  ),
                               ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
