////////////////////////////////////////////////////////////////////////////////
//					Merge Presidential and Population datasets				  //
////////////////////////////////////////////////////////////////////////////////

clear all
cd "/Users/marwan/Desktop/UNIMI/Lezioni/1st Year 2021:22/Micro-Econometrics, Causal Inference and Time Series Econometrics/Empirical Project/Stata"

use Main_US_Popular_vote.dta, clear
graph drop _all

merge m:m Year State using "/Users/marwan/Desktop/UNIMI/Lezioni/1st Year 2021:22/Micro-Econometrics, Causal Inference and Time Series Econometrics/Empirical Project/Stata/Main_Population_GDPR_GDPN.dta"
drop if _merge !=3													
drop _merge State_FIPS State_ab Region State_po Candidate_votes Total_votes
sort State Year
xtset State Year, delta(4)

// Interactions of the economic variables
bys Year State : gen Delta_PCI_i 			= Delta_PCI * I
bys Year State : gen Delta_PCI_1_i 			= Delta_PCI_1 * I
bys Year State : gen Delta_HP_i		 		= Delta_HP * I
bys Year State : gen Delta_HP_1_i		 	= Delta_HP_1 * I
bys Year State : gen Delta_PCDI_i 			= Delta_PCDI * I
bys Year State : gen Delta_PCDI_1_i 		= Delta_PCDI_1 * I
bys Year State : gen Delta_WWS_i		 	= Delta_WWS * I
bys Year State : gen Delta_WWS_1_i		 	= Delta_WWS_1 * I
bys Year State : gen Delta_PCT_i		 	= Delta_PCT * I
bys Year State : gen Delta_PCT_1_i		 	= Delta_PCT_1 * I
bys Year State : gen Delta_FG_i		 		= Delta_FG * I
bys Year State : gen Delta_FG_1_i		 	= Delta_FG_1 * I
bys Year State : gen Delta_HHS_i		 	= Delta_HHS * I
bys Year State : gen Delta_HHS_1_i		 	= Delta_HHS_1 * I

label variable Delta_PCI_i					"Delta_PCI * I"
label variable Delta_PCI_1_i 			 	"Delta_PCI_1 * I"
label variable Delta_HP_i		 			"Delta_HP * I"
label variable Delta_HP_1_i		 			"Delta_HP_1 * I"
label variable Delta_PCDI_i 				"Delta_PCDI * I"
label variable Delta_PCDI_1_i 				"Delta_PCDI_1 * I"
label variable Delta_WWS_i		 			"Delta_WWS * I"
label variable Delta_WWS_1_i		 		"Delta_WWS_1 * I"
label variable Delta_PCT_i		 			"Delta_PCT * I"
label variable Delta_PCT_1_i		 		"Delta_PCT_1 * I"
label variable Delta_FG_i		 			"Delta_FG * I"
label variable Delta_FG_1_i		 			"Delta_FG_1 * I"
label variable Delta_HHS_i		 			"Delta_HHS * I"
label variable Delta_HHS_1_i		 		"Delta_HHS_1 * I"

bys Year State : gen GDPD_i 				= GDPD * I 							
bys Year State : gen GDPD_1_i				= GDPD_1 * I 						
bys Year State : gen GDPD_2_i 				= GDPD_2 * I 						
bys Year State : gen GDPD_4_i				= GDPD_4 * I						
bys Year State : gen Y_i 					= Y * I 				
bys Year State : gen Y_1_i 					= Y_1 * I				
bys Year State : gen Y_2_i 					= Y_2 * I 				
bys Year State : gen Y_4_i 					= Y_4 * I		 		
bys Year State : gen P_i 					= P * I
bys Year State : gen G_i 					= G * I
bys Year State : gen Z_i 					= Z * I 				
bys Year State : gen gk_i					= gk * I 				

label variable GDPD_i						"GDPD * I "
label variable GDPD_1_i						"GDPD_1 * I "
label variable GDPD_2_i						"GDPD_2 * I "
label variable GDPD_4_i						"GDPD_4 * I "
label variable Y_i							"Y * I"
label variable Y_1_i						"Y_1 * I"
label variable Y_2_i						"Y_2 * I"
label variable Y_4_i						"Y_4 * I"
label variable P_i 							"P * I"
label variable G_i 							"G * I"
label variable Z_i 							"Z * I"
label variable gk_i							"gk * I"

bys Year State : gen Unem_rate_i 			= Unem_rate * I
bys Year State : gen Edu_i					= Edu_lvl * I
bys Year State : gen Civ_lab_i				= Civ_lab * I

label variable Unem_rate_i					"Unem_rate * I"
label variable Edu_i						"Edu_lvl * I"
label variable Civ_lab_i					"Civ_lab * I"

// Label values of categorical variables
lab def incumbent 1 "Dem incumbent" -1 "Rep incumbent" 0 "Third party"
lab val I incumbent

label def dper 1 "Dem running again" -1 "Rep running again" 0 "Incumbent not running again"
lab val DPER dper

lab def dur 0 "Dem or Rep party 1 term" /*
*/ 1 "Dem party 2 terms"  2 "Dem party 6 terms" /*
*/ -1 "Rep party 2 terms" -2 "Rep party 6 terms"
lab val DUR dur

lab def war 0 "Election held not during WW" 1 "Election held during WW"
lab val WAR war

lab def covid 1 "COVID-19 Pandemic" 0 "Not COVID-19 Pandemic"
lab val COVID covid

order DUR DPER WAR COVID I President


//							FE MODELS & PREDICTIONS

////////////////////////////FAIR VARIABLES//////////////////////////////////////
// FAIR VARIABLES: Vp I DPER DUR G_i Z_i P_i
summarize Vp I DPER DUR G_i Z_i P_i

// Here we will regress different models starting from a wrong model that doesn't account for HETEROSKEDASTICITY nor CORRELATION all the way to the final model with differnet Fixed Effects

/////////Model without Fixed Effects or robust estimates (weaker)///////////////
xtreg Vp I DPER DUR G_i Z_i P_i
estimates store m0

///Model without Fixed Effects but counting HETEROSKEDASTICITY and CORRELATION//
// Notice: using vce(cluster) command we let different states to have different variances, but we will restrict the correlation to the residuals within each state
xtreg Vp I DPER DUR G_i Z_i P_i, vce(cluster State)
estimates store m1

/////Model with state-Fixed Effect accounted for using the dummies i.State///////
xtreg Vp I DPER DUR G_i Z_i P_i, re
estimates store re

// POOLABILITY TEST: check if the state-fixed effects are statistically significant
xtreg Vp I DPER DUR G_i Z_i P_i i.State, fe
estimates store fe_state
//////////Model with both state-fixed effects and year-fixed effects////////////
xtreg Vp I DPER DUR G_i Z_i P_i i.State i.Year, fe vce(cluster State)
estimates store fe_year_state

// HAUSMAN fixed effects regression: here we check if the year-fixed effects are statistically significant
testparm i.Year
testparm I DPER DUR G_i Z_i P_i

// Compare the estimates of the for models above
estimates table m0 m1 re fe_state fe_year_state, stats(N r2_a) star(.1 .05 .01) keep (I DPER DUR G_i Z_i P_i) b(%4.3f) stfmt(%4.3f) 

////////////////FAIR EQUATION ON PANEL DATA - PREDICTIONS///////////////////////

// Here we will use out last model (fe) to predict the election outcome of 2016 and 2020.
// We will compute our model estimates both on data with year < 2016 and year < 2020 to check the goodness of our model by predicting as if we did not know the outcome.

// Estimate coefficient with Fixed Effect model
**2016
//xtreg Vp I DPER DUR I DPER DUR G_i Z_i P_i State_FE
summarize Vp I DPER DUR G_i P_i

reg Vp I DPER DUR G_i Z_i P_i i.State if Year <2016
testparm G_i Z_i P_i // Test joint significance of economic variables in fair's model
testparm i.State // Check if the panel data can be pooled by testing the joint significance of state-level FE.

predict fair_16 if Year==2016 //Forecast
gen e_fair_16 = Vp - fair_16 if Year==2016 //Errors
gen e_fair_16_sq = e_fair_16^2 if Year==2016 // Squared residuals

// Who won the elecion in 2016?
gen w_f_16 = 1 if fair_16 > 50.00 & Year == 2016
gen ge_fair_16 = Elec_votes * w_f_16
egen total_elec_votes_2016 = total(ge_fair_16), by(State)
egen s_fair_16 = sum(ge_fair_16)

**2020
reg Vp I DPER DUR G_i Z_i P_i i.State if Year < 2020
testparm G_i Z_i P_i // Test joint significance of economic variables in fair's model
testparm i.State // Check if the panel data can be pooled by testing the joint significance of state-level FE.

predict fair_20 if Year==2020
gen e_fair_20 = Vp - fair_20 if Year==2020 //Errors
gen e_fair_20_sq = e_fair_20^2 // Squared residuals

// Who won the election in 2020?
gen w_f_20 = 1 if fair_20 > 50.00 & Year == 2020
gen ge_fair_20 = Elec_votes * w_f_20
egen total_elec_votes_2020 = total(ge_fair_20), by(State)
egen s_fair_20 = sum(ge_fair_20)

list Vp fair_16 e_fair_16 if Year==2016
list Vp fair_20 e_fair_20 if Year==2020

summarize e_fair_16 e_fair_20 e_fair_16_sq e_fair_20_sq

/////////////////////////PLOT PREDICTION FE MODEL///////////////////////////////
**2016
/*
quietly twoway (scatter fair_16 State) if Year == 2016, ytitle("Forecasted Democratic Share") 	by(Year) name (Vp_predictions_fe_2016)
quietly twoway (scatter e_fair_16 State) if Year == 2016, ytitle("Forecasted Error")				by(Year) name (Error_predictions_fe_2016)
*/
**2020
/*
quietly twoway (scatter fair_20 State) if Year == 2020, ytitle("Forecasted Democratic Share") 	by(Year) name (Vp_predictions_fe_2020)
quietly twoway (scatter e_fair_20 State) if Year == 2020, ytitle("Forecasted Error")				by(Year) name (Error_predictions_fe_2020)
*/
** COMBINE GRAPHS
/*
graph combine Vp_predictions_fe_2016 Error_predictions_fe_2016 Vp_predictions_fe_2020 Error_predictions_fe_2020, c(2) xcommon
*/
list Year State Elec_votes fair_16 e_fair_16 total_elec_votes_2016 if Year == 2016
list Year State Elec_votes fair_20 e_fair_20 total_elec_votes_2020 if Year == 2020

////////////////////////////////////////////////////////////////////////////////
//					 		LASSO MODEL & PREDICTIONS					  //
////////////////////////////////////////////////////////////////////////////////

/*
HOW IS IT DONE?
	* Add square variables
	* Store variables you want to test with "global setname"
	* [Try also with time fixed effects]
	* Put FE in another global (exclude D1 and Y1, become base case)
	* Create global with GDP and StateFE
	* Statistics/Lasso/choose dependant variable/always include global with GDP/plugin heteroskedasticity formula
	* The non zero coefficient will include the selected and the fixed variable
	* "LassoCoefficient" to see selected
	* Re-run LASSO with dependent polity variable and see which are useful
	* Take union of results and run xtreg
	*/
	
// I CHOOSE THE FOLLOWING VARIABLES: Civ_lab_i Fed_Government_i GGE_i HHS_i House_pricing_i PC_D_Income_i PC_Income_i P_Cur_Taxes_i Unem_rate_i WWS_i
	
// We compute other possible variables (keep at minimum in order to avoid long interpretations)
bys Year State : gen Delta_PCI_i_2 				= Delta_PCI_i^2
bys Year State : gen Delta_PCI_1_i_2 			= Delta_PCI_1_i^2
bys Year State : gen Delta_HP_i_2		 		= Delta_HP_i^2
bys Year State : gen Delta_HP_1_i_2		 		= Delta_HP_1_i^2
bys Year State : gen Delta_PCDI_i_2 			= Delta_PCDI_i^2
bys Year State : gen Delta_PCDI_1_i_2 			= Delta_PCDI_1_i^2
bys Year State : gen Delta_WWS_i_2		 		= Delta_WWS_i^2
bys Year State : gen Delta_WWS_1_i_2		 	= Delta_WWS_1_i^2
bys Year State : gen Delta_PCT_i_2		 		= Delta_PCT_i^2
bys Year State : gen Delta_PCT_1_i_2		 	= Delta_PCT_1_i^2
bys Year State : gen Delta_FG_i_2		 		= Delta_FG_i^2
bys Year State : gen Delta_FG_1_i_2		 		= Delta_FG_1_i^2
bys Year State : gen Delta_HHS_i_2		 		= Delta_HHS_i^2
bys Year State : gen Delta_HHS_1_i_2		 	= Delta_HHS_1_i^2

label variable Delta_PCI_i_2					"Delta_PCI_i^2"
label variable Delta_PCI_1_i_2 			 		"Delta_PCI_1_i^2"
label variable Delta_HP_i_2		 				"Delta_HP_i^2"
label variable Delta_HP_1_i_2		 			"Delta_HP_1_i^2"
label variable Delta_PCDI_i_2 					"Delta_PCDI_i^2"
label variable Delta_PCDI_1_i_2 				"Delta_PCDI_1_i^2"
label variable Delta_WWS_i_2		 			"Delta_WWS_i^2"
label variable Delta_WWS_1_i_2		 			"Delta_WWS_1_i^2"
label variable Delta_PCT_i_2		 			"Delta_PCT_i^2"
label variable Delta_PCT_1_i_2		 			"Delta_PCT_1_i^2"
label variable Delta_FG_i_2		 				"Delta_FG_i^2"
label variable Delta_FG_1_i_2		 			"Delta_FG_1_i^2"
label variable Delta_HHS_i_2		 			"Delta_HHS_i^2"
label variable Delta_HHS_1_i_2		 			"Delta_HHS_1_i^2"

bys Year State : gen lDelta_PCI_i 				= log(Delta_PCI_i)
bys Year State : gen lDelta_PCI_1_i 			= log(Delta_PCI_1_i)
bys Year State : gen lDelta_HP_i		 		= log(Delta_HP_i)
bys Year State : gen lDelta_HP_1_i		 		= log(Delta_HP_1_i)
bys Year State : gen lDelta_PCDI_i 				= log(Delta_PCDI_i)
bys Year State : gen lDelta_PCDI_1_i 			= log(Delta_PCDI_1_i)
bys Year State : gen lDelta_WWS_i		 		= log(Delta_WWS_i)
bys Year State : gen lDelta_WWS_1_i		 		= log(Delta_WWS_1_i)
bys Year State : gen lDelta_PCT_i		 		= log(Delta_PCT_i)
bys Year State : gen lDelta_PCT_1_i		 		= log(Delta_PCT_1_i)
bys Year State : gen lDelta_FG_i		 		= log(Delta_FG_i)
bys Year State : gen lDelta_FG_1_i		 		= log(Delta_FG_1_i)
bys Year State : gen lDelta_HHS_i		 		= log(Delta_HHS_i)
bys Year State : gen lDelta_HHS_1_i		 		= log(Delta_HHS_1_i)

label variable lDelta_PCI_i						"log(Delta_PCI_i)"
label variable lDelta_PCI_1_i 				 	"log(Delta_PCI_1_i)"
label variable lDelta_HP_i		 				"log(Delta_HP_i)"
label variable lDelta_HP_1_i		 			"log(Delta_HP_1_i)"
label variable lDelta_PCDI_i 					"log(Delta_PCDI_i)"
label variable lDelta_PCDI_1_i 					"log(Delta_PCDI_1_i)"
label variable lDelta_WWS_i		 				"log(Delta_WWS_i)"
label variable lDelta_WWS_1_i		 			"log(Delta_WWS_1_i)"
label variable lDelta_PCT_i		 				"log(Delta_PCT_i)"
label variable lDelta_PCT_1_i		 			"log(Delta_PCT_1_i)"
label variable lDelta_FG_i		 				"log(Delta_FG_i)"
label variable lDelta_FG_1_i		 			"log(Delta_FG_1_i)"
label variable lDelta_HHS_i		 				"log(Delta_HHS_i)"
label variable lDelta_HHS_1_i		 			"log(Delta_HHS_1_i)"


// We always keep FE outside the LASSO (since we are already know they are jointly statistically significant[?])
global Xfixed S* i.Year

// We recall FAIR variables
summarize Vp I DPER DUR G_i P_i Z_i

// We recall our added variables (basic ones, without any new transformation)
describe Delta_FG_i Delta_FG_1_i Delta_HHS_i Delta_HHS_1_i Delta_HP_i Delta_HP_1_i Delta_PCDI_i Delta_PCDI_1_i Delta_PCI_i Delta_PCI_1_i Delta_PCT_i Delta_PCT_1_i Delta_WWS_1_i Delta_WWS_1_i 

// All Variables as global
global XLBig  P_i Z_i /*
*/ Delta_FG_i Delta_FG_1_i Delta_HHS_i Delta_HHS_1_i Delta_HP_i Delta_HP_1_i Delta_PCDI_i Delta_PCDI_1_i Delta_PCI_i Delta_PCI_1_i Delta_PCT_i Delta_PCT_1_i Delta_WWS_1_i Delta_WWS_1_i /*
*/ Delta_FG_i_2 Delta_FG_1_i_2 Delta_HHS_i_2 Delta_HHS_1_i_2 Delta_HP_i_2 Delta_HP_1_i_2 Delta_PCDI_i_2 Delta_PCDI_1_i_2 Delta_PCI_i_2 Delta_PCI_1_i_2 Delta_PCT_i_2 Delta_PCT_1_i_2 Delta_WWS_i_2 Delta_WWS_1_i_2 /*
*/ lDelta_FG_1_i lDelta_FG_i lDelta_HHS_1_i lDelta_HHS_i lDelta_HP_1_i lDelta_HP_i lDelta_PCDI_1_i lDelta_PCDI_i lDelta_PCI_1_i lDelta_PCI_i lDelta_PCT_1_i lDelta_PCT_i lDelta_WWS_1_i lDelta_WWS_i

// Subset of useful variables
global XLUseful I DPER DUR POP Unem_rate_i  Edu_i Civ_lab_i
// NAIVE LASSO (wrong model approach: does not take into account variables that are correlated G_i  but it just keep G_i as fixed)
global XLNaive I DPER DUR P_i Z_i Delta_FG_i Delta_FG_1_i Delta_HHS_i Delta_HHS_1_i Delta_HP_i Delta_HP_1_i Delta_PCDI_i Delta_PCDI_1_i Delta_PCI_i Delta_PCI_1_i Delta_PCT_i Delta_PCT_1_i Delta_WWS_1_i Delta_WWS_1_i

lasso linear Vp ($Xfixed G_i) $XLNaive, selection(plugin, heteroskedastic) nolog
estimates store naive_lasso
lassocoef

// DS LASSO (right approach: computes two lasso selections, both on Vp and G_i, and take into account the union of the outcomes)
global XLDS I DPER DUR P_i Z_i Delta_FG_i Delta_FG_1_i Delta_HHS_i Delta_HHS_1_i Delta_HP_i Delta_HP_1_i Delta_PCDI_i Delta_PCDI_1_i Delta_PCI_i Delta_PCI_1_i Delta_PCT_i Delta_PCT_1_i Delta_WWS_1_i Delta_WWS_1_i

lasso linear Vp ($Xfixed) $XLDS, selection(plugin, heteroskedastic)
estimates store ds_lasso_vp
lassocoef

lasso linear G_i ($Xfixed) $XLDS, selection(plugin, heteroskedastic)
estimates store ds_lasso_Gi_i
lassocoef

// DS BIG LASSO (right approach: computes two lasso selections, both on Vp and G_i)
lasso linear Vp ($Xfixed) $XLBig, selection(plugin, heteroskedastic)
estimates store ds_lasso_vp
lassocoef

lasso linear G_i ($Xfixed) $XLBig, selection(plugin, heteroskedastic) nolog
estimates store ds_lasso_G_i_i
lassocoef

// DS USEFUL LASSO (right approach: computes two lasso selection, both on Vp and G_i, and take into account the union of the outcomes)
lasso linear Vp ($Xfixed) $XLUseful, selection(plugin) nolog
estimates store ds_lasso_vp
lassocoef

lasso linear G_i ($Xfixed) $XLUseful, selection(plugin, heteroskedastic) nolog
estimates store ds_lasso_Gi_1_i
lassocoef

global XLDS I DPER DUR P_i Z_i Delta_FG_i Delta_FG_1_i Delta_HHS_i Delta_HHS_1_i Delta_HP_i Delta_HP_1_i Delta_PCDI_i Delta_PCDI_1_i Delta_PCI_i Delta_PCI_1_i Delta_PCT_i Delta_PCT_1_i Delta_WWS_1_i Delta_WWS_1_i

// BASTIANIN APPROACH 1
dsregress Vp G_i, controls(($Xfixed) $XLDS) selection(plugin, heteroskedastic)
estimate store ds
lassocoef (., for(Vp)) (.,for(G_i)) // Check selected variables

global XLDS I DPER DUR P_i Z_i Delta_FG_i Delta_FG_1_i Delta_HHS_i Delta_HHS_1_i Delta_HP_i Delta_HP_1_i Delta_PCDI_i Delta_PCDI_1_i Delta_PCI_i Delta_PCI_1_i Delta_PCT_i Delta_PCT_1_i Delta_WWS_1_i Delta_WWS_1_i

// BASTIANIN APPROACH 2
dsregress Vp G_i, controls((S* i.Year Z_i P_i I DUR DPER)  Delta_FG_i Delta_FG_1_i Delta_HHS_i Delta_HHS_1_i Delta_HP_i Delta_HP_1_i Delta_PCDI_i Delta_PCDI_1_i Delta_PCI_i Delta_PCI_1_i Delta_PCT_i Delta_PCT_1_i Delta_WWS_1_i Delta_WWS_1_i) select(plugin) // DS LASSO + CV as robustness check

estimates store lassocv
lassocoef (.,for(Vp))(.,for(G_i))

// COMMENTS: as expected, both P_i and Z_i results to be the "best" policy variables, that are able to explain all the new variables introduced for the LASSO model. We will then choose P_i and Z_i and compute the LASSO model:
global XLLM DUR DPER Delta_FG_i Delta_FG_1_i Delta_HHS_i Delta_HHS_1_i Delta_HP_i Delta_HP_1_i Delta_PCDI_i Delta_PCDI_1_i Delta_PCI_i Delta_PCI_1_i Delta_PCT_i Delta_PCT_1_i Delta_WWS_1_i Delta_WWS_1_i
lasso linear Vp (Z_i P_i) DUR DPER Delta_FG_i Delta_FG_1_i Delta_HHS_i Delta_HHS_1_i Delta_HP_i Delta_HP_1_i Delta_PCDI_i Delta_PCDI_1_i Delta_PCI_i Delta_PCI_1_i Delta_PCT_i Delta_PCT_1_i Delta_WWS_1_i Delta_WWS_1_i

/////////////////////LASSO EQUATION ON PANEL DATA - PREDICTIONS/////////////////

// Here we will use our last model to predict the election outcome of 2016 and 2020. We will recompute our model estimates both on data with year < 2016 and year < 2020 to check the goodness of our model by predicting as if we did not know the outcome.


//Estimate coefficients with Lasso models
global X_effects S*
global X_lasso I Z_i P_i DPER DUR Delta_PCI_1_i Delta_PCI_i Delta_FG_i Delta_FG_1_i Delta_HHS_i Delta_HHS_1_i Delta_HP_i Delta_HP_1_i Delta_PCDI_i Delta_PCDI_1_i Delta_PCT_i Delta_PCT_1_i Delta_WWS_1_i Delta_WWS_1_i Density Unem_rate_i Civ_lab_i Edu_i Delta_FG_i_2 Delta_FG_1_i_2 Delta_HHS_i_2 Delta_HHS_1_i_2 Delta_HP_i_2 Delta_HP_1_i_2 Delta_PCDI_i_2 Delta_PCDI_1_i_2 Delta_PCI_i_2 Delta_PCI_1_i_2 Delta_PCT_i_2 Delta_PCT_1_i_2 Delta_WWS_i_2 Delta_WWS_1_i_2
global X_lasso_pc I DPER DUR Density Unem_rate_i Civ_lab_i Edu_i

** 2016
lasso linear Vp ($X_effects) $X_lasso in 1/510, selection(plugin, heteroskedastic)
lassocoef
estimates store lasso_16
// selected: Delta_HHS_1_i_2 Delta_PCDI_1_i_2 Delta_WWS_1_i_2

lasso linear G_i ($X_effects) $X_lasso_pc in 1/510, selection(plugin, heteroskedastic)
lassocoef
estimates store lasso_pc_16
// Selected: I DPER DUR

reg Vp G_i DUR Delta_HHS_1_i_2 Delta_PCDI_1_i_2 Delta_WWS_1_i_2 DPER I i.State if Year<2016

predict lasso_16 if Year==2016
gen error_lasso_16 = Vp - lasso_16
gen error_lasso_16_sq = error_lasso_16^2

** 2020
lasso linear Vp ($X_effects) $X_lasso in 1/561, selection(plugin, heteroskedastic)
lassocoef
estimates store lasso_20
// Selected Delta_HHS_1_i_2 Delta_WWS_i_2

lasso linear G_i ($X_effects) $X_lasso in 1/561, selection(plugin, heteroskedastic)
lassocoef
estimates store lasso_pc_20
// Selected: Z_i Delta_PCI_i Delta_PCT_i Delta_HHS_1_i_2 Delta_PCDI_1_i_2

reg Vp G_i Z_i Delta_PCI_i Delta_PCT_i Delta_WWS_i_2 Delta_HHS_1_i_2 Delta_PCDI_1_i_2 i.State if Year<2020

predict lasso_20 if Year==2020
gen error_lasso_20 = Vp - lasso_20
gen error_lasso_20_sq = error_lasso_20^2

// Summarize errors
summarize e_fair_16_sq e_fair_20_sq error_lasso_16_sq error_lasso_20_sq

// Who won election in 2016?
gen w_lasso_16 = 1 if lasso_16 > 50.00 & Year==2016
gen ge_lasso_16 = Elec_votes * w_lasso_16
egen total_elec_votes_2016_lasso = total(ge_lasso_16), by(State)
egen s_lasso_16 = sum(ge_lasso_16)

// who won election in 2020?
gen w_lasso_20 = 1 if lasso_20 > 50.00 & Year==2020
gen ge_lasso_20 = Elec_votes* w_lasso_20
egen total_elec_votes_2020_lasso = total(ge_lasso_20), by(State)
egen s_lasso_20 = sum(ge_lasso_20)

/////////////////////////PLOT PREDICTION LASSO MODEL////////////////////////////
**2016
/*
quietly twoway (scatter lasso_16 State) if Year == 2016, ytitle("Forecasted Democratic Share") 	by(Year) name (Vp_predictions_lasso_2016)
quietly twoway (scatter error_lasso_16 State) if Year == 2016, ytitle("Forecasted Error")				by(Year) name (Error_predictions_lasso_2016)
*/
**2020
/*
quietly twoway (scatter lasso_20 State) if Year == 2020, ytitle("Forecasted Democratic Share") 	by(Year) name (Vp_predictions_lasso_2020)
quietly twoway (scatter error_lasso_20 State) if Year == 2020, ytitle("Forecasted Error")				by(Year) name (Error_predictions_lasso_2020)

** COMBINE GRAPHS
graph combine Vp_predictions_lasso_2016 Error_predictions_lasso_2016 Vp_predictions_lasso_2020 Error_predictions_lasso_2020, c(2) xcommon
*/
list Year State Elec_votes lasso_16 error_lasso_16 total_elec_votes_2016_lasso if Year == 2016
list Year State Elec_votes lasso_20 error_lasso_20 total_elec_votes_2020_lasso if Year == 2020

////////////////////////////////////////////////////////////////////////////////
/*
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 1976
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 1980
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 1984
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 1988
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 1992
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 1996
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 2000
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 2004
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 2008
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 2012
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 2016
twoway (scatter Vp Civ_lab) (lfit Vp Civ_lab) if Year == 2020

twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 1976
twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 1980
twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 1984
twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 1988
twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 1992
twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 1996
twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 2000
twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 2004
twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 2008
twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 2012
twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 2016
twoway (scatter Vp Edu_lvl) (lfit Vp Edu_lvl) if Year == 2020

twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 1976
twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 1980
twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 1984
twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 1988
twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 1992
twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 1996
twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 2000
twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 2004
twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 2008
twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 2012
twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 2016
twoway (scatter Vp Unem_rate) (lfit Vp Unem_rate) if Year == 2020

twoway (scatter Vp G_i) (lfit Vp G_i) if Year == 1980
twoway (scatter Vp G_i) (lfit Vp G_i) if Year == 1984
twoway (scatter Vp G_i) (lfit Vp G_i) if Year == 1988
twoway (scatter Vp G_i) (lfit Vp G_i) if Year == 1992
twoway (scatter Vp G_i) (lfit Vp G_i) if Year == 1996
twoway (scatter Vp G_i) (lfit Vp G_i) if Year == 2000
twoway (scatter Vp G_i) (lfit Vp G_i) if Year == 2004
twoway (scatter Vp G_i) (lfit Vp G_i) if Year == 2008
twoway (scatter Vp G_i) (lfit Vp G_i) if Year == 2012
twoway (scatter Vp G_i) (lfit Vp G_i) if Year == 2016
twoway (scatter Vp G_i) (lfit Vp G_i) if Year == 2020

twoway (scatter Vp gk) (lfit Vp gk) if Year == 1980
twoway (scatter Vp gk) (lfit Vp gk) if Year == 1984
twoway (scatter Vp gk) (lfit Vp gk) if Year == 1988
twoway (scatter Vp gk) (lfit Vp gk) if Year == 1992
twoway (scatter Vp gk) (lfit Vp gk) if Year == 1996
twoway (scatter Vp gk) (lfit Vp gk) if Year == 2000
twoway (scatter Vp gk) (lfit Vp gk) if Year == 2004
twoway (scatter Vp gk) (lfit Vp gk) if Year == 2008
twoway (scatter Vp gk) (lfit Vp gk) if Year == 2012
twoway (scatter Vp gk) (lfit Vp gk) if Year == 2016
twoway (scatter Vp gk) (lfit Vp gk) if Year == 2020
*/
////////////////////////////////////////////////////////////////////////////////

////////////////////////////LASSO - OLS COMPARISON//////////////////////////////

// At last we compare the LASSO estimates with OLS model estimates
estimates table lasso_20, stats(N r2_a) star(.1 .05 .01) keep (*) b(%4.3f) stfmt(%4.3f) varlabel

// And here we compare the two forecasts
list Year total_elec_votes_2020 total_elec_votes_2020_lasso if Year==2020
*/
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////Generic Save////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
save "/Users/marwan/Desktop/UNIMI/Lezioni/1st Year 2021:22/Micro-Econometrics, Causal Inference and Time Series Econometrics/Empirical Project/Stata/Main_Agourram.dta", replace

