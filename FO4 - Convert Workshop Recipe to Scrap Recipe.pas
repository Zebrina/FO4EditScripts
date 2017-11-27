{
  Converts Fallout 4 workshop recipes to scrap recipes.
}
unit UserScript;

function FormValueSignature(val: string): string;
begin
  Result := Copy(val, Pos('[', val) + 1, 4);
end;

function GetComponentScrapItem(c: IInterface): IInterface;
var
  val, form: string;
  rec: IInterface;
begin
  val := GetEditValue(c);
  form := Copy(val, Pos(':', val) + 1, 8);
  rec := RecordByFormID(FileByIndex(0), StrToInt('$' + form), True);
  Result := GetElementEditValues(rec, 'MNAM');
end;

function Process(e: IInterface): integer;
var
  kwda, k, fvpa, c: IInterface;
  i, n: integer;
begin
  Result := 0;

  // Remove unnecessary stuff.

  // Remove description.
  if ElementExists(e, 'DESC') then
    SetElementEditValues(e, 'DESC', '');

  // Remove conditions.
  RemoveElement(e, 'Conditions');
  // Remove Workbench Keyword.
  RemoveElement(e, 'BNAM');
  // Remove Menu Art Object.
  RemoveElement(e, 'ANAM');

  // Remove existing filter keywords and add WorkshopRecipeFilterScrap keyword.
  RemoveElement(e, 'FNAM');
  kwda := Add(e, 'FNAM', True);
  k := ElementAssign(kwda, HighInteger, nil, False);
  SetEditValue(k, '00106D8F');

  fvpa := ElementBySignature(e, 'FVPA');
  i := 0;
  n := ElementCount(fvpa);
  while i < n do begin
    c := ElementByPath(ElementByIndex(fvpa, i), 'Component');
    if FormValueSignature(GetEditValue(C)) <> 'CMPO' then
      i := i + 1
    else begin
      SetEditValue(c, GetComponentScrapItem(C));
      // Start over!
      i := 0;
    end;
  end;

  // Set priority to 0. Not sure if it matters, but w/e.
  SetElementNativeValues(e, 'INTV\Priority', 0);
end;

end.
