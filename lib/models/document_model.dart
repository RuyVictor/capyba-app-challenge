import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String content;
  final Timestamp created_at;
 
  DocumentModel({
    required this.content,
    required this.created_at,
  });
 
  factory DocumentModel.fromJson(Map<String, dynamic> parsedJson){
    return DocumentModel(
        content: parsedJson['content'],
        created_at : parsedJson['created_at'],
    );
  }
}