{
  For weapon and object mod records.
  Replaces models with a high res if available. Either from specific first person model or _1 model.

  Author: Zebrina
}
unit userscript;

function GetResourceCount(fileName: string): Integer;
var
  slResList: TStringList;
begin
  slResList := TStringList.Create;
  ResourceCount(fileName, slResList);
  Result := slResList.Count;
  slResList.Free;
end;

function TryReplaceModel(e: IInterface): String;
var
  newFileName: String;
begin
  if not Assigned(e) then exit;

  newFileName := StringReplace(GetEditValue(e), '.nif', '_1.nif', [rfReplaceAll, rfIgnoreCase]);
  if GetResourceCount('meshes\' + newFileName) > 0 then
    SetEditValue(e, newFileName);
end;

function Process(e: IInterface): Integer;
var
  sig: String;
begin
  Result := 0;

  sig := Signature(e);
  if (sig = 'WEAP') or (sig = 'OMOD') then begin
    // Replace model with first person model if available.
    if ElementExists(e, '1st Person Model\MOD4') then
      SetElementEditValues(e, 'Model\MODL', GetElementEditValues(e, '1st Person Model\MOD4'));

    TryReplaceModel(ElementByPath(e, 'Model\MODL'));
  end;
end;

end.
