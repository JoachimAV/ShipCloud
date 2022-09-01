/// <summary>
/// Table "BC2SC_Parcel" (ID 61003).
/// </summary>
table 61003 BC2SC_Parcel
{
    Caption = 'BC2SC_Parcel';
    DrillDownPageId = 61006;
    LookupPageId = 61006;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            Editable = false;
        }
        field(2; "Transport No."; Code[20])
        {
            Caption = 'Transport No.';
            TableRelation = "BC2SC_Transport Header";
        }
        field(7; "Packaging Code"; Code[10])
        {
            Caption = 'Packaging Code';
            TableRelation = BC2SC_Packaging;

            trigger OnValidate()
            var
                Packaging: Record BC2SC_Packaging;
            begin
                if "Packaging Code" = '' then begin
                    Rec.Length := 0;
                    Rec.Height := 0;
                    Rec.Width := 0;
                end else begin
                    Packaging.get("Packaging Code");
                    Rec.Length := Packaging.Length;
                    Rec.Height := Packaging.Height;
                    Rec.Width := Packaging.Width;
                end;
            end;
        }
        field(8; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(9; Length; Decimal)
        {
            Caption = 'Length';
            DataClassification = ToBeClassified;
        }
        field(10; Width; Decimal)
        {
            Caption = 'Width';
            DataClassification = ToBeClassified;
        }
        field(11; Height; Decimal)
        {
            Caption = 'Height';
            DataClassification = ToBeClassified;
        }
        field(12; Weight; Decimal)
        {
            Caption = 'Weight';
            DataClassification = ToBeClassified;
        }
        field(13; "Max. Weight"; Decimal)
        {
            Caption = 'Max. Weight';
            DataClassification = ToBeClassified;
        }
        field(30; "Tracking No."; Text[50])
        {
            Caption = 'Tracking No.';
        }
        field(31; "Price"; Decimal)
        {
            Caption = 'Price';
        }
        field(35; "ID"; Text[50])
        {
            Caption = 'ID';
            editable = false;
        }
        field(50; "No. of Printed"; Integer)
        {
            Caption = 'No. of Printed';
            Editable = false;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if "No." = '' then begin
            ShipCloudSetup.get;
            ShipCloudSetup.TestField("Parcel No. Series");
            "No." := NoSeriesMgt.GetNextNo(ShipCloudSetup."Parcel No. Series", today, true);
        end;
    end;

    trigger OnDelete()
    var
        TransportHeader: Record "BC2SC_Transport Header";
        TransportLine: record "BC2SC_Transport Line";
    //ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
    begin
        Testfield("Tracking No.", '');
        TransportHeader.get("Transport No.");
        TransportHeader.TestField(Status, TransportHeader.Status::Open);
        transportline.setrange("Transport No.", Rec."Transport No.");
        TransportLine.setrange("Parcel No.", Rec."No.");
        TransportLine.ModifyAll("Parcel No.", '', false);
        //ShipCloudSetup.get;
        //if ShipCloudSetup."Def. Qty. to Pack with Qty." then

    end;
}
