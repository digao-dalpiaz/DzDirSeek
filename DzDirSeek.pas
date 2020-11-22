{------------------------------------------------------------------------------
TDzDirSeek component
Developed by Rodrigo Depine Dalpiaz (digao dalpiaz)
Non visual component to search files in directories

https://github.com/digao-dalpiaz/DzDirSeek

Please, read the documentation at GitHub link.
------------------------------------------------------------------------------}

unit DzDirSeek;

interface

uses System.Classes;

type
  TDSResultKind = (rkComplete, rkRelative, rkOnlyName);

  TDzDirSeek = class(TComponent)
  private
    FAbout: string;

    FDir: string;
    FSubDir: Boolean;
    FSorted: Boolean;
    FResultKind: TDSResultKind;
    FUseMask: Boolean;
    FInclusions, FExclusions: TStrings;

    FList: TStringList;

    BaseDir: string;
    procedure IntSeek(const RelativeDir: string);
    function CheckMask(const aFile: string; IsDir: Boolean): Boolean;
    function CheckMask_List(const aFile: string; IsDir: Boolean; MaskList: TStrings): Boolean;
    function GetName(const RelativeDir, Nome: string): string;
    procedure DoSort;

    procedure SetInclusions(const Value: TStrings);
    procedure SetExclusions(const Value: TStrings);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Seek;

    property List: TStringList read FList;
  published
    property About: string read FAbout;

    property Dir: string read FDir write FDir;
    property SubDir: Boolean read FSubDir write FSubDir default True;
    property Sorted: Boolean read FSorted write FSorted default False;
    property ResultKind: TDSResultKind read FResultKind write FResultKind default rkComplete;
    property UseMask: Boolean read FUseMask write FUseMask default True;
    property Inclusions: TStrings read FInclusions write SetInclusions;
    property Exclusions: TStrings read FExclusions write SetExclusions;
  end;

function BytesToMB(X: Int64): string;
function GetFileSize(const aFileName: string): Int64;

procedure Register;

implementation

uses System.SysUtils, System.Masks, System.StrUtils;

const STR_VERSION = '1.3';

procedure Register;
begin
  RegisterComponents('Digao', [TDzDirSeek]);
end;

//

constructor TDzDirSeek.Create(AOwner: TComponent);
begin
  inherited;

  FAbout := 'Digao Dalpiaz / Version '+STR_VERSION;

  FSubDir := True;
  FResultKind := rkComplete;
  FUseMask := True;
  FInclusions := TStringList.Create;
  FExclusions := TStringList.Create;
  FList := TStringList.Create;
end;

destructor TDzDirSeek.Destroy;
begin
  FInclusions.Free;
  FExclusions.Free;
  FList.Free;

  inherited;
end;

procedure TDzDirSeek.SetInclusions(const Value: TStrings);
begin
  FInclusions.Assign(Value);
end;

procedure TDzDirSeek.SetExclusions(const Value: TStrings);
begin
  FExclusions.Assign(Value);
end;

procedure TDzDirSeek.Seek;
begin
  if not DirectoryExists(FDir) then
    raise Exception.CreateFmt('Path "%s" not found', [FDir]);

  BaseDir := IncludeTrailingPathDelimiter(FDir);

  FList.Clear;
  IntSeek(string.Empty);

  if FSorted then DoSort;
end;

procedure TDzDirSeek.IntSeek(const RelativeDir: string);
var Sr: TSearchRec;

  function IntCheckMask(IsDir: Boolean): Boolean;
  begin
    Result := CheckMask(RelativeDir + Sr.Name, IsDir);
  end;

begin
  if FindFirst(BaseDir + RelativeDir + '*', faAnyFile, Sr) = 0 then
  begin
    repeat
      if (Sr.Name = '.') or (Sr.Name = '..') then Continue;

      if (Sr.Attr and faDirectory) <> 0 then
      begin //directory
        if FSubDir then //include sub-directories
        begin
          if IntCheckMask(True{Dir}) then
            IntSeek(RelativeDir + Sr.Name + '\');
        end;
      end else
      begin //file
        if IntCheckMask(False) then
          FList.Add(GetName(RelativeDir, Sr.Name));
      end;

    until FindNext(Sr) <> 0;
    FindClose(Sr);
  end;
end;

function TDzDirSeek.CheckMask(const aFile: string; IsDir: Boolean): Boolean;
begin
  Result :=
    FUseMask
    and
    ( //Inclusions
      IsDir
      or (FInclusions.Count=0)
      or CheckMask_List(aFile, IsDir{always false here}, FInclusions)
    )
    and
    ( //Exclusions
      not CheckMask_List(aFile, IsDir, FExclusions)
    );
end;

function TDzDirSeek.CheckMask_List(const aFile: string; IsDir: Boolean; MaskList: TStrings): Boolean;

type
  TProps = (pOnlyFile);
  TPropsSet = set of TProps;

  function GetProps(var Mask: string): TPropsSet;
  var Props: TPropsSet;

    procedure CheckProp(const aProp: string; pProp: TProps);
    var aIntProp: string;
    begin
      aIntProp := '<'+aProp+'>';
    
      if Mask.Contains(aIntProp) then
      begin
        Include(Props, pProp);
        Mask := StringReplace(Mask, aIntProp, '', []); //you should type parameter just once!
      end;
    end;

  begin
    Props := [];

    CheckProp('F', pOnlyFile); //only file parameter
      
    Result := Props;
  end;

var
  aPreMask, aMask: string;
  P: TPropsSet;
  Normal: Boolean; //not OnlyFile
begin
  Result := False;

  for aPreMask in MaskList do
  begin
    aMask := aPreMask;
    P := GetProps(aMask);

    Normal := not (pOnlyFile in P); //not OnlyFile

    if ( Normal and MatchesMask(aFile, aMask) )
    or ( (Normal or not IsDir) and MatchesMask(ExtractFileName(aFile), aMask) ) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TDzDirSeek.GetName(const RelativeDir, Nome: string): string;
begin
  case FResultKind of
    rkComplete: Result := BaseDir + RelativeDir + Nome;
    rkRelative: Result := RelativeDir + Nome;
    rkOnlyName: Result := Nome;
  end;
end;

// ============================================================================

function SortItem(List: TStringList; Index1, Index2: Integer): Integer;
var A1, A2: string;
    Dir1, Dir2: string;
    Name1, Name2: string;
begin
  A1 := List[Index1];
  A2 := List[Index2];

  Dir1 := ExtractFilePath(A1);
  Dir2 := ExtractFilePath(A2);

  Name1 := ExtractFileName(A1);
  Name2 := ExtractFileName(A2);

  if Dir1 = Dir2 then
    Result := AnsiCompareText(Name1, Name2)
  else
    Result := AnsiCompareText(Dir1, Dir2);
end;

procedure TDzDirSeek.DoSort;
begin
  FList.CustomSort(SortItem);
end;

// ============================================================================

function BytesToMB(X: Int64): string;
begin
  Result := FormatFloat('0.00 MB', X / 1024 / 1024);
end;

function GetFileSize(const aFileName: string): Int64;
var
  Stm: TFileStream;
begin
  Stm := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyNone);
  try
    Result := Stm.Size;
  finally
    Stm.Free;
  end;
end;

end.
