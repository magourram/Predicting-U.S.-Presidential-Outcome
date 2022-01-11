////////////////////////////////////////////////////////////////////////////////
///////////Import US dataset and data manipulation//////////////////////////////
////////////////////////////////////////////////////////////////////////////////
clear all
import delimited "/Users/marwan/Desktop/UNIMI/Lezioni/1st Year 2021:22/Micro-Econometrics, Causal Inference and Time Series Econometrics/Empirical Project/DATASET/CSV FAIR/tot.csv"

// Encode string variable, rename numerical variables
encode geoname,								gen(State)
encode state_abbr, 							gen(State_ab)
encode unemployment_rate,					gen(Unem_rate)
encode transaction_housing_price,			gen(House_pricing)
encode density,								gen(Density)
encode educational_level,					gen(Edu_lvl)

rename fips_state_code 						State_FIPS
rename region 								Region
rename year 								Year
rename gdp_current							GDPN
rename total_population						POP
rename gdp_chained							GDPR
rename elec_votes							Elec_votes
rename pers_incometh_usd					P_Income
rename per_cap_pers_incusd					PC_Income
rename per_cap_disp_pers_incusd				PC_D_Income
rename pers_curr_taxth_usd					P_Cur_Taxes
rename fed_govth_usd						Fed_Government
rename governmentandgovernmententerpris		GGE
rename healthservicesthousandsofdollars		HHS
rename wagesandsalariesbyplaceofworktho		WWS
rename civilian_labor						Civ_lab

// Drop useless variables
drop geoname state_abbr description_current_gdp transaction_housing_price unemployment_rate unit description_chained_gdp unitsicnaics area_km density educational_level

// Recast long variables
recast int									Elec_votes
recast int									P_Income
recast int									PC_Income
recast int									PC_D_Income
recast int									HHS
recast float								Unem_rate
recast float								House_pricing

// Order and Sort
order Year State State_FIPS State_ab Region POP Density Elec_votes GDPN GDPR Unem_rate P_Income PC_Income PC_D_Income P_Cur_Taxes Fed_Government GGE HHS WWS Civ_lab House_pricing Edu_lvl 
sort State Year

// Label variables
label variable Year 						"Year of the observation"
label variable State 						"State name"
label variable State_FIPS 					"FIPS code"
label variable State_ab 					"State abbreviation"
label variable Region 						"State region"
label variable POP 							"Population estimates [Milions]"
label variable Elec_votes					"Electoral votes for each US State"
label variable GDPN 						"Nominal Gross Domestic Product (no inflation) [Milions]"
label variable GDPR 						"Real Gross Domestic Product (inflation) [Milions]"
label variable Unem_rate 					"Average unemployment rate in the US per state"
label variable P_Income						"Personal Income [Thousands of USD]"
label variable PC_Income					"Per Capita personal Income [USD]"
label variable PC_D_Income					"Per Capita disposable personal income [USD]"
label variable P_Cur_Taxes					"Personal Current taxes [USD]"
label variable Fed_Government				"Federal Governement [USD]"
label variable GGE							"Government and Government Enterprises (Thousand USD)"
label variable HHS							"Health Services (thousand USD)"
label variable WWS							"Wages and Salaries by place (thousand USD)"
label variable Civ_lab						"Portion of the U.S. civilian population that it considers either employed or unemployed"
label variable Edu_lvl						"Percentage of the population  that has a bachelor degree or higher istruction level"		
label variable Density						"Population density of each U.S. State"
label variable House_pricing				"Price changes of residential housing as a percentage change from some specific start date (1980=100)"

// Declare our State variable data to be a PanelData based on Year
xtset State Year, y

// Calculate the Real Per capita GDP Year (Y= new numerical variable), and label it
bys State : gen Y=(GDPR/POP)
bys State : gen Y_1 = Y[_n-1]
bys State : gen Y_2 = Y[_n-2]
bys State : gen Y_4 = Y[_n-4]

label variable Y 		"Real per Capita Gross Domestic Product"
label variable Y_1 		"Real per Capita Gross Domestic Product in the last year of admin"
label variable Y_2 		"Real per Capita Gross Domestic Product in the last two years of admin"
label variable Y_4 		"Real per Capita Gross Domestic Product in the last four years of admin"

// Calculate the GDP Deflator (GDPD), and label it
bys State : gen GDPD = (GDPN / GDPR)
bys State : gen GDPD_1 = GDPD[_n-1]
bys State : gen GDPD_2 = GDPD[_n-2]
bys State : gen GDPD_4 = GDPD[_n-4]

label variable GDPD 	"Gross Domestic Product Deflator (Inflation)"
label variable GDPD_1 	"Gross Domestic Product Deflator (Inflation) in the year of administration"
label variable GDPD_2 	"Gross Domestic Product Deflator (Inflation) in the mid-term"
label variable GDPD_4 	"Gross Domestic Product Deflator (Inflation) at the beginning of administration"

// Calculate the growth rate of real per capita GDP (G) in the mandate's third and Y3 last years, it indicates the "good news" 
bys State : gen G = ((l0.Y/l1.Y) -1)*100
replace G = 1 if G==.

label variable G 		"Growth rate of real per capita GDP in percentual in the first three quarters of the on-term election year (annual rate)"

// Block of code to create the Deflator growth up to 4 years, using lag-operators
bys State: gen P= ((l1.GDPD/(GDPD*(-1)))-1) 
replace P = -1 * ((l1.GDPD/(GDPD*(-1)))-1)  if P<0
replace P=1.0 if P==.

label variable P 		"Absolute value of the growth rate of the GDP deflator"

// Introduce our Z variable 
egen OK = anymatch(Year), values(1976 1980 1984 1988 1992 1996 2000 2004 2008 2012 2016 2020)
bys State : gen OK_1 = OK[_n-1]
replace OK_1 = 0 if OK_1 == .
bys State : gen OK_2 = OK[_n-2]
replace OK_2 = 0 if OK_2 == .
bys State : gen OK_3 = OK[_n-3]
replace OK_3 = 0 if OK_3 == .
bys State : gen OK_4 = OK[_n-4]
replace OK_4 = 0 if OK_4 == .


bys State : gen gk = ((Y/l1.Y)-1)*100 if OK_2==1 |OK_3==1|OK_4==1
bys State : replace gk = ((l3.Y/Y)-1)*100 if OK_1==1
bys State : gen Ind = 1 if gk > 2.7
bys State : replace Ind = 0 if Ind == .

bys State  : gen Z=(Ind+Ind[_n-1]+Ind[_n-2]+Ind[_n-3]) if OK==1
replace Z = 0 if Z==.

label variable Z 		"Number of years of the administration in which the growth rate of real per capita GDP is greater than 2.7%"
label variable gk		"Growth rate given in a certain year"
drop OK Ind OK_1 OK_2 OK_3 OK_4

// Generate some personal variables
bys State : gen Delta_PCI = (PC_Income/(PC_Income[_n-1]))-1
label variable Delta_PCI		"Growth wrt to last year in per capita personal income"

bys State : gen Delta_HP = (House_pricing/(House_pricing[_n-1]))-1
label variable Delta_HP			"Growth wrt to last year in House pricing (all-transactions)"

bys State : gen Delta_PCDI = (PC_D_Income/(PC_D_Income[_n-1]))-1
label variable Delta_PCDI		"Growth wrt to last year in Per capita disposable income"

bys State : gen Delta_WWS = (WWS/(WWS[_n-1]))-1
label variable Delta_WWS		"Growth wrt to last year in WWS"

bys State : gen Delta_PCT = (P_Cur_Taxes/(P_Cur_Taxes[_n-1]))-1
label variable 	Delta_PCT		"Growth wrt to last year in p_Cur_Taxes"

bys State : gen Delta_FG = (Fed_Government/(Fed_Government[_n-1]))-1
label variable Delta_FG					"Growth wrt to last year in Fed_Government"

bys State : gen Delta_HHS = (HHS/(HHS[_n-1]))-1
label variable Delta_HHS        "Growth wrt to last year in Health Expenditure"

// Lagged valued of the personal variables
bys State : gen Delta_PCI_1 	= Delta_PCI[_n-1]
bys State : gen Delta_HP_1		= Delta_HP[_n-1]
bys State : gen Delta_PCDI_1 	= Delta_PCDI[_n-1]
bys State : gen Delta_WWS_1 	= Delta_WWS[_n-1]
bys State : gen Delta_PCT_1 	= Delta_PCT[_n-1]
bys State : gen Delta_FG_1 		= Delta_FG[_n-1]
bys State : gen Delta_HHS_1 	= Delta_HHS[_n-1]

label variable Delta_PCI_1	"Delta_PCI in the last year of administration"
label variable Delta_HP_1	"Delta_HP in the last year of administration"
label variable Delta_PCDI_1	"Delta_PCDI in the last year of administration"
label variable Delta_WWS_1	"Delta_WWS in the last year of administration"
label variable Delta_PCT_1	"Delta_PCT in the last year of administration"
label variable Delta_FG_1	"Delta_FG in the last year of administration"
label variable Delta_HHS_1	"Delta_HHS in the last year of administration"

egen OK = anymatch(Year), values(1976 1980 1984 1988 1992 1996 2000 2004 2008 2012 2016 2020)
bys State : gen OK_1 = OK[_n-1]
replace OK_1 = 0 if OK_1 == .
bys State : gen OK_2 = OK[_n-2]
replace OK_2 = 0 if OK_2 == .
bys State : gen OK_3 = OK[_n-3]
replace OK_3 = 0 if OK_3 == .
bys State : gen OK_4 = OK[_n-4]
replace OK_4 = 0 if OK_4 == .

bys State : gen Delta_Unem = 1 if Unem_rate>Unem_rate[_n-1]
bys State : replace Delta_Unem = 0 if Delta_Unem ==.
bys State : gen  DUNEM = (Delta_Unem[_n-1]+Delta_Unem[_n-2]+Delta_Unem[_n-3]+Delta_Unem[_n-4]) if OK == 1
bys State : replace DUNEM = 0 if DUNEM ==.
drop OK OK_1 OK_2 OK_3 OK_4 Delta_Unem
rename DUNEM Delta_Unem
label variable Delta_Unem 		"Years in each mandate where the unemployment rate had growth"

keep if Year >1975

save "/Users/marwan/Desktop/UNIMI/Lezioni/1st Year 2021:22/Micro-Econometrics, Causal Inference and Time Series Econometrics/Empirical Project/Stata/Main_Population_GDPR_GDPN.dta", replace
