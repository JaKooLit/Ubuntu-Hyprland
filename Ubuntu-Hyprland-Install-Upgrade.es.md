# Guía de Instalación y Actualización de Ubuntu-Hyprland (26.04)

> [!ADVERTENCIA]
> Esta guía es **exclusiva** para Ubuntu 26.04 “Resolute Raccoon”. El instalador aborta en otras versiones porque los repositorios oficiales aún publican Hyprland 0.52.2. Usa el branch principal para 24.04–25.10 y Debian-Hyprland para Debian/Trixie.

## Contenido

1. [Resumen](#resumen)
2. [Novedades en la rama 26.04](#novedades-en-la-rama-2604)
3. [Referencia de flags](#referencia-de-flags)
4. [Gestión central de versiones](#gestión-central-de-versiones)
5. [Métodos de instalación](#métodos-de-instalación)
6. [Flujos de actualización](#flujos-de-actualización)
7. [Pruebas con dry-run](#pruebas-con-dry-run)
8. [Logs](#logs)
9. [Uso avanzado](#uso-avanzado)
10. [Solución de problemas](#solución-de-problemas)

## Resumen

- `install.sh` detecta Ubuntu 26.04, muestra una advertencia y te deja elegir entre:
  - Mantener el paquete de los repositorios (Hyprland 0.52.2).
  - Compilar Hyprland + dependencias desde código fuente (recomendado).
- `update-hyprland.sh` replica la herramienta usada en Debian pero adaptada al conjunto de scripts de Ubuntu.
- `dry-run-build.sh` compila cada módulo con `DRY_RUN=1` y genera un resumen PASS/FAIL.
- `hypr-tags.env` concentra todas las versiones (actualizado a Hyprland v0.53.3).
- `re2` se compila desde la fuente oficial de Google para que `hyprctl` aproveche las API con `string_view` (la versión del repo de Ubuntu es demasiado vieja).

## Novedades en la rama 26.04

| Cambio | Descripción |
| --- | --- |
| Verificación estricta de versión | El instalador se niega a ejecutarse fuera de Ubuntu 26.04. |
| Opción interactiva “Source build” | whiptail pregunta si deseas compilar desde código. Elegirla purga automáticamente los paquetes Hyprland de Ubuntu y limpia `/usr/local`. |
| Nuevas utilidades | `update-hyprland.sh`, `dry-run-build.sh` y `install-scripts/hyprwire.sh`. |

## Referencia de flags

### install.sh
- `--from-source`: Forzar compilación (también mediante `HYPR_FROM_SOURCE=1`).
- `--preset <archivo>`: Ejecutar con elecciones predefinidas.

### update-hyprland.sh
- `--dry-run` / `--install`
- `--fetch-latest`, `--force-update`, `--set CLAVE=valor`
- `--only lista`, `--skip lista`
- `--bundled` / `--system`
- `--with-deps`: reinstala dependencias (se ejecuta automáticamente cuando usas `--install`, a menos que lo desactives).
- `--without-deps`: omite el instalador de dependencias si ya sabes que el sistema está preparado.
- `--no-fetch`, `--auto`, `--via-helper`

### dry-run-build.sh
- `--with-deps`, `--only`, `--skip`

## Gestión central de versiones

Archivo `hypr-tags.env`:

```bash
HYPRLAND_TAG=v0.53.3
AQUAMARINE_TAG=v0.10.0
HYPRUTILS_TAG=v0.11.0
HYPRLANG_TAG=v0.6.8
HYPRGRAPHICS_TAG=v0.5.0
HYPRWAYLAND_SCANNER_TAG=v0.4.5
HYPRLAND_PROTOCOLS_TAG=v0.7.0
HYPRLAND_QT_SUPPORT_TAG=v0.1.0
HYPRLAND_QTUTILS_TAG=v0.1.5
HYPRWIRE_TAG=v0.2.1
WAYLAND_PROTOCOLS_TAG=1.46
```

Actualiza o fuerza versiones con:

```bash
./update-hyprland.sh --fetch-latest --dry-run
./update-hyprland.sh --fetch-latest --force-update --install
./update-hyprland.sh --set HYPRLAND=v0.53.3 --install
```

## Métodos de instalación

1. **Paquete oficial (0.52.2)**  
   - Selecciona “Ubuntu repo” en el prompt.  
   - Ejecuta `install-scripts/hyprland-ppa.sh`.

2. **Compilación desde código (recomendado)**  
   - Selecciona “Source build” o pasa `--from-source`.  
   - El instalador purga los paquetes `hyprland`, limpia `/usr/local` y construye en orden:  
     `wayland-protocols-src → hyprland-protocols → hyprutils → hyprlang → hyprwayland-scanner → aquamarine → hyprgraphics → hyprland-qt-support → hyprland-qtutils → hyprwire → hyprland`.

3. **Mantenimiento sin interfaz**  
   - Usa `update-hyprland.sh` para instalar o probar nuevas versiones sin ejecutar `install.sh`.

## Flujos de actualización

- **Permanecer en 0.52.2**: Reejecuta `install.sh` y elige “Ubuntu repo”.
- **Migrar a Hyprland ≥0.53**:
  ```bash
  ./update-hyprland.sh --set HYPRLAND=v0.53.3 --dry-run
  ./update-hyprland.sh --install --only hyprland
  ```
- **Actualizar librerías específicas**:
  ```bash
  ./update-hyprland.sh --fetch-latest --install --only hyprutils,hyprlang,aquamarine
  ```

## Pruebas con dry-run

```bash
./dry-run-build.sh
./update-hyprland.sh --fetch-latest --dry-run
./dry-run-build.sh --only hyprland --with-deps
```

Ventajas: validar combinaciones de etiquetas, integrar en CI, detectar fallos antes de instalar en `/usr/local`.

## Logs

```
Install-Logs/
├── 01-Hyprland-Install-Scripts-*.log
├── install-*_modulo.log
├── update-hypr-*.log
└── build-dry-run-*.log
```

Comandos útiles:

```bash
ls -t Install-Logs/*.log | head -1 | xargs less
grep -i "error" Install-Logs/install-*hyprland*.log
```

## Uso avanzado

- Mantén múltiples copias de `hypr-tags.env` (estable vs experimental).
- `./update-hyprland.sh --auto --install` reintenta con librerías embebidas si las del sistema fallan.
- Exporta `PKG_CONFIG_PATH`, `MAKEFLAGS`, etc., antes de ejecutar las herramientas si necesitas rutas personalizadas.

## Solución de problemas

1. **Hyprland no aparece en PATH**  
   - Revisa `Install-Logs/install-*_hyprland.log`.  
   - Asegura que `/usr/local/lib` esté en `/etc/ld.so.conf.d/usr-local.conf`.

2. **Errores de dependencias CMake**  
   - `./update-hyprland.sh --install --only wayland-protocols-src,hyprutils,hyprlang`.

3. **Se reinstalaron paquetes del repo accidentalmente**  
   - Ejecuta de nuevo `install.sh` en modo Source (volverá a purgarlos).

4. **Volver al paquete del repo**  
   - `HYPR_FROM_SOURCE=0 ./install.sh` o elige “Ubuntu repo” cuando aparezca la pregunta.

Para dudas sobre dotfiles, visita el README principal o el wiki de Hyprland-Dots.
