{------------------------------------------------------------------------------
TDzDirSeek component
Developed by Rodrigo Depine Dalpiaz (digao dalpiaz)
Non visual component to search files in directories

https://github.com/digao-dalpiaz/DzDirSeek

Please, read the documentation at GitHub link.
------------------------------------------------------------------------------}

unit DzDirSeek;

interface

uses System.Classes, System.SysUtils, System.Generics.Collections;

type
  TDSFile = class
  private
    FBaseDir: string;
    FRelativeDir: string;
    FName: string;
    FSize: Int64;
    FAttributes: Integer;
    FTimestamp: TDateTime;

    function GetAbsolutePath: string;
    function GetRelativePath: string;
  public
    property BaseDir: string read FBaseDir;
    property RelativeDir: string read FRelativeDir;
    property Name: string read FName;
    property Size: Int64 read FSize;
    property Attributes: Integer read FAttributes;
    property Timestamp: TDateTime read FTimestamp;

    /// <summary>
    ///  Returns: BaseDir + RelativeDir + Name
    /// </summary>
    property AbsolutePath: string read GetAbsolutePath;
    /// <summary>
    ///  Returns: RelativeDir + Name
    /// </summary>
    property RelativePath: string read GetRelativePath;
  end;

  TDSResultList = class(TObjectList<TDSFile>)
  public
    function IndexOfAbsolutePath(const Path: string; IgnoreCase: Boolean = False): Integer;
    function IndexOfRelativePath(const Path: string; IgnoreCase: Boolean = False): Integer;
  end;

  TDSResultKind = (rkComplete, rkRelative, rkOnlyName);

  TDzDirSeek = class(TComponent)
  private
    FAbout: string;

    FDir: string;
    FSubDir: Boolean;
    FSorted: Boolean;
    FUseMask: Boolean;
    FInclusions, FExclusions: TStrings;
    FIncludeHiddenFiles, FIncludeSystemFiles: Boolean;

    FResultList: TDSResultList;

    BaseDir: string;
    procedure IntSeek(const RelativeDir: string);
    function CheckMask(const aFile: string; IsDir: Boolean): Boolean;
    function CheckMask_List(const aFile: string; IsDir: Boolean; MaskList: TStrings): Boolean;
    procedure AddFile(const RelativeDir: string; const Sr: TSearchRec);
    procedure DoSort;

    procedure SetInclusions(const Value: TStrings);
    procedure SetExclusions(const Value: TStrings);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Seek;

    property ResultList: TDSResultList read FResultList;

    procedure GetResultStrings(S: TStrings; Kind: TDSResultKind);
  published
    property About: string read FAbout;

    property Dir: string read FDir write FDir;
    property SubDir: Boolean read FSubDir write FSubDir default True;
    property Sorted: Boolean read FSorted write FSorted default False;
    property UseMask: Boolean read FUseMask write FUseMask default True;
    property Inclusions: TStrings read FInclusions write SetInclusions;
    property Exclusions: TStrings read FExclusions write SetExclusions;

    property IncludeHiddenFiles: Boolean read FIncludeHiddenFiles write FIncludeHiddenFiles default False;
    property IncludeSystemFiles: Boolean read FIncludeSystemFiles write FIncludeSystemFiles default False;
  end;

function BytesToMB(X: Int64): string;
function GetFileSize(const aFileName: string): Int64;
function ContainsAttribute(AttributesEnum, Attribute: Integer): Boolean;

procedure Register;

implementation

uses System.Masks, System.StrUtils, System.Generics.Defaults;

const STR_VERSION = '2.0';

procedure Register;
begin
  RegisterComponents('Digao', [TDzDirSeek]);
end;

//

function TDSFile.GetAbsolutePath: string;
begin
  Result := FBaseDir + FRelativeDir + FName;
end;

function TDSFile.GetRelativePath: string;
begin
  Result := FRelativeDir + FName;
end;

//

function TDSResultList.IndexOfAbsolutePath(const Path: string; IgnoreCase: Boolean = False): Integer;
var
  I: Integer;
begin
  for I := 0 to Count-1 do
    if string.Compare(Items[I].GetAbsolutePath, Path, IgnoreCase)=0 then Exit(I);

  Exit(-1);
end;

function TDSResultList.IndexOfRelativePath(const Path: string; IgnoreCase: Boolean = False): Integer;
var
  I: Integer;
begin
  for I := 0 to Count-1 do
    if string.Compare(Items[I].GetRelativePath, Path, IgnoreCase)=0 then Exit(I);

  Exit(-1);
end;


//

constructor TDzDirSeek.Create(AOwner: TComponent);
begin
  inherited;

  FAbout := 'Digao Dalpiaz / Version '+STR_VERSION;

  FSubDir := True;
  FUseMask := True;
  FInclusions := TStringList.Create;
  FExclusions := TStringList.Create;

  FResultList := TDSResultList.Create;
end;

destructor TDzDirSeek.Destroy;
begin
  FResultList.Free;

  FInclusions.Free;
  FExclusions.Free;

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

  FResultList.Clear;
  IntSeek(string.Empty);

  if FSorted then DoSort;
end;

procedure TDzDirSeek.IntSeek(const RelativeDir: string);
var Sr: TSearchRec;

  function IntCheckMask(IsDir: Boolean): Boolean;
  begin
    Result := CheckMask(RelativeDir + Sr.Name, IsDir);
  end;

  function InAttr(Attr: Integer): Boolean;
  begin
    Result := (Sr.Attr and Attr) <> 0;
  end;

begin
  if FindFirst(BaseDir + RelativeDir + '*', faAnyFile, Sr) = 0 then
  begin
    repeat
      if (Sr.Name = '.') or (Sr.Name = '..') then Continue;

      {$IFDEF MSWINDOWS}
      {$WARN SYMBOL_PLATFORM OFF}
      if InAttr(faHidden) and not FIncludeHiddenFiles then Continue;
      if InAttr(faSysFile) and not FIncludeSystemFiles then Continue;
      {$WARN SYMBOL_PLATFORM ON}
      {$ENDIF}

      if InAttr(faDirectory) then
      begin //directory
        if FSubDir then //include sub-directories
        begin
          if IntCheckMask(True{Dir}) then
            IntSeek(RelativeDir + Sr.Name + '\');
        end;
      end else
      begin //file
        if IntCheckMask(False) then
          AddFile(RelativeDir, Sr);
      end;

    until FindNext(Sr) <> 0;
    FindClose(Sr);
  end;
end;

function TDzDirSeek.CheckMask(const aFile: string; IsDir: Boolean): Boolean;
begin
  if not FUseMask then Exit(True);

  Result :=
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

procedure TDzDirSeek.AddFile(const RelativeDir: string; const Sr: TSearchRec);
var
  F: TDSFile;
begin
  F := TDSFile.Create;
  F.FBaseDir := BaseDir;
  F.FRelativeDir := RelativeDir;
  F.FName := Sr.Name;
  F.FSize := Sr.Size;
  F.FAttributes := Sr.Attr;
  F.FTimestamp := Sr.TimeStamp;
  FResultList.Add(F);
end;

// ============================================================================

function SortItem(const Left, Right: TDSFile): Integer;
begin
  if Left.FRelativeDir = Right.FRelativeDir then
    Result := AnsiCompareText(Left.FName, Right.FName)
  else
    Result := AnsiCompareText(Left.FRelativeDir, Right.FRelativeDir);
end;

procedure TDzDirSeek.DoSort;
begin
  FResultList.Sort(TComparer<TDSFile>.Construct(SortItem));
end;

procedure TDzDirSeek.GetResultStrings(S: TStrings; Kind: TDSResultKind);
var
  F: TDSFile;
begin
  for F in FResultList do
  begin
    case Kind of
      rkComplete: S.Add(F.GetAbsolutePath);
      rkRelative: S.Add(F.GetRelativePath);
      rkOnlyName: S.Add(F.FName);

      else raise Exception.Create('Invalid kind');
    end;
  end;
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

function ContainsAttribute(AttributesEnum, Attribute: Integer): Boolean;
begin
  Result := (AttributesEnum and Attribute) <> 0;
end;

end.
