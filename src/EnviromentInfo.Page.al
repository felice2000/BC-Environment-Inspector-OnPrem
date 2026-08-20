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
                ToolTip = 'Shows a formatted summary of the current environment.';
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

        ConfiguredDatabaseServer: Text[250];
        ConfiguredDatabaseInstance: Text[250];

    local procedure LoadInformation()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        ApplicationVersion := GetBaseApplicationVersion();

        EnvironmentName :=
            EnvironmentInformation.GetEnvironmentName();

        ApplicationFamily :=
            EnvironmentInformation.GetApplicationFamily();

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

        SqlDatabaseName := GetCurrentDatabaseName();

        LoadServerInformation();
        LoadSqlInformation();
    end;

    local procedure GetBaseApplicationVersion(): Text
    var
        BaseApplicationInfo: ModuleInfo;
        BaseApplicationId: Guid;
    begin
        BaseApplicationId :=
            '437dbf0e-84ff-417a-965d-ed2bb9650972';

        if NavApp.GetModuleInfo(
            BaseApplicationId,
            BaseApplicationInfo)
        then
            exit(
                Format(
                    BaseApplicationInfo.AppVersion()));

        exit('Unknown');
    end;

    local procedure GetCurrentDatabaseName(): Text
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.SetRange(
            "Session ID",
            SessionId());

        if ActiveSession.FindFirst() then
            exit(
                ActiveSession."Database Name");

        exit('Unknown');
    end;

    local procedure GetCurrentServerInstanceName(): Text
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.SetRange(
            "Session ID",
            SessionId());

        if ActiveSession.FindFirst() then
            exit(
                ActiveSession."Server Instance Name");

        exit('');
    end;

    local procedure LoadServerInformation()
    var
        Environment: DotNet DotNetEnvironment;
    begin
        ServerName :=
            Environment.MachineName;

        OSVersion :=
            GetWindowsVersion();

        CPUModel :=
            GetCPUModel();

        ProcessorCount :=
            Environment.ProcessorCount;

        TotalRAM :=
            GetTotalRAM();

        Is64BitOS :=
            Environment.Is64BitOperatingSystem;

        Is64BitProcess :=
            Environment.Is64BitProcess;
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
        BaseKey :=
            BaseKey.OpenBaseKey(
                RegistryHive.LocalMachine,
                RegistryView.Registry64);

        RegistryKey :=
            BaseKey.OpenSubKey(
                'SOFTWARE\Microsoft\Windows NT\CurrentVersion');

        if IsNull(RegistryKey) then begin
            BaseKey.Close();
            exit('Unknown');
        end;

        ProductName :=
            Format(
                RegistryKey.GetValue(
                    'ProductName'));

        DisplayVersion :=
            Format(
                RegistryKey.GetValue(
                    'DisplayVersion'));

        CurrentBuild :=
            Format(
                RegistryKey.GetValue(
                    'CurrentBuild'));

        RegistryKey.Close();
        BaseKey.Close();

        if Evaluate(
            CurrentBuildNo,
            CurrentBuild)
        then
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
            exit(
                ProductName +
                ' ' +
                DisplayVersion);

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

        Collection :=
            Searcher.Get();

        foreach ManagementObject in Collection do begin
            CPUName :=
                Format(
                    ManagementObject.Item(
                        'Name'));

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

        Collection :=
            Searcher.Get();

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
            SqlServerName :=
                'Unable to retrieve SQL information';
    end;

    [TryFunction]
    local procedure TryLoadSqlInformation()
    var
        SqlConnection: DotNet DotNetSqlConnection;
        SqlCommand: DotNet DotNetSqlCommand;
        SqlReader: DotNet DotNetSqlDataReader;
        ConnectionString: Text;
        QueryText: Text;
        SqlDataSource: Text;
    begin
        LoadDatabaseConfiguration();

        if ConfiguredDatabaseServer = '' then
            Error(
                'Unable to determine the SQL Server configured for this Business Central Server instance.');

        SqlDataSource :=
            BuildSqlDataSource();

        ConnectionString :=
            'Server=' +
            SqlDataSource +
            ';' +
            'Database=' +
            SqlDatabaseName +
            ';' +
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

        SqlCommand :=
            SqlConnection.CreateCommand();

        SqlCommand.CommandText :=
            QueryText;

        SqlReader :=
            SqlCommand.ExecuteReader();

        if SqlReader.Read() then begin
            SqlServerName :=
                GetSqlString(
                    SqlReader,
                    0);

            SqlInstanceName :=
                GetSqlString(
                    SqlReader,
                    1);

            SqlProductVersion :=
                GetSqlString(
                    SqlReader,
                    2);

            SqlEdition :=
                GetSqlString(
                    SqlReader,
                    3);

            SqlProductName :=
                GetSqlProductName(
                    SqlProductVersion);
        end;

        SqlReader.Close();
        SqlConnection.Close();
    end;

    local procedure BuildSqlDataSource(): Text
    var
        DataSource: Text;
    begin
        DataSource :=
            ConfiguredDatabaseServer;

        if ConfiguredDatabaseInstance <> '' then
            if StrPos(
                ConfiguredDatabaseServer,
                '\') = 0
            then
                DataSource :=
                    DataSource +
                    '\' +
                    ConfiguredDatabaseInstance;

        exit(DataSource);
    end;

    local procedure LoadDatabaseConfiguration()
    var
        DotNetFile: DotNet DotNetFile;
        ConfigPath: Text;
        ConfigContent: Text;
        ConfigDocument: XmlDocument;
    begin
        Clear(ConfiguredDatabaseServer);
        Clear(ConfiguredDatabaseInstance);

        ConfigPath :=
            GetCustomSettingsPath();

        if ConfigPath = '' then
            Error(
                'Unable to locate CustomSettings.config for the current Business Central Server instance.');

        ConfigContent :=
            DotNetFile.ReadAllText(
                ConfigPath);

        if not XmlDocument.ReadFrom(
            ConfigContent,
            ConfigDocument)
        then
            Error(
                'Unable to parse CustomSettings.config.');

        ConfiguredDatabaseServer :=
            GetServerConfigValue(
                ConfigDocument,
                'DatabaseServer');

        ConfiguredDatabaseInstance :=
            GetServerConfigValue(
                ConfigDocument,
                'DatabaseInstance');
    end;

    local procedure GetCustomSettingsPath(): Text
    var
        Searcher: DotNet DotNetManagementObjectSearcher;
        Collection: DotNet DotNetManagementObjectCollection;
        ManagementObject: DotNet DotNetManagementObject;
        DotNetFile: DotNet DotNetFile;
        DotNetPath: DotNet DotNetPath;
        ServerInstanceName: Text;
        WindowsServiceName: Text;
        ServicePath: Text;
        ExecutablePath: Text;
        ServiceDirectory: Text;
        ConfigPath: Text;
    begin
        ServerInstanceName :=
            GetCurrentServerInstanceName();

        if ServerInstanceName = '' then
            exit('');

        if StrPos(
            ServerInstanceName,
            'MicrosoftDynamicsNavServer$') = 1
        then
            WindowsServiceName :=
                ServerInstanceName
        else
            WindowsServiceName :=
                'MicrosoftDynamicsNavServer$' +
                ServerInstanceName;

        Searcher :=
            Searcher.ManagementObjectSearcher(
                'SELECT PathName FROM Win32_Service WHERE Name = ''' +
                WindowsServiceName +
                '''');

        Collection :=
            Searcher.Get();

        foreach ManagementObject in Collection do begin
            ServicePath :=
                Format(
                    ManagementObject.Item(
                        'PathName'));

            ExecutablePath :=
                ExtractExecutablePath(
                    ServicePath);

            Searcher.Dispose();
            Collection.Dispose();

            if ExecutablePath = '' then
                exit('');

            ServiceDirectory :=
                DotNetPath.GetDirectoryName(
                    ExecutablePath);

            ConfigPath :=
                DotNetPath.Combine(
                    ServiceDirectory,
                    'Instances\' +
                    ServerInstanceName +
                    '\CustomSettings.config');

            if DotNetFile.Exists(
                ConfigPath)
            then
                exit(ConfigPath);

            ConfigPath :=
                DotNetPath.Combine(
                    ServiceDirectory,
                    'CustomSettings.config');

            if DotNetFile.Exists(
                ConfigPath)
            then
                exit(ConfigPath);

            exit('');
        end;

        Searcher.Dispose();
        Collection.Dispose();

        exit('');
    end;

    local procedure ExtractExecutablePath(ServicePath: Text): Text
    var
        RemainingText: Text;
        ClosingQuotePosition: Integer;
        SpacePosition: Integer;
    begin
        ServicePath :=
            ServicePath.Trim();

        if ServicePath = '' then
            exit('');

        if CopyStr(
            ServicePath,
            1,
            1) = '"'
        then begin
            RemainingText :=
                CopyStr(
                    ServicePath,
                    2);

            ClosingQuotePosition :=
                StrPos(
                    RemainingText,
                    '"');

            if ClosingQuotePosition > 0 then
                exit(
                    CopyStr(
                        RemainingText,
                        1,
                        ClosingQuotePosition - 1));
        end;

        SpacePosition :=
            StrPos(
                ServicePath,
                ' ');

        if SpacePosition > 0 then
            exit(
                CopyStr(
                    ServicePath,
                    1,
                    SpacePosition - 1));

        exit(ServicePath);
    end;

    local procedure GetServerConfigValue(
        ConfigDocument: XmlDocument;
        KeyName: Text): Text
    var
        ConfigNode: XmlNode;
        ConfigElement: XmlElement;
        ValueAttribute: XmlAttribute;
        XPath: Text;
    begin
        XPath :=
            StrSubstNo(
                '//appSettings/add[@key=''%1'']',
                KeyName);

        if not ConfigDocument.SelectSingleNode(
            XPath,
            ConfigNode)
        then
            exit('');

        ConfigElement :=
            ConfigNode.AsXmlElement();

        if not ConfigElement.Attributes().Get(
            'value',
            ValueAttribute)
        then
            exit('');

        exit(
            ValueAttribute.Value());
    end;

    local procedure GetSqlString(
        SqlReader: DotNet DotNetSqlDataReader;
        ColumnIndex: Integer): Text
    begin
        if SqlReader.IsDBNull(
            ColumnIndex)
        then
            exit('');

        exit(
            Format(
                SqlReader.GetValue(
                    ColumnIndex)));
    end;

    local procedure GetSqlProductName(
        ProductVersion: Text): Text
    var
        DotPosition: Integer;
        MajorVersionText: Text[10];
        MajorVersion: Integer;
    begin
        if ProductVersion = '' then
            exit('Unknown');

        DotPosition :=
            StrPos(
                ProductVersion,
                '.');

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
                    Format(
                        MajorVersion));
        end;
    end;

    local procedure ClearSqlInformation()
    begin
        Clear(SqlServerName);
        Clear(SqlInstanceName);
        Clear(SqlProductName);
        Clear(SqlProductVersion);
        Clear(SqlEdition);
        Clear(ConfiguredDatabaseServer);
        Clear(ConfiguredDatabaseInstance);
    end;

    local procedure ShowEnvironmentInformation()
    var
        EnvironmentText: Text;
    begin
        EnvironmentText :=
            BuildEnvironmentInformation();

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
            Format(
                ProcessorCount));

        EnvironmentText.AppendLine(
            'Total RAM: ' +
            TotalRAM);

        EnvironmentText.AppendLine(
            '64-bit OS: ' +
            FormatBoolean(
                Is64BitOS));

        EnvironmentText.AppendLine(
            '64-bit BC Process: ' +
            FormatBoolean(
                Is64BitProcess));

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

        exit(
            EnvironmentText.ToText());
    end;

    local procedure FormatBoolean(
        Value: Boolean): Text
    begin
        if Value then
            exit('Yes');

        exit('No');
    end;
}