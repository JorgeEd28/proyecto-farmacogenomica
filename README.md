# Análisis de microarreglos de genotipificación

Pipeline para análisis de microarreglos Infinium Global Screening Array (GSA) Illumina con 670,000 variantes (600,000 del chip original y 70,000 específicas) para hacer estudios de farmacogenómica.

El objetivo es hacer análisis de asociación de genoma a ciertas condiciones y extraer variantes de interés.

## Datos de entrada

* Archivos de datos crudos DMAP con la cuantificación de señal asociada a las variantes del chip.
* Pares de archivos MAP y PED.

## Datos de salida

* Reporte de benchmarking (comparación) entre archivos MAP y PED obtenidos de archivos de datos crudos DMAP y archivos originales.
* Archivos MAP y PED limpios.
* Archivos VCF por cada muestra con la información de cada variante.
* Reporte global por proyecto de estudios de asociación de genoma (formato PDF).
* Reportes por cada muestra con información genotípica y fenotípica y detalles técnicos (formato PDF).
* Gráficos generados en alta calidad (formatos PNG y PDF).
* Reportes para pacientes (formato PDF).

## Descripción del pipeline

* Validación de archivos MAP y PED originales a partir de datos crudos DMAP (50 muestras)
	* Control de calidad
	* Normalización
	* Generación de archivos MAP y PED
	* Benchmarking entre archivos obtenidos y archivos originales
* Limpieza de archivos MAP y PED
	* Limpieza de nombres de marcadores en archivos MAP
	* Asociación de marcadores con variantes y genes mediante archivo de anotación
	* Fusión de archivos PED por grupos
* Estudios de asociación de genoma con datos PED y MAP
	* Matriz de genotipos
	* Frecuencias alélicas
	* Prueba de asociación alélica y genotípica
	* Análisis estadísticos descriptivos adicionales
	* Generación de archivos VCF
* Generación de reportes
	* Reporte de benchmarking
	* Reporte global por proyecto
	* Reportes por muestra
	* Gráficos generados en alta calidad
	* Reportes para pacientes