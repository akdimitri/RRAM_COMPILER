;---------------------------------------------
/*

File Name:      CCSchangeLabelDelimiterSquareToAngular.il
Date Created:   01/15/2016
Language:       SKILL
Assumptions:    None
Tested In:      IC615
SKILL Lint Score (Max=100): 100
SKILL Audit:    Passed, no private functions were found

Here is a SKILL example code that replaces the labels starting with  "A" and ending with "]" 
to have delimiters replaced with "<>".

*/
/*******************************************************************************
*  DISCLAIMER: The following code is provided for Cadence customers to use at  *
*   their own risk. The code may require modification to satisfy the           *
*   requirements of any user. The code and any modifications to the code may   *
*   not be compatible with current or future versions of Cadence products.     *
*   THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING WITHOUT     *
*   LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES OF MERCHANTABILITY *
*   OR FITNESS FOR A PARTICULAR USE.                                           *
*******************************************************************************/

procedure(CCSchangeLabelDelimiterSquareToAngular(libname cellname viewname)
let( (cv mylabels myUniquelabels tmpcv labelText name index newlab)

;;cv = geGetEditCellView()
cv = dbOpenCellViewByType(libname cellname viewname nil "a")

;;search the cell hierarchy for labels that start with "A" and end with "]"
;;The third argument defines the number of hierarchy levels you wish to search

mylabels=leSearchHierarchy( cv cv~>bBox 1 "label"
list( list( "text" "==" "*" ) list("text" "==" "]$"))
          )

;;create a list of unique labels

myUniquelabels = nil

foreach(x mylabels
    unless(member(x myUniquelabels)
                myUniquelabels = cons(x myUniquelabels)
                  )
        )

foreach(lab myUniquelabels
     labelText = lab~>theLabel
     name = car(parseString(labelText "["))
      index= car(parseString(cadr(parseString(labelText "[")) "]"))
      newlab= buildString(list(buildString(list(name index ) "<") ">") "")

    printf("Original Label was %s\n" labelText)
    printf("The new Label would be %s\n" newlab)

;;if label is not in top level, we need to open the instance master in edit
;;mode to modify the label

 if(lab~>cellView~>cellName != cv~>cellName then
    tmpcv = dbOpenCellViewByType(lab~>cellView~>libName lab~>cellView~>cellName
 lab~>cellView~>viewName nil "a")

;;println(lab~>name)

 lab~>theLabel = newlab
 dbSave(tmpcv)
 dbClose(tmpcv)
  )

;; for top level labels
  ;;println(lab~>name)

  lab~>theLabel = newlab

)

dbSave(cv)
dbClose(cv)

 );let
);procedure

;---------------------------------------------
