import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;
  bool _isStep2 = false;
  bool _isResetPasswordForm = false;
  bool _isResetMobileForm = false;
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final _newMobileController = TextEditingController();
  final _confirmNewMobileController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _newMobileController.dispose();
    _confirmNewMobileController.dispose();
    super.dispose();
  }

  Future<void> _verifyIdentity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final response = await apiService.verifyIdentity(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );

      if (response['success']) {
        setState(() {
          _isLoading = false;
          _isStep2 = true;
          _successMessage = 'Utambulisho umethibitishwa. Chagua kile unachotaka kubadilisha.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response['message'] ?? 'Mteja hajapatikana na maelezo hayo.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Hitilafu ya mtandao: $e';
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.isEmpty || 
        _confirmNewPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Tafadhali weka nenosiri jipya na urudie.';
      });
      return;
    }

    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      setState(() {
        _errorMessage = 'Nenosiri halifanani. Tafadhali hakikisha nenosiri ni sawa.';
      });
      return;
    }

    if (_newPasswordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Nenosiri lazima liwe na angalau herufi 6';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final response = await apiService.resetPassword(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _newPasswordController.text,
      );

      if (response['success']) {
        setState(() {
          _isLoading = false;
          _successMessage = 'Nenosiri limebadilishwa kikamilifu! Unaweza kuingia sasa kwa nenosiri jipya.';
          _isResetPasswordForm = false;
          _isStep2 = false;
        });
        
        // Auto navigate to login after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LoginScreen(
                initialPhone: _firstNameController.text.trim(),
              ),
            ),
          );
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response['message'] ?? 'Hitilafu katika kubadilisha nenosiri.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Hitilafu ya mtandao: $e';
      });
    }
  }

  Future<void> _resetMobile() async {
    if (_newMobileController.text.isEmpty || 
        _confirmNewMobileController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Tafadhali weka nambari mpya ya simu na urudie.';
      });
      return;
    }

    if (_newMobileController.text != _confirmNewMobileController.text) {
      setState(() {
        _errorMessage = 'Nambari za simu hazifanani. Tafadhali hakikisha nambari ni sawa.';
      });
      return;
    }

    if (_newMobileController.text.length < 10) {
      setState(() {
        _errorMessage = 'Nambari ya simu sio sahihi';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final response = await apiService.resetMobile(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _newMobileController.text,
      );

      if (response['success']) {
        setState(() {
          _isLoading = false;
          _successMessage = 'Nambari ya simu imebadilishwa kikamilifu! Unaweza kuingia sasa kwa nambari mpya.';
          _isResetMobileForm = false;
          _isStep2 = false;
        });
        
        // Auto navigate to login after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LoginScreen(
                initialPhone: _newMobileController.text.trim(),
              ),
            ),
          );
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response['message'] ?? 'Hitilafu katika kubadilisha nambari ya simu.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Hitilafu ya mtandao: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Umesahau Nenosiri'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Umesahau Nenosiri?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tutakusaidia kupata nenosiri lako upya kwa urahisi',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Error/Success Messages
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),

            if (_errorMessage != null || _successMessage != null)
              const SizedBox(height: 20),

            if (!_isStep2 && !_isResetPasswordForm && !_isResetMobileForm) ...[
              // Step 1: Identity Verification
              const Text(
                'Weka jina lako la kwanza na jina la mwisho kuthibitisha utambulisho wako.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'Jina la Kwanza',
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
                    const SizedBox(height: 30),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _verifyIdentity,
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Endelea'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],

            if (_isStep2 && !_isResetPasswordForm && !_isResetMobileForm) ...[
              // Step 2: Choose what to reset
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Chagua kile unachotaka kubadilisha:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isResetPasswordForm = true;
                          _isStep2 = false;
                        });
                      },
                      icon: const Icon(Icons.lock),
                      label: const Text('Badilisha Nenosiri'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isResetMobileForm = true;
                          _isStep2 = false;
                        });
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Badilisha Nambari ya Simu'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (_isResetPasswordForm) ...[
              // Reset Password Form
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Weka nenosiri jipya lako:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              Column(
                children: [
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Nenosiri Jipya',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmNewPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Rudia Nenosiri Jipya',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _resetPassword,
                            icon: const Icon(Icons.check),
                            label: const Text('Weka Nenosiri Jipya'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                ],
              ),
            ],

            if (_isResetMobileForm) ...[
              // Reset Mobile Form
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Weka nambari mpya ya simu:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              Column(
                children: [
                  TextFormField(
                    controller: _newMobileController,
                    decoration: const InputDecoration(
                      labelText: 'Nambari Mpya ya Simu',
                      hintText: '07XX XXX XXX',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmNewMobileController,
                    decoration: const InputDecoration(
                      labelText: 'Rudia Nambari ya Simu',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 30),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _resetMobile,
                            icon: const Icon(Icons.check),
                            label: const Text('Weka Nambari Mpya'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}