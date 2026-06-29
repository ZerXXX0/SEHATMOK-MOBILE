import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../config/app_config.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../home/screens/home_screen.dart';
import 'login_screen.dart';

class OnboardingData {
  final String title;
  final String description;
  final String imageUrl;
  final String primaryButtonText;
  final IconData? icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.primaryButtonText,
    this.icon,
  });
}

class WelcomeScreen extends StatefulWidget {
  final bool isAlreadyLoggedIn;

  const WelcomeScreen({Key? key, this.isAlreadyLoggedIn = false}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Future<User>? _profileFuture;
  late String _currentTip;

  final List<String> _healthyTips = [
    'Drinking water before meals can help support digestion.',
    'Adding colorful veggies to your plate ensures a rich intake of vitamins!',
    'Planning meals in advance reduces stress and helps you make healthier choices.',
    'Check your Smart Fridge to see if any ingredients are close to expiration.',
    'Try to take a short walk after your meals to assist in blood sugar regulation.',
    'A handful of nuts makes for a great, fiber-rich mid-day energy boost!',
    'Consistent sleep is just as important for health as a nutritious diet.',
  ];

  @override
  void initState() {
    super.initState();
    _currentTip = _healthyTips[DateTime.now().microsecond % _healthyTips.length];
    if (widget.isAlreadyLoggedIn) {
      final currentUser = context.read<AuthService>().currentUser;
      if (currentUser != null) {
        _profileFuture = Future.value(currentUser);
      } else {
        _profileFuture = context.read<AuthService>().getCurrentUser().catchError((e) {
          return User(
            id: '',
            email: '',
            name: 'Healthy User',
          );
        });
      }
    }
  }

  final List<OnboardingData> _slides = [
    OnboardingData(
      title: 'Track Your Vitality',
      description: 'Log your meals effortlessly and monitor your nutrition with smart, real-time progress trackers.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBllXBpQrqkmNnJj34J7lNBU_zsP2S_--YwhUcyOQ4JUSC6Zt0lL1sXPS2WUwfvILMZzAPo-SRk2aKSy-WDCLYbmT_pvCqwIyrtTVZtw9AL4gMrII68zVmg19jOtfajJ_lMvEuBbo1H6u0wgbb1ZfTNtNLPS0nlbfLNyDWtcNtVl9F8cy6-9dhOsK0hO07Ez8eBO3_homMmlJMHyahmowYWCQAmeyBWYDTNZjehDZOubQA3MxCGSxSpOoDkEQ-detaoW--6EzzSjT4',
      primaryButtonText: 'Next',
      icon: Icons.arrow_forward,
    ),
    OnboardingData(
      title: 'Smart Fridge Manager',
      description: 'Reduce food waste by keeping a digital inventory of your ingredients and tracking their freshness.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDBpXKcO3KSM2sXJR3e-519z81ojnQ-yiLvFtVYY40dUoSsAGVD9NlkMveoNfs6dljvpfvc4VJhP8ZABgAZtLSYlXZJMVCfA7vN_hYs9TyDDQB4OeW_EWoVGG1C2ilIXzBopRUMCUFz_4l3cMl5RAzfJPQZ7OsYYJHeAj4aEOpViT1boEzPXsje6qQnBRgDesqjLKX_CnmsYa_xCv1wdDGvFAch2Kpdpn_EO8HE6-qb6PpNRvw9cht3cpfKBWEuWlVmwyXlkyoBaE8',
      primaryButtonText: 'Next',
      icon: Icons.arrow_forward,
    ),
    OnboardingData(
      title: 'AI Chef at Your Service',
      description: 'Get personalized recipe recommendations based on what you already have in your kitchen.',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD5gXabLseqH3tnGfA48_tJQmfBcuuHNP35MW2HA0xoRShp2wkaOtUemyuMteKpQtpgvbtY4tle5RNg6562u1jgpH66ujIFi9q8yA1RO8R32AczL_ztBsWIrWjIqty12T-dADUvyHAS7uUNhis-vLHVBE1M8h1OacgGFk_QHJKg-pAy8K67FQiuNFd3-2J2z7whhbYEml2MqyknmvFXT0rwB9ZGfmlWNskL27iSN2xy4MyXp6KV5utUkvDDDsn5OqwmpTMTvol3mPU',
      primaryButtonText: 'Get Started',
      icon: null,
    ),
  ];

  Future<void> _completeOnboarding() async {
    await StorageService.instance.setAppPreference('has_seen_onboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _onNextPressed() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Exact colors from HTML reference design
    const Color primaryColor = Color(0xFF006948);
    const Color backgroundColor = Color(0xFFF8F9FA);
    const Color onSurfaceColor = Color(0xFF191C1D);
    const Color onSurfaceVariantColor = Color(0xFF3D4A42);
    const Color outlineVariantColor = Color(0xFFBCCAC0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: widget.isAlreadyLoggedIn
            ? _buildAfterLoginScenario(primaryColor, backgroundColor, onSurfaceColor, onSurfaceVariantColor, outlineVariantColor)
            : _buildBeforeLoginScenario(primaryColor, backgroundColor, onSurfaceColor, onSurfaceVariantColor, outlineVariantColor),
      ),
    );
  }

  Widget _buildBeforeLoginScenario(
    Color primaryColor,
    Color backgroundColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    Color outlineVariantColor,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/sehatmok-logo-landscape.png',
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Row(
                    children: [
                      Icon(Icons.spa, color: primaryColor, size: 24),
                      const SizedBox(width: 4),
                      Text(
                        'SehatMok',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Manrope',
                            ),
                      ),
                    ],
                  );
                },
              ),
              TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: onSurfaceVariantColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withOpacity(0.06),
                          ),
                        ),
                        CachedNetworkImage(
                          imageUrl: slide.imageUrl,
                          height: 280,
                          width: 280,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => SizedBox(
                            height: 280,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 280,
                            width: 280,
                            decoration: BoxDecoration(
                              color: outlineVariantColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.image_not_supported, size: 64, color: onSurfaceVariantColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      slide.title,
                      style: TextStyle(
                        color: onSurfaceColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Manrope',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      slide.description,
                      style: TextStyle(
                        color: onSurfaceVariantColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        fontFamily: 'Manrope',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? primaryColor : outlineVariantColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 32.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _slides[_currentPage].primaryButtonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      if (_slides[_currentPage].icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(_slides[_currentPage].icon, size: 20),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Already have an account? Log In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAfterLoginScenario(
    Color primaryColor,
    Color backgroundColor,
    Color onSurfaceColor,
    Color onSurfaceVariantColor,
    Color outlineVariantColor,
  ) {
    final hour = DateTime.now().hour;
    final String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }

    return FutureBuilder<User>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.name ?? 'Healthy User';
        
        String? avatarPath = user?.avatarUrl;
        String? fullAvatarUrl;
        if (avatarPath != null && avatarPath.isNotEmpty) {
          if (avatarPath.startsWith('http')) {
            fullAvatarUrl = avatarPath;
          } else {
            final base = AppConfig.apiBaseUrl.endsWith('/')
                ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
                : AppConfig.apiBaseUrl;
            final path = avatarPath.startsWith('/') ? avatarPath : '/$avatarPath';
            fullAvatarUrl = '$base$path';
          }
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/sehatmok-logo-landscape.png',
                    height: 28,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Row(
                        children: [
                          Icon(Icons.spa, color: primaryColor, size: 24),
                          const SizedBox(width: 4),
                          Text(
                            'SehatMok',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Manrope',
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                primaryColor.withOpacity(0.15),
                                primaryColor.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 64,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          backgroundImage: fullAvatarUrl != null
                              ? NetworkImage(fullAvatarUrl)
                              : null,
                          child: fullAvatarUrl == null
                              ? Icon(
                                  Icons.person_outline,
                                  size: 56,
                                  color: primaryColor,
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '$timeGreeting,',
                      style: TextStyle(
                        color: onSurfaceVariantColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$name!',
                      style: TextStyle(
                        color: onSurfaceColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Manrope',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: outlineVariantColor.withOpacity(0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'DAILY HEALTH TIP',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentTip,
                            style: TextStyle(
                              color: onSurfaceVariantColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              fontFamily: 'Manrope',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 48.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Go to Dashboard',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
