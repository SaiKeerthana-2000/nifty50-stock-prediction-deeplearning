import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'prediction_screen.dart';
import 'welcome_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<dynamic> sections = [];
  Map<int, bool> expandedSections = {};

  @override
  void initState() {
    super.initState();
    loadContent();
  }

  Future<void> loadContent() async {
    try {
      String jsonString = await rootBundle.loadString('assets/content.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        sections = jsonData['learning_sections'] ?? [];
        expandedSections = {for (int i = 0; i < sections.length; i++) i: false};
      });
    } catch (e) {
      debugPrint("❌ Error loading JSON: $e");
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService().logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('👋 You have been logged out!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      debugPrint("⚠️ Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );
          },
          tooltip: 'Go to Welcome Screen',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const FlexibleSpaceBar(
          background: Image(
            image: AssetImage('assets/background9.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image for the body (same as the AppBar background)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background9.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                // 🌟 Tap to View Prediction Button moved to top of body
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical:
                        1, // Reduced vertical space to bring it closer to the top
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PredictionScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.trending_up, size: 28),
                        label: const Text(
                          "Tap to View Nifty 50 Predictions",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                      ),
                      const SizedBox(height: 8), // Reduced space
                    ],
                  ),
                ),
                // 📚 Learning Hub Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "📚 Learning Hub",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // 📚 Learning Sections
                sections.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sections.length,
                        itemBuilder: (context, index) {
                          final section = sections[index];
                          final String title = section['title'] ?? 'No Title';
                          final String description =
                              section['description'] ?? 'No Description';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                title,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 18,
                                ),
                              ),
                              initiallyExpanded:
                                  expandedSections[index] ?? false,
                              onExpansionChanged: (bool expanded) {
                                setState(() {
                                  expandedSections[index] = expanded;
                                });
                              },
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 16),
                                  ),
                                ),
                                // 📌 Glossary Terms (Tap to View)
                                if ((section['terms'] as List<dynamic>?)
                                        ?.isNotEmpty ??
                                    false)
                                  _buildGlossaryTerms(section['terms'] ?? []),

                                // 📌 Subsections (Tap to View)
                                if ((section['subsections'] as List<dynamic>?)
                                        ?.isNotEmpty ??
                                    false)
                                  _buildSubsections(
                                    section['subsections'] ?? [],
                                  ),

                                // 📌 Nifty 50 Sectors (Tap to View)
                                if ((section['sectors']
                                            as Map<String, dynamic>?)
                                        ?.isNotEmpty ??
                                    false)
                                  _buildNiftySectors(section['sectors'] ?? {}),

                                // 📌 Useful Resources (Tap to View)
                                if ((section['resources'] as List<dynamic>?)
                                        ?.isNotEmpty ??
                                    false)
                                  _buildUsefulResources(
                                    section['resources'] ?? [],
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📚 Build Glossary Terms
  Widget _buildGlossaryTerms(List<dynamic> terms) {
    return Column(
      children:
          terms.map((term) {
            return ExpansionTile(
              title: Text(
                term['term'] ?? 'No Term',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(term['definition'] ?? 'No Definition'),
                ),
              ],
            );
          }).toList(),
    );
  }

  // 📚 Build Subsections
  Widget _buildSubsections(List<dynamic> subsections) {
    return Column(
      children:
          subsections.map((subsection) {
            return ExpansionTile(
              title: Text(
                subsection['title'] ?? 'No Title',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(subsection['description'] ?? 'No Description'),
                ),
              ],
            );
          }).toList(),
    );
  }

  // 📊 Build Nifty 50 Sectors
  Widget _buildNiftySectors(Map<String, dynamic> sectors) {
    return Column(
      children:
          sectors.entries.map((entry) {
            final sector = entry.key;
            final companies = entry.value as List<dynamic>? ?? [];

            return ExpansionTile(
              title: Text(
                sector,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children:
                  companies.map((company) {
                    return ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(company),
                    );
                  }).toList(),
            );
          }).toList(),
    );
  }

  // 🌐 Build Useful Resources
  Widget _buildUsefulResources(List<dynamic> resources) {
    return Column(
      children:
          resources.map((resource) {
            final links = resource['links'] as List<dynamic>? ?? [];
            return ExpansionTile(
              title: Text(resource['title'] ?? 'No Title'),
              children:
                  links.map((link) {
                    return ListTile(
                      leading: const Icon(Icons.link),
                      title: InkWell(
                        onTap: () => _launchURL(link['url'] ?? ''),
                        child: Text(
                          link['name'] ?? 'No Name',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    );
                  }).toList(),
            );
          }).toList(),
    );
  }
}
