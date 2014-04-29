unit BugFix64;

(*
BugFix64.pas
------------
Begin: 2010/04/08
Last revision: $Date: 2010-04-08 17:56:46 $ $Author: areeves $
Version: $Revision: 1.1 $
Project: various
Website: http://www.naadsm.org/opensource/delphi
Author: Aaron Reeves <Aaron.Reeves@colostate.edu>
Original Author: Florent Ouchet
--------------------------------------------------
This unit is based on code written by Florent Ouchet, which is available from
http://qc.embarcadero.com/wc/qcmain.aspx?d=19859
*)

(*
  There is a known issue with versions of Delphi prior to Delphi 2009 on 64-bit Windows
  platforms that causes drawing of TPageControl and TTabControl components to fail when
  the OwnerDraw property of these components is set to True.  There are several bugs in
  the Delphi-supplied unit Controls.pas that cause this problem.

  The code below, slightly modified from code developed by Florent Ouchet, applies a fix
  for this problem when it is dynamically executed at run-time.  This saves a great deal
  of trouble that might otherwise be necessary to recompile Delphi-supplied units.

  This code has been tested and works with Delphi 7.  It has not been tested with any other
  versions of Delphi.

  Please see the following URLs for more detailed information:
    http://qc.embarcadero.com/wc/qcmain.aspx?d=19859
    https://forums.embarcadero.com/thread.jspa?threadID=30056&tstart=0
    https://forums.embarcadero.com/thread.jspa;jsessionid=0CDEE653439F274FF4FD42AB658626CB?messageID=115730
*)


interface

  // Use this function to execute the patch
  function patchTWinControl64(): boolean;

  // Use these two functions to check the status of the patch
  function patch64Success(): boolean;
  function patch64ErrorMessage(): string;


implementation

  uses
    Windows,
    Controls,
    Messages
  ;

  {$OVERFLOWCHECKS OFF}

  var
    _patch64ErrorMessage: string;
    _patch64Success: boolean;

//-----------------------------------------------------------------------------
// Private helper methods
//-----------------------------------------------------------------------------
  function GetMethodAddress(AMessageID: Word; AClass: TClass;
    out MethodAddr: Pointer): Boolean;
  var
    DynamicTableAddress: Pointer;
    MethodEntry: ^Pointer;
    MessageHandlerList: PWord;
    EntryCount, EntryIndex: Word;
  begin
    Result := False;

    DynamicTableAddress := Pointer(PInteger(Integer(AClass) + vmtDynamicTable)^);
    MessageHandlerList := PWord(DynamicTableAddress);
    EntryCount := MessageHandlerList^;

    if EntryCount > 0 then
      for EntryIndex := EntryCount - 1 downto 0 do
    begin
      Inc(MessageHandlerList);
      if (MessageHandlerList^ = AMessageID) then
      begin
        Inc(MessageHandlerList);
        MethodEntry := Pointer(Integer(MessageHandlerList) + 2 * (2 * EntryCount - EntryIndex) - 4);            
        MethodAddr := MethodEntry^;
        Result := True;
      end;
    end;
  end;


  function PatchInstructionByte(MethodAddress: Pointer; ExpectedOffset: Cardinal;
    ExpectedValue: Byte; NewValue: Byte): Boolean;
  var
    BytePtr: PByte;
    OldProtect: Cardinal;
  begin
    Result := False;

    BytePtr := PByte(Cardinal(MethodAddress) + ExpectedOffset);

    if BytePtr^ = NewValue then
    begin
      Result := True;
      Exit;
    end;

    if( BytePtr^ <> ExpectedValue ) then
      begin
        _patch64ErrorMessage := _patch64ErrorMessage + ( 'Existing value is not equal to expected value in PatchInstructionByte()' );
        Exit;
      end
    ;

    if VirtualProtect(BytePtr, SizeOf(BytePtr^), PAGE_EXECUTE_READWRITE, OldProtect) then
      begin
        try
          BytePtr^ := NewValue;
          Result := True;
        finally
          Result := Result
            and VirtualProtect(BytePtr, SizeOf(BytePtr^), OldProtect, OldProtect)
            and FlushInstructionCache(GetCurrentProcess, BytePtr, SizeOf(BytePtr^))
          ;
        end;
      end
    else
      _patch64ErrorMessage := _patch64ErrorMessage + ( 'virtualProtect failed in PatchInstructionByte()' );
    ;
  end;


  function PatchInstructionBytes(MethodAddress: Pointer; ExpectedOffset: Cardinal;
    const ExpectedValues: array of Byte; const NewValues: array of Byte;
    const PatchedValues: array of Byte): Boolean;
  var
    BytePtr, TestPtr: PByte;
    OldProtect, Index, PatchSize: Cardinal;
  begin
    BytePtr := PByte(Cardinal(MethodAddress) + ExpectedOffset);

    Result := True;
    TestPtr := BytePtr;
    for Index := Low(PatchedValues) to High(PatchedValues) do
    begin
      if TestPtr^ <> PatchedValues[Index] then
      begin
        Result := False;
        Break;
      end;
      Inc(TestPtr);
    end;

    if Result then
      Exit;

    Result := True;
    TestPtr := BytePtr;
    for Index := Low(ExpectedValues) to High(ExpectedValues) do
    begin
      if TestPtr^ <> ExpectedValues[Index] then
      begin
        Result := False;
        Exit;
      end;
      Inc(TestPtr);
    end;

    PatchSize := Length(NewValues) * SizeOf(Byte);

    if VirtualProtect(BytePtr, PatchSize, PAGE_EXECUTE_READWRITE, OldProtect) then
    begin
      try
        TestPtr := BytePtr;
        for Index := Low(NewValues) to High(NewValues) do
        begin
          TestPtr^ := NewValues[Index];
          Inc(TestPtr);
        end;
        Result := True;
      finally
        Result := Result
          and VirtualProtect(BytePtr, PatchSize, OldProtect, OldProtect)
          and FlushInstructionCache(GetCurrentProcess, BytePtr, PatchSize);
      end;
    end;
  end;
//-----------------------------------------------------------------------------



//-----------------------------------------------------------------------------
// Global functions
//-----------------------------------------------------------------------------
  function patch64ErrorMessage(): string;
    begin
      result := _patch64ErrorMessage;
    end
  ;


  function patch64Success(): boolean;
    begin
      result := _patch64Success;
    end
  ;


  function patchTWinControl64(): boolean;
    var
      MethodAddress: Pointer;
    begin
      result := true; // Until shown otherwise

      _patch64ErrorMessage := '';

      // Patch TWinControl.WMDrawItem
      //-----------------------------
      if not GetMethodAddress(WM_DRAWITEM, TWinControl, MethodAddress) then
        begin
          result := false;
          _patch64ErrorMessage := _patch64ErrorMessage + ( 'Cannot find WM_DRAWITEM handler in TWinControl' );
        end
      else if
        (not PatchInstructionByte(MethodAddress, 13, $4, $14)) // release and package
      and
        (not PatchInstructionByte(MethodAddress, 23, $4, $14)) // debug
      then
        begin
          result := false;
          _patch64ErrorMessage := _patch64ErrorMessage + ('Cannot patch WM_DRAWITEM');
        end
      ;


      // Patch TWinControl.WMCompareItem
      //--------------------------------
      if not GetMethodAddress(WM_COMPAREITEM, TWinControl, MethodAddress) then
        begin
          result := false;
          _patch64ErrorMessage := _patch64ErrorMessage + ( 'Cannot find WM_COMPAREITEM handler in TWinControl' );
        end
      else if
        (not PatchInstructionByte(MethodAddress, 13, $04, $8)) // release and package
      and
        (not PatchInstructionByte(MethodAddress, 23, $04, $8)) // debug
      then
        begin
          result := false;
          _patch64ErrorMessage := _patch64ErrorMessage + ( 'Cannot patch WM_COMPAREITEM handler' );
        end
      ;


      // Patch TWinControl.WMDeleteItem
      //-------------------------------
      if not GetMethodAddress(WM_DELETEITEM, TWinControl, MethodAddress) then
        begin
          result := false;
          _patch64ErrorMessage := _patch64ErrorMessage + ('Cannot find WM_DELETEITEM handler in TWinControl');
        end
      else if
        (not PatchInstructionByte(MethodAddress, 13, $04, $0C)) // release and package
      and
        (not PatchInstructionByte(MethodAddress, 23, $04, $0C)) // debug
      then
        begin
          result := false;
          _patch64ErrorMessage := _patch64ErrorMessage + ('Cannot patch WM_DELETEITEM handler');
        end
      ;


      // Patch TWinControl.WMMeasureItem
      //--------------------------------
      if not GetMethodAddress(WM_MEASUREITEM, TWinControl, MethodAddress) then
        begin
          result := false;
          _patch64ErrorMessage := _patch64ErrorMessage + ('Cannot find WM_MEASUREITEM handler in TWinControl');
        end
      else if
        (not PatchInstructionBytes(MethodAddress, 10, [$08, $8B], [$04, $90, $90, $90], [$04, $E8])) // release and package
      and
        (not PatchInstructionBytes(MethodAddress, 20, [$08, $8B], [$04, $90, $90, $90], [$04, $E8])) // debug
      then
        begin
          result := false;
          _patch64ErrorMessage := _patch64ErrorMessage + ('Cannot patch WM_MEASUREITEM handler');
        end
      ;

      _patch64Success := result;
    end
  ;
//-----------------------------------------------------------------------------


initialization
    _patch64ErrorMessage := '(Not attempted)';
    _patch64Success := false;

end.
