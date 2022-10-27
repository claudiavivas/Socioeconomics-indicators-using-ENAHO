// ***********************************************************
// Curso: 	 Análisis de Indicadores Sociodemográficos 
//           con la Encuesta Nacional de Hogares - ENAHO
// Sesión:	 03
// Tema: 	 Análisis de datos de encuestas por muestreo
// Fecha: 	 24/10/2022
// ***********************************************************
********************************************************************

* cerrar todos los archivos
clear all
* continuar con la ejecuciòn de comandos
set more off



// *****************************************
// 3. Establecer los parámetros del programa
// *****************************************

* identificar carpetas de trabajo
local DIR_RAIZ C:\Users\aml\Downloads\CURSO_ENAHO_PUCP
local DIR_DATOS `DIR_RAIZ'4_datos\
local DIR_RESUL `DIR_RAIZ'6_resultados\


// *************************
// 4. Leer archivos de datos
// *************************


* establecer log-file
log using `DIR_RESUL'sesion_03.log, replace

* mostrar contenido de macro local
display "`DIR_RAIZ'"
di "`DIR_DATOS'"

* establecer la carpeta con los archivo de datos
cd `DIR_DATOS'

* Variables a utilizar
**********************

* dominio	dominio geográfico
* estrato	estrato geográfico
* ubigeo	ubicación geográfica
* p203		¿cuál es la relación de parentesco con el jefe(a) del hogar
* p204		¿es miembro del hogar?
* p207		sexo
* p208a		¿qúe edad tiene en años cumplidos? (en años
* p301a 	¿cuál es el último año o grado de estudios y nivel que aprobó? - nivel


* ENAHO Características de los miembros del hogar
use "C:\Users\aml\Downloads\CURSO_ENAHO_PUCP\4_datos\enaho01-2022-200.dta", clear

* Vincular con el módulo 300 Educación
merge 1:1 conglome vivienda hogar codperso using "C:\Users\aml\Downloads\CURSO_ENAHO_PUCP\4_datos\enaho01a-2022-300.dta" // se une el moculo 200 conel modeulo 300
keep if _m==3


* Visualizar datos de solo miembros del hogar
browse if p204 == 1
br if p204 == 1
br if p204 == 1, nolabel

* Filtrar solo miembros del hogar
keep if p204 == 1


// *****************
// 5. Procesar datos
// *****************


// *******************
// NIVELES DE ANALISIS
// *******************

// **********
// Geográfico
// **********

* Identificar variable Dominio geográfico
* dominio

* Generar variable Area de residencia
gen area = estrato
recode area (1/5=1) (6/8=2)
* Etiquetar variable Area de residencia
lab var area "Area de residencia"
lab def larea 1 "Urbana" 2 "Rural"
lab val area larea


* Generar variable Ambito geográfico
gen ambiGeografico = 1 if dominio == 8
replace ambiGeografico = 2 if (dominio >= 1 & dominio <= 7) & (estrato >= 1 & estrato <= 5)
replace ambiGeografico = 3 if (dominio >= 1 & dominio <= 7) & (estrato >= 6 & estrato <= 8)
* Etiquetar variable Area de residencia (b)
label var ambiGeografico "Ambito geográfico"
label def lambiGeografico 1 "Lima Metropolitana" 2 "Resto urbano" 3 "Area rural"
label val ambiGeografico lambiGeografico


* Generar variable Región natural
gen regNatural = .
replace regNatural = 1 if dominio <= 3 | dominio == 8
replace regNatural = 2 if dominio >= 4 & dominio <= 6
replace regNatural = 3 if dominio == 7
* Etiquetar variable Región natural
label var regNatural "Región natural"
label def lregNatural 1 "Costa" 2 "Sierra" 3 "Selva"
label val regNatural lregNatural


* Generar variable Región
gen region = substr(ubigeo,1,2)
destring region, replace
* Etiquetar vriable Región
label var region "Región"
label def lregion 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho"  ///
	6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco"  ///
	11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima"  ///
	16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura"   ///
	21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label val region lregion


// ***********
// Demográfico
// ***********

* Identificar variable Género
gen sexo = p207
label var sexo "Sexo"
label def lsexo 1 "Hombre" 2 "Mujer"
label val sexo lsexo


* Generar variable Grupo de edad
gen gedad = 1 if p208a < 14 & p204 == 1
replace gedad = 2 if p208a >= 14 & p208a <= 29 & p204 == 1
replace gedad = 3 if p208a >= 30 & p208a <= 49 & p204 == 1
replace gedad = 4 if p208a >= 50 & p208a <= 59 & p204 == 1
replace gedad = 5 if p208a >= 60 & p204 == 1
* Etiquetar variable Grupo de edad
label var gedad "Grupo de edad"
label def lgedad 1 "Menos de 14 años" 2 "De 14 a 29 años"  3 "De 30 a 49 años"  4 "De 50 a 59 años"  5 "De 60 a más años"
label val gedad lgedad


* Generar variable Nivel educativo
gen nivEduca = 1 if p301a < 5 | p301a == 12
replace nivEduca = 2 if p301a > 4 & p301a < 7
replace nivEduca = 3 if p301a > 6 & p301a < 9
replace nivEduca = 4 if p301a > 8 & p301a < 12
* Etiquetar variable Nivel educativo
label var nivEduca "Nivel educativo"
label def lnivEduca 1 "Primaria" 2 "Secundaria" 3 "Superior no universitaria" 4 "Superior universitaria"
label val nivEduca lnivEduca

* uni el modulo 200 con 300 poruq me interesan las variables educativas 

// *********************
// VARIABLES DE ANALISIS
// *********************

* Generar variable Jefe de hogar
* 1 significa que el jefe de hogar es adulto mayor
gen jhAdulto = .
replace jhAdulto = 1 if p203 == 1 & p208a >= 60
replace jhAdulto = 0 if p203 == 1 & p208a < 60
label var jhAdulto "Jefe de hogar adulto mayor"
label def ljhAdulto 1 "JHog Adulto mayor" 0 "JHog no Adulto mayor"
label val jhAdulto ljhAdulto


// *****************
// ANALISIS DE DATOS
// *****************


* Realizar análisis descriptivo
sum jhAdulto

tabstat jhAdulto, stat(n mean sd variance  cv)
tabstat jhAdulto, by(area) stat(n mean sd variance  cv) // las estadisticas se sacan a nivel urbano rural

* Realizar análisis descriptivo ponderado
tabstat jhAdulto [aw = facpob], stat(n mean sd variance  cv)
tabstat jhAdulto [aw = facpob], by(area) stat(n mean sd variance  cv)

* ponderaciones: queremos hacer analisis de los parametros poblacionales por eso le ponemos pesos. 

*pw se usa con diseÃ±omuestral y se usa svyset
*aw analitic weight
*iw importance weight

* Calcular total y proporción de jefes de hogar adulto mayor (nacional)

* 
tab jhAdulto
tab jhAdulto [iw = facpob]

* table tambien se usa para tabulados
table jhAdulto //, row solo agregaba el total de observaciones por fila
table jhAdulto [iw = facpob]

* esimportante usar el diseÃ±o muestrar para calcular al varianza que finalmente impacta en el coeficiente de variaciÃ³n
svyset [pw = facpob], psu(conglome) strata(estrato) singleunit(centered)
svy: total jhAdulto
svy: mean jhAdulto


* Calcular total y proporción de jefes de hogar adulto mayor (area de residencia)

* 
tab area jhAdulto
tab area jhAdulto [iw = facpob]

* 
table area jhAdulto, row
table area jhAdulto [iw = facpob], format(%12.0f) row

* 
svy: total jhAdulto, over(area)
svy: mean jhAdulto, over(ambiGeografico) // en lugar de area sepuedehacer el analisis por el nivel del dominio uwu 


// *********************
// EJERCICIOS PROPUESTOS
// *********************

/* 
1. Realizar el análisis de los niveles geográficos:
Dominio, Ambito geográfico, Región natural, Región

2. ¿Dónde se ve la desigualdad?
*/


/* 
3. Realizar el análisis de los niveles geográficos:
Género, Nivel educativo

4. ¿Dónde se ve la desigualdad?
*/


// *********************
// REFUERZO DE CONCEPTOS
// *********************

* La ENAHO no tiene inferencia distrital
tabstat jhAdulto if ubigeo == "070101" [aw = facpob], by(area) stat(n mean sd variance  cv)

* declaramos diseÃ±omuestral
svyset [pw = facpob], psu(conglome) strata(estrato) singleunit(centered)
svy: mean jhAdulto if ubigeo == "070101", over(area)
* a nivel distrital el error estandar es alto y el intervalo de confianza se hace muy grande 
* RECOMENDACION: evaluar el boletin trimestral de poblacion de adultos mayores para replicar los datos 



// *********************
// 6. Guardar resultados
// *********************

// guardar archivo de datos (resultados)
save `DIR_RAIZ'enaho01-2022-200-300_EDIT.dta, replace



// **********************************************
// 7. Cerrar log-file y salir de Stata (opcional)
// **********************************************

* cerrar log-file
log close

* salir del do-file
exit, clear
