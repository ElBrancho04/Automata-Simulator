# Simulador Interactivo de Autómatas Celulares

[![Elm](https://img.shields.io/badge/Elm-0.19.1-60B5CC?logo=elm&logoColor=white)](https://elm-lang.org/)

Un simulador interactivo del **Juego de la Vida de Conway** y otros autómatas celulares, desarrollado en **Elm 0.19.1** como trabajo final de la asignatura **Programación Declarativa**.

## Descripción

Este proyecto proporciona una herramienta completa para experimentar con distintos patrones y reglas de evolución de autómatas celulares, demostrando la aplicación práctica del paradigma funcional puro en un entorno interactivo.

## Características Principales

- **Motor de reglas configurables** en formato B/S (Birth/Survival)
- **Dos modalidades de borde**: toroidal (wrap-around) y finito
- **Control de simulación**: play, pausa y ejecución paso a paso
- **Generación automática** de patrones aleatorios
- **Escalado dinámico** de celdas (5px – 40px)
- **Grillas de hasta 100×100** con rendimiento optimizado
- **Detección automática** de patrones y tendencias

## Sistema de Análisis de Patrones

El simulador incluye algoritmos de detección que identifican automáticamente:

- **Osciladores** – Patrones periódicos con período detectado
- **Naves espaciales** – Objetos con dirección y velocidad
- **Patrones estáticos** – Configuraciones que no evolucionan
- **Tendencias globales** – Crecimiento, extinción o comportamiento caótico

## Catálogo de Patrones Predefinidos

| Patrón | Categoría | Descripción |
|--------|-----------|-------------|
| **Glider** | Naves | Nave diagonal básica, el patrón móvil más simple |
| **LWSS** | Naves | Nave ligera horizontal, movimiento rápido |
| **Pulsar** | Osciladores | Oscilador de período 3 |
| **Diamond Ring** | Osciladores | Oscilador complejo con simetría |
| **Dinner Table** | Osciladores | Oscilador de período 2 |
| **Diehard** | Longevos | Patrón de vida prolongada (130+ generaciones) |
| **Acorn** | Crecientes | Patrón de crecimiento acelerado |
| **Ants** | Decrecientes | Patrón que decrece hasta estabilizarse en un cuadrado 2x2 |
| **Gosper Glider Gun** | Generadores | Generador continuo de planeadores |

## Instrucciones de Ejecución

### Prerrequisitos

- [Elm 0.19.1](https://guide.elm-lang.org/install/) instalado globalmente

### Pasos

```bash
# Clonar el repositorio
git clone https://github.com/ElBrancho04/automata-simulator.git

# Acceder al directorio del proyecto
cd automata-simulator

# Compilar el proyecto
elm make src/View/Main.elm --output=main.js

# Abre index.html en tu navegador web
```

**Nota**: La aplicación se ejecuta en `index.html` y no requiere servidor local.

## Estructura del Proyecto

```
src/
├── Core/
│   ├── Automata.elm        # Motor de evolución de generaciones
│   ├── Grid.elm            # Operaciones sobre grillas (Array-based)
│   ├── Rules.elm           # Parseo y aplicación de reglas B/S
│   ├── PatternAnalysis.elm # Algoritmos de detección y análisis
│   ├── Patterns.elm        # Catálogo de patrones predefinidos
│   └── Types.elm           # Tipos y modelos de datos centrales
├── State/
│   └── States.elm          # Máquina de estados y lógica de actualización
└── View/
    └── Main.elm            # Interfaz de usuario y renderización

elm.json                     # Manifiesto de dependencias
index.html                   # Punto de entrada HTML
```

## Dependencias

```json
{
  "elm/core": "1.0.5",
  "elm/html": "1.0.0",
  "elm/browser": "1.0.2",
  "elm/random": "1.0.0",
  "elm/time": "1.0.0"
}
```

## Cómo Usar la Aplicación

1. **Configuración inicial**: Define el tamaño de la grilla (1–100), tipo de borde y reglas
2. **Preparación de patrones**: 
   - Carga un patrón predefinido, o
   - Dibuja manualmente en la grilla, o
   - Genera aleatorio
3. **Ejecución**: Inicia la simulación y observa la evolución
4. **Análisis**: El sistema detecta automáticamente el tipo de patrón en cada generación

## Detalles Técnicos

### Optimizaciones de Rendimiento

- **Grillas con Arrays**: Migración de `List (List Cell)` a `Array (Array Cell)` para acceso O(1)
- **Análisis de patrones optimizado**: Early-out mediante comparación de conteos de celdas vivas
- **Detección incremental**: Historial limitado a 20 generaciones para evitar acumulación de memoria

### Algoritmos Principales

- **Detección de traslación**: Identifica naves mediante búsqueda acotada de desplazamientos
- **Detección de oscilación**: Encuentra períodos de repetición en el historial
- **Análisis de tendencia**: Evalúa crecimiento, extinción y caos mediante estadísticas locales

## Objetivos Académicos Alcanzados

Este proyecto demuestra:

✅ Aplicación rigurosa del paradigma funcional puro  
✅ Gestión compleja de estado mediante técnicas declarativas  
✅ Implementación de algoritmos avanzados de análisis  
✅ Arquitectura escalable y mantenible  
✅ Construcción de interfaz interactiva y receptiva  

## Notas de Desarrollo

El proyecto fue desarrollado siguiendo principios de **Programación Declarativa**:

- **Sin mutaciones**: Toda transformación es funcional e inmutable
- **Tipado estático**: Elm previene errores en tiempo de compilación
- **Arquitectura The Elm Architecture (TEA)**: Model-View-Update para gestión clara del estado
- **Composición modular**: Separación clara entre Core (lógica), State (gestión) y View (presentación)
