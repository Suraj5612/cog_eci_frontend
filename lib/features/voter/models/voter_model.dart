class VoterModel {
  final String voterName;
  final String epicNumber;
  final String address;
  final int serialNumber;
  final String partNumberAndName;
  final String constituencyName;
  final String stateName;
  final String mobileNumber;

  VoterModel({
    required this.voterName,
    required this.epicNumber,
    required this.address,
    required this.serialNumber,
    required this.partNumberAndName,
    required this.constituencyName,
    required this.stateName,
    required this.mobileNumber,
  });

  factory VoterModel.fromJson(Map<String, dynamic> json) {
    return VoterModel(
      voterName: json['voterName'] ?? '',
      epicNumber: json['epicNumber'] ?? '',
      address: json['address'] ?? '',
      serialNumber: json['serialNumber'] ?? 0,
      partNumberAndName: json['partNumberAndName'] ?? '',
      constituencyName: json['constituencyName'] ?? '',
      stateName: json['stateName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
    );
  }
}
