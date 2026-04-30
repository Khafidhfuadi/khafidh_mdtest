import 'package:flutter/material.dart';
import 'package:khafidh_mdtest/core/widgets/verification_badge.dart';
import 'package:khafidh_mdtest/data/models/user_model.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;

  const UserListItem({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(user.email),
        trailing: VerificationBadge(isVerified: user.isEmailVerified),
      ),
    );
  }
}
