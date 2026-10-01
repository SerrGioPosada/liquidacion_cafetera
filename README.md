# Sistema de Liquidación de Cosecha Cafetera

Proyecto desarrollado para la asignatura Programación 3, enfocado en la aplicación de fundamentos de programación funcional y manipulación de colecciones en Elixir.

---

## Integrantes del Grupo
* Sergio Posada García
* Jhonatan Perilla Betancur
* Sara Benjumea Gallego

---

## Descripción del Sistema
El sistema procesa y valida los registros de pesajes diarios realizados durante la cosecha semanal de una finca cafetera. Realiza la verificación de integridad de datos, aplica las reglas de negocio de liquidación financiera (tarifas, bonificaciones por rendimiento y descuentos por calidad o alimentación) y genera reportes estadísticos agregados.

### Arquitectura de Módulos
* **Datos (datos.exs):** Proveedor primario de información base (recolectores, lotes y pesajes).
* **Validacion (validacion.exs):** Pipeline puro de validación mediante with para detectar y clasificar registros anómalos.
* **Liquidacion (liquidacion.exs):** Módulo funcional puro para el cálculo de montos, bonificaciones y deducciones por recolector.
* **Reportes (reportes.exs):** Generador funcional de reportes estructurados R1-R8 e implementación de ranking/2 con Keyword Lists.
* **Util (util.exs):** Funciones de apoyo e interacción de consola (E/S).
* **Programa (programa.exs):** Punto de entrada principal (main/0) que orquesta el flujo de ejecución e interacción.

---

## Requisitos de Ejecución

* **Elixir:** Versión 1.14 o superior instalada en el entorno local.
* **Git:** Para la gestión del repositorio y la verificación de historial.

---

## Instrucciones de Compilación y Ejecución

Siga los comandos exactos en el orden especificado para compilar los módulos de apoyo y ejecutar el script principal:

1. **Compilación de Módulos de Apoyo:**
   elixirc datos.exs validacion.exs liquidacion.exs reportes.exs util.exs

2. **Ejecución del Programa Principal:**
   elixir programa.exs

Nota: Cada vez que el archivo datos.exs sea modificado o reemplazado por el docente, es obligatorio volver a ejecutar el comando de compilación del Paso 1 antes de iniciar el programa.

---

## Reglas de Negocio Implementadas

1. **Jerarquía de Validación de Pesajes:**
   - :recolector_desconocido (Existencia en padrón)
   - :lote_desconocido (Existencia en catálogo de lotes)
   - :dia_invalido (Entero acotado en el rango 1 a 6)
   - :kilos_fuera_de_rango (Rango mayor a 0 y hasta 250 kg)
   - :porcentaje_invalido (Rango de 0 a 100% de granos verdes)

2. **Liquidación Financiera:**
   - **Tarifa Base:** $1.000 / kg
   - **Calidad (Grano Verde):**
     - Hasta 2%: +5% bonificación sobre pesaje
     - Mayor a 2% y hasta 5%: Sin ajuste
     - Mayor a 5% y hasta 10%: -10% penalización
     - Mayor a 10%: -30% penalización
   - **Productividad:** Bonificación de $8.000 por cada día con acumulado de 120 kg o más de pesajes válidos.
   - **Alimentación:** Descuento de $12.000 por día trabajado a recolectores inscritos al servicio (alimentacion: true).

---

## Entregables del Proyecto
* **Archivos .exs:** Código fuente en Elixir etiquetado por integrante.
* **Documento_Parcial1.pdf:** Documento técnico con Análisis de Diseño (Parte A), Análisis Metodológico de R6, Investigación (Parte C) y Bitácora de Inteligencia Artificial (Parte D).