# GCE – Guerra Civil Española para Antistasi Ultimate

Mod de **facciones** (templates) que ambienta Antistasi Ultimate en la Guerra Civil
Española (1936-1939). Todo es **gratuito**.

| Rol en Antistasi | Bando | Archivo |
|---|---|---|
| Ocupantes / Invasores | Ejército Nacional (Regulares, Falange, Requetés) | `GCE_AI_Nacionales.sqf` |
| Ocupantes (modo anarquista) | República: Ejército Popular, Guardia de Asalto, Brigadas Internacionales | `GCE_AI_Republica.sqf` |
| Invasores | Legión Cóndor + CTV | `GCE_AI_Condor.sqf` |
| Rebeldes (jugadores) | República (Ejército Popular, Brigadas Internacionales) | `GCE_Reb_Republica.sqf` |
| Rebeldes (alternativa) | Milicias CNT-FAI (mismo equipo, bandera rojinegra) | `GCE_Reb_CNT.sqf` |
| Civiles | Población española de los años 30 | `GCE_CIV.sqf` |

### Modos de juego
| Modo | Ocupantes | Invasores | Rebeldes |
|---|---|---|---|
| Clásico (preseleccionado) | GCE Ejército Nacional | GCE Legión Cóndor | GCE República |
| Anarquista | GCE República (gobierno) | GCE Ejército Nacional (invasor) | GCE Milicias CNT-FAI |

Puedes mezclarlos como quieras en la pestaña de facciones de Antistasi.

Mapa recomendado: **Altis** (los bandos GCE salen arriba de la lista en ese mapa).

## Mods necesarios (Steam Workshop, gratis)
1. CBA_A3
2. Antistasi Ultimate - Mod
3. IFA3 AIO
4. Northern Fronts

Opcionales (si están cargados, los templates los usan solos):
- WW2 Armored Cars / WW2 Tanks → Panzer II, Sd.Kfz 231…
- Flying Legends → Bf 109, Ju 52, Ju 86
- Secret Weapons → He 111, I-16 "Mosca" para la República

## Estructura
```
mod.cpp                          info que se ve en el launcher
addons/gce_uniformes/            PBO 2 (solo Arma base): monos y boinas
  config.cpp                     GCE_U_Mono_Azul/_Mahon/_Negro/_Caqui, GCE_H_Boina_Roja/_Negra
  data/*_co.paa                  texturas (tools/make_uniforms.py)
addons/gce_misiones/             PBO 4: misiones nuevas y jefe de escuadra (sirve con cualquier facción)
  functions/menu/                qué misiones se pueden elegir (fn_availability.sqf)
  functions/misiones/            una misión por archivo (fn_m_*.sqf)
  functions/jefe/                jefe de escuadra
addons/gce_gorros/               PBO 3 (necesita Northern Fronts): gorrillos
  config.cpp                     GCE_H_Gorrillo_Negro / _Rojo (retextura de la pilotka)
addons/gce_main/
  $PBOPREFIX$                    GCE\addons\gce_main
  config.cpp                     registra los 4 bandos en Antistasi (class A3A >> Templates)
  Templates/
    GCE_AI_Nacionales.sqf        ocupantes
    GCE_AI_Condor.sqf            invasores
    GCE_Reb_Republica.sqf        rebeldes: tienda de vehículos y equipo inicial
    GCE_Reb_Vehicle_Attributes.sqf  PRECIOS de la tienda rebelde
    GCE_CIV.sqf                  civiles
    GCE_Vehicle_Attributes.sqf   coste de los vehículos enemigos
```

## Cómo cambiar vehículos, armas y precios
- **Tienda rebelde** (`GCE_Reb_Republica.sqf`): `vehiclesBasic` (el "quad"),
  `vehiclesLightUnarmed` (el "off-road"), `vehiclesTruck` (el camión), `vehiclesAT`,
  `staticMGs`… Pon cualquier classname de un mod cargado.
- **Precios**: `GCE_Reb_Vehicle_Attributes.sqf` → `["classname", ["rebCost", precio]]`.
- **Equipo inicial**: `_initialRebelEquipment` en `GCE_Reb_Republica.sqf`.
- **Armas enemigas**: bloque "GCE: armas de época" en los templates de IA.
- Para encontrar classnames: en el editor de Arma, clic derecho en un objeto → *Log → Copy classname*,
  o en el arsenal virtual con la consola de depuración.

## Misiones de la Guerra Civil
Acércate a Petros y usa **"Misiones de la Guerra Civil"**. Las misiones que no tienen sentido
en ese momento salen en gris con el motivo, y no se pueden elegir. Solo una misión GCE a la vez.

| Misión | Solo disponible si… | Recompensa |
|---|---|---|
| ¡No pasarán! | hay un pueblo **nuestro** en rango y una base enemiga que pueda atacarlo | dinero, RR. HH., apoyo |
| Volar el puente | hay un puente de carretera en **zona enemiga** en rango (no repetido) | dinero |
| Colectivizar la finca | hay una finca, mina o fábrica **enemiga** en rango: primero la tomas (60 min) y luego aguantas 10 min el contraataque | dinero, RR. HH., apoyo |
| La imprenta | hay una ciudad en rango (a más de 600 m) con apoyo rebelde < 80 % | mucho apoyo |
| Refugio antiaéreo | tenemos una **estática antiaérea** a < 800 m de un pueblo nuestro y el enemigo tiene aeródromo con aviones | apoyo, dinero por avión derribado |
| El oro de la República | la costa está a menos de **3 km** del cuartel (`GCE_oroDistanciaMax`) y hay carretera | mucho dinero |
| Liberar el penal | hay un puesto o base enemiga en rango | RR. HH. (cada preso rescatado) |

"En rango" = la distancia de misiones que tengas configurada en Antistasi.

- **¡No pasarán!** y **Refugio antiaéreo** no empiezan hasta que un jugador llega al pueblo
  (90 s / 2 min después), con un máximo de 10 minutos de espera.
- **Volar el puente** solo cuenta cargas puestas por rebeldes, y le quita recursos de ataque al enemigo.
- **Liberar el penal** termina cuando todos los presos liberados llegan al cuartel.
- Cada misión tiene un **tiempo de espera** antes de repetirse: puente 15 min, finca e imprenta 20,
  No pasarán, refugio y penal 30, el oro 90.

## Jefe de escuadra
Mira a un recluta de tu grupo y usa **"Nombrar jefe de escuadra"** (cuesta 100). A partir de ahí él
reparte los blancos: antitanques a los vehículos, ametralladoras a los grupos y el resto al enemigo
más cercano, sin amontonarse. Avisa por radio de los vehículos. **Tú sigues mandando el movimiento**
y el modo de combate (si mandas no disparar, solo apuntan). Solo un jefe por grupo.

## Morral de sanitario
Mochila del equipo inicial (ilimitada) con sitio para el Medikit (en el PBO `gce_uniformes`).
Los **médicos** rebeldes que recluta la IA la llevan puesta automáticamente, con su material
y un Medikit (lo hace `gce_misiones`). Solo se añade al arsenal en partidas nuevas.

## Banderas
Se generan con `python3 tools/make_flags.py` (necesita Pillow) y salen en:
- `addons/gce_main/data/flags/*_co.paa`: bandera del mástil y de la pantalla de selección.
- `addons/gce_main/data/markers/*_co.paa`: icono del mapa.
- `art/flags/*.png`: copias en PNG por si quieres retocarlas. Después conviértelas con ImageToPAA
  (Arma 3 Tools) usando el mismo nombre.

Para añadir otra bandera, crea una función de dibujo en `tools/make_flags.py` y añádela a `BANDERAS`.

## Compilar y publicar
Hay **cuatro PBO**. Empaqueta cada carpeta de `addons/` con su prefijo y ponlos todos en `@GCE/addons`:
| Carpeta | Prefijo |
|---|---|
| `gce_main` | `GCE\addons\gce_main` |
| `gce_uniformes` | `GCE\addons\gce_uniformes` |
| `gce_gorros` | `GCE\addons\gce_gorros` |
| `gce_misiones` | `GCE\addons\gce_misiones` |

1. Instala **Arma 3 Tools** (Steam → Biblioteca → Herramientas).
2. Con **Addon Builder**: origen `addons/gce_main`, destino `@GCE/addons`,
   y en opciones pon el prefijo `GCE\addons\gce_main`. Se genera `gce_main.pbo`.
3. Copia `mod.cpp` dentro de `@GCE/`.
4. Prueba: carga `@GCE` + las dependencias, entra en Antistasi Ultimate en Altis y elige los
   bandos "GCE …" en la pantalla de configuración.
5. Publica con **Arma 3 Publisher** marcando las dependencias del Workshop.

## Pendiente (siguientes fases)
- [x] Banderas propias (rojigualda, tricolor republicana, CNT-FAI) + marcadores de mapa.
- [x] Monos de miliciano (azul, mahón, negro, caqui) para CNT-FAI y milicias republicanas.
- [x] Boina roja de requeté, boina negra, gorrillos negro y rojo.
- [ ] Pañuelo rojinegro (no existe ningún accesorio de cuello que sirva de base).
- [ ] Material italiano del CTV (no hay en IFA3/Northern Fronts; buscar otro mod gratis o retexturas).
- [ ] Probar en partida y ajustar classnames que den error en el RPT.
- [ ] Bando "Rivales" (opcional).

Basado en templates de Antistasi Ultimate (MIT) – ver `THIRD_PARTY_NOTICES.md`.
