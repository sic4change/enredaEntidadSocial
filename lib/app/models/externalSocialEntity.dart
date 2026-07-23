import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_empresas/app/models/scope.dart';
import 'package:enreda_empresas/app/models/size.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'addressUser.dart';

class ReferencePerson {
  ReferencePerson({required this.name, required this.phone});
  final String name;
  final String phone;

  factory ReferencePerson.fromMap(Map<String, dynamic> data) => ReferencePerson(
        name: data['name']?.toString() ?? '',
        phone: data['phone']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {'name': name, 'phone': phone};
}

class ExternalSocialEntity {
  ExternalSocialEntity({
    this.externalSocialEntityId,
    required this.associatedSocialEntityId, /// this is the social entity that the user is belonging"
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.country,
    this.countryName,
    this.province,
    this.provinceName,
    this.city,
    this.cityName,
    this.postalCode,
    this.website,
    this.scope,
    this.size,
    this.photo,
    this.types,
    this.actionScope,
    this.category,
    this.subCategory,
    this.entityPhone,
    this.entityMobilePhone,
    this.contactPhone,
    this.contactMobilePhone,
    this.phones,
    this.referencePeople,
    this.geographicZone,
    this.subGeographicZone,
    this.linkedin,
    this.twitter,
    this.otherSocialMedia,
    this.contactName,
    this.contactEmail,
    this.contactPosition,
    this.contactChoiceGrade,
    this.contactKOL,
    this.contactProject,
    this.signedAgreements,
    this.signedAgreementsDate,
    this.offeredServices,
    this.kolType,
    this.trust,
    required this.createdAt,
    required this.createdBy,
  });

  final String? externalSocialEntityId;
  final String associatedSocialEntityId;
  final String name;
  final String? email;
  final String? phone;
  final String? country;
  String? countryName;
  final String? province;
  String? provinceName;
  final String? city;
  String? cityName;
  final Address? address;
  final String? postalCode;
  final String? website;
  final Scope? scope;
  final SizeOrg? size;
  final String? photo;
  final List<String>? types;
  final List<String>? actionScope;
  final String? category;
  final String? subCategory;
  final String? entityPhone;
  final String? entityMobilePhone;
  final String? contactPhone;
  final String? contactMobilePhone;
  final List<String>? phones;
  final List<ReferencePerson>? referencePeople;
  final String? geographicZone;
  final String? subGeographicZone;
  final String? linkedin;
  final String? twitter;
  final String? otherSocialMedia;
  final String? contactName;
  final String? contactEmail;
  final String? contactPosition;
  final String? contactChoiceGrade;
  final String? contactKOL;
  final String? contactProject;
  final String? signedAgreements;
  final DateTime? signedAgreementsDate;
  final String? offeredServices;
  final String? kolType;
  final bool? trust;
  final DateTime createdAt;
  final String createdBy;


  factory ExternalSocialEntity.fromMap(Map<String, dynamic> data, String documentId) {

    Address? address;
    try{
      address = Address(
          country: data['address']['country'],
          province: data['address']['province'],
          city: data['address']['city'],
          postalCode: data['address']['postalCode']
      );
    } catch(e) {
      address = null;
    }


    final String name = data['name'];
    final String? externalSocialEntityId = data['externalSocialEntityId'];
    final String email = data['email']??"";

    String photo;
    try {
      photo = data['logoPic']['src'];
    } catch (e) {
      photo = '';
    }

    final String website = data['website']??"";

    final List<String> types = [];
    if (data['types'] != null) {
      data['types'].forEach((type) {types.add(type.toString());});
    }

    List<String> actionScope = [];
    final dynamic actionScopeData = data['actionScope'];
    if (actionScopeData is List) {
      actionScope = List<String>.from(actionScopeData.map((e) => e.toString()));
    } else if (actionScopeData is String) {
      actionScope = [];
    }

    final String category = data['category'] ?? '';
    final String subCategory = data['subCategory'] ?? '';
    final String entityPhone = data['entityPhone'] ?? '';
    final String entityMobilePhone = data['entityMobilePhone'] ?? '';
    final String contactPhone = data['contactPhone'] ?? '';
    final String contactMobilePhone = data['contactMobilePhone'] ?? '';
    final List<String> phones = [];
    if (data['phones'] != null) {
      data['phones'].forEach((p) {phones.add(p.toString());});
    }
    final List<ReferencePerson> referencePeople = [];
    if (data['referencePeople'] is List) {
      for (final p in data['referencePeople']) {
        if (p is Map) {
          referencePeople.add(ReferencePerson.fromMap(Map<String, dynamic>.from(p)));
        }
      }
    }
    final String geographicZone = data['geographicZone'] ?? '';
    final String subGeographicZone = data['subGeographicZone'] ?? '';
    final String linkedin = data['linkedin'] ?? '';
    final String twitter = data['twitter'] ?? '';
    final String otherSocialMedia = data['otherSocialMedia'] ?? '';
    final String contactName = data['contactName'] ?? '';
    final String contactEmail = data['contactEmail'] ?? '';
    final contactPosition = data['contactPosition'] ?? '';
    final contactChoiceGrade = data['contactChoiceGrade'] ?? '';
    final contactKOL = data['contactKOL'] ?? '';
    final contactProject = data['contactProject'] ?? '';
    final trust = data['trust'] ?? false;
    final String? country = data['address']['country'];
    final String? province = data['address']['province'];
    final String? city = data['address']['city'];
    final String signedAgreements = data['signedAgreements'] ?? '';
    DateTime? signedAgreementsDate;
    if (data['signedAgreementsDate'] != null) {
      if (data['signedAgreementsDate'] is Timestamp) {
        signedAgreementsDate = (data['signedAgreementsDate'] as Timestamp).toDate();
      } else if (data['signedAgreementsDate'] is String) {
        signedAgreementsDate = DateTime.tryParse(data['signedAgreementsDate']);
      }
    }
    final String offeredServices = data['offeredServices'] ?? '';
    final String kolType = data['kolType'] ?? '';
    final DateTime createdAt = data['createdAt'].toDate();
    final String associatedSocialEntityId = data['associatedSocialEntityId'] ?? '';
    final String createdBy = data['createdBy'];

    return ExternalSocialEntity(
        externalSocialEntityId: externalSocialEntityId,
        associatedSocialEntityId: associatedSocialEntityId,
        name: name,
        email: email,
        address: address,
        website: website,
        photo: photo,
        types: types,
        actionScope: actionScope,
        category: category,
        subCategory: subCategory,
        entityPhone: entityPhone,
        entityMobilePhone: entityMobilePhone,
        contactPhone: contactPhone,
        contactMobilePhone: contactMobilePhone,
        phones: phones,
        referencePeople: referencePeople,
        geographicZone: geographicZone,
        subGeographicZone: subGeographicZone,
        linkedin: linkedin,
        twitter: twitter,
        otherSocialMedia: otherSocialMedia,
        contactName: contactName,
        contactEmail: contactEmail,
        contactPosition: contactPosition,
        contactChoiceGrade: contactChoiceGrade,
        contactKOL: contactKOL,
        contactProject: contactProject,
        trust: trust,
        country: country,
        province: province,
        city: city,
        signedAgreements: signedAgreements,
        signedAgreementsDate: signedAgreementsDate,
        offeredServices: offeredServices,
        kolType: kolType,
        createdAt: createdAt,
        createdBy: createdBy
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'externalSocialEntityId': externalSocialEntityId,
      'associatedSocialEntityId': associatedSocialEntityId,
      'name': name,
      'email': email,
      'address': address?.toMap(),
      'website': website,
      'types': types,
      'actionScope': actionScope,
      'category' : category,
      'subCategory': subCategory,
      'entityPhone': entityPhone,
      'entityMobilePhone': entityMobilePhone,
      'contactPhone': contactPhone,
      'contactMobilePhone': contactMobilePhone,
      'phones': phones,
      'referencePeople': referencePeople?.map((p) => p.toMap()).toList(),
      'geographicZone': geographicZone,
      'subGeographicZone': subGeographicZone,
      'linkedin': linkedin,
      'twitter': twitter,
      'otherSocialMedia': otherSocialMedia,
      'contactName': contactName,
      'contactEmail': contactEmail,
      'contactPosition': contactPosition,
      'contactChoiceGrade': contactChoiceGrade,
      'contactKOL': contactKOL,
      'contactProject': contactProject,
      'trust': trust,
      'country': country,
      'province': province,
      'city': city,
      'signedAgreements': signedAgreements,
      'signedAgreementsDate': signedAgreementsDate,
      'offeredServices': offeredServices,
      'kolType': kolType,
      'createdAt': createdAt,
      'createdBy': createdBy
    };
  }

  ExternalSocialEntity copyWith({
    String? externalSocialEntityId,
    String? associatedSocialEntityId,
    String? name,
    String? email,
    Address? address,
    String? website,
    List<String>? types,
    List<String>? actionScope,
    String? category,
    String? subCategory,
    String? entityPhone,
    String? entityMobilePhone,
    String? contactPhone,
    String? contactMobilePhone,
    List<String>? phones,
    List<ReferencePerson>? referencePeople,
    String? geographicZone,
    String? subGeographicZone,
    String? linkedin,
    String? twitter,
    String? otherSocialMedia,
    String? contactName,
    String? contactEmail,
    String? contactPosition,
    String? contactChoiceGrade,
    String? contactKOL,
    String? contactProject,
    String? country,
    String? countryName,
    String? province,
    String? provinceName,
    String? city,
    String? cityName,
    String? signedAgreements,
    DateTime? signedAgreementsDate,
    String? offeredServices,
    String? kolType,
    bool? trust,
    DateTime? createdAt,
    String? createdBy
  }) {
    return ExternalSocialEntity(
        externalSocialEntityId: externalSocialEntityId ?? this.externalSocialEntityId,
        associatedSocialEntityId: associatedSocialEntityId ?? this.associatedSocialEntityId,
        name: name ?? this.name,
        email: email ?? this.email,
        address: address ?? this.address,
        website: website ?? this.website,
        types: types ?? this.types,
        actionScope: actionScope ?? this.actionScope,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        entityPhone: entityPhone ?? this.entityPhone,
        entityMobilePhone: entityMobilePhone ?? this.entityMobilePhone,
        contactPhone: contactPhone ?? this.contactPhone,
        contactMobilePhone: contactMobilePhone ?? this.contactMobilePhone,
        phones: phones ?? this.phones,
        referencePeople: referencePeople ?? this.referencePeople,
        geographicZone: geographicZone ?? this.geographicZone,
        subGeographicZone: subGeographicZone ?? this.subGeographicZone,
        linkedin: linkedin ?? this.linkedin,
        twitter: twitter ?? this.twitter,
        otherSocialMedia: otherSocialMedia ?? this.otherSocialMedia,
        contactName: contactName ?? this.contactName,
        contactEmail: contactEmail ?? this.contactEmail,
        contactPosition: contactPosition ?? this.contactPosition,
        contactChoiceGrade: contactChoiceGrade ?? this.contactChoiceGrade,
        contactKOL: contactKOL ?? this.contactKOL,
        contactProject: contactProject ?? this.contactProject,
        country: country ?? this.country,
        countryName: countryName ?? this.countryName,
        province: province ?? this.province,
        provinceName: provinceName ?? this.provinceName,
        city: city ?? this.city,
        cityName: cityName ?? this.cityName,
        signedAgreements: signedAgreements ?? this.signedAgreements,
        signedAgreementsDate: signedAgreementsDate ?? this.signedAgreementsDate,
        offeredServices: offeredServices ?? this.offeredServices,
        kolType: kolType ?? this.kolType,
        trust: trust ?? this.trust,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy
    );
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExternalSocialEntity &&
            other.externalSocialEntityId == externalSocialEntityId);
  }


  @override
  // TODO: implement hashCode
  int get hashCode => externalSocialEntityId.hashCode;

}