class AdsModel{
  int? id;
  String? appId;
  String? name;
  String? adsId;

  AdsModel(this.id, this.appId, this.name, this.adsId);
  AdsModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    appId = json['app_id'];
    name = json['name'];
    adsId = json['ads_id'];
  }
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['app_id'] = this.appId;
    data['name'] = this.name;
    data['ads_id'] = this.adsId;
    return data;
  }
}