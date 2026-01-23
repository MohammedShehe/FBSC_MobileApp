import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final User user;
  
  const ProfileEditScreen({super.key, required this.user});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late String _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _selectedGender = widget.user.gender ?? 'mwanaume';
  }

  Future<void> _updateProfile() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tafadhali jaza jina lako kamili'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final result = await apiService.updateProfile(
        authService.authToken!,
        {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'email': _emailController.text.trim().isNotEmpty 
              ? _emailController.text.trim() 
              : null,
          'address': _addressController.text.trim(),
          'gender': _selectedGender,
        },
      );

      if (result['success']) {
        final updatedUser = User.fromJson(result['data']['customer']);
        authService.updateUserProfile(updatedUser);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profaili imesasishwa kikamilifu!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Hitilafu katika kusasisha profaili'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hariri Profaili'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue,
                    child: Text(
                      widget.user.initials,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // First Name and Last Name
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Jina la Kwanza',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Jina la Mwisho',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Phone Number (Read-only)
            TextFormField(
              controller: TextEditingController(text: widget.user.phone),
              decoration: const InputDecoration(
                labelText: 'Nambari ya Simu',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey,
              ),
              enabled: false,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                _showChangePhoneDialog();
              },
              icon: const Icon(Icons.edit),
              label: const Text('Badilisha Nambari ya Simu'),
            ),
            
            const SizedBox(height: 20),
            
            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Barua Pepe',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 20),
            
            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Anwani',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 20),
            
            // Gender
            const Text(
              'Jinsia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.male, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Mwanaume'),
                      ],
                    ),
                    value: 'mwanaume',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() => _selectedGender = value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.female, color: Colors.pink),
                        SizedBox(width: 8),
                        Text('Mwanamke'),
                      ],
                    ),
                    value: 'mwanamke',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() => _selectedGender = value!);
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Save Button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _updateProfile,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Hifadhi Mabadiliko',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showChangePhoneDialog() {
    final newPhoneController = TextEditingController();
    final confirmPhoneController = TextEditingController();
    final passwordController = TextEditingController();
    bool showPassword = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Badilisha Nambari ya Simu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: newPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Nambari Mpya ya Simu',
                    hintText: '07XX XXX XXX',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Rudia Nambari ya Simu',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Nenosiri la Sasa',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() => showPassword = !showPassword);
                      },
                    ),
                  ),
                  obscureText: !showPassword,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batilisha'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newPhoneController.text != confirmPhoneController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nambari za simu hazifanani'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tafadhali weka nenosiri'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Here you would call API to change phone number
                  Navigator.of(context).pop();
                },
                child: const Text('Badilisha'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}