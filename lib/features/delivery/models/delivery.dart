class DeliveryAgent {
  final int id;
  final String name;
  final String? phone;
  final String status;

  const DeliveryAgent({required this.id, required this.name, this.phone, required this.status});

  factory DeliveryAgent.fromJson(Map<String, dynamic> json) => DeliveryAgent(
        id: json['id'] as int,
        name: json['name'] as String? ?? 'Agent',
        phone: json['phone'] as String?,
        status: json['status'] as String? ?? 'offline',
      );
}

class DeliveryProviderInfo {
  final String provider;
  final bool configured;
  final String? reason;

  const DeliveryProviderInfo({required this.provider, required this.configured, this.reason});

  factory DeliveryProviderInfo.fromJson(Map<String, dynamic> json) => DeliveryProviderInfo(
        provider: json['provider'] as String? ?? 'unknown',
        configured: json['configured'] as bool? ?? false,
        reason: json['reason'] as String?,
      );
}

class DeliveryJob {
  final int id;
  final int orderId;
  final String provider;
  final String status;
  final int? agentId;
  final int? etaMinutes;
  final String? trackingUrl;

  const DeliveryJob({
    required this.id,
    required this.orderId,
    required this.provider,
    required this.status,
    this.agentId,
    this.etaMinutes,
    this.trackingUrl,
  });

  factory DeliveryJob.fromJson(Map<String, dynamic> json) => DeliveryJob(
        id: json['id'] as int,
        orderId: json['order_id'] as int,
        provider: json['provider'] as String? ?? 'own_agent',
        status: json['status'] as String? ?? 'created',
        agentId: json['agent_id'] as int?,
        etaMinutes: json['eta_minutes'] as int?,
        trackingUrl: json['tracking_url'] as String?,
      );
}
