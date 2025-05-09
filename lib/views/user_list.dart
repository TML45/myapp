import 'package:flutter/material.dart';
import 'package:myapp/components/user_tile.dart';
import 'package:myapp/provider/users.dart';
import 'package:myapp/routes/app_routes.dart';
import 'package:provider/provider.dart';

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    final Users users = Provider.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            AppRoutes.USER_FORM,
          );
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 150, 211, 252),
        shape: CircularNotchedRectangle(),
        // AutomaticNotchedShape(
        //   RoundedRectangleBorder(
        //     borderRadius: BorderRadius.only(
        //       topLeft: Radius.circular(25),
        //       topRight: Radius.circular(25),
        //     )
        //   ),
        // ),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.home), 
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.HOME,
                    );},
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 150, 211, 252),
        title: Image.asset(
          'assets/images/DINAXY_2.png',
          height: 25,
        ),
        actions: [
          // IconButton(
          //   onPressed: () {}, 
          //   icon: Icon(Icons.menu),
          // ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Histórico de Saúde',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(      
              child: users.count == 0
              ? Center(
                  child: Text(
                    'Aperte o botão + para adicionar seu primeiro item ao histórico!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                itemCount: users.count,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: UserTile(users.byIndex(i)),
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
