// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Model _$ModelFromJson(Map<String, dynamic> json) {
  return Model(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data']);
}

Map<String, dynamic> _$ModelToJson(Model instance) => <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data
    };

Article _$ArticleFromJson(Map<String, dynamic> json) {
  return Article(title: json['title'] as String);
}

Map<String, dynamic> _$ArticleToJson(Article instance) =>
    <String, dynamic>{'title': instance.title};
