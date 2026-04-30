// user_list_item.dart - Widget item daftar pengguna
import 'package:flutter/material.dart';

class UserListItem extends StatelessWidget {
  const UserListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        title: Text('User Item'),
      ),
    );
  }
}
