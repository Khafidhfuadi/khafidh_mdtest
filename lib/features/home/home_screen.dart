import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khafidh_mdtest/core/constants/enums.dart';
import 'package:khafidh_mdtest/core/widgets/verification_badge.dart';
import 'package:khafidh_mdtest/providers/auth_provider.dart';
import 'package:khafidh_mdtest/providers/user_provider.dart';
import 'package:khafidh_mdtest/features/auth/login/login_screen.dart';
import 'package:khafidh_mdtest/features/home/user_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().listenToUsers();
    });
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.logout();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderSection(theme),
          _buildSearchBar(theme),
          _buildFilterChips(theme),
          const Divider(height: 1),
          Expanded(child: _buildUserList(theme)),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  (user?.name.isNotEmpty == true)
                      ? user!.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'User',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    VerificationBadge(
                      isVerified: user?.isEmailVerified ?? false,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: auth.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Refresh status verifikasi',
                onPressed: auth.isLoading ? null : auth.refreshUser,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari nama atau email...',
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          context.read<UserProvider>().setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: FilterStatus.values.map((status) {
              final isSelected = userProvider.filterStatus == status;
              final label = switch (status) {
                FilterStatus.all => 'All',
                FilterStatus.verified => 'Verified',
                FilterStatus.unverified => 'Not Verified',
              };

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(label),
                  onSelected: (_) => userProvider.setFilter(status),
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.onPrimaryContainer,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildUserList(ThemeData theme) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = userProvider.filteredUsers;

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  userProvider.searchQuery.isNotEmpty ||
                          userProvider.filterStatus != FilterStatus.all
                      ? 'Tidak ada user yang cocok'
                      : 'Belum ada user terdaftar',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: users.length,
          itemBuilder: (context, index) {
            return UserListItem(user: users[index]);
          },
        );
      },
    );
  }
}
