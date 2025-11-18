import 'package:flutter/material.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/provider/users.dart';
import 'package:myapp/routes/app_routes.dart';
import 'package:provider/provider.dart';

class UserTile extends StatelessWidget {
  final User? user;

  const UserTile(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Adicione uma ação ao tocar no tile, se desejar
        },
        hoverColor: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.0),
        child: ListTile(
          leading: const Icon(Icons.receipt_long, color: Colors.teal, size: 40),
          title: Text(
            user!.procedimento,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(user!.dataDoProcedimento),
          trailing: SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.USER_FORM,
                      arguments: user,
                    );
                  },
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Excluir Procedimento'),
                        content: const Text(
                            'Tem certeza de que deseja excluir este registro?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child:
                                const Text('Não', style: TextStyle(color: Colors.teal)),
                          ),
                          TextButton(
                            onPressed: () {
                              Provider.of<Users>(
                                context,
                                listen: false,
                              ).remove(user!);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Sim',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: 'Excluir',
                ),
                const Icon(Icons.drag_handle, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
