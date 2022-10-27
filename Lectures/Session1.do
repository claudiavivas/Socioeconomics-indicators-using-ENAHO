// ***********************************************************
// Curso: 	 Análisis de Indicadores Sociodemográficos 
//           con la Encuesta Nacional de Hogares - ENAHO
// Sesión:	 02
// Tema: 	 Introducción al software Stata
// Fecha: 	 21/10/2022
// ***********************************************************



// **********************************************************************
// 2. Establecer entorno de trabajo (cambiar configuración predeterminada)
// **********************************************************************

* cerrar todos los archivos
clear all
* continuar con la ejecuciòn de comandos
set more off



// *****************************************
// 3. Establecer los parámetros del programa
// *****************************************

* Ningún parámetro en esta sesión



// *************************
// 4. Leer archivos de datos
// *************************

* solicitar información de comandos
help cd
search clear

* establecer la carpeta con los archivo de datos
cd "C:\Users\aml\Downloads\CURSO_ENAHO_PUCP\4_datos"

* cerrar archivos de datos
clear

* ENAHO Características de los miembros del hogar
use enaho01-2021-200.dta
use enaho01-2021-200.dta, clear



// *****************
// 5. Procesar datos
// *****************

// Comandos esenciales
//********************

* establecer log-file
log using "C:\Users\aml\Downloads\CURSO_ENAHO_PUCP\6_resultados\sesion_02.log", replace

// obtener información del archivo de datos
// dominio es el dominio geográfico
describe
describe dominio
desc dominio
desc p204 p207

codebook
codebook dominio
codebook p204 p207

// ver los 10 primeros registros del archivo
list in 1 / 10 , clean

// ver los 10 primeros registros de una lista de variables
list p204 p207 in 1 / 10 , clean // tambien puede ser sin clean 

// generar estadísticas descriptivas
// p208 edad en años cumplidos
summarize p208a
su p208a

// crear nueva variable
// vpet poblacion en edad de trabajar
// generate vpet = .
gen vpet = .
gen vpet2 = vpet

// cambiar nombre de variable
rename vpet2 pet

// reemplazar valores de una variable
replace vpet = 1 if p208a >= 14 & p208a != .
replace vpet = 0 if vpet != 1 & p208a != .

// etiquetar variable
label var vpet "poblacion en edad de trabajar"
label define nompet 1 "PET" 0 "No PET"
label values vpet nompet

// recodificar variable
recode vpet (1 = 1) (0 = 2) // cambia el cero por el numero 2
recode vpet (1 = 1) (2 = 0), gen (vpet3)

// obtener información de la variable
codebook vpet

// eliminar etiqueta
label drop nompet

// restituir etiqueta , ahora si podemos recnombrar categorias 
label define nompet 1 "PET" 2 "No PET"
label values vpet nompet


// generar tabla de frecuencias
// p207 sexo
tabulate p207
tab p207

// generar tabla de frecuencias (dos variables)
tab dominio p207


// comandos adicionales
//*********************

// mantener (filtrar) variables
keep p204 p207 p208a 

// mantener (filtrar) observaciones
keep if p204 == 1

// generar tabla de frecuencias
tab p207


// eliminar variables
drop pet vpet3

// eliminar observaciones
drop if p204 != 1



// *********************
// 6. Guardar resultados
// *********************

// guardar archivo de datos (resultados)
save "C:\Users\aml\Downloads\CURSO_ENAHO_PUCP\6_resultados\enaho01-2021-200_EDIT.dta", replace



// **********************************************
// 7. Cerrar log-file y salir de Stata (opcional)
// **********************************************

* cerrar log-file
log close

* salir del do-file
exit, clear
