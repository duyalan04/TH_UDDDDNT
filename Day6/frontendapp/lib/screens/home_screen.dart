import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/router/app_router.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Email is required';
  }

  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(email)) {
    return 'Email is not valid';
  }

  return null;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user session')));
    }

    if (auth.isAdmin) {
      return _AdminSection(authService: _authService, onLogout: _logout);
    }

    return _UserSection(
      authService: _authService,
      user: user,
      onLogout: _logout,
    );
  }
}

class _UserSection extends StatelessWidget {
  const _UserSection({
    required this.authService,
    required this.user,
    required this.onLogout,
  });

  final AuthService authService;
  final AppUser user;
  final Future<void> Function() onLogout;

  Future<void> _open(BuildContext context, Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text('Delete your account permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.deleteAccount();

    if (!context.mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Cannot delete account')),
      );
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('User Section'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          children: [
            Center(
              child: Text(
                'User Methods',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
            _SectionActionButton(
              label: 'User Info',
              icon: Icons.account_circle_outlined,
              color: Colors.blue.shade900,
              onPressed: () => _open(context, _UserInfoPage(user: user)),
            ),
            _SectionActionButton(
              label: 'Edit Profile',
              icon: Icons.edit_outlined,
              color: Colors.blue.shade900,
              onPressed: () => _open(context, _EditProfilePage(user: user)),
            ),
            _SectionActionButton(
              label: 'Change Password',
              icon: Icons.lock_reset,
              color: Colors.blue.shade900,
              onPressed: () => _open(
                context,
                _ChangePasswordPage(authService: authService),
              ),
            ),
            _SectionActionButton(
              label: 'Delete Account',
              icon: Icons.delete_outline,
              color: Colors.blue.shade900,
              onPressed: () => _deleteAccount(context),
            ),
            _SectionActionButton(
              label: 'Logout',
              icon: Icons.logout,
              color: Colors.blue.shade900,
              onPressed: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSection extends StatelessWidget {
  const _AdminSection({required this.authService, required this.onLogout});

  final AuthService authService;
  final Future<void> Function() onLogout;

  Future<void> _open(BuildContext context, Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Admin Section'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          children: [
            Center(
              child: Text(
                'Admin Methods',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
            _AdminActionButton(
              label: 'Show Users',
              icon: Icons.people_alt_outlined,
              onPressed: () => _open(
                context,
                _UsersPage(authService: authService),
              ),
            ),
            _AdminActionButton(
              label: 'Add New User',
              icon: Icons.person_add_alt_1,
              onPressed: () => _open(
                context,
                _AddUserPage(authService: authService),
              ),
            ),
            _AdminActionButton(
              label: 'Change User Roles',
              icon: Icons.admin_panel_settings_outlined,
              onPressed: () => _open(
                context,
                _ChangeUserRolesPage(authService: authService),
              ),
            ),
            _AdminActionButton(
              label: 'Change Password',
              icon: Icons.lock_reset,
              onPressed: () => _open(
                context,
                _ChangePasswordPage(authService: authService),
              ),
            ),
            _AdminActionButton(
              label: 'Logout',
              icon: Icons.logout,
              onPressed: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminActionButton extends StatelessWidget {
  const _AdminActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _SectionActionButton(
      label: label,
      icon: icon,
      color: Colors.green.shade700,
      onPressed: onPressed,
    );
  }
}

class _SectionActionButton extends StatelessWidget {
  const _SectionActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 54,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _UsersPage extends StatefulWidget {
  const _UsersPage({required this.authService});

  final AuthService authService;

  @override
  State<_UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<_UsersPage> {
  late Future<List<AppUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = widget.authService.getUsers();
  }

  Future<void> _refreshUsers() {
    final usersFuture = widget.authService.getUsers();

    setState(() {
      _usersFuture = usersFuture;
    });

    return usersFuture.then((_) {});
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete user'),
        content: Text('Delete ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await widget.authService.deleteUser(user.id);
    await _refreshUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshUsers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: FutureBuilder<List<AppUser>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Cannot load users: ${snapshot.error}'),
                    ),
                  ),
                ],
              );
            }

            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No users found'),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = users[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        user.fullName.isEmpty
                            ? '?'
                            : user.fullName[0].toUpperCase(),
                      ),
                    ),
                    title: Text(user.fullName),
                    subtitle: Text('${user.email}\n${user.roles.join(', ')}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'Delete',
                      onPressed: () => _deleteUser(user),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AddUserPage extends StatefulWidget {
  const _AddUserPage({required this.authService});

  final AuthService authService;

  @override
  State<_AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<_AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late Future<List<String>> _rolesFuture;
  final Set<String> _selectedRoles = {'User'};
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _rolesFuture = widget.authService.getRoles();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.authService.createUser(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        roles: _selectedRoles.toList(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      setState(() {
        _errorMessage = widget.authService.getErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New User')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Full name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                _RolesSelector(
                  rolesFuture: _rolesFuture,
                  selectedRoles: _selectedRoles,
                  onChanged: () => setState(() {}),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Create user'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangeUserRolesPage extends StatefulWidget {
  const _ChangeUserRolesPage({required this.authService});

  final AuthService authService;

  @override
  State<_ChangeUserRolesPage> createState() => _ChangeUserRolesPageState();
}

class _ChangeUserRolesPageState extends State<_ChangeUserRolesPage> {
  late Future<_RoleEditData> _dataFuture;
  final Set<String> _selectedRoles = {};
  AppUser? _selectedUser;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_RoleEditData> _loadData() async {
    final usersFuture = widget.authService.getUsers();
    final rolesFuture = widget.authService.getRoles();

    return _RoleEditData(
      users: await usersFuture,
      roles: await rolesFuture,
    );
  }

  void _selectUser(AppUser? user) {
    setState(() {
      _selectedUser = user;
      _selectedRoles
        ..clear()
        ..addAll(user?.roles ?? []);
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final selectedUser = _selectedUser;
    if (selectedUser == null) {
      setState(() {
        _errorMessage = 'Please select a user.';
      });
      return;
    }

    if (_selectedRoles.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one role.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.authService.updateUserRoles(
        selectedUser.id,
        _selectedRoles.toList(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User roles updated')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      setState(() {
        _errorMessage = widget.authService.getErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change User Roles')),
      body: FutureBuilder<_RoleEditData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Cannot load data: ${snapshot.error}'),
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<AppUser>(
                    initialValue: _selectedUser,
                    decoration: const InputDecoration(
                      labelText: 'User',
                      prefixIcon: Icon(Icons.person_search_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: data.users
                        .map(
                          (user) => DropdownMenuItem(
                            value: user,
                            child: Text(user.email),
                          ),
                        )
                        .toList(),
                    onChanged: _selectUser,
                  ),
                  const SizedBox(height: 16),
                  _RolesSelector(
                    roles: data.roles,
                    selectedRoles: _selectedRoles,
                    onChanged: () => setState(() {}),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _submit,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Save roles'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChangePasswordPage extends StatefulWidget {
  const _ChangePasswordPage({required this.authService});

  final AuthService authService;

  @override
  State<_ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<_ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      setState(() {
        _errorMessage = widget.authService.getErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Current password is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New password',
                    prefixIcon: Icon(Icons.lock_reset),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm new password',
                    prefixIcon: Icon(Icons.verified_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value != _newPasswordController.text
                          ? 'Passwords do not match'
                          : null,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Change password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RolesSelector extends StatelessWidget {
  const _RolesSelector({
    required this.selectedRoles,
    required this.onChanged,
    this.rolesFuture,
    this.roles,
  });

  final Future<List<String>>? rolesFuture;
  final List<String>? roles;
  final Set<String> selectedRoles;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (roles != null) {
      return _RoleCheckboxes(
        roles: roles!,
        selectedRoles: selectedRoles,
        onChanged: onChanged,
      );
    }

    return FutureBuilder<List<String>>(
      future: rolesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Text('Cannot load roles: ${snapshot.error}');
        }

        return _RoleCheckboxes(
          roles: snapshot.data ?? [],
          selectedRoles: selectedRoles,
          onChanged: onChanged,
        );
      },
    );
  }
}

class _RoleCheckboxes extends StatelessWidget {
  const _RoleCheckboxes({
    required this.roles,
    required this.selectedRoles,
    required this.onChanged,
  });

  final List<String> roles;
  final Set<String> selectedRoles;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Roles',
        border: OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: roles
            .map(
              (role) => FilterChip(
                label: Text(role),
                selected: selectedRoles.contains(role),
                onSelected: (selected) {
                  if (selected) {
                    selectedRoles.add(role);
                  } else {
                    selectedRoles.remove(role);
                  }

                  onChanged();
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RoleEditData {
  const _RoleEditData({required this.users, required this.roles});

  final List<AppUser> users;
  final List<String> roles;
}

class _UserInfoPage extends StatelessWidget {
  const _UserInfoPage({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 16),
          const _UserPanel(),
        ],
      ),
    );
  }
}

class _EditProfilePage extends StatefulWidget {
  const _EditProfilePage({required this.user});

  final AppUser user;

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      _fullNameController.text.trim(),
      _emailController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Cannot update profile')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Full name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    auth.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: auth.isLoading ? null : _submit,
                  icon: auth.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(user.email),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: user.roles
                        .map((role) => Chip(label: Text(role)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserPanel extends StatelessWidget {
  const _UserPanel();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.verified_user_outlined),
            SizedBox(width: 12),
            Expanded(
              child: Text('User role: you can view your own account profile.'),
            ),
          ],
        ),
      ),
    );
  }
}
