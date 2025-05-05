// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encrypted_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EncryptedPayload _$EncryptedPayloadFromJson(Map<String, dynamic> json) =>
    EncryptedPayload(
      algo: json['algo'] as String,
      data: json['data'] as String,
    );

Map<String, dynamic> _$EncryptedPayloadToJson(EncryptedPayload instance) =>
    <String, dynamic>{'algo': instance.algo, 'data': instance.data};
