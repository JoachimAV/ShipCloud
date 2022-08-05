/// <summary>
/// Table BC2SC_ShipCloud Setup (ID 61000).
/// </summary>
table 61000 "BC2SC_ShipCloud Setup"
{
    Caption = 'BC2SC_ShipCloud Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(2; "API Key"; Text[50])
        {
            Caption = 'API Key';
            DataClassification = ToBeClassified;
        }
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(3; "API Base URL"; Text[100])
        {
            Caption = 'API Base URL';
            DataClassification = ToBeClassified;
        }
        field(4; "Transport No. Series"; Code[20])
        {
            Caption = 'Transport No. Series';
            TableRelation = "No. Series";
        }
        field(5; "Parcel No. Series"; Code[20])
        {
            Caption = 'Parcel No. Series';
            TableRelation = "No. Series";
        }
        field(500; "Debug"; Boolean)
        {
            Caption = 'Debug';
        }
        field(10; "Def. Qty. to Pack with Qty."; Boolean)
        {
            Caption = 'Def. Qty. to Pack with Qty.';
        }

        field(11; "Def. Transport Item No."; Code[20])
        {
            Caption = 'Def. Transport Item No.';
            TableRelation = Item;
        }
        field(15; "Cr. Transp. w. Reg. Whse. Pick"; Boolean)
        {
            Caption = 'Create Transp. when reg. Whse. Pick';
        }
        field(16; "Cr. Transp. w. Serv.-Post"; Boolean)
        {
            Caption = 'Create Transp. when Serv.-Post';
        }
        field(18; "Cr. Transp. w. Sales.-Post"; Boolean)
        {
            Caption = 'Create Transp. when Sales.-Post';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
