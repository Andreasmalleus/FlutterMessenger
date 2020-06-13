import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");

void showSnackBar(String message, GlobalKey<ScaffoldState> key){
    key.currentState.showSnackBar(SnackBar(content: Text(message),));
}

String getCurrentDate(){
  return dateFormat.format(DateTime.now());
}

String getDateInHoursAndMinutes(){  
  return DateFormat.Hm().format(DateTime.now()).toString();
}

String formatDateToHoursAndMinutes(String date){
  return DateFormat.Hm().format(formatStringToDateTime(date)).toString();
}

String formatDate(String date){
  return dateFormat.format(dateFormat.parse(date));
}

DateTime formatStringToDateTime(String date){
  DateTime formattedString = dateFormat.parse(date);
  return formattedString;
}