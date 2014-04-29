unit PBPageControl;

(*
PBPageControl.pas
-----------------
Begin: 2005/12/20
Last revision: $Date: 2010-05-13 22:08:20 $ $Author: areeves $
Version: $Revision: 1.10 $
Project: various
Website: http://www.naadsm.org/opensource/delphi
Author: Aaron Reeves <Aaron.Reeves@colostate.edu>
Original Author: Peter Below
--------------------------------------------------
This unit is based on original code written by Peter Below, which is available from
http://groups.google.com/group/borland.public.delphi.vcl.components.using/browse_thread/thread/5ad1025d1d20b25a/1355c3fef60bcaaf?lnk=st&q=PBPageControl&rnum=1#1355c3fef60bcaaf

Modified version 
Copyright (C) 2005 - 2010 Animal Population Health Institute, Colorado State University

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
*)


(*
	Revision history 
	-----------------
  2010/05/12: Appearance of the labels at bottom tab positions is improved.

  2010/04/08: Bug fix for 64-bit versions of Windows implemented.
              Positions for tab labels now look much better.
              All four tab positions (top, bottom, left, and right) now work and look pretty good.

  2006/02/07: Added forceRepaint method to update display of tab page captions.

	2005/12/20: Bold caption for active tab eliminated.
	
	2005/12/20: Interface code reformatted.
	
	2005/12/20: Modifications made by Tony Lenton have been incorporated (procedure DrawTab). See
							http://groups.google.com/group/borland.public.delphi.vcl.components.using/browse_thread/thread/1d03284963576ce7/0f2b283bfc5f83d0?lnk=st&q=PBPageControl&rnum=2#0f2b283bfc5f83d0	

*)


interface

  uses
    Windows, 
    Messages, 
    SysUtils, 
    Classes, 
    Graphics, 
    Controls,
    Forms, 
    Dialogs,
    ComCtrls
  ;

	{*
		This unit implements an improved page control widget, which allows the
		display of disabled tab sheets.

		Create and install the package containing this component with the menu command 
		Component->Install component...

		This unit is based on code written by Peter Below.  Original source code is available
		at the URL listed above, or may be found by searching "groups.google.com" for
		"PBPageControl".
	}
	type TPBPageControl = class(TPageControl)
		private
			Procedure WMLButtonDown( Var msg: TWMLButtonDown ); message WM_LBUTTONDOWN;
			Procedure CMDialogKey( Var msg: TWMKey ); message CM_DIALOGKEY;
			procedure SetOwnerdraw(const Value: Boolean);
			function GetOwnerdraw(): Boolean;

		protected
			procedure DrawTab(TabIndex: Integer; const Rect: TRect; Active: Boolean); override;
      procedure TextOutAngle( Canvas: TCanvas; x, y: integer; s: string; angle: integer; enabled: boolean );

		public
			Constructor Create( aOwner: TComponent ); override;

      procedure forceRepaint();

		published
			property Ownerdraw: Boolean read GetOwnerdraw write SetOwnerdraw default True;

		end
	;

	// Global functions
	//-----------------
	{ Called when a package is created/installed }
	procedure Register();

implementation


  Uses
    //DebugWindow,
    BugFix64,
  
    CommCtrl
  ;

  procedure Register;
  begin
    RegisterComponents('APHIControls', [TPBPageControl]);
  end;

  { TPBPageControl }

  procedure TPBPageControl.CMDialogKey(var msg: TWMKEY);
  var
    thistab, tab: TTabSheet;
    forward: Boolean;
  begin
    If (msg.CharCode = Ord(#9)) and (GetKeyState( VK_CONTROL ) < 0) Then
    Begin
      thistab := ActivePage;
      forward := GetKeyState( VK_SHIFT ) >= 0;
      tab := thistab;
      Repeat
        tab := FindNextPage( tab, forward, true );
      Until tab.Enabled or (tab = thistab);
      If tab <> thistab Then Begin
        If CanChange Then Begin
          ActivePage := tab;
          Change;
        End;
        Exit;
      End;
    End;
    inherited;
  end;


  constructor TPBPageControl.Create(aOwner: TComponent);
  begin
    //dbcout( '*** Begin TPBPageControl.Create...' );
    inherited;

    OwnerDraw := True;
    //dbcout( '*** Done TPBPageControl.Create' );
  end;


  // Modified from http://www.experts-exchange.com/Programming/Programming_Languages/Delphi/Q_21488485.html
  procedure TPBPageControl.TextOutAngle( Canvas: TCanvas; x,y: integer; s: string; angle: integer; enabled: boolean );
    var
      Fnt, FntPrev: HFONT;
      lMyLogFont : TLogFont;
    begin
      if( enabled ) then
        begin
          Canvas.Brush.Style := bsSolid;
          Canvas.Font.Color := clBlack;

          SetBkMode(Canvas.Handle, TRANSPARENT);
          GetObject(Canvas.Font.Handle, SizeOf(TLogFont), @lMyLogFont);
          lMyLogFont.lfEscapement:= Angle;
          lMyLogFont.lfOutPrecision:= OUT_TT_ONLY_PRECIS;

          Fnt:= CreateFontIndirect(lMyLogFont);
          FntPrev := SelectObject(Canvas.Handle, Fnt);

          Canvas.TextOut( x, y, s );

          SelectObject(Canvas.Handle, FntPrev);
          DeleteObject(Fnt);
          SetBkMode(Canvas.Handle, OPAQUE);
        end
      else
        begin
          // Draw the shadow
          //----------------
          Canvas.Brush.Style := bsClear;
          Canvas.Font.Color := clWhite;

          SetBkMode(Canvas.Handle, TRANSPARENT);
          GetObject(Canvas.Font.Handle, SizeOf(TLogFont), @lMyLogFont);
          lMyLogFont.lfEscapement:= Angle;
          lMyLogFont.lfOutPrecision:= OUT_TT_ONLY_PRECIS;

          Fnt:= CreateFontIndirect(lMyLogFont);
          FntPrev := SelectObject(Canvas.Handle, Fnt);

          Canvas.TextOut( x + 1, y + 1, s );

          SelectObject(Canvas.Handle, FntPrev);
          DeleteObject(Fnt);
          SetBkMode(Canvas.Handle, OPAQUE);

          // Reset and draw the main text
          //-----------------------------
          Canvas.Brush.Style := bsClear;
          Canvas.Font.Color := clGray;

          SetBkMode(Canvas.Handle, TRANSPARENT);
          GetObject(Canvas.Font.Handle, SizeOf(TLogFont), @lMyLogFont);
          lMyLogFont.lfEscapement:= Angle;
          lMyLogFont.lfOutPrecision:= OUT_TT_ONLY_PRECIS;

          Fnt:= CreateFontIndirect(lMyLogFont);
          FntPrev := SelectObject(Canvas.Handle, Fnt);

          Canvas.TextOut( x, y, s );

          SelectObject(Canvas.Handle, FntPrev);
          DeleteObject(Fnt);
          SetBkMode(Canvas.Handle, OPAQUE);
        end
      ;
    end
  ;


  procedure TPBPageControl.DrawTab( TabIndex: Integer; const Rect: TRect; Active: Boolean );
    var
     imageindex: Integer;
     r: TRect;
     S: String;

     angle, x, y: integer;
    begin
     // AR: I don't care for the bold caption, so I've taken the following line out.
     //If Active then Canvas.Font.Style := [fsBold];

     //dbcout( 'Drawing tab ' + intToStr( TabIndex ) + ' of ' + self.Name );

      if Assigned( OnDrawTab ) then
        inherited
      else
        begin
          r := Rect;
          Canvas.Fillrect( r );
          imageindex := GetImageIndex( tabindex );

          if( ( imageindex >= 0 ) and Assigned( Images ) ) then
            begin
              SaveDC( canvas.handle );
              images.Draw( Canvas, Rect.Left+4, Rect.Top+2, imageindex, Pages[TabIndex].enabled );
              // images.draw fouls the canvas colors if it draws
              // the image disabled, thus the SaveDC/RestoreDC
              RestoreDC( canvas.handle, -1 );
              R.Left := R.Left + images.Width + 4;
            end
          ;

          if( tpTop = self.TabPosition ) then
            begin
              r.Left := r.Left + integer( 2 * canvas.textWidth( ' ' ) div 3 );

              if( self.TabIndex = tabIndex ) then
                r.Left := r.Left + 2
              else if( tpBottom = self.TabPosition ) then
                r.Top := r.Top - 2
              ;
            end
          else if( tpBottom = self.TabPosition ) then
            begin
              r.Left := r.Left + integer( 2 * canvas.textWidth( ' ' ) div 3 );

              // Active tab
              if( self.TabIndex = tabIndex ) then
                begin
                  r.Top := r.Top + 1;
                  r.Left := r.Left + 3;
                end

              // Inactive tabs
              else if( tpBottom = self.TabPosition ) then
                r.Top := r.Top - 2
              ;
            end
          else if( tpLeft = self.TabPosition ) then
            begin
              r.Bottom := r.Bottom - integer( 2 * canvas.textWidth( ' ' ) div 3 );

              if( self.TabIndex = tabIndex ) then
                r.Bottom := r.Bottom - 2
              ;
            end
          else // tpRight = self.TabPosition
            begin
              r.Top := r.Top + integer( 2 * canvas.textWidth( ' ' ) div 3 );

              if( self.TabIndex = tabIndex ) then
                r.Top := r.Top + 2
              ;
            end
          ;

          // print caption
          S := Pages[ TabIndex ].Caption;
          InflateRect( r, -2, -2 );

          if( self.TabPosition in [ tpTop, tpBottom ] ) then
            begin
              angle := 0;
              x := r.Left;
              y := r.Top;
            end
          else if( self.TabPosition = tpLeft ) then
            begin
              angle := 900;
              x := r.Left;
              y := r.Bottom;
            end
          else // self.TabPosition = tpRight
            begin
              angle := -900;
              x := r.Right;
              y := r.Top;
            end
          ;

          TextOutAngle( Canvas, x, y, s, angle, Pages[TabIndex].Enabled );
        end
      ;
    end
  ;


  function TPBPageControl.GetOwnerdraw: Boolean;
  begin
    result := inherited OwnerDraw;
  end;


  procedure TPBPageControl.SetOwnerdraw(const Value: Boolean);
  begin
    inherited OwnerDraw := true;
  end;


  procedure TPBPageControl.WMLButtonDown(var msg: TWMLButtonDown);
  var
    hi: TTCHitTestInfo;
    tabindex: Integer;
  begin
    If csDesigning In ComponentState Then Begin
      inherited;
      Exit;
    End;
    hi.pt.x := msg.XPos;
    hi.pt.y := msg.YPos;
    hi.flags := 0;
    tabindex := Perform( TCM_HITTEST, 0, longint(@hi));
    If (tabindex >= 0) and ((hi.flags and TCHT_ONITEM) <> 0)
    Then
      If not Pages[ tabindex ].Enabled Then Begin
        msg.result := 0;
        Exit;
      End;
    inherited;
  end;


  procedure TPBPageControl.forceRepaint();
    begin
      self.Invalidate();
      self.repaint();
    end
  ;


initialization
  patchTWinControl64();

end.
