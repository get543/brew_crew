import 'package:flutter/material.dart';
import 'package:brew_crew/screens/authenticate/authenticate.dart';
import 'package:brew_crew/screens/customer/customer_home.dart';
import 'package:brew_crew/screens/barista/barista_home.dart';
import 'package:brew_crew/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:brew_crew/models/user.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModels?>(context);

    if (user == null) {
      // no user logged in, show authenticate screen
      return Authenticate();
    } else {
      return StreamBuilder(
        stream: UserService().user(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // return either BaristaHome or CustomerHome
          return snapshot.data!.role == 'barista' ? const BaristaHome() : CustomerHome(user: snapshot.data!);
        },
      );
    }
  }
}
