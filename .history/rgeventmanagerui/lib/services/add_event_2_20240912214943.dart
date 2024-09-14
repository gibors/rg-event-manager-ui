// Padding( 
//         padding: EdgeInsets.only(left: 100.0, right: 200.0),
//         child: Form( 
//           key: _formKey,
//           child:Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: SizedBox( 
//                     width: 100,
//                     child: TextFormField(
//                       controller: eventName,
                      
//                       validator: (value) => value!.isEmpty ? 'Ingrese el nombre del evento' : null,
//                       decoration: InputDecoration(
//                         labelText: 'Nombre del evento',
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 200),
//                 Expanded( 
//                       child: isEditMode ? TextField(
//                         enabled: false,
//                         controller: TextEditingController(text: selectedEvent?.eventType.description.toString()),
//                         decoration: InputDecoration(
//                           labelText: 'Tipo del Evento',
//                         ),
//                       ) 
//                        : Autocomplete<EventType>(
//                         initialValue: TextEditingValue(text: selectedEventType?.description ?? ''),
//                       displayStringForOption: _displayStringEventTypesForOption,
//                       optionsBuilder: (TextEditingValue textEditingValue) {
                      
//                       return eventTypes
//                           .where((EventType option) {
//                         return option.description.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
//                       });
//                     },
//                     onSelected: (EventType selection) {
//                       setState(() {
//                         selectedEventType = selection;
//                       });
//                     },
//                     fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
//                       return TextFormField(
//                         validator: (value) => value!.isEmpty ? 'Seleccione el tipo de evento' : null,
//                       controller: textEditingController,
//                       focusNode: focusNode,
//                       decoration: InputDecoration(
//                         labelText: 'Tipo de evento',
//                       ),
//                       onChanged: (String value) {
                       
//                       },
                      
//                       );    
//                     },
//                     optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<EventType> onSelected, Iterable<EventType> options) {
//                       return Material(
//                         child:
//                         SizedBox( 
//                         height: 100.0,
//                         width: 200,
//                       child: ListView(
//                         children: options.map((EventType option) => GestureDetector(
//                           onTap: () {
//                             onSelected(option);
//                           },
//                           child: ListTile(
//                             title: Text(option.description),
//                           ),
//                         )).toList(),
//                       ),
//                       ),
//                       );
//                     },
//                   ), 
//                 )
//               ],
//             ),
//              SizedBox(height: 30.0), 
//              Visibility(
//               visible: (selectedEventType != null && selectedEventType!.id == 3), // condition here
//               child: Container(child:
//              Row( 
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: grado,
//                     decoration: InputDecoration(
//                       labelText: 'Grado',
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 200),
//                 Expanded(
//                   child: TextFormField(
//                     inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],  
//                     controller: additionalCost,
//                     decoration: InputDecoration(
//                       labelText: 'Costo Adicional',
//                     ),
//                   ),
//                 ),
//               ],
//              ),
//              ),
//              ),
//             SizedBox(height: 30.0),
//                    Row(
//               children: [
//                 Expanded(
//                     child: RawAutocomplete<Location>(
//                       displayStringForOption: _displayStringLocationsForOption,
//               key: _autocompleteKey,
//               focusNode: _focusNode,
//               textEditingController: _textEditingLocationController,
//               optionsBuilder: (TextEditingValue textEditingValue) {
//                 return locations.where((Location option) {
//                   return option.locationName.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
//                 }).toList();
//               },
//               optionsViewBuilder: (BuildContext context,
//                   AutocompleteOnSelected<Location> onSelected,
//                   Iterable<Location> options) {
//                 return Material(
//                   elevation: 4.0,
//                   child: ListView(
//                     children: options
//                         .map((Location option) => GestureDetector(
//                               onTap: () {
//                                 onSelected(option);
//                               },
//                               child: ListTile(
//                                 title: Text(option.locationName),
//                               ),
//                             ))
//                         .toList(),
//                   ),
//                 );
//               },
//               fieldViewBuilder: (
//                 BuildContext context,
//                 TextEditingController fieldTextEditingController,
//                 FocusNode fieldFocusNode,
//                 VoidCallback onFieldSubmitted,
//               ) {
//                 return TextFormField(
//                   controller: fieldTextEditingController,
//                   focusNode: fieldFocusNode,
//                   decoration: const InputDecoration(labelText: 'Selecciona salón'),
//                 );
//               },
//               onSelected: (Location selection) {
//                 log('Selected location: ${selection.locationName}');
//                 _textEditingCapacityController.text = selection.capacity.toString();
//                       setState(() {
//                         selectedLocation = selection;
//                       });
//                     },
//             ),
//                 ),
//                 SizedBox(width: 200),
                
//                 Expanded(
//                     child: RawAutocomplete<Location>(
//                       displayStringForOption: _displayStringCapacityForOption,
//               key: _autocompleteKeyCapacity,
//               focusNode: _focusCapacityNode,
//               textEditingController: _textEditingCapacityController,
//               optionsBuilder: (TextEditingValue textEditingValue) {
//                 return locations.where((Location option) {
//                   return option.capacity.toString().startsWith(textEditingValue.text.toLowerCase());
//                 }).toList();
//               },
//               optionsViewBuilder: (BuildContext context,
//                   AutocompleteOnSelected<Location> onSelected,
//                   Iterable<Location> options) {
//                 return Material(
//                   elevation: 4.0,
//                   child: ListView(
//                     children: options
//                         .map((Location option) => GestureDetector(
//                               onTap: () {
//                                 onSelected(option);
//                               },
//                               child: ListTile(
//                                 title: Text(option.capacity.toString()),
//                               ),
//                             ))
//                         .toList(),
//                   ),
//                 );
//               },
//               fieldViewBuilder: (
//                 BuildContext context,
//                 TextEditingController fieldTextEditingController,
//                 FocusNode fieldFocusNode,
//                 VoidCallback onFieldSubmitted,
//               ) {
//                 return TextFormField(
//                   controller: fieldTextEditingController,
//                   focusNode: fieldFocusNode,
//                   decoration: const InputDecoration(labelText: 'Selecciona capacidad'),
//                 );
//               },
//               onSelected: (Location selection) {
//                 log('Selected location: ${selection.locationName}');
//                 _textEditingLocationController.text = selection.locationName;
//                 _textEditingLocationController.selection = TextSelection.fromPosition( TextPosition(offset: _textEditingCapacityController.text.length));
//                       setState(() {
//                         selectedLocation = selection;
//                       });
//                     },
//             ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 30.0),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: contactName,
//                     decoration: InputDecoration(
//                       labelText: 'Nombre del Contacto',
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 200),
//                 Expanded(
//                   child: TextFormField(
//                     controller: contactPhone,
//                     inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
//                     decoration: InputDecoration(
//                       labelText: 'Telefono del Contacto',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//              SizedBox(height: 30.0),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     validator: (value) {
//                       if (value != null && value.isNotEmpty && !RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$').hasMatch(value)) {
                        
//                         return 'Ingrese un correo valido';
//                       }

//                       return null;
//                     },
//                     controller: contactEmail,
//                     decoration: InputDecoration(
//                       labelText: 'Correo para estado de cuenta',
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 200),
//                 Expanded(
//                   child: TextFormField(
//                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     controller: minCapacity,
//                     decoration: InputDecoration(
//                       labelText: 'minimo de invitados',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 30.0),
//             Row( 
              
//               children: [
//                 Expanded( 
//                   flex: 1,
//                   child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                     'Fecha del evento:',
//                     style: TextStyle(
//                       fontSize: 16.0,
//                     ),
//                     ),
//                     SizedBox(height: 10.0),
//                     CalendarDatePicker( 
//                     initialDate: selectedDate ?? DateTime.now(),
//                     firstDate: DateTime.now().subtract(Duration(days: 365)),
//                     lastDate: DateTime.now().add(Duration(days: 365)),
//                     onDateChanged: (date) {
//                       // Handle date change
//                       selectedDate = date;
//                       log('Selected date: $date');
//                     },
                    
//                     initialCalendarMode: DatePickerMode.day,
//                     selectableDayPredicate: (date) {
                     
//                       return true;
//                     },
                    
//                     ),
//                   ],
//                   ),
//                 ),
//                 SizedBox(width: 200),
//                 Expanded(  
//                   flex: 1,
//                   child: Column(  
//                     mainAxisAlignment: MainAxisAlignment.end ,
                    
//                     children: [
//                     TextFormField(
//                       controller: eventCost,
//                       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],                      
//                     decoration: InputDecoration(
//                       labelText: 'Precio por platillo',
//                     ),
//                   ),
                  
//                   SizedBox(height: 10.0),
                  
//                   Visibility(
//                     visible: (selectedEventType != null && selectedEventType!.id == 3),
//                     child: Column( 
                      
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         TextFormField(
//                           controller: eventCostPackage10,
//                           inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],  
//                           decoration: InputDecoration(
//                             labelText: 'Precio paq 10',
//                           ),
//                         ),
//                         SizedBox(height: 10.0),
//                         TextFormField(
//                           controller: eventCostPackage10NoPre,
//                           inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],  
//                           decoration: InputDecoration(
//                             labelText: 'Precio paq 10 sin prefiestas',
//                           ),
//                         ),
//                         SizedBox(height: 10.0),
//                         TextFormField(
//                           inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],  
//                           controller: eventCostPackageHalf,
//                           decoration: InputDecoration(
//                             labelText: 'Precio paq 5',
//                           ),
//                         ),
//                         SizedBox(height: 10.0),
//                         TextFormField(
//                           controller: eventCostPackageHalfNoPre,
//                           inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],  
//                           decoration: InputDecoration(
//                             labelText: 'Precio paq 5 sin prefiestas',
//                           ),
//                         ),
//                         SizedBox(height: 10.0),
//                         TextFormField(
//                           inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],  
//                           controller: eventCostPackageDouble,
//                           decoration: InputDecoration(
//                             labelText: 'precio paquete doble',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   ],
//                   ),
//                   )
//               ],
//             ),
//             SizedBox(height: 30.0),
 
//             ElevatedButton(
//                style: ButtonStyle(
//                 textStyle: WidgetStateProperty.all<TextStyle>(TextStyle(fontSize: 18)),
//                 foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
//                 // fixedSize: MaterialStateProperty.all<Size>(Size(120, 60 )),
//                 backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 243, 33, 128)),
//                  ),
//               onPressed: () {
//                 if(_formKey.currentState!.validate()) {
//                   log('Form is valid');
//                   saveEvent();

//                 } else {
//                   log('form is invalid');
//                 }
//               },
              
//               child: Text('Guardar'),
             
//             ),
//           ],
//         ),
//       ),
//       ),
//       );