{
  Just like 'Add prefix or suffix to Editor ID.pas' but with FULL - Name.
}
unit UserScript;

var
  DoPrepend: boolean;
  s: string;

function Initialize: integer;
var
  i: integer;
begin
  Result := 0;
  // ask for prefix or suffix mode
  i := MessageDlg('Prepend [YES] or append [NO] to Editor ID?', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
  if i = mrYes then DoPrepend := true else
    if i = mrNo then DoPrepend := false else begin
      Result := 1;
      Exit;
    end;
  // ask for string
  if not InputQuery('Enter', 'Prefix/suffix', s) then begin
    Result := 2;
    Exit;
  end;
  // empty string - do nothing
  if s = '' then
    Result := 3;
end;

function Process(e: IInterface): integer;
var
  elEditorID: IInterface;
begin
  Result := 0;
  AddMessage('Processing: ' + Name(e));
  elEditorID := ElementByName(e, 'FULL - Name');
  if Assigned(elEditorID) then begin
    if DoPrepend then
      SetEditValue(elEditorID, s + GetEditValue(elEditorID))
    else
      SetEditValue(elEditorID, GetEditValue(elEditorID) + s);
  end;
end;

end.
