unit UFrmMain;

interface

uses Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Controls, System.Classes,
  DzDirSeek;

type
  TFrmMain = class(TForm)
    DS: TDzDirSeek;
    Label1: TLabel;
    EdDir: TEdit;
    BtnPath: TButton;
    CkSorted: TCheckBox;
    CkSubDir: TCheckBox;
    GroupBox1: TGroupBox;
    EdInc: TMemo;
    EdExc: TMemo;
    Label2: TLabel;
    Label3: TLabel;
    CkUseMasks: TCheckBox;
    RgResultKind: TRadioGroup;
    EdResult: TMemo;
    BtnSeek: TButton;
    Label4: TLabel;
    LbCount: TLabel;
    CkHiddenFiles: TCheckBox;
    CkSystemFiles: TCheckBox;
    CkDirItem: TCheckBox;
    procedure BtnPathClick(Sender: TObject);
    procedure BtnSeekClick(Sender: TObject);
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses Vcl.FileCtrl, System.SysUtils;

procedure TFrmMain.BtnPathClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := EdDir.Text;
  if SelectDirectory('Please, specify directory:', '', Dir) then
    EdDir.Text := Dir;
end;

procedure TFrmMain.BtnSeekClick(Sender: TObject);
var
  S: TStringList;
begin
  DS.Dir := EdDir.Text;
  DS.SubDir := CkSubDir.Checked;
  DS.UseMask := CkUseMasks.Checked;
  DS.Inclusions.Assign(EdInc.Lines);
  DS.Exclusions.Assign(EdExc.Lines);
  DS.SearchHiddenFiles := CkHiddenFiles.Checked;
  DS.SearchSystemFiles := CkSystemFiles.Checked;
  DS.Sorted := CkSorted.Checked;
  DS.IncludeDirItem := CkDirItem.Checked;

  EdResult.Text := 'Searching...';
  Refresh;

  DS.Seek;

  S := TStringList.Create;
  try
    DS.GetResultStrings(S, TDSResultKind(RgResultKind.ItemIndex));

    LbCount.Caption := IntToStr(S.Count);
    EdResult.Lines.Assign(S);
  finally
    S.Free;
  end;
end;

end.
