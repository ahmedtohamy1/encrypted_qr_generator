import 'package:json_annotation/json_annotation.dart';

part 'encrypted_payload.g.dart';

@JsonSerializable()
class EncryptedPayload {
  final String algo;
  final String data;

  EncryptedPayload({required this.algo, required this.data});

  factory EncryptedPayload.fromJson(Map<String, dynamic> json) =>
      _$EncryptedPayloadFromJson(json);
  Map<String, dynamic> toJson() => _$EncryptedPayloadToJson(this);
}
