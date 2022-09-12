/// <summary>
/// Unknown "BC2SC_ShipCloudAdmin" (ID 61000).
/// </summary>
permissionset 61000 BC2SC_ShipCloudAdmin
{
    Assignable = true;
    Caption = 'ShipCloud Admin', MaxLength = 30;
    Permissions =
        table BC2SC_Parcel = X,
        tabledata BC2SC_Parcel = RMID,
        table BC2SC_Packaging = X,
        tabledata BC2SC_Packaging = RMID,
        table "BC2SC_Transport Line" = X,
        tabledata "BC2SC_Transport Line" = RMID,
        table "BC2SC_ShipCloud Setup" = X,
        tabledata "BC2SC_ShipCloud Setup" = RMID,
        table "BC2SC_Transport Header" = X,
        tabledata "BC2SC_Transport Header" = RMID,
        table "BC2SC_PrintNode Label Printer" = X,
        tabledata "BC2SC_PrintNode Label Printer" = RMID,
        table "BC2SC_PrintNode User Setup" = X,
        tabledata "BC2SC_PrintNode User Setup" = RMID,
        codeunit "BC2SC_ShipCloud Management" = X,
        page "BC2SC_JsonBuffer Result" = X,
        page "BC2SC_Transport Lines" = X,
        page "BC2SC_Parcel List" = X,
        page "BC2SC_ShipCloud Setup" = X,
        page BC2SC_Packagings = X,
        page "BC2SC_Transport List" = X,
        page "BC2SC_Transport Card" = X,
        page "BC2SC_PrintNode Label Printer" = X,
        page "BC2SC_PrintNode User Setup" = X,
        page "BC2SC_Parcel Card" = X;
}
