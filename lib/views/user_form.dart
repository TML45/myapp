import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/provider/users.dart';
import 'package:myapp/routes/app_routes.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final Map<String, String> _formData = {};
  List<String> _arquivos = [];
  DateTime? _selectedDate;
  final _form = GlobalKey<FormState>(); 
  
  void _loadFormData(User? user) {
    if (user != null) {
      _formData['id'] = user.id!;
      _formData['dataDoProcedimento'] = user.dataDoProcedimento;
      _formData['procedimento'] = user.procedimento;
      _formData['observacao'] = user.observacao;
      _arquivos = user.arquivo;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = ModalRoute.of(context)?.settings.arguments as User?;
    _loadFormData(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 150, 211, 252),
        shape: AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            )
          ),
        ),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.home), 
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.HOME,
                    );
                  },
                  iconSize: 40,
                ),
                // SizedBox(width: 28),
                // IconButton(icon: Icon(Icons.account_circle), onPressed: () {}),
              ],
            ),
            Row(
              children: [
                // IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
                // SizedBox(width: 28),
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.information,
                    );
                  },
                  iconSize: 40,
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Formulário do Procedimento'),
        backgroundColor: Color.fromARGB(255, 150, 211, 252),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              final isValid = _form.currentState!.validate();

              if (isValid) {
                _form.currentState!.save();

                Provider.of<Users>(context, listen: false).put(
                  User(
                    id: _formData['id'],
                    dataDoProcedimento: _formData['dataDoProcedimento']!,
                    procedimento: _formData['procedimento']!,
                    observacao: _formData['observacao']!,
                    arquivo: _arquivos,
                  ),
                );

                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Form(
          key: _form,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _formData['procedimento'],
                decoration: InputDecoration(
                  labelText: 'Procedimento',
                  // labelStyle: TextStyle(color: Colors.blue),                  
                  // border: OutlineInputBorder(
                  //     borderRadius: BorderRadius.circular(10.0),
                  //     borderSide: BorderSide(
                  //       color: Color.fromARGB(255, 150, 211, 252),
                  //       width: 2.0,
                  //     ),
                  //   ),
                  ),
                items: ['Consulta', 'Exame', 'Antropometria']
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _formData['procedimento'] = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, selecione um procedimento';
                  }
                  return null;
                },
                onSaved: (value) => _formData['procedimento'] = value!,
              ),
              TextFormField(
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                      : _formData['dataDoProcedimento'] ?? '',
                ),
                decoration: InputDecoration(
                  labelText: 'Data do Procedimento',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _formData['dataDoProcedimento'] = DateFormat('dd/MM/yyyy').format(pickedDate);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, selecione uma data';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (_selectedDate != null) {
                    _formData['dataDoProcedimento'] = DateFormat('dd/MM/yyyy').format(_selectedDate!);
                  }
                },
              ),
              TextFormField(
                initialValue: _formData['observacao'] ?? '',
                decoration: InputDecoration(labelText: 'Observação'),
                onSaved: (value) => _formData['observacao'] = value!,
                maxLines: null,
              ),
              FormField<List<String>>(
                initialValue: _arquivos,
                builder: (FormFieldState<List<String>> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.attach_file),
                        label: Text('Selecionar Arquivos'),
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

                          if (result != null) {
                            List<String> selectedPaths = result.files
                                .where((file) => file.path != null)
                                .map((file) => file.path!)
                                .toList();

                            setState(() {
                              _arquivos.addAll(selectedPaths);
                            });
                            state.didChange(_arquivos);
                          }
                        },
                      ),
                      if (state.value != null && state.value!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: state.value!.length,
                            itemBuilder: (context, index) {
                              String filePath = state.value![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        OpenFile.open(filePath);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.insert_drive_file, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.5,
                                            child: Text(
                                              p.basename(filePath),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                                decoration: TextDecoration.underline,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.blueAccent),
                                      onPressed: () {
                                        setState(() {
                                          _arquivos.removeAt(index);
                                        });
                                        state.didChange(_arquivos);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
                onSaved: (value) {
                  _arquivos = value ?? [];
                },
              )
            ],
          ),
        ),
      ),
    );
  }

}
