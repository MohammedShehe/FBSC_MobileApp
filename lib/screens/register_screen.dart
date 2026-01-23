import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'terms_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _selectedGender;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;

  void _checkPasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) strength++;
    
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      } else if (strength == 1) {
        _passwordStrength = 'Dhaifu';
        _passwordStrengthColor = Colors.red;
      } else if (strength == 2) {
        _passwordStrength = 'Wastani';
        _passwordStrengthColor = Colors.orange;
      } else if (strength == 3) {
        _passwordStrength = 'Imara';
        _passwordStrengthColor = Colors.blue;
      } else {
        _passwordStrength = 'Imara sana';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tafadhali kubali Masharti ya Huduma'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final result = await apiService.register({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text.trim(),
        'confirm_password': _confirmPasswordController.text.trim(),
        'email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        'address': _addressController.text.trim(),
        'gender': _selectedGender,
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usajili umefanikiwa! Sasa unaweza kuingia.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to login screen with phone number
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              initialPhone: _phoneController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Hitilafu katika usajili'),
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
        title: const Text('Jiandikishe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
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
                                    fontSize: 18,
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
                      'Uanze Safari Yako',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Unda akaunti yako kwa dakika chache tu',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
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
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tafadhali weka jina la kwanza';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Jina la Mwisho',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tafadhali weka jina la mwisho';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nambari ya Simu',
                  hintText: '07XX XXX XXX',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tafadhali weka nambari ya simu';
                  }
                  if (value.length < 10) {
                    return 'Nambari ya simu sio sahihi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Password
              TextFormField(
                controller: _passwordController,
                onChanged: _checkPasswordStrength,
                decoration: InputDecoration(
                  labelText: 'Nenosiri',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: !_showPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tafadhali weka nenosiri';
                  }
                  if (value.length < 6) {
                    return 'Nenosiri lazima liwe na angalau herufi 6';
                  }
                  return null;
                },
              ),
              
              // Password Strength Indicator
              if (_passwordStrength.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Nguvu ya nenosiri: ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _passwordStrength,
                      style: TextStyle(
                        color: _passwordStrengthColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: _passwordStrength == 'Dhaifu' ? 0.25 :
                         _passwordStrength == 'Wastani' ? 0.5 :
                         _passwordStrength == 'Imara' ? 0.75 : 1.0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                  minHeight: 4,
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Rudia Nenosiri',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showConfirmPassword = !_showConfirmPassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                obscureText: !_showConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tafadhali rudia nenosiri';
                  }
                  if (value != _passwordController.text) {
                    return 'Nenosiri halifanani';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Email (Optional)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Barua Pepe (Hiari)',
                  hintText: 'jina@mfano.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 20),
              
              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Anwani Kamili',
                  hintText: 'Andika anwani yako kamili',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tafadhali weka anwani yako';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Gender Selection
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
                        setState(() => _selectedGender = value);
                      },
                      contentPadding: EdgeInsets.zero,
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
                        setState(() => _selectedGender = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              
              // Gender Validation
              if (_selectedGender == null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Tafadhali chagua jinsia yako',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Terms Agreement
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() => _agreeToTerms = value ?? false);
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TermsScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: 'Nimekubaliana na '),
                            TextSpan(
                              text: 'Masharti ya Huduma',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' ya Four Brothers Sports Center'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Register Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add),
                          SizedBox(width: 8),
                          Text(
                            'Jiandikishe',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
              
              const SizedBox(height: 20),
              
              // Divider
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Ama'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tayari una akaunti? '),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Ingia hapa',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}