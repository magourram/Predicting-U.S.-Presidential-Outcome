////////////////////////////////////////////////////////////////////////////////
///////////Import US popular vote dataset and data manipulation/////////////////
////////////////////////////////////////////////////////////////////////////////

//The data file `1976-2016-president` contains constituency (state-level) returns 
//for elections to the U.S. presidency from 1976 to 2016. 
//The data source is the document "[Statistics of the Congressional Election]
//(http://history.house.gov/Institution/Election-Statistics/Election-Statistics/)
//" published biennially by the Clerk of the U.S. House of Representatives.

clear all
import delimited "/Users/marwan/Desktop/UNIMI/Lezioni/1st Year 2021:22/Micro-Econometrics, Causal Inference and Time Series Econometrics/Empirical Project/DATASET/Popular vote by US State/Popular vote by US State 1976-2020.csv"

label variable year 			"Year in which election was held"
label variable office 			"U.S. PRESIDENT"
label variable state 			"State name"
label variable state_po 		"U.S. postal code state abbreviation"
label variable state_fips 		"State FIPS code"
label variable state_cen 		"U.S. Census state code"
label variable state_ic 		"State code"
label variable candidate 		"Name of the candidate"
label variable party_detailed 	"Party of the candidate (always entirely uppercase)"
label variable party_simplified "Party of the candidate (always entirely uppercase)"
label variable writein 			"Vote totals associated with write-in candidates. TRUE: write-in candidates; FALSE: non-write-in candidates"
label variable candidatevotes 	"Votes received by this candidate for this particular party"
label variable totalvotes 		"Total number of votes cast for this election"
label variable version 			"20200113"

// Some of the presidetial candidate are "write-in"=TRUE. Manipulate it manually in order to obtain a strongly balanced dataset

replace writein = "FALSE" if party_simplified=="DEMOCRAT" & year == 2020 & state == "DISTRICT OF COLUMBIA"
replace writein = "FALSE" if party_simplified=="REPUBLICAN" & year == 2020 & state == "DISTRICT OF COLUMBIA"

// In the dataset I changed the writein variable to "FALSE" for the presidential candidate Biden and Trump in the 2020 Election run (since in the original data are set both to "TRUE")
bys state year: keep if writein=="FALSE"
bys state year: keep if (party_simplified== "REPUBLICAN" | party_simplified =="DEMOCRAT")
bys state year: gen votes = sum(candidatevotes)
bys state year: gen Votes = votes[2]
drop votes
gen propvotes = (candidatevotes/Votes)
label variable propvotes 		"Ratio between candidatevotes and totalvotes"
bys state year: gen totvotes=sum(candidatevotes)
label variable totvotes 		"Total votes for the two parties in each state per election year"
bys state year: gen tot=totvotes[2]
label variable tot 				"Total votes per State given only two parties"
bys state year:gen d=(candidatevotes/Votes)*100 // Dependent variable of the model
label variable d 				"Dem share of presidential vote"
bys state year: gen D=sum(d)
bys state year: gen D_=D[2]
label variable D_ 				"Sum of the Democratic and Republican share votes in the election year by State"
drop D D_ propvotes Votes totvotes tot


// The democrat party in the following states is not registered formally as DEMOCRAT. Change it in order to preserve the observation.
replace party_detailed = "DEMOCRAT" if party_simplified=="DEMOCRAT" & year == 2000 & state == "MINNESOTA"
replace party_detailed = "DEMOCRAT" if party_simplified=="DEMOCRAT" & year == 2004 & state == "MINNESOTA"
replace party_detailed = "DEMOCRAT" if party_simplified=="DEMOCRAT" & year == 2012 & state == "MINNESOTA"

// Remove all observartions that are related to REPUBLICAN party
bys state year : keep if party_detailed == "DEMOCRAT"

// Destring string variables and drop unnecesary variables
rename d Vp
encode state, gen (State)
encode candidate, gen (Candidate)
encode state_po, gen (State_po)
encode party_simplified, gen (Party)

drop state notes version writein  state_po office candidate party_detailed party_simplified state_fips state_cen state_ic

rename year (Year)
rename candidatevotes (Candidate_votes)
rename totalvotes (Total_votes)
order Year State State_po Party Candidate Candidate_votes Total_votes Vp

// Introduce president variable in order to generate I [Incumbent]
gen President = "."
label variable President "President name"
replace President = "CARTER, JIMMY" if Year==1976
replace President = "REAGAN, RONALD" if Year==1980
replace President = "REAGAN, RONALD" if Year==1984
replace President = "BUSH, GEORGE H.W." if Year==1988 
replace President = "CLINTON, BILL" if Year==1992
replace President = "CLINTON, BILL" if Year==1996
replace President = "BUSH, GEORGE W." if Year==2000
replace President = "BUSH, GEORGE W." if Year==2004
replace President = "OBAMA, BARACK H." if Year==2008
replace President = "OBAMA, BARACK H." if Year==2012
replace President = "TRUMP, DONALD J." if Year==2016
replace President = "BIDEN, JOSEPH R. JR" if Year==2020
encode President, gen(President_)
drop President
rename President_ (President)

gen I =.
label variable I 	"Incumbent: 1 [-1] if Dem [Rep] presidential incumbent at the time of the election"
replace I = -1 	if 	Year == 1976
replace I = 1 	if 	Year == 1980
replace I = -1 	if 	Year == 1984
replace I = -1 	if 	Year == 1988
replace I = -1 	if 	Year == 1992
replace I = 1 	if 	Year == 1996
replace I = 1 	if 	Year == 2000
replace I = -1 	if 	Year == 2004
replace I = -1 	if 	Year == 2008
replace I = 1 	if 	Year == 2012
replace I = 1 	if 	Year == 2016
replace I = -1 	if 	Year == 2020

// Introduce DPER [President running again]
gen DPER =.
label variable DPER 	"President running again: 1 [-1] if a Dem [Rep] president is running again, 0 otherwise"
replace DPER = 0 	if 	Year == 1976
replace DPER = 1 	if 	Year == 1980
replace DPER = -1	if 	Year == 1984
replace DPER = 0 	if 	Year == 1988
replace DPER = -1 	if 	Year == 1992
replace DPER = 1 	if 	Year == 1996
replace DPER = 0 	if 	Year == 2000
replace DPER = -1 	if 	Year == 2004
replace DPER = 0 	if 	Year == 2008 
replace DPER = 1 	if	Year == 2012
replace DPER = 0	if	Year == 2016
replace DPER = -1 	if 	Year == 2020

// Introduce WAR (Years in which the election were held during the 1st or 2nd World War)
gen WAR = 0
label variable WAR	 "1 [0] Presidential lection [not] held during WWI or WWII"

// Introduce COVID [Years in which covid affected the economy], similar to WAR variable in Fair model
gen COVID = 0
replace COVID = 1 if Year >= 2019

label variable COVID "Election held during COVID-19 pandemic"

// Introduce DUR [Duration of the party as US President]
gen DUR =.
label variable DUR "0 if either party has been in the White House for one term, 1 [−1] if the Democratic [Republican] party has been in the White House for two consecutive terms, 1.25 [−1.25] if the Democratic [Republican] party has been in the White House for three consecutive terms, 1.50 [−1.50] if the Democratic [Republican] party has been in the White House for four consecutive terms, and so on."
replace DUR = -1	if		Year == 1976
replace DUR = 0		if		Year == 1980
replace DUR = 0 	if 		Year == 1984
replace DUR = 1 	if 		Year == 1988
replace DUR = -2	if		Year == 1992 
replace DUR = 0 	if 		Year == 1996
replace DUR = 1		if		Year == 2000
replace DUR = 0 	if 		Year == 2004
replace DUR = -1	if		Year == 2008
replace DUR = 0 	if 		Year == 2012
replace DUR = 1		if		Year == 2016
replace DUR = 0		if		Year == 2020

// Tabulate the variable Year
tab Year

// Declare variable to be a panel data variable
xtset State Year, delta (4)

//SAVE!!
save "/Users/marwan/Desktop/UNIMI/Lezioni/1st Year 2021:22/Micro-Econometrics, Causal Inference and Time Series Econometrics/Empirical Project/Stata/Main_US_Popular_vote.dta", replace
