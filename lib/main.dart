import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ukgrkpslqgggnuvfqzbb.supabase.co',
    publishableKey: 'sb_publishable_AxBmE12nVkp02XFZqkiRuw_KsQTnh9D',
  );

  runApp(const MyTrendingWebApp());
}

final supabase = Supabase.instance.client;

class FormValidators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? minLength(String? value, String fieldName, int minimumLength) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < minimumLength) {
      return '$fieldName must be at least $minimumLength characters';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final email = value.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (supabase.auth.currentSession != null) {
        Navigator.of(context).pushReplacementNamed('/admin/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/admin/dashboard');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Unable to sign in. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/New_Logo.png',
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.account_balance,
                            size: 70,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Admin Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to manage the Ardaita website.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 28),
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Back to website'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  Future<void> _checkSession() async {
    if (supabase.auth.currentSession == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/admin');
      }
      return;
    }
    if (mounted) setState(() => _checkingSession = false);
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/admin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ardaita Admin'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                user?.email ?? '',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width >= 900 ? 3 : 1,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.5,
              children: [
                _AdminCard(
                  icon: Icons.mail_outline,
                  title: 'Contact Messages',
                  subtitle: 'View and manage contact submissions.',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminContactMessagesPage(),
                    ),
                  ),
                ),
                _AdminCard(
                  icon: Icons.volunteer_activism_outlined,
                  title: 'Volunteer Applications',
                  subtitle: 'View and manage volunteer applications.',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminVolunteerApplicationsPage(),
                    ),
                  ),
                ),
                _AdminCard(
                  icon: Icons.folder_outlined,
                  title: 'Documents & Gallery',
                  subtitle: 'Manage uploaded files and images.',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminMediaPage()),
                  ),
                ),
                _AdminCard(
                  icon: Icons.edit_note_outlined,
                  title: 'Website Content',
                  subtitle: 'Manage editable website content.',
                  onTap: () => _showComingSoon(context, 'Website Content'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$feature is the next admin module we will connect.'),
    ),
  );
}

class _AdminCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<_AdminCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Card(
          elevation: _hovered ? 6 : 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: widget.onTap,
            hoverColor: const Color(0x142E7D32),
            splashColor: const Color(0x242E7D32),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(widget.icon, size: 34, color: const Color(0xFF2E7D32)),
                  const SizedBox(height: 14),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'Open',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: Color(0xFF2E7D32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminContactMessagesPage extends StatefulWidget {
  const AdminContactMessagesPage({super.key});

  @override
  State<AdminContactMessagesPage> createState() =>
      _AdminContactMessagesPageState();
}

class _AdminContactMessagesPageState extends State<AdminContactMessagesPage> {
  late Future<List<Map<String, dynamic>>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _messagesFuture = _loadMessages();
  }

  Future<List<Map<String, dynamic>>> _loadMessages() async {
    final response = await supabase
        .from('contact_messages')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Messages')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _messagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load messages: ${snapshot.error}'),
            );
          }
          final messages = snapshot.data ?? [];
          if (messages.isEmpty) {
            return const Center(child: Text('No contact messages yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: messages.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final m = messages[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.mail_outline)),
                  title: Text('${m['full_name'] ?? 'Unknown'}'),
                  subtitle: Text('${m['email'] ?? ''}\n${m['message'] ?? ''}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminVolunteerApplicationsPage extends StatefulWidget {
  const AdminVolunteerApplicationsPage({super.key});

  @override
  State<AdminVolunteerApplicationsPage> createState() =>
      _AdminVolunteerApplicationsPageState();
}

class _AdminVolunteerApplicationsPageState
    extends State<AdminVolunteerApplicationsPage> {
  late Future<List<Map<String, dynamic>>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _applicationsFuture = _loadApplications();
  }

  Future<List<Map<String, dynamic>>> _loadApplications() async {
    final response = await supabase
        .from('volunteer_applications')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Volunteer Applications')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load applications: ${snapshot.error}'),
            );
          }
          final applications = snapshot.data ?? [];
          if (applications.isEmpty) {
            return const Center(child: Text('No volunteer applications yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: applications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final a = applications[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.volunteer_activism_outlined),
                  ),
                  title: Text('${a['full_name'] ?? a['name'] ?? 'Unknown'}'),
                  subtitle: Text(
                    '${a['email'] ?? ''}\n${a['initiative'] ?? ''}\n${a['motivation'] ?? ''}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminMediaPage extends StatefulWidget {
  const AdminMediaPage({super.key});

  @override
  State<AdminMediaPage> createState() => _AdminMediaPageState();
}

class _AdminMediaPageState extends State<AdminMediaPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _loading = true;
  bool _uploading = false;
  String? _error;
  List<FileObject> _gallery = [];
  List<FileObject> _documents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final gallery = await supabase.storage
          .from('gallery')
          .list(
            path: '',
            searchOptions: const SearchOptions(
              sortBy: SortBy(column: 'name', order: 'asc'),
            ),
          );
      final documents = await supabase.storage
          .from('documents')
          .list(
            path: '',
            searchOptions: const SearchOptions(
              sortBy: SortBy(column: 'name', order: 'asc'),
            ),
          );

      if (!mounted) return;
      setState(() {
        _gallery = gallery.where(_isFile).toList();
        _documents = documents.where(_isFile).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _formatError(e);
      });
    }
  }

  bool _isFile(FileObject file) => file.metadata != null;

  Future<void> _pickAndUpload({required String bucket}) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: bucket == 'gallery'
          ? ['jpg', 'jpeg', 'png', 'webp', 'gif']
          : ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
    );

    if (files.isEmpty) return;

    final file = files.first;
    if (!mounted) return;
    setState(() => _uploading = true);

    try {
      final bytes = await file.readAsBytes();
      final safeName = file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final storagePath = '${DateTime.now().millisecondsSinceEpoch}_$safeName';

      await supabase.storage
          .from(bucket)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: _contentType(file.name),
              upsert: false,
            ),
          );

      await _loadFiles();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${file.name} uploaded successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${_formatError(e)}')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteFile(String bucket, String fileName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete file?'),
        content: Text('This will permanently delete "$fileName".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await supabase.storage.from(bucket).remove([fileName]);
      await _loadFiles();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: ${_formatError(e)}')),
      );
    }
  }

  String _contentType(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    const types = <String, String>{
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'gif': 'image/gif',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
    };
    return types[ext] ?? 'application/octet-stream';
  }

  String _formatError(Object error) =>
      error.toString().replaceFirst('StorageException: ', '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents & Gallery'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.photo_library_outlined), text: 'Gallery'),
            Tab(icon: Icon(Icons.description_outlined), text: 'Documents'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _errorView()
          : TabBarView(
              controller: _tabController,
              children: [_galleryView(), _documentsView()],
            ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Unable to load Storage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFiles,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar({required bool gallery}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              gallery
                  ? 'Upload and manage public gallery images.'
                  : 'Upload and manage public website documents.',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          FilledButton.icon(
            onPressed: _uploading
                ? null
                : () =>
                      _pickAndUpload(bucket: gallery ? 'gallery' : 'documents'),
            icon: _uploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    gallery
                        ? Icons.add_photo_alternate_outlined
                        : Icons.upload_file_outlined,
                  ),
            label: Text(
              _uploading
                  ? 'Uploading...'
                  : gallery
                  ? 'Upload Image'
                  : 'Upload Document',
            ),
          ),
        ],
      ),
    );
  }

  Widget _galleryView() {
    return Column(
      children: [
        _toolbar(gallery: true),
        Expanded(
          child: _gallery.isEmpty
              ? const Center(child: Text('No gallery images uploaded yet.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: _gallery.length,
                  itemBuilder: (context, index) {
                    final file = _gallery[index];
                    final url = supabase.storage
                        .from('gallery')
                        .getPublicUrl(file.name);
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 42,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Text(
                                    file.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                onPressed: () =>
                                    _deleteFile('gallery', file.name),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _documentsView() {
    return Column(
      children: [
        _toolbar(gallery: false),
        Expanded(
          child: _documents.isEmpty
              ? const Center(child: Text('No documents uploaded yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: _documents.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final file = _documents[index];
                    final extension = file.name.contains('.')
                        ? file.name.split('.').last.toUpperCase()
                        : 'FILE';
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.description_outlined),
                        ),
                        title: Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('$extension document'),
                        trailing: IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _deleteFile('documents', file.name),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class MyTrendingWebApp extends StatelessWidget {
  const MyTrendingWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ardaita and its Surrounding Charittable Association',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: const Color(0xFF2E7D32), // Dark Green
          surface: const Color(0xFFFFFFF0), // Ivory White
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFF0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 48,
          ),
          displayMedium: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(fontSize: 18, height: 1.6),
        ),
      ),
      home: const MainLayout(),
      routes: {
        '/admin': (_) => const AdminLoginPage(),
        '/admin/dashboard': (_) => const AdminDashboardPage(),
      },
    );
  }
}

// class _LogoSplashScreen extends StatelessWidget {
//   const _LogoSplashScreen();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFFF0),
//       body: Center(
//         child: Image.asset(
//           'assets/New_Logo.png',
//           width: 110,
//           height: 110,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => const Icon(
//             Icons.account_balance,
//             size: 80,
//             color: Color(0xFF2E7D32),
//           ),
//         ),
//       ),
//     );
//   }
// }

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  int? _aboutUsSubTab;
  int? _resourcesSubTab;
  int? _volunteerSubTab;

  late final StreamSubscription<html.PopStateEvent> _popStateSubscription;

  @override
  void initState() {
    super.initState();

    // Restore the page represented by the current browser URL.
    _applyPath(html.window.location.pathname ?? '/', addHistory: false);

    // Keep Flutter's content in sync with browser Back/Forward.
    _popStateSubscription = html.window.onPopState.listen((_) {
      if (mounted) {
        _applyPath(html.window.location.pathname ?? '/', addHistory: false);
      }
    });
  }

  @override
  void dispose() {
    _popStateSubscription.cancel();
    super.dispose();
  }

  List<Widget> get _pages => [
    HomePage(
      onNavigate: (index, [subTab]) {
        _navigate(index, subTab);
      },
    ),
    AboutUsPage(initialSubTab: _aboutUsSubTab),
    ResourcesWrapper(initialSubTab: _resourcesSubTab),
    VolunteerWrapper(initialSubTab: _volunteerSubTab),
    const ContactUsPage(),
    const DonatePage(),
  ];

  String _pathFor(int index, [int? subTab]) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        switch (subTab) {
          case 0:
            return '/about/who-we-are';
          case 1:
            return '/about/what-we-do';
          case 2:
            return '/about/initiatives';
          default:
            return '/about/who-we-are';
        }
      case 2:
        switch (subTab) {
          case 0:
            return '/resources/documents';
          case 1:
            return '/resources/gallery';
          default:
            return '/resources/documents';
        }
      case 3:
        return '/volunteer/become-a-volunteer';
      case 4:
        return '/contact';
      case 5:
        return '/donate';
      default:
        return '/';
    }
  }

  void _navigate(int index, [int? subTab]) {
    _setPage(index, subTab);

    final path = _pathFor(index, subTab);
    final currentPath = html.window.location.pathname ?? '/';

    if (currentPath != path) {
      html.window.history.pushState(null, '', path);
    }
  }

  void _setPage(int index, [int? subTab]) {
    setState(() {
      _selectedIndex = index;

      if (index == 1) {
        _aboutUsSubTab = subTab ?? _aboutUsSubTab ?? 0;
      } else if (index == 2) {
        _resourcesSubTab = subTab ?? _resourcesSubTab ?? 0;
      } else if (index == 3) {
        _volunteerSubTab = subTab ?? _volunteerSubTab ?? 0;
      }
    });
  }

  void _applyPath(String path, {required bool addHistory}) {
    final normalized = path.replaceFirst(RegExp(r'/$'), '');
    int index = 0;
    int? subTab;

    switch (normalized) {
      case '':
      case '/':
        index = 0;
        break;

      case '/about':
      case '/about/who-we-are':
        index = 1;
        subTab = 0;
        break;

      case '/about/what-we-do':
        index = 1;
        subTab = 1;
        break;

      case '/about/initiatives':
        index = 1;
        subTab = 2;
        break;

      case '/resources':
      case '/resources/documents':
        index = 2;
        subTab = 0;
        break;

      case '/resources/gallery':
        index = 2;
        subTab = 1;
        break;

      case '/volunteer':
      case '/volunteer/become-a-volunteer':
        index = 3;
        subTab = 0;
        break;

      case '/contact':
        index = 4;
        break;

      case '/donate':
        index = 5;
        break;

      default:
        index = 0;
    }

    _setPage(index, subTab);

    if (addHistory) {
      final target = _pathFor(index, subTab);
      html.window.history.pushState(null, '', target);
    }
  }

  Widget _buildTopMenuItem(int index, String label) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: TextButton(
          onPressed: () => _navigate(index),
          style: TextButton.styleFrom(
            foregroundColor: isSelected ? Colors.white : Colors.green.shade100,
            backgroundColor: isSelected
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            overlayColor: Colors.white.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutUsMenu() {
    return _HoverDropdownMenu(
      label: 'About Us',
      isSelected: _selectedIndex == 1,
      items: const [
        _HoverMenuItem(value: 0, label: 'Who We Are'),
        _HoverMenuItem(value: 1, label: 'What We Do'),
        _HoverMenuItem(value: 2, label: 'Initiatives'),
      ],
      onSelected: (value) => _navigate(1, value),
    );
  }

  Widget _buildResourcesMenu() {
    return _HoverDropdownMenu(
      label: 'Resources',
      isSelected: _selectedIndex == 2,
      items: const [
        _HoverMenuItem(value: 0, label: 'Documents'),
        _HoverMenuItem(value: 1, label: 'Gallery'),
      ],
      onSelected: (value) => _navigate(2, value),
    );
  }

  Widget _buildVolunteerMenu() {
    return _HoverDropdownMenu(
      label: 'Volunteer',
      isSelected: _selectedIndex == 3,
      items: const [_HoverMenuItem(value: 0, label: 'Become a Volunteer')],
      onSelected: (value) => _navigate(3, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: 50,
          height: 50,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Image.asset('assets/New_Logo.png', fit: BoxFit.cover),
        ),
        actions: [
          _buildTopMenuItem(0, 'Home'),
          _buildAboutUsMenu(),
          _buildResourcesMenu(),
          _buildVolunteerMenu(),
          _buildTopMenuItem(4, 'Contact Us'),
          _buildTopMenuItem(5, 'Donate'),
          const SizedBox(width: 20),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey(
            '${_selectedIndex}_${_aboutUsSubTab}_${_resourcesSubTab}_$_volunteerSubTab',
          ),
          child: _pages[_selectedIndex],
        ),
      ),
    );
  }
}

class _HoverMenuItem {
  final int value;
  final String label;

  const _HoverMenuItem({required this.value, required this.label});
}

class _HoverDropdownMenu extends StatefulWidget {
  final String label;
  final bool isSelected;
  final List<_HoverMenuItem> items;
  final ValueChanged<int> onSelected;

  const _HoverDropdownMenu({
    required this.label,
    required this.isSelected,
    required this.items,
    required this.onSelected,
  });

  @override
  State<_HoverDropdownMenu> createState() => _HoverDropdownMenuState();
}

class _HoverDropdownMenuState extends State<_HoverDropdownMenu> {
  static const double _menuWidth = 190;
  static const double _menuGap = 4;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;

  bool _parentHovered = false;
  bool _menuHovered = false;

  bool get _isOpen => _overlayEntry != null;

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _scheduleHide() {
    _cancelHideTimer();

    _hideTimer = Timer(const Duration(milliseconds: 120), () {
      if (!_parentHovered && !_menuHovered) {
        _removeMenu();
      }
    });
  }

  void _showMenu() {
    _cancelHideTimer();

    if (_overlayEntry != null) {
      if (mounted) setState(() {});
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 44 + _menuGap),
          child: Align(
            alignment: Alignment.topLeft,
            child: MouseRegion(
              onEnter: (_) {
                _menuHovered = true;
                _cancelHideTimer();
              },
              onExit: (_) {
                _menuHovered = false;
                _scheduleHide();
              },
              child: Material(
                type: MaterialType.transparency,
                child: SizedBox(
                  width: _menuWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E2E2)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: widget.items.map((item) {
                          return _HoverDropdownItem(
                            label: item.label,
                            onTap: () {
                              widget.onSelected(item.value);
                              _removeMenu();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    if (mounted) setState(() {});
  }

  void _removeMenu() {
    _cancelHideTimer();
    _parentHovered = false;
    _menuHovered = false;

    final entry = _overlayEntry;
    _overlayEntry = null;

    if (entry != null) {
      entry.remove();
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cancelHideTimer();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected || _parentHovered || _isOpen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            _parentHovered = true;
            _showMenu();
          },
          onExit: (_) {
            _parentHovered = false;
            _scheduleHide();
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_isOpen) {
                _removeMenu();
              } else {
                _parentHovered = true;
                _showMenu();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.green.shade100,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 3),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 120),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: active ? Colors.white : Colors.green.shade100,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverDropdownItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _HoverDropdownItem({required this.label, required this.onTap});

  @override
  State<_HoverDropdownItem> createState() => _HoverDropdownItemState();
}

class _HoverDropdownItemState extends State<_HoverDropdownItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? Colors.green.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
              fontWeight: _hovered ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class ResourcesWrapper extends StatefulWidget {
  final int? initialSubTab;
  const ResourcesWrapper({super.key, this.initialSubTab});

  @override
  State<ResourcesWrapper> createState() => _ResourcesWrapperState();
}

class _ResourcesWrapperState extends State<ResourcesWrapper> {
  int? selectedSubTab;

  @override
  void initState() {
    super.initState();
    selectedSubTab = widget.initialSubTab;
  }

  @override
  void didUpdateWidget(ResourcesWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSubTab != oldWidget.initialSubTab) {
      selectedSubTab = widget.initialSubTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/Home_page.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: selectedSubTab == null
                  ? const Center(
                      child: Text(
                        'Select a resource section to view details',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.93),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: selectedSubTab == 0
                            ? const ResourcesPage()
                            : const GalleryPage(),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class VolunteerWrapper extends StatefulWidget {
  final int? initialSubTab;
  const VolunteerWrapper({super.key, this.initialSubTab});

  @override
  State<VolunteerWrapper> createState() => _VolunteerWrapperState();
}

class _VolunteerWrapperState extends State<VolunteerWrapper> {
  int? selectedSubTab;

  @override
  void initState() {
    super.initState();
    selectedSubTab = widget.initialSubTab;
  }

  @override
  void didUpdateWidget(VolunteerWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSubTab != oldWidget.initialSubTab) {
      selectedSubTab = widget.initialSubTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/Home_Page.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: selectedSubTab == null
                  ? const Center(
                      child: Text(
                        'Select a section to start volunteering',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.93),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: BecomeVolunteerPage(),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  final Function(int, [int?]) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          Stack(
            children: [
              SizedBox(
                height: 520,
                width: double.infinity,
                child: Image.asset(
                  'assets/Home_page.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.72),
                        Colors.black.withValues(alpha: 0.24),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.45, 1.0],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        const Text(
                          'Empowering Ardaita Together',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Unity, Development, and Sustainable Growth for our Community',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 40),
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () => onNavigate(
                                1,
                                2,
                              ), // Initiatives under About Us
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 20,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Explore Initiatives'),
                            ),
                            OutlinedButton(
                              onPressed: () =>
                                  onNavigate(3, 0), // Become a Volunteer
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 20,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Become a Volunteer'),
                            ),
                            OutlinedButton(
                              onPressed: () => onNavigate(5), // Donate
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 20,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Support Ardaita'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Features/Stats Summary
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
            child: Wrap(
              spacing: 40,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: [
                _buildStatItem(
                  context,
                  Icons.people,
                  '1000+',
                  'Lives Impacted',
                ),
                _buildStatItem(
                  context,
                  Icons.school,
                  '20+',
                  'Education Programs',
                ),
                _buildStatItem(context, Icons.eco, '100+', 'Green Initiatives'),
                _buildStatItem(
                  context,
                  Icons.trending_up,
                  '24/7',
                  'Community Support',
                ),
              ],
            ),
          ),

          // Short About Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  'Who We Are',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 24),
                const MaxWidthContainer(
                  child: Text(
                    'Ardaita and its Surrounding Charittable Association is a community-driven organization dedicated to fostering sustainable progress, equitable education, and accessible healthcare in the Ardaita region.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, height: 1.6),
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => onNavigate(1),
                  child: const Text(
                    'Read our full story →',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Call to Action Bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
            decoration: BoxDecoration(color: Colors.green.shade50),
            child: Column(
              children: [
                const Text(
                  'Join us in making a difference',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => onNavigate(4), // Contact
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    'Get Involved Today',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            color: Colors.green.shade900,
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 2,
                        ),
                      ),
                      child: Image.asset(
                        'assets/New_Logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ardaita and its Surrounding Charittable Association',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Empowering Communities Together',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '© 2026 Ardaita and its Surrounding Charittable Association. All rights reserved.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ardaita, Ethiopia | info@ardaitaunity.org',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 48, color: Colors.green.shade700),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}

class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class AboutUsPage extends StatefulWidget {
  final int? initialSubTab;

  const AboutUsPage({super.key, this.initialSubTab});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  int? selectedSubTab; // null = nothing selected initially

  @override
  void initState() {
    super.initState();
    selectedSubTab = widget.initialSubTab;
  }

  @override
  void didUpdateWidget(covariant AboutUsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSubTab != widget.initialSubTab) {
      selectedSubTab = widget.initialSubTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/Home_Page.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
        ),
        Column(
          children: [
            // Content area
            Expanded(
              child: selectedSubTab == null
                  ? const Center(
                      child: Text(
                        'Select a section to view details',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.93),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: selectedSubTab == 0
                            ? const WhoWeAreTab()
                            : selectedSubTab == 1
                            ? const WhatWeDoTab()
                            : const InitiativesTab(),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class WhoWeAreTab extends StatelessWidget {
  const WhoWeAreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo at the top
          Center(
            child: Container(
              width: 100,
              height: 100,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Image.asset('assets/New_Logo.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Organizational Structure',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 48),

          // Tree Structure
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  _buildTreeLevel(
                    'Chairperson',
                    'Dejen Kuma(PhD)',
                    Icons.person_rounded,
                    isRoot: false,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 1032,
                    height: 250,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 264,
                          top: 44,
                          child: _buildTreeLevel(
                            'Vice Chairperson',
                            'Yasin Tufa',
                            Icons.person_outline_rounded,
                            width: 230,
                          ),
                        ),
                        Positioned(
                          left: 516,
                          top: 0,
                          child: _buildVerticalLine(height: 230),
                        ),
                        Positioned(
                          left: 494,
                          top: 134,
                          child: Container(
                            width: 22,
                            height: 2,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        Positioned(
                          left: 120,
                          top: 230,
                          child: Container(
                            width: 792,
                            height: 2,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        Positioned(
                          left: 120,
                          top: 230,
                          child: _buildVerticalLine(height: 20),
                        ),
                        Positioned(
                          left: 384,
                          top: 230,
                          child: _buildVerticalLine(height: 20),
                        ),
                        Positioned(
                          left: 648,
                          top: 230,
                          child: _buildVerticalLine(height: 20),
                        ),
                        Positioned(
                          left: 912,
                          top: 230,
                          child: _buildVerticalLine(height: 20),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTreeBranchWithRightChild(
                        title: 'Operational and Admin Lead',
                        subtitle: 'Dr.Tefaye Megersa',
                        icon: Icons.admin_panel_settings_rounded,
                        childTitle: 'Operational Support',
                        childSubtitle: '',
                        childIcon: Icons.support_agent_rounded,
                        showChildDivider: false,
                        customChildContent: _buildIndividualBulletList([
                          'Bizuayehu Chala',
                          'Cheru Fano',
                        ]),
                      ),
                      const SizedBox(width: 24),
                      _buildTreeBranchWithRightChild(
                        title: 'Treasurer',
                        subtitle: 'Dereje Tilahun',
                        icon: Icons.account_balance_wallet_rounded,
                        childTitle: 'Treasurer Support',
                        childSubtitle: 'Faruk Teshale',
                        childIcon: Icons.payments_rounded,
                      ),
                      const SizedBox(width: 24),
                      _buildTreeBranchWithRightChild(
                        title: 'Secretary and PR lead',
                        subtitle: 'Abdulkadir Kaltiso',
                        icon: Icons.edit_note_rounded,
                        childTitle: 'Secretary and PR support',
                        childSubtitle: 'Beshir Edao',
                        childIcon: Icons.support_agent_rounded,
                      ),
                      const SizedBox(width: 24),
                      _buildTreeBranchWithRightChild(
                        title: 'Legal Lead',
                        subtitle: 'Habib Amano',
                        icon: Icons.gavel_rounded,
                        childTitle: 'Legal subcommittee',
                        childSubtitle: '',
                        childIcon: Icons.balance_rounded,
                        showChildDivider: false,
                        customChildContent: _buildIndividualBulletList([
                          'Asrat Abdo',
                          'Fitsum Husen',
                          'Mohammed Hayato',
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 64),
          Text(
            'Authority & Governance',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 24),
          const Text(
            'The NGO Establishment Committee (NEsCo) serves as a temporary, mandate-driven body entrusted by the General Assembly to lead and coordinate the establishment of the Association. Its primary role is to facilitate all preparatory processes required for legal registration and initial operational readiness, including drafting foundational documents, guiding consultative discussions, mobilizing membership, and ensuring compliance with applicable legal requirements. NEsCo exercises delegated authority to make timely decisions necessary for these purposes, within the scope defined by the General Assembly, and operates in a transparent and accountable manner. Its mandate concludes upon the formal establishment of the Association and the transition to the duly constituted governing body.',
            style: TextStyle(fontSize: 18, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualBulletList(List<String> names) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: names
          .map(
            (name) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTreeBranchWithRightChild({
    required String title,
    String subtitle = '',
    required IconData icon,
    required String childTitle,
    String childSubtitle = '',
    required IconData childIcon,
    bool showChildDivider = true,
    Widget? customChildContent,
  }) {
    return SizedBox(
      width: 240,
      child: Column(
        children: [
          _buildTreeLevel(title, subtitle, icon, width: 230),
          SizedBox(
            width: 240,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: _buildVerticalLine(height: 50)),
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 5, right: 5),
                  child: _buildTreeLevel(
                    childTitle,
                    childSubtitle,
                    childIcon,
                    width: 230,
                    height: null,
                    showCustomDivider: showChildDivider,
                    customContent: customChildContent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeLevel(
    String title,
    String subtitle,
    IconData icon, {
    bool isRoot = false,
    double width = 230,
    double? height = 180,
    String? imagePath,
    bool showCustomDivider = true,
    Widget? customContent,
  }) {
    return Container(
      width: width,
      height: height,
      constraints: height == null ? const BoxConstraints(minHeight: 180) : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRoot ? const Color(0xFF2E7D32) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          imagePath != null
              ? CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(imagePath),
                  onBackgroundImageError: (exception, stackTrace) =>
                      const Icon(Icons.person_rounded, size: 32),
                )
              : Icon(
                  icon,
                  color: isRoot ? Colors.white : const Color(0xFF2E7D32),
                  size: 32,
                ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isRoot ? Colors.white : Colors.black87,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isRoot ? Colors.white70 : Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (customContent != null) ...[
            const SizedBox(height: 12),
            if (showCustomDivider)
              const Divider(height: 1, color: Colors.green),
            const SizedBox(height: 8),
            customContent,
          ],
        ],
      ),
    );
  }

  Widget _buildVerticalLine({double height = 40}) {
    return Container(height: height, width: 2, color: const Color(0xFF2E7D32));
  }
}

class WhatWeDoTab extends StatelessWidget {
  const WhatWeDoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vision', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 16),
          const Text(
            'To build a healthy, educated, environmentally sustainable, and economically empowered community where every individual has the opportunity to thrive with dignity and unity.',
            style: TextStyle(fontSize: 18, height: 1.6),
          ),
          const SizedBox(height: 40),
          Text('Mission', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 16),
          const Text(
            'Ardaita and its Surrounding Charittable Association is a charitable organization committed to improving the quality of life in our community by:',
            style: TextStyle(fontSize: 18, height: 1.6),
          ),
          const SizedBox(height: 24),
          _buildListItem(
            'Promoting accessible and sustainable public health initiatives.',
            Icons.health_and_safety_outlined,
          ),
          _buildListItem(
            'Expanding equitable access to quality education and lifelong learning opportunities.',
            Icons.school_outlined,
          ),
          _buildListItem(
            'Protecting and restoring the environment through community-led conservation efforts.',
            Icons.eco_outlined,
          ),
          _buildListItem(
            'Supporting small-scale economic activities and entrepreneurship to enhance household income and self-reliance.',
            Icons.trending_up_outlined,
          ),
          const SizedBox(height: 40),
          Text('Core Values', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 16),
          _buildCoreValue(
            '1. Unity',
            'We believe collective effort and community collaboration are the foundation of sustainable development.',
          ),
          _buildCoreValue(
            '2. Integrity',
            'We operate with transparency, accountability, and ethical responsibility in all our actions.',
          ),
          _buildCoreValue(
            '3. Compassion',
            'We serve with empathy, prioritizing the needs of vulnerable and underserved populations.',
          ),
          _buildCoreValue(
            '4. Empowerment',
            'We strengthen individuals and families by building skills, knowledge, and economic opportunities.',
          ),
          _buildCoreValue(
            '5. Sustainability',
            'We promote environmentally responsible and long-term solutions that benefit future generations.',
          ),
          _buildCoreValue(
            '6. Equity and Inclusion',
            'We ensure equal opportunities regardless of gender, age, background, or economic status.',
          ),
          _buildCoreValue(
            '7. Innovation',
            'We embrace creative, practical, and locally driven approaches to solving community challenges.',
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreValue(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 18, height: 1.6)),
        ],
      ),
    );
  }
}

class InitiativesTab extends StatelessWidget {
  const InitiativesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> initiatives = [
      {
        'title': 'Environment protection',
        'subtitle': 'Sustainability & Conservation',
        'icon': Icons.eco_rounded,
        'activities': [
          'Community reforestation projects',
          'Sustainable water resource management',
          'Environment awareness workshops',
          'Waste reduction initiatives',
        ],
      },
      {
        'title': 'Education',
        'subtitle': 'Learning & Development',
        'icon': Icons.school_rounded,
        'activities': [
          'Primary school support programs',
          'Vocational training for youth',
          'Digital literacy classes',
          'Educational resource distribution',
        ],
      },
      {
        'title': 'Health',
        'subtitle': 'Public Wellness & Safety',
        'icon': Icons.health_and_safety_rounded,
        'activities': [
          'Public health awareness campaigns',
          'Mental wellness support sessions',
          'Preventive care education',
          'Medical resource facilitation',
        ],
      },
      {
        'title': 'Economic activities',
        'subtitle': 'Growth & Empowerment',
        'icon': Icons.trending_up_rounded,
        'activities': [
          'Micro-finance group support',
          'Small business mentorship',
          'Entrepreneurship training',
          'Agricultural development support',
        ],
      },
      {
        'title': 'Social Care',
        'subtitle': 'Care for Vulnerable children & elderly',
        'icon': Icons.volunteer_activism_rounded,
        'activities': [
          'Protect Children & Elderly',
          'Support At-Risk Children',
          'Assist Vulnerable Elderly',
        ],
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo at the top
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/New_Logo.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Our Initiatives',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisExtent: 320,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: initiatives.length,
            itemBuilder: (context, index) {
              final item = initiatives[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.green.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item['icon'],
                              color: Colors.green,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item['subtitle'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Core Activities:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (item['activities'] as List).length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item['activities'][i],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> initiatives = [
      {
        'title': 'Environment protection',
        'subtitle': 'Sustainability & Conservation',
        'icon': Icons.eco_rounded,
        'activities': [
          'Community reforestation projects',
          'Sustainable water resource management',
          'Environment awareness workshops',
          'Waste reduction initiatives',
        ],
      },
      {
        'title': 'Education',
        'subtitle': 'Learning & Development',
        'icon': Icons.school_rounded,
        'activities': [
          'Primary school support programs',
          'Vocational training for youth',
          'Digital literacy classes',
          'Educational resource distribution',
        ],
      },
      {
        'title': 'Health',
        'subtitle': 'Public Wellness & Safety',
        'icon': Icons.health_and_safety_rounded,
        'activities': [
          'Public health awareness campaigns',
          'Mental wellness support sessions',
          'Preventive care education',
          'Medical resource facilitation',
        ],
      },
      {
        'title': 'Economic activities',
        'subtitle': 'Growth & Empowerment',
        'icon': Icons.trending_up_rounded,
        'activities': [
          'Micro-finance group support',
          'Small business mentorship',
          'Entrepreneurship training',
          'Agricultural development support',
        ],
      },
      {
        'title': 'Social Care',
        'subtitle': 'Care for Vulnerable children & elderly',
        'icon': Icons.volunteer_activism_rounded,
        'activities': [
          'Protect Children & Elderly',
          'Support At-Risk Children',
          'Assist Vulnerable Elderly',
        ],
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Initiatives',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500,
              mainAxisExtent: 320,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: initiatives.length,
            itemBuilder: (context, index) {
              final item = initiatives[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.green.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item['icon'],
                              color: Colors.green,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item['subtitle'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Core Activities:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (item['activities'] as List).length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item['activities'][i],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  bool _loading = true;
  String? _error;
  List<FileObject> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final files = await supabase.storage
          .from('documents')
          .list(
            path: '',
            searchOptions: const SearchOptions(
              sortBy: SortBy(column: 'name', order: 'asc'),
            ),
          );

      final documents = files.where(_isFile).toList();

      if (!mounted) return;
      setState(() {
        _documents = documents;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _formatStorageError(e);
      });
    }
  }

  bool _isFile(FileObject file) => file.metadata != null;

  String _formatStorageError(Object error) {
    return error.toString().replaceFirst('StorageException: ', '');
  }

  String _descriptionFor(String fileName) {
    final lower = fileName.toLowerCase();

    if (lower.endsWith('.pdf')) return 'PDF document';
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return 'Word document';
    }
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
      return 'Excel spreadsheet';
    }
    if (lower.endsWith('.txt')) return 'Text document';

    return 'Website document';
  }

  Future<void> _openDocument(BuildContext context, String fileName) async {
    final url = supabase.storage.from('documents').getPublicUrl(fileName);

    final opened = await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the selected document.')),
      );
    }
  }

  void _downloadDocument(String fileName) {
    final url = supabase.storage.from('documents').getPublicUrl(fileName);
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..rel = 'noopener noreferrer'
      ..setAttribute('download', fileName)
      ..click();
    anchor.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Documents',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh documents',
                  onPressed: _loading ? null : _loadDocuments,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 52,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to load documents',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadDocuments,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _documents.isEmpty
                ? const Center(
                    child: Text('No documents are currently available.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    itemCount: _documents.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final file = _documents[index];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF2E7D32),
                          child: Icon(Icons.description, color: Colors.white),
                        ),
                        title: Text(
                          file.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(_descriptionFor(file.name)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Open document',
                              icon: const Icon(
                                Icons.open_in_new,
                                color: Colors.green,
                              ),
                              onPressed: () =>
                                  _openDocument(context, file.name),
                            ),
                            IconButton(
                              tooltip: 'Download document',
                              icon: const Icon(
                                Icons.download_rounded,
                                color: Colors.green,
                              ),
                              onPressed: () => _downloadDocument(file.name),
                            ),
                          ],
                        ),
                        onTap: () => _openDocument(context, file.name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool _loading = true;
  String? _error;
  List<FileObject> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final files = await supabase.storage
          .from('gallery')
          .list(
            path: '',
            searchOptions: const SearchOptions(
              sortBy: SortBy(column: 'name', order: 'asc'),
            ),
          );

      final images = files.where(_isImage).toList();

      if (!mounted) return;
      setState(() {
        _images = images;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _formatStorageError(e);
      });
    }
  }

  bool _isImage(FileObject file) {
    if (file.metadata == null) return false;

    final name = file.name.toLowerCase();
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif');
  }

  String _formatStorageError(Object error) {
    return error.toString().replaceFirst('StorageException: ', '');
  }

  void _openGalleryImage(
    BuildContext context,
    String imageUrl,
    String fileName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(dialogContext).size.width * 0.9,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.9,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fileName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Close image',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          semanticLabel: fileName,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Project Visuals',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              IconButton(
                tooltip: 'Refresh gallery',
                onPressed: _loading ? null : _loadImages,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 52,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to load gallery',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadImages,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _images.isEmpty
                ? const Center(
                    child: Text('No gallery images are currently available.'),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 1.5,
                        ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      final file = _images[index];
                      final url = supabase.storage
                          .from('gallery')
                          .getPublicUrl(file.name);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () =>
                              _openGalleryImage(context, url, file.name),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: Colors.green.shade50,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;

                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          size: 40,
                                          color: Colors.green.shade200,
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withValues(alpha: 0.6),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        file.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;
  String? _feedbackMessage;
  bool _submissionSucceeded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _feedbackMessage = null;
    });

    try {
      await supabase.from('contact_messages').insert({
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submissionSucceeded = true;
        _feedbackMessage = 'Your message has been sent successfully.';
      });

      _formKey.currentState?.reset();
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submissionSucceeded = false;
        _feedbackMessage = _formatError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Us', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactMethod(
                      Icons.location_on_rounded,
                      'Our Head Office',
                      'Addis Ababa, Ethiopia',
                    ),
                    const SizedBox(height: 24),
                    _buildContactMethod(
                      Icons.email_rounded,
                      'Email Us',
                      'info@ardaitaunity.org',
                    ),
                    const SizedBox(height: 24),
                    _buildContactMethod(
                      Icons.phone_rounded,
                      'Call Us',
                      '+251 911 123 000',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_feedbackMessage != null) ...[
                        _buildFeedbackBanner(
                          _feedbackMessage!,
                          success: _submissionSucceeded,
                        ),
                        const SizedBox(height: 24),
                      ],
                      const Text(
                        'Send us a message',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => FormValidators.minLength(
                                value,
                                'Full name',
                                2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                border: OutlineInputBorder(),
                              ),
                              validator: FormValidators.email,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _messageController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Message',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => FormValidators.minLength(
                                value,
                                'Message',
                                10,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                _isSubmitting
                                    ? 'Submitting...'
                                    : 'Submit Message',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner(String message, {required bool success}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: success ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: success ? Colors.green.shade900 : Colors.orange.shade900,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatError(Object error) {
    final message = error.toString();
    return message.startsWith('Bad state: ')
        ? message.substring('Bad state: '.length)
        : message;
  }

  Widget _buildContactMethod(IconData icon, String title, String detail) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              detail,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }
}

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Support Our Cause',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 24),
          const Text(
            'Until the website integration is complete, please make your donation to the following account:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Column(
              children: [
                Text(
                  'Account Name: Ardaita and its Surrounding Charittable Association',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'CBE: 1000758051367',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Your generous donation helps us continue our mission to empower the Ardaita community through education, health, and sustainable development.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, height: 1.6),
          ),
          const SizedBox(height: 48),
          // Wrap(
          //   spacing: 24,
          //   runSpacing: 24,
          //   alignment: WrapAlignment.center,
          //   children: [
          //     _buildDonationCard(
          //       context,
          //       '\$1',
          //       'Provides school supplies for one student',
          //     ),
          //     _buildDonationCard(
          //       context,
          //       '\$5',
          //       'Supports a local community health workshop',
          //     ),
          //     _buildDonationCard(
          //       context,
          //       '\$10',
          //       'Funds a small-scale conservation project',
          //     ),
          //     _buildDonationCard(
          //       context,
          //       'Custom',
          //       'Any amount makes a significant difference',
          //     ),
          //   ],
          // ),
          const SizedBox(height: 48),
          // ElevatedButton(
          //   onPressed: () {},
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: const Color(0xFF2E7D32),
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
          //     textStyle: const TextStyle(
          //       fontSize: 20,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          //   child: const Text('Donate Now'),
          // ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(
    BuildContext context,
    String amount,
    String description,
  ) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class BecomeVolunteerPage extends StatefulWidget {
  const BecomeVolunteerPage({super.key});

  @override
  State<BecomeVolunteerPage> createState() => _BecomeVolunteerPageState();
}

class _BecomeVolunteerPageState extends State<BecomeVolunteerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _motivationController = TextEditingController();
  String? selectedInitiative;
  bool _isSubmitting = false;
  String? _feedbackMessage;
  bool _submissionSucceeded = false;
  final List<String> initiatives = [
    'Environment protection',
    'Education',
    'Health',
    'Economic activities',
    'Social Care',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    if (selectedInitiative == null || selectedInitiative!.trim().isEmpty) {
      setState(() {
        _submissionSucceeded = false;
        _feedbackMessage = 'Please choose an initiative before submitting.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _feedbackMessage = null;
    });

    try {
      await supabase.from('volunteer_applications').insert({
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'initiative': selectedInitiative!.trim(),
        'motivation': _motivationController.text.trim(),
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submissionSucceeded = true;
        _feedbackMessage =
            'Your volunteer application has been submitted successfully.';
        selectedInitiative = null;
      });

      _formKey.currentState?.reset();
      _nameController.clear();
      _emailController.clear();
      _motivationController.clear();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _submissionSucceeded = false;
        _feedbackMessage = _formatError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Become a Volunteer',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_feedbackMessage != null) ...[
                  _buildFeedbackBanner(
                    _feedbackMessage!,
                    success: _submissionSucceeded,
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Join our community of change-makers',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            FormValidators.minLength(value, 'Full name', 2),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormValidators.email,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Choose Initiative',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: selectedInitiative,
                        items: initiatives.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) =>
                            FormValidators.requiredField(value, 'Initiative'),
                        onChanged: (newValue) {
                          setState(() {
                            selectedInitiative = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _motivationController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Tell us what inspired you to volunteer',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            FormValidators.minLength(value, 'Motivation', 10),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(
                          _isSubmitting
                              ? 'Submitting...'
                              : 'Submit Application',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner(String message, {required bool success}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: success ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: success ? Colors.green.shade900 : Colors.orange.shade900,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatError(Object error) {
    final message = error.toString();
    return message.startsWith('Bad state: ')
        ? message.substring('Bad state: '.length)
        : message;
  }
}
