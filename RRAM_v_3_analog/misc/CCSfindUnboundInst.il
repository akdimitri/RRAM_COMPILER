/*************************************************************************
* DISCLAIMER: The following code is provided for Cadence customers       *
* to use at their own risk. The code may require modification to         *
* satisfy the requirements of any user. The code and any modifications   *
* to the code may not be compatible with current or future versions of   *
* Cadence products. THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, *
* INCLUDING WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED         *
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.         *
*************************************************************************/

/* USAGE
The following SKILL code can help you print information about unbound cells
of a library. 

Load the SKILL code in CIW:
load "CCSfindUnboundInst.il"

It defines SKILL function CCSfindUnboundInst(). It expects three arguments:

1. Library name, example:  "mylib"
2. Cell name, example: "mycell"
3. View name,example: "schematic"

To run it, type in CIW:
CCSfindUnboundInst("mylib" "mycell" "schematic" )

It will look into the "mylib" "mycell" "schematic" hierarchically and tell
about all the unbound instances.

Another example, for looking into layout hierarchy:
CCSfindUnboundInst("mylib" "mycell" "layout")

NOTE: Line number three of the code has a variable skipLibList. The code does
not traverse through cells belonging to libraries mentioned in skipLibList.

If you want to ignore a library from being traversed or reported, add the name
of the library in the skipLibList.

*/

procedure(CCSfindUnboundInst(myLib myCell myview  @optional (mylist list()))
let(( cv insts myMaster skipLibList)
     skipLibList=list("basic" "analogLib" "gpdk")

     cv=dbOpenCellViewByType(myLib myCell myview "" "r")
     insts = cv~>instHeaders
     
	foreach( header insts
              myMaster= header~>master
              getWarn()

              if( myMaster
                    then
                    if( !member(myMaster mylist) && !member(header~>libName skipLibList) 
				&& member( myview myMaster~>cell~>views~>name)
                          then
                          mylist = cons( myMaster mylist)

              mylist=CCSfindUnboundInst(header~>libName header~>cellName 
		if(cv~>cellViewType=="schematic" then myview else header~>viewName) mylist)
                                      )

         else

printf("Unbound Master: Library:%s, Cell:%s, View:%s, Missing From: Lib:%s, Cell:%s, View:%s\n"
header~>libName header~>cellName header~>viewName cv~>libName cv~>cellName cv~>viewName)

                   )
              )
dbClose(cv)
mylist
) ; end let
) ; end procedure

