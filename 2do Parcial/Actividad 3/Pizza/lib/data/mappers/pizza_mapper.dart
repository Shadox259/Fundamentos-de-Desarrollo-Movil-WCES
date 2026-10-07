import '../../models/pizza_model.dart';

class PizzaMapper {
  static Map<String, dynamic> toMap(PizzaModel p) => p.toMap();

  static PizzaModel fromMap(Map<String, dynamic> m) => PizzaModel.fromMap(m);
}