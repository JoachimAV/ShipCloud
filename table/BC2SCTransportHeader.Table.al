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
            Caption = 'Name';
        }
        field(3; "Ship-to Name 2"; Text[50])
        {
            Caption = 'Name 2';
        }
        field(4; "Ship-to Address"; Text[100])
        {
            Caption = 'Address';
        }
        field(5; "Ship-to Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(6; "Ship-to Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
        }
        field(16; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = "Post Code" where("Country/Region Code" = Field("Ship-to Country/Region Code"));
            TestTableRelation = False;
            ValidateTableRelation = False;
            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                if Postcode.get(Rec."Ship-to Country/Region Code", Rec."Ship-to Post Code") then
                    "Ship-to City" := PostCode.City;
            end;
        }
        field(17; "Ship-to City"; Text[30])
        {
            Caption = 'City';
        }
        field(18; "Ship-to County"; Text[30])
        {
            Caption = 'County';
        }
        field(19; "Ship-to Contact"; Text[50])
        {
            Caption = 'Contact';
        }
        field(20; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                Customer.get("Customer No.");
                Rec."Source Document Type" := Rec."Source Document Type"::Manual;
                Rec."Ship-to Name" := Customer.Name;
                Rec."Ship-to Name 2" := Customer."Name 2";
                if (Customer.Address = '') and (Customer."Address 2" <> '') then begin
                    Rec."Ship-to Address" := Customer."Address 2";
                end else begin
                    Rec."Ship-to Address" := Customer.Address;
                    Rec."Ship-to Address 2" := Customer."Address 2";
                end;
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

        field(40; "Shipment Value (LCY) (insur.)"; Decimal)
        {
            Caption = 'Shipment Value (LCY) (insur.)';
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
            trigger OnValidate()
            begin
                if status = status::Sended then begin
                    "Transport sendet at" := CurrentDateTime;
                    "Transport sendet from" := UserId;
                end;
            end;
        }
        field(121; "Transport Document Type"; enum BC2SC_Direction)
        {
            Caption = 'Transport Document Type';
            trigger OnValidate()
            begin
                Rec.TestField("Source Document Type", Rec."Source Document Type"::Manual);

            end;
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
        field(250; "Created at"; DateTime)
        {
            Caption = 'Created at';
            Editable = false;
        }
        field(251; "Created from"; Text[50])
        {
            Caption = 'Created from';
            Editable = false;
        }
        field(252; "Transport sendet at"; DateTime)
        {
            Caption = 'Transport sendet at';
            Editable = false;
        }
        field(253; "Transport sendet from"; text[50])
        {
            Caption = 'Transport sendet from';
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
        "Created at" := CurrentDateTime;
        "Created from" := UserId;
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
