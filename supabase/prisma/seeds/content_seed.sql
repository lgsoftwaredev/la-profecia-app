-- Seed de contenido oficial para La Profecia (preguntas y retos)
-- Fuentes:
-- - /Users/Geral/Downloads/Preguntas y Retos Parejas (1).docx
-- - /Users/Geral/Downloads/Preguntas y Retos Amigos (1).docx
-- Generado: 2026-04-23

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
  "variables",
  "timerSeconds",
  "hasMatchEffect",
  "isOfficial",
  "isActive"
)
SELECT
  gm."id",
  lv."id",
  cc."id",
  payload."text",
  payload."variables",
  payload."timerSeconds",
  payload."hasMatchEffect",
  TRUE,
  TRUE
FROM (
  VALUES
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuál fue la primera impresión que tuviste de [nombre de la pareja]? Sé honesto/a.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué no es tóxico para ti, pero todos piensan que sí lo es?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuánto dinero debe gastar una persona para salir contigo?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], si [nombre de la pareja] te da permiso para pedir algo “sin límites”, ¿qué le pedirías?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuánto es lo menos que has durado en la cama? Cuéntanos la experiencia.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo que más extrañas de tu ex? Cuéntaselo a [nombre de la pareja] y no puedes responder “nada”.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué errores has cometido durante todas tus relaciones?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es el mayor sacrificio que has hecho por tu pareja actual o ex, aunque no lo sepa?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], si pudieras hacer algo ilegal con [nombre de la pareja], ¿qué sería y por qué?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿has espiado el teléfono de [nombre de la pareja] o alguna ex pareja? ¿Qué viste?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cómo reaccionarías y qué harías si descubrieras a [nombre de la pareja] siéndote infiel?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué secreto guardas ahora mismo que [nombre de la pareja] jamás debe descubrir?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿aún tienes agregado a tu ex? Muéstranos la última conversación con él/ella.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuáles son 5 cosas que te gustan de la persona que tienes enfrente?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿dejarías que [nombre de la pareja] revise tu celular ahora mismo? Explica por qué.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿por cuál ex pareja cambiarías a tu pareja actual? Di su nombre y explica el porqué. No puedes decir “ninguno”.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es el recuerdo más especial o divertido que guardas de una noche con tu ex?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], si [nombre de la pareja] cambiara drásticamente su apariencia física, ¿seguirías deseándola o considerarías buscar a alguien más?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], siendo realistas, ¿crees que [nombre de la pareja] puede ser el amor de tu vida?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuál ha sido la escena más tóxica y dramática que armaste por celos y cómo terminó?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿puedes adivinar el color de la ropa interior de [nombre de la pareja]? Si fallas, toma 2 shots.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿cuál es el lugar más loco donde has tenido sexo?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿alguna vez has pensado en otra persona mientras estás en una relación amorosa? Di en quién pensaste y por qué.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿eres vengativo/a? Cuéntanos alguna vez que te hayas vengado de alguien.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿volverías a estar con la persona que te quitó la virginidad?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿te has arrepentido de acostarte con alguien de tu pasado? ¿Por qué y con quién? Muéstranos una foto.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿qué le cambiarías físicamente a [nombre de la pareja]? No se vale decir “nada”.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿dejarías subir contenido explícito a [nombre de la pareja]? ¿Qué opinas acerca de esto? Sé sincero/a.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo más hiriente que has pensado sobre [nombre de la pareja], pero nunca le has dicho?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿cómo te gusta que [nombre de la pareja] te complazca en la cama?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], si [nombre de la pareja] no pudiera tener relaciones íntimas nunca más, ¿te quedarías con él/ella o buscarías a alguien más? Explica tu respuesta.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿qué pareja pasada es mejor en la cama que tu pareja actual? Di su nombre y cuéntanos por qué lo crees.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿te han sido infiel? Di su nombre y ridiculízalo frente a todos; se vale ser creativo/a.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], si tuvieras que ser infiel, ¿con quién lo harías?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿alguna vez has desvirgado a alguien? Di su nombre y cuéntanos cómo fue.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿cuál sería tu plan perfecto para traicionar a [nombre de la pareja]? Detalla cómo lo harías y qué pasos seguirías.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿quién de las personas con las que has estado tenía mal olor en su zona íntima? Muestra una foto y di su nombre al grupo.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿alguna vez has sentido que otra persona te haría más feliz que [nombre de la pareja]? ¿Sí o no, y por qué?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿qué no te gustaría que [nombre de la pareja] encontrara en tu celular?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿puedes contarnos explícitamente y en voz alta cómo fue la vez que perdiste tu virginidad?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿con cuántas personas has tenido sexo? Nómbralas.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿cómo describirías las partes íntimas de [nombre de la pareja] o las tuyas? Debes ser sincero/a.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿con qué frecuencia te autocomplaces? Muestra el último video, foto o pensamiento con el que lo hiciste.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], si pudieras hoy tener el mejor sexo de tu vida, ¿con quién sería? No puedes elegir a [nombre de la pareja].', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿alguna vez te acostaste o hiciste algo comprometedor con la pareja de un amigo? Explica qué hiciste.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿alguna vez has tenido en mente a otra persona durante un momento de intimidad? Cuéntanos en quién pensaste.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿has mentido sobre tu pasado sexual?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿con quién de las personas con las que has estado sexualmente te has arrepentido de estar? Di su nombre y muestra una foto al grupo.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿has fingido alguna vez un orgasmo? Si la respuesta es sí, dinos el nombre de esa persona y por qué.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿qué límite sexual tendrías con [nombre de la pareja] que crees que nunca cruzarías, pero lo harías con alguien más?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿con quién fue la última vez que tuviste sexo sin contar a [nombre de la pareja]? Di su nombre, la fecha y cuenta cómo fue.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo más extremo que has hecho sexualmente que aún no le has contado a [nombre de la pareja] porque temes su reacción?', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo más “sucio” que alguien te ha hecho y que te encantó?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es el aspecto menos atractivo de [nombre de la pareja]? Sé sincero/a y explica por qué piensas así.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿alguna vez has terminado insatisfecho/a en la cama y no se lo dijiste a tu ex o actual pareja?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], si terminaras tu relación actual, ¿quién sería la primera persona con la que tendrías sexo? Di su nombre y muéstranos una foto. Si no contestas, debes tomar 2 shots.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿cuál de tus parejas sexuales tenía la parte íntima más desagradable, pequeña o extraña? Di su nombre y muestra una foto al grupo.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], entre todas las personas de tus contactos, ¿quién crees que es una bestia en la cama? Di su nombre y muestra una foto de él/ella.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿qué tipo de contenido para adultos has visto para autocomplacerte? Descríbelo.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿qué te hizo enamorarte de tu ex novia/o?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es la peor excusa que has usado para terminar con alguien?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es el peor error que cometiste y aún te persigue?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual],¿cuál es tu amigo más tacaño y que es lo peor que ha hecho? Di su nombre y exponlo frente a todos.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué has hecho que puedes catalogar “fui mala persona”?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué crees que diría tu ex si le preguntan cual es tu peor y mejor cualidad?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo más vergonzoso que has hecho en público?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿por qué crees que estás soltero? Explica, detalle a detalle, por qué nadie quiere estar contigo. 😂', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es la mentira más grande que haz dicho?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], mira atentamente a todos: ¿quién es la persona más fea del grupo y por qué? No puedes decir “ninguno”.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué mentira le has dicho a tus padres que ellos no sepan?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo que menos te gusta de [nombre cualquiera]? Debe ser físico y de personalidad.', '{"tokens": ["CURRENT_PLAYER_NAME", "ANY_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo más ridículo que hiciste por despecho?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo más loco que has hecho en una fiesta con tus amigo/as?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿por qué terminó tu última relación? Cuéntanos todo a detalle', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es el peor comportamiento que has tenido frente a personas que te quieren?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuál ha sido el momento más vulnerable que has vivido?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es el secreto más oscuro que llevas contigo? cuéntalo.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿quién fue la persona que más te hizo sufrir sentimentalmente? Cuéntanos quién es y qué hizo', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], cuenta la historia de tu vida en menos de un minuto.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, 60, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo que más te avergüenza de ti?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], describe como te vengarías de una persona que te hizo mucho daño', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], si estuvieras obligado/a a decidir, ¿con cuál pareja actual o ex de [nombre cualquiera] tendrías una relación? Explica por qué.', '{"tokens": ["CURRENT_PLAYER_NAME", "ANY_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿Te acostarías con [nombre de preferencia del jugador] hoy? Si la respuesta es no, [nombre cualquiera] te deberá dar 3 nalgadas.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME", "ANY_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿cuándo fue la última vez que te masturbaste? ¿Y en quién pensaste? Muestra una foto', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo más funable que has hecho con tus amigo/as?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], explícanos explícitamente cómo te imaginarías una noche con [nombre de preferencia del jugador].', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo más cruel que has dicho a alguien en un momento de enojo?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], cuéntale un secreto a [nombre cualquiera] que nadie puede saber al oído y que todos vean su reacción.', '{"tokens": ["CURRENT_PLAYER_NAME", "ANY_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], di en voz alta un hecho que haría enojar a todos en redes sociales, sin censura.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿has hecho o harías algún favor sexual para conseguir lo que quieres? ¿Qué sería?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿alguna vez has desvirgado a alguien? si así es, ¿cuántos años tenía?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿cuándo fue la última vez que tuviste sexo y con quién? Muestra una foto.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], cuéntanos la historia de quien fue el hombre o mujer que más amaste en menos de 2 minutos.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, 120, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿Le robarías la pareja a [nombre de preferencia del jugador]? Si no las conoces o no tienen pareja, pideles que te muestren una foto de su ex o de su pareja actual antes de responder.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], si pudieras besar a alguien dentro o fuera del grupo sin consecuencias, ¿a quién elegirías y por qué?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿cómo describirías a tu ex en la cama? Se explicito.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿cuántas personas te has besado en un día?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿te has aprovechado de alguien alguna vez? Por más mínimo que sea, cuéntanos de quién y cómo fue.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], si tu pareja o amigos supieran todo lo que has hecho en secreto, ¿seguirán confiando en ti?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], ¿alguna vez has manipulado a alguien para obtener algo que querías? ¿Cómo lo hiciste?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿alguna vez te has involucrado con alguien que sabías que estaba en una relación? No mientas. Di su nombre y cuéntanos cómo fue.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], pregúntale a [nombre de preferencia del jugador]: ¿Te gustaría verme mientras me toco?', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], pregúntale a [nombre de preferencia del jugador]: “¿Tendrías sexo hoy conmigo?” Si no lo haces, tomas doble shot.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es el lugar más raro donde te has masturbado?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo que más te gusta que te hagan en la cama? Descríbelo', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es esa inseguridad que siempre tratas de ocultar y nunca admitirías en público? Cuéntalo ahora públicamente.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿Le pedirías a [nombre de preferencia del jugador] que te enseñe un nude? Pídele que te lo enseñe; si no lo convences, debes tomar 2 shots.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿con cuántos de los contactos guardados en tu teléfono has tenido sexo? Enseñalos todos', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es el nombre de la persona con la que estuviste por despecho? Cuenta como jugaste con él/ella', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿cuál es el nombre completo de la persona con quien has tenido la peor experiencia íntima? Muestra una foto al grupo y cuéntanos los detalles.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿qué es lo más manipulador que has hecho para llevar a alguien a la cama? No se vale contestar “nada”', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿con cuántas personas has estado sexualmente? ¿Alguna vez mentiste al respecto?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], sé sincero: ¿Alguna vez has fallado durante el sexo? Cuéntanos qué pasó.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿te arrepientes de la persona con la que perdiste tu virginidad? Di su nombre y muestra una foto.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿prefieres el sexo duro o suave? Menciona el nombre de la última persona con la que lo hiciste así y muestra su foto.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿alguna vez has usado a alguien solo como un objeto para satisfacer tus deseos y luego lo abandonaste?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], describe con detalles el video sexual más explícito que hayas grabado: ¿dónde fue, con quién y cómo sucedió?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿qué secreto íntimo tienes que sería tan devastador que si tu pareja o familia lo supieran se alejaría de ti?', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], si [nombre de preferencia del jugador] te propone tener sexo, ¿lo harías?', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], ¿cuál fue la persona de mayor o menor edad con la que has tenido sexo? Di sus nombre y enseña una foto.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE)
) AS payload("modeCode", "levelCode", "text", "variables", "timerSeconds", "hasMatchEffect")
JOIN "GameMode" gm ON gm."code" = payload."modeCode"
JOIN "Level" lv ON lv."code" = payload."levelCode"
JOIN "ChallengeCategory" cc ON cc."slug" = 'preguntas';

INSERT INTO "Challenge" (
  "modeId",
  "levelId",
  "categoryId",
  "text",
  "variables",
  "timerSeconds",
  "hasMatchEffect",
  "isOfficial",
  "isActive"
)
SELECT
  gm."id",
  lv."id",
  cc."id",
  payload."text",
  payload."variables",
  payload."timerSeconds",
  payload."hasMatchEffect",
  TRUE,
  TRUE
FROM (
  VALUES
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], convence a [nombre de la pareja] de llamar a su madre o padre en altavoz y que le pregunte qué opina de ti; si no lo hace, debes tomar 1 shot.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], dale un cabezazo a [nombre de la pareja] y luego pídele perdón de rodillas.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", 'Haz que un amigo tuyo compre la APP de la profecía, si no lo logras tomas un shot.', '{"tokens": []}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[nombre de la pareja] tiene 1 minuto para pedirte lo que desee y no puedes negarte; si te niegas, toma un shot.', '{"tokens": ["PARTNER_NAME"]}'::jsonb, 60, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], recrea con tu cuerpo la situación del día en que menos has durado en la cama; utiliza lo que tengas a tu alcance para hacerlo lo más realista posible.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], envíale un mensaje a tu ex diciendo “te extraño mucho” y no lo borres hasta terminar el juego.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], déjale tu celular a [nombre de la pareja] durante 3 minutos, desbloqueado, para que revise lo que quiera.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, 180, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], baila la canción que [nombre de la pareja] elija.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], métete los dedos de tu pareja en la boca durante 10 segundos; quien se ría debe tomar un shot.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, 10, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], revisa las fotos eliminadas de [nombre de la pareja].', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], besa en el cachete a cualquier persona que no sea [nombre de la pareja].', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], dile una mentira y una verdad a [nombre de la pareja]; si adivina cuál es cuál, tomas un shot; si no, lo toma [nombre de la pareja].', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], quítate 4 prendas; no podrás volver a usarlas durante el resto del juego.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], nalgueate a ti mismo/a por 15 segundos mientras repites la frase: “He sido un(a) chico/a muy, muy malo/a”.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, 15, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], muéstrale a [nombre de la pareja] una conversación subida de tono de antes de conocerse.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], sube una historia a Instagram etiquetando a tu ex y escribe: “Te extraño”.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], lame el cuello de [nombre de la pareja] lentamente y detente en su boca.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], llama a tus padres y diles que estás loco/a por hacer el amor hoy, y pregúntales si puede ser en su cama.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ponte la ropa interior de [nombre de la pareja].', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], describe cómo fue la noche más caliente de tu vida, pero sin hablar.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], convence a [nombre de la pareja] y hazle un “calzón chino” con la boca.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], haz una videollamada grupal con tu familia y confiesa cuál ha sido el lugar más loco donde has tenido sexo.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], escríbele a una persona aleatoria y dile que tienes muchas ganas de hacer un trío con el/ella.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], cada persona cerca a ti te dará una nalgada por tu mal comportamiento; si alguno no lo hace, tomas doble shot.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], envíale un mensaje de texto a la persona con la que perdiste tu virginidad y dile que la extrañas.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], busca en redes sociales a la persona con la que te hayas arrepentido de estar y envíale un mensaje contándole por qué te arrepientes.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], sube una captura de un chat falso donde diga que te fueron infiel; déjala hasta que se termine el juego.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], sube una publicación en cualquier red social donde indiques que vas a ser papá o mamá; etiqueta a tus familiares y déjala durante todo el juego.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], haz la cara de orgasmo que pondría [nombre de la pareja].', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], llama a tu “casi algo” y pregúntale sobre tu mejor y peor cualidad.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], imita tu posición favorita en la cama y permite que todos te tomen una foto.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], desabrocha el sujetador de [nombre de la pareja] (o quítale los pantalones) usando solo una mano.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], busca a la persona que te fue infiel y escríbele diciéndole que ahora eres más feliz sin él/ella.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], llama a tus padres y confiesa que vendes contenido sexual a cambio de dinero.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], mete la mano completa en la boca de [nombre de la pareja]; si fracasas, debes tomar 2 shots. Elige bien, debes convencerlo.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], llama a un familiar de tu ex y dile que lo/la echas de menos.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], convence a [nombre de la pareja] de tomarse 3 shots; si no lo logras, debes hacerlo tú.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], mete tu lengua en la nariz de [nombre de la pareja] hasta que el grupo decida qué pares.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], permite que [nombre de la pareja], manosee cualquier parte de tu cuerpo, sin límites o tomas shot.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], quítate la ropa interior y ponla frente a todos los jugadores para que la puedan ver.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], busca en tu celular una conversación con alguien con quien hayas tenido una relación íntima y deja que [nombre de la pareja] la lea en voz alta.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], muéstranos el último mensaje que enviaste coqueteándole a alguien.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], dale la clave de tu celular a [nombre de la pareja], porque tiene 1 minuto para buscar un nude en tu teléfono; si no encuentra ninguno, ambos deben tomar un shot.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, 60, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], envía un mensaje a la persona que pondría celoso/a a [nombre de la pareja] y sugiérele pasar una noche juntos.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], llama a la pareja de un amigo/a y dile que se vean a solas en tu casa, pero sin que su pareja se entere.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], muéstrale a [nombre de la pareja] un video íntimo tuyo con otra persona; si no tienes, cámbialo por una conversación subida de tono que hayas tenido con alguien.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], sube una historia con una foto subida de tono y escribe: “Tengo casa sola hoy, ¿quién quiere venir?”. Déjala hasta que termine el juego.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], haz que una persona de tu elección se quite su ropa interior; luego debes olerla y describir su aroma.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], llama a alguien con quien hayas tenido un encuentro íntimo y dile que fingiste un orgasmo y que no podías quedarte sin confesárselo.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], sube en tus historias una foto de [nombre de la pareja] en la posición sexual. Debes dejarla hasta terminar el juego.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, TRUE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], envíale un nude a [nombre de la pareja] por WhatsApp y que todos vean su reacción; si no tienes, puedes ir a tomártelo en un lugar privado.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], debes hacer lo que [nombre de la pareja] elija durante 1 minuto; si no aceptas, deberás tomar un shot cada vez que te niegues.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, 60, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], quédate en ropa interior y siéntate en la cara de [nombre de la pareja] durante 10 segundos.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, 10, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], envía un video a tu ex pareja besando a tu pareja actual, acompañado de un mensaje que diga: “Ahora soy más feliz sin ti”.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], deja que alguien te introduzca el dedo en el ano.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], pasa la lengua desde la pelvis hasta el mentón de [nombre de la pareja].', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], hazle un twerk a la persona que los jugadores elijan; debes quitarte una prenda en el proceso.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], gime al oído de [nombre de la pareja] mientras acaricias cualquier parte de su cuerpo; queda a libre elección.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], muéstrale a [nombre de la pareja] un video +18 con el cual te autocomplacerías.', '{"tokens": ["CURRENT_PLAYER_NAME", "PARTNER_NAME"]}'::jsonb, NULL, FALSE),
    ('COUPLES'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], el primero que excite a su pareja más rápido gana; el perdedor toma 5 shots. Cada uno tiene 2 minutos para intentarlo. Buena suerte.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, 120, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], muéstranos el mensaje de texto más reciente que enviaste coqueteándole a alguien.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], dale tu celular [nombre cualquiera] para que lo revise por dos minutos, puede hacer lo que quiera.', '{"tokens": ["CURRENT_PLAYER_NAME", "ANY_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], señala al amigo tacaño y dile en la cara porque, si no está presente llamalo y lo expones frente a todos.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], sube una historia a WhatsApp confesando lo que [nombre cualquiera] te diga, debes dejarla hasta terminar el juego.', '{"tokens": ["CURRENT_PLAYER_NAME", "ANY_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], llama a tu ex pareja y pregúntale tu mejor y peor cualidad en altavoz.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], cuenta tu mejor chiste; si nadie se ríe, te tomas un shot.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], todos en el grupo deben decir cuánto ganan mensualmente y mostrar su cuenta bancaria o tomar un shot (sean sinceros).', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], di una mentira y una verdad; si el grupo adivina, debes tomar 3 shots; si no adivinan, todo el grupo debe tomar un shot.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], tómale una foto a la persona más fea del grupo y súbela a Instagram diciendo: “que se sentirá ser tan feo?”', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], llama a tus padres y diles una mentira tan grande que los haga molestar, si no les importa debes tomar un shot.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], imita el gemido más extraño que hayas escuchado durante el sexo.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], ladra hasta que [nombre cualquiera] decida que pares.', '{"tokens": ["CURRENT_PLAYER_NAME", "ANY_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], intercambia la camiseta con [nombre de preferencia del jugador], tenla hasta que termine el juego', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], llama a tu ex y pídele que te cuente su versión de por qué terminaron y pon el altavoz.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], escríbele a alguien que hayas lastimado y pídele perdón por nota de voz; envíale 10.000 pesos para que te perdone.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], permite que [nombre de preferencia del jugador] te dé una nalgada lo más fuerte posible.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], durante toda una ronda, quédate en una esquina mirando la pared para reflexionar.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], busca a la persona que más te hizo sufrir en redes sociales y coméntale una foto diciendo que la extrañas.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], el grupo confisca tu teléfono durante 5 minutos, pueden revisarlo si quieren.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, 300, FALSE),
    ('FRIENDS'::"GameModeCode", 'CIELO'::"LevelCode", '[Nombre del jugador actual], pega tu cara en las nalgas de [nombre de preferencia del jugador] por una ronda; sigan jugando con normalidad.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], sube una historia y amenaza públicamente a alguien que te caiga mal.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], llama a la novia o ex de alguien aquí presente e invitala a salir, si no acepta tomas shot.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], usa tu ropa al revés por las siguientes 3 rondas.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], déjate manosear cualquier parte del cuerpo por [nombre de preferencia del jugador] durante 10 segundos.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, 10, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], déjate vendar los ojos y permite que alguien del grupo te dé un beso sorpresa. Luego, investiga quién fue.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], realiza un “perreo intenso” con la canción que [nombre de preferencia del jugador] elija.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], sacale a [nombre cualquiera] una media y ponla en tu boca hasta la próxima ronda.', '{"tokens": ["CURRENT_PLAYER_NAME", "ANY_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], gime como actriz porno durante 10 segundos.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, 10, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], [nombre de preferencia del jugador o cualquiera] debe darte 3 latigazos por tu mal comportamiento.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_OR_ANY_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], cambia tu foto de perfil por la peor foto que tengas en la galería; el grupo debe estar de acuerdo. Debes dejarla durante el resto del juego.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], llama a tu ex y preguntale cual es tu peor defecto y mejor cualidad.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], tomate una foto en la pose que elija [nombre de preferencia del jugador] y publicala en Whatsapp.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], llama a tu mamá o papá y dile que consumes drogas y no sabes como dejarla. No le digas que es broma hasta el final de juego.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], envíale un vídeo besando a [nombre de preferencia del jugador o cualquiera] en la mejilla a tu actual pareja o ex pareja.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_OR_ANY_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], cuenta un chiste; si nadie se ríe tomas un shot.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], haz un live en Instagram y cuenta cómo te arrepientes de ser infiel; intenta llorar.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], muestra al grupo la última conversación íntima que tuviste con alguien; si no quieres, toma 3 shots.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], toma un shot de la parte del cuerpo que [nombre de preferencia del jugador] elija.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], no hables por el resto de la ronda, si fallas tomas 3 shots.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'TIERRA'::"LevelCode", '[Nombre del jugador actual], pide un domicilio y, cuando llegue el repartidor, intenta convencerlo de unirse al juego con ustedes; si no lo logras, deberás darle una propina considerada.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], busca en redes sociales a una persona con la que hayas estado y escríbele a su pareja actual confesándole lo que hicieron en la cama.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], investiga quién es la pareja actual de tu ex y escríbele que es una basura; trátalo/a de lo peor.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], intenta excitar a [nombre de preferencia del jugador] en 2 minutos; si fallas, debes darle una propina por el mal servicio.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, 120, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], haz que [nombre de preferencia del jugador] te muerda el cuello y finge que lo disfrutas durante 10 segundos.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, 10, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], llévate a [nombre de preferencia del jugador] a un lugar donde nadie los vea y muéstrale una parte de tu cuerpo que no enseñarías en público; tiene derecho a tocarla.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], llama a tu mamá o papá pidiéndole consejos sexuales; debe estar en altavoz y no le puedes decir que estás jugando hasta terminar la ronda.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], debes quitarte una prenda que [nombre de preferencia del jugador] decida y quedarte así el resto del juego.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], deja que [nombre cualquiera] publique algo en tus redes sin que puedas verlo hasta que termine el juego.', '{"tokens": ["CURRENT_PLAYER_NAME", "ANY_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], envíale un nude a la persona con la que estuviste por despecho y pregúntale: “¿Me extrañaste?”', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], muestra al grupo tu galería y deja que [nombre cualquiera] elija la foto más comprometedora para enviarla a un contacto aleatorio.', '{"tokens": ["CURRENT_PLAYER_NAME", "ANY_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], pasa una ronda completa solo en ropa interior.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, TRUE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], haz que [nombre de preferencia del jugador] te ponga un chupón en el cuello y súbelo a tus historias sin explicar nada.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], muéstrale un nude a [nombre de preferencia del jugador]; si no tienes, tomas un shot.', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], llama a la persona con la que perdiste la virginidad y dile que te arrepientes profundamente de haber estado con él/ella.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], muestra una foto de la persona con la que más te arrepientes de haber estado (sentimental o sexualmente) y envíale un WhatsApp pidiéndole perdón.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], llama a un/a amigo/a que tenga pareja y dile que tuviste una aventura con su novio/a.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], muéstrale al grupo el video sexual más explícito que hayas grabado durante al menos 10 segundos.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, 10, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], sube una historia en Instagram con una foto muy subida de tono preguntando: “¿Quién quiere probarme hoy?”', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], mándale una foto a tu ex besándote con alguien más.', '{"tokens": ["CURRENT_PLAYER_NAME"]}'::jsonb, NULL, FALSE),
    ('FRIENDS'::"GameModeCode", 'INFIERNO'::"LevelCode", '[Nombre del jugador actual], siéntate por 10 segundos en la cara de [nombre de preferencia del jugador].', '{"tokens": ["CURRENT_PLAYER_NAME", "PLAYER_PREFERENCE_NAME"]}'::jsonb, 10, FALSE)
) AS payload("modeCode", "levelCode", "text", "variables", "timerSeconds", "hasMatchEffect")
JOIN "GameMode" gm ON gm."code" = payload."modeCode"
JOIN "Level" lv ON lv."code" = payload."levelCode"
JOIN "ChallengeCategory" cc ON cc."slug" = 'retos';

COMMIT;
