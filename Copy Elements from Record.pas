{
  Copy any record elements from another record.

  Author: Zebrina
}
unit UserScript;

var
  elementPathList: TStringList;
  sourceRecord: IInterface;

function Initialize: Integer;
var
  args1, args2: String;
  i: Integer;
  f: IwbFile;
  formId: cardinal;
begin
  Result := 0;

  if not InputQuery('Elements', 'Enter one or more element paths separated by commas:', args1) then begin
    AddMessage('Script canceled.');
    Result := 1;
    exit;
  end;

  if length(args1) = 0 then begin
    AddMessage('Atleast one element path must be entered.');
    Result := 2;
    exit;
  end;

  if not InputQuery('Record', 'Enter a load order valid form id:', args2) then begin
    AddMessage('Script canceled.');
    Result := 3;
    exit;
  end;

  sourceRecord := RecordByFormID(FileByIndex((StrToIntDef('$' + args2, 0) shr 24) + 1), StrToInt('$' + args2), True);
  if not Assigned(sourceRecord) then begin
    AddMessage('''' + args2 + ''' is not a valid form id.');
    Result := 4;
    exit;
  end;

  elementPathList := TStringList.Create;
  elementPathList.Delimiter := ',';
  elementPathList.StrictDelimiter := True;
  elementPathList.DelimitedText := args1;
end;

function Process(e: IInterface): Integer;
var
  i: Integer;
  elementPath: String;
  rec: IInterface;
  ml: TStringList;
begin
  for i := 0 to Pred(elementPathList.Count) do begin
    elementPath := elementPathList[i];
    AddMessage('Copying ''' + elementPath + ''' from record: ' + Name(sourceRecord));

    RemoveElement(e, elementPath);
    if not ElementExists(sourceRecord, elementPath) then begin
      RemoveElement(e, elementPath);
      continue;
    end;

    ml := TStringList.Create;
    rec := ElementByPath(sourceRecord, elementPath);
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
