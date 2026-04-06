import '../../domain/entities/match_level.dart';

final Map<MatchLevel, List<String>>
kCouplesQuestionsSeed = <MatchLevel, List<String>>{
  MatchLevel.cielo: <String>[
    'Cual fue tu primera impresion de tu pareja?',
    'Que error de pareja no volverias a repetir?',
    'Que te hizo quedarte cuando pensaste en irte?',
  ],
  MatchLevel.tierra: <String>[
    'Que le cambiarias fisicamente a tu pareja y por que?',
    'Que conversacion pendiente evitaste en su relacion?',
    'Que celos te cuesta admitir frente a tu pareja?',
  ],
  MatchLevel.infierno: <String>[
    'Que limite sexual no cruzarias con tu pareja pero si con otra persona?',
    'Que verdad aun no te animas a decirle a tu pareja?',
    'Con quien de tu pasado comparas en silencio a tu pareja?',
  ],
  MatchLevel.inframundo: <String>[
    'Confiesa la verdad que mas miedo te da decir ahora mismo.',
    'Nombra la inseguridad que ocultas dentro de tu relacion.',
  ],
};

final Map<MatchLevel, List<String>> kCouplesChallengesSeed =
    <MatchLevel, List<String>>{
      MatchLevel.cielo: <String>[
        'Diganse 3 verdades incomodas mirandose a los ojos.',
        'Recreen en 20 segundos su peor discusion.',
        'Respondan una pregunta del grupo sin interrumpirse.',
      ],
      MatchLevel.tierra: <String>[
        'Envien un mensaje arriesgado dictado por el grupo.',
        'Hagan una llamada breve y confiesen un detalle vergonzoso.',
        'Intercambien telefonos por 30 segundos sin borrar nada.',
      ],
      MatchLevel.infierno: <String>[
        'Publiquen una historia de pareja provocadora por 1 minuto.',
        'Dejen que el grupo redacte un mensaje y envienlo a un ex.',
        'Hagan una promesa incomoda frente al grupo.',
      ],
      MatchLevel.inframundo: <String>[
        'Cumplan una orden del grupo sin negociar.',
        'Tienen 20 segundos para una confesion doble o quedan fuera.',
      ],
    };
