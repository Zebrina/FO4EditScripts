{
  Restore any record element from it's last master.

  Author: Zebrina
}
unit UserScript;

var
  elementPathList: TStringList;

function Initialize: Integer;
var
  args: String;
  i: Integer;
begin
  Result := 0;

  if not InputQuery('Elements', 'Enter one or more element paths separated by commas:', args) then begin
    AddMessage('Script canceled.');
    Result := 1;
    exit;
  end;

  if length(args) = 0 then begin
    AddMessage('Atleast one element path must be entered.');
    Result := 2;
    exit;
  end;

  elementPathList := TStringList.Create;
  elementPathList.Delimiter := ',';
  elementPathList.StrictDelimiter := True;
  elementPathList.DelimitedText := args;
end;

function HasMasterFile(e, m: IInterface): Boolean;
var
  i: Integer;
begin
  //AddMessage('Checking if ' + GetFileName(e) + ' has master ' + GetFileName(m));
  Result := True;
  if not Equals(e, m) then
    for i := MasterCount(e) - 1 downto 0 do begin
      if Equals(MasterByIndex(e, i), m) then
        exit;
    end;
  Result := False;
end;

function Process(e: IInterface): Integer;
var
  i: Integer;
  elementPath: String;
  m, rec: IInterface;
  ml: TStringList;
begin
  m := Master(e);
  if not Assigned(m) then
    exit;

  for i := Pred(OverrideCount(m)) downto 0 do begin
    rec := OverrideByIndex(m, i);
    if HasMasterFile(GetFile(e), GetFile(rec)) then begin
      m := rec;
      break;
    end;
  end;

  for i := 0 to Pred(elementPathList.Count) do begin
    elementPath := elementPathList[i];
    AddMessage('Restoring ''' + elementPath + ''' from master: ' + GetFileName(GetFile(m)));

    if not ElementExists(m, elementPath) then begin
      RemoveElement(e, elementPath);
      continue;
    end;

    ml := TStringList.Create;
    rec := ElementByPath(m, elementPath);
    ReportRequiredMasters(rec, ml, False, True);
    for i := 0 to Pred(ml.Count) do begin
      //AddMessage('Adding master: ' + ml[i]);
      AddMasterIfMissing(GetFile(e), ml[i]);
    end;
    ml.Free;

    ElementAssign(Add(e, elementPath, True), LowInteger, rec, False);
  end;
end;

function Finalize: Integer;
begin
  Result := 0;

  elementPathList.Free;
end;

end.
