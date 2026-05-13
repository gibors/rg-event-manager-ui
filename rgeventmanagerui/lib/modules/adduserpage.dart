import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rg_event_management_ui/main.dart';
import 'package:rg_event_management_ui/models/User.dart';
import 'package:rg_event_management_ui/services/userservices.dart';

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  List<String> roles = ['Administrador', 'Operador', 'Solo lectura'];
  
  String? _selectedRole;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _autocompleteRoleKey = GlobalKey();
  final _focusRole = FocusNode();
  TextEditingController _roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if(context.read<MyAppState>().selectedUserToEdit != null){
      mapUserToControllers(context.read<MyAppState>().selectedUserToEdit!);
    }

  }

  mapUserToControllers(User user){
    _nameController.text = user.name;
    _lastNameController.text = user.lastname;
    _emailController.text = user.email;
    _usernameController.text = user.username;
    _passwordController.text = user.password;
    _roleController.text = user.role == 1 ? 'Administrador' : user.role == 2 ? 'Operador' : 'Solo lectura';
  }
  
  mapControllerToUser(){
    var appState = context.read<MyAppState>();
    var user =  User(
      id: appState.selectedUserToEdit != null ? appState.selectedUserToEdit!.id : -1,
      name: _nameController.text,
      lastname: _lastNameController.text,
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      role: _selectedRole != null ? _selectedRole == 'Administrador' ? 1 : _selectedRole == 'Operador' ? 2 : 3 : 3,
      status: true
    );
    return user;
  }

  void saveUser(){
    var user = mapControllerToUser();
    var appState = context.read<MyAppState>();

    UserService().saverUser(user, appState.appToken).then(
      (value) {
        
        appState.setSelectedUserToEdit(value);
         Flushbar( 
        flushbarPosition : FlushbarPosition.TOP,
        title: 'Guardado',
        message: 'Usuario guardado correctamente',
        flushbarStyle: FlushbarStyle.FLOATING,
        messageColor: Colors.green,
        duration: Duration(seconds: 3),
      ).show(context);
      }
     )
     .catchError((e){
      log('Error saving user ${e.toString()}');
      if(e.toString().contains('User already exists')){
        Flushbar( 
        flushbarPosition : FlushbarPosition.TOP,
        title: 'Error',
        message: 'El usuario ya existe',
        flushbarStyle: FlushbarStyle.FLOATING,
        messageColor: Colors.red,
        duration: Duration(seconds: 3),
      ).show(context);
      } else {
       Flushbar( 
        flushbarPosition : FlushbarPosition.TOP,
        title: 'Error',
        message: 'Error al guardar el usuario',
        flushbarStyle: FlushbarStyle.FLOATING,
        messageColor: Colors.red,
        duration: Duration(seconds: 3),
      ).show(context);
      }
     });

  }

  void registerUser(){
    var appState = context.read<MyAppState>();
    var user =  User(
      id: appState.selectedUserToEdit != null ? appState.selectedUserToEdit!.id : -1,
      name: _nameController.text,
      lastname: _lastNameController.text,
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      role: _selectedRole != null ? _selectedRole == 'Administrador' ? 1 : _selectedRole == 'Operador' ? 2 : 3 : 3,
      status: true
    );
    try {
     UserService().registerUser(user).then(
      (value) {
        setState(() {
          appState.setSelectedUserToEdit(value);
        });
         Flushbar( 
        flushbarPosition : FlushbarPosition.TOP,
        title: 'Guardado',
        message: 'Usuario guardado correctamente',
        flushbarStyle: FlushbarStyle.FLOATING,
        messageColor: Colors.green,
        duration: Duration(seconds: 3),
      ).show(context);
      }
     )
     .catchError((e){
      log('Error saving user ${e.toString()}');
      if(e.toString().contains('User already exists')){
        Flushbar( 
        flushbarPosition : FlushbarPosition.TOP,
        title: 'Error',
        message: 'El usuario ya existe',
        flushbarStyle: FlushbarStyle.FLOATING,
        messageColor: Colors.red,
        duration: Duration(seconds: 3),
      ).show(context);
      } else {
       Flushbar( 
        flushbarPosition : FlushbarPosition.TOP,
        title: 'Error',
        message: 'Error al guardar el usuario',
        flushbarStyle: FlushbarStyle.FLOATING,
        messageColor: Colors.red,
        duration: Duration(seconds: 3),
      ).show(context);
      }
     });
     
    } catch (e) {
      Flushbar( 
        flushbarPosition : FlushbarPosition.TOP,
        title: 'Error',
        message: 'Ocurrió un error al guardar el usuario',
        flushbarStyle: FlushbarStyle.FLOATING,
        messageColor: Colors.red,
        duration: Duration(seconds: 3),
      ).show(context);
    }

    // Navigator.pop(context);
  }

  bool passwordValidator() {
    var valid = true;
    if (_passwordController.text.length < 8 && _passwordController.text.length > 12) {
      valid = false;
    }
    if (!_passwordController.text.contains(RegExp(r'[0-9]'))) {
      valid = false;
    }
    return valid;
  }

  bool emailValidator() {
    var valid = true;
    if (!_emailController.text.contains(RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'))) {
      valid = false;
    }
    return valid;
  }

  @override
  Widget build(BuildContext context) {

    var appState = context.read<MyAppState>();

    return Scaffold(
       appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            appState.clearSelectedUserToEdit();
            appState.setIndex(7);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EventsHomePage()));

          },
        ),
        title: Text(appState.selectedUserToEdit == null ? 'Agregar Usuario' : 'Editar Usuario',
            style: TextStyle(
                fontSize: 24.0, color: Color.fromRGBO(250, 10, 100, 0.8))),
      ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child:
         Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20,),
         Row(
           children: <Widget>[
             Expanded(
               child: TextFormField(
                validator: (value) => value!.isEmpty ? 'El nombre es requerido' : null,
                controller: _nameController,
                 decoration: InputDecoration(
                   hintText: 'Nombre'
                 ),
               ),
             ),
             SizedBox(width: 20,),
              Expanded(
                child: TextFormField(
                  validator: (value) => value!.isEmpty ? 'El apellido es requerido' : null,
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    hintText: 'Apellido'
                  ),
                ),
              )
           ],
         ),
          SizedBox(height: 20,),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _usernameController,
                  validator: (value) => value!.isEmpty ? 'El usuario es requerido' : null,
                  decoration: InputDecoration(
                    hintText: 'Usuario'
                  ),
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) => _passwordController.text.isEmpty ? "La contraseña es requerida" : passwordValidator() ? null : 'La contraseña debe estar entre 6 y 12 caracteres, include al menos un número',
                  decoration: InputDecoration(
                    hintText: 'Contraseña',

                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 20,),
          Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  inputFormatters: [],
                  validator: (value) => value!.isEmpty ? 'El correo es requerido' : emailValidator() ? null : 'Ingrese un correo válido',
                  decoration: InputDecoration(
                    hintText: 'Correo'
                  ),
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: RawAutocomplete<String>(
                  key: _autocompleteRoleKey,
                  focusNode: _focusRole,
                  textEditingController: _roleController,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return roles;
                    }
                    return roles.where((String option) {
                      return option.contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    _roleController.text = selection;
                    _selectedRole = selection;
                  },
                   fieldViewBuilder: (BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) {
                                return TextFormField(
                                
                                  controller: _roleController,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    labelText: 'Role',
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? 'El role es requerido'
                                      : null,
                                );
                              },
                              optionsViewBuilder: (BuildContext context,
                                  AutocompleteOnSelected<String> onSelected,
                                  Iterable<String> options) {
                                return Material(
                                  child: ListView(
                                    children: options
                                        .map((String option) => GestureDetector(
                                              onTap: () {
                                                onSelected(option);
                                              },
                                              child: ListTile(
                                                title: Text(option),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                );
                              },

                ),
              )
            ],
          ),
          SizedBox(height: 55,),
          Row(children: [
            Expanded(
              flex: 1,
              child: Expanded(
                child: OutlinedButton(
                  onPressed: (){
                    if(_formKey.currentState!.validate()){
                      if(appState.selectedUserToEdit != null){
                      
                      saveUser();
                      }
                     else {
                      registerUser();
                    }
                    }
                  },
                  child: Text(appState.selectedUserToEdit == null ? 'Registrar' :'Guardar'),
                ),
              ),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 1,
              child: Expanded(
                child: OutlinedButton(
                  onPressed: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Cancelar'),
                        content: Text('¿Está seguro de cancelar el registro?'),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: (){
                              appState.clearSelectedUserToEdit();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text('Si'),
                          )
                        ],
                      );
                    }
                  );
                  },
                  child: Text('Cancelar'),
                ),
              ),
            )
          ],)
        ],
      ),
      ),
    ),
     
    );
  }
}