class Contact {//définit le modèle pour tout objet contact
  final String id;
  final String name;
  final String email;
  final String phone;//Ce sont les attributs de la classe - final signifie qu'elles sont non modifiables après la création de l'objet
  
  Contact({required this.id, required this.name, required this.email, required this.phone});
  //Le constructeur principal-Il utilise des paramètres nommés ({...}) qui sont tous obligatoires (required)
  // La syntaxe this.id est un raccourci pour assigner directement la valeur du paramètre à la propriété correspondante


  Contact.fromMap(String id, Map<String, dynamic> map)
  //Un constructeur nommé qui suit la convention fromMap. Son rôle est de transformer une Map en un objet Contact
  // Il prend en paramètre l'ID et une Map dont les clés sont des String et les valeurs sont dynamic, car leur type n'est pas garanti à la compilation
      : id = id, // Initialisation directe
        name = map['name'] ?? '',//si le nom dans map est null remplace le par ''
        email = map['email'] ?? '',
        phone = map['phone'] ?? '';

  Map<String, dynamic> toMap() {//Une méthode nommée toMap qui transforme l'objet en Map et retourne cette Map
    return {'id': id, 'name': name, 'email': email, 'phone': phone};
  }
}
