import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../utils/app_theme.dart';

class UserManagementScreen extends StatefulWidget {
  static const String routeName = '/user-management';

  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _error;
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    // Only admins can access this screen
    if (auth.user?.role != 'admin') {
      setState(() {
        _error = 'Admin access required for user management.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // This would be a new API endpoint for user management
      final users = await adminProvider.getAllUsers(auth.user?.orgId ?? '');
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _changeUserRole(String userId, String newRole) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Role Change'),
          content: Text(
            'Are you sure you want to change this user\'s role to $newRole?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // This would be a new API endpoint
      await adminProvider.updateUserRole(userId, newRole);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role updated to $newRole'),
          backgroundColor: Colors.green,
        ),
      );

      _loadUsers(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update role: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_selectedRole == 'all') return _users;
    return _users.where((user) => user['role'] == _selectedRole).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Only admins can access this screen
    if (auth.user?.role != 'admin') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Admin Access Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Only administrators can manage user roles.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      body: Column(
        children: [
          // Header with filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'System Administration',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Role filter
                Row(
                  children: [
                    const Text('Filter by role: '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Roles'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admins'),
                          ),
                          DropdownMenuItem(
                            value: 'teacher',
                            child: Text('Teachers'),
                          ),
                          DropdownMenuItem(
                            value: 'student',
                            child: Text('Students'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUsers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _filteredUsers.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text('No users found', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserCard(user);
                    },
                  ),
          ),

          // Summary footer
          if (_users.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Total Users',
                    _users.length.toString(),
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    'Admins',
                    _users.where((u) => u['role'] == 'admin').length.toString(),
                    Colors.red,
                  ),
                  _buildSummaryItem(
                    'Teachers',
                    _users
                        .where((u) => u['role'] == 'teacher')
                        .length
                        .toString(),
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    'Students',
                    _users
                        .where((u) => u['role'] == 'student')
                        .length
                        .toString(),
                    Colors.orange,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = user['role'] ?? 'unknown';
    final name = user['name'] ?? 'Unknown User';
    final email = user['email'] ?? 'No email';
    final userId = user['id']?.toString() ?? '';

    Color roleColor;
    IconData roleIcon;

    switch (role) {
      case 'admin':
        roleColor = Colors.red;
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'teacher':
        roleColor = Colors.green;
        roleIcon = Icons.school;
        break;
      case 'student':
        roleColor = Colors.orange;
        roleIcon = Icons.person;
        break;
      default:
        roleColor = Colors.grey;
        roleIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.1),
          child: Icon(roleIcon, color: roleColor),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role.toUpperCase(),
                style: TextStyle(
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (newRole) => _changeUserRole(userId, newRole),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'student',
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Make Student'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'teacher',
              child: Row(
                children: [
                  Icon(Icons.school, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Make Teacher'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'admin',
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Make Admin'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
