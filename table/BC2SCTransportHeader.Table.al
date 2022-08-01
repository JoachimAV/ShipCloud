/// <summary>
/// Table BC2SC_Transport Header (ID 61001).
/// </summary>
table 61001 "BC2SC_Transport Header"
{
    Caption = 'BC2SC_Transport Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Ship-to Name"; Text[100])
        {
            Caption = 'Ship-to Name';
        }
        field(3; "Ship-to Name 2"; Text[50])
        {
            Caption = 'Ship-to Name 2';
        }
        field(4; "Ship-to Address"; Text[100])
        {
            Caption = 'Ship-to Address';
        }
        field(5; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Ship-to Address 2';
        }
        field(6; "Ship-to Country/Region Code"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
        }
        field(16; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Ship-to Post Code';
        }
        field(17; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
        }
        field(18; "Ship-to County"; Text[30])
        {
            Caption = 'Ship-to County';
        }
        field(19; "Ship-to Contact"; Text[50])
        {
            Caption = 'Ship-to Contact';
        }
        field(20; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                Rec.TestField("Source Document Type", Rec."Source Document Type"::Manual);

                Customer.get("Customer No.");
                Rec."Source Document Type" := Rec."Source Document Type"::Manual;
                Rec."Ship-to Name" := Customer.Name;
                Rec."Ship-to Name 2" := Customer."Name 2";
                Rec."Ship-to Address" := Customer.Address;
                Rec."Ship-from Address 2" := Customer."Address 2";
                Rec."Ship-to Country/Region Code" := Customer."Country/Region Code";
                Rec."Ship-to Post Code" := Customer."Post Code";
                Rec."Ship-to City" := Customer.City;
                Rec."Ship-to County" := Customer.County;
                Rec."Ship-to Contact" := Customer.Contact;
                Rec."Notification E-Mail" := Customer."E-Mail";
                Rec."Shipping Agent Code" := Customer."Shipping Agent Code";
                Rec."Shipping Agent Service Code" := Customer."Shipping Agent Service Code";
                Rec."Shipment Method Code" := Customer."Shipment Method Code";
            end;
        }
        field(21; "Sell-to / Buy-from Name"; Text[50])
        {
            Caption = 'Sell-to / Buy-from Name';
        }
        field(30; "Ship-from Code"; Code[10])
        {
            Caption = 'Ship-from Code';
        }
        field(31; "Ship-from Name"; Text[100])
        {
            Caption = 'Ship-from Name';
        }
        field(32; "Ship-from Name 2"; Text[50])
        {
            Caption = 'Ship-from Name 2';
            DataClassification = ToBeClassified;
        }
        field(33; "Ship-from Address"; Text[100])
        {
            Caption = 'Ship-from Address';
            DataClassification = ToBeClassified;
        }
        field(34; "Ship-from Address 2"; Text[50])
        {
            Caption = 'Ship-from Address 2';
            DataClassification = ToBeClassified;
        }
        field(35; "Ship-from Country/Region Code"; Code[10])
        {
            Caption = 'Ship-from Country/Region Code';
            DataClassification = ToBeClassified;
        }
        field(36; "Ship-from Post Code"; Code[20])
        {
            Caption = 'Ship-from Post Code';
            DataClassification = ToBeClassified;
        }
        field(37; "Ship-from City"; Text[30])
        {
            Caption = 'Ship-from City';
            DataClassification = ToBeClassified;
        }
        field(38; "Ship-from County"; Text[30])
        {
            Caption = 'Ship-from County';
            DataClassification = ToBeClassified;
        }
        field(39; "Ship-from Contact"; Text[50])
        {
            Caption = 'Ship-from Contact';
            DataClassification = ToBeClassified;
        }
        field(40; "Shipment Value (LCY) (insur.)"; Decimal)
        {
            Caption = 'Shipment Value (LCY) (insur.)';
            DataClassification = ToBeClassified;
        }
        field(80; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(81; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
        }
        field(82; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
        }
        field(83; "Shipment Date"; Date)
        {
            Caption = 'Shipment Date';
        }
        field(100; "Your Reference"; Text[50])
        {
            Caption = 'Your Reference';
        }
        field(101; "Notification E-Mail"; Text[80])
        {
            Caption = 'Notification E-Mail';
        }
        field(120; "Status"; Enum BC2SC_TransportStatus)
        {
            Caption = 'Status';
        }
        field(200; "Source Document Type"; Enum BC2SC_TransportSourceDocType)
        {
            Caption = 'Source Document Type';
            Editable = False;
        }
        field(201; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            Editable = False;
        }
        field(210; "Created from Document Type"; Enum BC2SC_TransportCreatedDocType)
        {
            Caption = 'Created from Document Type';
            Editable = False;
        }
        field(211; "Created from Document No."; Code[20])
        {
            Caption = 'Created from Document No.';
            Editable = False;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        SetCustomerNoEditable: Boolean;

    trigger OnInsert()
    var
        ShipCloudSetup: Record "BC2SC_ShipCloud Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if "No." = '' then begin
            ShipCloudSetup.get;
            ShipCloudSetup.TestField("Transport No. Series");
            "No." := NoSeriesMgt.GetNextNo(ShipCloudSetup."Transport No. Series", today, true);
        end;
    end;

    trigger OnDelete()
    var
        Parcel: Record BC2SC_Parcel;
        TransportLine: Record "BC2SC_Transport Line";
    begin
        Rec.TestField(Status, Rec.Status::Open);
        TransportLine.setrange("Transport No.", "No.");
        TransportLine.DeleteAll(true);

        Parcel.setrange("Transport No.", "No.");
        Parcel.deleteall(true);
    end;

    trigger OnModify()
    begin
        //Rec.TestField(Status, Rec.Status::Open);
    end;
}
