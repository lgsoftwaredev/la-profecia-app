import '../../domain/entities/match_level.dart';

final Map<MatchLevel, List<String>> kFriendsQuestionsSeed =
    <MatchLevel, List<String>>{
      MatchLevel.cielo: <String>[
        'Cual es la peor excusa que has usado para terminar con alguien?',
        'Que es lo mas vergonzoso que has hecho en publico?',
        'Cual es el secreto mas oscuro que llevas contigo?',
      ],
      MatchLevel.tierra: <String>[
        'Con quien aqui presente te acostarias hoy y por que?',
        'Que es lo mas cruel que has dicho en un momento de enojo?',
        'Si tus amigos supieran todo de ti, seguirian confiando?',
      ],
      MatchLevel.infierno: <String>[
        'Con cuantas personas has estado sexualmente y mentiste al respecto?',
        'Que secreto intimo destruiria tu reputacion si se supiera?',
        'A quien del grupo pedirias un nude y por que?',
      ],
      MatchLevel.inframundo: <String>[
        'Confiesa algo que nunca dirias fuera de este juego.',
        'Nombra a quien del grupo mas has juzgado en silencio.',
      ],
    };

final Map<MatchLevel, List<String>> kFriendsChallengesSeed =
    <MatchLevel, List<String>>{
      MatchLevel.cielo: <String>[
        'Baila 20 segundos la cancion que elija el grupo.',
        'Haz una imitacion de otro jugador sin reirte.',
        'Cuenta una historia bochornosa en 30 segundos.',
      ],
      MatchLevel.tierra: <String>[
        'Envia un audio vergonzoso a un contacto elegido por el grupo.',
        'Deja que el grupo te cambie el peinado por una ronda.',
        'Haz una llamada corta y di una frase absurda que te dicte el grupo.',
      ],
      MatchLevel.infierno: <String>[
        'Publica una historia durante 1 minuto con texto elegido por el grupo.',
        'Deja que otro jugador escriba un mensaje y envialo sin editar.',
        'Haz una declaracion extrema frente a todos sin reirte.',
      ],
      MatchLevel.inframundo: <String>[
        'Tienes 15 segundos para convencer al grupo de perdonarte.',
        'Acepta una penitencia instantanea decidida por el grupo.',
      ],
    };
