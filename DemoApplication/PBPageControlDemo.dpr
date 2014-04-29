program PBPageControlDemo;

(*
PBPageControlDemo.dpr
---------------------
Begin: 2010/04/07
Last revision: $Date: 2010-04-08 17:56:47 $ $Author: areeves $
Version: $Revision: 1.1 $
Project: PBPageControl demo application
Website: http://www.naadsm.org/opensource/delphi
Author: Aaron Reeves <Aaron.Reeves@colostate.edu>
--------------------------------------------------
Copyright (C) 2010 Animal Population Health Institute, Colorado State University

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
*)

(*
  This very simple application shows how instances of PBPageControl can be used
  with various tab positions and enabled/disabled tabs.
*)

uses
  Forms,
  FormMain in 'FormMain.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, frmMain);
  Application.Run;
end.
