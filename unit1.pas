unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, sqlite3conn, IBConnection, FileUtil, Forms,
  Controls, Graphics, Dialogs, StdCtrls, Grids, ExtCtrls, Clipbrd, LCLType;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    ListBox1: TListBox;
    RadioGroup1: TRadioGroup;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure search();
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure StringGrid1Resize(Sender: TObject);
    procedure convertdb();
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  if not FileExists('dict.db') then
  begin
    ShowMessage('dict.db not found');
    Application.Terminate;
  end;
  SQLite3Connection1.Open;
  if not SQLite3Connection1.Connected then
  begin
    ShowMessage('cannot connect to db');
    application.terminate;
  end;
  SQLQuery1.Close;
  SQLQuery1.SQL.Text :=
    'SELECT name FROM sqlite_master WHERE type="table" AND name="singlewords1";';
  SQLQuery1.Open;


  if SQLQuery1.EOF then
  begin
    ShowMessage('You must convert the db befor usage');

    convertdb();
    application.terminate;
  end;
end;

procedure TForm1.StringGrid1DblClick(Sender: TObject);
begin
  //StringGrid1.SelectedColumn.;
  Clipboard.AsText := StringGrid1.Cells[StringGrid1.SelectedColumn.Index, StringGrid1.Row];
end;

procedure TForm1.StringGrid1Resize(Sender: TObject);
begin
  StringGrid1.ColWidths[0] := trunc(StringGrid1.Width / 2) - 10;
  StringGrid1.ColWidths[1] := trunc(StringGrid1.Width / 2) - 10;
end;


procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked then
  begin

    with SQLQuery1 do
    begin
      Close;
      //SQL.Text := 'SELECT term4search FROM singlewords' + IntToStr(RadioGroup1.ItemIndex + 1) + ' WHERE term4search LIKE "' + ComboBox1.Text + '%" LIMIT 10;';
      SQL.Text := 'SELECT term4search FROM singlewords' +
        IntToStr(RadioGroup1.ItemIndex + 1) + ' WHERE term4search LIKE :Searchterm LIMIT 20;';
      //ParamByName('tables').AsString := 'singlewords' + IntToStr(RadioGroup1.ItemIndex + 1);
      ParamByName('Searchterm').AsString := ComboBox1.Text + '%';
      //ShowMessage(SQL.Text);
      //ExecSQL;
      //ShowMessage(IntToStr(FieldCount));
      Open;
      ComboBox1.Items.Clear;
      ComboBox1.Items.Add(Fields[0].AsString);
      ListBox1.Items.Clear;
      while not EOF do
      begin
        ListBox1.Items.Add(Fields[0].AsString);
        Next;
      end;

    end;
  end;
end;



procedure TForm1.ComboBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if key = 13 then search();
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (key = 69) then
    RadioGroup1.ItemIndex := 1;//set lang to english
  if (ssCtrl in Shift) and (key = 68) then
    RadioGroup1.ItemIndex := 0;//set lang to deutsch

end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Ord(key) = 27 then
    Application.Minimize;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ComboBox1.SetFocus;
  ComboBox1.SelectAll;
end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
begin
  ComboBox1.Text := ListBox1.Items[ListBox1.ItemIndex];
  search();
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  search();
end;

procedure TForm1.search();
var
  i: integer;
begin

  with SQLQuery1 do
  begin
    Close;
    sql.Text := 'SELECT * FROM main_ft WHERE term' +
      IntToStr(RadioGroup1.ItemIndex + 1) +
      ' like :Searchterm order by vt_usage DESC , sort2 , sort1 limit 60 ';
    ParamByName('Searchterm').AsString := ComboBox1.Text + '%';
    Open;
    //StringGrid1.RowCount := FieldCount;
    StringGrid1.Clean;
    StringGrid1.Update;
    i := 0;
    while not EOF do
    begin
      //StringGrid1.Rows[i].Add(Fields[1].AsString);
      //StringGrid1.Rows[i].Add(Fields[2].AsString);
      StringGrid1.Cells[0, i] := Fields[1].AsString;
      StringGrid1.Cells[1, i] := Fields[2].AsString;
      Inc(i);
      Next;
    end;
  end;
end;

procedure TForm1.convertdb();
var
  Reply, BoxStyle: integer;
begin
  SQLQuery1.Close;
  SQLQuery1.SQL.Text :=
    'SELECT name FROM sqlite_master WHERE type="table" AND name="singlewords";';
  SQLQuery1.Open;
  if not SQLQuery1.EOF then
  begin
    BoxStyle := MB_ICONQUESTION + MB_YESNO;
    Reply := Application.MessageBox('Convert db now?', 'Convert', BoxStyle);
    if Reply = idYes then
    begin
      Reply := Application.MessageBox(
        'dict.db will be changed. Backup DB to dict_backup.db?', 'Backup', BoxStyle);
      if Reply = idYes then
      begin
        Copyfile('dict.db', 'dict_backup.db');
        ShowMessage('backup completed');
      end;
        {SQLQuery1.Close;
        SQLQuery1.SQL.Text :=   'CREATE TABLE singlewords1(term4search VARCHAR);';
        SQLQuery1.ExecSQL;
        SQLTransaction1.Commit;
        SQLQuery1.Close;
        SQLQuery1.SQL.Text :=   'CREATE TABLE singlewords2(term4search VARCHAR);';
        SQLQuery1.ExecSQL;
        SQLTransaction1.Commit;
        ShowMessage('tabels created, copy data now');
        SQLQuery1.Close;
        SQLQuery1.SQL.Text := 'INSERT INTO singlewords1 SELECT term4search FROM singlewords WHERE colnum = 1';
        SQLQuery1.ExecSQL;
        SQLTransaction1.Commit;
        SQLQuery1.Close;
        SQLQuery1.SQL.Text := 'INSERT INTO singlewords2 SELECT term4search FROM singlewords WHERE colnum = 2' ;
        SQLQuery1.ExecSQL;
        SQLTransaction1.Commit;
        SQLQuery1.Close;
        SQLQuery1.SQL.Text := 'CREATE INDEX "singlewords1_index" ON "singlewords1" ("term4search" ASC)';
        SQLQuery1.ExecSQL;
        SQLTransaction1.Commit;
        SQLQuery1.Close;
        SQLQuery1.SQL.Text := 'CREATE INDEX "singlewords2_index" ON "singlewords2" ("term4search" ASC)';
        SQLQuery1.ExecSQL;
        SQLTransaction1.Commit;
        ShowMessage('drop old table and cleanup');
        SQLQuery1.Close;
        SQLQuery1.SQL.Text := 'DROP TABLE singlewords';
        SQLQuery1.ExecSQL;
        SQLTransaction1.Commit;
        SQLQuery1.Close;
        SQLQuery1.SQL.Text := 'VACUUM;';
        SQLQuery1.ExecSQL;
        SQLTransaction1.Commit;  }

        SQLite3Connection1.ExecuteDirect('CREATE TABLE singlewords1(term4search VARCHAR);');
        SQLite3Connection1.ExecuteDirect('CREATE TABLE singlewords2(term4search VARCHAR);');
        ShowMessage('tabels created, copy data now');
        SQLite3Connection1.ExecuteDirect('INSERT INTO singlewords1 SELECT term4search FROM singlewords WHERE colnum = 1');
        SQLite3Connection1.ExecuteDirect('INSERT INTO singlewords2 SELECT term4search FROM singlewords WHERE colnum = 2');
        SQLite3Connection1.ExecuteDirect('CREATE INDEX "singlewords1_index" ON "singlewords1" ("term4search" ASC)');
        SQLite3Connection1.ExecuteDirect('CREATE INDEX "singlewords2_index" ON "singlewords2" ("term4search" ASC)');
        ShowMessage('drop old table and cleanup');
        SQLite3Connection1.ExecuteDirect('DROP TABLE singlewords');
        SQLite3Connection1.ExecuteDirect('End Transaction');
        SQLite3Connection1.ExecuteDirect('VACUUM;');

        ShowMessage('finished, now restart the programm and enjoy ;)');
    end;
  end;
end;

end.
