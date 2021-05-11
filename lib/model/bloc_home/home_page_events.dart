import 'package:equatable/equatable.dart';

class HomePageEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RefreshList extends HomePageEvent {
  @override
  List<Object> get props => [];
}

class FilterList extends HomePageEvent {
  final filterString;

  FilterList(this.filterString);

  @override
  List<Object> get props => [];
}
