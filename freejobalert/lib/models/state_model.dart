class StateModel {
  final String name;
  final String value;

  StateModel({
    required this.name,
    required this.value,
  });
}

class IndianStates {
  static final List<StateModel> states = [
    StateModel(name: 'All States', value: 'state-government-jobs'),
    StateModel(name: 'Andhra Pradesh', value: 'ap-government-jobs'),
    StateModel(name: 'Arunachal Pradesh', value: 'arunachal-pradesh-government-jobs'),
    StateModel(name: 'Assam', value: 'assam-government-jobs'),
    StateModel(name: 'Bihar', value: 'bihar-government-jobs'),
    StateModel(name: 'Chhattisgarh', value: 'chhattisgarh-government-jobs'),
    StateModel(name: 'Goa', value: 'goa-government-jobs'),
    StateModel(name: 'Gujarat', value: 'gujarat-government-jobs'),
    StateModel(name: 'Haryana', value: 'haryana-government-jobs'),
    StateModel(name: 'Himachal Pradesh', value: 'hp-government-jobs'),
    StateModel(name: 'Jharkhand', value: 'jharkhand-government-jobs'),
    StateModel(name: 'Karnataka', value: 'karnataka-government-jobs'),
    StateModel(name: 'Kerala', value: 'kerala-government-jobs'),
    StateModel(name: 'Madhya Pradesh', value: 'mp-government-jobs'),
    StateModel(name: 'Maharashtra', value: 'maharashtra-government-jobs'),
    StateModel(name: 'Manipur', value: 'manipur-government-jobs'),
    StateModel(name: 'Meghalaya', value: 'meghalaya-government-jobs'),
    StateModel(name: 'Mizoram', value: 'mizoram-government-jobs'),
    StateModel(name: 'Nagaland', value: 'nagaland-government-jobs'),
    StateModel(name: 'Odisha', value: 'odisha-government-jobs'),
    StateModel(name: 'Punjab', value: 'punjab-government-jobs'),
    StateModel(name: 'Rajasthan', value: 'rajasthan-government-jobs'),
    StateModel(name: 'Sikkim', value: 'sikkim-government-jobs'),
    StateModel(name: 'Tamil Nadu', value: 'tn-government-jobs'),
    StateModel(name: 'Telangana', value: 'telangana-government-jobs'),
    StateModel(name: 'Tripura', value: 'tripura-government-jobs'),
    StateModel(name: 'Uttar Pradesh', value: 'up-government-jobs'),
    StateModel(name: 'Uttarakhand', value: 'uttarakhand-government-jobs'),
    StateModel(name: 'West Bengal', value: 'wb-government-jobs'),
    // Union Territories
    StateModel(name: 'Andaman and Nicobar Islands', value: 'an-government-jobs'),
    StateModel(name: 'Chandigarh', value: 'chandigarh-government-jobs'),
    StateModel(name: 'Dadra and Nagar Haveli', value: 'dadra-nagar-haveli-government-jobs'),
    StateModel(name: 'Delhi', value: 'delhi-government-jobs'),
    StateModel(name: 'Jammu and Kashmir', value: 'jk-government-jobs'),
    StateModel(name: 'Daman and Diu', value: 'daman-diu-government-jobs'),
    StateModel(name: 'Lakshadweep', value: 'lakshadweep'),
    StateModel(name: 'Puducherry', value: 'puduchhery-government-jobs'),
  ];
}
