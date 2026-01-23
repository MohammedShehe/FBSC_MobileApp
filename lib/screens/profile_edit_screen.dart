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
      _showError('Tafadhali jaza jina lako kamili');
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
        
        _showSuccess('Profaili imesasishwa kikamilifu!');
        
        Navigator.of(context).pop();
      } else {
        _showError(result['message'] ?? 'Hitilafu katika kusasisha profaili');
      }
    } catch (e) {
      _showError('Hitilafu ya mtandao: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showChangePhoneDialog() {
    final newPhoneController = TextEditingController();
    final confirmPhoneController = TextEditingController();
    final passwordController = TextEditingController();
    bool showPassword = false;
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Badilisha Nambari ya Simu'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  
                  if (errorMessage != null) const SizedBox(height: 16),
                  
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
                  
                  const SizedBox(height: 16),
                  const Text(
                    'Unahitaji kuthibitisha jina lako la kwanza na la mwisho pamoja na nenosiri la sasa kubadilisha nambari ya simu.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Batilisha'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (newPhoneController.text.isEmpty || 
                      confirmPhoneController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    setState(() {
                      errorMessage = 'Tafadhali jaza sehemu zote';
                    });
                    return;
                  }

                  if (newPhoneController.text != confirmPhoneController.text) {
                    setState(() {
                      errorMessage = 'Nambari za simu hazifanani';
                    });
                    return;
                  }

                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });

                  final authService = Provider.of<AuthService>(context, listen: false);
                  final apiService = Provider.of<ApiService>(context, listen: false);

                  try {
                    final result = await apiService.changePhoneNumber(
                      authService.authToken!,
                      newPhoneController.text,
                      passwordController.text,
                      widget.user.firstName,
                      widget.user.lastName,
                    );

                    if (result['success']) {
                      final updatedUser = User(
                        id: widget.user.id,
                        firstName: widget.user.firstName,
                        lastName: widget.user.lastName,
                        phone: newPhoneController.text,
                        email: widget.user.email,
                        address: widget.user.address,
                        gender: widget.user.gender,
                        token: authService.authToken,
                        refreshToken: authService.currentUser?.refreshToken,
                      );
                      authService.updateUserProfile(updatedUser);
                      
                      Navigator.of(context).pop();
                      _showSuccess('Nambari ya simu imebadilishwa kikamilifu!');
                    } else {
                      setState(() {
                        errorMessage = result['message'];
                        isLoading = false;
                      });
                    }
                  } catch (e) {
                    setState(() {
                      errorMessage = 'Hitilafu ya mtandao: $e';
                      isLoading = false;
                    });
                  }
                },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Badilisha'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
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
              onPressed: _showChangePhoneDialog,
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}