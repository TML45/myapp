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
    final avatar = const CircleAvatar(child: Icon(Icons.image));
    return ListTile(
      leading: avatar,
      title: Text(user!.dataDoProcedimento),
      subtitle: Text(user!.procedimento),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.blueAccent,
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.USER_FORM, arguments: user);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.blueAccent,
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: Text('Excluir Procedimento'),
                        content: Text('Tem certeza?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Não'),
                          ),
                          TextButton(
                            onPressed: () {
                              Provider.of<Users>(
                                context,
                                listen: false,
                              ).remove(user!);
                              Navigator.of(context).pop();
                            },
                            child: Text('Sim'),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
