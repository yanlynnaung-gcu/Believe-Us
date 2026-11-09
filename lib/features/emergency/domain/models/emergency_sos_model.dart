class EmergencySOSModel {
  final String alertId;
  final String senderId;
  final String senderName;
  final String? partnerId;
  final String? partnerName;
  final String coupleSpaceId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String message;
  final String address;
  final String status;
  final bool isSender;

  const EmergencySOSModel({
    required this.alertId,
    required this.senderId,
    required this.senderName,
    this.partnerId,
    this.partnerName,
    required this.coupleSpaceId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.message,
    required this.address,
    this.status = 'ACTIVE_EMERGENCY',
    this.isSender = false,
  });

  factory EmergencySOSModel.fromJson(Map<String, dynamic> json, {bool isSender = false}) {
    DateTime parsedTime;
    final rawTimestamp = json['timestamp'];
    if (rawTimestamp is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else if (rawTimestamp is String) {
      parsedTime = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    return EmergencySOSModel(
      alertId: json['alertId']?.toString() ?? 'sos_${DateTime.now().millisecondsSinceEpoch}',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? 'Partner',
      partnerId: json['partnerId']?.toString(),
      partnerName: json['partnerName']?.toString(),
      coupleSpaceId: json['coupleSpaceId']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: parsedTime,
      message: json['message']?.toString() ?? '🚨 EMERGENCY SOS Triggered!',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'ACTIVE_EMERGENCY',
      isSender: isSender,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alertId': alertId,
      'senderId': senderId,
      'senderName': senderName,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'coupleSpaceId': coupleSpaceId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'message': message,
      'address': address,
      'status': status,
    };
  }
}

/// Type alias for hybrid real-time MQTT payload
typedef EmergencySOSAlert = EmergencySOSModel;
