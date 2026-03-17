# Documentación Backend FINARA — LaTeX

Documentación técnica del backend Node.js + Express + MySQL del proyecto FINARA.

**Trabajo Terminal:** 2026-A062  
**Institución:** IPN — Escuela Superior de Cómputo  
**Generado con:** pdfLaTeX + BibTeX

---

## Estructura de Archivos

```
latex_backend/
├── main.tex                     # Orquestador principal (compilar este)
├── config.tex                   # Paquetes, estilos, colores, comandos
├── portada.tex                  # Portada IPN-ESCOM
├── introduccion.tex             # Cap. 1: Propósito, alcance, audiencia
├── stack_tecnico.tex            # Cap. 2: Node.js, Express, MySQL, dependencias
├── arquitectura_backend.tex     # Cap. 3: MVC por capas, estructura, flujos
├── endpoints_api.tex            # Cap. 4: 46 endpoints documentados
├── base_datos.tex               # Cap. 5: 10 tablas, DDL, triggers, ER
├── autenticacion_seguridad.tex  # Cap. 6: JWT, bcrypt, rate limit, XSS
├── decisiones_diseno.tex        # Cap. 7: Comparativas, justificaciones
├── integracion_frontend.tex     # Cap. 8: Consumo desde Flutter
├── changelog.tex                # Cap. 9: Versiones 1.0.0–4.0.0
├── referencias_backend.bib      # 34 referencias técnicas (IEEE style)
└── README.md                    # Este archivo
```

---

## Compilar en Overleaf (recomendado)

1. Crear proyecto nuevo en [overleaf.com](https://overleaf.com)
2. Subir **todos** los archivos `.tex`, `.bib` y este `README.md`
3. Seleccionar `main.tex` como documento principal
4. Configurar compilador: **Settings → Compiler → pdfLaTeX**
5. Clic en **Recompile**

El PDF se genera automáticamente. Si hay errores de bibliografía, hacer clic en **Recompile** una segunda vez.

---

## Compilar localmente

Requiere: TeX Live 2022+ o MikTeX con paquetes completos.

```bash
# Primera compilación
pdflatex main.tex

# Compilar bibliografía
bibtex main

# Dos compilaciones más para resolver referencias cruzadas
pdflatex main.tex
pdflatex main.tex
```

Con `latexmk` (automatiza los pasos):
```bash
latexmk -pdf main.tex
```

---

## Resultado Esperado

Al compilar `main.tex` se genera un PDF de ~50 páginas:

| Capítulo | Páginas aprox. |
|---|---|
| Portada + Índices | 5 |
| Cap. 1: Introducción | 4 |
| Cap. 2: Stack Técnico | 7 |
| Cap. 3: Arquitectura | 7 |
| Cap. 4: Endpoints API | 15 |
| Cap. 5: Base de Datos | 8 |
| Cap. 6: Autenticación | 6 |
| Cap. 7: Decisiones | 5 |
| Cap. 8: Integración Frontend | 4 |
| Cap. 9: Changelog | 3 |
| Bibliografía | 2 |
| **Total** | **~66** |

---

## Personalización

### Agregar tu nombre en la portada

Editar `portada.tex`, sección de la tabla de autores:
```latex
Alumno 1: & [Tu nombre completo aquí] \\
Boleta:   & [Tu número de boleta] \\
```

### Agregar los logos IPN y ESCOM

1. Colocar `ipn_logo.png` y `escom_logo.png` en la misma carpeta
2. En `portada.tex`, descomentar las líneas:
```latex
% \includegraphics[width=\textwidth]{ipn_logo.png}
% \includegraphics[width=\textwidth]{escom_logo.png}
```

### Cambiar el nombre del director TT

Editar `portada.tex`:
```latex
Director: & [Nombre del director TT] \\
```

---

## Paquetes LaTeX Requeridos

Todos incluidos en TeX Live Full y disponibles en Overleaf:

- `babel` (español)
- `geometry`
- `xcolor`
- `listings` + `listingsutf8`
- `booktabs`, `longtable`, `tabularx`
- `tikz` + `arrows.meta`, `positioning`
- `tcolorbox`
- `fancyhdr`
- `hyperref`
- `biblatex` con backend `bibtex`
- `setspace`, `enumitem`, `microtype`
