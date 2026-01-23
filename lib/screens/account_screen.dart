import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/theme_service.dart';
import 'orders_screen.dart';
import 'addresses_screen.dart';
import 'profile_edit_screen.dart';
import 'terms_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akaunti Yangu'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue,
                            child: Text(
                              user.initials,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.phone,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          if (user.email != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.email!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Account Options
                  const Text(
                    'Mipangilio ya Akaunti',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: [
                        // Orders
                        _buildListTile(
                          icon: Icons.shopping_bag,
                          title: 'Maagizo Yangu',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const OrdersScreen(),
                              ),
                            );
                          },
                        ),
                        
                        // Addresses
                        _buildListTile(
                          icon: Icons.location_on,
                          title: 'Anwani Zangu',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddressesScreen(),
                              ),
                            );
                          },
                        ),
                        
                        // Edit Profile
                        _buildListTile(
                          icon: Icons.person,
                          title: 'Hariri Profaili',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProfileEditScreen(user: user),
                              ),
                            );
                          },
                        ),
                        
                        // Change Password
                        _buildListTile(
                          icon: Icons.lock,
                          title: 'Badilisha Nenosiri',
                          onTap: () {
                            _showChangePasswordDialog(context);
                          },
                        ),
                        
                        // Theme Toggle
                        ListTile(
                          leading: Icon(
                            themeService.isDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                          title: const Text('Mwonekano'),
                          trailing: Switch(
                            value: themeService.isDarkMode,
                            onChanged: (value) {
                              themeService.toggleTheme();
                            },
                          ),
                        ),
                        
                        // Terms of Service
                        _buildListTile(
                          icon: Icons.description,
                          title: 'Masharti ya Huduma',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TermsScreen(),
                              ),
                            );
                          },
                        ),
                        
                        // Contact Us
                        _buildListTile(
                          icon: Icons.help,
                          title: 'Wasiliana Nasi',
                          onTap: () {
                            _showContactDialog(context);
                          },
                        ),
                        
                        // About
                        _buildListTile(
                          icon: Icons.info,
                          title: 'Kuhusu Sisi',
                          onTap: () {
                            _showAboutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final apiService = Provider.of<ApiService>(context, listen: false);
                        
                        // Call logout API if authenticated
                        if (authService.authToken != null) {
                          await apiService.logout(authService.authToken!);
                        }
                        
                        await authService.logout();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Ondoka',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wasiliana Nasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactItem(Icons.phone, 'WhatsApp:', '+255 777 730 606'),
            _buildContactItem(Icons.email, 'Barua Pepe:', 'fourbrothers10112627@gmail.com'),
            _buildContactItem(Icons.chat, 'Instagram:', '@four_brothers_sports_center'),
            _buildContactItem(Icons.group, 'Kikundi cha WhatsApp:', 'https://chat.whatsapp.com/I8qaaMkm8EU2V77eJBkZ8g'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Sawa'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // In the AccountScreen class, update the about dialog:
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kuhusu Sisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.blue,
                      child: const Center(
                        child: Text(
                          'FB',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Four Brothers Sports Center',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Wauzaji na wasambazaji wa viatu bora vya michezo nchini Tanzania.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tunatoa huduma bora kwa wateja wetu kwa bei nafuu.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Programu hii imesanikishwa na Four Brothers Technology.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Sawa'),
          ),
        ],
      ),
    );
  }
  }

class ChangePasswordDialog extends StatefulWidget {
  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Badilisha Nenosiri'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current Password
            TextFormField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Nenosiri la Sasa',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showCurrentPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _showCurrentPassword = !_showCurrentPassword);
                  },
                ),
              ),
              obscureText: !_showCurrentPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tafadhali weka nenosiri la sasa';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // New Password
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'Nenosiri Jipya',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showNewPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _showNewPassword = !_showNewPassword);
                  },
                ),
              ),
              obscureText: !_showNewPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tafadhali weka nenosiri jipya';
                }
                if (value.length < 6) {
                  return 'Nenosiri lazima liwe na angalau herufi 6';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Rudia Nenosiri Jipya',
                prefixIcon: const Icon(Icons.lock_clock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _showConfirmPassword = !_showConfirmPassword);
                  },
                ),
              ),
              obscureText: !_showConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tafadhali rudia nenosiri jipya';
                }
                if (value != _newPasswordController.text) {
                  return 'Nenosiri halifanani';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batilisha'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Badilisha'),
        ),
      ],
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final result = await apiService.changePassword(
        authService.authToken!,
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenosiri limebadilishwa kikamilifu!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Hitilafu katika kubadilisha nenosiri'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hitilafu ya mtandao: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}