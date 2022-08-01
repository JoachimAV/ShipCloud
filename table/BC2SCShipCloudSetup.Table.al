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
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
