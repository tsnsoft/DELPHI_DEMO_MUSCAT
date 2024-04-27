unit Unit1;

interface

uses
  Windows, Dialogs, StdCtrls, Buttons, ComCtrls, Controls, ExtCtrls,
  Classes, Forms,ShellAPI, SysUtils, Graphics;

type
  TForm1 = class(TForm)
    SpeedButton1: TSpeedButton;
    Label1: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    SpeedButton2: TSpeedButton;
    Label2: TLabel;
    Edit_FL_Name: TEdit;
    Edit_NF_Folder: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Shape3: TShape;
    SpeedButton3: TSpeedButton;
    Panel1: TPanel;
    ProgressBar1: TProgressBar;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label5: TLabel;
    SpeedButton4: TSpeedButton;
    Shape4: TShape;
    Shape5: TShape;
    OpenDialog1: TOpenDialog;
    Bevel3: TBevel;
    Label6: TLabel;
    Panel_FCopy: TPanel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    CheckBox_PF: TCheckBox;
    Label10: TLabel;
    Timer1: TTimer;
    Timer2: TTimer;
    Label11: TLabel;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  flag_stop_proc: boolean;
  Spisok: TStrings;

implementation

uses Unit2, unit3;

{$R *.dfm}

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    Edit_FL_Name.Text:=Opendialog1.FileName;
    Edit_FL_Name.SelStart:=length(Edit_FL_Name.Text);
  end else Edit_FL_Name.Text:='';
  ProgressBar1.Min:=1; ProgressBar1.Max:=1;
  ProgressBar1.Position:=1;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  form2.ShowModal;
  Edit_NF_Folder.SetFocus;
  if form2.StaticText1.Caption='' then Edit_NF_Folder.Text:='';
  ProgressBar1.Min:=1; ProgressBar1.Max:=1;
  ProgressBar1.Position:=1;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
label 1,2;
var numb_generator, kol_udach_fail, kol_neudach_fail: integer;
    i,k: integer; fc, fe, fuf: boolean;
    s, st: string; f: textFile;
begin
  if Edit_FL_Name.Text='' then begin
     showmessage('�������� ���� �� ������� !'); exit;
  end;
  if Edit_NF_Folder.Text='' then begin
     showmessage('�������� ����� ��� ����������� !'); exit;
  end;
  if MessageDlg('�� ��������� ������� �������-���� ?',
       mtConfirmation, [mbNo, mbYes],0) <> mrYes then exit;

    if not DirectoryExists(Edit_NF_Folder.Text) then
    if not CreateDir(Edit_NF_Folder.Text) then begin
       MessageDlg('�������� � ��������� ����������',
       mtError, [mbOk],0); Edit_NF_Folder.Text:=''; beep;
       exit;
    end;


  ProgressBar1.Min:=1; ProgressBar1.Max:=1; ProgressBar1.Position:=1;
  Spisok.Clear; Panel_FCopy.Visible:=true; application.ProcessMessages;

   try
    AssignFile(F, Edit_FL_Name.Text); Reset(F);
    st:=ExtractFilePath(Edit_FL_Name.Text);
    while not eof(f) do begin Readln(f, s);

      { ������ -ASX- }
      if OpenDialog1.FilterIndex=1 then begin
      k:=pos('<Ref href',s);
      if k>0 then begin
         delete(s,1,13); delete(s,length(s)-2,4);
         Spisok.add(s);
      end; end;

      { ������ -M3U- }
      if OpenDialog1.FilterIndex=2 then begin
      if s[1]<>'#' then begin
          { ������ ��� ������ � ������� ����� }
         if ExtractFileDrive(s)='' then s:=st+s;
         Spisok.add(s);
      end; end;

    application.ProcessMessages;

    end;
    CloseFile(F);

    except
       showmessage('�������� � ������. ����� !');
       Panel_FCopy.Visible:=false; application.ProcessMessages; exit;
    end;

  flag_stop_proc:=false; if Spisok.Text='' then exit;
  label8.Caption:='���������� ����������� '+inttostr(Spisok.count)+
      ' �����(-�)';

    application.ProcessMessages;

   ProgressBar1.Max:=Spisok.count; numb_generator:=1;
   kol_udach_fail:=0; kol_neudach_fail:=0; form3.memo1.Clear;
   form3.Memo1.Lines.Add('�������� �������������/��������� �����:');
   form3.Memo1.Lines.Add(''); fe:=false;

  { MUSCAT - Processor }
  for i:=1 to Spisok.count do begin
     if not FileExists(pwidechar(Spisok[i-1])) then begin
       inc(kol_neudach_fail);
       form3.Memo1.Lines.add(inttostr(kol_neudach_fail)+') '+Spisok[i-1]);
       ProgressBar1.Position:=i; application.ProcessMessages; continue;
     end;


     try SetFileAttributes(pwidechar('\\?\'+Spisok[i-1]),FILE_ATTRIBUTE_NORMAL); except end;

     if CheckBox_PF.Checked then begin
       fuf:=movefile(pwidechar(Spisok[i-1]),
          pwidechar(Edit_NF_Folder.Text+ExtractFileName(Spisok[i-1])))
       end else begin
       fuf:=copyfile(pwidechar(Spisok[i-1]),
          pwidechar(Edit_NF_Folder.Text+ExtractFileName(Spisok[i-1])), true)
       end;


       if not fuf then begin
         1: if flag_stop_proc then break;
         fc:=copyfile(pwidechar(Spisok[i-1]),
             pwidechar(Edit_NF_Folder.Text+
             '('+inttostr(numb_generator)+') '+
             ExtractFileName(Spisok[i-1])), true);
             inc(numb_generator); application.ProcessMessages;
             if not fc then begin
                 if not FileExists(Edit_NF_Folder.Text+
                   ExtractFileName(Spisok[i-1])) then begin
                    inc(kol_neudach_fail);
                    form3.Memo1.Lines.add(inttostr(kol_neudach_fail)+') '+
                       Spisok[i-1]);
                    ProgressBar1.Position:=i;
                    application.ProcessMessages; continue;
                       end else goto 1;
               end else inc(kol_udach_fail);
       end else inc(kol_udach_fail);
     ProgressBar1.Position:=i; application.ProcessMessages;

     if CheckBox_PF.Checked  and fc then begin
        try
        try SetFileAttributes(pwidechar('\\?\'+Spisok[i-1]),FILE_ATTRIBUTE_NORMAL); except end;
        if not DeleteFile(pwidechar(Spisok[i-1])) then begin
          fe:=true; form3.Memo1.Lines.add('[�� ������->] '+Spisok[i-1]);
        end;
        except
          fe:=true; form3.Memo1.Lines.add('[�� ������->] '+Spisok[i-1]);
        end;
     end;

     if flag_stop_proc then break;
  end;

  Panel_FCopy.Visible:=false; application.ProcessMessages;

  { MUSCAT - Informer }
   if (Spisok.count=kol_udach_fail) and (not fe) then
      showmessage('Ok. ��� ������!');
   if (Spisok.count=kol_udach_fail) and (fe) then begin
      showmessage('��� ����� �����������. � ������� �� ��� ...');
      ProgressBar1.Min:=1; ProgressBar1.Max:=1; ProgressBar1.Position:=1;
      goto 2;
   end;
   if (Spisok.count<>kol_udach_fail) then begin
        showmessage('� ���������, '+inttostr(Spisok.count-kol_udach_fail)+
           ' ����(-��) �� �����������!');
      ProgressBar1.Min:=1; ProgressBar1.Max:=1; ProgressBar1.Position:=1;
      if (kol_neudach_fail>0) or (fe) then begin
2:          form3.Memo1.Lines.Add('');
            form3.Memo1.Lines.Add('��� ������, �� ��������������� !');
            form3.showmodal;
         end;
    end;

end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  flag_stop_proc:=true;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 Spisok := TStringList.Create; 
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Spisok.Free;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if label10.font.Color=clMaroon then label10.font.Color:=clNavy
     else label10.font.Color:=clMaroon;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  if fsUnderline in label11.font.Style then label11.font.Style:=
  label11.font.Style-[fsunderline] else
  label11.font.Style:=
  label11.font.Style+[fsunderline];
end;

end.
