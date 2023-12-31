#!/usr/bin/env perl

$latex            = 'platex -halt-on-error';
$latex_silent     = 'platex -halt-on-error -interaction=batchmode';
$bibtex           = 'pbibtex';
$biber            = 'biber --bblencoding=utf8 -u -U --output_safechars';
$dvipdf           = 'dvipdfmx %O -o %D %S';
$makeindex        = 'mendex %O -o %D %S';
$max_repeat       = 5;
$pdf_mode         = 3;
$pvc_view_file_via_temporary = 0;
#$pdf_previewer    = '"/mnt/c/'Program Files (x86)'/Google/Chrome/Application/chrome.exe" -reuse-instance %O %S';
$pdf_previewer    = '"/mnt/c/FreeSoft/SumatraPDF-3.1.2-64/sumatraPDF.exe" -reuse-instance %O %S';
