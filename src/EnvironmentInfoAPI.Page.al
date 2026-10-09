page 90201 "Environment Inspector API"
{
    PageType = API;

    APIPublisher = 'felice2000';
    APIGroup = 'environmentInspector';
    APIVersion = 'v1.0';

    EntityName = 'environmentInfo';
    EntitySetName = 'environmentInfos';

    SourceTable = Integer;
    ODataKeyFields = Number;

    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.Number)
                {
                    Caption = 'Id';
                    Editable = false;
                }

                field(applicationVersion; ApplicationVersion)
                {
                    Caption = 'Application Version';
                }

                field(environmentName; EnvironmentName)
                {
                    Caption = 'Environment Name';
                }

                field(deploymentType; DeploymentType)
                {
                    Caption = 'Deployment Type';
                }

                field(environmentType; EnvironmentType)
                {
                    Caption = 'Environment Type';
                }

                field(applicationFamily; ApplicationFamily)
                {
                    Caption = 'Application Family';
                }

                field(company; CompanyNameValue)
                {
                    Caption = 'Company';
                }

                field(serverName; ServerName)
                {
                    Caption = 'Server Name';
                }

                field(operatingSystem; OperatingSystem)
                {
                    Caption = 'Operating System';
                }

                field(cpu; CPUName)
                {
                    Caption = 'CPU';
                }

                field(logicalProcessors; LogicalProcessors)
                {
                    Caption = 'Logical Processors';
                }

                field(totalRAM; TotalRAM)
                {
                    Caption = 'Total RAM';
                }

                field(is64BitOS; Is64BitOS)
                {
                    Caption = '64-bit OS';
                }

                field(is64BitBC; Is64BitBC)
                {
                    Caption = '64-bit BC Process';
                }

                field(sqlServer; SQLServer)
                {
                    Caption = 'SQL Server';
                }

                field(sqlInstance; SQLInstance)
                {
                    Caption = 'SQL Instance';
                }

                field(sqlVersion; SQLVersion)
                {
                    Caption = 'SQL Version';
                }

                field(sqlProductVersion; SQLProductVersion)
                {
                    Caption = 'SQL Product Version';
                }

                field(sqlEdition; SQLEdition)
                {
                    Caption = 'SQL Edition';
                }

                field(databaseName; DatabaseName)
                {
                    Caption = 'Database';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Integer è una tabella virtuale.
        // Vogliamo restituire una sola entità JSON.
        Rec.SetRange(Number, 1);
    end;

    trigger OnAfterGetRecord()
    begin
        LoadEnvironmentInformation();
    end;

    var
        ApplicationVersion: Text;
        EnvironmentName: Text;
        DeploymentType: Text;
        EnvironmentType: Text;
        ApplicationFamily: Text;
        CompanyNameValue: Text;

        ServerName: Text;
        OperatingSystem: Text;
        CPUName: Text;
        LogicalProcessors: Integer;
        TotalRAM: Text;
        Is64BitOS: Boolean;
        Is64BitBC: Boolean;

        SQLServer: Text;
        SQLInstance: Text;
        SQLVersion: Text;
        SQLProductVersion: Text;
        SQLEdition: Text;
        DatabaseName: Text;

    local procedure LoadEnvironmentInformation()
    begin
        // Qui mettiamo la stessa logica di lettura
        // utilizzata dalla pagina Environment Inspector.
        //
        // Nessun INSERT
        // Nessun MODIFY
        // Nessuna tabella custom
    end;
}