import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for form inputs
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _conditionController = TextEditingController();
  final _medicationController = TextEditingController();

  // List to store medications
  final List<String> _medications = [];

  // Loading state
  bool _isLoading = false;

  // Current page in onboarding
  int _currentPage = 0;

  // Page controller
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _conditionController.dispose();
    _medicationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            _buildWelcomePage(),
            _buildUserInfoPage(),
            _buildMedicationPage(),
            _buildCompletionPage(),
          ],
        ),
      ),
    );
  }

  // Welcome page
  Widget _buildWelcomePage() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo/icon
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(Icons.health_and_safety, size: 80, color: Colors.white),
          ),
          SizedBox(height: 40),

          // Welcome text
          Text(
            'Welcome to MyMedBuddy',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          Text(
            'Your personal health and medication manager',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60),

          // Get started button
          CustomButton(
            text: 'Get Started',
            onPressed: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  // User information page
  Widget _buildUserInfoPage() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            SizedBox(height: 30),

            Text(
              'Tell us about yourself',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 30),

            // Name field
            CustomTextField(
              controller: _nameController,
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Age field
            CustomTextField(
              controller: _ageController,
              labelText: 'Age',
              hintText: 'Enter your age',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your age';
                }
                if (int.tryParse(value) == null || int.parse(value) < 1) {
                  return 'Please enter a valid age';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Condition field
            CustomTextField(
              controller: _conditionController,
              labelText: 'Medical Condition (Optional)',
              hintText: 'e.g., Diabetes, Hypertension',
              maxLines: 2,
            ),

            Spacer(),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Back',
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    isSecondary: true,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Next',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Medication page
  Widget _buildMedicationPage() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          SizedBox(height: 30),

          Text(
            'Add your medications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 30),

          // Medication input
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _medicationController,
                  labelText: 'Medication Name',
                  hintText: 'e.g., Aspirin 100mg',
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                onPressed: _addMedication,
                icon: Icon(
                  Icons.add_circle,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Medications list
          Expanded(
            child: _medications.isEmpty
                ? Center(
                    child: Text(
                      'No medications added yet\nTap + to add medications',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _medications.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.medication,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(_medications[index]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeMedication(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Back',
                  onPressed: () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  isSecondary: true,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Next',
                  onPressed: () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Completion page
  Widget _buildCompletionPage() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success icon
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(Icons.check, size: 60, color: Colors.white),
          ),
          SizedBox(height: 40),

          Text(
            'Setup Complete!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          Text(
            'Your profile has been created successfully. You can now start managing your health and medications.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60),

          // Complete setup button
          CustomButton(
            text: _isLoading ? 'Setting up...' : 'Complete Setup',
            onPressed: _isLoading ? null : _completeOnboarding,
          ),
        ],
      ),
    );
  }

  // Progress indicator
  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            decoration: BoxDecoration(
              color: index <= _currentPage
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  // Add medication to list
  void _addMedication() {
    if (_medicationController.text.isNotEmpty) {
      setState(() {
        _medications.add(_medicationController.text);
        _medicationController.clear();
      });
    }
  }

  // Remove medication from list
  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  // Complete onboarding process
  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save user data using Provider
      await Provider.of<UserProvider>(context, listen: false).saveUserData(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        condition: _conditionController.text,
        medications: _medications,
      );

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing setup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
