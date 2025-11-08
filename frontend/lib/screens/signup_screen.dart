import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String email = '';
  String password = '';
  String role = 'Parent';
  String? phone;
  String? profilePicture;
  bool isLoading = false;
  bool showPassword = false;

  void submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final Map<String, dynamic> data = {
      'full_name': fullName.trim(),
      'email': email.trim(),
      'password': password,
      'role': role,
      'phone': phone,
      'profile_picture': profilePicture,
    };

    final response = await ApiService.signup(data);
    setState(() => isLoading = false);

    final message = response['message'] ?? 'Unknown error';
    final success = response['token'] != null || (response['success'] == true) || message.toLowerCase().contains('success');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success && mounted) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحديد إذا كان التطبيق يعمل على الويب
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Color(0xFFF0E5FF),
      body: SafeArea(
        child: Center(
          child: Container(
            // تحديد عرض الحاوية بناءً على المنصة
            width: isWeb ? 500 : double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 40 : 30,
                vertical: isWeb ? 20 : 40
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Container مع خلفية بيضاء وظل للويب
                    Container(
                      decoration: isWeb ? BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 6),
                          )
                        ],
                      ) : null,
                      padding: isWeb ? EdgeInsets.all(30) : EdgeInsets.zero,
                      child: Column(
                        children: [
                          // Tabs: Login / Signup
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                child: Text(
                                  'Log in',
                                  style: TextStyle(
                                    fontSize: isWeb ? 22 : 20,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: isWeb ? 22 : 20,
                                    color: Color(0xFF7815A0),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isWeb ? 30 : 30),

                          // Logo
                          Image.asset(
                            'assets/images/jusoor_logo.png',
                            height: isWeb ? 120 : 100,
                          ),
                          SizedBox(height: isWeb ? 30 : 30),

                          // Full Name
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: TextStyle(
                                fontSize: isWeb ? 16 : null,
                                color: Color(0xFF7815A0),
                              ),
                              prefixIcon: Icon(Icons.person_outline, color: Color(0xFF7815A0)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Color(0xFF7815A0)),
                              ),
                              contentPadding: isWeb
                                  ? EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                  : null,
                            ),
                            onChanged: (val) => fullName = val,
                            validator: (val) => val!.trim().isEmpty ? 'Required' : null,
                          ),
                          SizedBox(height: isWeb ? 20 : 16),

                          // Email
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                fontSize: isWeb ? 16 : null,
                                color: Color(0xFF7815A0),
                              ),
                              prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF7815A0)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Color(0xFF7815A0)),
                              ),
                              contentPadding: isWeb
                                  ? EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                  : null,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (val) => email = val,
                            validator: (val) => val!.isEmpty ? 'Required' : null,
                          ),
                          SizedBox(height: isWeb ? 20 : 16),

                          // Password
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontSize: isWeb ? 16 : null,
                                color: Color(0xFF7815A0),
                              ),
                              prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF7815A0)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Color(0xFF7815A0),
                                ),
                                onPressed: () => setState(() => showPassword = !showPassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Color(0xFF7815A0)),
                              ),
                              contentPadding: isWeb
                                  ? EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                  : null,
                            ),
                            obscureText: !showPassword,
                            onChanged: (val) => password = val,
                            validator: (val) => val!.length < 6 ? 'Minimum 6 characters required' : null,
                          ),
                          SizedBox(height: isWeb ? 20 : 16),

                          // Phone
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Phone (Optional)',
                              labelStyle: TextStyle(
                                fontSize: isWeb ? 16 : null,
                                color: Color(0xFF7815A0),
                              ),
                              prefixIcon: Icon(Icons.phone, color: Color(0xFF7815A0)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Color(0xFF7815A0)),
                              ),
                              contentPadding: isWeb
                                  ? EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                  : null,
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (val) => phone = val,
                          ),
                          SizedBox(height: isWeb ? 20 : 16),

                          // Role Dropdown
                          DropdownButtonFormField<String>(
                            value: role,
                            items: ['Parent','Admin','Specialist','Donor','Institution']
                                .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r,
                                style: TextStyle(
                                  fontSize: isWeb ? 16 : null,
                                ),
                              ),
                            )).toList(),
                            onChanged: (val) => setState(() => role = val!),
                            decoration: InputDecoration(
                              labelText: 'Role',
                              labelStyle: TextStyle(
                                fontSize: isWeb ? 16 : null,
                                color: Color(0xFF7815A0),
                              ),
                              prefixIcon: Icon(Icons.work_outline, color: Color(0xFF7815A0)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Color(0xFF7815A0)),
                              ),
                              contentPadding: isWeb
                                  ? EdgeInsets.symmetric(horizontal: 12, vertical: 16)
                                  : null,
                            ),
                            dropdownColor: Colors.white,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: isWeb ? 16 : null,
                            ),
                          ),
                          SizedBox(height: isWeb ? 30 : 24),

                          // Signup Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: isWeb ? 18 : 16),
                                backgroundColor: Color(0xFF7815A0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: isLoading ? null : submit,
                              child: isLoading
                                  ? SizedBox(
                                height: isWeb ? 24 : 20,
                                width: isWeb ? 24 : 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: isWeb ? 20 : 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  )
                              ),
                            ),
                          ),
                          SizedBox(height: isWeb ? 25 : 20),

                          // Link to Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: isWeb ? 16 : null,
                                  )
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Color(0xFF7815A0),
                                      fontSize: isWeb ? 16 : null,
                                      fontWeight: FontWeight.w600,
                                    )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}