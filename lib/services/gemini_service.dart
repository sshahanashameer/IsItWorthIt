import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class GeminiService {
  // Get your FREE API key from: https://makersuite.google.com/app/apikey
  // For demo, using a placeholder - REPLACE WITH YOUR KEY
  static const String _apiKey = 'AIzaSyDGpypiGJjZOWTZC9zJ2ENHZKU6yN7G7og';

  static GenerativeModel? _model;

  static GenerativeModel get model {
    _model ??= GenerativeModel(
      model: 'gemini-1.5-flash', // Free tier model
      apiKey: _apiKey,
    );
    return _model!;
  }

  // Analyze event with Gemini AI
  static Future<Map<String, dynamic>> analyzeEventWithGemini({
    required String eventName,
    required String description,
    required String organizer,
    required String organizerType,
    required int duration,
  }) async {
    try {
      final prompt = '''
You are an expert career advisor for engineering students. Analyze this event and provide structured output in JSON format.

Event Details:
- Name: $eventName
- Description: $description
- Organizer: $organizer ($organizerType)
- Duration: $duration hours

Analyze and return a JSON object with these exact fields:
{
  "sector": "string (e.g., AI/ML, Web Development, Mobile, etc.)",
  "verdict": "string (one of: Worth It!, Probably Worth It, Maybe, Skip)",
  "worthItScore": number (0-100),
  "skills": ["skill1", "skill2", "skill3"],
  "portfolioImpact": {
    "level": "string (Strong/Moderate/Weak)",
    "resumePlacement": "string",
    "signalStrength": "string (High/Medium/Low)",
    "longevity": "string"
  },
  "internshipAlignment": {
    "relevanceScore": number (0-10),
    "targetRole": "string",
    "networkPotential": "string (High/Medium/Low)"
  },
  "odHourAnalysis": {
    "hoursRequired": number,
    "remainingAfter": number,
    "costBenefitRatio": "string (with quality assessment)"
  },
  "missingInfo": [
    {"question": "string"}
  ],
  "aiSummary": "string (2-3 sentences explaining the verdict)"
}

Important: Return ONLY the JSON object, no markdown formatting, no explanations.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text == null) {
        throw Exception('No response from Gemini');
      }

      // Parse the JSON response
      String jsonText = response.text!.trim();

      // Remove markdown code blocks if present
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }

      final analysisData = json.decode(jsonText.trim());

      return analysisData;
    } catch (e) {
      print('Gemini API Error: $e');
      // Fallback to rule-based analysis if API fails
      return _fallbackAnalysis(
        eventName: eventName,
        description: description,
        organizerType: organizerType,
        duration: duration,
      );
    }
  }

  // Generate LinkedIn post with Gemini
  static Future<String> generateLinkedInPost({
    required String eventName,
    required String reflection,
    required String takeaways,
    String? networking,
    bool? certificateReceived,
    String? projectOutput,
  }) async {
    try {
      final prompt = '''
Write a professional LinkedIn post about attending "$eventName".

Details:
- Reflection: $reflection
- Key Takeaways: $takeaways
${networking != null ? '- Networking: $networking' : ''}
${certificateReceived == true ? '- Received Certificate: Yes' : ''}
${projectOutput != null ? '- Project Created: $projectOutput' : ''}

Requirements:
1. Start with an engaging hook
2. Be concise (150-250 words)
3. Use 2-3 relevant hashtags
4. Sound authentic and professional
5. Highlight learnings and growth
6. Use emojis sparingly (1-2 max)

Return only the post text, no explanations.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ??
          _generateFallbackPost(
            eventName: eventName,
            reflection: reflection,
            takeaways: takeaways,
          );
    } catch (e) {
      print('Gemini API Error: $e');
      return _generateFallbackPost(
        eventName: eventName,
        reflection: reflection,
        takeaways: takeaways,
      );
    }
  }

  // Fallback analysis if Gemini fails
  static Map<String, dynamic> _fallbackAnalysis({
    required String eventName,
    required String description,
    required String organizerType,
    required int duration,
  }) {
    int score = 60;
    if (organizerType == 'Company') score += 15;
    if (duration <= 8) score += 10;

    return {
      'sector': 'General Technology',
      'verdict': score >= 70 ? 'Worth It!' : 'Maybe',
      'worthItScore': score,
      'skills': ['Problem Solving', 'Teamwork'],
      'portfolioImpact': {
        'level': 'Moderate',
        'resumePlacement': 'Projects Section',
        'signalStrength': 'Medium',
        'longevity': 'Short-term value',
      },
      'internshipAlignment': {
        'relevanceScore': 7,
        'targetRole': 'Software Engineer',
        'networkPotential': 'Medium',
      },
      'odHourAnalysis': {
        'hoursRequired': duration,
        'remainingAfter': 40 - duration,
        'costBenefitRatio': '${(score / duration).toStringAsFixed(1)} (Good)',
      },
      'missingInfo': [
        {'question': 'What are the expected outcomes?'},
        {'question': 'Will certificates be provided?'},
      ],
      'aiSummary':
          '$eventName has a worth-it score of $score/100. Consider attending based on your current goals.',
    };
  }

  static String _generateFallbackPost({
    required String eventName,
    required String reflection,
    required String takeaways,
  }) {
    return '''Excited to share my experience at $eventName! 🚀

$reflection

Key takeaways:
${takeaways.split('\n').map((t) => '• ${t.trim()}').join('\n')}

Looking forward to applying these insights in future projects!

#TechEvents #Learning #Growth''';
  }
}
