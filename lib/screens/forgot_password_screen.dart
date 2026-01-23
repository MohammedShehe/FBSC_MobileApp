import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

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

    setState(() => _isLoading = true);
    
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
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Mteja hajapatikana na maelezo hayo.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hitilafu ya mtandao: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.isEmpty || 
        _confirmNewPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tafadhali weka nenosiri jipya na urudie.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenosiri halifanani. Tafadhali hakikisha nenosiri ni sawa.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final response = await apiService.resetPassword(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _newPasswordController.text,
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenosiri limebadilishwa kikamilifu! Unaweza kuingia sasa kwa nenosiri jipya.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Hitilafu katika kubadilisha nenosiri.'),
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

  Future<void> _resetMobile() async {
    if (_newMobileController.text.isEmpty || 
        _confirmNewMobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tafadhali weka nambari mpya ya simu na urudie.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newMobileController.text != _confirmNewMobileController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nambari za simu hazifanani. Tafadhali hakikisha nambari ni sawa.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final response = await apiService.resetMobile(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _newMobileController.text,
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nambari ya simu imebadilishwa kikamilifu! Unaweza kuingia sasa kwa nambari mpya.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Hitilafu katika kubadilisha nambari ya simu.'),
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