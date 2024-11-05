import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/app_colors.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/AuthResponse.dart';
import 'package:rg_event_management_ui/services/userservices.dart';
import 'dart:developer';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final userText = TextEditingController();
  final passwordText = TextEditingController();
  var token = "";
  @override
  Widget build(BuildContext context) {
    
    var appState = context.watch<MyAppState>();

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.backColor,
      appBar: AppBar(
        title: Text('Pantalla inicial', style: TextStyle(color: AppColors.blueDarkColor,
        fontWeight: FontWeight.w700),),
      ),
      body: SizedBox(
        height: height,
        width: width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: height,
                color:AppColors.blueDarkColor,
                child: Center(
                  child: Image(
                    image: AssetImage('assets/images/rg.png'),
                    width: 600.0,
                    height: 600.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: height,
                margin: EdgeInsets.symmetric(horizontal: height * 0.12),
                color: AppColors.backColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: '',
                                style: TextStyle(
                                  fontSize: 25.0,
                                  color: AppColors.blueDarkColor,
                                  fontWeight: FontWeight.normal,
                                )),
                            TextSpan(
                              text: ' Bienvenido',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.blueDarkColor,
                                fontSize: 25.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      Text(
                        'Ingresa tus datos para continuar',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pinkColor,
                        ),
                      ),
                      SizedBox(height: height * 0.064),
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: Text(
                          'Usuario: ',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: AppColors.pinkColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Container(
                        height: 50.0,
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: AppColors.whiteColor,
                        ),
                        child: TextFormField(
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor,
                            fontSize: 12.0,
                          ),
                          controller: userText,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(top: 7.0),
                            hintText: ' Ingresa tu usuario',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0,
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'El campo no puede estar vacío'
                              : null,
                        ),
                      ),
                      SizedBox(height: height * 0.014),
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: Text(
                          'Password:',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: AppColors.pinkColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Container(
                        height: 50.0,
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: AppColors.whiteColor,
                        ),
                        child: TextFormField(
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor,
                            fontSize: 12.0,
                          ),
                          obscureText: true,
                          controller: passwordText,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(top: 6.0),
                            hintText: 'Ingresa tu contraseña',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            UserService()
                                .login(userText.text, passwordText.text)
                                .then(
                                    (AuthResponse response) => setState(() {
                                          token = response.token;
                                          if (token != "" && response.error == "") {
                                            log('token: $token');
                                            appState.setToken(token);
                                            Navigator.push(context,
                                            MaterialPageRoute(builder: (context) {
                                              return EventsHomePage();
                                            }));
                                          } else {
                                            
                                            passwordText.clear();
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Error'),
                                                  content: Text(
                                                      'Usuario o contraseña incorrectos'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('Cerrar'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                        }
                            }),
                            onError: (s) => {log('error: $s')});
                          },
                          borderRadius: BorderRadius.circular(16.0),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 70.0, vertical: 18.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: AppColors.blueDarkColor,
                            ),
                            child: Text(
                              'Ingresar',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteColor,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
