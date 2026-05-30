class AppFormOptions {
  AppFormOptions._();

  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  static const List<String> urgencies = ['normal', 'urgent', 'emergency'];

  static const List<String> districts = [
    'Bagerhat',
    'Bandarban',
    'Barguna',
    'Barishal',
    'Bhola',
    'Bogura',
    'Brahmanbaria',
    'Chandpur',
    'Chattogram',
    'Chuadanga',
    'Cox’s Bazar',
    'Cumilla',
    'Dhaka',
    'Dinajpur',
    'Faridpur',
    'Feni',
    'Gaibandha',
    'Gazipur',
    'Gopalganj',
    'Habiganj',
    'Jamalpur',
    'Jashore',
    'Jhalokathi',
    'Jhenaidah',
    'Joypurhat',
    'Khagrachhari',
    'Khulna',
    'Kishoreganj',
    'Kurigram',
    'Kushtia',
    'Lakshmipur',
    'Lalmonirhat',
    'Madaripur',
    'Magura',
    'Manikganj',
    'Meherpur',
    'Moulvibazar',
    'Munshiganj',
    'Mymensingh',
    'Naogaon',
    'Narail',
    'Narayanganj',
    'Narsingdi',
    'Natore',
    'Netrokona',
    'Nilphamari',
    'Noakhali',
    'Pabna',
    'Panchagarh',
    'Patuakhali',
    'Pirojpur',
    'Rajbari',
    'Rajshahi',
    'Rangamati',
    'Rangpur',
    'Satkhira',
    'Shariatpur',
    'Sherpur',
    'Sirajganj',
    'Sunamganj',
    'Sylhet',
    'Tangail',
    'Thakurgaon',
  ];

  static const Map<String, List<String>> hospitalsByDistrict = {
    'Bagerhat': [
      'Bagerhat District Hospital',
      'Bagerhat Sadar Hospital',
      'Khan Jahan Ali Hospital',
      'Other',
    ],

    'Bandarban': [
      'Bandarban District Hospital',
      'Bandarban Sadar Hospital',
      'Other',
    ],

    'Barguna': [
      'Barguna District Hospital',
      'Barguna Sadar Hospital',
      'Barguna 100 Bed Hospital',
      'Other',
    ],

    'Barishal': [
      'Sher-e-Bangla Medical College Hospital',
      'Barishal General Hospital',
      'Barishal District Hospital',
      'Islami Bank Hospital Barishal',
      'South Apollo Medical College Hospital',
      'Other',
    ],

    'Bhola': [
      'Bhola 250 Bed General Hospital',
      'Bhola District Hospital',
      'Bhola Sadar Hospital',
      'Other',
    ],

    'Bogura': [
      'Shaheed Ziaur Rahman Medical College Hospital',
      'Mohammad Ali Hospital',
      'Bogura 250 Bed General Hospital',
      'TMSS Medical College Hospital',
      'Popular Diagnostic Centre Bogura',
      'Other',
    ],

    'Brahmanbaria': [
      'Brahmanbaria District Sadar Hospital',
      'Brahmanbaria Medical College Hospital',
      'Brahmanbaria General Hospital',
      'Labaid Diagnostic Brahmanbaria',
      'Other',
    ],

    'Chandpur': [
      'Chandpur 250 Bed General Hospital',
      'Chandpur District Hospital',
      'Chandpur Sadar Hospital',
      'Other',
    ],

    'Chattogram': [
      'Chattogram Medical College Hospital',
      'Chattogram General Hospital',
      'Chattogram Maa-O-Shishu Hospital',
      'Imperial Hospital',
      'Parkview Hospital',
      'Max Hospital',
      'CSCR Hospital',
      'Evercare Hospital Chattogram',
      'Chevron Clinical Laboratory',
      'Other',
    ],

    'Chuadanga': [
      'Chuadanga Sadar Hospital',
      'Chuadanga District Hospital',
      'Other',
    ],

    'Cox’s Bazar': [
      'Cox’s Bazar District Sadar Hospital',
      'Cox’s Bazar Medical College Hospital',
      'Hope Hospital',
      'Union Hospital Cox’s Bazar',
      'Other',
    ],

    'Cumilla': [
      'Cumilla Medical College Hospital',
      'Cumilla General Hospital',
      'Cumilla Sadar Hospital',
      'Moon Hospital',
      'CD Path & Hospital',
      'Other',
    ],

    'Dhaka': [
      'Dhaka Medical College Hospital',
      'Bangladesh Medical University',
      'Sir Salimullah Medical College Mitford Hospital',
      'Mugda Medical College Hospital',
      'Kurmitola General Hospital',
      'Shaheed Suhrawardy Medical College Hospital',
      'National Institute of Cardiovascular Diseases',
      'National Institute of Neurosciences & Hospital',
      'National Institute of Kidney Diseases & Urology',
      'National Institute of Traumatology and Orthopaedic Rehabilitation',
      'National Institute of Cancer Research & Hospital',
      'National Institute of Diseases of the Chest & Hospital',
      'BIRDEM General Hospital',
      'Square Hospital',
      'United Hospital',
      'Evercare Hospital Dhaka',
      'Ibn Sina Hospital',
      'Labaid Specialized Hospital',
      'Popular Diagnostic Centre',
      'Anwer Khan Modern Medical College Hospital',
      'Asgar Ali Hospital',
      'Central Hospital',
      'Other',
    ],

    'Dinajpur': [
      'M Abdur Rahim Medical College Hospital',
      'Dinajpur 250 Bed General Hospital',
      'Dinajpur District Hospital',
      'Zia Heart Foundation Hospital',
      'Other',
    ],

    'Faridpur': [
      'Faridpur Medical College Hospital',
      'Faridpur General Hospital',
      'Faridpur District Hospital',
      'Diabetic Association Medical College Hospital',
      'Other',
    ],

    'Feni': [
      'Feni 250 Bed General Hospital',
      'Feni District Hospital',
      'Feni Sadar Hospital',
      'Other',
    ],

    'Gaibandha': [
      'Gaibandha District Hospital',
      'Gaibandha Sadar Hospital',
      'Gaibandha 100 Bed Hospital',
      'Other',
    ],

    'Gazipur': [
      'Shaheed Tajuddin Ahmad Medical College Hospital',
      'Gazipur District Hospital',
      'Tairunnessa Memorial Medical College Hospital',
      'City Medical College Hospital',
      'Other',
    ],

    'Gopalganj': [
      'Gopalganj 250 Bed General Hospital',
      'Sheikh Sayera Khatun Medical College Hospital',
      'Gopalganj District Hospital',
      'Other',
    ],

    'Habiganj': [
      'Habiganj 250 Bed District Sadar Hospital',
      'Habiganj District Hospital',
      'Habiganj Sadar Hospital',
      'Sheikh Hasina Medical College Hospital, Habiganj',
      'Other',
    ],

    'Jamalpur': [
      'Jamalpur 250 Bed General Hospital',
      'Jamalpur District Hospital',
      'Sheikh Hasina Medical College Hospital, Jamalpur',
      'Other',
    ],

    'Jashore': [
      'Jashore 250 Bed General Hospital',
      'Jashore Medical College Hospital',
      'Queen’s Hospital Jashore',
      'Ibn Sina Hospital Jashore',
      'Other',
    ],

    'Jhalokathi': [
      'Jhalokathi District Hospital',
      'Jhalokathi Sadar Hospital',
      'Other',
    ],

    'Jhenaidah': [
      'Jhenaidah District Hospital',
      'Jhenaidah Sadar Hospital',
      'Jhenaidah 250 Bed General Hospital',
      'Other',
    ],

    'Joypurhat': [
      'Joypurhat District Hospital',
      'Joypurhat Sadar Hospital',
      'Other',
    ],

    'Khagrachhari': [
      'Khagrachhari District Hospital',
      'Khagrachhari Sadar Hospital',
      'Other',
    ],

    'Khulna': [
      'Khulna Medical College Hospital',
      'Shaheed Sheikh Abu Naser Specialized Hospital',
      'Khulna General Hospital',
      'Gazi Medical College Hospital',
      'Khulna City Medical College Hospital',
      'Islami Bank Hospital Khulna',
      'Other',
    ],

    'Kishoreganj': [
      'Shaheed Syed Nazrul Islam Medical College Hospital',
      'Kishoreganj 250 Bed General Hospital',
      'Kishoreganj District Hospital',
      'Other',
    ],

    'Kurigram': [
      'Kurigram General Hospital',
      'Kurigram District Hospital',
      'Kurigram Sadar Hospital',
      'Other',
    ],

    'Kushtia': [
      'Kushtia Medical College Hospital',
      'Kushtia General Hospital',
      'Kushtia District Hospital',
      'Other',
    ],

    'Lakshmipur': [
      'Lakshmipur District Hospital',
      'Lakshmipur Sadar Hospital',
      'Lakshmipur 100 Bed Hospital',
      'Other',
    ],

    'Lalmonirhat': [
      'Lalmonirhat District Hospital',
      'Lalmonirhat Sadar Hospital',
      'Lalmonirhat 100 Bed Hospital',
      'Other',
    ],

    'Madaripur': [
      'Madaripur District Hospital',
      'Madaripur Sadar Hospital',
      'Other',
    ],

    'Magura': [
      'Magura 250 Bed General Hospital',
      'Magura District Hospital',
      'Magura Sadar Hospital',
      'Other',
    ],

    'Manikganj': [
      'Manikganj 250 Bed General Hospital',
      'Manikganj District Hospital',
      'Colonel Malek Medical College Hospital',
      'Other',
    ],

    'Meherpur': [
      'Meherpur General Hospital',
      'Meherpur District Hospital',
      'Meherpur Sadar Hospital',
      'Other',
    ],

    'Moulvibazar': [
      'Moulvibazar 250 Bed District Hospital',
      'Moulvibazar Sadar Hospital',
      'Life Line Hospital Moulvibazar',
      'Other',
    ],

    'Munshiganj': [
      'Munshiganj District Hospital',
      'Munshiganj General Hospital',
      'Other',
    ],

    'Mymensingh': [
      'Mymensingh Medical College Hospital',
      'Mymensingh Sadar Hospital',
      'Community Based Medical College Hospital',
      'Nexus Cardiac Hospital',
      'Popular Diagnostic Centre Mymensingh',
      'Other',
    ],

    'Naogaon': [
      'Naogaon 250 Bed General Hospital',
      'Naogaon District Hospital',
      'Naogaon Sadar Hospital',
      'Other',
    ],

    'Narail': [
      'Narail District Hospital',
      'Narail Sadar Hospital',
      'Narail 100 Bed Hospital',
      'Other',
    ],

    'Narayanganj': [
      'Narayanganj General Hospital',
      'Khanpur 300 Bed Hospital',
      'Narayanganj 300 Bed Hospital',
      'Other',
    ],

    'Narsingdi': [
      'Narsingdi District Hospital',
      'Narsingdi Sadar Hospital',
      'Narsingdi 100 Bed District Hospital',
      'Other',
    ],

    'Natore': [
      'Natore District Hospital',
      'Natore Sadar Hospital',
      'Natore 100 Bed Hospital',
      'Other',
    ],

    'Netrokona': [
      'Netrokona District Hospital',
      'Netrokona Sadar Hospital',
      'Netrokona 100 Bed Hospital',
      'Other',
    ],

    'Nilphamari': [
      'Nilphamari 250 Bed General Hospital',
      'Nilphamari District Hospital',
      'Nilphamari Sadar Hospital',
      'Other',
    ],

    'Noakhali': [
      'Noakhali 250 Bed General Hospital',
      'Abdul Malek Ukil Medical College Hospital',
      'Noakhali District Hospital',
      'Good Heal Hospital',
      'Other',
    ],

    'Pabna': [
      'Pabna Medical College Hospital',
      'Pabna General Hospital',
      'Pabna Mental Hospital',
      'Pabna District Hospital',
      'Other',
    ],

    'Panchagarh': [
      'Panchagarh District Hospital',
      'Panchagarh Sadar Hospital',
      'Panchagarh 100 Bed Hospital',
      'Other',
    ],

    'Patuakhali': [
      'Patuakhali Medical College Hospital',
      'Patuakhali 250 Bed General Hospital',
      'Patuakhali District Hospital',
      'Other',
    ],

    'Pirojpur': [
      'Pirojpur District Hospital',
      'Pirojpur Sadar Hospital',
      'Pirojpur 100 Bed Hospital',
      'Other',
    ],

    'Rajbari': ['Rajbari District Hospital', 'Rajbari Sadar Hospital', 'Other'],

    'Rajshahi': [
      'Rajshahi Medical College Hospital',
      'Rajshahi General Hospital',
      'Islami Bank Medical College Hospital',
      'Barind Medical College Hospital',
      'Royal Hospital Rajshahi',
      'Other',
    ],

    'Rangamati': [
      'Rangamati General Hospital',
      'Rangamati District Hospital',
      'Rangamati Sadar Hospital',
      'Other',
    ],

    'Rangpur': [
      'Rangpur Medical College Hospital',
      'Rangpur Community Medical College Hospital',
      'Prime Medical College Hospital',
      'Rangpur Central Hospital',
      'Good Health Hospital Rangpur',
      'Other',
    ],

    'Satkhira': [
      'Satkhira Medical College Hospital',
      'Satkhira Sadar Hospital',
      'Satkhira District Hospital',
      'Other',
    ],

    'Shariatpur': [
      'Shariatpur District Hospital',
      'Shariatpur Sadar Hospital',
      'Other',
    ],

    'Sherpur': [
      'Sherpur District Hospital',
      'Sherpur Sadar Hospital',
      'Sherpur 250 Bed General Hospital',
      'Other',
    ],

    'Sirajganj': [
      'Shaheed M. Monsur Ali Medical College Hospital',
      'Sirajganj 250 Bed General Hospital',
      'Sirajganj District Hospital',
      'North Bengal Medical College Hospital',
      'Other',
    ],

    'Sunamganj': [
      'Sunamganj District Hospital',
      'Sunamganj Sadar Hospital',
      'Sunamganj 250 Bed Hospital',
      'Other',
    ],

    'Sylhet': [
      'Sylhet MAG Osmani Medical College Hospital',
      'Sylhet Women’s Medical College Hospital',
      'Mount Adora Hospital',
      'Ibn Sina Hospital Sylhet',
      'North East Medical College Hospital',
      'Jalalabad Ragib-Rabeya Medical College Hospital',
      'Oasis Hospital Sylhet',
      'Other',
    ],

    'Tangail': [
      'Tangail 250 Bed General Hospital',
      'Sheikh Hasina Medical College Hospital, Tangail',
      'Tangail District Hospital',
      'Kumudini Hospital',
      'Other',
    ],

    'Thakurgaon': [
      'Thakurgaon 250 Bed General Hospital',
      'Thakurgaon District Hospital',
      'Thakurgaon Sadar Hospital',
      'Other',
    ],
  };

  static List<String> hospitalsForDistrict(String? district) {
    final normalizedDistrict = district?.trim();

    if (normalizedDistrict == null || normalizedDistrict.isEmpty) {
      return const ['Other'];
    }

    return hospitalsByDistrict[normalizedDistrict] ?? const ['Other'];
  }

  static String defaultHospitalAddress({
    required String? district,
    required String? hospital,
  }) {
    final normalizedHospital = hospital?.trim();
    final normalizedDistrict = district?.trim();

    if (normalizedHospital == null || normalizedHospital.isEmpty) return '';

    if (normalizedHospital == 'Other') return '';

    if (normalizedDistrict == null || normalizedDistrict.isEmpty) {
      return normalizedHospital;
    }

    return '$normalizedHospital, $normalizedDistrict';
  }
}
