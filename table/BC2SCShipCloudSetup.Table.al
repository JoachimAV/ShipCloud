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
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
