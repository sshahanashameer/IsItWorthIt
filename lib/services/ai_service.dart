import 'dart:math';
import 'gemini_service.dart';

class AIService {
  // Toggle to use Gemini (set to true when you have API key)
  static const bool USE_GEMINI = true; // Change to true after adding API key

  // Main analysis method - routes to Gemini or fallback
  static Future<Map<String, dynamic>> analyzeEvent({
    required String eventName,
    required String description,
    required String organizer,
    required String organizerType,
    required int duration,
  }) async {
    if (USE_GEMINI) {
      // Use Gemini AI
      return await GeminiService.analyzeEventWithGemini(
        eventName: eventName,
        description: description,
        organizer: organizer,
        organizerType: organizerType,
        duration: duration,
      );
    } else {
      // Use rule-based analysis
      return await _ruleBasedAnalysis(
        eventName: eventName,
        description: description,
        organizer: organizer,
        organizerType: organizerType,
        duration: duration,
      );
    }
  }

  static Future<String> generateLinkedInPost({
    required String eventName,
    required String reflection,
    required String takeaways,
    String? networking,
    bool? certificateReceived,
    String? projectOutput,
  }) async {
    if (USE_GEMINI) {
      // Use Gemini for post generation
      return await GeminiService.generateLinkedInPost(
        eventName: eventName,
        reflection: reflection,
        takeaways: takeaways,
        networking: networking,
        certificateReceived: certificateReceived,
        projectOutput: projectOutput,
      );
    } else {
      // Use template-based generation
      return _generateTemplatePost(
        eventName: eventName,
        reflection: reflection,
        takeaways: takeaways,
        networking: networking,
        certificateReceived: certificateReceived,
        projectOutput: projectOutput,
      );
    }
  }

  // Rule-based analysis (your existing logic)
  static Future<Map<String, dynamic>> _ruleBasedAnalysis({
    required String eventName,
    required String description,
    required String organizer,
    required String organizerType,
    required int duration,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final keywords = _extractKeywords(description);
    final sector = _determineSector(keywords, description);
    final skills = _extractSkills(keywords, description);

    final worthItScore = _calculateWorthItScore(
      description: description,
      organizer: organizer,
      organizerType: organizerType,
      duration: duration,
      sector: sector,
    );

    final verdict = _determineVerdict(worthItScore);

    return {
      'sector': sector,
      'verdict': verdict,
      'worthItScore': worthItScore,
      'skills': skills,
      'portfolioImpact': _generatePortfolioImpact(worthItScore),
      'internshipAlignment': _generateInternshipAlignment(sector, skills),
      'odHourAnalysis': _generateODHourAnalysis(duration, worthItScore),
      'missingInfo': _generateMissingInfo(),
      'aiSummary': _generateAISummary(eventName, sector, verdict, worthItScore),
    };
  }

  static String _generateTemplatePost({
    required String eventName,
    required String reflection,
    required String takeaways,
    String? networking,
    bool? certificateReceived,
    String? projectOutput,
  }) {
    final hasProject = projectOutput != null && projectOutput.isNotEmpty;
    final hasCertificate = certificateReceived ?? false;
    final hasNetworking = networking != null && networking.isNotEmpty;

    String post = 'Thrilled to share my experience at $eventName! 🚀\n\n';

    if (reflection.isNotEmpty) {
      post += '${_capitalizeFirst(reflection)}\n\n';
    }

    if (takeaways.isNotEmpty) {
      post += 'Key takeaways:\n';
      final takeawayList =
          takeaways.split('\n').where((t) => t.trim().isNotEmpty);
      for (var takeaway in takeawayList) {
        post += '• ${_capitalizeFirst(takeaway.trim())}\n';
      }
      post += '\n';
    }

    if (hasProject) {
      post += 'Proud to have built: $projectOutput\n\n';
    }

    if (hasNetworking) {
      post += 'Great connecting with amazing people in the tech community!\n\n';
    }

    if (hasCertificate) {
      post +=
          'Grateful for the recognition and certificate of participation.\n\n';
    }

    post += 'Excited to apply these learnings in future projects! 💡\n\n';
    post += '#TechEvents #Learning #Growth #Innovation';

    return post;
  }

  // All your existing helper methods below...
  static List<String> _extractKeywords(String text) {
    final techKeywords = [
      'AI',
      'ML',
      'machine learning',
      'artificial intelligence',
      'web',
      'react',
      'frontend',
      'backend',
      'fullstack',
      'mobile',
      'flutter',
      'android',
      'iOS',
      'blockchain',
      'web3',
      'crypto',
      'data',
      'analytics',
      'python',
      'java',
      'cloud',
      'AWS',
      'Azure',
      'DevOps',
      'cybersecurity',
      'security',
      'ethical hacking',
      'IoT',
      'embedded',
      'robotics',
      'UI/UX',
      'design',
      'figma',
      'hackathon',
      'workshop',
      'seminar',
      'conference',
    ];

    return techKeywords
        .where((keyword) => text.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  static String _determineSector(List<String> keywords, String description) {
    final sectorMap = {
      'AI/ML': [
        'ai',
        'ml',
        'machine learning',
        'artificial intelligence',
        'deep learning'
      ],
      'Web Development': [
        'web',
        'react',
        'frontend',
        'backend',
        'fullstack',
        'javascript'
      ],
      'Mobile Development': [
        'mobile',
        'flutter',
        'android',
        'ios',
        'react native'
      ],
      'Blockchain': ['blockchain', 'web3', 'crypto', 'ethereum', 'solidity'],
      'Data Science': [
        'data',
        'analytics',
        'python',
        'visualization',
        'statistics'
      ],
      'Cloud & DevOps': [
        'cloud',
        'aws',
        'azure',
        'devops',
        'kubernetes',
        'docker'
      ],
      'Cybersecurity': [
        'cybersecurity',
        'security',
        'ethical hacking',
        'penetration'
      ],
      'IoT & Robotics': [
        'iot',
        'embedded',
        'robotics',
        'arduino',
        'raspberry pi'
      ],
      'UI/UX Design': ['ui', 'ux', 'design', 'figma', 'user experience'],
    };

    for (var entry in sectorMap.entries) {
      if (entry.value
          .any((term) => keywords.any((k) => k.toLowerCase().contains(term)))) {
        return entry.key;
      }
    }

    return 'General Technology';
  }

  static List<String> _extractSkills(
      List<String> keywords, String description) {
    final skillMap = {
      'Python': ['python'],
      'JavaScript': ['javascript', 'js'],
      'React': ['react'],
      'Flutter': ['flutter'],
      'Machine Learning': ['ml', 'machine learning'],
      'TensorFlow': ['tensorflow'],
      'Node.js': ['node', 'nodejs'],
      'Docker': ['docker'],
      'AWS': ['aws'],
      'Git': ['git', 'github'],
    };

    final extractedSkills = <String>[];
    for (var entry in skillMap.entries) {
      if (entry.value.any((term) => description.toLowerCase().contains(term))) {
        extractedSkills.add(entry.key);
      }
    }

    return extractedSkills.isEmpty
        ? ['Problem Solving', 'Teamwork']
        : extractedSkills;
  }

  static int _calculateWorthItScore({
    required String description,
    required String organizer,
    required String organizerType,
    required int duration,
    required String sector,
  }) {
    int score = 50;

    if (organizerType == 'Company') {
      score += 20;
    } else if (organizerType == 'College Club') {
      score += 10;
    } else {
      score += 15;
    }

    if (duration <= 4) {
      score += 10;
    } else if (duration <= 8) {
      score += 15;
    } else if (duration > 24) {
      score -= 10;
    }

    final valuableKeywords = [
      'prize',
      'award',
      'certificate',
      'internship',
      'opportunity',
      'network',
      'sponsor',
      'swag'
    ];
    for (var keyword in valuableKeywords) {
      if (description.toLowerCase().contains(keyword)) {
        score += 5;
      }
    }

    if (['AI/ML', 'Web Development', 'Blockchain'].contains(sector)) {
      score += 10;
    }

    return min(100, max(0, score));
  }

  static String _determineVerdict(int score) {
    if (score >= 80) return 'Worth It!';
    if (score >= 60) return 'Probably Worth It';
    if (score >= 40) return 'Maybe';
    return 'Skip';
  }

  static Map<String, dynamic> _generatePortfolioImpact(int score) {
    if (score >= 80) {
      return {
        'level': 'Strong',
        'resumePlacement': 'Featured Projects',
        'signalStrength': 'High',
        'longevity': 'Showcase-worthy',
      };
    } else if (score >= 60) {
      return {
        'level': 'Moderate',
        'resumePlacement': 'Projects Section',
        'signalStrength': 'Medium',
        'longevity': 'Short-term value',
      };
    } else {
      return {
        'level': 'Weak',
        'resumePlacement': 'Optional mention',
        'signalStrength': 'Low',
        'longevity': 'Minimal impact',
      };
    }
  }

  static Map<String, dynamic> _generateInternshipAlignment(
      String sector, List<String> skills) {
    final relevanceScore = min(10, 7 + (skills.length * 0.5).round());
    return {
      'relevanceScore': relevanceScore,
      'targetRole': _suggestTargetRole(sector),
      'networkPotential': relevanceScore >= 8 ? 'High' : 'Medium',
    };
  }

  static String _suggestTargetRole(String sector) {
    final roleMap = {
      'AI/ML': 'ML Engineer / AI Research Intern',
      'Web Development': 'Frontend Developer / Full Stack Engineer',
      'Mobile Development': 'Mobile App Developer',
      'Blockchain': 'Blockchain Developer',
      'Data Science': 'Data Analyst / Data Scientist',
      'Cloud & DevOps': 'Cloud Engineer / DevOps Intern',
      'Cybersecurity': 'Security Analyst',
      'IoT & Robotics': 'IoT Developer / Robotics Engineer',
      'UI/UX Design': 'UI/UX Designer',
    };
    return roleMap[sector] ?? 'Software Engineer';
  }

  static Map<String, dynamic> _generateODHourAnalysis(int duration, int score) {
    final costBenefitRatio = (score / (duration * 10)).toStringAsFixed(1);
    final quality = double.parse(costBenefitRatio) >= 1.5
        ? 'Excellent'
        : double.parse(costBenefitRatio) >= 1.0
            ? 'Good'
            : 'Fair';

    return {
      'hoursRequired': duration,
      'remainingAfter': 40 - duration,
      'costBenefitRatio': '$costBenefitRatio ($quality)',
    };
  }

  static List<Map<String, String>> _generateMissingInfo() {
    final questions = [
      'Will certificates be provided to all participants or only winners?',
      'What is the expected tangible output (project, certificate, etc.)?',
      'Are there opportunities for direct interaction with sponsors?',
    ];

    questions.shuffle();
    return questions.take(2).map((q) => {'question': q}).toList();
  }

  static String _generateAISummary(
      String eventName, String sector, String verdict, int score) {
    return 'Based on AI analysis, $eventName in the $sector sector has a worth-it score of $score/100. '
        'Verdict: $verdict. This assessment considers factors like organizer reputation, skill development '
        'potential, networking opportunities, and OD hour efficiency.';
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
