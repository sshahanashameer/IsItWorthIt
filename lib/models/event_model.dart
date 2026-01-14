class Event {
  final String id;
  final String name;
  final String description;
  final String organizer;
  final String organizerType;
  final int duration;
  final DateTime date;
  final DateTime time;

  // AI Analysis Results
  final String? sector;
  final String? verdict;
  final int? worthItScore;
  final Map<String, dynamic>? analysisData;

  // Post-Event Data
  final String? reflection;
  final String? takeaways;
  final String? networking;
  final bool? certificateReceived;
  final String? projectOutput;
  final String? linkedInPost;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.organizer,
    required this.organizerType,
    required this.duration,
    required this.date,
    required this.time,
    this.sector,
    this.verdict,
    this.worthItScore,
    this.analysisData,
    this.reflection,
    this.takeaways,
    this.networking,
    this.certificateReceived,
    this.projectOutput,
    this.linkedInPost,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'organizer': organizer,
      'organizerType': organizerType,
      'duration': duration,
      'date': date.toIso8601String(),
      'time': time.toIso8601String(),
      'sector': sector,
      'verdict': verdict,
      'worthItScore': worthItScore,
      'analysisData': analysisData,
      'reflection': reflection,
      'takeaways': takeaways,
      'networking': networking,
      'certificateReceived': certificateReceived,
      'projectOutput': projectOutput,
      'linkedInPost': linkedInPost,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      organizer: json['organizer'],
      organizerType: json['organizerType'],
      duration: json['duration'],
      date: DateTime.parse(json['date']),
      time: DateTime.parse(json['time']),
      sector: json['sector'],
      verdict: json['verdict'],
      worthItScore: json['worthItScore'],
      analysisData: json['analysisData'],
      reflection: json['reflection'],
      takeaways: json['takeaways'],
      networking: json['networking'],
      certificateReceived: json['certificateReceived'],
      projectOutput: json['projectOutput'],
      linkedInPost: json['linkedInPost'],
    );
  }

  Event copyWith({
    String? name,
    String? description,
    String? organizer,
    String? organizerType,
    int? duration,
    DateTime? date,
    DateTime? time,
    String? sector,
    String? verdict,
    int? worthItScore,
    Map<String, dynamic>? analysisData,
    String? reflection,
    String? takeaways,
    String? networking,
    bool? certificateReceived,
    String? projectOutput,
    String? linkedInPost,
  }) {
    return Event(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      organizer: organizer ?? this.organizer,
      organizerType: organizerType ?? this.organizerType,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      time: time ?? this.time,
      sector: sector ?? this.sector,
      verdict: verdict ?? this.verdict,
      worthItScore: worthItScore ?? this.worthItScore,
      analysisData: analysisData ?? this.analysisData,
      reflection: reflection ?? this.reflection,
      takeaways: takeaways ?? this.takeaways,
      networking: networking ?? this.networking,
      certificateReceived: certificateReceived ?? this.certificateReceived,
      projectOutput: projectOutput ?? this.projectOutput,
      linkedInPost: linkedInPost ?? this.linkedInPost,
    );
  }
}
