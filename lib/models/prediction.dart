class Prediction{
  String placeId;
  String mainText;
  String secondaryText;
  Function onSelect;

  Prediction({
    this.placeId,
    this.mainText,
    this.secondaryText,
});

  Prediction.fromJson(Map<String, dynamic> json, Function onSelect){
    placeId = json['place_id'];
    mainText= json['structured_formatting']['main_text'];
    secondaryText = json['structured_formatting']['secondary_text'];
    this.onSelect = onSelect;
  }

}