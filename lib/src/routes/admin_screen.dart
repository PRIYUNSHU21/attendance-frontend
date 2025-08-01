import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../models/organization.dart';
class AdminScreen extends StatefulWidget {
  static const String routeName = '/admin';
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}
class _AdminScreenState extends State<AdminScreen> {
  bool _showOnlyMyOrganization = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final admin = Provider.of<AdminProvider>(context, listen: false);
      // Load user from storage first
      auth.loadUserFromStorage().then((_) {
        // Then fetch data
        admin.fetchUsers();
        admin.fetchOrganizations();
        admin.fetchSessions();
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = auth.user?.role == 'admin';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: admin.loading
          ? const Center(child: CircularProgressIndicator())
          : !isAdmin
          ? _buildAccessDeniedMessage()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Users Section
                  _buildUsersSection(admin),
                  const SizedBox(height: 24),
                  // Organizations Section
                  _buildOrganizationsSection(auth, admin),
                  const SizedBox(height: 24),
                  // Sessions Section
                  _buildSessionsSection(admin),
                ],
              ),
            ),
    );
  }
  Widget _buildUsersSection(AdminProvider admin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Users', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => admin.fetchUsers(),
            ),
          ],
        ),
        ...admin.users.map(
          (u) => Card(
            child: ListTile(
              title: Text(u.name),
              subtitle: Text('Email: ${u.email}\nRole: ${u.role}'),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildOrganizationsSection(AuthProvider auth, AdminProvider admin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Organizations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => admin.fetchOrganizations(),
                  tooltip: 'Refresh organizations',
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateOrganizationDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Filter toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Show only my organization',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _showOnlyMyOrganization,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyMyOrganization = value;
                      });
                    },
                    activeColor: Colors.blue.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildOrganizationList(auth, admin),
      ],
    );
  }
  Widget _buildOrganizationList(AuthProvider auth, AdminProvider admin) {
    final currentUser = auth.user;
    final userOrgId = currentUser?.orgId.trim();
    final allOrgs = admin.organizations;
    // Apply filter if toggle is on
    List<Organization> orgsToShow = allOrgs;
    if (_showOnlyMyOrganization) {
      orgsToShow = allOrgs
          .where(
            (org) =>
                userOrgId != null &&
                userOrgId.isNotEmpty &&
                org.orgId.trim() == userOrgId,
          )
          .toList();
    }
    // Separate admin's organization from others
    final adminOrgs = orgsToShow
        .where(
          (org) =>
              userOrgId != null &&
              userOrgId.isNotEmpty &&
              org.orgId.trim() == userOrgId,
        )
        .toList();
    final otherOrgs = orgsToShow
        .where(
          (org) =>
              userOrgId == null ||
              userOrgId.isEmpty ||
              org.orgId.trim() != userOrgId,
        )
        .toList();
    // Sort other organizations alphabetically
    otherOrgs.sort((a, b) => a.name.compareTo(b.name));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Admin's Organization Section
        if (adminOrgs.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                Text(
                  'MY ORGANIZATION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ADMIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...adminOrgs.map((org) => _buildOrganizationCard(org, true)),
          if (!_showOnlyMyOrganization) ...[
            const SizedBox(height: 24),
            Divider(thickness: 2, color: Colors.grey.shade300),
            const SizedBox(height: 16),
          ],
        ],
        // Other Organizations Section
        if (otherOrgs.isNotEmpty && !_showOnlyMyOrganization) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.business, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  'OTHER ORGANIZATIONS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${otherOrgs.length} organization${otherOrgs.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ...otherOrgs.map((org) => _buildOrganizationCard(org, false)),
        ],
        // Empty state
        if (allOrgs.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.business_center_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No organizations found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first organization to get started',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ] else if (_showOnlyMyOrganization && adminOrgs.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.orange.shade400),
                const SizedBox(height: 16),
                Text(
                  'Your organization not found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userOrgId == null || userOrgId.isEmpty
                      ? 'You don\'t have an organization assigned to your account'
                      : 'Turn off the filter to see all organizations or contact support',
                  style: TextStyle(fontSize: 14, color: Colors.orange.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
        // Fix for admin without matching organization
        if (adminOrgs.isEmpty &&
            !_showOnlyMyOrganization &&
            userOrgId != null &&
            userOrgId.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Organization Not Found',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your account is assigned to organization ID "$userOrgId", but this organization doesn\'t exist in the system.',
                  style: TextStyle(fontSize: 14, color: Colors.amber.shade700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showSelectOrganizationDialog(context),
                      icon: const Icon(Icons.link, size: 16),
                      label: const Text('Link to Existing Organization'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showCreateOrganizationDialog(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Create New Organization'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  Widget _buildOrganizationCard(Organization org, bool isAdminOrg) {
    return Card(
      elevation: isAdminOrg ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isAdminOrg ? Colors.blue.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isAdminOrg
            ? BorderSide(color: Colors.blue.shade700, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            if (isAdminOrg) ...[
              Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                org.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isAdminOrg ? FontWeight.bold : FontWeight.w500,
                  color: isAdminOrg ? Colors.blue.shade800 : null,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAdminOrg ? Colors.blue.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ID: ${org.orgId}',
                style: TextStyle(
                  fontSize: 11,
                  color: isAdminOrg
                      ? Colors.blue.shade700
                      : Colors.grey.shade600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            if (org.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(org.description, style: const TextStyle(fontSize: 14)),
            ],
            if (org.contactEmail != null && org.contactEmail!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    org.contactEmail!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditOrganizationDialog(context, org),
              tooltip: 'Edit Organization',
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteOrganizationDialog(context, org),
              tooltip: isAdminOrg
                  ? 'Delete My Organization'
                  : 'Delete Organization',
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSessionsSection(AdminProvider admin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sessions', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => admin.fetchSessions(),
            ),
          ],
        ),
        ...admin.sessions.map(
          (s) => Card(
            child: ListTile(
              title: Text(s.sessionName),
              subtitle: Text(
                'ID: ${s.sessionId}\nStart: ${s.startTime}\nEnd: ${s.endTime}',
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildAccessDeniedMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            const Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You do not have admin privileges to access this section. '
              'Only users with admin role can manage organizations, users, and sessions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showCreateOrganizationDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final contactEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Organization'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Organization Name',
                  hintText: 'Enter organization name',
                ),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'Name is required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter organization description',
                ),
                minLines: 3,
                maxLines: 5,
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'Description is required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contactEmailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  hintText: 'contact@organization.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<AdminProvider>(
            builder: (context, admin, child) => ElevatedButton(
              onPressed: admin.loading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final result = await admin.createOrganization(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        contactEmail: contactEmailController.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        _showSnackBar(
                          result
                              ? 'Organization created successfully'
                              : 'Failed to create organization: ${admin.error}',
                          isError: !result,
                        );
                      }
                    },
              child: admin.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create'),
            ),
          ),
        ],
      ),
    );
  }
  void _showEditOrganizationDialog(
    BuildContext context,
    Organization organization,
  ) {
    final nameController = TextEditingController(text: organization.name);
    final descriptionController = TextEditingController(
      text: organization.description,
    );
    final contactEmailController = TextEditingController(
      text: organization.contactEmail,
    );
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Organization'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Organization Name',
                ),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'Name is required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contactEmailController,
                decoration: const InputDecoration(labelText: 'Contact Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final admin = Provider.of<AdminProvider>(context, listen: false);
              final result = await admin.updateOrganization(
                organization.orgId,
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                _showSnackBar(
                  result
                      ? 'Organization updated successfully'
                      : 'Failed to update organization: ${admin.error}',
                  isError: !result,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
  void _showDeleteOrganizationDialog(
    BuildContext context,
    Organization organization,
  ) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isMyOrganization = auth.user?.orgId == organization.orgId;
    showDialog(
      context: context,
      builder: (context) => _DeleteOrganizationDialog(
        organization: organization,
        isMyOrganization: isMyOrganization,
        onDeleted: () {
          // If user deleted their own organization, logout immediately
          if (isMyOrganization) {
            _showSnackBar(
              'You have been logged out because your organization was deleted',
              isError: true,
            );
            // Auto-logout will be handled by session invalidation
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            });
          }
        },
      ),
    );
  }
  void _showSelectOrganizationDialog(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.link, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Link to Organization'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select an organization to link your admin account to:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: admin.organizations.length,
                itemBuilder: (context, index) {
                  final org = admin.organizations[index];
                  return ListTile(
                    leading: Icon(Icons.business, color: Colors.blue),
                    title: Text(org.name),
                    subtitle: Text('ID: ${org.orgId}'),
                    trailing: ElevatedButton(
                      onPressed: () => _linkToOrganization(context, org.orgId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Link'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  Future<void> _linkToOrganization(BuildContext context, String orgId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // This would normally be an API call to update the user's orgId
    // For now, we'll show a message that this needs backend implementation
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Backend Update Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To link your account to organization "$orgId", you need to:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backend SQL Update:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UPDATE users SET org_id = \'$orgId\' WHERE user_id = \'${auth.user?.userId}\';',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Or implement an API endpoint to update user organization.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
/// Two-phase organization deletion dialog following the backend security guide
class _DeleteOrganizationDialog extends StatefulWidget {
  final Organization organization;
  final bool isMyOrganization;
  final VoidCallback onDeleted;
  const _DeleteOrganizationDialog({
    required this.organization,
    required this.isMyOrganization,
    required this.onDeleted,
  });
  @override
  State<_DeleteOrganizationDialog> createState() =>
      _DeleteOrganizationDialogState();
}
class _DeleteOrganizationDialogState extends State<_DeleteOrganizationDialog> {
  bool _isLoading = false;
  Map<String, dynamic>? _deletePreview;
  bool _showConfirmation = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          Text(_showConfirmation ? 'Confirm Deletion' : 'Delete Organization'),
        ],
      ),
      content: _isLoading
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading deletion preview...'),
              ],
            )
          : _showConfirmation
          ? _buildConfirmationContent()
          : _buildInitialContent(),
      actions: _isLoading
          ? []
          : _showConfirmation
          ? _buildConfirmationActions()
          : _buildInitialActions(),
    );
  }
  Widget _buildInitialContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This will show you what will be deleted before proceeding.'),
        const SizedBox(height: 16),
        Text(
          'Organization: ${widget.organization.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (widget.isMyOrganization) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Important Warning',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is YOUR organization. Deleting it will automatically log you out and you will lose access to the system.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.info, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'You can also use "Soft Delete" to deactivate the organization while preserving data.',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildConfirmationContent() {
    final preview = _deletePreview?['deletion_preview'] ?? {};
    final org = _deletePreview?['organization'] ?? {};
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organization: ${org['name'] ?? widget.organization.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'This will permanently delete:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        _buildDeletionItem(
          Icons.people,
          '${preview['users_to_delete'] ?? 0} users',
        ),
        _buildDeletionItem(
          Icons.event,
          '${preview['sessions_to_delete'] ?? 0} attendance sessions',
        ),
        _buildDeletionItem(
          Icons.assignment,
          '${preview['attendance_records_to_delete'] ?? 0} attendance records',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '⚠️ This action cannot be undone!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildDeletionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Text('• $text'),
        ],
      ),
    );
  }
  List<Widget> _buildInitialActions() {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: _softDeleteOrganization,
        child: const Text(
          'Soft Delete',
          style: TextStyle(color: Colors.orange),
        ),
      ),
      ElevatedButton(
        onPressed: _getDeletePreview,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: const Text('Preview Deletion'),
      ),
    ];
  }
  List<Widget> _buildConfirmationActions() {
    return [
      TextButton(
        onPressed: () => setState(() => _showConfirmation = false),
        child: const Text('Back'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _confirmDeletion,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: const Text('✅ Yes, Delete Everything'),
      ),
    ];
  }
  Future<void> _getDeletePreview() async {
    setState(() => _isLoading = true);
    final admin = Provider.of<AdminProvider>(context, listen: false);
    final preview = await admin.getDeletePreview(widget.organization.orgId);
    setState(() {
      _isLoading = false;
      if (preview != null) {
        _deletePreview = preview;
        _showConfirmation = true;
      } else {
        // Show error
        _showError('Failed to get deletion preview: ${admin.error}');
      }
    });
  }
  Future<void> _confirmDeletion() async {
    setState(() => _isLoading = true);
    final admin = Provider.of<AdminProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await admin.deleteOrganization(widget.organization.orgId);
    setState(() => _isLoading = false);
    if (context.mounted) {
      Navigator.pop(context);
      if (result != null) {
        _showSuccess(
          'Organization deleted successfully!\n'
          '• ${result['users']} users deleted\n'
          '• ${result['attendance_sessions']} sessions deleted\n'
          '• ${result['attendance_records']} records deleted\n'
          '• ${result['invalidated_sessions']} user sessions invalidated',
        );
        widget.onDeleted();
        // Check if session was invalidated
        if (auth.handleApiResponse({'session_invalidated': true})) {
          _showError(
            'Your session has been invalidated. Redirecting to login...',
          );
        }
      } else {
        _showError('Failed to delete organization: ${admin.error}');
      }
    }
  }
  Future<void> _softDeleteOrganization() async {
    setState(() => _isLoading = true);
    final admin = Provider.of<AdminProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await admin.softDeleteOrganization(
      widget.organization.orgId,
    );
    setState(() => _isLoading = false);
    if (context.mounted) {
      Navigator.pop(context);
      if (result != null) {
        _showSuccess(
          'Organization deactivated successfully!\n'
          'Data has been preserved and can be reactivated later.\n'
          '• ${result['invalidated_sessions'] ?? 0} user sessions invalidated',
        );
        widget.onDeleted();
        // Check if session was invalidated
        if (auth.handleApiResponse({'session_invalidated': true})) {
          _showError(
            'Your session has been invalidated. Redirecting to login...',
          );
        }
      } else {
        _showError('Failed to deactivate organization: ${admin.error}');
      }
    }
  }
  void _showSuccess(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
