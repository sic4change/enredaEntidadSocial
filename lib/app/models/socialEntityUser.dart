import 'addressUser.dart';

class SocialEntityUser {
  SocialEntityUser({
    required this.email,
    this.firstName,
    this.lastName,
    this.userId,
    this.organization,
    this.country,
    this.province,
    this.city,
    this.address,
    this.role,
    this.phone,
    this.postalCode,
  });

  String? email;
  String? userId;
  final String? firstName;
  final String? lastName;
  final String? organization;
  final String? country;
  final String? province;
  final String? city;
  final Address? address;
  final String? role;
  final String? phone;
  final String? postalCode;


  factory SocialEntityUser.fromMap(Map<String, dynamic> data, String documentId) {

    final Address? address = new Address(
        country: data['address']['country'],
        province: data['address']['province'],
        city: data['address']['city'],
        postalCode: data['address']['postalCode']
    );

    return SocialEntityUser(
      email: data['email'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      organization: data['organization'],
      userId: data['userId'],
      address: address,
      role: data['role'],
      phone: data['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'organization': organization,
      'userId': userId,
      'address': address?.toMap(),
      'role' : role,
      'phone': phone,
    };
  }
}