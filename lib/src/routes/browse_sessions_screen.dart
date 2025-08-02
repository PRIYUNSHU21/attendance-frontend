import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/session.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';

class BrowseSessionsScreen extends StatefulWidget {
  static const String routeName = '/browse-sessions';
  const BrowseSessionsScreen({super.key});

  @override
  State<BrowseSessionsScreen> createState() => _BrowseSessionsScreenState();
}

class _BrowseSessionsScreenState extends State<BrowseSessionsScreen> {
  List<Session> _sessions = [];
  bool _loading = true;
  String? _error;
  String? _selectedOrgFilter;
  Set<String> _availableOrgs = {};

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getPublic(
        '/attendance/public-sessions',
      );

      if (response['success'] == true) {
        final sessionsData = response['data'] as List;
        final sessions = sessionsData.map((e) => Session.fromJson(e)).toList();

        // Extract unique organizations
        final orgs = sessions
            .where((s) => s.orgId != null)
            .map((s) => s.orgId!)
            .toSet();

        setState(() {
          _sessions = sessions.where((s) => s.isActive).toList();
          _availableOrgs = orgs;
          _loading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load sessions';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading sessions: $e';
        _loading = false;
      });
    }
  }

  List<Session> get _filteredSessions {
    if (_selectedOrgFilter == null) return _sessions;
    return _sessions.where((s) => s.orgId == _selectedOrgFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Available Sessions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
            icon: const Icon(Icons.login),
            tooltip: 'Login to Mark Attendance',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse Available Sessions',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'View all active attendance sessions. Login to mark your attendance.',
                  style: TextStyle(color: AppTheme.textMedium, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms),

          // Organization Filter
          if (_availableOrgs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Filter by Organization:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String?>(
                      value: _selectedOrgFilter,
                      hint: const Text('All Organizations'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Organizations'),
                        ),
                        ..._availableOrgs.map(
                          (org) => DropdownMenuItem<String>(
                            value: org,
                            child: Text('Organization: $org'),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedOrgFilter = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ).animate().slideX(duration: 400.ms, delay: 200.ms),

          const SizedBox(height: 16),

          // Sessions List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Sessions',
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadSessions,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _filteredSessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: AppTheme.textMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Sessions',
                          style: TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedOrgFilter != null
                              ? 'No sessions available for the selected organization'
                              : 'No sessions are currently active',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadSessions,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadSessions,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredSessions.length,
                      itemBuilder: (context, index) {
                        final session = _filteredSessions[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.event,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          session.sessionName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (session.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            session.description,
                                            style: TextStyle(
                                              color: AppTheme.textMedium,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.successColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        color: AppTheme.successColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: AppTheme.textMedium,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${session.startTime} - ${session.endTime}',
                                    style: TextStyle(
                                      color: AppTheme.textMedium,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (session.orgId != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.business,
                                      size: 16,
                                      color: AppTheme.textMedium,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Organization: ${session.orgId}',
                                      style: TextStyle(
                                        color: AppTheme.textMedium,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        LoginScreen.routeName,
                                      );
                                    },
                                    icon: const Icon(Icons.login, size: 16),
                                    label: const Text('Login to Join'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryColor,
                                      side: BorderSide(
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().slideY(
                          duration: 400.ms,
                          delay: (index * 100).ms,
                          begin: 0.3,
                          end: 0,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
