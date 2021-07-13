unit FrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvToolEdit, Vcl.StdCtrls, Vcl.Mask,
  JvExMask, Vcl.ComCtrls, Xml.xmldom, Xml.XMLIntf, Data.DB, Datasnap.DBClient,
  Xml.XMLDoc, Vcl.Grids, Vcl.DBGrids, JvComponentBase, JvDBGridExport, System.Zip,
  Vcl.Buttons;

type
  TFrmPrincipale = class(TForm)
    LblOutputFolder: TJvDirectoryEdit;
    BtnElaborate: TButton;
    BtnClose: TButton;
    EdtSelectedOILFile: TJvFilenameEdit;
    XMLSource: TXMLDocument;
    CdsTemp: TClientDataSet;
    Memo1: TMemo;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    JvDBGridCSVExport: TJvDBGridCSVExport;
    LbxFiles: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SpeedButton1: TSpeedButton;
    OpenDialog: TOpenDialog;
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnElaborateClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    procedure ElaboraFile(sFileName: String);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipale: TFrmPrincipale;

implementation

{$R *.dfm}

procedure TFrmPrincipale.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPrincipale.BtnElaborateClick(Sender: TObject);
var
  sFileDaElaborare, sTmpFileCsvName: String;
  TmpZip: TZipFile;
  bElaborazioneMultipla: boolean;
  i: Integer;
begin
  try
    Screen.Cursor := crHourGlass;

    if EdtSelectedOILFile.Text = '' then
    begin
      if LbxFiles.Items.Count = 0 then
      begin
        ShowMessage('Per procedere è necessario selezionare un file sorgente');
        Exit;
      end;
    end;

    // creo il dataset temporaneo
    CdsTemp.CreateDataSet;

    if EdtSelectedOILFile.Text <> ''  then
    begin
      // si elabora un singolo file
      bElaborazioneMultipla := False;
      sFileDaElaborare := EdtSelectedOILFile.Text;
    end
    else
    begin
      if LbxFiles.Items.Count > 1 then
      begin
        // si elaborano più files
        bElaborazioneMultipla := True;
      end
      else
      begin
        bElaborazioneMultipla := False;
        sFileDaElaborare := LbxFiles.Items[0];
      end;
    end;

    // lancio elaborazione file
    if bElaborazioneMultipla then
    begin
      for i := 0 to LbxFiles.Items.Count - 1 do
      begin
        ElaboraFile(LbxFiles.Items[i]);
      end; // for i := 0 to LbxFiles.Items.Count - 1 do
    end
    else
      ElaboraFile(sFileDaElaborare);

    sTmpFileCsvName := LblOutputFolder.Text + '\' + 'GdC_' + FormatDateTime('yyyy_mm_dd__hh_nn_ss', now);

    // procedo con l'esportazione del file csv
    if CdsTemp.RecordCount > 0 then
    begin
      JvDBGridCSVExport.FileName := sTmpFileCsvName + '.csv';
      JvDBGridCSVExport.ExportGrid;

      TmpZip := TZipFile.Create;
      try
        TmpZip.Open(sTmpFileCsvName + '.zip', zmWrite);
        TmpZip.Add(JvDBGridCSVExport.FileName);
      finally
        if Assigned(TmpZip) then
          FreeAndNil(TmpZip);
      end;
    end; // if CdsTemp.RecordCount > 0 then

    MessageDlg('Elaborazione completata', mtInformation, [mbOk], 0);

  finally
    Screen.Cursor := crDefault;
  end;

end;

procedure TFrmPrincipale.SpeedButton1Click(Sender: TObject);
var
  i: Integer;
begin
  if OpenDialog.Execute then
  begin
    LbxFiles.Clear;
    if OpenDialog.Files.Count > 1 then
    begin
      for i := 0 to OpenDialog.Files.Count - 1 do
      begin
        LbxFiles.Items.Add(OpenDialog.Files[i]);
      end; // for i := 0 to OpenDialog.Files.Count - 1 do
    end;
  end; // if OpenDialog.Execute then
end;

procedure TFrmPrincipale.ElaboraFile(sFileName: String);
var
  i, j, k, x: Integer;
  XmlNode, XmlMovimentoContoEvidenza,
  XmlInternoGiornaleDiCassa, XmlNodoOrdinante: IXmlNode;
  sTemp, sTempInternoGDC, sTempMovContoEvidenza, sTmpVal, sEsercizio, sTmpFileCsvName,
  sTipoMovimento, sTipoOperazione, sCliente, sCausale, sOrdinante, sImporto,
  sDatamovimento, sDataValuta, sNumeroBolletta: String;
begin
  // leggo il documento specificato
  XMLSource.LoadFromFile(sFileName);

  Memo1.Lines.Text := XMLSource.XML.Text;

  // scorro il documento alla ricerca delle info e le salvo nel dataset
  XmlNode := XMLSource.DocumentElement;

  if XmlNode.NodeName = 'flusso_giornale_di_cassa' then
  begin
    for i := 0 to XmlNode.ChildNodes.Count - 1 do
    begin
      sTemp := XmlNode.ChildNodes.Get(i).NodeName;

      if sTemp = 'esercizio' then
      begin
        sEsercizio := XmlNode.ChildNodes.Get(i).NodeValue;
      end; //if sTemp = 'esercizio' then

      if sTemp = 'informazioni_conto_evidenza' then
      begin
        XmlInternoGiornaleDiCassa := XmlNode.ChildNodes[i];

        for j := 0 to XmlInternoGiornaleDiCassa.ChildNodes.Count - 1 do
        begin
          // Scorro il contenuto del nodo "Informazioni_conto_evidenza"

          sTempInternoGDC := XmlInternoGiornaleDiCassa.ChildNodes.Get(j).NodeName;
          if sTempInternoGDC = 'movimento_conto_evidenza' then
          begin
            //------------------------------------------------------------------

            // elaboro il nodo relativo al movimento
            XmlMovimentoContoEvidenza := XmlInternoGiornaleDiCassa.ChildNodes[j];

            // scorro il contenuto del conto evidenza e inserisco i dati nel dataset
            for k := 0 to XmlMovimentoContoEvidenza.ChildNodes.Count - 1 do
            begin
              sTempMovContoEvidenza := XmlMovimentoContoEvidenza.ChildNodes.Get(k).NodeName;

              if sTempMovContoEvidenza = 'cliente' then
              begin
                XmlNodoOrdinante := XmlMovimentoContoEvidenza.ChildNodes[k];
                for x := 0 to XmlNodoOrdinante.ChildNodes.Count - 1 do
                begin
                  if XmlNodoOrdinante.ChildNodes.Get(x).NodeName = 'anagrafica_cliente' then
                    sCliente := XmlNodoOrdinante.ChildNodes.Get(x).NodeValue;
                end; // for x := 0 to XmlNodoOrdinante.ChildNodes.Count - 1 do
              end;

              if sTempMovContoEvidenza = 'tipo_operazione' then
              begin
                sTipoOperazione := XmlMovimentoContoEvidenza.ChildNodes.Get(k).NodeValue;
              end;

              if sTempMovContoEvidenza = 'tipo_movimento' then
              begin
                sTipoMovimento := XmlMovimentoContoEvidenza.ChildNodes.Get(k).NodeValue;
              end;

              if sTempMovContoEvidenza = 'numero_documento' then
              begin
                sNumeroBolletta := XmlMovimentoContoEvidenza.ChildNodes.Get(k).NodeValue;
              end;

              if sTempMovContoEvidenza = 'causale' then
              begin
                sCausale := XmlMovimentoContoEvidenza.ChildNodes.Get(k).NodeValue;
              end;

              if sTempMovContoEvidenza = 'importo' then
              begin
                sImporto := XmlMovimentoContoEvidenza.ChildNodes.Get(k).NodeValue;
              end;

              if sTempMovContoEvidenza = 'data_movimento' then
              begin
                sDatamovimento := XmlMovimentoContoEvidenza.ChildNodes.Get(k).NodeValue;
              end;

              if sTempMovContoEvidenza = 'data_valuta_ente' then
              begin
                sDataValuta := XmlMovimentoContoEvidenza.ChildNodes.Get(k).NodeValue;
              end;

            end; // for k := 0 to XmlMovimentoContoEvidenza.ChildNodes.Count - 1 do

            // se il documento è relativo ad un'entrata di pagoPA procedo con
            // l'inserimento nel cds altrimenti lo salto
            if (sTipoMovimento = 'ENTRATA') and
              (sTipoOperazione = 'ESEGUITO') and
              (Pos('LGPE-RIVERSAMENTO', sCausale) > 0) then
            begin
              CdsTemp.Insert;

              CdsTemp.FieldByName('AnnoBolletta').AsVariant := sEsercizio;
              CdsTemp.FieldByName('Causale').AsVariant := sCausale;
              CdsTemp.FieldByName('Importo').AsVariant := Copy(sImporto, 1, Length(sImporto));
              // CdsTemp.FieldByName('Importo').AsVariant := Copy(sImporto, 2, Length(sImporto) - 1);
              CdsTemp.FieldByName('DataMovimento').AsVariant := sDatamovimento;
              CdsTemp.FieldByName('DataValuta').AsVariant := sDataValuta;
              CdsTemp.FieldByName('NumeroBolletta').AsVariant := sNumeroBolletta;
              CdsTemp.FieldByName('Ordinante').AsVariant := sCliente;

              CdsTemp.Post;
            end;

            //------------------------------------------------------------------

          end; // if sTempInternoGDC = 'movimento_conto_evidenza' then
        end; // for j := 0 to XmlInternoGiornaleDiCassa.ChildNodes.Count - 1 do
      end; // if sTemp = 'informazioni_conto_evidenza' then
    end; // for i := 0 to XmlNode.ChildNodes.Count - 1 do
  end;

  XMLSource.Active := False;
end;

end.
