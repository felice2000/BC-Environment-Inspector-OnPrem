page 90200 "Environment Inspector"
{
    PageType = Card;
    Caption = 'Environment Inspector';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(BusinessCentral)
            {
                Caption = 'Business Central';

                field(ApplicationVersion; ApplicationVersion)
                {
                    ApplicationArea = All;
                    Caption = 'Application Version';
                    Editable = false;
                }

                field(EnvironmentName; EnvironmentName)
                {
                    ApplicationArea = All;
                    Caption = 'Environment Name';
                    Editable = false;
                }

                field(DeploymentType; DeploymentType)
                {
                    ApplicationArea = All;
                    Caption = 'Deployment Type';
                    Editable = false;
                }

                field(EnvironmentType; EnvironmentType)
                {
                    ApplicationArea = All;
                    Caption = 'Environment Type';
                    Editable = false;
                }

                field(ApplicationFamily; ApplicationFamily)
                {
                    ApplicationArea = All;
                    Caption = 'Application Family';
                    Editable = false;
                }

                field(CurrentCompany; CurrentCompany)
                {
                    ApplicationArea = All;
                    Caption = 'Company';
                    Editable = false;
                }

                field(CurrentUser; CurrentUser)
                {
                    ApplicationArea = All;
                    Caption = 'User';
                    Editable = false;
                }
            }

            group(ServiceTier)
            {
                Caption = 'Business Central Service Tier';

                field(ServerName; ServerName)
                {
                    ApplicationArea = All;
                    Caption = 'Server Name';
                    Editable = false;
                }

                field(OSVersion; OSVersion)
                {
                    ApplicationArea = All;
                    Caption = 'Operating System';
                    Editable = false;
                }

                field(CPUModel; CPUModel)
                {
                    ApplicationArea = All;
                    Caption = 'CPU';
                    Editable = false;
                }

                field(ProcessorCount; ProcessorCount)
                {
                    ApplicationArea = All;
                    Caption = 'Logical Processors';
                    Editable = false;
                }

                field(TotalRAM; TotalRAM)
                {
                    ApplicationArea = All;
                    Caption = 'Total RAM';
                    Editable = false;
                }

                field(Is64BitOS; Is64BitOS)
                {
                    ApplicationArea = All;
                    Caption = '64-bit OS';
                    Editable = false;
                }

                field(Is64BitProcess; Is64BitProcess)
                {
                    ApplicationArea = All;
                    Caption = '64-bit BC Process';
                    Editable = false;
                }
            }

            group(SqlServer)
            {
                Caption = 'SQL Server';

                field(SqlServerName; SqlServerName)
                {
                    ApplicationArea = All;
                    Caption = 'Server Name';
                    Editable = false;
                }

                field(SqlInstanceName; SqlInstanceName)
                {
                    ApplicationArea = All;
                    Caption = 'Instance';
                    Editable = false;
                }

                field(SqlProductName; SqlProductName)
                {
                    ApplicationArea = All;
                    Caption = 'SQL Version';
                    Editable = false;
                }

                field(SqlProductVersion; SqlProductVersion)
                {
                    ApplicationArea = All;
                    Caption = 'Product Version';
                    Editable = false;
                }

                field(SqlEdition; SqlEdition)
                {
                    ApplicationArea = All;
                    Caption = 'Edition';
                    Editable = false;
                }

                field(SqlDatabaseName; SqlDatabaseName)
                {
                    ApplicationArea = All;
                    Caption = 'Database';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshInformation)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                ToolTip = 'Refreshes all environment information.';
                Image = Refresh;

                trigger OnAction()
                begin
                    LoadInformation();
                    CurrPage.Update(false);
                end;
            }

            action(ShowEnvironmentInfo)
            {
                ApplicationArea = All;
                Caption = 'Environment Info';
                ToolTip = 'Shows the environment information in a format that can be copied.';
                Image = View;

                trigger OnAction()
                begin
                    ShowEnvironmentInformation();
                end;
            }
        }

        area(Promoted)
        {
            actionref(RefreshInformationPromoted; RefreshInformation)
            {
            }

            actionref(ShowEnvironmentInfoPromoted; ShowEnvironmentInfo)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        LoadInformation();
    end;

    var
        ApplicationVersion: Text[50];
        EnvironmentName: Text[250];
        DeploymentType: Text[50];
        EnvironmentType: Text[50];
        ApplicationFamily: Text[50];
        CurrentCompany: Text[250];
        CurrentUser: Text[250];

        ServerName: Text[250];
        OSVersion: Text[250];
        CPUModel: Text[250];
        ProcessorCount: Integer;
        TotalRAM: Text[50];
        Is64BitOS: Boolean;
        Is64BitProcess: Boolean;

        SqlServerName: Text[250];
        SqlInstanceName: Text[250];
        SqlProductName: Text[100];
        SqlProductVersion: Text[100];
        SqlEdition: Text[250];
        SqlDatabaseName: Text[250];

    local procedure LoadInformation()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        ApplicationVersion := GetBaseApplicationVersion();

        EnvironmentName := EnvironmentInformation.GetEnvironmentName();
        ApplicationFamily := EnvironmentInformation.GetApplicationFamily();

        if EnvironmentInformation.IsOnPrem() then
            DeploymentType := 'On-Premises'
        else
            if EnvironmentInformation.IsSaaS() then
                DeploymentType := 'SaaS'
            else
                DeploymentType := 'Unknown';

        if EnvironmentInformation.IsProduction() then
            EnvironmentType := 'Production'
        else
            if EnvironmentInformation.IsSandbox() then
                EnvironmentType := 'Sandbox'
            else
                EnvironmentType := 'Unknown';

        CurrentCompany := CompanyName();
        CurrentUser := UserId();

        LoadServerInformation();
        LoadSqlInformation();

        SqlDatabaseName := GetCurrentDatabaseName();
    end;

    local procedure GetBaseApplicationVersion(): Text
    var
        BaseApplicationInfo: ModuleInfo;
        BaseApplicationId: Guid;
    begin
        BaseApplicationId := '437dbf0e-84ff-417a-965d-ed2bb9650972';

        if NavApp.GetModuleInfo(BaseApplicationId, BaseApplicationInfo) then
            exit(Format(BaseApplicationInfo.AppVersion()));

        exit('Unknown');
    end;

    local procedure GetCurrentDatabaseName(): Text
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.SetRange("Session ID", SessionId());

        if ActiveSession.FindFirst() then
            exit(ActiveSession."Database Name");

        exit('Unknown');
    end;

    local procedure LoadServerInformation()
    var
        Environment: DotNet DotNetEnvironment;
    begin
        ServerName := Environment.MachineName;
        OSVersion := GetWindowsVersion();
        CPUModel := GetCPUModel();
        ProcessorCount := Environment.ProcessorCount;
        TotalRAM := GetTotalRAM();
        Is64BitOS := Environment.Is64BitOperatingSystem;
        Is64BitProcess := Environment.Is64BitProcess;
    end;

    local procedure GetWindowsVersion(): Text
    var
        BaseKey: DotNet DotNetRegistryKey;
        RegistryKey: DotNet DotNetRegistryKey;
        RegistryHive: DotNet DotNetRegistryHive;
        RegistryView: DotNet DotNetRegistryView;
        ProductName: Text[250];
        DisplayVersion: Text[50];
        CurrentBuild: Text[50];
        CurrentBuildNo: Integer;
    begin
        BaseKey := BaseKey.OpenBaseKey(
            RegistryHive.LocalMachine,
            RegistryView.Registry64);

        RegistryKey := BaseKey.OpenSubKey(
            'SOFTWARE\Microsoft\Windows NT\CurrentVersion');

        if IsNull(RegistryKey) then begin
            BaseKey.Close();
            exit('Unknown');
        end;

        ProductName := Format(RegistryKey.GetValue('ProductName'));
        DisplayVersion := Format(RegistryKey.GetValue('DisplayVersion'));
        CurrentBuild := Format(RegistryKey.GetValue('CurrentBuild'));

        RegistryKey.Close();
        BaseKey.Close();

        if Evaluate(CurrentBuildNo, CurrentBuild) then
            if CurrentBuildNo >= 22000 then
                ProductName :=
                    ProductName.Replace(
                        'Windows 10',
                        'Windows 11');

        ProductName :=
            ProductName.Replace(
                'Microsoft ',
                '');

        if DisplayVersion <> '' then
            exit(ProductName + ' ' + DisplayVersion);

        exit(ProductName);
    end;

    local procedure GetCPUModel(): Text
    var
        Searcher: DotNet DotNetManagementObjectSearcher;
        Collection: DotNet DotNetManagementObjectCollection;
        ManagementObject: DotNet DotNetManagementObject;
        CPUName: Text[250];
    begin
        Searcher :=
            Searcher.ManagementObjectSearcher(
                'SELECT Name FROM Win32_Processor');

        Collection := Searcher.Get();

        foreach ManagementObject in Collection do begin
            CPUName := Format(ManagementObject.Item('Name'));

            Searcher.Dispose();
            Collection.Dispose();

            exit(CPUName);
        end;

        Searcher.Dispose();
        Collection.Dispose();

        exit('Unknown');
    end;

    local procedure GetTotalRAM(): Text
    var
        Searcher: DotNet DotNetManagementObjectSearcher;
        Collection: DotNet DotNetManagementObjectCollection;
        ManagementObject: DotNet DotNetManagementObject;
        TotalMemoryBytes: Decimal;
        TotalMemoryGB: Decimal;
    begin
        Searcher :=
            Searcher.ManagementObjectSearcher(
                'SELECT TotalPhysicalMemory FROM Win32_ComputerSystem');

        Collection := Searcher.Get();

        foreach ManagementObject in Collection do begin
            if Evaluate(
                TotalMemoryBytes,
                Format(
                    ManagementObject.Item(
                        'TotalPhysicalMemory')))
            then begin
                TotalMemoryGB :=
                    TotalMemoryBytes /
                    1024 /
                    1024 /
                    1024;

                Searcher.Dispose();
                Collection.Dispose();

                exit(
                    Format(
                        Round(
                            TotalMemoryGB,
                            0.1)) +
                    ' GB');
            end;
        end;

        Searcher.Dispose();
        Collection.Dispose();

        exit('Unknown');
    end;

    local procedure LoadSqlInformation()
    begin
        ClearSqlInformation();

        if not TryLoadSqlInformation() then
            SqlServerName := 'Unable to retrieve SQL information';
    end;

    [TryFunction]
    local procedure TryLoadSqlInformation()
    var
        SqlConnection: DotNet DotNetSqlConnection;
        SqlCommand: DotNet DotNetSqlCommand;
        SqlReader: DotNet DotNetSqlDataReader;
        ConnectionString: Text;
        QueryText: Text;
    begin
        ConnectionString :=
            'Server=localhost;' +
            'Integrated Security=True;' +
            'TrustServerCertificate=True;';

        SqlConnection :=
            SqlConnection.SqlConnection();

        SqlConnection.ConnectionString :=
            ConnectionString;

        SqlConnection.Open();

        QueryText :=
            'SELECT ' +
            'CAST(SERVERPROPERTY(''ServerName'') AS nvarchar(250)), ' +
            'CAST(SERVERPROPERTY(''InstanceName'') AS nvarchar(250)), ' +
            'CAST(SERVERPROPERTY(''ProductVersion'') AS nvarchar(100)), ' +
            'CAST(SERVERPROPERTY(''Edition'') AS nvarchar(250));';

        SqlCommand := SqlConnection.CreateCommand();
        SqlCommand.CommandText := QueryText;

        SqlReader := SqlCommand.ExecuteReader();

        if SqlReader.Read() then begin
            SqlServerName := GetSqlString(SqlReader, 0);
            SqlInstanceName := GetSqlString(SqlReader, 1);
            SqlProductVersion := GetSqlString(SqlReader, 2);
            SqlEdition := GetSqlString(SqlReader, 3);

            SqlProductName :=
                GetSqlProductName(
                    SqlProductVersion);
        end;

        SqlReader.Close();
        SqlConnection.Close();
    end;

    local procedure GetSqlString(
        SqlReader: DotNet DotNetSqlDataReader;
        ColumnIndex: Integer): Text
    begin
        if SqlReader.IsDBNull(ColumnIndex) then
            exit('');

        exit(
            Format(
                SqlReader.GetValue(
                    ColumnIndex)));
    end;

    local procedure GetSqlProductName(ProductVersion: Text): Text
    var
        DotPosition: Integer;
        MajorVersionText: Text[10];
        MajorVersion: Integer;
    begin
        if ProductVersion = '' then
            exit('Unknown');

        DotPosition := StrPos(ProductVersion, '.');

        if DotPosition = 0 then
            exit('Unknown');

        MajorVersionText :=
            CopyStr(
                ProductVersion,
                1,
                DotPosition - 1);

        if not Evaluate(
            MajorVersion,
            MajorVersionText)
        then
            exit('Unknown');

        case MajorVersion of
            17:
                exit('SQL Server 2025');
            16:
                exit('SQL Server 2022');
            15:
                exit('SQL Server 2019');
            14:
                exit('SQL Server 2017');
            13:
                exit('SQL Server 2016');
            12:
                exit('SQL Server 2014');
            11:
                exit('SQL Server 2012');
            10:
                exit('SQL Server 2008 / 2008 R2');
            else
                exit(
                    'SQL Server - Major Version ' +
                    Format(MajorVersion));
        end;
    end;

    local procedure ClearSqlInformation()
    begin
        Clear(SqlServerName);
        Clear(SqlInstanceName);
        Clear(SqlProductName);
        Clear(SqlProductVersion);
        Clear(SqlEdition);
    end;

    local procedure ShowEnvironmentInformation()
    var
        EnvironmentText: Text;
    begin
        EnvironmentText := BuildEnvironmentInformation();

        Message(EnvironmentText);
    end;

    local procedure BuildEnvironmentInformation(): Text
    var
        EnvironmentText: TextBuilder;
    begin
        EnvironmentText.AppendLine(
            '=== Business Central Environment ===');

        EnvironmentText.AppendLine('');

        EnvironmentText.AppendLine(
            'Business Central');

        EnvironmentText.AppendLine(
            'Application Version: ' +
            ApplicationVersion);

        EnvironmentText.AppendLine(
            'Environment Name: ' +
            EnvironmentName);

        EnvironmentText.AppendLine(
            'Deployment Type: ' +
            DeploymentType);

        EnvironmentText.AppendLine(
            'Environment Type: ' +
            EnvironmentType);

        EnvironmentText.AppendLine(
            'Application Family: ' +
            ApplicationFamily);

        EnvironmentText.AppendLine(
            'Company: ' +
            CurrentCompany);

        EnvironmentText.AppendLine('');

        EnvironmentText.AppendLine(
            'Business Central Service Tier');

        EnvironmentText.AppendLine(
            'Server Name: ' +
            ServerName);

        EnvironmentText.AppendLine(
            'Operating System: ' +
            OSVersion);

        EnvironmentText.AppendLine(
            'CPU: ' +
            CPUModel);

        EnvironmentText.AppendLine(
            'Logical Processors: ' +
            Format(ProcessorCount));

        EnvironmentText.AppendLine(
            'Total RAM: ' +
            TotalRAM);

        EnvironmentText.AppendLine(
            '64-bit OS: ' +
            FormatBoolean(Is64BitOS));

        EnvironmentText.AppendLine(
            '64-bit BC Process: ' +
            FormatBoolean(Is64BitProcess));

        EnvironmentText.AppendLine('');

        EnvironmentText.AppendLine(
            'SQL Server');

        EnvironmentText.AppendLine(
            'Server Name: ' +
            SqlServerName);

        if SqlInstanceName <> '' then
            EnvironmentText.AppendLine(
                'Instance: ' +
                SqlInstanceName);

        EnvironmentText.AppendLine(
            'SQL Version: ' +
            SqlProductName);

        EnvironmentText.AppendLine(
            'Product Version: ' +
            SqlProductVersion);

        EnvironmentText.AppendLine(
            'Edition: ' +
            SqlEdition);

        EnvironmentText.AppendLine(
            'Database: ' +
            SqlDatabaseName);

        exit(EnvironmentText.ToText());
    end;

    local procedure FormatBoolean(Value: Boolean): Text
    begin
        if Value then
            exit('Yes');

        exit('No');
    end;
}