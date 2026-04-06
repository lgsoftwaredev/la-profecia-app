-- Seed de contenido oficial para La Profecia (preguntas y retos)
-- Fuentes:
-- - /Users/Geral/Downloads/Preguntas y Retos Parejas (1).txt
-- - /Users/Geral/Downloads/Preguntas y Retos Amigos (1).txt
-- Generado: 2026-04-01

BEGIN;

INSERT INTO "GameMode" ("code", "label") VALUES
  ('FRIENDS'::"GameModeCode", 'Amigos'),
  ('COUPLES'::"GameModeCode", 'Parejas')
ON CONFLICT ("code") DO UPDATE SET
  "label" = EXCLUDED."label";

INSERT INTO "Level" ("code", "label", "isPremium", "intensity", "isActive") VALUES
  ('CIELO'::"LevelCode", 'El Cielo', FALSE, 1, TRUE),
  ('TIERRA'::"LevelCode", 'La Tierra', TRUE, 2, TRUE),
  ('INFIERNO'::"LevelCode", 'El Infierno', TRUE, 3, TRUE),
  ('INFRAMUNDO'::"LevelCode", 'Inframundo', TRUE, 4, TRUE)
ON CONFLICT ("code") DO UPDATE SET
  "label" = EXCLUDED."label",
  "isPremium" = EXCLUDED."isPremium",
  "intensity" = EXCLUDED."intensity",
  "isActive" = EXCLUDED."isActive";

INSERT INTO "ChallengeCategory" ("slug", "name", "description", "isActive") VALUES
  ('preguntas', 'Preguntas', 'Contenido tipo pregunta para dinamica grupal', TRUE),
  ('retos', 'Retos', 'Contenido tipo reto para dinamica grupal', TRUE)
ON CONFLICT ("slug") DO UPDATE SET
  "name" = EXCLUDED."name",
  "description" = EXCLUDED."description",
  "isActive" = EXCLUDED."isActive";

WITH seed_scope AS (
  SELECT
    gm."id" AS "modeId",
    cc."id" AS "categoryId"
  FROM "GameMode" gm
  JOIN "ChallengeCategory" cc ON cc."slug" = 'preguntas'
  WHERE gm."code" IN ('FRIENDS'::"GameModeCode", 'COUPLES'::"GameModeCode")
)
DELETE FROM "Question" q
USING seed_scope s
WHERE q."modeId" = s."modeId"
  AND q."categoryId" = s."categoryId"
  AND q."isOfficial" = TRUE
  AND q."createdByUserId" IS NULL;

WITH seed_scope AS (
  SELECT
    gm."id" AS "modeId",
    cc."id" AS "categoryId"
  FROM "GameMode" gm
  JOIN "ChallengeCategory" cc ON cc."slug" = 'retos'
  WHERE gm."code" IN ('FRIENDS'::"GameModeCode", 'COUPLES'::"GameModeCode")
)
DELETE FROM "Challenge" c
USING seed_scope s
WHERE c."modeId" = s."modeId"
  AND c."categoryId" = s."categoryId"
  AND c."isOfficial" = TRUE
  AND c."createdByUserId" IS NULL;

INSERT INTO "Question" (
  "modeId",
  "levelId",
  "categoryId",
  "text",
  "isOfficial",
  "isActive"
)
SELECT
  gm."id",
  lv."id",
  cc."id",
  payload."text",
  TRUE,
  TRUE
FROM (
  VALUES
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuál fue la primera impresión que tuviste de tu pareja? Sé honesto.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Qué no es tóxico para ti pero todos piensan que si lo es?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuánto dinero debe gastar una persona para salir contigo?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Si te doy permiso para pedir algo ''sin límites'', ¿qué me pedirías?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuanto es lo menos que has durado en la cama? cuéntanos la experiencia'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Qué es lo que más extrañas de tu ex? Cuéntaselo a tu pareja y no puedes responder “nada”.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Qué errores has cometido durante todas tus relaciones?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuál es el mayor sacrificio que has hecho por alguna pareja, aunque no lo sepa?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Si pudieras hacer algo ilegal con tu pareja, ¿qué sería y por qué?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Has espiado el teléfono de tu pareja o ex pareja? ¿Qué viste?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cómo reaccionarías y qué harías si descubrieras a tu pareja siéndote infiel?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Qué secreto guardas ahora mismo que tu pareja jamás debe descubrir?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Aún tienes agregado a tu ex? Muéstranos la última conversación con él'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuáles son 5 cosas que te gustan de la persona que tienes enfrente?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Dejarías revisarte el celular por tu pareja ahora mismo? Explica por qué.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Por cuál ex pareja cambiarías a tu pareja actual? Di su nombre y explica el porqué. No puedes decir ‘Ninguno’.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuál es el recuerdo más especial o divertido que guardas de una noche con tu ex?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Si tu pareja cambiará drásticamente en su apariencia física, ¿seguirías deseándola o considerarías buscar a alguien más?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Siendo realistas, ¿Crees que tu pareja actual puede ser el amor de tu vida?'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuál ha sido la escena más tóxica y dramática que armaste por celos y cómo terminó?'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Puedes adivinar el color de la ropa interior de tu pareja? Si fallas, toma 2 shots.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Cual es el lugar más loco donde has tenido sexo?'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Alguna vez has pensado en otra persona mientras estás en una relación amorosa? Di en quien pensaste y porque'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Eres vengativo/a? Cuéntanos alguna vez que te hayas vengado de alguien.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Volverías a estar con la persona que te quitó la virginidad?'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Te has arrepentido de acostarte con alguien de tu pasado? ¿Por qué y con quién? Muéstranos una foto'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Qué le cambiarías físicamente a tu pareja? No se vale decir nada.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Me dejarías subir contenido explícito? ¿Qué opinas acerca de esto? Sé sincero.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Qué es lo más hiriente que has pensado sobre tu pareja pero nunca le has dicho?'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Cómo te gusta que tu pareja te complazca en la cama?'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Si tu pareja no pudiera tener relaciones íntimas nunca más, ¿te quedarías con ella o buscarías a alguien más? Explica tu respuesta.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Quién crees que de tu pasado es mejor en la cama que tu pareja actual? Di su nombre y cuéntanos porque lo crees'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Te han sido infiel? Di su nombre y ridiculizalo frente a todos, se vale ser creativo.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Si tuvieras que ser infiel ¿Con quién lo harías?'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Alguna vez has desvirgado a alguien? Di su nombre y cuéntanos como fue.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Cuál sería tu plan perfecto para traicionar a tu pareja? Detalla cómo lo harías y qué pasos seguirías.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Quién de las personas con las que has estado tenía mal olor en su zona íntima? Muestra una foto y di su nombre al grupo.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Alguna vez has sentido que otra persona te haría más feliz que tu pareja actual? Si y por qué?'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Qué es lo que menos te gustaría que tu pareja encontrará en tu celular?'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Puedes contarnos explícitamente y en voz alta cómo fue la vez que perdiste tu virginidad?'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Con cuantas personas has tenido sexo? Nombralos.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Cómo describirías las partes íntimas de tu pareja o las tuyas? Debes ser sincero/a.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Con qué frecuencia te autocomplaces? Muestra el último video, foto o pensamiento con el que lo hiciste.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Si pudieras hoy tener el mejor sexo de tu vida, con quién sería? no puedes elegir a tu pareja.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Alguna vez te acostaste o hiciste algo comprometedor con alguna pareja de un amigo? Explica que hiciste'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Alguna vez has tenido en mente a otra persona durante un momento de intimidad? Cuéntanos en quien pensaste'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Has mentido sobre tu pasado sexual?'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Con quién de las personas con las que has estado sexualmente te has arrepentido de estar? Di su nombre y muestra una foto al grupo.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Has fingido alguna vez un orgasmo? Si la respuesta es sí, dinos el nombre de esa persona ¿Y por qué?'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Qué límite sexual tendrías con tu pareja qué crees que nunca cruzarás, pero lo harías con alguien más?'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Con quién fue la última vez que tuviste sexo fuera de tu pareja? Da su nombre, fecha y cuenta cómo fue.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Qué es lo más extremo que has hecho sexualmente que aún no le has contado a tu pareja porque temes de su reacción?'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Qué es lo más sucio que alguien te ha hecho y que te encantó?'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Cuál es el aspecto menos atractivo de tu pareja? Sé sincero y explica por qué piensas así.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Alguna vez has terminado insatisfecho/a en la cama y no se lo dijiste a tu ex o actual pareja?'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Si terminas una relación, ¿quién sería la primera persona con la que tendrías sexo? Di su nombre y muéstranos una foto, Si no contestas, debes tomar 2 shots.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Cuál de tus parejas sexuales tenía la parte íntima más desagradable, pequeña o extraña? Di su nombre y muestra una foto al grupo.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Entre todas las personas de tus contactos ¿Quién crees que en la cama es una bestia? Di su nombre y muestra una foto de él/ella'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Qué tipo de contenido para adulto has visto para autocomplacerte? Describelo'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Qué fue lo que te hizo enamorarte de tu ex novia/o?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuál es la peor excusa que has usado para terminar con alguien?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuál es el peor error que cometiste y aún te persigue?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cual es tu amigo más tacaño y que es lo peor que ha hecho? Di su nombre y exponlo frente a todos.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Qué has hecho que puedes catalogar “fui mala persona”?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Qué crees que diría tu ex si le preguntan cual es tu peor y mejor cualidad?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Qué es lo más vergonzoso que has hecho en público?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '⁠¿Por qué crees que estás soltero? Explica detalle a detalle porque nadie quiere estar contigo'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuál es la mentira más grande que haz dicho?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Mira atentamente a todos, ¿quién es la persona más fea del grupo y por qué? No puedes decir "Ninguno”'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Qué mentira le has dicho a tus padres que ellos no sepan?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Qué es lo que menos te gusta de la persona que tienes al frente? Debe ser Fisicamente y personalidad'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Qué es lo más ridículo que hiciste por despecho?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Qué es lo más loco que has hecho en una fiesta con tus amigo/as?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Por qué terminó tu última relación? Cuéntanos todo a detalle'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuál es el peor comportamiento que has tenido frente a personas que te quieren?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuál ha sido el momento más vulnerable que has vivido?'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Cuál es el secreto más oscuro que llevas contigo? cuéntalo.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Quién fue la persona que más te hizo sufrir sentimentalmente? Cuéntanos quién es y qué hizo'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Cuenta la historia de tu vida en menos de un minuto.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '¿Qué es lo que más te avergüenza de ti?'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Describe como te vengarías de una persona que te hizo mucho daño'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Si estuvieras obligado/a a elegir, ¿con cuál pareja actual o ex de algún amigo/a presente tendrías una relación? Explica por qué.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Con quién aquí presente te acostarías hoy? Si la respuesta es ninguno, enseña una foto de alguien que el grupo pueda conocer.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Cuándo fue la última vez que te masturbaste? ¿Y en quién pensaste? Muestra una foto'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Qué es lo más funable que has hecho con tus amigo/as?'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Explicanos explícitamente cómo te imaginarías una noche con alguien de aquí, tienes que elegir sabiamente.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Qué es lo más cruel que has dicho a alguien en un momento de enojo?'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Cuéntale un secreto a alguien de aquí que nadie puede saber al oído y que todos vean su reacción.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Di en voz alta un hecho que haría enojar a todos en redes sociales, sin censura.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Has hecho o harías algún favor sexual para conseguir lo que quieres? ¿Qué sería?'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Alguna vez has desvirgado a alguien? si así es, ¿cuántos años tenía?'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Cuándo fue la última vez que tuviste sexo y con quién? Muestra una foto.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Cuéntanos la historia de quien fue el hombre o mujer que más amaste en menos de 2 minutos.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿A quién del grupo le robarías su pareja? Si no las conoces o no tienen pareja, pideles que te muestren una foto de su ex o de su pareja actual antes de responder.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Si pudieras besar a alguien dentro o fuera del grupo sin consecuencias, ¿a quién elegirías y por qué?'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Cómo describirías a tu ex en la cama? Se explicito.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Cuántas personas te has besado en un día?'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Te has aprovechado de alguien alguna vez? Por más mínimo que sea, cuentanos de quien y como fue'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Si tu pareja o amigos supieran todo lo que has hecho en secreto, ¿seguirán confiando en ti?'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '¿Alguna vez has manipulado a alguien para obtener algo que querías? ¿Cómo lo hiciste?'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Alguna vez te has involucrado con alguien que sabías que estaba en una relación? No mientas, Di su nombre y cuéntanos como fue.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Te gustaría verme mientras me toco? Preguntale eso a el jugador/a de tu elección'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Tendrías sexo hoy conmigo? hazle esta pregunta a un jugador que te interese. Si no lo haces, tomas doble shot.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Cual es el lugar más raro donde te has masturbado?'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Qué es lo que más te gusta que te hagan en la cama? Descríbelo'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Cuál es esa inseguridad que siempre tratas de ocultar y nunca admitirías en público? Cuéntalo ahora públicamente.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿A quién del grupo le pedirías que te enseñe un nude? Pide que te la enseñe, si no lo convences, debes tomar 2 shots.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Con cuántos de los contactos guardados en tu teléfono has tenido sexo? Enseñalos todos'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Cuál es el nombre de la persona con la que estuviste por despecho? Cuenta como jugaste con él/ella'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Cuál es el nombre completo de la persona con quien has tenido la peor experiencia íntima? Muestra una foto al grupo y cuéntanos los detalles.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Qué es lo más manipulador que has hecho para llevar a alguien a la cama? No se vale contestar “nada”'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Con cuántas personas has estado sexualmente? ¿Alguna vez mentiste al respecto?'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Sé sincero: ¿Alguna vez has fallado durante el sexo? Cuéntanos qué pasó.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Te arrepientes de la persona con la que perdiste tu virginidad? Di su nombre y muestra una foto.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Prefieres el sexo duro o suave? Menciona el nombre de la última persona con la que lo hiciste así y muestra su foto.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Alguna vez has usado a alguien solo como un objeto para satisfacer tus deseos y luego lo abandonaste?'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Describe con detalles el video sexual más explícito que hayas grabado: ¿dónde fue, con quién, y cómo sucedió?'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Qué secreto íntimo tienes que sería tan devastador que si tu pareja o familia lo supieran se alejaría de ti?'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Si alguien de aquí te propone tener sexo con quien lo harías?'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '¿Cuál fue la persona de mayor o menor edad con la que has tenido sexo? Di sus nombre y enseña una foto.')
) AS payload("modeCode", "levelCode", "text")
JOIN "GameMode" gm ON gm."code" = payload."modeCode"
JOIN "Level" lv ON lv."code" = payload."levelCode"
JOIN "ChallengeCategory" cc ON cc."slug" = 'preguntas';

INSERT INTO "Challenge" (
  "modeId",
  "levelId",
  "categoryId",
  "text",
  "isOfficial",
  "isActive"
)
SELECT
  gm."id",
  lv."id",
  cc."id",
  payload."text",
  TRUE,
  TRUE
FROM (
  VALUES
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Convence a tu pareja de llamar a su madre en altavoz y que le pregunte que opina de ti, sino lo hace debes tomar 1 shot.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Dale un cabezazo a tu pareja y luego pídele perdón de rodillas.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Haz que un amigo tuyo compre el ‘juego’ la profecía y use este código de descuento: “reto” para tener 20,000cop gratis, si no lo logras tomas un shot.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Tu pareja tiene 1 minuto para pedirte lo que desee, y no puedes negarte. Si te niegas, toma un shot.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Recrea la situación con tu cuerpo del día que menos has durado en la cama, utiliza lo que tengas al alcance de tu mano para hacerlo lo más realista posible.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Enviale un mensaje a tu ex diciendo “te extraño mucho” y no lo borres hasta terminar el juego.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Dejale tu celular a tu pareja por 3 minutos desbloqueado para que revise lo que quiera.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Baila la canción que el grupo elija.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Metete los dedos de tu pareja en la boca durante 10 segundos, el que se ría debe tomar un shot.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Revisa la galería de fotos eliminadas de tu pareja.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Besa en el cachete a un jugador del grupo que no sea la persona que te gusta.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Dile una mentira y una verdad a tu pareja. Si adivina cuál es cuál, tomas un shot. Si no, lo toma tu pareja.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Quítate 4 prendas, no podrás volver a usarlas durante el resto del juego.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Nalgueate a ti mismo por 15 segundos, mientras repites la frase “he sido un(a) chico/a muy, muy, malo/a”.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Muestrale al grupo una conversación subida de tono de antes de conocer a tu pareja.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Sube una historia a Instagram etiquetando a tu ex y escribe: “Te extraño”.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Lame todo el cuello de tu pareja lentamente y para en su boca.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Llama a tus padres y dile que estas loco por hacer el amor hoy, que si puede ser en su cama.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Ponte la ropa interior de la persona que elijan del grupo.'),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Describe cómo fue la noche más caliente de tu vida pero sin hablar.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Convence a tu pareja y hazle calzon chino con la boca.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Haz una videollamada grupal con tu familia y confiesa cuál ha sido el lugar más loco donde has tenido sexo.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Escríbele a una persona aleatoria y cuentale como piensas en el/ella mientras estas con tu pareja.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Cada miembro del grupo te dará una nalgada por tu mal comportamiento, si alguno no lo hace tomas doble shot.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Envíale un mensaje de texto a la persona con la que perdiste tu virginidad y dile que le extrañas.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Busca en las redes sociales a la persona con la que te hayas arrepentido de estar y envíale un mensaje contándole porque te arrepientes.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Sube una captura de un chat falso donde diga que te fueron infiel, déjala hasta que se termine el juego.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Sube una publicación en cualquier red social donde indiques que vas a ser papá o mamá, etiqueta a tus familiares y déjala durante todo el juego'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Haz la cara de orgasmo que pondría tu pareja.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Llama a tu ‘casi algo’ que heriste y pregúntale tu mejor cualidad y peor cualidad.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Imita tu posición favorita en la cama y permite que todos te tomen una foto.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Desabrocha el sujetador de tu pareja (o quítale los pantalones) usando solo una mano.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Busca a la persona que te fue infiel, y escribile diciendole que ahora eres más feliz sin él/ella'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Llama a tus padres y confiesa que vendes contenido sexual a cambio de dinero.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Metele la mano completa en la boca a un jugador del grupo, si fracasas debes tomar 2 shots. Elige bien, debes convencerlo.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Llama a un familiar de tu ex y dile que le echas de menos.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Convence a un jugador de tomarse 3 shots, sino debes hacerlo tú'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Mete tu lengua en la nariz de tu pareja hasta que el grupo decida que pares.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Permite que alguien, elegido por el grupo, manosee cualquier parte de tu cuerpo que decida el jugador más borracho.'),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", 'Quítate la ropa interior y ponla al frente de todos los jugadores para que la puedan ver.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Busca en tu celular una conversación con alguien que hayas tenido una relación íntima y deja que otro jugador del grupo la lea en voz alta.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Muéstranos el último mensaje que enviaste coqueteandole a alguien.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Dale la clave de tu celular a la persona a tu derecha, porque a partir de ahora tiene 1 minuto para buscar una nude en tu teléfono. Si no encuentra ninguna, ambos deben tomar un shot.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Envía un mensaje a la persona que pondría celoso/a a tu pareja y sugiérele pasar una noche juntos.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Llama a la pareja de un amigo/a y dile que se vean solos en tu casa, pero sin que su pareja se entere.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Muestrale a tu pareja un video íntimo tuyo con otra persona, si no tienes, cambialo por una conversación caliente que hayas tenido con alguien.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Sube una story con una foto subida de tono y ponle ‘Tengo casa sola hoy, ¿quién quiere venir?’. déjala hasta que termine el juego'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Haz que una persona de tu elección se quite su ropa interior, y luego debes olerla y describir su aroma.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Llama a alguien con quien hayas tenido un encuentro íntimo y dile que fingiste un orgasmo, y que no podías quedarte sin confesárselo.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Sube a tus historias una foto de tu pareja en la posición que el grupo elija. Debes dejarla hasta terminar el juego'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Envíale una nude a tu pareja por Whatsapp y que todos veamos su reaccion, si no tienes puedes ir y tomartela a un lugar privado.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Tienes que hacer lo que el grupo pida durante un minuto, si no aceptas deberás tomar un shot cada que te niegues.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Quédate en ropa interior, y ponle el trasero en la cara a un jugador por elección del grupo durante10 segundos.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Envía un video a tu ex pareja besando a tu pareja actual, acompañado de un mensaje que diga: ''Ahora soy más feliz sin ti''.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Déjate meter el dedo por el an*'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Pasale la lengua desde la pelvis hasta el mentón a tu pareja.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Hazle un twerk a la persona que el grupo elija, debes quitarte una prenda en el proceso.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Gimele al oido a tu pareja mientras acaricias cualquier parte de su cuerpo, Queda a libre elección'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Muestrale un vídeo +18 a tu pareja con el cual te autocomplacerías.'),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", 'El primero que excite a su pareja mas rápido gana, el perdedor toma 5 shots. Cada uno tiene 2 minutos para intentarlo, buena suerte.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Muéstranos el mensaje de texto más reciente que enviaste coqueteándole a alguien.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Dale tu celular a la persona de la derecha para que lo revise por dos minutos, puede hacer lo que quiera.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Señala al amigo tacaño y dile en la cara porque, si no está presente llamalo y lo expones frente a todos.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Sube una historia a whatsapp confesando algo que el grupo decida, debes dejarla hasta terminar el juego.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Llama a tu ex pareja y pregúntale tu mejor y peor cualidad en altavoz.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Cuenta tu mejor chiste; si nadie se ríe, te tomas un shot.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Todos los grupo deben responder cuánto ganan mensualmente y mostrar su cuenta de banco o tomar shot. (sean sinceros)'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Di una mentira y una verdad, si el grupo adivina te debes tomar 3 shots, si no adivinan todo el grupo debe tomar un shot.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Tómale una foto a la persona más fea del grupo y súbela a Instagram diciendo “que se sentirá ser tan feo?”'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Llama a tus padres y diles una mentira tan grande que los haga molestar, si no les importa debes tomar un shot.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Imita el gemido más extraño que hayas escuchado durante el sexo.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Ladra hasta que el grupo decida qué pares.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Intercambia la camiseta con el jugador de la derecha, tenla hasta que termine el juego'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Llama a tu ex y pídele que te cuente su versión de por qué terminaron y pon el altavoz.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Escríbele a alguien que hayas lastimado y pídele perdón por nota de voz, envíale 10.000 mil pesos para que te perdone.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Permite que alguien del grupo te dé una nalgada lo más fuerte posible.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Por favor, Durante toda una ronda hazte en una esquina mirando la pared para reflexionar.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Busca a la persona que más te hizo sufrir en redes sociales, y comentale una foto diciendo que le extrañas.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'El grupo confisca tu teléfono durante 5 minutos, pueden revisarlo si quieren.'),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", 'Pega tu cara a la parte del cuerpo de un jugador por una ronda, sigan jugando con normalidad.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Sube una historia y amenaza públicamente a alguien que te caiga mal.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Llama a la novia o ex de alguien aquí presente e invitala a salir, si no acepta tomas shot.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Usa tu ropa al revés por las siguientes 3 rondas.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Dejate manosear por el participante que quieras durante 10 segundos.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Déjate vendar los ojos y permite que alguien en el grupo te dé un beso sorpresa. (Puede ser en la mejilla) Investiga quién fue.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Realiza un “perreo intenso” con la canción que el grupo elija.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Sacate una media y ponla en tu boca hasta la próxima ronda.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Gime como actriz porno durante 10 segundos.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Un jugador del grupo debe darte 3 latigazos por tu mal comportamiento.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Cambia tu foto de perfil por la peor foto que tengas en galeria, el grupo debe estar de acuerdo. Debes dejarla el resto del juego'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Llama a tu Ex y preguntale cual es tu peor defecto y mejor cualidad.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Tomate una foto en la pose que elijan los jugadores y publicala en Whatsapp.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Llama a tu mamá y dile que consumes drogas y no sabes como dejarla. no le digas que es broma hasta el final de juego.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Envíale un vídeo besando a un jugador en la mejilla a tu actual pareja o ex pareja.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Cuenta un chiste, si nadie se ríe tomas un shot.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Haz un live en Instagram y cuenta como te arrepientes de ser infiel, intenta llorar.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Muestra la última conversación íntima que tuviste con alguien. Si no quieres, toma 3 shots.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Toma un shot de la parte del cuerpo de un jugador, tú decides quién y él/ella decide donde'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'No hables por el resto del juego, o toma shot.'),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", 'Pide un domicilio y, cuando llegue el repartidor intenta convencerlo de unirse al juego con ustedes. Si no lo logras, deberás darle una propina considerada.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Busca en redes sociales una persona con la que hayas estado y escribele a su pareja actual confesándole lo que hicieron en la cama.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Investiga quien es la actual pareja de tu ex, y escribele que es una basura, tratalo/a de lo peor.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Intenta excitar a alguien del grupo en 2 minutos, Si fallas debes darle una propina por el mal servicio.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Haz que alguien del grupo te muerda el cuello y finge que lo disfrutas durante 10 segundos.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Llévate a alguien del grupo donde nadie los pueda ver y muestrale una parte de tu cuerpo que no enseñarías en público, tiene derecho a tocarla.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Llama a tu mamá o papá pidiendole consejos sexuales, debe estar en altavoz y no le puedes decir que estás jugando hasta terminar la ronda.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Debes quitarte una prenda que el grupo elija y quedarte así el resto del juego.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Deja que alguien del grupo publique algo en tus redes sin que puedas verlo hasta que termine el juego.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Envíale un nude a la persona con la que te metiste por despecho y preguntale ¿me extrañaste?'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Muestra al grupo tu galería y deja que elijan la foto más comprometedora para enviarla a un contacto aleatorio.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Pasa una ronda completa solo en ropa interior.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Haz que alguien del grupo te ponga un chupón en el cuello y súbelo a tus historias sin explicar nada.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Muestrale un nude a alguien del grupo, si no tienes una tomas shot.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Llama a la persona con la que perdiste la virginidad y dile que te arrepientes profundamente de estar con él.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Muestra una foto de la persona con la que más te arrepientes de haber estado, ya sea sentimental o sexualmente, y envíale un Whatsapp pidiéndole perdón.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Llama a una amiga/o que tenga novio/a y dile que tuviste una aventura con su pareja.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Muestrale al grupo el vídeo sexual más explícito que has grabado por lo menos durante 10 segundos.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Sube una historia en tu Instagram con una foto muy subida de tono preguntando ¿Quién quiere probarme hoy?'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Mandale una foto a tu ex besándote con alguien más.'),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", 'Siéntate por 10 segundos en la cara del jugador que el grupo decida.')
) AS payload("modeCode", "levelCode", "text")
JOIN "GameMode" gm ON gm."code" = payload."modeCode"
JOIN "Level" lv ON lv."code" = payload."levelCode"
JOIN "ChallengeCategory" cc ON cc."slug" = 'retos';

COMMIT;
