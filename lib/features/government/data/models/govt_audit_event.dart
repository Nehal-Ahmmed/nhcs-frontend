class GovtAuditEvent {
  final String id;
  final String action;
  final String target;
  final String description;
  final String timestamp;
  final String operator;
  final String status; // 'success', 'warning', 'info'

  const GovtAuditEvent({
    required this.id,
    required this.action,
    required this.target,
    required this.description,
    required this.timestamp,
    required this.operator,
    required this.status,
  });

  GovtAuditEvent copyWith({
    String? id,
    String? action,
    String? target,
    String? description,
    String? timestamp,
    String? operator,
    String? status,
  }) {
    return GovtAuditEvent(
      id: id ?? this.id,
      action: action ?? this.action,
      target: target ?? this.target,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      operator: operator ?? this.operator,
      status: status ?? this.status,
    );
  }
}
