unit FormMain;

(*
FormMain.pas/dpr
----------------
Begin: 2010/04/07
Last revision: $Date: 2010-04-08 17:56:46 $ $Author: areeves $
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

interface

  uses
    Windows,
    Messages,
    SysUtils,
    Variants,
    Classes,
    Graphics,
    Controls,
    Forms,
    Dialogs,
    ComCtrls,
    PBPageControl,
    ExtCtrls,
    StdCtrls
  ;


  // Note that the PBPageControls don't look great at design time, 
  // but at run time, all of the problems go away.
  // Some day, it might be nice to fix that, but at the moment, it's
  // unnecessary.

  type TFormMain = class(TForm)
      Panel2: TPanel;
      PBPageControl2: TPBPageControl;
      TabSheet3: TTabSheet;
      TabSheet4: TTabSheet;
      TabSheet6: TTabSheet;
      PBPageControl1: TPBPageControl;
      TabSheet1: TTabSheet;
      TabSheet2: TTabSheet;
      TabSheet5: TTabSheet;
      Panel1: TPanel;
      PBPageControl3: TPBPageControl;
      TabSheet7: TTabSheet;
      TabSheet8: TTabSheet;
      PBPageControl4: TPBPageControl;
      TabSheet9: TTabSheet;
      TabSheet10: TTabSheet;
      TabSheet11: TTabSheet;
      TabSheet12: TTabSheet;
      Button1: TButton;
      procedure Button1Click(Sender: TObject);
    private
      { Private declarations }
    public
      { Public declarations }
    end
  ;

  var
    frmMain: TFormMain;
  
implementation

{$R *.dfm}


  procedure TFormMain.Button1Click(Sender: TObject);
    begin
      TabSheet5.Enabled := not( TabSheet5.Enabled );
      
      // When tab sheets are enabled or disabled dynamically,
      // The page control must be updated manually.
      // Some day, it might be nice for that to be automated, but
      // it would require a new TabSheet-derived class and potentially a lot
      // of extra work to make PBPageControl work with the new tabsheets.
      // For now, just remember to call forceRepaint() whenever a tab's
      // enabled status is changed at run time.
      PBPageControl1.forceRepaint();
    end
  ;


end.
