# SQL Projekt

## Zadání

Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

Potřebují k tomu od vás připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.
Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.

## Výzkumné otázky
### 1.Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Z data setu si vytvoříme dočasnou tabulku, jelikož budeme chtít z těchto dat získat více informací. Do této dočasné tabulky přidáme 2 sloupce, jeden nám ukáže hodnotu mzdy pro dané odvětví za minulý rok a další sloupec nám řekne, jestli mzda vzrostla, klesla nebo zůstala stejná. Tvorba dočasné tabulky obsahuje vnořený SELECT, pomocí kterého vypočítáme průměrné mzdy pro všechna odvětví za dané roky.  
Po zobrazení dočasné tabulky pohledem zjistíme, že se mzdy zvýšily pro všechna odvětví ve většině let.  
Pomocí funkcí MIN, MAX a COUNT + DISTINCT, zjistíme, že zkoumáme data pro 19 odvětví v letech 2000 až 2021.   
V roce 2013 se snížily pro 11 odvětví a v roce 2021 pro 5 odvětví. V ostatních letech mzdy klesly maximálně pro 1 až 3 odvětví. Tyto informace získáme, když si dáme podmínku do klauzule WHERE a seřadíme odvětví podle počtu výskytů.
Když z tabulky schováme data pro roky 2013, jednoduše zjistíme, kterým odvětvím nejčastěji klesly průměrné roční mzdy. 
Celkem třikrát klesly mzdy těmto odvětvím:
•	Těžba a dobývání
•	Ubytování, stravování a pohostinství
•	Veřejná správa a obrana; povinné sociální zabezpečení, kterým mzdy klesly za zkoumané období celkem třikrát a odvětví
A celkem dvakrát těmto odvětvím:
•	Kulturní, zábavní a rekreační činnosti,
•	Vzdělávání
•	Zemědělství, lesnictví, rybářství
Rok 2013 negativně ovlivnil mzdy u 11 odvětví. Pojďme se podívat, kterým odvětvím v tomto roce mzdy vzrostly.
•	Doprava a skladování
•	Ostatní činnosti
•	Ubytování, stravování a pohostinství
•	Veřejná správa a obrana; povinné sociální zabezpečení
•	Vzdělávání
•	Zdravotní a sociální péče
•	Zemědělství, lesnictví, rybářství
•	Zpracovatelský průmysl

Pokud se podíváme, kde mzdy vzrostly v roce 2013 i v roce 2021, zjistíme, kterým odvětvím se daří i v krizových letech. Tohoto dosáhneme s využitím funkce INTERSECT, které nám pomůže ukázat průnik dat pro oba tyto roky.
•	Doprava a skladování
•	Ostatní činnosti
•	Ubytování, stravování a pohostinství
•	Zdravotní a sociální péče
•	Zpracovatelský průmysl

Také by nás mohlo zajímat, jestli je odvětví, které ve zkoumaném odvětví neměly pokles mezd.
V tomto případě použijeme klauzuli HAVING, kde počítáme počet výskytů situace, kde se mzdy snížily. Tato klauzule musí mít hodnotu 0, aby nám to ukázalo požadovaná data.
•	Doprava a skladování
•	Ostatní činnosti
•	Zdravotní a sociální péče
•	Zpracovatelský průmysl

### 2.Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
Pomocí operátoru ILIKE najdeme kód pro chléb a pro mléko.
Ve svém scriptu jsem použila funkce MIN a MAX v klauzuli WHERE ve vnořeném SELECTu, takto najdeme první a poslední rok s cenami potravin, ale zároveň si musíme pojistit, že za tyto roky máme i data ke mzdám. Dosáhneme toho pomocí podmínky, která zajistí, že průměrné platy budou mít nějaká data. Další podmínka hledá data pouze pro požadované dvě potraviny. Data pro tyto dva roky pak sloučíme pomocí funkce UNION.
Další vnořený SELECT je použitý u FROM, tam počítáme průměrný roční plat a průměrnou roční cenu potravin.  Opět používáme stejné podmínky jako u předchozího vnořeného SELECTu.
V hlavním SELECTu si ukážeme roky pro srovnatelné období a dva nové sloupce, které nám počítají průměr ze vzorce mzda / cena pro chleba nebo pro mléko a zaokrouhlují tento počet na koruny dolů.
Výsledek vypadá takto:
Rok	Počet chleba (kg)	Počet mléka (l)
2006	1282.0	1432.0
2018	1340.0	1639.0

Z výsledků můžeme posoudit, že mzdy rostou rychleji než ceny těchto dvou potravin.

### 3.Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší procentuální meziroční nárůst)?
Pokud nás zajímá celkový trend přes celé zkoumané období, můžeme využít CTE, pomocí kterého si pro každou kategorii potravin a rok zjistíme meziroční procentuální nárůst. Poté si pomocí funkce SUM sečteme všechny tyto hodnoty pro každou kategorii zvlášť a z výsledné tabulky zjistíme, že na třetím místě je jakostní víno bílé (první záznam s kladnou hodnotou), a tedy potravina, která zdražuje nejpomaleji. Pokud by nás zajímaly potraviny, které naopak za zkoumané období zlevnily, jsou to první dvě v tabulce – cukr krystalový a rajská jablka červená kulatá.

### 4.Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
Pro tuto otázku jsem použila dvě CTE, první CTE nám vyfiltruje společné roky pro data ke mzdám a cenám potravin, druhé CTE nám k těmto datům přidá dva sloupce s meziročními nárůsty a jeden sloupec s rozdílem těchto hodnot a na závěr si z těchto dat vyfiltrujeme roky, kde byl nárůst cen potravin o 10% a více větší než nárůst cen mezd -> žádný. 
Pro kontrolu jsem si našla rozdíly v nárůstech sestupně, nejblíže k 10% je rok 2013, s hodnotou 6,7%.

### 5.Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
Data o HDP máme v tabulce, kterou jsem nepřidala do hlavního datasetu. Proto si ho upravím pomocí příkazu ALTER TABLE, kdy přidám nový sloupec, a pomocí UPDATE table vložím data z připraveného SELECTu.

Poté pokračujeme podobně, jako v předchozí otázce. Pomocí dvou CTE si najdeme roky a pomocí druhé CTE k nim doplníme meziroční nárůsty, HDP, cen a mezd.
Výraznější nárůsty HDP (nad 5%) jsme zaznamenali ve třech letech:
•	2007 – ceny a mzdy v tomto a následujícím roce vzrostly o 6 až 7 procent
•	2015 – ceny se v tomto a následujícím roce snížily a mzdy rostly o 2 až 3 procenta
•	2017 – ceny a mzdy se výrazně zvýšily o 9 a 6 procent a následující rok o 2 a 7 procent
Poklesy HDP jsme zaznamenali v těchto letech:
•	2009 – HDP pokleslo o necelých 5 procent, ceny o 6 a mzdy vzrostly, následující rok ceny i mzdy vzrostly
•	2012 a 2013 – v těchto letech byl nepatrný pokles HDP, ceny až do roku 2014 rostly, mzdy vzrostly, následující rok poklesly, a pak zase vzrostly

Z výsledků těchto dat soudím, že HDP nemá vliv na ceny potravin ani na výši mezd.
Pro přesnější analýzu bych doporučila otestovat korelaci a / nebo regresní analýzu.


