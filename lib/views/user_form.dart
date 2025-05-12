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
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(), // Step 0 - Procedimento
    GlobalKey<FormState>(), // Step 1 - Data
  ];
  int _currentStep = 0;

  late TextEditingController _dateController;
  late TextEditingController _observacaoController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _observacaoController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  void _loadFormData(User? user) {
    if (user != null) {
      _formData['id'] = user.id!;
      _formData['dataDoProcedimento'] = user.dataDoProcedimento;
      _formData['procedimento'] = user.procedimento;
      _formData['observacao'] = user.observacao;
      _arquivos = user.arquivo;
      _dateController.text = user.dataDoProcedimento;
      _observacaoController.text = user.observacao;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ModalRoute.of(context)?.settings.arguments as User?;
    _loadFormData(user);
  }

  void _saveForm() {
    try {
      _formData['observacao'] = _observacaoController.text;
      _formData['dataDoProcedimento'] = _dateController.text;

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
    } catch (e) {
      print('Error during save: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> steps = [
      _buildProcedimentoStep(),
      _buildDataStep(),
      _buildObservacaoStep(),
      _buildArquivosStep(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário do Procedimento'),
        backgroundColor: Color.fromARGB(255, 150, 211, 252),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: steps[_currentStep],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 150, 211, 252),
        shape: AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
        ),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 40,
              onPressed:
                  _currentStep > 0
                      ? () {
                        setState(() {
                          _currentStep--;
                        });
                      }
                      : null,
            ),
            IconButton(
              icon: Icon(
                _currentStep < steps.length - 1
                    ? Icons.arrow_forward
                    : Icons.save,
              ),
              iconSize: 40,
              onPressed: () {
                if (_currentStep < steps.length - 1) {
                  if (_currentStep < _formKeys.length) {
                    final currentFormKey = _formKeys[_currentStep];
                    if (currentFormKey.currentState == null ||
                        currentFormKey.currentState!.validate()) {
                      setState(() {
                        _currentStep++;
                      });
                    }
                  } else {
                    setState(() {
                      _currentStep++;
                    });
                  }
                } else {
                  // Last step, validate all forms before saving
                  bool allValid = true;
                  for (var formKey in _formKeys) {
                    if (formKey.currentState != null &&
                        !formKey.currentState!.validate()) {
                      allValid = false;
                    }
                  }
                  if (allValid) {
                    _saveForm();
                  } else {
                    print('Form has validation errors.');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedimentoStep() {
    return Form(
      key: _formKeys[0],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Para começar, escolha o tipo de entrada de saúde.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Essa informação é importante para....',
              style: TextStyle(fontSize: 14),
            ),
            FormField<String>(
            initialValue: _formData['procedimento'],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, selecione um procedimento';
              }
              return null;
            },
            builder: (FormFieldState<String> field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...['Consulta', 'Exame', 'Antropometria'].map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: field.value,
                      onChanged: (value) {
                        field.didChange(value);
                        setState(() {
                          _formData['procedimento'] = value!;
                        });
                      },
                    );
                  }).toList(),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        field.errorText!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              );
            },
          ),
              SizedBox(height: 16),
            ],
          ),
      ),
    );
  }

  Widget _buildDataStep() {
    return Form(
      key: _formKeys[1],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Essa consulta aconteceu quando?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Se foi hoje, pode avançar. Caso contrário selecione o a data no calendário abaixo.',
              style: TextStyle(fontSize: 14),
            ),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Data do Procedimento',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: false,
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
                    String formattedDate = DateFormat(
                      'dd/MM/yyyy',
                    ).format(pickedDate);
                    _dateController.text = formattedDate;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, selecione a data do procedimento';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservacaoStep() {
    return Form(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Entre agora com uma informação sobre sua consulta:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Adicione detalhes de texto descrevendo o que aconteceu durante a sua consulta.',
              style: TextStyle(fontSize: 14),
            ),
            TextFormField(
              maxLines: null,
              controller: _observacaoController,
              decoration: InputDecoration(labelText: 'Observação'),
              onChanged: (value) => _formData['observacao'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArquivosStep() {
    return Form(
      child: Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Possui algum arquivo para guardar?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Sua consulta gerou algum prontuário, receita, exame, etc. Você pode fazer o upload do arquivo ou tirar uma foto clicando nas opções abaixo:',
                style: TextStyle(fontSize: 14),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.attach_file),
                label: Text('Selecionar Arquivos'),
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                  );

                  if (result != null) {
                    List<String> selectedPaths =
                        result.files
                            .where((file) => file.path != null)
                            .map((file) => file.path!)
                            .toList();

                    setState(() {
                      _arquivos.addAll(selectedPaths);
                    });
                  }
                },
              ),
              if (_arquivos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _arquivos.length,
                    itemBuilder: (context, index) {
                      String filePath = _arquivos[index];
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
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
      ),
    );
  }
}
