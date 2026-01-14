# Guía para Contribuir a KooL Hyprland Projects (Ubuntu)

[Ver versión en inglés](./CONTRIBUTING.md)

¡Gracias por tu interés en contribuir! Aceptamos correcciones de errores, nuevas características, mejoras de documentación y otras mejoras generales.

## Primeros pasos

1. Haz un fork del repositorio en tu cuenta de GitHub.
    - Botón **Fork** o [enlace directo](https://github.com/JaKooLit/Ubuntu-Hyprland/fork).
    - Desmarca la opción de copiar solo la rama `main` si deseas incluir otras ramas.

2. Clona tu fork en tu equipo (nota: este repo usa ramas por versión):

    ```bash
    git clone --depth=1 -b `branch-versions` https://github.com/JaKooLit/Ubuntu-Hyprland.git
    ```

3. Crea una rama para tus cambios:

    ```bash
    git checkout -b tu-rama
    ```

4. Realiza tus cambios y crea un commit con mensaje descriptivo (sigue la [guía de commits](./COMMIT_MESSAGE_GUIDELINES.md)):

    ```bash
    git commit -m "feat: add a new feature"
    ```

5. Sube tu rama a tu fork:

    ```bash
    git push origin tu-rama
    ```

6. Abre un **pull request** contra la rama de desarrollo adecuada.
    - Usa la [plantilla de PR](https://github.com/JaKooLit/Ubuntu-Hyprland/blob/main/.github/PULL_REQUEST_TEMPLATE.md) y añade etiquetas relevantes.

## Directrices

- Sigue el estilo de código del proyecto.
- Actualiza la documentación cuando sea necesario.
- Añade tests si aplica y verifica que pasen.
- Mantén el PR enfocado; evita cambios no relacionados.
- Revisa estos archivos útiles:
    - [bug.yml](https://github.com/JaKooLit/Ubuntu-Hyprland/blob/main/.github/ISSUE_TEMPLATE/bug.yml)
    - [feature.yml](https://github.com/JaKooLit/Ubuntu-Hyprland/blob/main/.github/ISSUE_TEMPLATE/feature.yml)
    - [documentation-update.yml](https://github.com/JaKooLit/Ubuntu-Hyprland/blob/main/.github/ISSUE_TEMPLATE/documentation-update.yml)
    - [PULL_REQUEST_TEMPLATE.md](https://github.com/JaKooLit/Ubuntu-Hyprland/blob/main/.github/PULL_REQUEST_TEMPLATE.md)
    - [COMMIT_MESSAGE_GUIDELINES.md](./COMMIT_MESSAGE_GUIDELINES.md)
    - [CONTRIBUTING.md](./CONTRIBUTING.md)
    - [LICENSE](https://github.com/JaKooLit/Ubuntu-Hyprland/blob/main/LICENSE.md)
    - [README.md](https://github.com/JaKooLit/Ubuntu-Hyprland/blob/main/README.md)

## Contacto

Para preguntas, usa [GitHub Discussions](https://github.com/JaKooLit/Ubuntu-Hyprland/discussions) o el [Servidor de Discord](https://discord.gg/RZJgC7KAKm).
