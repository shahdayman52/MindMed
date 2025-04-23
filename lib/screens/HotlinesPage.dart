import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HotlinesPage extends StatelessWidget {
  const HotlinesPage({super.key});

void _launchPhone(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);

    // 🐞 Debug print to check if the number is being passed correctly
    print("Trying to launch: $url"); // Should print something like tel:7621602

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("❌ Could not launch $number");
    }
  }

  void _launchWebsite(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint("❌ Could not launch website $urlStr");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            children: [
              /// Header: Back + Title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.brown),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      'Mental Health Hotlines',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            
              const SizedBox(height: 12),
            
              /// Hotline Cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildHotlineCard(
                      emoji: "🇪🇬",
                      title: "National Mental Health Services",
                      description: "Free and confidential mental health support, available 24/7.",
                      hotline: "16328",
                      onCall: () => _launchPhone("16328"),
                    ),
                    _buildHotlineCard(
                      emoji: "🚑",
                      title: "Emergency Medical Services",
                      description: "Immediate help for medical emergencies, including mental health crises.",
                      hotline: "123",
                      onCall: () => _launchPhone("123"),
                    ),
                    _buildHotlineCard(
                      emoji: "🧠",
                      title: "Befrienders Cairo",
                      description:
                          "Confidential, non-judgmental listening service.\nHotlines: 7621602, 7621603, 7622381\nAddress: 61 Al Zahara St, Mohandessin, Cairo\nWebsite: befrienderscairo.com",
                      hotline: "7621602",
                      onCall: () => _launchPhone("7621602"),
                    ),
            
                    /// 🌐 Website Support Card
                    _buildWebsiteCard(
                      emoji: "💻",
                      title: "National Mental Health Platform",
                      description:
                          "Online counseling and psychoeducational support provided by the Ministry of Health.",
                      url: "https://mohp.gov.eg",
                    ),
            
                    const SizedBox(height: 24),
                    const Text(
                      "🧡 Reaching out is a sign of strength.\nIf you're in immediate danger, please call 123.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotlineCard({
    required String emoji,
    required String title,
    required String description,
    required String hotline,
    required VoidCallback onCall,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(121, 0, 0, 0),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$emoji $title",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.green, size: 20),
              const SizedBox(width: 6),
              Text("Hotline: $hotline", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.call, color: Colors.brown),
                onPressed: onCall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteCard({
    required String emoji,
    required String title,
    required String description,
    required String url,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$emoji $title",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.language, color: Colors.blue, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text("Website: mohp.gov.eg",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_browser, color: Colors.brown),
                onPressed: () => _launchWebsite(url),
              ),
            ],
          ),
        ],
      ),
    );
  }
}