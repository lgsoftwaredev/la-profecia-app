# Game Flow - La Profecia MVP

## 1. Objetivo del flujo
Garantizar una partida local completa, entretenida y simple de operar en un solo dispositivo, minimizando fricciones entre rondas y turnos.

## 2. Flujo principal de partida
1. Pantalla inicial y seleccion de modo de juego.
2. Configuracion rapida de participantes.
3. Tutorial corto (si aplica para primer uso).
4. Inicio de ronda.
5. Secuencia de turnos por jugador/equipo.
6. Registro de resultados y puntajes.
7. Cierre de ronda y avance.
8. Juicio final / cierre de partida.
9. Resumen de resultados.

## 3. Reglas funcionales base
- El flujo debe ser jugable de punta a punta sin login obligatorio.
- La transicion entre turnos debe ser inmediata y clara.
- El puntaje se actualiza al final de cada turno/ronda segun reglas del modo.
- Debe existir feedback visual del estado actual de la partida.

## 4. Estados de juego recomendados
- `setup`: configuracion inicial.
- `tutorial`: introduccion guiada.
- `in_round`: partida en curso.
- `round_end`: cierre de ronda.
- `final_judgement`: resolucion final.
- `match_end`: resultados finales.

## 5. Criterios de UX para MVP
- Maximo 3-4 acciones para empezar a jugar.
- Texto y CTA claros para pasar el dispositivo entre jugadores.
- Evitar pasos ocultos o configuraciones profundas.
- Mantener consistencia entre modos de juego.

## 6. Casos borde a cubrir
- Reinicio de partida sin cerrar app.
- Salida accidental durante ronda.
- Jugador agregado/retirado antes de iniciar.
- Empate en puntaje al cierre.

## 7. Indicadores minimos a medir
- inicio de partida
- ronda iniciada/finalizada
- partida completada
- abandono antes de finalizar
