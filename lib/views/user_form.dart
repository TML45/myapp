import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/provider/users.dart';
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

class _UserFormState extends State<UserForm>
    with SingleTickerProviderStateMixin {
  final Map<String, String> _formData = {};
  List<String> _arquivos = [];
  DateTime? _selectedDate;
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(), // Etapa 0 - Procedimento
    GlobalKey<FormState>(), // Etapa 1 - Data
  ];
  int _currentStep = 0;

  late TextEditingController _dateController;
  late TextEditingController _observacaoController;
  late TextEditingController _pesoController;
  late TextEditingController _alturaController;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _observacaoController = TextEditingController();
    _pesoController = TextEditingController();
    _alturaController = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _observacaoController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _animationController.dispose();
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
      if (_formData['procedimento'] == 'Antropometria') {
        _formData['observacao'] =
            'Peso: ${_pesoController.text} kg, Altura: ${_alturaController.text} cm';
      } else {
        _formData['observacao'] = _observacaoController.text;
      }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_currentStep < _formKeys.length) {
        final currentFormKey = _formKeys[_currentStep];
        if (currentFormKey.currentState?.validate() ?? true) {
          setState(() {
            _currentStep++;
            _animationController.forward(from: 0.0);
          });
        }
      } else {
        setState(() {
          _currentStep++;
          _animationController.forward(from: 0.0);
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _animationController.forward(from: 0.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> steps = [
      _buildProcedimentoStep(),
      _buildDataStep(),
      _buildObservacaoStep(),
      _buildArquivosStep(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Formulário do Procedimento',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: _slideAnimation,
              child: child,
            ),
          );
        },
        child: Padding(
          key: ValueKey<int>(_currentStep),
          padding: const EdgeInsets.all(15.0),
          child: steps[_currentStep],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 150, 211, 252),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 30,
              color: Colors.blue,
              onPressed: _currentStep > 0 ? _previousStep : null,
            ),
            if (_currentStep < steps.length - 1)
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                iconSize: 30,
                color: Colors.blue,
                onPressed: _nextStep,
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text(
                  'SALVAR',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
                onPressed: () {
                  bool allValid = true;
                  for (var formKey in _formKeys) {
                    if (formKey.currentState != null &&
                        !formKey.currentState!.validate()) {
                      allValid = false;
                    }
                  }
                  if (allValid) {
                    _saveForm();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Qual o tipo de procedimento?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FormField<String>(
                initialValue: _formData['procedimento'],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Selecione um procedimento';
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
                          activeColor: Colors.blue,
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
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataStep() {
    return Form(
      key: _formKeys[1],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Quando aconteceu?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Data do Procedimento',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
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
                      String formattedDate = DateFormat(
                        'dd/MM/yyyy',
                      ).format(pickedDate);
                      _dateController.text = formattedDate;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Selecione a data';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObservacaoStep() {
    if (_formData['procedimento'] == 'Antropometria') {
      return Form(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Informe seu peso e altura',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _pesoController,
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alturaController,
                  decoration: const InputDecoration(
                    labelText: 'Altura (cm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Form(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Adicione uma observação',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  maxLines: 5,
                  controller: _observacaoController,
                  decoration: const InputDecoration(
                    labelText: 'Escreva aqui...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _formData['observacao'] = value,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildArquivosStep() {
    return Form(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Anexe seus arquivos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Selecionar'),
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                  );

                  if (result != null) {
                    List<String> selectedPaths = result.files
                        .where((file) => file.path != null)
                        .map((file) => file.path!)
                        .toList();

                    setState(() {
                      _arquivos.addAll(selectedPaths);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              if (_arquivos.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _arquivos.length,
                    itemBuilder: (context, index) {
                      String filePath = _arquivos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
                          title: Text(
                            p.basename(filePath),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            OpenFile.open(filePath);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _arquivos.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
