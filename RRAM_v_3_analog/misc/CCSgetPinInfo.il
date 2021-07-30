/* CCSgetPinInfo.il

Group		Custom IC, Cadence Design Systems
Language	SKILL
Revision No.	1.3
Date Created	Mar 13, 2003 
Last Modified	
Tested in	IC50, IC617
Lint score	100 (best is 100)
Description:

A simple SKILL procedure to process the current cellview, or the
cellview that is passed in as an argument, to print a list of the
pins in that design and their bounding boxes. Shape pins and
instance pins are processed.

Usage:

  ;; with a layout cellview currently open, output to CIW
  CCSgetPinInfo()

  ;; for a specifically named cellview, output to CIW
  cv = dbOpenCellViewByType("testLib" "testCell" "layout")
  CCSgetPinInfo(?cv cv)

  ;; to send output to named file for current layout cellview
  CCSgetPinInfo(?file "/tmp/pinInfo.txt")

  ;; to use single file for several cellviews
  cv1 = dbOpenCellViewByType("testLib" "testCell1" "layout")
  cv2 = dbOpenCellViewByType("testLib" "testCell2" "layout")
  fptr = outfile("/tmp/singleFileForMultipleCVs")
  CCSgetPinInfo(?file fptr ?cv cv1)
  CCSgetPinInfo(?file fptr ?cv cv2)
  close(fptr)

***************************************************

SCCS Info: @(#) CCSgetPinInfo.il 03/30/10.10:14:52 1.3

********************************************************************
* DISCLAIMER: The following code is provided for Cadence customers *
* to use at their own risk. The code may require modification to   *
* satisfy the requirements of any user. The code and any           *
* modifications to the code may not be compatible with current or  *
* future versions of Cadence products.                             *
* THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING   *
* WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES  *
* OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.              *
********************************************************************

*/


/*******************************************************************
*                                                                  *
*    CCSgetPinInfo(?cv d_cellview ?file p_outport || s_filename)   *
*                                                                  *
* This procedure accepts two keyword arguments (optional), the     *
* "cv" argument can be used to supply a cellview db object to      *
* operate on, if none supplied, the current cellview is assumed.   *
* The "file" argument can be used to supply either an output port  *
* object or a filename, if neither are given then stdout is used.  *
* Shape and instance pins are found in the cellview and their net  *
* names and bounding boxes are printed to the appropriate location *
*                                                                  *
*******************************************************************/

procedure(CCSgetPinInfo(@key (cv geGetEditCellView())
                         file)
let( (shapePins instPins allPins filePtr)
  ;; when cv is not nil and is a valid database object
  when(and(cv dbobjectp(cv))
    ;; get lists of instance pins and shape pins
    instPins  = setof(x dbGetq(cv instances) x~>pin)
    shapePins = setof(x dbGetq(cv shapes) x~>pin)
    ;; when there are instance pins or shape pins
    when(or(instPins shapePins)
      ;; combine pin lists into one list
      allPins = append(instPins shapePins)
      ;; if the "file" argument is an output port object use that,
      ;; otherwise if it is a string then open an output port,
      ;; otherwise send output to stdout
      filePtr = cond(
		  (outportp(file) file)
		  (stringp(file) outfile(file) || stdout)
		  (t stdout)
      )
      fprintf(filePtr "%s %s %s contains the following pins:\n"
	cv~>libName cv~>cellName cv~>viewName)
      ;; process pin list and print out information
      foreach(pin allPins
        fprintf(filePtr "Name: %-15s bBox: %L\n"
	  pin~>net~>name pin~>bBox)
      )
      ;; when "file" was supplied but not an output port [don't
      ;; want to close a supplied port!] and a file was opened
      ;; close the pointer to that file
      when(and(file nequal(filePtr stdout) null(outportp(file)))
        close(filePtr)
      )
    );; when instance or shape pins exist
    t
  );; when a valid cellview is supplied
);; let
);; procedure CCSgetPinInfo
