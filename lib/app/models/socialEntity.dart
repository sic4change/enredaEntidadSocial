import 'package:enreda_empresas/app/models/scope.dart';
import 'package:enreda_empresas/app/models/size.dart';
import 'package:enreda_empresas/app/models/socialEntitiesType.dart';
import 'addressUser.dart';

class SocialEntity {
  SocialEntity({
    this.socialEntityId,
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
    this.trust,
  });

  //Old fields
  final String? socialEntityId;
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
  //New fields
  final String? actionScope;
  final String? category;
  final String? subCategory;
  final String? entityPhone;
  final String? entityMobilePhone;
  final String? contactPhone;
  final String? contactMobilePhone;
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
  final bool? trust;


  factory SocialEntity.fromMap(Map<String, dynamic> data, String documentId) {

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
    final String? socialEntityId = data['socialEntityId'];
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

    final String actionScope = data['actionScope'] ?? '';
    final String category = data['category'] ?? '';
    final String subCategory = data['subCategory'] ?? '';
    final String entityPhone = data['entityPhone'] ?? '';
    final String entityMobilePhone = data['entityMobilePhone'] ?? '';
    final String contactPhone = data['contactPhone'] ?? '';
    final String contactMobilePhone = data['contactPhone'] ?? '';
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
    final String? countryName = data['countryName'];
    final String? province = data['address']['province'];
    final String? provinceName = data['provinceName'];
    final String? city = data['address']['city'];
    final String? cityName = data['cityName'];

    return SocialEntity(
        socialEntityId: socialEntityId,
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
        countryName: countryName,
        province: province,
        provinceName: provinceName,
        city: city,
        cityName: cityName
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'socialEntityId': socialEntityId,
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

    };
  }

  @override
  bool operator ==(Object other){
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SocialEntity &&
            other.socialEntityId == socialEntityId);
  }


  @override
  // TODO: implement hashCode
  int get hashCode => socialEntityId.hashCode;

}